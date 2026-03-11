function r = th_plotphasederivative(action, varargin)
%    th_tippanel('write', 'You have selected to plot the infinitesimal response curves for variable phases (peak times).', 0);

persistent selAllHndl clearAllHndl phaseTypeHndl axesTypeHndl dataTypeHndl
persistent selectLblHndl panel phasedata table_is_formatted logHndl lblHndl dataTbl selectTblHndl

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
    
    %peaks or troughs
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 3 0.5],'string','Use phase of','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    phaseTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3 pheight-1.45 3.5 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotphasederivative(''phaseTypeChange'');', ...
        'String', {'peaks', 'troughs'});
    
    
    %plot logs? 
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-2.5 3.5 0.5],'string','Derivative of','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    dataTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3 pheight-2.45 7.75 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotphasederivative(''phaseTypeChange'');', ... 
        'String', {'phase with respect to parameter', 'phase with respect to log parameter'});
    
    logHndl=uicontrol('Style','checkbox', 'Units','centimeters', 'position',[0.5 pheight-3.5 3 0.6],'min', 0, 'max', 1, ...
        'callback', 'th_plotphasederivative(''phaseTypeChange'');', ...
        'string', 'Take log10' , 'Parent',panel,'FontUnits', 'points', 'FontSize', 10, 'BackgroundColor', maincol, 'tooltipstring', 'Check to take log to the base 10 of the absolute value of the derivative');

   % axHndl = axes('Units','centimeters','parent', panel, 'position', [5 pheight-3.25 pwidth-5.5 0.6], 'xtick', [], 'ytick', [], 'color', 'none', 'box', 'off', 'visible', 'off');
   % xlim([0 1]); ylim([0 1]);
  %  lblHndl = text(0,0, '', 'parent', axHndl,'FontUnits', 'points', 'FontSize', 14);
   % set([logHndl dataTypeHndl], 'callback', {@updateLabel, dataTypeHndl, logHndl, lblHndl});
   
   
    %list of params or vars to select
     uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-4.5 3.5 0.5],'string','Axes show','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
     
    axesTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3 pheight-4.5 7.75 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotphasederivative(''axesTypeChange'');', ...
        'String', {'selected parameters for one variable', 'selected variables for one parameter'}, ...
        'value', 1, 'userdata', 1);
 
    
     selectLblHndl = uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5.75 3.5 0.5],'string','','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);

     selectTblHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[0.5 pheight-6.5 3.5 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotphasederivative(''fillTable'');', ...
        'String', {'...'});

    
     dataTbl = uitable('units', 'centimeters','position', [4.5 0.5 pwidth-5 pheight-5.75], ...
        'columneditable', [true false false], ...
        'columnname', {'', '', ''}, ...
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
        'Position',[0.5 pheight-7.5 3.5 0.6], ...
        'Parent',panel, ...
        'string', 'Select all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Select all table entries', ...
        'Callback','th_plotphasederivative(''selall'');');
    clearAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-8.3 3.5 0.6], ...
        'Parent',panel, ...
        'string', 'Clear all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Clear table selections', ...
        'Callback','th_plotphasederivative(''clearall'');');
    
 
 %   updateLabel([], [], dataTypeHndl, logHndl, lblHndl);

    
    table_is_formatted = false;
    phasedata = [];
        
     
    r = panel;
    
elseif strcmp(action, 'name')
    
    r  = 'Phase Derivatives';
    
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
    
    r = 'Plots the derivatives of the phases of variable peaks and troughs with respect to parameter. One figure can show the derivative of selected variables with repsect to a set parameter, or the derivative of a set variable with respect to selected parameters.';
    
elseif strcmp(action, 'phaseTypeChange')
    
    axesTypeChange(dataTbl, phaseTypeHndl, dataTypeHndl, logHndl, selectTblHndl, axesTypeHndl, selectLblHndl, phasedata);
    if ~isempty(phasedata)
        show_message(phaseTypeHndl, axesTypeHndl);
    end

elseif strcmp(action, 'axesTypeChange')
    
    axesTypeChange(dataTbl, phaseTypeHndl,  dataTypeHndl, logHndl, selectTblHndl, axesTypeHndl, selectLblHndl, phasedata);
    if ~isempty(phasedata)
        show_message(phaseTypeHndl, axesTypeHndl);
    end
    
elseif strcmp(action, 'fillTable')
    
    %user has chosen a new variable or parameter
    
    fillTable(dataTbl, phaseTypeHndl,  dataTypeHndl, logHndl, selectTblHndl, axesTypeHndl, phasedata);
    
    
elseif strcmp(action, 'changefile')
    %called when ts file changes.
    model = varargin{1};
    phasedata = varargin{2};
    
    th_plotphasederivative('newtheory', model);
    
elseif strcmp(action, 'newtheory')
 
    model = varargin{1};
    
    if nargin > 2
        %running theory on current file, not selecting a ne wfile
        phasedata = varargin{2};
        new_file = false;
    else
        %don't show message here if selecting new file, as 'isvalid' will
        %be called next
        new_file = true;
    end
    
    if ~IsValid(model, phasedata)
        phasedata = [];
    end
    %fill in var/param list and fill derivatives table
    axesTypeChange(dataTbl, phaseTypeHndl,  dataTypeHndl, logHndl, selectTblHndl, axesTypeHndl, selectLblHndl, phasedata);
    if ~new_file && ~isempty(phasedata)
        show_message(phaseTypeHndl, axesTypeHndl);
    end
    
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
    
    phase_type = get(phaseTypeHndl, 'value');
    data_type = get(dataTypeHndl, 'value');
    dolog = (get(logHndl, 'value') == get(logHndl, 'max'));
    axes_type = get(axesTypeHndl, 'value');
    
    
    doplot(data, phase_type, data_type, dolog, axes_type, selectTblHndl, dataTbl, fname, model.name);
    
elseif strcmp(action, 'set')
    return;
    
    
    %return index value for next panel
    r = idx;
elseif strcmp(action, 'save')
    return;
    %save control values to file
    %the order here must match the order they are loaded in, as above
    
    
elseif  strcmp(action,'isvalid')
    %called from other files to determine whether or not to activate the
    %plot button
    
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
            msg = 'You have selected to plot the derivative of the variable phases of the forced limit cycle, with respect to the model parameters';
        else
            msg = 'Phase derivative plotting is not available ';
            message_level = 2;
            if ~strcmp(model.orbit_type, 'oscillator')
                msg = [msg 'as the selected model is not an oscillator.'];
            elseif isempty(data)
                msg = [msg 'as the data cannot be found.'];
            elseif ~data.forced
                msg = [msg 'as the selected limit cycle is free running. Select the IRC option instead to view the derivatives of the period.'];
            else
                msg = [msg 'as derivatives have not been calculated for the selected file.'];
            end
        end
        th_tippanel('write', msg,  message_level);
        %show info about controls
        if r
            show_message(phaseTypeHndl, axesTypeHndl);
        end
        
    end
    
end


%=========================================================================

function  v = IsValid(mdl, ts, showMsg)

%to be a valid plot type, model must be oscillator,
%time series must be forced and theoretical analysis must
%have been done.

%reason is the cause of this function being called. It can be
%a) this plot type selected by user
%b) new ts file selected
%c) theoretical data added to current file

v = ~isempty(mdl) && strcmp(mdl.orbit_type, 'oscillator') && ~isempty(ts) &&  ts.forced && isfield(ts, 'theory') && isfield(ts.theory, 'dpkdpar');




%=========================================================================

function axesTypeChange(dataTbl, phaseTypeHndl,  dataTypeHndl, logHndl, selectTblHndl, axesTypeHndl, selectLblHndl, data)

%user opts to plot all params or all vars on one set of axes
%called when selecting a new file, running theory, changing phase type
%(peak/trough) or changing axis type


if isempty(data)
    set(selectTblHndl, 'string', '...');
    set(dataTbl, 'data', {});
    set(selectLblHndl, 'string', '');
else
    ctrl = gcbo;
    if isempty(ctrl) ||  ~any([phaseTypeHndl  dataTypeHndl logHndl] == ctrl)
        % no need to refill list if just changing peak/trough, do log10, or
        % derivative type. Just need to refill table in this case
        %ctrl empty at startup
        choice = get(axesTypeHndl, 'value');
        
        if choice == 1
            %all params for 1 var
            
            set(selectTblHndl, 'string', data.vnames, 'value', 1);
            set(selectLblHndl, 'string', 'Variable:');
        else
            parnames = cell(length(data.parn),1);
            for p = 1:length(parnames)
                parnames{p} = [data.parn{p} ', ' data.parnames{p}];
            end
            set(selectTblHndl, 'string', parnames, 'value', 1);
            set(selectLblHndl, 'string', 'Parameter:');
            
        end
    end
    
    
    fillTable(dataTbl, phaseTypeHndl,  dataTypeHndl, logHndl, selectTblHndl, axesTypeHndl, data);
end

%=========================================================================

function show_message(phaseTypeHndl, axesTypeHndl)

%dispalys information about current settings. Called when user changes
%phase or axis type

msg = '';   
phasetype = get(phaseTypeHndl, 'value');
str = get(phaseTypeHndl, 'string');
phasetype = str{phasetype};
choice = get(axesTypeHndl, 'value');
if choice == 1
    %all params for 1 var
    msg = [msg 'Axes will show the derivatives of the phase of the ' phasetype ' of the single selected variable with respect to the all the selected parameters.'];
else
    msg = [msg 'Axes will show the derivatives of the phase of the ' phasetype ' of all the selected variables with respect to the single selected parameter.']; 
end
th_tippanel('clear_highlight');
th_tippanel('write', msg, 1);


%=========================================================================

function fillTable(dataTbl, phaseTypeHndl,  dataTypeHndl, logHndl, selectTblHndl, axesTypeHndl, data)

%fills data table with either a list of params or a list of variables

if isfield(data, 'theory') && isfield(data.theory, 'dpkdpar')

    user_data = get(dataTbl, 'Userdata');
    phasetype = get(phaseTypeHndl, 'value');
    if phasetype == 1 
        dphi = data.theory.dpkdpar;
    else
        dphi = data.theory.dtrdpar;
    end
    datatype = get(dataTypeHndl, 'value');
    dolog = get(logHndl, 'value') == get(logHndl, 'max');
    axestype = get(axesTypeHndl, 'value');
    
    oldtabledata =  get(dataTbl, 'data');
    if ~isempty(oldtabledata) && strcmp(user_data.model, data.name) && user_data.axes_type == axestype
        %changed file or param/var from drop down list so keep selections
        %in table
        keep_selections = true;
    else
        %check that we haven't just changed the model or axes type. Ignore
        %previous  
        %selections if we have.
        keep_selections = false;
    end
    
    if axestype == 1
        %table will display a list of parameters
        variable = get(selectTblHndl, 'value');
        tabledata = cell(length(data.parn), 3);
        parn  = data.parn;
        dphi_values = zeros(1,length(data.parn));
        if ~isempty(dphi{variable})
            for p = 1:length(data.parn)
                [m idx] = max(abs(dphi{variable}(p,:)));
                dphi_values(p) = dphi{variable}(p,idx);
                %in case of > 1 peak display largest derivative
            end
        end
        if datatype == 1
           %want dphi/dpar, so need to divide by par
           for i=1:length(data.par)
                if data.par(i) > 0
                    dphi_values(i)=dphi_values(i)/data.par(i);
                end
                % if par <=0, derivative already dphi/dpar as wasn't scaled
                % in parscale.
           end
            column_label = '&#8706&#934/&#8706k'; %html special chars
        else 
            %want dphi/dlogpar
            %find values that weren't scaled. These can't be scaled
            dphi_values(data.par <=0) = NaN;
            column_label = '&#8706&#934/&#8706log(k)'; %html special chars
        end
        if dolog
            warning off MATLAB:log:logOfZero;
            dphi_values = log10(abs(dphi_values));
            warning on MATLAB:log:logOfZero;
            column_label = ['log<sub>10</sub>(&#124' column_label '&#124)'];
        end
        
        if keep_selections && length(parn) == size(oldtabledata,1)
            sel = cell2mat(oldtabledata(:,1));
        else
            sel = zeros(1, length(parn));
        end
        
        dphi_values_txt = createSortableColumn(dphi_values);
        for p = 1:length(parn)
            if sel(p)
                tabledata(p, :) = {true parn{p} dphi_values_txt{p}};
            else
                tabledata(p, :) = {false parn{p} dphi_values_txt{p}};
            end
        end
       
        set(dataTbl, 'columnname', {'', '<html><span style="font-size:8px">k', ['<html><span style="font-size:8px">' column_label]});
        
    else
        %table will display a list of variables
        param = get(selectTblHndl, 'value');
        tabledata = cell(length(data.vnames), 3);
        
        if keep_selections && length(data.vnames) == size(oldtabledata,1)
            sel = cell2mat(oldtabledata(:,1));
        else
            sel = zeros(1, length(data.vnames));
        end
        
        dphi_values = zeros(1,length(data.vnames));
        
        for v = 1:length(data.vnames)
            if ~isempty(dphi{v})
                [m, idx] = max(abs(dphi{v}(param,:)));
                dphi_values(v) = dphi{v}(param,idx);
            end
        end
        if datatype == 1
           %want dphi/dpar, so need to divide by par
           if data.par(param) > 0
               dphi_values=dphi_values/data.par(param);
           end
           % if par <=0, derivative already dphi/dpar as wasn't scaled
           % in parscale.
           column_label = '&#8706&#934/&#8706k'; %html special chars
        else

            if data.par(param) <= 0
                %can't caclulate dphi/dlogpar for this par
               dphi_values = NaN(size(dphi_values)); 
            end
            column_label = '&#8706&#934/&#8706log(k)'; %html special chars
        end
  
        if dolog
            warning off MATLAB:log:logOfZero;
            dphi_values = log10(abs(dphi_values));
            warning on MATLAB:log:logOfZero;
            column_label = ['log<sub>10</sub>(&#124' column_label '&#124)'];
        end
        
        dphi_values_txt = createSortableColumn(dphi_values);
        
        for v = 1:length(data.vnames)
             if sel(v)
                tabledata(v, :) = {true data.vnames{v} dphi_values_txt{v}};
             else
                 tabledata(v, :) = {false data.vnames{v} dphi_values_txt{v}};
             end
        end
        set(dataTbl, 'columnname', {'', '<html><span style="font-size:8px">y', ['<html><span style="font-size:8px">' column_label]});
        
    end
    
    
    user_data.model = data.name;
    user_data.axes_type = axestype;
    set(dataTbl, 'data', tabledata, 'Userdata', user_data);

    
    %sorting resets on data change with native MATLAB uitable
else
    set(dataTbl, 'data', {});
end

%==========================================================================

function doplot(data, phase_type, data_type, dolog, axes_type, selectTblHndl, dataTbl, file_name, model_name)  

global plot_font_size

if phase_type == 1
    tstr = ['Derivative of peak'];
    dphi = data.theory.dpkdpar;
else
    tstr = ['Derivative of trough'];
    dphi = data.theory.dtrdpar;
end
%find order in which rows of table are displayed
tblData = get(dataTbl, 'Data');
sorted_idx = (1:size(tblData,1))';
  
if axes_type == 1
    
    %plotting selected parameters and a specified variable
    variable = get(selectTblHndl, 'value');
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
    dphi = dphi{variable};  %param by peak matrix
    
    if isempty(dphi)
        ShowError('The selected variable appears not to have a phase. This suggests its time series is either flat or monotonically increasing or decreasing. Please select a different variable.');
        return;
    end
    
    dphi_to_plot = dphi(parameters, :); %select required rows
    parnames = data.parn(parameters);
    parvalues = data.par(parameters);
   
    %apply required processing
    if data_type == 1
        %plot dphi/dk. Stored values are dphi/dlogk, so divide by k if
        %previously scaled
        y_label = '\partial\phi / \partialk_j';

        for i=1:length(parvalues)
            if parvalues(i) > 0
                dphi_to_plot(i, :)=dphi_to_plot(i, :)/parvalues(i);
            end;
        end
        
    else
        %plot dphi/dlogk.  Note that if some parameters have zero or negative
        %values, for those we can't plot dphi/dlog(k). These are
        %removed as were never scaled in the first place.
        y_label = '\partial\phi / \partiallogk_j';

        dphi_to_plot(parvalues <=0, :) = NaN;
        if all(isnan(dphi_to_plot))
           ShowError('You cannot take logs of the selected parameters as they all have values less than or equal to zero.');
           return;
        end
        
    end
    if dolog
        warning off MATLAB:log:logOfZero;
        dphi_to_plot = log10(abs(dphi_to_plot));
        warning on MATLAB:log:logOfZero;
        y_label = ['log_{10}(|' y_label '|)'];
        
    end
    
    %create figure
    %size it in cm and centre it on screen
    pos = get_size_of_figure();
    newfig = figure('NumberTitle', 'off', 'Units', 'normalized', 'Position', pos, 'Color', [1 1 1]);
    
    %filter out bad values
    toremove = find(isnan(dphi_to_plot(:,1)));
    parnames(toremove) = [];
    dphi_to_plot(toremove, :) = [];
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
    dphi_to_plot = dphi_to_plot(new_idx, :);
    parnames = parnames(new_idx);
    
    %plot each peak as a seperate data serie
    bar(dphi_to_plot);
    
    %labels
    set(gca, 'xticklabel', []);
    xlim([0 size(dphi_to_plot,1)+1]);
    yv = get(gca, 'YLim');
    set(gca,'xtick', [1:size(dphi_to_plot,1)]);
    set(gca,'YGrid', 'on');
    
    %label cols
    if size(dphi_to_plot,1) > 12
        %vertical text to save space
        for p = 1:size(dphi_to_plot,1)
            text('parent', gca, 'string', parnames(p), 'rotation', 90, 'position', [p yv(1)-diff(yv)/10], 'fontsize', plot_font_size);
        end
    else
        xticks = cell(0);
        for p = 1:size(dphi_to_plot,1)
            xticks = [xticks, parnames{p}];
        end
        set(gca, 'xticklabel', xticks, 'fontsize', plot_font_size);
    end
    
    %legend if > 1 peak
    if size(dphi_to_plot,2) > 1
        legend_str = {};
        for p = 1:size(dphi_to_plot,2)
            legend_str{p} = ['Peak ' num2str(p)];
        end
        legend(legend_str);
    end
    
    ylabel(y_label, 'FontSize', plot_font_size);
   % xlabel ('Parameter', 'FontSize', 12);
    
    tstr = [tstr ' phase of ' data.vnames{variable} ' with respect to parameters,      '];
    title([tstr y_label], 'FontSize', plot_font_size);
    set(newfig, 'name', [tstr 'from ' model_name ', ' file_name]);
    
    
else
    %plotting selected variables with respect to a specified parameter
   
    parameter = get(selectTblHndl, 'value');
    tabledata = get(dataTbl, 'data');
    variables = [];
    for y = 1:size(tabledata,1)
        if tabledata{y, 1}
            variables = [variables y];
        end
    end
    if isempty(variables)
        ShowError('You must select one or more variables to plot');
        return;
    end
    
    dphi_to_plot = [];
    %find var with most peaks
    [~, max_peaks] = cellfun(@size, dphi(variables));
    max_peaks = max(max_peaks);
    
    if ~max_peaks
        ShowError('The selected variable(s) appear not to have a phase. This suggests the time series are either flat or monotonically increasing or decreasing. Please select different variable(s).');
        return;
    end
    
    dphi_to_plot  = zeros(length(variables), max_peaks);
    %must pad with zeros so all data series the same length
    row = 1;
    for y = variables
        %each var has a param by peak matrix of derivatives
        dm = dphi{y};
        %select rquired param
        if ~isempty(dm)
            dm = dm(parameter,:);
            for p = 1:length(dm)
                 dphi_to_plot(row, p) = dm(p);
            end
        end
        row = row+1;
    end
    
    vnames = data.vnames(variables);
    parvalue = data.par(parameter);
   
    %apply required processing
    if data_type == 1
        %plot dphi/dk. Stored values are dphi/dlogk, so divide by k if
        %previously scaled
        y_label = ['\partial\phi / \partial' data.parn{parameter}];
         
        if parvalue > 0
           dphi_to_plot = dphi_to_plot/parvalue; 
        end
        
    else
        %plot dphi/dlogk.  Note that if parameter has zero or negative
        %value, we can't plot dphi/dlog(k).
        if parvalue > 0
            y_label = ['\partial\phi / \partiallog ' data.parn{parameter}];
             
        else
           ShowError('You cannot take the log of the selected parameter as it has a value less than or equal to zero.');
           return;
        end
        
    end
    if dolog
        warning off MATLAB:log:logOfZero;
        dphi_to_plot = log10(abs(dphi_to_plot));
        warning on MATLAB:log:logOfZero;
        y_label = ['log_{10}(|' y_label '|)'];
       
    end
    
    %create figure
    %size it in cm and centre it on screen
    pos = get_size_of_figure();
    newfig = figure('NumberTitle', 'off', 'Units', 'normalized', 'Position', pos);
    
    %sort them to get the order they appear in table
    %sorted_idx(n) is the position in the sorrted table of the nth
    %parameter of the unsorted list, ie the order in data.vnames
    selected_sorted_idx = [];
    for y = variables
        %y is position in unsorted table that a selected variable sppears
        %at. Find its index in the current, possibly sorted table
       selected_sorted_idx = [selected_sorted_idx sorted_idx(y)];
    end
    %sort selections to thi sorder
    [~, new_idx] = sort(selected_sorted_idx);
    dphi_to_plot = dphi_to_plot(new_idx, :);
    vnames = vnames(new_idx);

    %plot each peak as a seperate data serie
    bar(dphi_to_plot);
    
    %labels
    set(gca, 'xticklabel', []);
    xlim([0 size(dphi_to_plot,1)+1]);
    yv = get(gca, 'YLim');
    set(gca,'xtick', [1:size(dphi_to_plot,1)]);
    set(gca,'YGrid', 'on');
    
    %label cols
    if size(dphi_to_plot,1) > 12
        %vertical text to save space
        for y = 1:size(dphi_to_plot,1)
            text('parent', gca, 'string', vnames(y), 'rotation', 90, 'position', [y yv(1)-diff(yv)/10], 'fontsize', plot_font_size);
        end
    else
        xticks = cell(0);
        for y = 1:size(dphi_to_plot,1)
            xticks = [xticks, vnames{y}];
        end
        set(gca, 'xticklabel', xticks, 'fontsize', plot_font_size);
    end
    
    %legend if > 1 peak
    if size(dphi_to_plot,2) > 1
        legend_str = {};
        for p = 1:size(dphi_to_plot,2)
            legend_str{p} = ['Peak ' num2str(p)];
        end
        legend(legend_str);
    end
    
    ylabel([y_label], 'FontSize', plot_font_size);
    xlabel ('Variable', 'FontSize', plot_font_size);
    
    tstr = [tstr ' phase of model variables with respect to parameter ' data.parn{parameter} ',  '];
    title([tstr   y_label], 'FontSize', plot_font_size);
    set(newfig, 'name', [tstr 'from ' model_name ', ' file_name]);
    
    
end
