

function r = exportSpeciesPanel(varargin)


persistent myDir panel tblHndl model  unitsTypeHndl unitsNameHndl unitsScaleHndl timeNameHndl timeScaleHndl vFileHndl
 
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
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Model species' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

    
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'The model variables will be converted to SMBL species with units of' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2 panelwidth-5 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   unitsTypeHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', {'concentration', 'amount'} , 'value', 1, 'Units','centimeters','Style','popup', ...
       'position',[panelwidth-4.5 panelheight-2 4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'Default substance units will M be for concentration and mol for amount. You can change this by entering a name and scale factor below. Scale is an integer exponent for a power of ten multiplier. For example, enter nM and -9.' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-4 panelwidth-1 1.5],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'Name:' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-4.75 2 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   unitsNameHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'M' ,'Units','centimeters','Style','edit', ...
       'position',[2.5 panelheight-4.65 1.25 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string' ,'Scale:', 'units','centimeters','Style','text', ...
       'position',[4.5 panelheight-4.75 1.75 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    unitsScaleHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', '0' ,'Units','centimeters','Style','edit', 'horizontalAlignment', 'right', ...
       'position',[6.25 panelheight-4.65 2 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
   set(unitsTypeHndl, 'callback', {@unitTypeChange unitsNameHndl});
   
   
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'The default time units for species reactions will be seconds. If you wish to use different units, please enter a name and multiplier below, for example hours and 3600. PeTTSy has attempted to guess values based on the plotting_timescale model property.' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-6.5 panelwidth-1 1.5],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'Name:' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-7.25 2 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   timeNameHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'sec' ,'Units','centimeters','Style','edit', ...
       'position',[2.5 panelheight-7.15 1.25 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string' ,'Multiplier:', 'units','centimeters','Style','text', ...
       'position',[4.5 panelheight-7.25 1.75 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    timeScaleHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', '1' ,'Units','centimeters','Style','edit', 'horizontalAlignment', 'right', ...
       'position',[6.25 panelheight-7.15 2 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string' ,'Select a file to provide the initial conditions:', 'units','centimeters','Style','text', ...
       'position',[0.5 panelheight-8.5 (panelwidth-1)/2 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    vFileHndl=uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', {'-none-'} , 'value', 1, 'Units','centimeters','Style','popup', ...
       'position',[panelwidth/2 panelheight-8.4 4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string' ,'You can edit the description and value columns of the species below', 'units','centimeters','Style','text', ...
       'position',[0.5 panelheight-9.25 panelwidth-1 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
 
   tblpos = [0.5 0.5 panelwidth-1 panelheight-9.75];
   tblwidth = tblpos(3);
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
   tblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos, ...
       'ColumnName', {'Name', 'Description', 'Initial value'}, 'ColumnWidth', {tblwidth*0.2 tblwidth*0.5 tblwidth*0.2}, 'ColumnEditable', [false true true]);

   
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        model = varargin{2};
 
        tbldata = cell(length(model.vnames), 3);
        for s = 1:length(model.vnames)
           tbldata{s, 1} = model.vnames{s};       
           tbldata{s, 2} = model.vardesc{s}; 
           tbldata{s, 3} = model.init_cond(s);
        end
       
        set(tblHndl, 'data', tbldata);
        
        %model.plotting_timescale: 1=plot shows hours, 60 = plot shows
        %minutes, 3600 = plot shows sec
        
        timescale =  ceil(3600/model.plotting_timescale);
        set(timeScaleHndl, 'string', num2str(timescale));
        
        if timescale == 1
            set(timeNameHndl, 'string', 'seconds');
        elseif timescale == 60
            set(timeNameHndl, 'string', 'minutes');
        elseif timescale == 3600
            set(timeNameHndl, 'string', 'hours');
        end
        
  
        vfiles = {'-none-'};
        f = dir(fullfile(model.dir, '*.y'));
        if ~isempty(f)
            for i = 1:length(f)
                vfiles{end+1} = f(i).name;
            end
        else
            
        end
       
        set(vFileHndl, 'string', vfiles);
        set(vFileHndl, 'callback', {@SelVFile, tblHndl, model});
        
        
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 

elseif strcmp(action, 'gonext')

    %called when user click Next.
   
    r = [];
    tbldata = get(tblHndl, 'data');
    for s = 1:size(tbldata, 1)
        
        model.vardesc{s} = fixXMLString(tbldata{s,2}); %record users edit
        if isnan(tbldata{s,3}) || ~isnumeric(tbldata{s,3}) || isempty(tbldata{s,3});
            ShowError(['Row ' num2str(s) ', please enter a numeric value.']);
            return;
        end
        model.init_cond(s) = tbldata{s,3};
        
    end
    
    %deal with empty amount and time units
    
    idx = get(unitsTypeHndl, 'value');
    units_type = get(unitsTypeHndl, 'string');
    units_type = units_type{idx};
    
    units_name = fixXMLString(get(unitsNameHndl, 'string'));
    if isempty(units_name)
       if strcmp(units_type, 'concentration')
            units_name = 'M';
       else
            units_name = 'mol';
       end
    end
    
    units_scale = get(unitsScaleHndl, 'string');

    if isempty(units_scale)
       units_scale = 0;
    else
        units_scale = str2double(units_scale);
        if isempty(units_scale) || (units_scale ~= floor(units_scale))
           ShowError('Please enter an integer value for scale.');
           uicontrol(unitsScaleHndl);
           return
        end
    end

    time_name = fixXMLString(get(timeNameHndl, 'string')); %check for illegal chars in SBML name attribute
    if isempty(time_name)
        time_name = 'seconds';
    end

    time_mult = get(timeScaleHndl, 'string');


    if isempty(time_mult)
       time_mult = 1;
    else
        time_mult = str2double(time_mult);
        if isempty(time_mult) || (time_mult <= 0)
           ShowError('Please enter a positive numeric value for time multiplier.');
           uicontrol(timeScaleHndl);
           return
        end
    end
    
    model.speciesUnitsType = units_type;
    model.speciesUnitsName = units_name;
    model.speciesUnitsScale = units_scale;
    model.timeUnitsName = time_name;
    model.timeUnitsMultiplier = time_mult;

    r = model;
    
    set(panel, 'visible', 'off');

    
elseif strcmp(action, 'goback') 
   
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'isvisible') 
    
    r = get(panel, 'visible');
    if strcmp(r, 'on')
        r = 1;
    else
        r = 0;
    end 
    

end

function unitTypeChange(obj, event, editCtrl)


type = get(obj, 'value');

if type == 1
    set(editCtrl, 'string', 'M');
else
    set(editCtrl, 'string', 'mol');
end


%============================================
function SelVFile(hFile, event, hTbl, model)

%user has chosen an initial cond file


fname = get(hFile, 'String');
idx = get(hFile, 'value');
fname = fname{idx};

tblData = get(hTbl, 'data'); 

if strcmp(fname, '-none-')
    %no p file, so fill in default  values
   
    tblData(:,3) = num2cell(model.init_cond);
  
else
    %read selected file
    fid_tmp = fopen(fullfile(model.dir, fname), 'r');
    tmp_scan = textscan(fid_tmp, '%f');
    fclose(fid_tmp);
    ivals = tmp_scan{1};
    if length(ivals) ~= size(tblData, 1)
        ShowError('The selected initial conditions file is invalid.');
        return; 
    end  
    
    tblData(:,3) = num2cell(ivals);
end

set(hTbl, 'data', tblData);
    




