function savedeb(name, mdir, rhs, model_type, numForce)

global forcesym parsym forcei pari dforcesym dforcei varsym vari include_force

disp(['Creating (dy/dp)/dp matrix, file ' name '_deb.m']);

namer = fullfile(mdir,[name '_deb.m']);
file = fopen(namer, 'w');
fileheader(file, name,'d_eps b(s)');

dim = length(rhs);

%This matrix is a special case. Here we need to differentiate twice with
%respect to dawn and dusk. We can't just calculate dy/dawn = dy/dforce *
%dforce_ddawn as the symbolic expression dforce_ddawn will be replaced with
%one containing dawn at run time and the code that does the differentiation
%here can't know this, ie if dy/dforce = z, and dy/ddawn = z*dforce_ddawn,
%then (dy/ddawn)/ddawn would be zero as code doesn't know that dforce_ddawn
%will contain dawn.

%This doesn't work for > 1 force. What about (dy/ddusk1)/ddusk2 etc...?
%dforce1/ddawn2 will always be zero??? etc...

%calc derivative with respect to parameter
for p = 1:length(parsym)
   pv(p) = sym(parsym{p});
end
parn = parsym;
jac1 = jacobian(rhs,pv); %in savedifpar we replace y1 with y(1). don't do that here. Does this matter??

if include_force
    %add cols for each dawn/dusk for every force
    %now with respect to forces
    for i = 1:length(forcesym)
        pv = sym(forcesym{i});
        df = jacobian(rhs, pv);
        %with repect to dawn, dy/ddawn is dy/dforce * dforce/ddawn
        ddawn = df .* sym(['df_ddawn' num2str(i)]);
        %and dusk
        ddusk = df .* sym(['df_ddusk' num2str(i)]);
        jac1 = [jac1 ddawn ddusk];
    end
end
jac1 = subs(jac1, str2sym(varsym), str2sym(vari));

%jac1 is dy/dp

% Now get (dy/dp)/dp
fprintf(1, '\tpreparing %d parameters:',length(parsym));
%calc derivative with respect to parameter
for p = 1:length(parsym)
   pv(p) = sym(parsym{p});
end
for k=1:length(pv)
    fprintf(1,' %d ',k);
    if ~mod(k,20)
        fprintf(1, '\n');
    end
    dif1{k} = diff(jac1,pv(k));%(dy/dp)/dp_k Row
end

if include_force    
    %Add dawn and dusk matrices
    %here differentiating twice with respect to dawn and dusk can't
    %differentiate d(dy/dforce * dforce/ddawn) / ddawn as we don't
    %know what dforce/ddawn is until runtime. Instead we use the formula
    %d2y/ddawn2 = (d2y/dforce2)*(dforce/ddawn)^2 + (dy/dforce)*(d2force/ddawn2)
    %with symbolic variables to calculate the second derivative of y
    %with respect to dawn and dusk
    
    numforce = length(forcesym);
    
    
    for f = 1:numforce
        syms tmp;
        %for each force
        pv = sym(forcesym{f});
        
        m = jacobian(jac1(:,length(parsym)), pv); %(dy/dp)/dforce
        for c = 1:length(parsym)
            %change to dy/dp * df/ddawn
            for r = 1:dim%for each y
                tmp = m(r,c);   %before euse of tmp variable, this wasn't done properly as no brackets put around m(r,c), ie a+b * df_ddawn would be written as a+b*df_ddawn rather than (a+b)*df_ddawn
                eval(['tmp = tmp * df_ddawn' num2str(f) ';']);
                m(r,c) = tmp;
            end
        end
        %only the first cols referring to parameters, not dawn/dusk, can be
        %done like this, for the reasons above. For the remaining columns, we
        %need to get (dy/ddawn)/ddawn etc as below
        
        dawncol = [];duskcol = [];
        for r = 1:dim
            %calc its second derivative with respect to dawn.
            %%d2y/ddawn2 = (d2y/dforce2)*(dforce/ddawn)^2 + (dy/dforce)*(d2force/ddawn2)
            dawncol = [dawncol; diff(rhs(r), pv, 2) * sym(['df_ddawn' num2str(f)])^2 + diff(rhs(r), pv) * sym(['d2f_ddawn2' num2str(f)])];
            %(dy/dusk)/ddawn = (d2y/dforce2)*(dforce/ddawn)* (dforce/ddusk) + (dy/dforce)*((dforce/ddusk)/dawn)
            duskcol = [duskcol; diff(rhs(r), pv, 2) * sym(['df_ddusk' num2str(f)]) * sym(['df_ddawn' num2str(f)]) + diff(rhs(r), pv)* sym(['df_ddusk_ddawn' num2str(f)])];
        end
        m = [m dawncol duskcol];
        dif1{end+1} = m;
        parn{end+1} = ['dawn' num2str(f) ', ' pv];
        
        
        %repeat for dusk
        m = jacobian(jac1(:,length(parsym)), pv); %(dy/dp)/dforce
        for c = 1:length(parsym)
            %change to dy/dp * df/ddawn
            for r = 1:dim%for each y
                tmp = m(r,c);   %before euse of tmp variable, this wasn't done properly as no brackets put around m(r,c), ie a+b * df_ddawn would be written as a+b*df_ddawn rather than (a+b)*df_ddawn
                eval(['tmp = tmp * df_ddusk' num2str(f) ';']);
                m(r,c) = tmp;
            end
        end
        
        dawncol = [];duskcol = [];
        for r = 1:dim
            %calc its second derivative with respect to dawn.
            %(dy/ddusk)/ddusk
            duskcol = [duskcol; diff(rhs(r), pv, 2) * sym(['df_ddusk' num2str(f)])^2 + diff(rhs(r), pv)*sym(['d2f_ddusk2' num2str(f)])];
            %(dy/dawn)/ddusk
            dawncol = [dawncol; diff(rhs(r), pv, 2) * sym(['df_ddusk' num2str(f)]) * sym(['df_ddawn' num2str(f)]) + diff(rhs(r), pv)* sym(['df_ddawn_ddusk' num2str(f)])];
        end
        m = [m dawncol duskcol];
        dif1{end+1} = m;
        parn{end+1} = ['dusk' num2str(f) ', ' pv];
        
    end
    
end



fprintf(1,' %d ',length(parn));
fprintf(1, '\n');    
fprintf(1, '\tfor %d parameters:',length(parn));
fprintf(file,'function deb = %s_deb(t,y,p)\n\n', name);


if numForce > 0
    fprintf(file, '\tforce = get_force(t, ModelForce, CP, ''%s'');\n', model_type);
    if include_force
        %derivatives with respect to force required
        %this function won't actually return the second derivatives yet
        fprintf(file, '\t[df_ddawn df_ddusk d2f_ddawn2 d2f_ddusk2 df_ddawn_ddusk df_ddusk_ddawn] = get_dforce_ddawn(t, ModelForce, CP, ''%s'');\n\n', model_type);
    end
end

for k=1:length(dif1)
    dif = dif1{k};
    [m,n] = size(dif);
    fprintf(file,'\t%% derivative of dy/dp by parameter %d, %s\n', k, parn{k});
    fprintf(file,'\tc = zeros(%d,%d);\n',m,n);    
    for i=1:m
        for j=1:n
            if dif(i,j)~= 0
                dif(i,j) = fastsubs(dif(i,j), [forcesym parsym dforcesym], [forcei pari dforcei]);
                z = ['c(',num2str(i),',',num2str(j),')= ',...
                    char(dif(i,j)), ';'];
                fprintf(file,'\t%s\n',z);
            end
        end
    end
   fprintf(file,'\tdeb{%d} = c;\n\n',k);       
   fprintf(1,' %d ',k);
   if ~mod(k,20)
      fprintf(1, '\n');      
   end
end
fprintf(1, '\n');      
fclose(file);


