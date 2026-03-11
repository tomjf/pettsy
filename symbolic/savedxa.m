function savedxa(name, mdir, rhs, model_type, numForce)

%This is (dy/dy)/dy

global varsym vari forcesym parsym forcei pari 

% generating dxadex m-file

disp(['Creating (dy/dy)/dy matrix, file ' name '_dxa.m']);
namer = fullfile(mdir,[name '_dxa.m']);

dim = length(rhs);
syms y jac1 jac;
for j=1:dim
  y(j) = (['y',num2str(j)]);
end

jac1 = jacobian(rhs,y); %dy/dy
jac1 = subs(jac1, [str2sym(forcesym) str2sym(parsym)], [str2sym(forcei) str2sym(pari)]);%replace param names with p(n)

for k=1:dim
    dxa{k} = diff(jac1,y(k)); %d^2y/dy^2
end

file = fopen(namer,'w');
fileheader(file, name,'dxa');
fprintf(file,'function dxa = %s_dxa(t,y,p, ModelForce, CP)\n\n', name);
if numForce > 0
    fprintf(file, '\tforce = get_force(t, ModelForce, CP, ''%s'');\n\n', model_type);
end

fprintf(1, '\tcalculation for %d variables:',dim);
fprintf(file, '\t%%d^2y/dy^2 Derivative of jacobian matrix with respect to y\n\n');
for k=1:dim
    jac = fastsubs(dxa{k},varsym,vari);%yn to y(n)
    fprintf(file,'\t%s\n',['dxa{',num2str(k),'} = [']);
    fprintf(file, '\t\t%%derivative with respect to y%d\n', k);
    for i=1:dim
        fprintf(file,'\t\t[ ');
        for j=1:dim    
            if jac(i,j)~=0
                fprintf(file,' (%s) ',char(jac(i,j)));
            else
                fprintf(file,' 0 ');
            end
        end
        fprintf(file,'\t\t];\n');
    end
    fprintf(file,'\t];\n\n');
    fprintf(1,' %d ',k);
    if ~mod(k,20)
      fprintf(1, '\n');      
    end
end
fprintf(1, '\n'); 
fclose(file);
