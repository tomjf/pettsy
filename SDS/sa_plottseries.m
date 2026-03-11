function r = sa_plottseries(action, varargin)

global maincol btncol 
persistent varList; %which variables listbox
persistent normChk; %normalise? checkbox
persistent panel clearHndl selAllHndl;

global plot_font_size

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
    %which variables listbox
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth/2-1 0.5],'string','Select the Variables to Plot','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    varList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 1 pwidth/2-0.5 pheight-2],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
    set(varList, 'UserData', 15, 'callback', ['sagui(''synch'',15);']);
    %normalise? checkbox
    normChk = uicontrol('Parent',panel, 'String', 'Normalise the data', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','checkbox', 'position',[0.5 0.5 pwidth/2-1 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10,'BackgroundColor', maincol, 'Value', 0);
    set(normChk, 'UserData', 13, 'callback', ['sagui(''synch'',13);']);
    
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
        'Callback','sa_plottseries(''selAllVars'');');
    
    clearHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-3.1 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Clear', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plottseries(''clearAllVars'');');
    
    r = panel;
elseif strcmp(action, 'name')
    r = 'Time Series';
elseif strcmp(action, 'description')
    r = 'Plots the time series of the model variables and the external force that is used to create the SDS data. Option to normalise the data so that each variable has a mean of one.';
elseif strcmp(action, 'fillSDS')
    %called when sds changes.
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
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set(varList, 'String', []);   
elseif strcmp(action, 'plot')
    sds = varargin{1};
    all_y = get(varList, 'Value');
    ycols = get(varList, 'Userdata');
    ysel = zeros(size(ycols,1), 1);
    ysel(all_y) = 1;
    
    if isempty(all_y)
        ShowError('Please select one or more variables to plot.');
    else
        ytoplot = cell(length(sds.lc),1);
        numplots = 0;
        for p = 1:length(sds.lc) 
            %cut selection down to this dgs
            ytoplot{p} = ycols(ysel & (ycols(:,1) == p), 2);
            if ~isempty(ytoplot{p}) 
                numplots = numplots + 1;
            end
        end
        
        nm = get(normChk, 'Value');  
        pnum=0;
        for p = 1:length(sds.lc)
            if ~isempty(ytoplot{p})
                pnum = pnum + 1;             
                if numplots == 1
                    pos = get_size_of_figure();
                else
                    pos = [(pnum-1)/numplots 0 1/numplots 1];
                end
                newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Time Series'],  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]);%MD background
                x = sds.t{p};
                
                y = sds.lc{p}(:,ytoplot{p});
                if nm
                    for c = 1:size(y,2) %scale each time series so they have a mean of 1
                        y(:,c) = y(:,c) / mean(y(:,c));
                    end
                end

                if nm
                    tstr = [sds.mymodel ' Normalised Time Series from ' sds.exptnames{p}];
                else
                    tstr = [sds.mymodel ' Time Series from ' sds.exptnames{p}];
                end
                ha = axes('Parent', newfig);
               % plot(ha, x, [y (sds.force{p} * max(max(y))*0.9)]);
               for c = 1:size(y,2)
                  plot(ha, x, y(:,c), get_plot_style(c), 'LineWidth', 2); 
                  hold on;
               end
               plot(ha, x,sds.force{p});
                
                
                set(ha, 'xlim', [x(1) x(end)], 'FontSize', plot_font_size); %MD fontsize
                title(tstr, 'FontSize', plot_font_size);
                xlabel('Time', 'FontSize', plot_font_size);ylabel('Model Variable', 'FontSize', plot_font_size);
                leg = sds.vnames{p};
                legend([leg(ytoplot{p}), sds.forcename{p}], 'location', 'best', 'FontSize', 12);
            end
        end
    end
    
elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    idx = varargin{1};
    vals = varargin{2};
    vars = vals{idx};
    idx = idx + 1;
    nm = vals{idx};
    idx = idx + 1;
    %The order they are set in must match the order they are written to file
    %in
    numvar = length(get(varList, 'String'));
    vars = sscanf(vars, '%f')';
    m = find( vars > numvar);
    vars(m) = [];
    set(varList, 'Value', vars);
    set(normChk, 'Value', str2double(nm));
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
    v = get(normChk, 'Value');
    fprintf(fp, '\n%d\n', v);
%========================================================================
elseif strcmp(action, 'selAllVars')
    str = get(varList, 'String');
    set(varList, 'Value', 1:length(str));
elseif strcmp(action, 'clearAllVars')
    set(varList, 'Value', []);
end



    
    