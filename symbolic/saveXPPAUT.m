function saveXPPAUT(name, mdir, rhs, varnames)
% saveXPPAUT(name, mdir,  rhs, varnames)
%
% creates the file 'name'.eqn with the model's ODE for XPPAUT
%
% mdir is the directory where the file will be created
% rhs is the right hand side of the model
% varnames are the varaible names. If name.varn found in defs dir, then
% they are read from here. If not, they are read from name.varn in mdir, unless 
% we are overwriting this with the defaults. 
% If this file is not found, then they will be defaults y1, y2 etc ...
% 
% This function just saves symbolic equations. These used to create ode
% file for xppaut at runtime

global varsym



namer = fullfile(mdir, [name '.eqn']);
dim = length(rhs);

file = fopen(namer,'wt');

%rhs will include y(1), y(2), etc ... for variable names.
%want to change these to actual names stored in varnames

rhss = subs(rhs, str2sym(varsym), str2sym(varnames));

%write the equations
for i=1:dim
    fprintf(file,'d%s/dt=%s\n',varnames{i}, char(rhss(i)));
end   
fclose(file);


%xpp                %MATLAB

%flr                floor
%ran(upper)         rand(1)*upper
%normal(arg1,arg2)  arg1 + arg2 * randn(1)

%Also, the following are keywords and cannot be used as variable names

%delay ln  then heav flr ran normal del_shft  hom_bcs
%arg1 ... arg9  @ $ + - / * ^ ** shift not \# sum of i'


 %mor erestrictions on forces, name cant have illegal chars eg space
 
%don't use i as matlab symbolic stuff treatsit as imaginary number
%t is time, don't use
%pi is 3.1, don't use

%var names must begin wit hletter

%can't name param fter on eof the force names

%only alphanumeric and underscore in force name

%param names can't be > 10 char long

