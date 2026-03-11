function newcyclegui(action, varargin)
 
%how to ensure that results.force cols order corrrwpsnds to force order on
%model.force
persistent theModel

%get a new limit cycle

%controls on this form
global newlcPanel newparamHndl newvarHndl newFig forcetypeHndl selfFileHndl saveFHndl;
global selvFileHndl selpFileHndl getlcHndl cancelnewHndl;
global varnumHndl ptHndl ldlabelHndl shiftsignHndl shiftHndl newsolverHndl newnameHndl;
global lcPlotHndl savePHndl saveVHndl tendHndl  tunitHndl ddlabelHndl cpHndl stiffsolverHndl   ;


if strcmp(action,'init')
   
    theModel = varargin{1};
    %'WindowStyle', 'modal',
    newFig=figure('menubar', 'none', 'resize', 'off', 'Units', 'centimeters','Name','New Time Series' ,'NumberTitle','off','Visible','on'); 
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    figwidth = 18;
    figheight = 19;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    set(newFig, 'Units', 'centimeters', 'Position', [figleft figbottom figwidth figheight]);


    % The panels
    panelheight = figheight-1.2;
    panelwidth = figwidth-0.2;
    newlcPanel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', get(newFig, 'Color'), ...
        'Units','centimeters', ...
        'Position',[0.1 1.1  panelwidth panelheight], ...
        'HandleVisibility', 'on', ...
        'Parent', newFig, 'Visible', 'on');
    
    ctrltop = panelheight - 0.5;
   
    %parameter values
    uicontrol('HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 ctrltop-0.5 (panelwidth-2)/2 0.5],'string','Select a Parameter file:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    selpFileHndl = uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[0.5 ctrltop-1.25 (panelwidth-2)/4 0.5], ...
        'HandleVisibility', 'on', ...
        'Parent',newlcPanel, ...
        'call', {@SelPFile, theModel}, ...
        'visible', 'on', ...
        'string', '-none-', ...
        'BackgroundColor', 'w', ...
        'FontUnits', 'points', 'FontSize', 10);
    %save button 
     savePHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[(panelwidth-2)/4+1 ctrltop-1.4 (panelwidth-2)/4-0.5 0.7], ...
        'Interruptible','on', ...
        'string', 'Save', ...
        'HandleVisibility', 'on', ...
        'Parent',newlcPanel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Callback',{@SaveP, theModel});
    
    newparamHndl= uitable('parent', newlcPanel, 'Units','centimeters', 'FontUnits', 'points', 'FontSize', 10, 'position', [0.5 ctrltop-panelheight/2 (panelwidth-2)/2 panelheight/2-1.75], ...
                        'Rowname', [], 'ColumnName', {'Parameter Value'}, ...
                        'Data', {}, 'ColumnFormat', {'numeric'}, 'ColumnEditable', [true], ...
                        'CellEditCallback', {@paramChange, theModel});

   %init cond
    uicontrol('HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[panelwidth/2+0.5 ctrltop-0.5 (panelwidth-2)/2 0.5],'string','Select an Initial Conditions file:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    selvFileHndl = uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[panelwidth/2+0.5 ctrltop-1.25 (panelwidth-2)/4 0.5], ...
        'HandleVisibility', 'on', ...
        'Parent',newlcPanel, ...
        'call', {@SelVFile, theModel}, ...
        'visible', 'on', ...
        'string', '-none-', ...
        'BackgroundColor', 'w', ...
        'FontUnits', 'points', 'FontSize', 10);
    %save button 
     saveVHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[panelwidth*0.75+0.5 ctrltop-1.4 (panelwidth-2)/4-0.5 0.7], ...
        'Interruptible','on', ...
        'string', 'Save', ...
        'HandleVisibility', 'on', ...
        'Parent',newlcPanel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Callback', {@SaveV, theModel});
    
     newvarHndl= uitable('parent', newlcPanel, 'Units','centimeters', 'FontUnits', 'points', 'FontSize', 10, 'position', [panelwidth/2+0.5 ctrltop-panelheight/2 (panelwidth-2)/2 panelheight/2-1.75], ...
                        'Rowname', [], 'ColumnName', {'Initial Condition'}, ...
                        'Data', {}, 'ColumnFormat', {'numeric'}, 'ColumnEditable', [true]);

         
    %add files to lists
    f = dir(fullfile(theModel.dir, '*.pv'));
    fsp = cell(0);
    if ~isempty(f)
        for i = 1:length(f)
            fsp{end+1} = f(i).name;
        end
    else
        fsp = {'-none-'};
    end

    fsy = cell(0);
    f = dir(fullfile(theModel.dir, '*.y'));
    if ~isempty(f)
        for i = 1:length(f)
            fsy{end+1} = f(i).name;
        end
    else
         fsy = {'-none-'};
    end
    set(selpFileHndl, 'string', fsp);
    set(selvFileHndl, 'string', fsy);
    
  
    %estimate time units
    tunit = '';
    if theModel.plotting_timescale == 60
        tunit = 'min';
    elseif theModel.plotting_timescale == 1
        tunit = 'hrs';
    elseif theModel.plotting_timescale == 3600
        tunit = 'sec';
    else
        tunit = 'time units';
    end

   
    %force selectors
    ctrltop = ctrltop-panelheight/2;
    
    if  theModel.numforce > 0
        enabled = 'on';
    else
        enabled = 'off';
    end
    uicontrol('Enable', enabled, 'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 ctrltop-1 (panelwidth-2)/2 0.5],'string','Select a Force file:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    selfFileHndl = uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[0.5 ctrltop-1.75 (panelwidth-2)/4 0.5], ...
        'HandleVisibility', 'on', ...
        'Parent',newlcPanel, ...
        'call', {@SelFFile, theModel}, ...
        'visible', 'on', ...
        'string', '-none-', ...
        'BackgroundColor', 'w', ...
        'Enable', enabled, ...
        'FontUnits', 'points', 'FontSize', 10);
    %save button 
     saveFHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[(panelwidth-2)/4+1 ctrltop-1.9 (panelwidth-2)/4-0.5 0.7], ...
        'Interruptible','on', ...
        'string', 'Save', ...
        'HandleVisibility', 'on', ...
        'Parent',newlcPanel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Enable', enabled, ...
        'Callback',{@SaveF, theModel});
    %list of force files
    f = dir(fullfile(theModel.dir, '*.fv'));
    fsf = cell(0);
    if ~isempty(f)
        for i = 1:length(f)
            fsf{end+1} = f(i).name;
        end
    else
        fsf = {'-none-'};
    end
    set(selfFileHndl, 'string', fsf);
    forcenames = cell(0);data = cell(0);
    for f = 1:length(theModel.force_type)
        %fill defaults
        forcenames{end+1} = theModel.force_type(f).name;
        data{end+1,1} = theModel.force_type(f).type;
        data{end,2} = theModel.force_type(f).dawn;
        data{end,3} = theModel.force_type(f).dusk;
    end

    forcetypeHndl= uitable('parent', newlcPanel, 'Units','centimeters', 'FontUnits', 'points', 'FontSize', 10, 'position', [0.5 ctrltop-4.25 (panelwidth-2)/2 2], ...
                        'Rowname', forcenames, 'ColumnName', {'Type', 'Dawn', 'Dusk'}, 'Enable', enabled, ...
                        'Data', data, 'ColumnFormat', {get_all_force_types(), 'numeric', 'numeric'}, 'ColumnEditable', [true true true], ...
                        'CellEditCallback', {@ForceChange, theModel});
                    
    %force preview plot
  %  if strcmp(enabled, 'on')
        lcPlotHndl = axes('Visible', enabled,  'parent', newlcPanel,'units', 'centimeters', 'position', [panelwidth/2+0.5 ctrltop-4.25 (panelwidth-2)/2 3]);
   % end
    ctrltop = ctrltop-3;
    
    
   %set start/end of simulation
   if strcmp(theModel.orbit_type,'oscillator')
       
        %Add controls to get the period of peridic force
        uicontrol('Tag', 'forced','HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 3.25 6 0.5],'string','Set period of force','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        uicontrol('Tag', 'forced','Units','centimeters','position',[0.5 2.5 3 0.5],'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','string','Cycle Period','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        cpHndl=uicontrol('callback', {@ForceChange, theModel}, 'Tag', 'forced','Units','centimeters','position',[3 2.49 1 0.6],'String', theModel.cycle_period, 'HorizontalAlignment', 'right','Parent',newlcPanel ,'Style', 'edit','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);   
        uicontrol('Tag', 'forced','Units','centimeters','position',[4.25 2.5 2 0.5],'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','string',tunit,'BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        
        %control to determine phase for constant force
    
        uicontrol('Tag', 'unforced','HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 3.25 6 0.5],'string','Set phase of free running cycle','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        ldlabelHndl=uicontrol('Tag', 'unforced','Units','centimeters','position',[0.5 2.5 2 0.5],'string','Starts at', 'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        ptHndl=uicontrol('Tag', 'unforced','Units','centimeters','position',[2.25 2.52 3 0.5],'Value', 2, 'String', 'Peak|Trough','HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'popup','Units','normalized','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 9);
        ddlabelHndl=uicontrol('Tag', 'unforced','Units','centimeters','position',[5.25 2.5 0.5 0.5],'string','of','HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        varnumHndl=uicontrol('Tag', 'unforced','Units','centimeters','position',[5.75 2.52 3 0.5],'String', ['Default'; theModel.vnames],'HorizontalAlignment', 'left','Parent', newlcPanel ,'Style', 'popup','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 9);
        shiftsignHndl=uicontrol('Tag', 'unforced','Units','centimeters','position',[9 2.52 2 0.5],'String', '+|-','HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'popup','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        shiftHndl=uicontrol('Tag', 'unforced','Units','centimeters','position',[11.25 2.37 1 0.65],'String', '0','HorizontalAlignment', 'right','Parent',newlcPanel ,'Style', 'edit','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        tunitHndl=uicontrol('Tag', 'unforced','Units','centimeters','position',[12.5 2.5 1 0.5],'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','string',tunit,'BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    
  
        
   else
        %control to set length of run for non-oscialltor
        %no force
        uicontrol('HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 3.25 6 0.5],'string','Set length of simulation','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        uicontrol('string','Run for', 'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','Units','centimeters','position',[0.5 2.5 2 0.5],'BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        tendHndl = uicontrol('String', theModel.tend, 'HorizontalAlignment', 'right','Parent',newlcPanel ,'Style', 'edit','Units','centimeters','position',[2 2.49 2 0.6],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        uicontrol('string',tunit, 'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','Units','centimeters','position',[4.25 2.49 2 0.6],'BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        if  theModel.numforce > 0
           set(tendHndl, 'callback', {@ForceChange, theModel}); 
        end
   end
    
    %solver
    uicontrol('HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 1.5 4 0.5],'string','Select an ODE solver:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    newsolverHndl=uicontrol( 'String', {'matlab';'cvode'}, 'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'popup','Units','centimeters','position',[0.5 0.75 (panelwidth-2)/4 0.5],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
    
   stiffsolverHndl=uicontrol( 'String', {'stiff problem';'non-stiff problem'}, 'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'popup','Units','centimeters','position',[(1 + (panelwidth-2)/4) 0.75 (panelwidth-2)/4 0.5],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);

    if strncmp(theModel.ode_method, 'mat', 3)
       set(newsolverHndl, 'Value', 1); %set default solver
    else
       set(newsolverHndl, 'Value', 2); 
    end
    
    if strcmp(theModel.ode_method(end-8:end), 'non-stiff')
       set(stiffsolverHndl, 'Value', 2); %set default solver
    else
       set(stiffsolverHndl, 'Value', 1); 
    end
 
    %file name
    uicontrol('HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[panelwidth/2+0.5 1.5 4 0.5],'string','Enter a file name:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    newnameHndl=uicontrol('String', '', 'HorizontalAlignment', 'left','Parent',newlcPanel ,'Style', 'edit','Units','centimeters','position',[panelwidth/2+0.5 0.75 (panelwidth-2)/4 0.6],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

  
    %buttons
   getlcHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-5.1 0.1 2.5 0.8], ...
        'Interruptible','on', ...
        'string', 'Run', ...
        'HandleVisibility', 'on', ...
        'Parent',newFig, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Callback',{@Runlc, theModel});
    cancelnewHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.6 0.1 2.5 0.8], ...
        'Interruptible','on', ...
        'string', 'Cancel', ...
        'HandleVisibility', 'on', ...
        'Parent',newFig, ...
        'FontUnits', 'points', 'FontSize',10, ...
        'FontWeight', 'bold', ...
        'Callback','delete(gcf);');    %close main form
    
  
    %fill in tables of values and set column widths
    SelPFile(theModel);
    SelVFile(theModel); 
    SelFFile(theModel);
    uiwait(newFig);
end

%===========================================

function SelPFile(varargin)

%user has chosen a par file so fill in table with its values

global selpFileHndl newparamHndl

theModel = varargin{end};

fname = get(selpFileHndl, 'String');
idx = get(selpFileHndl, 'value');
fname = fname{idx};
params = cell(theModel.pnum,2);
for i = 1:theModel.pnum
    params{i, 1} = theModel.parn{i};
end

if strcmp(fname, '-none-')
    %no p file, so fill in default parameter values
    for i = 1:theModel.pnum
        params{i, 2} = theModel.parv(i);
    end
else
    %read selected file
    fid_tmp = fopen(fullfile(theModel.dir, fname), 'r');
    tmp_scan = textscan(fid_tmp, '%f');
    fclose(fid_tmp);
    pvals = tmp_scan{1};
    if length(pvals) ~= theModel.pnum
        ShowError('The selected parameters file is invalid.');
        return; 
    end  
    for i = 1:theModel.pnum
        params{i, 2} = pvals(i);
    end
end
    
set(newparamHndl, 'data', params(:,2), 'rowname', params(:,1));
%set col width
set(newparamHndl, 'units', 'pixels');
tblpos = get(newparamHndl, 'position');
tblheight = tblpos(4);
tblwidth = tblpos(3);
%first must ge trid of 'auto' setting so can read column width
set(newparamHndl, 'ColumnWidth', {[100]}); %make 100 pixels
%find empty space
datapos = get(newparamHndl, 'extent');
dataheight = datapos(4);
datawidth = datapos(3);
w = tblwidth-datawidth; %empty space
if dataheight > tblheight
    w = w - 15;
end
%increase colwidth by this much, minus 15 for a slider if required
set(newparamHndl, 'ColumnWidth', {[100 + w]});   
set(newparamHndl, 'units', 'centimeters');


%===========================================

function SelFFile(varargin)

%user has chosen a force file so fill in table with its values

global selfFileHndl forcetypeHndl

theModel = varargin{end};
forcenames = cell(0);data = cell(0);

if theModel.numforce > 0    %if no forces, called only at startup
    fname = get(selfFileHndl, 'String');
    idx = get(selfFileHndl, 'value');
    fname = fname{idx};
    
    if strcmp(fname, '-none-')
        %no fv file, so fill in default  values
        
        for f = 1:length(theModel.force_type)
            %fill defaults
            forcenames{f} = theModel.force_type(f).name;
            data{end+1,1} = theModel.force_type(f).type;
            data{end,2} = theModel.force_type(f).dawn;
            data{end,3} = theModel.force_type(f).dusk;
        end
    else
        %read selected file
        fp = fopen(fullfile(theModel.dir, fname), 'rt');
        fvals = textscan(fp, '%s %s %f %f');
        fclose(fp);
        if size(fvals{1},1) ~= theModel.numforce
            ShowError('The selected force file is invalid.');
            return;
        end
        for i = 1:size(fvals{1},1)
            forcenames{i} = theModel.force_type(i).name;
            data{i,1} = char(fvals{2}{i});
            data{i,2} = fvals{3}(i);
            data{i,3} = fvals{4}(i);
        end
    end
end
    
%set col width
set(forcetypeHndl, 'data', data, 'rowname', forcenames);
ForceChange(theModel); 


%set col width
set(forcetypeHndl, 'units', 'pixels');
tblpos = get(forcetypeHndl, 'position');
tblheight = tblpos(4);
tblwidth = tblpos(3);
%first must ge trid of 'auto' setting so can read column width
set(forcetypeHndl, 'ColumnWidth', {100 100 100}); %make 100 pixels
%find empty space
datapos = get(forcetypeHndl, 'extent');
dataheight = datapos(4);
datawidth = datapos(3);
w = tblwidth-datawidth; %empty space
if dataheight > tblheight
    w = w - 15;
end
%increase colwidth by this much, minus 15 for a slider if required
set(forcetypeHndl, 'ColumnWidth', {(100 + w/3) (100 + w/3) (100 + w/3)});   
set(forcetypeHndl, 'units', 'centimeters');


%============================================
function SelVFile(varargin)

%user has chosen an initial cond file
global selvFileHndl newvarHndl 

theModel = varargin{end};

fname = get(selvFileHndl, 'String');
idx = get(selvFileHndl, 'value');
fname = fname{idx};
initc = cell(theModel.vnum,2);
for i = 1:theModel.vnum
    initc{i, 1} = theModel.vnames{i};
end

if strcmp(fname, '-none-')
    %no p file, so fill in default  values
    for i = 1:theModel.vnum
        initc{i, 2} = theModel.init_cond(i);
    end
else
    %read selected file
    fid_tmp = fopen(fullfile(theModel.dir, fname), 'r');
    tmp_scan = textscan(fid_tmp, '%f');
    fclose(fid_tmp);
    ivals = tmp_scan{1};
    if length(ivals) ~= theModel.vnum
        ShowError('The selected initial conditions file is invalid.');
        return; 
    end  
    for i = 1:theModel.vnum
        initc{i, 2} = ivals(i);
    end
end
    
set(newvarHndl, 'data', initc(:,2), 'rowname', initc(:,1));
%set col width
set(newvarHndl, 'units', 'pixels')
tblpos = get(newvarHndl, 'position');
tblwidth = tblpos(3);
tblheight = tblpos(4);
%first must ge trid of 'auto' setting so can read column width
set(newvarHndl, 'ColumnWidth', {[100]}); %make 100 pixels
%find empty space
datapos = get(newvarHndl, 'extent');
datawidth = datapos(3);
dataheight = datapos(4);
w = tblwidth-datawidth; %empty space
if dataheight > tblheight
    w = w - 15;
end
%increase colwidth by this much, miuns 15 for a slider if required
set(newvarHndl, 'ColumnWidth', {[100 + w]});   
set(newvarHndl, 'units', 'centimeters')

%==========================================================================

function SaveP(src, evnt, theModel)

global selpFileHndl newparamHndl

%called only when clicking Save button
overwriting = false;

params = get(newparamHndl, 'data');
%validate first
for p = 1:length(params)
   if isnan(params{p})
      errordlg(['Please enter a numeric value for ' theModel.parn{p} '.'], 'Error', 'modal');
      return;
   end
end

str = get(selpFileHndl, 'String');
idx = get(selpFileHndl, 'value');
init_name = str{idx};
if strcmp(init_name, '-none-')
    init_name = [theModel.name '.pv'];
end

%get new file name
fname = GetFileName(init_name);
if isempty(fname)
    return; %user cancelled
end

%add extension
if length(fname) > 2
    if ~strcmp(fname(end-2:end), '.pv')
        fname = [fname '.pv'];
    end
else
    fname = [fname '.pv'];
end
fullfname = fullfile(theModel.dir, fname);

%check if it exists
if exist(fullfname, 'file') == 2
    response = questdlg('Overwrite the existing parameters file?', 'New file', 'Yes', 'No', 'Yes');
    if strcmp(response, 'No')
        return;
    end
    overwriting = true;
end

fid = fopen(fullfname, 'wt');
if fid > 0
    for p = 1:length(params)
       fprintf(fid, '%g\n', params{p}); 
    end
    fclose(fid);
    %refresh list of files and select new one
    if overwriting
        %find and select
        set(selpFileHndl,  'value', find(strcmp(str, fname)));
    else
        %new file
        str{end+1} = fname;
        set(selpFileHndl, 'String', str, 'value', length(str));
    end
else
    ShowError('Error creating the new parameters file.');
end

%==========================================================================
function SaveV(src, evnt, theModel)

%called only when clicking Save button

global selvFileHndl newvarHndl

%called only when clicking Save button
overwriting = false;

%validate first
initc = get(newvarHndl, 'data');
for v = 1:length(initc)
   if isnan(initc{v})
      errordlg(['Please enter a numeric value for ' theModel.vnames{v} '.'], 'Error', 'modal');
      return;
   elseif strcmp(theModel.positivity, 'non-negative')
       if initc{v} < 0
           errordlg(['Please enter a non-negative value for ' theModel.vnames{v} '.'], 'Error', 'modal');
           return;
       end
   end
end

str = get(selvFileHndl, 'String');
idx = get(selvFileHndl, 'value');
init_name = str{idx};
if strcmp(init_name, '-none-')
    init_name = [theModel.name '.y'];
end

%get new file name
fname = GetFileName(init_name);
if isempty(fname)
    return; %user cancelled
end

%add extension
if length(fname) > 1
    if ~strcmp(fname(end-1:end), '.y')
        fname = [fname '.y'];
    end
else
    fname = [fname '.y'];
end
fullfname = fullfile(theModel.dir, fname);

%check if it exists
if exist(fullfname, 'file') == 2
    response = questdlg('Overwrite the existing initial conditions file?', 'New file', 'Yes', 'No', 'Yes');
    if strcmp(response, 'No')
        return;
    end
    overwriting = true;
end

fid = fopen(fullfname, 'wt');
if fid > 0
    for v = 1:length(initc)
       fprintf(fid, '%g\n', initc{v}); 
    end
    fclose(fid);
    %refresh list of files and select new one
    if overwriting
        %find and select
        set(selvFileHndl,  'value', find(strcmp(str, fname)));
    else
        %new file
        str{end+1} = fname;
        set(selvFileHndl, 'String', str, 'value', length(str));
    end
else
    ShowError('Error creating the new initial conditions file.');
end

%==========================================================================

function SaveF(src, evnt, theModel)

%called only when clicking Save button

global selfFileHndl forcetypeHndl

%called only when clicking Save button
overwriting = false;

str = get(selfFileHndl, 'String');
idx = get(selfFileHndl, 'value');
init_name = str{idx};
if strcmp(init_name, '-none-')
    init_name = [theModel.name '.fv'];
end

%get new file name
fname = GetFileName(init_name);
if isempty(fname)
    return; %user cancelled
end

%add extension
if length(fname) > 2
    if ~strcmp(fname(end-2:end), '.fv')
        fname = [fname '.fv'];
    end
else
    fname = [fname '.fv'];
end
fullfname = fullfile(theModel.dir, fname);

%check if it exists
if exist(fullfname, 'file') == 2
    response = questdlg('Overwrite the existing force file?', 'New file', 'Yes', 'No', 'Yes');
    if strcmp(response, 'No')
        return;
    end
    overwriting = true;
end

fid = fopen(fullfname, 'wt');
if fid > 0
    ft = get(forcetypeHndl, 'data');

    for f = 1:size(ft,1)
        type = ft{f, 1};
        dawn = ft{f, 2};
        dusk = ft{f, 3};
       fprintf(fid, '%s %s %g %g\n', theModel.force_type(f).name, type, dawn, dusk);
    end
    
    fclose(fid);
    %refresh list of files and select new one
    if overwriting
        %find and select
        set(selfFileHndl,  'value', find(strcmp(str, fname)));
    else
        %new file
        str{end+1} = fname;
        set(selfFileHndl, 'String', str, 'value', length(str));
    end
else
    ShowError('Error creating the new force file.');
end

%=================================================
function ForceChange(varargin)

%draws the currently selected force
%called when users selects or edits a force file or edits length of simulation

theModel = varargin{end};

global lcPlotHndl newparamHndl forcetypeHndl
global tendHndl  cpHndl  

    
%see if any selected forces are periodic

ft = get(forcetypeHndl, 'data');
per = 0;
ModelForce = [];
for f = 1:size(ft, 1)
    forcenames{f} = theModel.force_type(f).name;    %force, force1 etc...
    ModelForce(f).name = ft{f, 1};  %'photo', 'cts' etc...
    ModelForce(f).dawn = ft{f, 2};
    ModelForce(f).dusk = ft{f, 3};
    if ~force_is_constant(ft{f, 1}, theModel.orbit_type)
        per = 1;
    end
end
    
if strcmp(theModel.orbit_type, 'oscillator')

    %for oscillators enable the cycle period contorl for periodic force
    %and the phase contorls for constant force or model with no force
    forced_ctrls = findobj('Tag', 'forced');
    unforced_ctrls = findobj('Tag', 'unforced');
    if per   %periodic force
        set(forced_ctrls, 'visible', 'on');
        set(unforced_ctrls, 'visible', 'off'); 
    else %constant or no force
        set(forced_ctrls, 'visible', 'off');
        set(unforced_ctrls, 'visible', 'on');
    end 
end


%get length of simulation
if ~per
    if strcmp(theModel.orbit_type, 'oscillator')%only osc
        CP = str2double(theModel.cycle_period);
    else
        tend = get(tendHndl, 'String');
        tend = CorrectNumber(tend);
        if isempty(tend) || str2double(tend) < 0
            tend = theModel.tend;  %set to default
        end
        set(tendHndl, 'String', tend);
        tend = str2double(tend);
        CP = tend;
    end
    t = [0 CP];
else    %periodic force
    if strcmp(theModel.orbit_type, 'oscillator')%only osc
        %cycle period
        cp = get(cpHndl, 'String');
        cp = CorrectNumber(cp);
        if isempty(cp) || str2double(cp) < 0
            cp = theModel.cycle_period;  %set to default
        end
        set(cpHndl, 'String', cp);
    else
        tend = get(tendHndl, 'String');
        tend = CorrectNumber(tend);
        if isempty(tend) || str2double(tend) < 0
            tend = theModel.tend;  %set to default
        end
        set(tendHndl, 'String', tend);
        cp = tend;
    end
    CP = str2double(cp);
    t = [0:(CP/1000):CP];
end

if theModel.numforce > 0
    force = plusforce(theModel, t, ModelForce, CP);
    
    t = t - t(1);
    t = t / theModel.plotting_timescale;
    plot(lcPlotHndl,t , force, 'Linewidth', 2);
    xlim([t(1) t(end)]);
    ylim([0 1.1]);
    set(gca, 'ytick', []);
    ylabel({''});
    xlabel('Time');
    if length(forcenames) > 1
        legend(forcenames);
    end
end


%============================================

function Runlc(src, evnt, theModel)

global shiftHndl shiftsignHndl varnumHndl newsolverHndl stiffsolverHndl
global ptHndl newnameHndl newparamHndl newvarHndl newFig;
global getlcHndl cancelnewHndl forcetypeHndl;
global newtsfilename tendHndl cpHndl;

%find the force types selected
ft = get(forcetypeHndl, 'data');
per = 0;
ModelForce = [];
for f = 1:size(ft, 1)
   %The order of these must match the order of the force(n) vector in the
   %equations. Will do as 'make' matches sorted list of force names with
   %force(n). names appear in the same order in info file and in fv files.
    ModelForce(f).force = theModel.force_type(f).name;  %force, force1 etc...
    ModelForce(f).name = ft{f, 1}; %'photo', 'cts', etc ...
    ModelForce(f).dawn = ft{f, 2};
    ModelForce(f).dusk = ft{f, 3};
    if ~force_is_constant(ft{f, 1}, theModel.orbit_type)
        per = 1;    %at least one force is periodic
    end
end

%check input parameters are valid - shift and timepoints
if strcmp(theModel.orbit_type, 'oscillator')%only osc
    if ~per
        env = 0;
        %Time shift
        shift = get(shiftHndl, 'String');
        shift = CorrectNumber(shift);
        if isempty(shift) || str2double(shift) < 0
            shift = '0';
        end
        set(shiftHndl, 'String', shift);
        shift = str2double(shift);
        if(get(shiftsignHndl, 'value') == 2)
            shift = -shift;
        end
        %variable number
        vn = get(varnumHndl,'Value');
        vn = vn - 1;
        if ~vn
            vn = -1;    %use default
        end
        if get(ptHndl, 'Value') == 1
            mtype = 'max';
        else
            mtype = 'min';
        end  
       %CP not used for unforced
       cp = theModel.cycle_period;
       
    else    %periodic force
        env = 1; %forced
        vn = 1;
        shift = 0;
        %cycle period
        cp = get(cpHndl, 'String');
        cp = CorrectNumber(cp);
        if isempty(cp) || str2double(cp) < 0
            cp = theModel.cycle_period;  %set to default
        end
        set(cpHndl, 'String', cp);
        cp = str2double(cp);
        %mtype not used for forced model
        mtype = [];
    end
else
    %non-oscillator model
    if per
        env = 1;
    else
        env = 0;
    end
    %tend for signal
    tend = get(tendHndl, 'String');
    tend = CorrectNumber(tend);
    if isempty(tend) || str2double(tend) <= 0
        tend = theModel.tend;  %set to default
    end
    set(tendHndl, 'String', tend);
    tend = str2double(tend);
end

%solver
sol = get(newsolverHndl, 'String');
si = get(newsolverHndl, 'Value');
sol = sol{si};

stiff = (get(stiffsolverHndl, 'value') == 1);

%params values
params = cell2mat(get(newparamHndl, 'data'));
%ic values
initc = cell2mat(get(newvarHndl, 'data'));


%new file name
rname = get(newnameHndl, 'String'); 
%illegal chars
badname = false;
if isempty(rname)
    badname = true;
else
    for i = 1:length(rname)
        if ~isstrprop(rname(i), 'alphanum')
            if (~strcmp('_', rname(i)) && ~strcmp('.', rname(i))) || i == 1
                badname = true;
                break;
            end
        end
    end
end
if badname
    uiwait(msgbox('Please enter a file name beginning with an alphanumeric character, and consisting only of alphanumeric characters, ''-'' or ''.''','error','modal'));
    return;
end
          
if length(rname) > 4
    if ~strcmp('.mat', rname(end-3:end))
        rname = [rname '.mat'];
    end
else
      rname = [rname '.mat'];
end

fullrname = fullfile(theModel.dir, 'results', rname);
if exist(fullrname, 'file') == 2 
    uiwait(msgbox(['The file ' rname ' already exists. Please choose a different name.'],'error','modal'));
    return;
end
set([getlcHndl cancelnewHndl], 'enable', 'off');

%launch simulation
try
    set(newFig, 'visible', 'off');
    if strcmp(theModel.orbit_type, 'oscillator')
        %16 means 16 steps to prog bar.
        %5 is estimate at time in sec between steps. More accurate this is 
        %the smoother the bar moves
        progressform('init', 16, 5);
        theresults = limitcycle(theModel, 'gui', @progressform, 'param', params, 'ic', initc, 'varnum', vn, 'mtype', mtype, 'shift', shift, 'solver', {sol stiff}, 'env', env, 'force_type', ModelForce, 'cycle_period', cp);
    else
        progressform('init', 3, 5);
        theresults = signal(theModel, 'gui', @progressform, 'param', params, 'ic', initc, 'solver', {sol stiff}, 'env', env, 'force_type', ModelForce, 'tend', tend);
    end
   progressform('end');
catch err
   theresults = [];

   progressform('write', 'Error generating the limit cycle');
   progressform('end');
   ShowError('Error generating the limit cycle', err);

end
%save solution
if ~isempty(theresults)
    if exist(fullfile(theModel.dir, 'results'), 'dir') == 0
        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(theModel.dir, 'results'));
        if ~SUCCESS
           ShowError(['Error saving results in ', theModel.dir, ' : ', MESSAGE]); 
        end
    end
    save(fullrname, 'theresults');
    newtsfilename = rname;

end
delete(newFig);


%==================================================
function str = CorrectNumber(str)

%this function ensures str is a proper positive numerical value 
%by removing non-digits and excess decimal points

to_remove = [];
for i = 1:length(str)
    if ~isstrprop(str(i), 'digit') && ~strcmp('.', str(i))
        to_remove = [to_remove i];
    end
end
str(to_remove) = [];
dps = find(str == '.');
if length(dps) > 1
    str(dps(2:end)) = [];
end




%==========================================================================

function fname = GetFileName(init)

options.Resize='off';
options.WindowStyle='modal';

fname=inputdlg('Enter a name for the new file:','New file name',1,{init},options);

if ~isempty(fname)
    fname = char(fname);
    %check for illegal characters
    for i=1:length(fname)
       if ~isstrprop(fname(i), 'alphanum') && (fname(i) ~= '_') && (fname(i) ~= '.')
           errordlg(['You can use alphanumeric characters plus _ or . in file names.'], 'Error', 'modal');
           fname = '';
           return;
       end
    end
end



%what if dawn> dusk or > CP etc ... make sure tend big enough

%load initc fro existing limit cycle???

%setting menu option, eg tol values

