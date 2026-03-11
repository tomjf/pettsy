function r = sa_rightpanel(action, varargin)

global btncol maincol;

persistent plotTypeHndl plotHndl plotTypePanels PlotFuncs descHndl plotCmbHndl;

r = [];

if strcmp(action, 'init')
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',varargin{2}, ...
        'HandleVisibility', 'on', ...
        'title', 'Plotting', ...
        'Parent', varargin{1});
    
    pheight = varargin{2}(4);
    pwidth = varargin{2}(3);

    %list box of plot types
    uicontrol('Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 pheight-1.3 pwidth/2-1 0.5],'string','Select a plot type','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    plotTypeHndl = uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[pwidth/2 pheight-1.3 pwidth/2-0.5 0.5], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'String' , 'Plots', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'call','sa_rightpanel(''changePlotType'');');
    descHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.25 pheight-3.8 pwidth-0.5 2],'string','','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);


    %plot button
    plotHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[pwidth/2 0.5 pwidth/2-0.5 0.75], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Plot', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Enable', 'off', ...
        'Callback','sagui(''plot'');');
    %plot combined graphs??   
    plotCmbHndl = uicontrol('Parent',panel ,'Style', 'checkbox','FontWeight', 'bold','Units','centimeters','position',[0.5 0.5 pwidth/2-0.5 0.5],'string','Plot combined SDS','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10, 'Enable', 'off','Value', 1);
    
    r = panel;
    
     %plot specific panels
    frmPos = [0.25 1.75 pwidth-0.5 pheight-5.75];
    PlotFuncs = varargin{3};
    plotTypePanels = zeros(length(PlotFuncs),1);
    PlotNames = cell(length(PlotFuncs),1);
    for i = 1:length(PlotFuncs)
        %this list of the panels allows them to be shown when appropriate
        %this creates the controls on the panel
        plotTypePanels(i) = feval(PlotFuncs{i}, 'init', panel, frmPos);
        %fill in name of plot in list
        set(plotTypePanels(i), 'title', 'Settings');
        PlotNames(i) = cellstr(feval(PlotFuncs{i}, 'name'));
    end
   % uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 pheight-4.3 1.5 0.5],'string','Settings','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    %plot button
    set(plotTypeHndl, 'String', PlotNames, 'Value', 1);
    sa_rightpanel('changePlotType');
elseif strcmp(action, 'changePlotType')
    %called when user changes plot
    %show/hide plot specific panels according to selected plot
    v = get(plotTypeHndl, 'Value');
    for i = 1:length(plotTypePanels)
        if i == v
            set(plotTypePanels(i), 'Visible', 'on');
        else
            set(plotTypePanels(i), 'Visible', 'off');
        end
    end
    desc = cellstr(feval(PlotFuncs{v}, 'description'));
    set(descHndl, 'String', desc);

elseif strcmp(action, 'fillPlotSDSCtrls')
    %called when SDS is calculated to fill in parameter and strength related plot specific controls
    sds = varargin{1};
    for p = 1:length(PlotFuncs)
        feval(PlotFuncs{p}, 'fillSDS', sds);
    end
elseif strcmp(action, 'nodata')
    for p = 1:length(PlotFuncs)
        idx = feval(PlotFuncs{p}, 'unfill');
    end
elseif strcmp(action, 'save')
    %called when program exits
    fp = varargin{1};
    fprintf(fp, '%d\n', get(plotTypeHndl, 'Value'));
    for p = 1:length(PlotFuncs)
        feval(PlotFuncs{p}, 'save', fp);
    end
elseif strcmp(action, 'load') 
    %called at startup
    vals = varargin{1};
    set(plotTypeHndl, 'Value', str2double(vals{1}));
    sa_rightpanel('changePlotType');
    %set values of the plot specific controls at startup
    idx = 2;
    for p = 1:length(PlotFuncs)
        idx = feval(PlotFuncs{p}, 'set', idx, vals);
    end
elseif strcmp(action, 'plot') 
    %called when user clicks plot
    %call plot function of whihcever plot type is selected
    SDSdata = varargin{1};  
    plotCmb = get(plotCmbHndl, 'Value');
    p = get(plotTypeHndl, 'Value');
    feval(char(PlotFuncs(p)), 'plot', SDSdata, plotCmb);
elseif strcmp(action, 'enableplot') 
    pt = varargin{1};
    cmb = varargin{2};
    set(plotHndl, 'Enable', pt);
    if cmb == 0
        %user selected only 1 expt to analyse
        set(plotCmbHndl, 'enable', 'off', 'Value', 0);
    elseif cmb == 1
        % > 1 selected so allow combined plots
        set(plotCmbHndl, 'enable', 'on');
    else
        %no current SDS
        set(plotCmbHndl, 'enable', 'off');
    end
    
end


