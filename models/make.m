function modelpath = make(name, varargin)

% make(name, [force_overwrite])

%Parameters

%name is the model name
%if the optional second parameter is 'f', this supresses asking the user before
%overwriting an existing installation. This is useful when using
%makeallmodels to call make multiple times without user input
%
%
% From the files 'name'_model.m and name.par in /models/definitions this function creates,
% by means of symbolic calculations, a file with the ODE, a file with the force and files
% with some first derivatives
%
% make can create:
% - 'name'.m     with the model's differential equation
% - 'name'_f.m   with the model's force
% - 'name'_jac.m with the model's jacobian
% - 'name'_dp.m  with the model's vector field derivative with respect to
%                the parameters
% - 'name'.ode   the model's equations in xppauto format
%
%and second derivative files

% - 'name_dea.m   
% - 'name_dxa.m  
% - 'name_deb.m  
% - 'name_dxb.m  

%Can also make ode files for XPPAUT


%Outputs

%The files name.m, name.ode and name_f.m will be made in /models/orbit_type/name,
%and the files name_jac.m and name_dp.m will be made in
%/models/orbit_type/name/derivatives
%The files name_dea.m,
%name_dxa.m, name_deb.m and name_dxb.m will be made in
%/models/orbit_type/name/derivatives2

%If it does not already exist, then name.varn will be made in
%/models/orbit_type/name/. This will contain a default variable names list y1, y2,
%...yn

%XPPAUT file will be created, called
%/models/orbit_type/name/xpp/name.ode

global DefsDir force_overwrite

modelpath = [];

result = 0;

MAX_VAR = 100;
MAX_FORCE = 9;
%arbitrary upper limits to the most variables and external forces a model
%can have

CreateSecond = 0;
mydir = fileparts(mfilename('fullpath'));
DefsDir = fullfile(mydir, 'definitions');  %where model definition files are found

if nargin > 1 && strcmp(varargin{1}, 'f') 
    force_overwrite = 1;
else
    force_overwrite = 0;
end 

if nargin > 2
   wbHndl = varargin{2};
 inc = 1/11;
else
    wbHndl = [];inc=[];
   
end

%check required files are present
if exist(fullfile(DefsDir, [name '_model.m']), 'file') ~= 2    
     ShowError(['Model definition file was not found in ', DefsDir]);  return;  
end
if exist(fullfile(DefsDir, [name '.par']), 'file') ~= 2    
     ShowError(['Model parameters file was not found in ', DefsDir]);   return;      
end

clear global rootdir mdir
global rootdir mdir
global orbit_type

rootdir = pwd;
if (exist(fullfile(rootdir, 'shared'), 'dir')~= 7)
     ShowError('Make should be run from the package installation directory'); return;  
end

updatebar(wbHndl, inc, 'Installing the model. Processing model parameters...');

fid_tmp = fopen(fullfile(DefsDir, [name '.par']), 'r');
tmp_scan = textscan(fid_tmp, '%s %f %[^\n]');
fclose(fid_tmp);
parn = tmp_scan{1}; parv = tmp_scan{2}; parnames = tmp_scan{3};

%parn names must exist
%if default value smissing, set them all to one
if isempty(parv)
    ShowError('Can''t find parameters file'); return;  
elseif length(parn) ~= length(parv)
    ShowError('Badly formatted parameters file'); return;  
end
%if decription missing, set to names
if isempty(parnames)
    parnames = parn;
elseif length(parnames) < length(parn)
    for i = length(parnames)+1:length(parn)
        parnames{i} = parn{i};
    end
elseif length(parnames) > length(parn)
    ShowError('Badly formatted parameters file'); return;  
end

%check if this is old style (model can only have one force) or new style
%(can have multiple forces).

[dawn,i1] = getpar('dawn',parn, parv);
[dusk,i2] = getpar('dusk',parn, parv);

dawnFound = i1 > 0;
duskFound = i2 > 0;
if dawnFound && duskFound
    %dawn and dusk found in par file
    style = 'old';
    parv([i1 i2]) = [];
    parn([i1 i2]) = [];
    parnames([i1 i2]) = [];
elseif ~dawnFound && ~duskFound
    %neither found
    style = 'new';
elseif dawnFound
    ShowError('Dawn is defined in the model par file but not dusk. You should define both or neither.'); return;  
else
    ShowError('Dusk is defined in the model par file but not dawn. You should define both or neither.'); return;  
end


pnum = length(parn);
% get symbolic variables. Need to create symbolic version of all
% parameters and variables referred to in model equations


updatebar(wbHndl, 0, 'Installing the model. Processing model external force...');

t=sym('t');
s ='syms(''dydt'', ''force''';
%include both 'force' and 'force1' as either are valid
for i = 1:MAX_FORCE
    s = [s ', ''force' num2str(i) ''''];
end
s = [s ');'];

for i = 1:pnum
    s = [s, parn{i}, '=sym(''',parn{i},'''); '];
end
syms y;
for i=1:MAX_VAR    
  y(i) = (['y',num2str(i)]);
end
% rhs   = right hand side of the model's differential equations
cd(DefsDir);
try
    rhs = feval(str2func([name '_model']), t, y, s); 
    
    %count actual number of forces
    forcenames = cell(0);
    numForce = 0;
    for d = 1:length(rhs)
        svars = symvar(rhs(d));
        for s = 1:length(svars)
            t = char(svars(s));
            tmp = regexp(t, '^(force[0-9]?$)', 'match', 'ignorecase');
            if ~isempty(tmp)
               forcenames{end+1} =  char(tmp);
            end
        end
        updatebar(wbHndl, inc/length(rhs));
    end
    %remove duplicates
    f = 1;
    while f < length(forcenames)
       tmp = forcenames{f};
       matches = find(strcmp(forcenames(f+1:end), tmp));
       forcenames(matches+f) = [];
       f = f+1;
    end
    numForce = length(forcenames);
    forcenames = sort(forcenames);
    
    %check dawn and dusk not defined in the wrong place
    if strcmp(style, 'old') && length(forcenames)>1
        %>1 force so must treat as new style definition
       ShowError('Dawn and dusk are defined in the model par file. Did you forget to remove them? These values will be ignored.'); 
        style = 'new';
    end
    %if only one force, can treat this as an old style definition and still
    %make the model

catch err
    cd(rootdir);

    ShowError(['Badly formatted model definition file. ', err.message]); return;
end
cd(rootdir);

dim = length(rhs);

updatebar(wbHndl, inc, 'Installing the model. Processing model additional settings...');

ok = read_extras_from_model(name, pnum, dim, forcenames, style, dawn, dusk); %DAR

if ~ok
    return;
end

global pari vari parsym varsym   forcei forcesym dforcei dforcesym conv
pari = cell(0);vari=cell(0);forcei = cell(0);forcesym = cell(0);dforcei = cell(0);dforcesym = cell(0);
varsym = cell(0); parsym = cell(0); conv = cell(0);


updatebar(wbHndl, inc, 'Installing the model. Creating symbolic variables...');

for i=1:pnum
    pari{i} = ['p(',num2str(i),')'];
    parsym{i} = parn{i};
end
%similarly, var contains 'y(n)' and varsym 'y1', 'y2', etc...
for i = 1:dim
    varsym{i} = ['y',num2str(i)];
    vari{i} = ['y(',num2str(i),')'];
end

for f = 1:numForce
    
    forcei{f} = ['force(',num2str(f),')'];
    forcesym{f} = forcenames{f};
    
    dforcei{end+1} = ['df_ddawn(',num2str(f),')'];
    dforcei{end+1} = ['df_ddusk(',num2str(f),')'];
    
    dforcesym{end+1} = ['df_ddawn' num2str(f)];
    dforcesym{end+1} = ['df_ddusk' num2str(f)];
    
    if CreateSecond
        
        dforcei{end+1} = ['d2f_ddawn2(',num2str(f),')'];
        dforcei{end+1} = ['d2f_ddusk2(',num2str(f),')'];
        dforcei{end+1} = ['df_ddusk_ddawn(',num2str(f),')'];
        dforcei{end+1} = ['df_ddawn_ddusk(',num2str(f),')'];
        
        dforcesym{end+1} = ['d2f_ddawn2' num2str(f)];
        dforcesym{end+1} = ['d2f_ddusk2' num2str(f)];
        dforcesym{end+1} = ['df_ddusk_ddawn' num2str(f)];
        dforcesym{end+1} = ['df_ddawn_ddusk' num2str(f)];
    end
    
end
   

% information string with parameters numbers and the corresponding parameters names
% to attach to some of the generated files
for i = 1:length(parsym)
    conv{i} = {['% ',pari{i},'=',parsym{i}]};
end
conv{end+1}={'% ----'};
for i = 1:length(forcei);
    conv{end+1} = {['% ',forcei{i},'=',forcesym{i}]};
end

updatebar(wbHndl, inc, 'Installing the model. Creating installation files...');
%create directory for model if required
mdir=fullfile(rootdir,'models', orbit_type, name);
if exist(mdir, 'dir') == 7
    
    if ~force_overwrite
        %directory exists
        if isempty(wbHndl)
            disp('A previous installation already exists at ');
            disp(fullfile(mdir, [name '_model.m']));
            reply = input('This will be replaced if you continue. Enter Y to continue, any other value to quit. >> ', 's');
            if ~strcmp(reply, 'Y') && ~strcmp(reply, 'y')
                disp(['Make abandonned for ', name]);
                if exist(fullfile(DefsDir, [name '.info'])) == 2
                    delete(fullfile(DefsDir, [name '.info']));
                end
                return;
            end
        else
            response = questdlg(['A model with the name ' name ' is already installed. Do you wish to overwrite it?'], 'Install model', 'Yes', 'No', 'No');
            if strcmp(response, 'No')
                if exist(fullfile(DefsDir, [name '.info'])) == 2
                    delete(fullfile(DefsDir, [name '.info']));
                end
                return;
            end
        end
    end
    
    %delete old installation
    [SUCCESS,MESSAGE,MESSAGEID] =  rmdir(mdir, 's');
    if ~SUCCESS
        ShowError(MESSAGE); return;
    end
    
end

%make installation dir
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(mdir);
if ~SUCCESS
    ShowError(MESSAGE); return;
end
%create sub directories
mdir1 = fullfile(mdir, 'derivatives');
if exist(mdir1) ~= 7
    [status,message,messageid] = mkdir(mdir1);
    if  status==0
        ShowError(message); return;  
    end
end
if CreateSecond
    mdir2 = fullfile(mdir, 'derivatives2');
    if exist(mdir2) ~= 7
        [status,message,messageid] = mkdir(mdir2);
        if  status==0
            ShowError(message) ;return;  
        end
    end
end
mdir3 = fullfile(mdir, 'xpp');
if exist(mdir3) ~= 7
    [status,message,messageid] = mkdir(mdir3);
    if  status==0
        ShowError(message); return;  
    end
end
addpath(genpath(mdir));
%add variable names file if doesn't exist
fname = fullfile(DefsDir, [name '.varn']);
if exist(fname, 'file') == 2
    %file exists in defs directory
    fid_tmp = fopen(fname, 'r');
    tmp_scan = textscan(fid_tmp, '%s %f %[^\n]');
    fclose(fid_tmp);
    varnames = tmp_scan{1}; init_cond = tmp_scan{2}; vardesc = tmp_scan{3};
    if length(varnames) ~= length(rhs) || length(init_cond) ~= length(rhs)
        ShowError('The variable names file has the wrong number of names'); return;  
    end
    if length(vardesc) < length(varnames)
        for i = length(vardesc)+1:length(varnames)
            vardesc{i} = varnames{i};
        end
    end
else
    %no varn file found in defs dir, so create it 
    varnames = cell(1, length(rhs));init_cond = zeros(length(rhs),1);vardesc = cell(length(rhs),1);
    for i = 1:length(rhs)
        varnames{i} = ['y' num2str(i)];
        vardesc{i} = ['y' num2str(i)];
    end
end
if size(varnames, 1) > 1;
    varnames = varnames';
end
%create varn file in model directory
fid = fopen(fullfile(mdir, [name '.varn']), 'w');
for i = 1:length(rhs)
     fprintf(fid, '%s %g %s\n', varnames{i}, init_cond(i), vardesc{i});
end
fclose(fid);

%create the default parameter values file
fid = fopen(fullfile(mdir, [name '.pv']), 'w');
for i = 1:length(parv)
    fprintf(fid, '%g\n', parv(i));
end
fclose(fid);

%create the default force  file
global force_type
if ~isempty(force_type)
    fid = fopen(fullfile(mdir, [name '.fv']), 'w');
    for f = 1:length(force_type)
        fprintf(fid, '%s\n', force_type{f}); %format is 'name dawn dusk'
    end
    fclose(fid);
end

%and default init cond file
fid = fopen(fullfile(mdir, [name '.y']), 'w');
for i = 1:length(init_cond)
    fprintf(fid, '%g\n', init_cond(i));
end
fclose(fid);

%order of values in here matches the order of the names in the par and varn
%files.

%Note which variables and paramters are included in each equation. 
%This can provide the user with hints if a derivative matrix should
%evaluate to NaN or Inf when running 'theory'
eqn_info = [];
for i = 1:dim
    sym_names = symvar(rhs(i));

    tmp_info = struct('variables', [], 'parameters', [], 'force', []);
    for s = 1:length(sym_names)
        sym_name = char(sym_names(s));
        
        varnum = regexp(sym_name, 'y([0-9])?', 'tokens', 'ignorecase');
        if ~isempty(varnum)
            tmp_info.variables = [tmp_info.variables, str2double(char(varnum{1}))];
        elseif  strcmp(sym_name, 'force')
            %force
            tmp_info.force = [tmp_info.force, 1];
        else
            forcenum = regexp(sym_name, 'force([0-9])?', 'tokens', 'ignorecase');
            if ~isempty(forcenum)
                tmp_info.force = [tmp_info.force, str2double(char(forcenum{1}))];
            else
                %must be  parameter
                parnum = find(strcmp(sym_name, parn));
                tmp_info.parameters = [tmp_info.parameters, parnum];
            end
        end
            
    end
    
    eqn_info = [eqn_info tmp_info];
end
%save this to be read by error handling function to generate hint



%now create equatations files

updatebar(wbHndl, inc, 'Installing the model. Saving model equations...');
savesystem(name, mdir, rhs, orbit_type, numForce, wbHndl);
updatebar(wbHndl, 0, 'Installing the model. Saving model jacobian matrix...');
dydtdy_tmp = savejac(name, mdir1, orbit_type, numForce, wbHndl, inc);
updatebar(wbHndl, 0, 'Installing the model. Saving model parameter derrivatives...');
dydtdk_tmp = savedifpar(name, mdir1, rhs, orbit_type, numForce, wbHndl, inc);


updatebar(wbHndl, 0, 'Installing the model. Saving model information...');
%save matrices in symbolic form for displaying to the user
rhs_tmp = subs(rhs, str2sym(varsym), str2sym(varnames));
dydtdk_tmp = subs(dydtdk_tmp, str2sym(vari), str2sym(varnames));
dydtdy_tmp = subs(dydtdy_tmp, [str2sym(varsym) str2sym(pari) str2sym(forcei)], [str2sym(varnames) str2sym(parn') str2sym(forcesym)]);
for i = 1:dim
  model_odes{i} = char(rhs_tmp(i));  
  
  for j = 1:size(dydtdk_tmp,2)
     dydtdk{j, i} = char(dydtdk_tmp(i, j));%note transpose required here so matric matches model_dp file
  end
  for j = 1:dim
      dydtdy{i,j} = char(dydtdy_tmp(i,j));
  end

    updatebar(wbHndl, inc/dim);
  
end



save(fullfile(mdir1, [name '_eqn_info.mat']), 'eqn_info', 'model_odes', 'dydtdy', 'dydtdk', 'parn', 'varnames', 'forcenames', 'dforcesym');

if CreateSecond
    global include_force
    include_force= false;
    savedea(name, mdir2, rhs, orbit_type, numForce);
    savedxa(name, mdir2, rhs, orbit_type, numForce);
    savedxb(name, mdir2, rhs, orbit_type, numForce);
    savedeb(name, mdir2, rhs, orbit_type, numForce);
end

%Don't want any symbolic name removed from ode file, except for t1 to be replaced with 
%'t - floor(t/CP)*CP' or 't'

updatebar(wbHndl, inc, 'Installing the model. Creating XPP link...');
saveXPPAUT(name, mdir3, rhs, varnames);

%clean up
clear global conv par parsym  var parf
clear global vps vp vps_p vp_p vps_y vp_y

updatebar(wbHndl, inc, 'Clearing up...');
%must replace old definiotn files in case it has changed.
if exist(fullfile(mdir, [name '.par']), 'file') == 2
    delete(fullfile(mdir, [name '.par']));
end

%update par file
fp = fopen(fullfile(mdir, [name '.par']), 'wt');
for i = 1:length(parn)
    fprintf(fp, '%s\t%f\t%s\n', parn{i}, parv(i), parnames{i});
end
fclose(fp);

[SUCCESS,MESSAGE,MESSAGEID] = movefile(fullfile(DefsDir, [name '.info']), mdir,'f');
if ~SUCCESS
    ShowError(MESSAGE); return;  
end
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(fullfile(DefsDir, [name '_model.m']), mdir,'f');
if ~SUCCESS
    ShowError(MESSAGE); return;  
end
%add comments to copy of _model file
fid = fopen(fullfile(mdir, [name '_model.m']), 'r');
filecontents = cell(0);
i = 1;
while ~feof(fid)
    filecontents{i} = fgets(fid);
    i=i+1;
end
fclose(fid);
fid = fopen(fullfile(mdir, [name '_model.m']), 'w');
fprintf(fid, '%%This file is a copy of that used to create the model at %s\n%%If you wish to re-make the model you must edit the file in %s\n%%Editing this one will have no effect\n\n', datestr(now), DefsDir);
for i = 1:length(filecontents)
   fprintf(fid, '%s', filecontents{i}); 
end
fclose(fid);

if isempty(wbHndl)
    disp('make finished');
end

modelpath = mdir;
clear rootdir mdir  orbit_type cycle_period
clear p parsym pf parsymf
clear varsym var 


return;

%Could replace the force definitions written into the files by a call to
%get_force_expr. This would add lots of overhead?, but would mean that new
%forces could be added without the need to re-make all the models
%======================================================

function result = read_extras_from_model(name, pnum, dim, fnames, style, dawn, dusk)

global tend positivity orbit_type force_type cycle_period
global DefsDir

result = false;

%PEB changed this to set default values
fnum = length(fnames);
tend = 100;
positivity = 'non-negative';
ode_method = 'matlab_non-stiff';
orbit_type = 'oscillator';

force_type = cell(0);

plotting_timescale = '1';
cycle_period = '24';

% symname = 'name'_model.m is the model name (user created file)
symname = [name, '_model'];

% fname is the model name with the full path (for files to be created)
fname = fullfile(DefsDir, [symname '.m']);
if exist(fname) == 0    
     ShowError(['file: ' symname ' was not found']);     return;  
end

if exist(fname, 'file') == 2
    file = fopen(fname,'r');
    %read whole file
    filecontents = cell(0);
    i = 1;
    while ~feof(file)
        filecontents{i} = fgets(file);
        i=i+1;
    end
    k=1;
    for j = 1:length(filecontents)
        newline = filecontents{j};
        if strncmp('%%%tend',newline,7)
            [token, remain] = strtok(newline);
            tend = str2double(remain);
        end
        if strncmp('%%%positivity',newline,13)
            [token, remain] = strtok(newline);
            positivity = strtrim(char(remain));
        end
        if strncmp('%%%method',newline,9)
            [token, remain] = strtok(newline);
            ode_method = strtrim(char(remain));
        end
        if strncmp('%%%orbit_type',newline,13)
            [token, remain] = strtok(newline);
            orbit_type = strtrim(char(remain));
        end
        if strncmp('%%%force_type',newline,13)
            [token, remain] = strtok(newline);
            ft = strtrim(char(remain));
            [force rem] = strtok(ft, ',');
            f=1;

            valid_force_names = get_all_force_types();
            while length(force)
                if strcmp(style, 'old')
                    %ensuredawn and dusk values not defined here
                    if any(isspace(force))
                       ShowError(['Dawn and dusk values seem to be defined both in the par file and in the model definition file (' force ')']);  return;  
                    else
                        %add dawn and dusk values from par file to definition 
                        force = [force ' ' num2str(dawn) ' ' num2str(dusk)];
                    end
                end
                fn = char(regexp(force, '^(\S+)\s', 'tokens', 'once'));
                if ~any(strcmp(valid_force_names,fn))
                    %replac einvalid force with default
                    force = strrep(force, fn, valid_force_names{1});
                end
                force_type{end+1} = [fnames{f} ' ' force];               
                [force rem] = strtok(rem, ',');
                f=f+1;
            end

        end
        if strncmp('%%%plotting_timescale',newline,13)
            [token, remain] = strtok(newline);
            plotting_timescale = strtrim(char(remain));
        end
        if strncmp('%%%cycle_period',newline,13)
            [token, remain] = strtok(newline);
            cycle_period = strtrim(char(remain));
        end
        if strncmp('%%%info',newline,7)
            info{k}=newline;
            k=k+1;
        end
    end
    fclose(file);
end

fname = fullfile(DefsDir, [name '.info']);
file = fopen(fname, 'w');
fprintf(file, '%% File created at %s\n', datestr(now));
if k>1  % there is other info
    for i=1:length(info) fprintf(file,'%s',info{i});end
end
fprintf(file,'%s\n', '% =====================================');
%these could be changed via the gui. Values could be defaults

fprintf(file,'%s\n', '% This sets the default end time for a signallng system');
fprintf(file,'%s\n', 'tend');
fprintf(file,'%f\n', tend);
fprintf(file,'%s\n', '% =====================================');

fprintf(file,'%s\n', '% This tells which ode solver method to use by default. Typical ones are ode45 and ode15s');
fprintf(file,'%s\n', 'method');
fprintf(file,'%s\n', ode_method);
fprintf(file,'%s\n', '% =====================================');

if fnum > 0
    fprintf(file,'%s\n', '% This is the force type used from the file /shared/get_force_expr');
    fprintf(file,'%s\n', 'force_type');
    
    %ensure enough forces defined, if not set them to default 'photo'
    if strcmp(style, 'old')
        if length(force_type) == 0 && length(fnames) > 0
            force_type{1} = [fnames{1} ' photo ' num2str(dawn) ' ' num2str(dusk)];
        end
    else
        for i = length(force_type)+1:fnum
            force_type{i} = [fnames{i} ' photo 6 18'];
        end
    end
    
    for i = 1:length(force_type)
        fprintf(file,'%s,', force_type{i});
    end
    
    fprintf(file,'\n');
    fprintf(file,'%s\n', '% =====================================');
end

fprintf(file,'%s\n', '% The period of an oscillating force');
fprintf(file,'%s\n', 'cycle_period');
fprintf(file,'%s\n', cycle_period);
fprintf(file,'%s\n', '% =====================================');

%this one probably shouldn't be changed
fprintf(file,'%s\n', '% This tells whether to treat all variables as non-negative or not. Options are non-negative and allow_negative');
fprintf(file,'%s\n', 'positivity');
fprintf(file,'%s\n', positivity);
fprintf(file,'%s\n', '% =====================================');

%these are fixed forever when the model is created. Need to re-make to
%change these
%this needed by gui to run in correct way
fprintf(file,'%s\n', '% Options are oscillator and signal. This tells us whether the solution should be periodic or not');
fprintf(file,'%s\n', 'orbit_type');
fprintf(file,'%s\n', orbit_type);
fprintf(file,'%s\n', '% =====================================');

%needed by gui to plot graph
fprintf(file,'%s\n', '% This is scaling factor for time i.e. if computation is in mins and the plot in hours then plotting_timescale = 60: tnew = t/plotting_timescale');
fprintf(file,'%s\n', 'plotting_timescale');
fprintf(file,'%s\n', plotting_timescale);
fprintf(file,'%s\n', '% =====================================');



%just for information
fprintf(file,'%s\n', '% The number of dimensions the model has');
fprintf(file,'%s\n', 'dim');
fprintf(file,'%s\n', num2str(dim));
fprintf(file,'%s\n', '% =====================================');

fprintf(file,'%s\n', '% The number of parameters');
fprintf(file,'%s\n', 'pnum');
fprintf(file,'%s\n', num2str(pnum));
fprintf(file,'%s\n', '% =====================================');

% fprintf(file,'%s\n', '% Possible force_types as defined in get_force_expr. The gui allows the user to select one of these');
% fprintf(file,'%s\n', 'all_force_types');
% i = 1;
% [fname, ftype] = get_force_expr(i);
% while ~isempty(fname)
%     fprintf(file, '%s %d:', fname, ftype);%fytpe = 1 means force is constant. 
%     i = i + 1;
%     [fname, ftype] = get_force_expr(i);
% end

fclose(file);

result = true;

