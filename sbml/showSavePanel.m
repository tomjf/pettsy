function r = showSavePanel(varargin)

persistent myDir panel tblHndl sbml_model species parameters lblHndl forceTblHndl  sassy_properties 
 
global title_fontsize
 
action = varargin{1};
r = [];

if strcmp(action, 'init')

    %creates controls on the first panel
    myDir = varargin{2};
    pos = varargin{3};
    fig = varargin{4};

    
    maincol = get(fig, 'Color');
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'off', ...
        'Parent', fig);
    
    panelwidth = pos(3);panelheight=pos(4);
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Import model' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

    
   lblHndl=uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'The SBML model has been successfully imported.', ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2.5 panelwidth-1 1.2],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'You can enter additional PeTTSy specific information about the model below:', ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-3.5 panelwidth-1 1],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   
   sassy_properties = {'Orbit type:', 'orbit_type', {'oscillator', 'signal'}; ...
       'Positivity', 'positivity', {'non-negative', 'allow_negative'}; ...
       'Timescale factor', 'plotting_timescale', 1; ...
       'Default cycle period', 'cycle_period', 24; ...
       'Default time (tend)', 'tend', 100; ...
       'Default ODE solver', 'method', {'matlab_non-stiff', 'matlab_stiff', 'cvode_non-stiff', 'cvode_stiff'}; ...
       
       };
   
   for p = 1:size(sassy_properties, 1)
       
       uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
           'string', sassy_properties{p, 1}, ...
           'Units','centimeters','Style','text', ...
           'position',[2 panelheight-3.5-p*0.9 (panelwidth-4)/2 0.7],'Visible', 'on', ...
           'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
       
       if iscell(sassy_properties{p,3})
           
           uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
               'string', sassy_properties{p, 3},'Tag', sassy_properties{p, 2},  'value', 1, ...
               'Units','centimeters','Style','popup', ...
               'position',[panelwidth/2 panelheight-3.4-p*0.9 panelwidth/3 0.7],'Visible', 'on', ...
               'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
           
       else
           uicontrol('HorizontalAlignment', 'right','Parent',panel, ...
               'string', sassy_properties{p, 3}, 'Tag', sassy_properties{p, 2}, ...
               'Units','centimeters','Style','edit', ...
               'position',[3*panelwidth/4 panelheight-3.4-p*0.9 panelwidth/12 0.7],'Visible', 'on', ...
               'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
           
       end
       
   end
   
%     tblpos = [0.5 5.5 panelwidth-1 panelheight-7.7];
   tblwidth = panelwidth-1;
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
%    tblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
%        'parent', panel, 'position', tblpos, 'Rowname', {},...
%        'ColumnName', {'Property', 'Value'}, 'ColumnWidth', {tblwidth*0.48 tblwidth*0.48}, 'ColumnEditable', [false true]);
%    
%    
%     
%    set(tblHndl, 'data', sassy_properties);
   
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'Select the default force settings here:', ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 5 panelwidth-1 1],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   tblpos = [0.5 2 panelwidth-1 3];
   forceTblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos,...
       'ColumnName', {'SBML Name', 'PeTTSy Name', 'Default function', 'Dawn', 'Dusk'}, 'ColumnFormat', {'char', 'char', get_all_force_types(), 'numeric', 'numeric'}, ...
       'ColumnWidth', {tblwidth*0.2 tblwidth*0.2 tblwidth*0.2 tblwidth*0.15 tblwidth*0.15}, 'ColumnEditable', [false false true true true]);
   
   
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['When you click Save the model, parameters and  ' ...
       'variables files will be created in the model definitions directory.'], ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 0.5 panelwidth-1 1],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
 
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        data = varargin{2};
        sbml_model = data{1};
        species = data{2};
        parameters = data{3};
        
        if length(parameters) > 0
            num_param_forces = nnz([parameters(:).isforce]);
        else
            num_param_forces = 0;
        end
        if length(sbml_model.functionDefinition) > 0
            num_func_forces = nnz([sbml_model.functionDefinition(:).isforce]);
        else
            num_func_forces = 0;
        end
        num_forces = num_param_forces + num_func_forces;
        
        numparams = length(parameters)-num_param_forces;
   
        str = ['The SBML model ' sbml_model.id ' has been successfully imported. It consists of ' num2str(length(species)) ...
            ' ODEs, which contain ' num2str(numparams) ' parameters and ' num2str(num_forces) ' external force(s)'];
        
        set(lblHndl, 'string', str);
        
        def_force= get_all_force_types();
        
        tbldata = cell(num_forces, 4);
        sassy_force_names = cell(num_forces, 1);
        sassy_force_types = cell(num_forces, 1);
        if num_forces == 1
            sassy_force_names{1} = 'force';
        else
           for f = 1:num_forces
               sassy_force_names{f} = ['force' num2str(f)];
           end
        end
        
        row = 1;
        for f = 1:length(parameters)
            if parameters(f).isforce
                tbldata{row, 1} = parameters(f).Name;
                tbldata{row, 2} = sassy_force_names{row};
                tbldata{row, 3} = def_force{1};
                tbldata{row, 4} = 0;
                tbldata{row, 5} = 12;
                sassy_force_types{row} = 'p';
                row = row+1;
            end
        end
        for f = 1:length(sbml_model.functionDefinition)
            if sbml_model.functionDefinition(f).isforce
                tbldata{row, 1} = sbml_model.functionDefinition(f).id;
                tbldata{row, 2} = sassy_force_names{row};
                tbldata{row, 3} = def_force{1};
                tbldata{row, 4} = 0;
                tbldata{row, 5} = 12;
                sassy_force_types{row} = 'f';
                row = row+1;
            end
        end
        
        
        set(forceTblHndl, 'data', tbldata, 'userdata',  sassy_force_types);
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 
    
elseif strcmp(action, 'goback') 
   
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'finished')
    


    %check for numeric values
    ctrl = findobj(panel, 'Tag', 'plotting_timescale');
    timescale = str2double(get(ctrl, 'string'));
    if isempty(timescale) || timescale <= 0
       ShowError('Please enter a positive numeric value for timescale.');
       uicontrol(ctrl);
        return;
    end

    ctrl = findobj(panel, 'Tag', 'cycle_period');
    cp = str2double(get(ctrl, 'string'));
    if isempty(cp) || cp <= 0
       ShowError('Please enter a positive numeric value for cycle period.');
       uicontrol(ctrl);
       return;
    end

    ctrl = findobj(panel, 'Tag', 'tend');
    tend = str2double(get(ctrl, 'string'));
    if isempty(tend) || tend <= 0
       ShowError('Please enter a positive numeric value for default time.');
       uicontrol(ctrl);
       return;
    end
    
    tbldata = get(forceTblHndl, 'data');
    for f = 1:size(tbldata, 1)
        for d = 4:5
            dval = tbldata{f, d};
            if isempty(dval) || dval < 0
                ShowError('Please enter non-negative numeric values for dawn and dusk.');
                return;
            end
        end
        
    end
     
    forces = get(forceTblHndl, 'data');
    forcetypes = get(forceTblHndl, 'userdata');
    forces = [forces forcetypes];
    
    
    %create sassy files
    
    Name = sbml_model.sassyname;
    mydir = fileparts(mfilename('fullpath'));
    DefsDir = fullfile(mydir, '..', 'models', 'definitions');
   
    Name = fullfile(DefsDir, Name );
    sassyname = sbml_model.sassyname;
    
    while exist([Name '_model.m'], 'file')
        newname = inputdlg(['A model definition file with the name ' sassyname '_model.m already exists. Please enter an alternative name for this model'], 'PeTTSy - Import SBML file',1);
        if isempty(newname)
            return;
        end
        newname = char(newname);
        goodname = regexp(newname, '^[a-zA-Z][a-zA-Z0-9_]*$', 'once');
        if isempty(goodname)         
            ShowError('Please enter a valid model name consisting of alphanumeric characters and underscores, and beginning with an alphanumeric character.');
        else
             Name = fullfile(DefsDir, newname);
             sassyname = newname;
        end
       
    end
    
   

    sassy_dir = fileparts(which('pettsy.m'));
    if isdir(fullfile(sassy_dir,'models', 'oscillator', sassyname)) || isdir(fullfile(sassy_dir,'models', 'signal', sassyname))
        ShowError(['A model with the name ' sassyname ' is already installed. Please choose a different name.']); return;
    end
    
    ctrl = findobj(panel, 'Tag', 'orbit_type');
    str=get(ctrl, 'string');
    orbit_type = str{get(ctrl, 'value')};
    
    try
        writeODEfile(sbml_model, Name, species, parameters, forces, sassy_properties(:,2), panel);
        writeParFile(Name, parameters);
        writeVarnFile(Name, species);
        
    catch err
        ShowError('There was an error creating the model definition files', err);
        return;
    end
   
    
    newpath = installModel(sassyname);
    
    if ~isempty(newpath) 
        %add to menu
        
        pettsy('addmodel', newpath);
        
        msgbox(['Model ' sassyname ' installed successfully.'], 'PeTTSy - Import SBML');
    end
    
   
    
    
elseif strcmp(action, 'isvisible')
    
    r = get(panel, 'visible');
    if strcmp(r, 'on')
        r = 1;
    else
        r = 0;
    end
    
     
end



%==========================================================================

function result = installModel(Name)

%now run make on the model



wbHndl = waitbar(0.0,'Installing the new model...', 'Name', 'PeTTSy', 'pointer', 'watch', 'resize', 'off');
set(wbHndl, 'userdata', 0);
result = make(Name, 'f', wbHndl);

delete(wbHndl);











