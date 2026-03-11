function r = th_plottseries(action, varargin)


persistent normChk; %normalise? checkbox
persistent panel typeList xHndl y2DHndl y3DHndl zHndl zlblHndl
global plot_font_size

r = [];


if strcmp(action, 'init')
    
    maincol = get(varargin{1}, 'backgroundcolor');
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
    typeList = uibuttongroup('Units','centimeters','SelectionChangeFcn','th_plottseries(''changetype'');', 'Position', [0.5 pheight-1.5 (pwidth-1)/2 0.5], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    t1=uicontrol('HorizontalAlignment', 'right', 'Parent',typeList,'string', '2D plot' ,'Units','normalized','Style','radiobutton', 'position',[0 0 0.5 1],'Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    t2=uicontrol('HorizontalAlignment', 'right', 'Parent',typeList,'string', '3D plot' ,'Units','normalized','Style','radiobutton', 'position',[0.5 0 0.5 1], 'Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(typeList, 'UserData', [t1 t2]);
    
    %x axis 
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3 pwidth/2-1 0.5],'string','X axis','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    xHndl = uicontrol('Parent',panel ,'Style', 'popup','Units','centimeters','position',[(pwidth+0.5)/2 pheight-3 pwidth/2-1 0.5],'string','time', 'FontUnits', 'points', 'FontSize', 10, 'tooltipstring', 'Select a variable to plot along the X axis');

    %y axis is a list box for 2d plots and a popup for 3D, so set both initially
    %invisible
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-4.5 pwidth/2-1 0.5],'string','Y axis','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    y3DHndl = uicontrol('visible', 'off', 'Parent',panel, 'Style', 'popup','Units','centimeters','position',[(pwidth+0.5)/2 pheight-4.5 pwidth/2-1 0.5],'string','y', 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10, 'tooltipstring', 'Select a variable to plot along the Y axis');
    y2DHndl = uicontrol('visible', 'off', 'Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[(pwidth+0.5)/2 2 pwidth/2-1 pheight-6],'Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'tooltipstring', 'Select one or more variables to plot along the Y axis');

    %z axis for 3 d plot option
    zlblHndl = uicontrol('Parent', panel, 'Style', 'text', 'Units','centimeters','position',[0.5 pheight-6 pwidth/2-1 0.5],'string','Z axis','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    zHndl = uicontrol('visible', 'off', 'Parent', panel ,'Style', 'popup','Units','centimeters','position',[(pwidth+0.5)/2 pheight-6 pwidth/2-1 0.5],'string','z', 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10, 'tooltipstring', 'Select a variable to plot along the Z axis');

    %normalise? checkbox
    normChk = uicontrol('Parent',panel, 'String', 'Normalise the data', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','checkbox', 'position',[0.5 0.5 pwidth/2-1 0.5],'FontUnits', 'points', 'FontSize', 10,'BackgroundColor', maincol, 'Value', 0, 'tooltipstring', 'Check to scale each variable, excluding time, so each has a mean of one');

    th_plottseries('changetype', false);
    
    r = panel;
    
elseif strcmp(action, 'name')
    
    r = 'Time Series';
    
elseif strcmp(action, 'show')
    
    set(panel, 'visible', 'on');
    
elseif strcmp(action, 'hide')
    
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'description')
    
    r = 'Plots the model variables either as a time series, or against each other. In the case of oscillator models, this would be a limit cycle. Option to normalise the data so that each variable has a mean of one.';
    
elseif strcmp(action, 'changefile')
    %called when ts file changes.
    model = varargin{1};
    data = varargin{2};
    %fill in variable names
    set([xHndl y2DHndl y3DHndl zHndl], 'string', ['...'], 'value', 1);
  
    if IsValid(model, data)
        forcenames = cell(0);
        for f = 1:length(model.force_type)
            forcenames{f} = data.forceparams(f).force;
        end
        set([xHndl y3DHndl zHndl], 'string',  ['time'; data.vnames; forcenames'], 'value', 1);
        set(y2DHndl, 'string',  [data.vnames; forcenames'], 'value', 1);
    else
        set(xHndl, 'string',  'x axis', 'value', 1);
        set(zHndl, 'string',  'z axis', 'value', 1);
        set([y2DHndl y3DHndl], 'string',  'y axis', 'value', 1);
    end

elseif strcmp(action, 'newtheory')
    
    %no theory here
    
elseif strcmp(action, 'changetype')
    
    opts = get(typeList, 'userdata');
    
    if get(opts(1), 'value')
        %2 D
        set(y2DHndl, 'visible', 'on');
        set([zlblHndl y3DHndl zHndl], 'visible', 'off');
        msg = 'To plot in 2D, select an X variable, and one or more Y variables';
    else
        %3 D
        set(y2DHndl, 'visible', 'off');
        set([zlblHndl y3DHndl zHndl], 'visible', 'on');
        msg = 'To plot in 3D, select a variable for the X,Y and Z axes';
    end
    if nargin == 1
        %called in response to user action
        th_tippanel('clear_highlight');
        th_tippanel('write', msg, 3);
    end
     
elseif strcmp(action, 'plot')
    
    model = varargin{1};
    data = varargin{2};
    forcenames = cell(0);
    for f = 1:length(model.force_type)
        forcenames{f} = data.forceparams(f).force;
    end
    
    pt = get(typeList, 'userdata');
    
    xsel = get(xHndl, 'value');
    if get(pt(1), 'value')
        %2d
        plottype = 2;
        ysel = get(y2DHndl, 'value');
    else
        plottype = 3;
        ysel = get(y3DHndl, 'value');
        zsel = get(zHndl, 'value');
    end
   
    if isempty(xsel) || isempty(ysel) || (plottype == 3 && isempty(zsel))
        ShowError('Please select one or more variables to plot on each axis.');
    else
        nm = get(normChk, 'Value');
        [p fname] = fileparts(data.myfile);
        
        %size it in cm and centre it on screen
        pos = get_size_of_figure();
        newfig = figure('NumberTitle', 'off',  'units', 'normalized', 'Position', pos, 'Color', [1 1 1]); %MD changed background to white

        ha = axes('Parent', newfig, 'Fontsize', plot_font_size); %MD changed the font size of the axes
        
        if plottype == 2
            %2d plot
          
            if xsel == 1
                xlbl = 'Time';
                xvals = data.sol.x; 
            elseif (xsel-1) <= length(data.vnames)
                xlbl = data.vnames{xsel-1};
                xvals = data.sol.y(:, xsel-1);
            else
               xlbl = forcenames{xsel-1-length(data.vnames)};
               xvals = data.force(:,xsel-1-length(data.vnames));
            end
            if length(ysel) == 1
                %one series
                if ysel <= length(data.vnames)
                    ylbl = data.vnames{ysel};
                    ylb2='Level';
                    yvals = data.sol.y(:, ysel);
                else
                    ylbl = forcenames{ysel-length(data.vnames)};
                    ylb2='Level';
                    yvals = data.force(:,ysel-length(data.vnames));
                end
            else
                %more than one
                ylbl = 'Variable'; %MD changed from 'Variable'
                ylb2='Levels';
                fsel = ysel(ysel>length(data.vnames))-length(data.vnames);
                vsel = ysel(ysel<=length(data.vnames));
                yvals = [data.sol.y(:, vsel) data.force(:,fsel)];
            end
            
            %normalise if required
            if nm
                if xsel > 1
                    xvals = xvals/mean(xvals);
                end
                for c = 1:size(yvals,2) %scale each time series so they have a mean of 1
                    yvals(:,c) = yvals(:,c) / mean(yvals(:,c));
                end
            end
            
           %plot
           for i = 1:size(yvals, 2)
                plot(ha, xvals, yvals(:,i), get_plot_style(i), 'LineWidth', 2); 
                hold on;
           end
           
           xlabel(xlbl, 'FontUnits', 'points', 'FontSize', plot_font_size);ylabel(ylb2,  'FontUnits', 'points', 'FontSize', plot_font_size);
           
           %title and legend
           
           if xsel == 1
               %time on x axis
               set(ha, 'xlim', [xvals(1) xvals(end)]);
               tstr = [ylbl ' time series'];
           else
               %plotting a limit cycle
               tstr = [ylbl ' v ' xlbl];
           end
           if size(yvals, 2) > 1
               %many series so need legend
               leg = [data.vnames(vsel); forcenames(fsel)'];
               legend(leg,  'FontUnits', 'points', 'FontSize', 12);
           end
           tstr = [tstr ' from ' model.name ', ' fname];
           title(tstr, 'FontUnits', 'points', 'FontSize', plot_font_size);
           if nm
               set(newfig, 'name', [tstr ' (normalised)']);
           else
                set(newfig, 'name', tstr);
           end
        else
            %3d plot
            if xsel == 1
                xlbl = 'Time';
                xvals = data.sol.x; 
            elseif (xsel-1) <= length(data.vnames)
                xlbl = data.vnames{xsel-1};
                xvals = data.sol.y(:, xsel-1);
            else
               xlbl = forcenames{xsel-1-length(data.vnames)};
               xvals = data.force(:,xsel-1-length(data.vnames));
            end
            if ysel == 1
                ylbl = 'Time';
                yvals = data.sol.x; 
            elseif (ysel-1) <= length(data.vnames)
                ylbl = data.vnames{ysel-1};
                yvals = data.sol.y(:, ysel-1);
            else
               ylbl = forcenames{ysel-1-length(data.vnames)};
               yvals = data.force(:,ysel-1-length(data.vnames));
            end
            if zsel == 1
                zlbl = 'Time';
                zvals = data.sol.x; 
            elseif (zsel-1) <= length(data.vnames)
                zlbl = data.vnames{zsel-1};
                zvals = data.sol.y(:, zsel-1);
            else
               zlbl = forcenames{zsel-1-length(data.vnames)};
               zvals = data.force(:,zsel-1-length(data.vnames));
            end
      
            %normalise if required (not if time)
            if nm
                if xsel > 1
                    xvals = xvals/mean(xvals);
                end
                if ysel > 1
                    yvals = yvals/mean(yvals);
                end
                if zsel > 1
                    zvals = zvals/mean(zvals);
                end
            end
            
           %plot
           plot3(ha, xvals, yvals, zvals, 'LineWidth', 2);
           grid on;
           
           xlabel(xlbl, 'FontUnits', 'points', 'FontSize', plot_font_size);ylabel(ylbl, 'FontUnits', 'points', 'FontSize', plot_font_size);zlabel(zlbl, 'FontUnits', 'points', 'FontSize', plot_font_size);
           
           %title and legend
           
           if xsel == 1
               %time on x axis
               set(ha, 'xlim', [xvals(1) xvals(end)]);
               tstr = [zlbl ' v ' ylbl ' time series'];
           elseif ysel == 1
               set(ha, 'ylim', [yvals(1) yvals(end)]);
               tstr = [zlbl ' v ' xlbl ' time series'];
           elseif zsel == 1
               set(ha, 'zlim', [zvals(1) zvals(end)]);
               tstr = [ylbl ' v ' xlbl ' time series'];
           else
               %time not plotted
               tstr = [zlbl ' v ' ylbl ' v ' xlbl];
           end
           tstr = [tstr ' from ' model.name ', ' fname];
           title(tstr, 'FontUnits', 'points', 'FontSize', plot_font_size);
           if nm
               set(newfig, 'name', [tstr ' (normalised)']);
           else
                set(newfig, 'name', tstr);
           end
            
        end
    end
    
elseif strcmp(action, 'set')
    return;
    %set control values from settings file read at startup
    idx = varargin{1};
    vals = varargin{2};
    plottype = vals{idx};
    idx = idx + 1;
    xsel = str2double(vals{idx});
    idx = idx + 1;
    ysel = str2double(vals{idx});
    idx = idx + 1;
    zsel = str2double(vals{idx});
    idx = idx + 1;
    nm = str2double(vals{idx});
    idx = idx + 1;
    %The order they are set in must match the order they are written to file
    %in
    v = get(typpeList, 'userdata');
    set(v(plottype), 'value', 1);
    th_plottseries('changetype');
    set(xHndl, 'value', xsel);
    
    if plotype == 1
        set(y2DHndl, 'Value', ysel);
    else
        set(y3DHndl, 'Value', ysel(1));
        set(zHndl, 'value', zsel);
    end
    set(normChk, 'Value', nm);
    %return index value for next panel
    r = idx; 
elseif strcmp(action, 'save')
    return;
    %save control values to file
    %the order here must match the order they are loaded in, as above
    fp = varargin{1};
    v = get(typpeList, 'userdata');
    if get(v(1), 'value')
        fprintf(fp, '1\n');
    else
        fprintf(fp, '2\n');
    end
    fprintf(fp, '%d\n', get(xHndl, 'value'));
    if get(v(1), 'value')
        ysel = get(y2DHndl, 'value');
        for i = 1:length(ysel)
           fprintf(fp, '%d ', ysel(i)); 
        end
        fprintf(fp, '\n');
    else
        fprintf(fp, '%d\n', get(y3DHndl, 'value'));
        fprintf(fp, '%d\n', get(zHndl, 'value'));
    end
    
    v = get(normChk, 'Value');
    fprintf(fp, '%d\n', v);
    
elseif  strcmp(action,'isvalid')
    %called from other files to determine whether or not to activate the
    %plot button.
    
    %called when selecting this plot type, when creating a new ts file, or when running
    %theoretical analysis on the currenrt file
    %Only called however, if this plot type is the current one.
    
    model = varargin{1};
    data = varargin{2};
    if nargin > 3
        %can be set to false to suppress message at startup
        showMsg = varargin{3};
    else
        showMsg = true;
    end
    
    r = IsValid(model, data);
    
    if r %valid file
        if  showMsg  
            %user has selected this plot
            th_tippanel('write', 'You have selected to plot the time series data from the selected file', 0);
            th_plottseries('changetype');
        end
    else
        %invalid, always show warning
       th_tippanel('write', 'Time series plotting is not available as the data cannot be found', 2);
    end

end
%=========================================================================
 
function v = IsValid(mdl, ts)

 %to be a valid plot type just needs the time series data 
 
 v =  ~isempty(ts);
 
%%%Could plot force on secondary axis