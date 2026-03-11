function r = th_plotperiod(action, varargin)

%plots the derivative of the period with respect to parameter for unforced
%oscillators

persistent panel logHndl dataTypeHndl perioddata dataTbl table_is_formatted selAllHndl clearAllHndl
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
    
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 3.5 0.5],'string','Derivative of','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    dataTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3 pheight-1.45 7.75 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotperiod(''dataTypeChange'');', ... 
        'String', {'period with respect to parameter', 'period with respect to log parameter', 'log period with respect to log parameter'});
    
    logHndl=uicontrol('Style','checkbox', 'Units','centimeters', 'position',[0.5 pheight-2.5 3 0.6],'min', 0, 'max', 1, ...
        'callback', 'th_plotperiod(''dataTypeChange'');', ...
        'string', 'Take log10' , 'Parent',panel,'FontUnits', 'points', 'FontSize', 10, 'BackgroundColor', maincol, 'tooltipstring', 'Check to take log to the base 10 of the absolute value of the derivative');

    
     dataTbl = uitable('units', 'centimeters','position', [4.5 0.5 pwidth-5 pheight-3.75], ...
        'columneditable', [true false false], ...
        'columnname', {'', 'k', ''}, ...
        'rowname', {}, 'rowstriping', 'off', 'backgroundcolor', [1 1 1], ...
        'fontunits', 'points', 'fontsize', 10, ...
        'parent', panel);
    
    set(dataTbl, 'units', 'pixels')
    tblwidth = get(dataTbl, 'position');
    colwidth = (tblwidth(3)-45)/3;
    set(dataTbl, 'columnwidth', {25 colwidth 2*colwidth});
    
    selAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-3.85 3.5 0.6], ...
        'Parent',panel, ...
        'string', 'Select all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Select all table entries', ...
        'Callback','th_plotperiod(''selall'');');
    clearAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-4.65 3.5 0.6], ...
        'Parent',panel, ...
        'string', 'Clear all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Clear table selections', ...
        'Callback','th_plotperiod(''clearall'');');

    
    table_is_formatted = false;
    perioddata = [];

    r = panel;
    
elseif strcmp(action, 'name')
    
    r  = 'Period Derivatives';
    
elseif strcmp(action, 'show')
    
    set(panel, 'visible', 'on');
    drawnow;
 
    %Customise table. Have to wait until table is visible to get java
    %object
   
    if ~table_is_formatted
        %just do this once f
        colwidths = [1/3 2/3];
        selectable = true;
        table_is_formatted = create_sortable_table(dataTbl, colwidths, selectable);
       
    end
    
elseif strcmp(action, 'hide')
    
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'description')
     
    r = 'Plots the derivative of the period of the unforced limit cycle with respect to the model parameters.';

elseif strcmp(action, 'changefile')
    %called when ts file changes.
    model = varargin{1};
    perioddata = varargin{2};

   th_plotperiod('newtheory', model);
   
elseif strcmp(action, 'newtheory')
    
    %theory run on a ts file
    
    model = varargin{1};

    if nargin > 2
        %running theory on current file, not selecting a ne wfile
        perioddata = varargin{2};
    end
    
    if ~IsValid(model, perioddata)
        perioddata = [];
    end
    %fill in var/param list and fill derivatives table
    fillPeriodTable(dataTbl,  dataTypeHndl, logHndl, perioddata);
    
    
elseif strcmp(action, 'dataTypeChange')
    
    fillPeriodTable(dataTbl,  dataTypeHndl, logHndl, perioddata);
    
elseif strcmp(action, 'selall')
    
    tblData = get(dataTbl, 'Data');
    tblData(:,1) = {true};
    set(dataTbl, 'Data', tblData);

elseif strcmp(action, 'clearall')

    tblData = get(dataTbl, 'Data');
    tblData(:,1) = {false};
    set(dataTbl, 'Data', tblData);
    
elseif strcmp(action, 'plot')
    
    model = varargin{1};
    data = varargin{2};
    [p fname] = fileparts(data.myfile);
 
    %find order in which rows of table are displayed
    tblData = get(dataTbl, 'Data');
    sorted_idx = (1:size(tblData,1))';
    tabledata = get(dataTbl, 'data');
    parameters = [];
    for p = 1:size(tabledata,1)
        if tabledata{p, 1}
            parameters = [parameters p];
        end
    end
    if isempty(parameters)
        ShowError('You must select one or more parameters to plot');
        return;
    end
    

    datatype = get(dataTypeHndl, 'value');
    dolog = get(logHndl, 'value') == get(logHndl, 'max');
    
    parnames = data.parn(parameters);
    parvalues = data.par(parameters);
    dper_values = data.theory.dperdpar(parameters);

    
    if datatype == 1
        %want dper/dpar, so need to divide by par
        for i=1:length(parvalues)
            if parvalues(i) > 0
                dper_values(i)=dper_values(i)/parvalues(i);
            end
            % if par <=0, derivative already dper/dpar as wasn't scaled
            % in parscale.
        end
        y_label = '\partial\tau / \partialk_j';
    elseif datatype == 2
        %want dper/dlogpar
        %find values that weren't scaled. These can't be scaled
        dper_values(parvalues <=0) = NaN;
         y_label = '\partial\tau / \partiallogk_j';
    else
        %want dlogper/dpar, which is 1/per * dper/dpar
        
        for i=1:length(parvalues)
            if parvalues(i) > 0
                dper_values(i)=dper_values(i)/data.per;
            else
                dper_values(i) = NaN;
            end
            % if par <=0, derivative already dper/dpar as wasn't scaled
            % in parscale.
        end
        y_label = '\partiallog\tau / \partiallogk_j';
    end
    
    if all(isnan(dper_values))
        ShowError('You cannot take logs of the selected parameters as they all have values less than or equal to zero.');
        return;
    end
    
    if dolog
        warning off MATLAB:log:logOfZero;
        dper_values = log10(abs(dper_values));
        warning on MATLAB:log:logOfZero;
        y_label = ['log_{10}(|' y_label '|)'];
    end
    

    %create figure
    %size it in cm and centre it on screen
    pos = get_size_of_figure();
    newfig = figure('NumberTitle', 'off', 'Units', 'normalized', 'Position', pos, 'Color', [1 1 1]); %MD background
    
    %filter out bad values
    toremove = find(isnan(dper_values));
    parnames(toremove) = [];
    dper_values(toremove) = [];
    %these are selected values that can be plotted
    parameters(toremove) = [];
    
    %sort them to get the order they appear in table
    %sorted_idx(n) is the position in the sorrted table of the nth parameter of the unsorted list, ie the order in data.par
    selected_sorted_idx = [];
    for p = parameters
        %p is position in unsorted table that a selected paramerer sppears
        %at. Find its index in the current, possibly sorted table
       selected_sorted_idx = [selected_sorted_idx sorted_idx(p)];
    end
    %sort selections to thi sorder
    [~, new_idx] = sort(selected_sorted_idx);
    dper_values = dper_values(new_idx);
    parnames = parnames(new_idx);
    
    bar(dper_values, 'r');
    
    %labels
    set(gca, 'xticklabel', []);
    xlim([0 length(dper_values)+1]);
    yv = get(gca, 'YLim');
    set(gca,'xtick', [1:length(dper_values)]);
    set(gca,'YGrid', 'on');
    
    %label cols
    if length(dper_values) > 12
        %vertical text to save space
        for i = 1:length(dper_values)
            text('parent', gca, 'string', parnames(i), 'rotation', 90, 'position', [i yv(1)-diff(yv)/10], 'fontsize', plot_font_size);
        end
    else
        xticks = cell(0);
        for i = 1:length(dper_values)
            xticks = [xticks, parnames(i)];
        end
        set(gca, 'xticklabel', xticks, 'fontsize', plot_font_size);
    end
   
    ylabel(y_label, 'FontSize', plot_font_size);

    tstr = 'Derivative of period with respect to parameter value,       ';%MD need more spaces here
    title([tstr y_label], 'FontSize', plot_font_size);
    set(newfig, 'name', [tstr 'from ' data.name ', ' fname]);
    
elseif strcmp(action, 'set')
    return;
    %set control values from settings file read at startup
    idx = varargin{1};
    vals = varargin{2};
    plotopt = vals{idx};
    idx = idx + 1;
    dolog = str2double(vals{idx});
    idx = idx + 1;
    srt = str2double(vals{idx});
    idx = idx + 1;
    n = str2double(vals{idx});
    idx = idx + 1;
    %The order they are set in must match the order they are written to file
    %in
    p = get(dTauoptsgrp, 'userdata');
    set(p(plotopt), 'value', 1);
    set(logHndl, 'value', dolog);
    set(sortHndl, 'value', srt);
    set(nHndl, 'value', n);
 
    %return index value for next panel
    r = idx; 
elseif strcmp(action, 'save')
    return;
    %save control values to file
    %the order here must match the order they are loaded in, as above
    fp = varargin{1};
    v = get(dTauoptsgrp, 'userdata');
    if get(v(1), 'value')
        fprintf(fp, '1\n');
    elseif get(v(2), 'value')
        fprintf(fp, '2\n');
    else
        fprintf(fp, '3\n');
    end
    fprintf(fp, '%d\n', get(logHndl, 'value'));
    fprintf(fp, '%d\n', get(sortHndl, 'Value'));
    fprintf(fp, '%d\n', get(nHndl, 'Value'));
    
 elseif  strcmp(action,'isvalid')
    %called from other files to determine whether or not to activate the
    %plot button.
    
    %called when selecting this plot type, when creating a new ts file, or when running
    %theoretical analysis on the currenrt file
    %Only called however, if this plot type is the current one.
   
    model = varargin{1};
    data = varargin{2};
   
    r = IsValid(model, data);
    
    if nargin > 3
        %can se false to supress message at startup
        showMsg = varargin{3};
    else
        showMsg = true;
    end
    
    if showMsg
        
        if r
            message_level= 0;
            msg = 'You have selected to plot the derivative of the period of the limit cycle with respect to the model parameters';
        else
            msg = 'Period derivative plotting is not available ';
            message_level = 2;
            if ~strcmp(model.orbit_type, 'oscillator')
                msg = [msg 'as the selected model is not an oscillator.'];
            elseif isempty(data)
                msg = [msg 'as the data cannot be found.'];
            elseif data.forced
                msg = [msg 'as the period of the selected limit cycle is fixed by a periodic external force.'];
            else
                msg = [msg 'as derivatives have not been calculated for the selected file.'];
            end
        end
        th_tippanel('write', msg,  message_level);
    end
    
end


%=========================================================================
 
function  v = IsValid(mdl, ts)

 %to be a valid plot type, model must be oscillator,
 %time series must be unforced and theoretical analysis must
 %have been done.

 v = ~isempty(mdl) && strcmp(mdl.orbit_type, 'oscillator') && ~isempty(ts) &&  ~ts.forced && isfield(ts, 'theory') && isfield(ts.theory, 'dperdpar');
 
 
%=========================================================================

function fillPeriodTable(dataTbl, dataTypeHndl, logHndl, data)


if isfield(data, 'theory') && isfield(data.theory, 'dperdpar')

    user_data = get(dataTbl, 'Userdata');
    
    datatype = get(dataTypeHndl, 'value');
    dolog = get(logHndl, 'value') == get(logHndl, 'max');
    
    oldtabledata =  get(dataTbl, 'data');
    if ~isempty(oldtabledata) && strcmp(user_data.model, data.name)
        %changed file so keep selections
        %in table
        keep_selections = true;
    else
        %check that we haven't just changed the model. Ignore
        %previous selections if we have.
        keep_selections = false;
    end
    
    %table will display a list of parameters
    tabledata = cell(length(data.parn), 3);
    parn  = data.parn;
    dper_values = data.theory.dperdpar;

    if datatype == 1
        %want dper/dpar, so need to divide by par
        for i=1:length(data.par)
            if data.par(i) > 0
                dper_values(i)=dper_values(i)/data.par(i);
            end
            % if par <=0, derivative already dper/dpar as wasn't scaled
            % in parscale.
        end
        column_label = '&#8706&#964/&#8706k'; %html special chars
    elseif datatype == 2
        %want dper/dlogpar
        %find values that weren't scaled. These can't be scaled
        dper_values(data.par <=0) = NaN;
        column_label = '&#8706&#964/&#8706log(k)'; %html special chars
    else
        %want dlogper/dpar, which is 1/per * dper/dpar
        
        for i=1:length(data.par)
            if data.par(i) > 0
                dper_values(i)=dper_values(i)/data.per;
            else
                dper_values(i) = NaN;
            end
            % if par <=0, derivative already dper/dpar as wasn't scaled
            % in parscale.
        end
        column_label = '&#8706log(&#964)/&#8706log(k)'; %html special chars
    end
    
    if dolog
        warning off MATLAB:log:logOfZero;
        dper_values = log10(abs(dper_values));
        warning on MATLAB:log:logOfZero;
        column_label = ['log<sub>10</sub>(&#124' column_label '&#124)'];
    end
    
    if keep_selections && length(parn) == size(oldtabledata,1)
        sel = cell2mat(oldtabledata(:,1));
    else
        sel = zeros(1, length(parn));
    end
    
    dper_values_txt = createSortableColumn(dper_values);
    for p = 1:length(parn)
        if sel(p)
            tabledata(p, :) = {true parn{p} dper_values_txt{p}};
        else
            tabledata(p, :) = {false parn{p} dper_values_txt{p}};
        end
    end
    
    set(dataTbl, 'columnname', {'', '<html><span style="font-size:8px">k', ['<html><span style="font-size:8px">' column_label]});
    
    
    user_data.model = data.name;
    set(dataTbl, 'data', tabledata, 'Userdata', user_data);
    
    
    %sorting resets on data change with native MATLAB uitable
else
    set(dataTbl, 'data', {});
end

 