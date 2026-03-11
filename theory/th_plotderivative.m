function r = th_plotderivative(action, varargin)


persistent panel scaleHndl selAllHndl clearAllHndl typeList perdgs nonperdgs axesTypeHndl selectLblHndl selectTblHndl dataTbl data dataTypeHndl;

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
    
    
    typeList = uibuttongroup('SelectionChangeFcn', 'th_plotderivative(''perChange'');', 'Units','centimeters', 'Position', [0.5 pheight-1.5 (pwidth-1) 0.5], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    perdgs=uicontrol('HorizontalAlignment', 'right', 'Parent',typeList,'string', '<html>Periodic &#8706g/&#8706k' ,'Units','normalized','Style','radiobutton', 'min', 0, 'max', 1, 'position',[0 0 0.5 1],'Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    nonperdgs=uicontrol('HorizontalAlignment', 'right', 'Parent',typeList,'string', '<html>Non-periodic &#8706g/&#8706k' ,'Units','normalized','Style','radiobutton', 'min', 0, 'max', 1,'position',[0.5 0 0.5 1], 'Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(typeList, 'UserData', [perdgs nonperdgs]);
    
    
     %scaling
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-2.5 2.5 0.5],'string','Scaling','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    scaleHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3 pheight-2.45 7.75 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotderivative(''scaleChange'');', ...
        'String', {'<html>No scaling', '<html>Divide &#8706g/&#8706k by variable values'});
    
  
    %log or abs?
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3.4 2.5 0.5],'string','Then plot','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    dataTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3 pheight-3.3 3.875 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotderivative(''dataChange'');', ...
        'String', {'<html>&#8706g/&#8706k', '<html>&#124 &#8706g/&#8706k &#124', '<html>&#8706g/&#8706logk'});
    
    %list of params or vars to select
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-4.3 2.5 0.5],'string','Axes show','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
     
    axesTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3 pheight-4.2 7.75 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotderivative(''axesTypeChange'');', ...
        'String', {'selected parameters for one variable', 'selected variables for one parameter'}, ...
        'value', 1, 'userdata', 1);
  
    selectLblHndl = uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5.4 3.5 0.5],'string','','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);

    selectTblHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[0.5 pheight-6.15 3.5 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', {'...'});
    
    dataTbl = uitable('units', 'centimeters','position', [4.5 0.5 pwidth-5 pheight-5.4], ...
        'columneditable', [true false], ...
        'columnname', {'', ''}, ...
        'rowname', {}, 'rowstriping', 'off', 'backgroundcolor', [1 1 1], ...
        'fontunits', 'points', 'fontsize', 10, ...
        'parent', panel);
    
    set(dataTbl, 'units', 'pixels')
    tblwidth = get(dataTbl, 'position');
    colwidth = (tblwidth(3)-45);
    set(dataTbl, 'columnwidth', {25 colwidth});
    
    selAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-7.2 3.5 0.6], ...
        'Parent',panel, ...
        'string', 'Select all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Select all table entries', ...
        'Callback','th_plotderivative(''selall'');');
    clearAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-8 3.5 0.6], ...
        'Parent',panel, ...
        'string', 'Clear all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Clear table selections', ...
        'Callback','th_plotderivative(''clearall'');');
    
    r = panel;
    
elseif strcmp(action, 'name')
    r = 'Solution Derivatives';
    
elseif strcmp(action, 'show')
    
    set(panel, 'visible', 'on');
    
elseif strcmp(action, 'hide')
    
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'description')
    r = 'Plots the time series of the derivative of the solution variables with respect to parameters, &&#8706g/&#8706k. This can be divided by corresponding variable values and the result plotted as absolute or log absolute values.';

    
elseif strcmp(action, 'changefile')
    %called when ts file changes.
    model = varargin{1};
    data = varargin{2};

   th_plotderivative('newtheory', model, data);
    
elseif strcmp(action, 'newtheory')

   model = varargin{1};
   data = varargin{2};

   if IsValid(model, data)
  
       if isfield(data.theory, 'nonper_dgs') && isfield(data.theory, 'periodic_dgs')
           set([perdgs nonperdgs], 'enable', 'on');
       else
           if isfield(data.theory, 'nonper_dgs')
               set(nonperdgs, 'value', 1, 'enable', 'on');
               set(perdgs, 'enable', 'off');
           else
                set(perdgs, 'value', 1, 'enable', 'on');
                set(nonperdgs, 'enable', 'off');
           end
       end
   else
       set([perdgs nonperdgs], 'enable', 'off');
   end
   th_plotderivative('axesTypeChange', 0); %no message to dispaly as 'isvalid' will take case of this
   
   
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
        %can be false to suppress message at startup
        showMsg = varargin{3};
    else
        showMsg = true;
    end
    if showMsg
        if r
            th_tippanel('write', 'You have selected to plot the derivatives of the solution with respect to the model parameters', 0);
            th_plotderivative('showmessage', [typeList scaleHndl dataTypeHndl axesTypeHndl]); %displays information about control settings
            
        else
            msg = 'Solution derivative plotting is not available ';
            if isempty(data) || ~isfield(data, 'theory')
                msg = [msg 'as the data cannot be found.'];
            elseif ~isfield(data.theory, 'periodic.dgs') || ~isfield(data.theory, 'nonper_dgs')
                msg = [msg 'as derivatives have not been calculated for the selected file.'];
            end
            th_tippanel('write', msg,  2);
        end
    end
    
elseif strcmp(action, 'plot')
    
    model = varargin{1};
    data = varargin{2};
    
    %periodic?
    if get(perdgs, 'Value') ~= 0
        periodic = true;
    else
        periodic = false;
    end
    scaling = get(scaleHndl, 'value');
    derivative_type = get(dataTypeHndl, 'value');
    ax_type = get(axesTypeHndl, 'value');
    select_list = get(selectTblHndl, 'value');
    
    tabledata = get(dataTbl, 'data');
    select_table = zeros(size(tabledata, 1),1);
    for r = 1:size(tabledata, 1)
       if tabledata{r, 1} 
           select_table(r) = 1;
       end
    end
    
    if ~any(select_table)
       if ax_type == 1
           ShowError('Please select one or more parameters to plot');
           return;
       else
            ShowError('Please select one or more variables to plot');
            return;
       end
    end

   
   doplot(data, periodic, scaling, derivative_type, ax_type, select_list, select_table);

    %plot as heat maps option   

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
elseif strcmp(action, 'selall')
    
    tabledata = get(dataTbl, 'data');
    for i = 1:size(tabledata, 1)
        tabledata{i,1} = true;
    end
    set(dataTbl, 'data', tabledata);
   
elseif strcmp(action, 'clearall')
  
    tabledata = get(dataTbl, 'data');
    for i = 1:size(tabledata, 1)
        tabledata{i,1} = false;
    end
    set(dataTbl, 'data', tabledata);
    
%=========================================================================
elseif strcmp(action, 'axesTypeChange')
    %switching between one param or one variable per plot
    
    if isempty(data)
        set(selectTblHndl, 'string', '...');
        set(dataTbl, 'data', {});
        set(selectLblHndl, 'string', '');
    else
        pnames = cell(length(data.parn), 1);
        for i = 1:length(pnames)
            if ~strcmp(data.parnames{i}, data.parn{i})
                pnames{i} = sprintf('%s, %s', data.parn{i}, data.parnames{i});
            else
                pnames{i} = data.parn{i};
            end
        end
        vnames = data.vnames;
        
        axis_type = get(axesTypeHndl, 'value');
        oldtabledata =  get(dataTbl, 'data');
        
        if axis_type == 1
            set(selectTblHndl, 'string', vnames);
            tabledata = cell(length(pnames), 2);
            
            if nargin > 1 && size(oldtabledata, 1) == size(tabledata, 1);
                %new file or running theory on current file
                %keep selections
                sel = cell2mat(oldtabledata(:,1));
                
            else
                %changing axes type
                sel = zeros(size(tabledata, 1), 1);
            end
            
            
            for i = 1:length(pnames)
                if sel(i)
                    tabledata(i, :) = {true pnames{i}};
                else
                    tabledata(i, :) = {false pnames{i}};
                end
            end
            set(dataTbl, 'data', tabledata);
            set(dataTbl, 'Columnname' , {'', 'Parameter'});
            if nargin < 1
               th_plotderivative('showmessage', axesTypeHndl);
            end
        else
            set(selectTblHndl, 'string', pnames);
            tabledata = cell(length(vnames), 2);
            
            if nargin > 1 && size(oldtabledata, 1) == size(tabledata, 1);
                %new file or running theory on current file
                %keep selections
                sel = cell2mat(oldtabledata(:,1));
                
            else
                %changing axes type
                sel = zeros(size(tabledata, 1), 1);
            end
            
            for i = 1:length(vnames)
                if sel(i)
                    tabledata(i, :) = {true vnames{i}};
                else
                    tabledata(i, :) = {false vnames{i}};
                end
            end
            set(dataTbl, 'data', tabledata);
            set(dataTbl, 'Columnname' , {'', 'Variable'});
            
        end
        if nargin < 2
            th_plotderivative('showmessage', axesTypeHndl);
        end
    end
    
elseif strcmp(action, 'scaleChange')
    
   th_plotderivative('showmessage', scaleHndl);
    
    
elseif strcmp(action, 'dataChange')
    
      th_plotderivative('showmessage', dataTypeHndl);
      
elseif strcmp(action, 'perChange')
    
      th_plotderivative('showmessage', typeList);
    
elseif strcmp(action, 'showmessage')
    
    th_tippanel('clear_highlight');
    
    ctrls = varargin{1};
    
    for c = 1:length(ctrls)
     
       switch ctrls(c)
           
           case typeList
               
               opts = get(typeList, 'userdata');
               if strcmp(get(opts(1), 'enable'), 'on') && strcmp(get(opts(2), 'enable'), 'on')
                   %must be unforced oscillator
                   if get(opts(1), 'value') == get(opts(1), 'max')
                       msg = 'The rescaled periodic derivatives will be plotted';
                   else
                       msg = 'The non-periodic derivatives will be plotted.';
                   end
               else
                   msg = '';
               end
          
           case scaleHndl
               
               sc = get(scaleHndl, 'value');
               if sc == 2
                  msg = 'Solution derivatives will be divided by the solution variables.'; 
               else
                   msg = 'Solution derivatives will not be divided by the solution variables.';
               end
               
           case dataTypeHndl
               
               dt = get(dataTypeHndl, 'value');
               if dt == 1
                   msg = 'Values will not be made absolute, or logs taken.';
               elseif dt == 2
                   msg = 'Absolute values will be plotted.';
               else
                   msg = 'Log k values will be plotted.'; %MD 24.07.2015
               end
               
           case axesTypeHndl
               
               ax = get(axesTypeHndl, 'value');
               if ax == 1
                    msg = 'Axes will show the derivatives of the single selected variable with respect to the all the selected parameters.';
               else
                    msg = 'Axes will show the derivatives of all the selected variables with respect to the single selected parameter.';
               end  
           
       end
       if ~isempty(msg)
            th_tippanel('write', msg, 1);
       end
   end
    
end


%=========================================================================

function  doplot(data, periodic, scaling, derivative_type, ax_type, select_list, select_table)
   
%one set of axes for each param, one data series for each variable
global plot_font_size

[p fname] = fileparts(data.myfile);
if periodic
    dgs = data.theory.periodic_dgs;
    tstr = 'Periodic';
else
    dgs = data.theory.nonper_dgs;
    tstr = 'Non-periodic';
end


if scaling == 2
    title_str = [tstr ' solution derivatives / time series, '];
else
    title_str = [tstr ' solution derivatives, '];
end

pos = get_size_of_figure();
newfig = figure('NumberTitle', 'off', 'Units', 'normalized', 'Position', pos, 'Name', [title_str 'from ' data.name ', ' fname], 'Color', [1 1 1]); %MD change background
axes('Fontsize', plot_font_size); %MD

if ax_type == 1
    
    %creating a plot wih one series for each parameter
    ptoplot = find(select_table); 
    vartoplot = select_list;
    tspan = data.sol.x;
    pcount = 1;
    leg_str = cell(length(ptoplot), 1);
 
    for p = ptoplot'
       
        data_to_plot = dgs(:,vartoplot,p);
        if scaling == 2
            data_to_plot = data_to_plot ./ data.sol.y(:,vartoplot);
        end
        if derivative_type == 2 %want |dg/dk|
            data_to_plot = abs(data_to_plot);
        elseif derivative_type == 3 %want dg/dlogk
            if data.par(p)>0
                data_to_plot =data_to_plot*data.par(p);
            end%log(abs(data_to_plot)); MD 24.07.2015 I am removing this and putting in the dg/dlogk instead asthis is more useful to know.  Also gone with the scaling option (as in parscale.m) that if parameter is zero the value doesn't get scaled
        end
        plot(tspan, data_to_plot, get_plot_style(pcount),'LineWidth',2);
        hold on;
        
        if derivative_type == 1 || derivative_type == 2 %MD 24.07.2015
        leg_str{pcount} = ['\partial'  data.vnames{vartoplot}  ' / \partial' data.parn{p}];
        else
        leg_str{pcount} = ['\partial'  data.vnames{vartoplot}  ' / \partiallog' data.parn{p}];
        end
        pcount = pcount+1;
        
    end
    xlabel('Time', 'FontUnits', 'points', 'FontSize', plot_font_size);
    xlim([tspan(1) tspan(end)]);
    
   
    legend(leg_str, 'FontUnits', 'points', 'FontSize', 12);
    
    if derivative_type == 1
        ylbl = '\partialg / \partialk';
    elseif derivative_type == 2
        ylbl = '| \partialg / \partialk |';
    else
        ylbl = ' \partialg / \partiallogk'; %MD 24.07.2015
    end
    ylabel(ylbl, 'FontUnits', 'points', 'FontSize', plot_font_size);
  
    title(['Derivative of  ' data.vnames{vartoplot} ', ' ylbl], 'FontUnits', 'points', 'FontSize', plot_font_size);
    
else
    %one data serie sfor each selected variable
    
    vtoplot = find(select_table); 
    ptoplot = select_list;
    tspan = data.sol.x;
    leg_str = cell(length(vtoplot), 1);
    vcount = 1;
    for v = vtoplot'
        data_to_plot = dgs(:,v,ptoplot);
        if scaling == 2
            data_to_plot = data_to_plot ./ data.sol.y(:,v);
        end
        if derivative_type == 2
            data_to_plot = abs(data_to_plot);
        elseif derivative_type == 3
            data_to_plot = log(abs(data_to_plot));
        end
        plot(tspan, data_to_plot, get_plot_style(vcount),'LineWidth',2);
        hold on;
         if derivative_type == 1 || derivative_type == 2 %MD 24.07.2015
        leg_str{vcount} = ['\partial' data.vnames{v}  ' / \partial' data.parn{ptoplot}];
         else 
           leg_str{vcount} = ['\partial' data.vnames{v}  ' / \partiallog' data.parn{ptoplot}];   
         end
        vcount = vcount+1;
        
    end
    xlabel('Time', 'FontUnits', 'points', 'FontSize', plot_font_size);
    xlim([tspan(1) tspan(end)]);
   
    legend(leg_str, 'FontUnits', 'points', 'FontSize', 12);
    
    if derivative_type == 1
        ylbl = ['\partialg / \partial' data.parn{ptoplot}];
    elseif derivative_type == 2
        ylbl = ['| \partialg / \partial' data.parn{ptoplot} ' |'];
    else
        ylbl = ['\partialg / \partiallog' data.parn{ptoplot} ' ']; %MD 24.07.2015
    end
    ylabel(ylbl, 'FontUnits', 'points', 'FontSize', plot_font_size);
  
    title(['Derivative with respect to ' data.parn{ptoplot} ', ' ylbl], 'FontUnits', 'points', 'FontSize', plot_font_size);
    
end



%=========================================================================

function  v = IsValid(mdl, ts, showMsg)

 %to be a valid plot type, model must be oscillator,
 %time series must be unforced and theoretical analysis must
 %have been done.
 
 %reason is the cause of this function being called. It can be
 %a) this plot type selected by user
 %b) new ts file selected
 %c) theoretical data added to current file
 
 v = ~isempty(mdl) && ~isempty(ts) && isfield(ts, 'theory') && (isfield(ts.theory, 'periodic_dgs') || isfield(ts.theory, 'nonper_dgs'));


 %change plot 'isvalid' if selected
 %change file 'newtheory', 'isvalid' if selected
 %new theory  'newtheory', 'isvalid' if selected
 
