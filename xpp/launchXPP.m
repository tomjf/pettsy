 function r = launchXPP(action, varargin)

%In this form,user selects parameters and initial conditions and force
%These are then added to ode file and XPPAUT run on it.

persistent fileType newFig panel paramTbl varTbl selforceHndl OKHndl cancelHndl seltsHndl selparamHndl selvarHndl
persistent model ts configHndl cpHndl forcetypeHndl

if strcmp(action,'init')
    
   
    ts = varargin{1};    %may be empty, as don't need a time series to launch xppaut
    model = varargin{2};
    
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    
    figwidth = 18;
    figheight = 18;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    
    pos = [figleft figbottom figwidth figheight];
    
    newFig=figure('resize', 'off', 'units', 'centimeters', 'position', pos,'menubar', 'none' ,'Name', 'Launch XPPAUT' ,'NumberTitle','off','Visible','off');
    %'windowstyle', 'modal'
   maincol = get(newFig, 'Color');
   pwidth=figwidth-0.2;
   pheight=figheight-1.1;
   frmPos=[0.1 1 pwidth pheight];
   
   panel = uipanel('BorderType', 'etchedin', ...
       'BackgroundColor', maincol, ...
       'Units','centimeters', ...
       'Position',frmPos, ...
       'HandleVisibility', 'on', ...
       'visible', 'on', ...
       'Parent', newFig);
      
   uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1 pwidth-1  0.5],'string','First select the parameter, initial conditions and force required', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
   fileType = uibuttongroup('Units','centimeters','SelectionChangeFcn','launchXPP(''getall'');', 'Position', [0.5 pheight-4 pwidth/2-0.5 2.75], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
   t1=uicontrol('HorizontalAlignment', 'right','Parent',fileType,'string', 'Read from existing time series:' ,'Units','normalized','Style','radiobutton', 'position',[0/100 66/100 1 33/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
   t2=uicontrol('HorizontalAlignment', 'right', 'Parent',fileType,'string', 'Read from files' ,'Units','normalized','Style','radiobutton', 'position',[0/100 33/100 1 33/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   set(fileType, 'UserData', [t1 t2]);
   
   seltsHndl = uicontrol( ...
        'Style','popup', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[pwidth/2+0.25 pheight-2 pwidth/2-0.75 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '...', ...
        'Value', 1, ...
        'BackgroundColor', 'w', 'CallBack', 'launchXPP(''gettsfile'');');
    
     uicontrol('HorizontalAlignment', 'right','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2-2 pheight-3 2  0.5],'string','Parameters:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'FontUnits', 'points', 'FontSize', 10);
     selparamHndl = uicontrol( ...
        'Style','popup', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[pwidth/2+0.25 pheight-3 pwidth/2-0.75 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '...', ...
        'Value', 1, ...
        'BackgroundColor', 'w', 'CallBack', 'launchXPP(''getparams'');');
        
    uicontrol('HorizontalAlignment', 'right','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2-2 pheight-3.75 2  0.5],'string','Init cond:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'FontUnits', 'points', 'FontSize', 10);
    selvarHndl = uicontrol( ...
        'Style','popup', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[pwidth/2+0.25 pheight-3.75 pwidth/2-0.75 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '...', ...
        'Value', 1, ...
        'BackgroundColor', 'w', 'CallBack', 'launchXPP(''getinitcond'');');
    
    if model.numforce > 0
        uicontrol( 'HorizontalAlignment', 'right','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2-2 pheight-4.5 2 0.5],'string','Force:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'FontUnits', 'points', 'FontSize', 10);
        selforceHndl = uicontrol( ...
            'Style','popup', ...
            'HorizontalAlignment', 'left', ...
            'Units','centimeters', ...
            'position',[pwidth/2+0.25 pheight-4.5 pwidth/2-0.75 0.6], ...
            'HandleVisibility', 'on', ...
            'Parent',panel, ...
            'FontUnits', 'points', 'FontSize', 10, ...
            'String', '...', ...
            'Value', 1, ...
            'BackgroundColor', 'w', ...
            'CallBack', 'launchXPP(''getforce'');');
    end
     
   uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5.5 pwidth-1  0.5],'string','Now you can edit the selected values below', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    
   %list of parameters
   paramTbl = uitable('units', 'centimeters', 'position', [0.5 1.25 pwidth/2-0.75 pheight-7.25], ...
       'fontunits', 'points', 'fontsize', 10, ...
       'parent', panel, 'ColumnName', {'Parameter', 'Value'}, 'Rowname', [], ...
       'ColumnFormat', {'char', 'numeric'}, 'ColumnEditable', [false true]);

   
   %list of init cond
   if model.numforce > 0
       tbl_lower = 3.25;
   else
       tbl_lower = 1.25;
   end
   varTbl = uitable('units', 'centimeters', 'position', [pwidth/2+0.25 tbl_lower pwidth/2-0.75 pheight-tbl_lower-6], ...
       'fontunits', 'points', 'fontsize', 10, ...
       'parent', panel, 'ColumnName', {'Variable', 'Value'}, 'Rowname', [], ...
       'ColumnFormat', {'char', 'numeric'}, 'ColumnEditable', [false true]);
   
   set([paramTbl varTbl], 'units', 'pixels')
   tblwidth = get(varTbl, 'position');
   tblwidth = tblwidth(3);
   set([paramTbl varTbl], 'ColumnWidth', {[tblwidth*0.47], [tblwidth*0.47]});
   
   %table of force values
   if model.numforce > 0
       
       forcetypeHndl= uitable('parent', panel, 'Units','centimeters', 'FontUnits', 'points', 'FontSize', 10, 'position', [pwidth/2+0.25 1.25 pwidth/2-0.75 1.75], ...
           'ColumnName', {'Force', 'Type', 'Dawn', 'Dusk'}, ...
           'ColumnFormat', {'char', get_all_force_types(), 'numeric', 'numeric'}, 'ColumnEditable', [false true true true]);
       set(forcetypeHndl, 'units', 'pixels')
       tblwidth = get(forcetypeHndl, 'position');
       tblwidth = tblwidth(3);
       set(forcetypeHndl, 'ColumnWidth', {[tblwidth*0.2] [tblwidth*0.3], [tblwidth*0.19], [tblwidth*0.19]});
   end
   
    if strcmp(model.orbit_type,'oscillator')
        if model.numforce > 0
            msg = 'Cycle period for forced oscillator:';
        else
            msg = 'Length of time to run simulation:';
        end
        t_len = model.cycle_period;
    else
        msg = 'Length of time to run simulation:';
        t_len = model.tend;
    end
    
    uicontrol( 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 0.4 pwidth-3 0.5],'string',msg, 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'FontUnits', 'points', 'FontSize', 10);
    cpHndl = uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'right', ...
        'Units','centimeters', ...
        'position',[pwidth/2-2.25 0.4 2 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'String', num2str(t_len), ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'BackgroundColor', 'w');
   
   
   %OK and Cancel buttons
   
   OKHndl = uicontrol(...
       'Style','pushbutton', ...
       'Units','centimeters', ...
       'Position',[figwidth-4.1 0.1 2 0.7], ...
       'Parent',newFig, ...
       'string', 'GO', ...
       'FontUnits', 'points', 'FontSize', 10, ...
       'Callback','launchXPP(''ok'');');
   
   cancelHndl = uicontrol(...
       'Style','pushbutton', ...
       'Units','centimeters', ...
       'Position',[figwidth-2.1 0.1 2 0.7], ...
       'Parent',newFig, ...
       'string', 'Cancel', ...
       'FontUnits', 'points', 'FontSize', 10, ...
       'Callback','launchXPP(''cancel'');');
   
   configHndl = uicontrol(...
       'Style','pushbutton', ...
       'Units','centimeters', ...
       'Position',[0.1 0.1 2 0.7], ...
       'Parent',newFig, ...
       'string', 'Configure', ...
       'FontUnits', 'points', 'FontSize', 10, ...
       'Callback','launchXPP(''config'');');
   
   %fill list boxes
   f = dir(fullfile(model.dir, '*.pv' ));
   paramfiles = cell(0);
   for i = 1:length(f)
       paramfiles{end+1} = f(i).name;
   end
   f = dir(fullfile(model.dir, '*.y' ));
   initfiles = cell(0);
   for i = 1:length(f)
       initfiles{end+1} = f(i).name;
   end
   f = dir(fullfile(model.dir, '*.fv' ));
   forcefiles = cell(0);
   for i = 1:length(f)
       forcefiles{end+1} = f(i).name;
   end
   
   if isempty(model.files)
       set(seltsHndl, 'enable', 'off');
       set(t1,'value', 0, 'enable', 'off');
   else
       set(seltsHndl, 'string', model.files);
   end
   if ~isempty(paramfiles)
       set(selparamHndl, 'string', paramfiles, 'value', 1);  
   end
   if ~isempty(initfiles)
       set(selvarHndl, 'string', initfiles, 'value', 1);
   end
   if ~isempty(forcefiles)
       set(selforceHndl, 'string', forcefiles, 'value', 1);
   end
   
   if isempty(ts)
       set(t2, 'value', 1);
   else
        set(t1, 'value', 1);
        %pre-select file
        [pth fname ext] = fileparts(ts.myfile);
        idx = find(strcmp(model.files, [fname ext]));
        set(seltsHndl, 'value', idx);
   end
   
   launchXPP('getall');
   
    set(newFig, 'visible', 'on');
    
    r = newFig; %uiwait function requires this function to return a value
    
elseif strcmp(action,'cancel')
        
    delete(gcf);
    
    
elseif strcmp(action,'config')
    
    %set the parameters to configure xpp launch
    
    uiwait(ConfigXPPGUI('init'));
    
elseif strcmp(action,'ok')
    
    %validate entries
    params = get(paramTbl, 'data');
    for p = 1:size(params, 1)
        if isnan(params{p, 2})
            ShowError('Please enter a value for all model parameters');
            uicontrol(paramTbl)
            return;
        end
        
    end
    
    init_c = get(varTbl, 'data');
    for v = 1:size(init_c, 1)
        if isnan(init_c{v, 2})
            ShowError('Please enter a value for all ininital conditions');
            uicontrol(varTbl)
            return;
        end
        
    end
    
    if model.numforce > 0
        force = get(forcetypeHndl, 'data');
        for f = 1:size(force, 1)
            if isnan(force{f, 3}) || isnan(force{f, 4})
                ShowError('Please enter a value for all force parameters');
                uicontrol(forcetypeHndl)
                return;
            end
        end
    else
        force = [];
    end
    


    t_len = str2double(get(cpHndl, 'string'));
    if isempty(t_len) || isnan(t_len) || t_len <= 0
        ShowError('Please enter a positive numeric value for cycle period');
        uicontrol(cpHndl);
        return;
    end
    
    
    %all valid
    fname = fullfile(model.dir, 'xpp', [model.name, '.ode']);
    xppdir = fullfile(model.dir, 'xpp');
    ok = writeODEFileforXPP(model, params, init_c, force, t_len, xppdir);  
    if ok
        %launch xppauto
        delete(gcf);
        runxppaut(fname);
    end

    
elseif strcmp(action,'getall')
    
    %user switching between time series object and using files
    opts = get(fileType, 'UserData');
    if get(opts(1), 'Value')
        %values based on the current time series file
        if model.numforce > 0
           set(selforceHndl, 'enable', 'off'); 
        end
        set([selparamHndl, selvarHndl], 'enable', 'off');
        set(seltsHndl, 'enable', 'on');
        launchXPP('gettsfile');
    else
        %select params, init_c and force files
        set([selparamHndl, selvarHndl], 'enable', 'on');
        if model.numforce > 0
           set(selforceHndl, 'enable', 'on'); 
        end
        set(seltsHndl, 'enable', 'off');
        launchXPP('getparams');
        launchXPP('getinitcond');
        launchXPP('getforce');
    end

elseif strcmp(action,'gettsfile')  
    
    %new time series object
    str = get(seltsHndl, 'string');
    fname = str{get(seltsHndl, 'value')};
    fname = fullfile(model.dir, 'results', fname);
    if exist(fname, 'file') == 2
        ts = load(fname, '-mat');
        f = fieldnames(ts);
        ts = getfield(ts, f{1});
        num_params = length(model.parn);
        %ts includes dawn and dusk. Don't want these
        params = [ts.parn(1:num_params) num2cell(ts.par(1:num_params))];
        set(paramTbl, 'data', params);
        init_c = [model.vnames num2cell(ts.sol.y(1,:)')];
        set(varTbl, 'data', init_c);
        if model.numforce > 0
            tbldata = {};
            for f = 1:length(ts.forceparams)
                tbldata{end+1, 1} = ts.forceparams(f).force;
                tbldata{end,2} = ts.forceparams(f).name;
                tbldata{end,3} = ts.forceparams(f).dawn;
                tbldata{end,4} = ts.forceparams(f).dusk;
            end
            set(forcetypeHndl, 'data', tbldata);
        else
            set(selforceHndl, 'data', {});
        end
        set(cpHndl, 'string', num2str(ts.sol.x(end) - ts.sol.x(1)));
    else
         set(paramTbl, 'data', [model.parn cell(length(model.parn, 1))]);
         set(varTbl, 'data', [model.vnames cell(length(model.vnames), 1)]);
         if model.numforce > 0
             forcenames = {};
             for f = 1:length(model.force_type)
                 forcenames{f} = model.force_type(f).name;
             end
             set(forcetypeHndl, 'data', [forcenames cell(model.numforce,1) cell(model.numforce,1) cell(model.numforce,1)]);
         end
      
    end
    
    
elseif strcmp(action,'getparams')
   
    %changing params file
    pfile = get(selparamHndl, 'string');
    pfile = pfile{get(selparamHndl, 'Value')};
    if exist(fullfile(model.dir, pfile), 'file') == 2
        fid_tmp = fopen(fullfile(model.dir, pfile), 'r');
        tmp_scan = textscan(fid_tmp, '%f');
        fclose(fid_tmp);
        values = tmp_scan{1};
        set(paramTbl, 'data', [model.parn num2cell(values)]);
    else
        set(paramTbl, 'data', [model.parn cell(length(model.parn, 1))]);
    end


elseif strcmp(action,'getinitcond')

    %new init cond file
    yfile = get(selvarHndl, 'string');
    yfile = yfile{get(selvarHndl, 'Value')};
    if exist(fullfile(model.dir, yfile), 'file') == 2
        fid_tmp = fopen(fullfile(model.dir, yfile), 'r');
        tmp_scan = textscan(fid_tmp, '%f');
        fclose(fid_tmp);
        values = tmp_scan{1};
        set(varTbl, 'data', [model.vnames num2cell(values)]);
    else
        set(varTbl, 'data', [model.vnames cell(length(model.vnames), 1)]);
    end
    
    
elseif strcmp(action,'getforce')

     %new force file 
     if model.numforce > 0
        ffile = get(selforceHndl, 'string');
        ffile = ffile{get(selforceHndl, 'value')};
        if exist(fullfile(model.dir, ffile) , 'file') == 2
            fp = fopen(fullfile(model.dir, ffile), 'rt');
            fvals = textscan(fp, '%s %s %f %f');
            fclose(fp);
            data = {};
            for i = 1:size(fvals{1},1)
                data{end+1, 1} = char(fvals{1}{i});
                data{i,2} = char(fvals{2}{i});
                data{i,3} = fvals{3}(i);
                data{i,4} = fvals{4}(i);
            end
            set(forcetypeHndl, 'data', data);
        else
            forcenames = {};
            for f = 1:length(model.force_type)
                forcenames{f} = model.force_type(f).name;
            end
            set(forcetypeHndl, 'data', [forcenames cell(model.numforce,1) cell(model.numforce,1) cell(model.numforce,1)]);
        end
    end
         
end


%========================================================================

function runxppaut(odeFilename)

%if silent mode, creates a file called output.dat
%must rename this 

if ispc
    [s msg] = system(['.\xpp\runxpp.bat "' odeFilename '"']);
    %[s w] = system(['xppaut -silent ' odeFilename]);
else
    [s msg] = system(['./xpp/runxpp.sh "' odeFilename '"']);
end
if s % then failed
    ShowError('Call to XPP failed');
    ShowError(msg);
end

%can also run in silent mode and use matlab toplot and analyse the results,
%eg param range expt
