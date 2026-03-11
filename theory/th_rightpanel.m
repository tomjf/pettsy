function r = th_rightpanel(action, varargin)

persistent mainFig lblHndl plotTypeHndl plotHndl plotTypePanels PlotFuncs descHndl theModel tsData myPos panel fromTop jDescHndl;

r = [];
global plot_font_size %MD required size

plot_font_size=16; %MD required size

if strcmp(action, 'init')
    
    mainFig = varargin{1};
    maincol = get(mainFig, 'color');
    myPos = varargin{2};
    tstr = varargin{3};
    pheight = myPos(4);
    pwidth = myPos(3);
    %measure height from to of figure
    %so we can keep this constant if figure increases in height
    figheight= get(mainFig, 'position');
    figheight = figheight(4);
    fromTop = figheight-(myPos(2)+myPos(4));
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',myPos, ...
        'HandleVisibility', 'on', ...
        'title', 'Plotting', ...
        'Parent', mainFig);
 
    lblPos(1) = 0.2;
    lblPos(2) = pheight-0.7;
    lblPos(3) = 1.4;
    lblPos(4) = 0.5;
 %   lblHndl =  uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',lblPos,'string',tstr,'BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);

    PlotFuncs = {'th_plottseries'; 'th_plotderivative'; 'th_plotperiod'; 'th_plotirc'; 'th_plotphasederivative'; 'th_plotphaseirc'; };
    theModel = []; tsData = [];

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
        'call','th_rightpanel(''changePlotType'');');
   % descHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3.3 pwidth-1 1.5],'string','','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
   descHndl = uipanel('Parent',panel, 'BorderType', 'none' ,'Units','centimeters','position',[0.5 pheight-3.4 pwidth-1 1.7],'BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
   label_size_in_cm = [0 0 pwidth-1 1.7];
   [jDescHndl, ~] = create_html_panel(descHndl, label_size_in_cm, '', false);
    
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
        'FontWeight', 'bold', ...
        'Enable', 'off', ...
        'Callback','th_rightpanel(''plot'');');

     %plot specific panels
    frmPos = [0.25 1.75 pwidth-0.5 pheight-5.75];
  
    plotTypePanels = zeros(length(PlotFuncs),1);
    PlotNames = cell(length(PlotFuncs),1);
    for i = 1:length(PlotFuncs)
        %this list of the panels allows them to be shown when appropriate
        %this creates the controls on the panel
        plotTypePanels(i) = feval(PlotFuncs{i}, 'init', panel, frmPos);
        set( plotTypePanels(i), 'title', 'Settings');
        %fill in name of plot in list
        PlotNames(i) = cellstr(feval(PlotFuncs{i}, 'name'));
    end
  %  uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 pheight-4.3 1.5 0.5],'string','Settings','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    set(plotTypeHndl, 'String', PlotNames, 'Value', 1);
    th_rightpanel('changePlotType', action);
    
    r = panel;
    
elseif strcmp(action, 'position')
    
    %called when figure resized. Ensures absolute position is maintained
    set(panel, 'visible', 'off');
    figheight= get(mainFig, 'position');
    figheight = figheight(4);
    pos = myPos;
    pos(2) = figheight-(fromTop+myPos(4));
    set(panel, 'position', pos);
    set(panel, 'visible', 'on');
    
elseif strcmp(action, 'changePlotType')
    %called when user changes plot
    %show/hide plot specific panels according to selected plot
    v = get(plotTypeHndl, 'Value');
    for i = 1:length(plotTypePanels)
        if i == v
            feval(PlotFuncs{i}, 'show');
            %is it valid for this type of data?
            if nargin > 1 && strcmp(varargin{1}, 'init')
                %if startup, false suppresses warning message
                valid = feval(PlotFuncs{i}, 'isvalid', theModel, tsData, 1);
            else
                th_tippanel('clear_highlight');
                valid = feval(PlotFuncs{i}, 'isvalid', theModel, tsData, 2);
            end
            if valid
                set(plotHndl, 'enable', 'on');
            else
                set(plotHndl, 'enable', 'off');
            end
        else
           feval(PlotFuncs{i}, 'hide');
        end
    end
    desc = feval(PlotFuncs{v}, 'description');
    %set(descHndl, 'String', desc);
    %if not html,text won't wrap
     tt_text = desc;
    desc = ['<html><span style = "font-size:9px">' desc]; %MD changed from 9 to 8 so all fits. 

    try
        jDescHndl.Data = desc;
    catch
        set(jDescHndl, 'String', regexprep(desc, '<[^>]*>', ''));
    end
    
elseif strcmp(action, 'changefile')
    %user has selected a new time series file
    
    theModel = varargin{1};
    tsData = varargin{2};
    
    %update all plots
    for p = 1:length(PlotFuncs)
        feval(PlotFuncs{p}, 'changefile', theModel, tsData);
    end
    %find which is selected
    p = get(plotTypeHndl, 'Value');
    %is it valid for this type of data?
    if feval(PlotFuncs{p}, 'isvalid', theModel, tsData, 3);
        set(plotHndl, 'enable', 'on');
    else
        set(plotHndl, 'enable', 'off');
    end
    
elseif strcmp(action, 'newtheory')
    %theory run on selected time series file
    
    theModel = varargin{1};
    tsData = varargin{2};
    
    for p = 1:length(PlotFuncs)
        feval(PlotFuncs{p}, 'newtheory', theModel, tsData);
    end
    %find which is selected
    p = get(plotTypeHndl, 'Value');
    %is it valid for this type of data?
    if feval(PlotFuncs{p}, 'isvalid', theModel, tsData, 4);
        set(plotHndl, 'enable', 'on');
    else
         set(plotHndl, 'enable', 'off');
    end

elseif strcmp(action, 'plot') 
    %called when user clicks plot
    %call plot function of whihcever plot type is selected
    p = get(plotTypeHndl, 'Value');
    feval(PlotFuncs{p}, 'plot', theModel, tsData);
    
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
    th_rightpanel('changePlotType');
    %set values of the plot specific controls at startup
    idx = 2;
    for p = 1:length(PlotFuncs)
        idx = feval(PlotFuncs{p}, 'set', idx, vals);
    end
    
end


