function savedxb(name, mdir, rhs, model_type, numForce)

global forcesym parsym forcei pari dforcesym dforcei varsym vari include_force

% saving vector field derivatives of parameters
disp(['Creating (dy/dp)/dy matrix, file ' name '_dxb.m']);
namer = fullfile(mdir,[name '_dxb.m']);

syms y;
dim = length(rhs);
for j=1:dim
  y(j) = (['y',num2str(j)]);
end

file = fopen(namer,'w');
fileheader(file, name,'- d_x b(s)');
fprintf(file, 'function dxb = %s_dxb(t,y,p, ModelForce, CP)\n\n', name);
if numForce > 0
    fprintf(file, '\tforce = get_force(t, ModelForce, CP, ''%s'');\n', model_type);
     if include_force
         %derivatives with respect to force needed
        fprintf(file, '\t[df_ddawn df_ddusk] = get_dforce_ddawn(t, ModelForce, CP, ''%s'');\n\n', model_type);
     end
end

%calc derivative with respect to parameter
for p = 1:length(parsym)
   pv(p) = sym(parsym{p});
end
parn = parsym;
jac1 = jacobian(rhs,pv); %dy/dp

if include_force
    %now with respect to forces
    for i = 1:length(forcesym)
        pv = sym(forcesym{i});
        df = jacobian(rhs, pv);%dy/dforce
        %with repect to dawn, dy/ddawn is dy/dforce * dforce/ddawn
        ddawn = df .* sym(['df_ddawn' num2str(i)]);
        %and dusk
        ddusk = df .* sym(['df_ddusk' num2str(i)]);
        jac1 = [jac1 ddawn ddusk];
        parn{end+1} = ['dawn' num2str(i) ', ' forcesym{i}];
        parn{end+1} = ['dusk' num2str(i) ', ' forcesym{i}];
    end
end

jac1 = fastsubs(jac1,[forcesym dforcesym parsym], [forcei dforcei pari]);
fprintf(1, '\tcalculation for %d variables:',dim);


for k=1:dim
    dxb{k} = diff(jac1, y(k));  %(dy/dpar)/dy
    dif = dxb{k};
    [m,n] = size(dif);
    fprintf(file,'\t%% derivative of dy/dp by variable %d\n', k);
    fprintf(file,'\tc = zeros(%d,%d);\n',m,n);
    for i=1:m 
        for j=1:n 
            if dif(i,j)~= 0
                dif(i,j) = fastsubs(dif(i,j), varsym, vari);
                z = ['c(',num2str(i),',',num2str(j),')= ',...
                    char(dif(i,j)), ';'];
                fprintf(file,'\t%s\n',z);    
            end
        end
    end
    fprintf(file,'\tdxb{%d} = c;\n\n',k);  
    fprintf(1,' %d ',k);
    if ~mod(k,20)
      fprintf(1, '\n');      
    end
end
fprintf(1, '\n');  
fclose(file);

