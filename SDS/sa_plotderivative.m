function r = sa_plotderivative(action, varargin)

global maincol btncol plot_font_size
persistent varList; %which variables listbox
persistent parList; %which parameters listbox
persistent scaleHndl; %raw abs or log
persistent panel selAllHndl clearHndl divHndl;

r = [];

if strcmp(action, 'init')
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',varargin{2}, ...
        'HandleVisibility', 'on', ...
        'Visible', 'off', ...
        'Parent', varargin{1});
    
    pheight = varargin{2}(4);
    pwidth = varargin{2}(3);
    %create controls
    %which vars to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth/2-1 0.5],'string','Select the Variables to Plot','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    varList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-4 pwidth/2-0.5 3],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
    
    %select the variables
    selAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-2.5 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Select All', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotderivative(''selAllVars'');');
    
    clearHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-3.1 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Clear', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotderivative(''clearAllVars'');');
    
    %which params to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5 pwidth/2-1 0.5],'string','With Respect to Parameters','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    parList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-7.5 pwidth/2-0.5 3],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
    
    
    %divide by time series??
    divHndl = uicontrol('Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-8.75 pwidth-1 0.5],'string','Divide derivative by variable time series','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    %raw, abs or log?
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 0.5 pwidth/2-1 0.5],'string','Select the values to plot','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    scaleHndl = uibuttongroup('units', 'centimeters', 'Position', [pwidth/2 0.5 pwidth/2-0.5 0.6], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    t1=uicontrol('Parent',scaleHndl,'string', 'raw data' ,'Units','normalized','Style','togglebutton', 'position',[0/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    t2=uicontrol('Parent',scaleHndl,'string', 'absolute' ,'Units','normalized','Style','togglebutton', 'position',[33/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    t3=uicontrol('Parent',scaleHndl,'string', 'log abs' ,'Units','normalized','Style','togglebutton', 'position',[66/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(scaleHndl, 'UserData', [t1 t2 t3]);
    
    
    r = panel;
elseif strcmp(action, 'name')
    r = 'Solution Derivatives';
elseif strcmp(action, 'description')
    r = 'Plots the time series of the derivative of the solution variables with respect to parameters. Data can be divided by corresponding variable values and plotted as absolute or log absolute values.';
% elseif strcmp(action, 'fill')
%     %fill control values in response to changing results file
%     lc = varargin{1};
%     %fill in variable names and select all by default
%     set(varList, 'String', lc.vnames, 'Value', 1:length(lc.vnames));
elseif strcmp(action, 'fillSDS')
    %called when sds changes. Fill in parameters that were used
    sds = varargin{1};
     %fill in variable names and select all by default
    vnames = cell(0);
    ycols = [];
    for i = 1:length(sds.vnames)
        vnames = [vnames sds.vnames{i}];
        ycols = [ycols; (ones(length(sds.vnames{i}),1)*i) (1:length(sds.vnames{i}))'];
    end
    %record which dgs each variable belongs to 
    set(varList, 'String', vnames, 'Value', [1:length(vnames)], 'Userdata', ycols);
    %parameter names too
    set(parList, 'String', sds.parnames, 'Value', 1);
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set([parList varList], 'String', []);
elseif strcmp(action, 'plot')
    sds = varargin{1};
    all_y = get(varList, 'Value');
    ycols = get(varList, 'Userdata');
    ysel = zeros(size(ycols,1), 1);
    ysel(all_y) = 1;
    ptoplot = get(parList, 'Value'); %num axes on each figure
    %scaling
    opts = get(scaleHndl, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            scalev = i;
            break;
        end
    end
    %divide by time series??
    divts = get(divHndl, 'Value');

    if isempty(all_y)
        ShowError('Please select one or more variables to plot.');
    elseif isempty(ptoplot)
        ShowError('Please select one or more parameters to plot.');
    else
        %find which variables required for each dgs
        ytoplot = cell(length(sds.main_deriv),1);
        numplots = 0;
        for p = 1:length(sds.main_deriv)
            %cut selection down to this dgs
            ytoplot{p} = ycols(ysel & (ycols(:,1) == p), 2);
            if ~isempty(ytoplot{p}) 
                numplots = numplots + 1;
            end
        end
        
        pnames = get(parList, 'String');
        %shorten names
        for i = 1:length(pnames)
            j = strfind(pnames{i}, ',');
            j = j(1);
            pnames{i} = pnames{i}(1:j-1);
        end
        pnum = 0;
        for p = 1:length(sds.main_deriv)
            if ~isempty(ytoplot{p})
                pnum = pnum + 1;
                data = sds.main_deriv{p};
                lc = sds.lc{p};
                tspan = sds.t{p};
                len = length(tspan);
                vnames = sds.vnames{p};
                vnames = vnames(ytoplot{p});
                              
                %create seperate figure for each dgs
                if numplots == 1
                    pos = get_size_of_figure();
                else
                    pos = [(pnum-1)/numplots 0 1/numplots 1];
                end
                newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Solution Derivatives'],  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]); %MD background
                
                p_count = 0;
                firstplot = 1;
                for i = ptoplot
                    p_count = p_count+1;
                    subplot(length(ptoplot),1,p_count);
                    hold on;
                    ma=0;mi=0;
                    yvals = ytoplot{p}';
                    for j = yvals
                        u=(data((j-1)*len+1:j*len,i));
                        dv = ' ';
                        if divts
                            u = u ./ lc(:,j);
                            dv = ' / time series ';
                        end
                        if scalev == 2
                            u = abs(u);
                        elseif scalev == 3
                            u = log(abs(u));
                        end
                        mi=min(mi,min(u));ma=max(ma,max(u));
                        plot(tspan, u, get_plot_style(j),'LineWidth',2);
                    end
                    if mi ~= ma
                        ylim([1.05*mi 1.05*ma]);
                    end
                    xlim([tspan(1) tspan(end)]);
                    if scalev == 1
                        ylabel(['\partial y / \partial' pnames{i}], 'FontSize', plot_font_size);
                    elseif scalev == 2
                        ylabel(['|\partial y / \partial' pnames{i} '|'], 'FontSize', plot_font_size);
                    else
                        ylabel(['log |\partial y / \partial' pnames{i} '|'], 'FontSize', plot_font_size);
                    end
                    if sds.periodic(p)
                       per = ' Periodic ';
                    else
                        per = ' ';
                    end
                    
                    if firstplot
                        if scalev == 1
                            tstr = [sds.mymodel per 'Solution Derivatives' dv 'from '  sds.exptnames{p}];
                        elseif scalev == 2
                            tstr = [sds.mymodel ' Absolute' per 'Solution Derivatives' dv 'from ' sds.exptnames{p}];
                        else
                            tstr = [sds.mymodel ' Log Absolute' per 'Solution Derivatives' dv 'from ' sds.exptnames{p}];
                        end
                        title(tstr, 'FontSize', plot_font_size);
                        legend(gca, vnames);
                        firstplot = 0;
                    end
                    if p_count == length(ptoplot)
                        xlabel('Time', 'FontSize', plot_font_size);
                    end
                    hold off;
                end
                hold off;
            end
        end
    end
 %divide by time series, plot as heat maps option   
elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    %input arg is whole contents of file, idx is where to start reading it
    %return value if where next plot type needs to start
    idx = varargin{1};
    vals = varargin{2};
    vars = vals{idx};
    idx = idx + 1;
    scalev = vals{idx};
    idx = idx + 1;
    divts = vals{idx};
    idx = idx + 1;
    %The order they are set in must match the order they are written to file
    %in
    numvar = length(get(varList, 'String'));
    vars = sscanf(vars, '%f')';
    m = find( vars > numvar);
    vars(m) = [];
    set(varList, 'Value', vars);
    opts = get(scaleHndl, 'UserData');
    set(opts(str2double(scalev)), 'Value', 1);
    set(divHndl, 'Value', str2double(divts));
    %return index value for next panel
    r = idx; 
elseif strcmp(action, 'save')
    %save control values to file
    %the order here must match the order they are loaded in, as above
    fp = varargin{1};
    v = get(varList, 'Value');
    for i = 1:length(v)
        fprintf(fp, '%d ', v(i));
    end
    fprintf(fp, '\n');
    opts = get(scaleHndl, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            fprintf(fp, '%d\n', i);
            break;
        end
    end
    fprintf(fp, '%d\n', get(divHndl, 'Value'));
%========================================================================
elseif strcmp(action, 'selAllVars')
    str = get(varList, 'String');
    set(varList, 'Value', 1:length(str));
elseif strcmp(action, 'clearAllVars')
    set(varList, 'Value', []);
end



    
        %this is a list of handles for controls on this panel. Their values will be passed to the function creating the plot this panel applies to in the order in which the handles appear in the list
        %UserData for controls links them together so their values can be
        %synchronised. Groups are: 
        %1 scaling on principle components, sensitivity heat map,
        %sensitivty time series, spec and dplot, Strengths and Composite
        %amp per scatter plot
        %2 Tolerance for sensitivity heat map and Time Series with PCs
        %3 threshold type for sensitivity heat map and sensitivity time
        %series and composite
        %4 threshold value for sensitivity heat map, sensitivity timer
        %series and composite
        %5 start time for sensitivity heat map, sensitivity timer
        %series and composite
        %6 end time for sensitivity heat map, sensitivity timer
        %series and composite
        %7 normalise for plot strengths and composite
        %8 add sea level for plot strengths and composite
        %9 seal level value for plot strengths and composite
        %10 log for plot strengths and composite
        %11 parameter ordering for plot strengths 2d bar charts and
        %composite NOT USED
        %12 apply * W for pc_heatmap and composite plot and pc time series
        %13 normalise time series for time series plot and time series with
        %PCs
        %14 Num pcs for principle components and amp per scatter plot
        %15 Num vars for time series, principle components and amp per scatter plot
        
        %Add controls to these panels
 
%             case 'Principle Components'
%                 %list box for number of components
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[0 60/100 25/100 20/100],'string','Principle components to plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','listbox','Max', 10, 'Min', 0, 'String','1|2|3|4|5|6|7|8|9|10', 'position',[25/100 10/100 10/100 70/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.15, 'Tag', 'pc');
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 14, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',14);']);
%                  tm = [tm; tempHndl_sa];
%                  %and number of variables
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[40/100 60/100 20/100 20/100],'string','Variables to plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','listbox','Max', 10, 'Min', 0, 'String','1|2|3|4|5|6|7|8|9|10', 'position',[60/100 10/100 10/100 70/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.15, 'Tag', 'var');
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 15, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',15);']);
%                  tm = [tm; tempHndl_sa];
%                  %scaling
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[75/100 60/100 10/100 20/100],'string','Scaling','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[85/100 60/100 12.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',1);']);
%                  tm = [tm; tempHndl_sa];
%                   %divide by time series
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Divide by time series', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[77.5/100 25/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  tm = [tm; tempHndl_sa];
%                  
%             case 'Sensitivity Heat Map'
%                  %text box for tolerance
%                  %labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[67.5/100 70/100 15/100 20/100],'string','where >','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'where >', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[70/100 70/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','0.05', 'position',[79/100 70/100 6/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 2, 'callback', ['SensitivityAnalysisGUI5(''synch'',', num2str(i), ', 2 );']);
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[85/100 70/100 15/100 20/100],'string','of the global max','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  
%                  %scaling
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[6/100 70/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',', num2str(i) ', 1 );']);
%                  tm = [tm; tempHndl_sa]; 
%                  %check box fo rphases
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Show peaks and troughs of the variables', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[60/100 2.5/100 35/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  tm = [tm; tempHndl_sa];
%                   %text box for threshold
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[47.5/100 35/100 25/100 20/100],'string','highlighting where','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','1', 'position',[92.5/100 35/100 5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 4, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 4 );']);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','absolute value >|within this fraction of global max', 'position',[67.5/100 35/100 25/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 3, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 3 );']);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %timespan and derivative
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[0/100 35/100 5/100 20/100],'string','Plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','the function|the derivative', 'position',[6/100 35/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);                 
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[22.5/100 35/100 7/100 20/100],'string','over time','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','0', 'position',[30/100 35/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'time');
%                  set(tempHndl_sa, 'UserData', 5, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 5 );']);
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[37.5/100 35/100 5/100 20/100],'string','to','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','0', 'position',[42.5/100 35/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'time');
%                  set(tempHndl_sa, 'UserData', 6, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 6 );']);
%                  tm = [tm; tempHndl_sa];
%                  %multiply by W
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','HorizontalAlignment', 'left', 'Units','normalized','position',[0/100 70/100 5/100 20/100],'string','Select','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','sig_i*U_i,m|f_i,m', 'position',[21/100 70/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 12, 'callback', ['SensitivityAnalysisGUI5(''synch'',', num2str(i) ', 12 );']);
%                  tm = [tm; tempHndl_sa];
%                   %sort 
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Sort by size', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[35/100 2.5/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  tm = [tm; tempHndl_sa];
%                  %colour scaling type
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[0/100 2.5/100 10/100 20/100],'string','Scale colour','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','by maxima|by amplitude|all equally|to fill', 'position',[12.5/100 2.5/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa]; 
%                  %select which pc
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','pc', 'tag', 'pc-1', 'position',[57.5/100 70/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[37.5/100 70/100 5/100 20/100],'string','from','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  btngrp = uibuttongroup('Position', [42.5/100 70/100 40/100 20/100], 'Parent',PlotTypePanels_sa(i), 'Backgroundcolor',get(mainFig_sa, 'Color'), 'bordertype', 'none' );
%                  tempHndl_sa = uicontrol('Parent',btngrp,'string', 'all pcs' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 20/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Backgroundcolor',get(mainFig_sa, 'Color'));
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',btngrp,'string', 'only' ,'Units','normalized','Style','radiobutton', 'position',[20/100 0/100 17/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Backgroundcolor',get(mainFig_sa, 'Color'));
%                  tm = [tm; tempHndl_sa];
% 
%                  
%              case 'Time Series with PCs'
%                  %text box for tolerance
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[52/100 70/100 25/100 20/100],'string','for the variable is greater than','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','0.05', 'position',[77/100 70/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 2, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 2 );']);
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[85/100 70/100 15/100 20/100],'string','of the global max','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  %scaling
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[30/100 70/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 1 );']);
%                  tm = [tm; tempHndl_sa]; 
%                   %text box for threshold
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[35/100 35/100 25/100 20/100],'string','overlaying the above where ','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','1', 'position',[85/100 35/100 5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 4, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 4 );']);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','absolute value >|within this fraction of global max', 'position',[60/100 35/100 25/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 3, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 3 );']);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %timespan
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[1/100 35/100 11.5/100 20/100],'string','Plot over time','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','0', 'position',[12.5/100 35/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'time');
%                  set(tempHndl_sa, 'UserData', 5, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 5 );']);
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[20/100 35/100 5/100 20/100],'string','to','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','0', 'position',[25/100 35/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'time');
%                  set(tempHndl_sa, 'UserData', 6, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 6 );']);
%                  tm = [tm; tempHndl_sa];
%                   %multiply by W
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[0 70/100 30/100 20/100],'string','Plot any variable time series where','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','sig_i*U_i,m|f_i,m', 'position',[40/100 70/100 12/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 12, 'callback', ['SensitivityAnalysisGUI5(''synch'',', num2str(i) ', 12 );']);
%                  tm = [tm; tempHndl_sa];
%                   % normalise?
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Normalise the data', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[2/100 2.5/100 30/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  set(tempHndl_sa, 'UserData', 13, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',13);']);
%                  tm = [tm; tempHndl_sa];
%                 
%             case 'Heat Map'
%                 %popup of different data items
%                 labelHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[5/100 60/100 20/100 20/100],'string','Select variable to plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                 tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String',HeatMapVars, 'position',[40/100 60/100 25/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                 set(tempHndl_sa, 'Value',6);
%                 tm = [tm; tempHndl_sa]; 
%                 %popup of different data items
%                 labelHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[5/100 25/100 20/100 20/100],'string','Plot type','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                 tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','raw data|absolute values|log absolute values', 'position',[40/100 25/100 25/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                 set(tempHndl_sa, 'Value',1);
%                 tm = [tm; tempHndl_sa];     
%             case 'Singular Spectrum Plot'  
%                  %axis limits
% %                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[5/100 60/100 30/100 20/100],'string','D plot x axis limit 10^-X','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% %                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','10', 'position',[40/100 60/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
% %                  set(tempHndl_sa, 'Value',5);
% %                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[5/100 60/100 30/100 20/100],'string','Number of singular values','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'HorizontalAlignment', 'right', 'Units','normalized','Style','popup','String','1|2|3|4|5', 'position',[40/100 60/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'tag', 'numpc');
%                  set(tempHndl_sa, 'Value',5);
%                  tm = [tm; tempHndl_sa];  
%                  %scaling
%                  labelHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[55/100 60/100 20/100 20/100],'string','Scaling','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[75/100 60/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 1 );']);
%                  tm = [tm; tempHndl_sa];  
%                  %normalise data?
%                  labelHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[55/100 20/100 20/100 20/100],'string','Normalise data','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','checkbox', 'position',[75/100 23/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  tm = [tm; tempHndl_sa];
%             case 'Strength Surface Plot'
%                  %scaling
%                  labelHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[5/100 58/100 20/100 20/100],'string','Scaling','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[20/100 60/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 1 );']);
%                  tm = [tm; tempHndl_sa];
%                  %normalise
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Normalise S', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[50/100 63/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'UserData', 7, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 7 );']);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %log S
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'log10 S', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[65/100 63/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 10, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',10);']);
%                  tm = [tm; tempHndl_sa];
%                  %add sea level
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Add sea level of', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[5/100 23/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  set(tempHndl_sa, 'UserData', 8, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 8 );']);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i),'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','-2.0', 'position',[30/100 20/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 9, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 9 );']);
%                  tm = [tm; tempHndl_sa]; 
%             case 'Strength 3D Bar Chart'
%                  %scaling
%                  labelHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[5/100 58/100 20/100 20/100],'string','Scaling','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[20/100 60/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 1 );']);
%                  tm = [tm; tempHndl_sa];
%                  %normalise
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Normalise S', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[50/100 63/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'UserData', 7, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 7 );']);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %log S
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'log10 S', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[65/100 63/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 10, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',10);']);
%                  tm = [tm; tempHndl_sa];
%                  %add sea level
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Add sea level of', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[5/100 23/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  set(tempHndl_sa, 'UserData', 8, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 8 );']);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i),'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','-2.0', 'position',[30/100 20/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 9, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 9 );']);
%                  tm = [tm; tempHndl_sa];
%             case 'Strength 2D Bar Chart'
%                  %scaling
%                  labelHndl_sa = uicontrol('HorizontalAlignment', 'left','Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[2.5/100 58/100 7.5/100 20/100],'string','Scaling','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[10/100 60/100 12.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 1 );']);
%                  tm = [tm; tempHndl_sa];
%                  %normalise
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Normalise S', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[35/100 63/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'UserData', 7, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 7 );']);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %log S
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'log10 S', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[52.5/100 63/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 10, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',10);']);
%                  tm = [tm; tempHndl_sa];
%                  %add sea level
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Add sea level of', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[70/100 63/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',0);
%                  set(tempHndl_sa, 'UserData', 8, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 8 );']);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i),'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','-2.0', 'position',[87.5/100 60/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 9, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 9 );']);
%                  tm = [tm; tempHndl_sa];
%                  %sort by value
%                  labelHndl_sa = uicontrol( 'Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[72.5/100 23/100 12.5/100 20/100],'string','Sort params by','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'none|1st pc|max pc', 'HorizontalAlignment', 'right', 'Units','normalized','Style','popup', 'position',[87.5/100 23/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);       
%                  %set(tempHndl_sa, 'UserData', 11, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 11 );']);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %group
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'Group pcs', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[35/100 23/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %num pcs
%                  labelHndl_sa = uicontrol('Horizontalalignment', 'left', 'Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[2.5/100 23/100 15/100 20/100],'string','Num pcs to plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','string', '-', 'position',[15/100 23/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'numpc');
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %num params to plot
%                  labelHndl_sa = uicontrol('Horizontalalignment', 'left', 'Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[52.5/100 23/100 10/100 20/100],'string','Num params','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','string', '-', 'position',[62.5/100 23/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'params');
%                  tm = [tm; tempHndl_sa];
%             
%             case 'Composite Plot'
%                 %select pc required
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[0 70/100 5/100 20/100],'string','Plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','pc', 'position',[37.5/100 70/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'pc');
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %variable
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[47.5/100 70/100 12.5/100 20/100],'string','of variable','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','var', 'position',[60/100 70/100 10/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'var');
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %scaling
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[5/100 70/100 12.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 1 );']);
%                  tm = [tm; tempHndl_sa]; 
%                  %text box for threshold
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[35/100 35/100 25/100 20/100],'string','highlighting regions where is','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','1', 'position',[85/100 35/100 5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 4, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 4 );']);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','absolute value >|within this fraction of global max', 'position',[60/100 35/100 25/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 3, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 3 );']);
%                  set(tempHndl_sa, 'Value',1);
%                  tm = [tm; tempHndl_sa];
%                  %timespan
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','HorizontalAlignment', 'left', 'Units','normalized','position',[1/100 35/100 11.5/100 20/100],'string','Plot over time','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','0', 'position',[12.5/100 35/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'time');
%                  set(tempHndl_sa, 'UserData', 5, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 5 );']);
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[20/100 35/100 5/100 20/100],'string','to','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','0', 'position',[25/100 35/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Tag', 'time');
%                  set(tempHndl_sa, 'UserData', 6, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 6 );']);
%                  tm = [tm; tempHndl_sa]; 
%                   %normalise S
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'normalise', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[12.5/100 2.5/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 7, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 7 );']);                
%                  tm = [tm; tempHndl_sa];
%                   %log S
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'take log10', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[32.5/100 2.5/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 10, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',10);']);
%                  tm = [tm; tempHndl_sa];
%                  %add sea level
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'add sea level of', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[52.5/100 2.5/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 8, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 8 );']);
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i),'HorizontalAlignment', 'right', 'Units','normalized','Style','edit','String','-2.0', 'position',[72.5/100 2.5/100 7.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'UserData', 9, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 9 );']);
%                  tm = [tm; tempHndl_sa]; 
%                  %sort parameters
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'String', 'sort by parameter', 'HorizontalAlignment', 'right', 'Units','normalized','Style','checkbox', 'position',[82.5/100 2.5/100 20/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6,'BackgroundColor', get(mainFig_sa, 'Color'));
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 11, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ', 11 );']);                
%                  tm = [tm; tempHndl_sa];
%                  
%                  
%                  %*W?
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[32.5/100 70/100 5/100 20/100],'string','for','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','sig_i*U_i,m|f_i,m', 'position',[17.5/100 70/100 15/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 12, 'callback', ['SensitivityAnalysisGUI5(''synch'',', num2str(i) ', 12 );']);
%                  tm = [tm; tempHndl_sa];
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[0/100 2.5/100 12.5/100 20/100],'string','For strengths','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6); 
%             case 'Amp Period Scatter Plot'
%                 %option of pcs or dgs
%                  btngrp3 = uibuttongroup('Position', [0 0/100 30/100 1], 'Parent',PlotTypePanels_sa(i), 'Backgroundcolor',get(mainFig_sa, 'Color'), 'bordertype', 'none' );
%                  tempHndl_sa = uicontrol('Parent',btngrp3,'string', 'Principle Components to plot' ,'Units','normalized','Style','radiobutton', 'position',[1/100 60/100 99/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Backgroundcolor',get(mainFig_sa, 'Color'));
%                  tm = [tm; tempHndl_sa];
%                  tempHndl_sa = uicontrol('Parent',btngrp3,'string', 'Parameters from dgs to plot' ,'Units','normalized','Style','radiobutton', 'position',[1/100 30/100 99/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6, 'Backgroundcolor',get(mainFig_sa, 'Color'));
%                  tm = [tm; tempHndl_sa];
%                 %list box for number of components/params
%                 % labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[0 60/100 25/100 20/100],'string','Principle components to plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','listbox','Max', 10, 'Min', 0, 'String','1|2|3|4|5|6|7|8|9|10', 'position',[30/100 10/100 10/100 70/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.15, 'Tag', 'params');
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 14, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',14);']);
%                  tm = [tm; tempHndl_sa];
%                  %and number of variables
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[40/100 60/100 20/100 20/100],'string','Variables to plot','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','listbox','Max', 10, 'Min', 0, 'String','1|2|3|4|5|6|7|8|9|10', 'position',[60/100 10/100 10/100 70/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.15, 'Tag', 'var');
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 15, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',15);']);
%                  tm = [tm; tempHndl_sa];
%                  %scaling
%                  labelHndl_sa=uicontrol('Parent',PlotTypePanels_sa(i) ,'Style', 'text','Units','normalized','position',[75/100 60/100 10/100 20/100],'string','Scaling','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%                  tempHndl_sa = uicontrol('Parent',PlotTypePanels_sa(i), 'Units','normalized','Style','popup','String','unscaled|p scaled|zp scaled', 'position',[85/100 60/100 12.5/100 20/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'normalized', 'FontSize', 0.6);
%                  set(tempHndl_sa, 'Value',1);
%                  set(tempHndl_sa, 'UserData', 1, 'callback', ['SensitivityAnalysisGUI5(''synch'',' num2str(i) ',1);']);
%                  tm = [tm; tempHndl_sa];

   
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
   
    
%     %model info
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 62.5/100 25/100 3/100],'string','Name','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     name_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'left','Style', 'text','Units','normalized','position',[30/100 62.5/100 62.5/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 59/100 25/100 3/100],'string','Date','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     date_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'left','Style', 'text','Units','normalized','position',[30/100 59/100 62.5/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 55.5/100 57.5/100 3/100],'string','Forced','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     forced_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 55.5/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 52/100 57.5/100 3/100],'string','Variables','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     var_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 52/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 48.5/100 57.5/100 3/100],'string','Parameters','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     par_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 48.5/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 45/100 57.5/100 3/100],'string','Slope Spec','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     slope_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 45/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 41.5/100 57.5/100 3/100],'string','Slope Spec p','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     slope_pscaled_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 41.5/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 38/100 57.5/100 3/100],'string','Slope Spec zp','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     slope_zp_scaled_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 38/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 34.5/100 57.5/100 3/100],'string','Max sig*U','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     umax_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 34.5/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 31/100 57.5/100 3/100],'string','Max sig*U p','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     p_umax_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 31/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
% 
%     labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'Style', 'text','Units','normalized','HorizontalAlignment', 'left','position',[7.5/100 27.5/100 57.5/100 3/100],'string','Max sig*U zp','BackgroundColor', get(mainFig_sa, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
%     zp_umax_labelHndl_sa=uicontrol('FontUnits', 'normalized', 'Parent',leftPanel_sa ,'HorizontalAlignment', 'right','Style', 'text','Units','normalized','position',[62.5/100 27.5/100 30/100 3/100],'BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);


