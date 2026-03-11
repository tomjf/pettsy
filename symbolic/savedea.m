function savedea(name, mdir, rhs, model_type, numForce)

%This is (dy/dy)/dp

global varsym vari forcesym parsym forcei pari include_force

% generating linearized system m-file

disp(['Creating (dy/dy)/dp matrix, file ' name '_dea.m']);
namer = fullfile(mdir,[name '_dea.m']);

dim = length(rhs);
syms y jac jac1 dif;
for j=1:dim
  y(j) = (['y',num2str(j)]);
end

jac = jacobian(rhs,y);
jac1 = subs(jac, str2sym(varsym), str2sym(vari));%replace y1 with y(1) ...

file = fopen(namer,'w');
fileheader(file, name,'d_eps A');

fprintf(file,'function dea = %s_dea(t,y,p, ModelForce,CP)\n\n', name);
%add the force options, including df_ddawn and df_ddusk
if numForce > 0
    fprintf(file, '\tforce = get_force(t, ModelForce, CP, ''%s'');\n\n', model_type);
    if include_force
        %need derivatives with respect to force
        fprintf(file, '\t[df_ddawn df_ddusk] = get_dforce_ddawn(t, ModelForce, CP, ''%s'');\n\n', model_type);
    end
end

%calc derivative with respect to parameter
for p = 1:length(parsym)
   pv(p) = sym(parsym{p});
end
parn = parsym;
for k=1:length(pv)
    dif1{k} = diff(jac1,pv(k)); %this gives dim * dim matrix
end

if include_force
    %now with respect to forces
    for i = 1:length(forcesym)
        pv = sym(forcesym{i});
        %df = jacobian(jac1, pv);    %dy/dforce, a dim^2 by 1 vector, a martix with cols stacked
        %PEB changed this to
        df = diff(jac1, pv);    %as this gives a dim*dim matrix
        
        %with repect to dawn, dy/ddawn is dy/dforce * dforce/ddawn
        ddawn = df .* sym(['df_ddawn' num2str(i)]); %this gives dim * dim matrix with respect to dawn
        dif1{end+1} = ddawn;
        parn{end+1} = ['dawn' num2str(i) ', ' forcesym{i}];
        %and dusk
        ddusk = df .* sym(['df_ddusk' num2str(i)]);
        dif1{end+1} = ddusk;
        parn{end+1} = ['dusk' num2str(i) ', ' forcesym{i}];
    end
end

dimm = 1;
if dim > dimm
    fprintf(1, '\tcalculation for %d parameters:',length(parn));
end

for k=1:length(dif1)
    dif = fastsubs(dif1{k},[forcesym parsym], [forcei pari]);
    
    fprintf(file,'\tdea{%d} = [\n',k); % for each param,      
    fprintf(file,'\t\t%%Derivative of model jacobian dy/dy with respect to parameter %s\n', char(parn{k}));
    %create i*j matrix for paramter k
    for i=1:dim 
        z = '';
        fprintf(file,'\t\t[');
        for j=1:dim
            z = [z, '(', char(dif(i,j)), ') '];
        end
        fprintf(file,' %s ];\n',z);
    end
    fprintf(file,'\t];\n\n');
   
    
    if dim > dimm
       fprintf(1,' %d ',k);
       if ~mod(k,20)
          fprintf(1, '\n');      
        end
    end
    
end
if dim > dimm
    fprintf(1, '\n');      
end
fclose(file);