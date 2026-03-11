function r = tppgui(action, varargin)

persistent OKHndl cancelHndl tpTbl axHndl selplotHndl figHndl tfromHndl ttoHndl seltimeHndl deseltimeHndl
persistent new_vnames new_lc t_range newFig everyTimeHndl selEveryTimeHndl


if strcmp(action,'init')
    
    %draw figur
    vars = varargin{1};
    vnames = varargin{2};
    figHndl = varargin{3};
    fname = varargin{4};
    
    newFig=figure('menubar', 'none' ,'Name', 'Select timepoints' ,'NumberTitle','off','Visible','off', 'windowstyle', 'modal');
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    
    figwidth = 18;
    figheight = 15;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    
    pos = [figleft figbottom figwidth figheight];
    set(newFig, 'Units', 'centimeters', 'Position', pos);
    
    maincol = get(newFig, 'Color');
    frmPos=[0.1 0.9 figwidth-0.2 figheight-1];
  
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',frmPos, ...
        'HandleVisibility', 'on', ...
        'visible', 'on', ...
        'Parent', newFig);
    
    pheight = frmPos(4);
    pwidth = frmPos(3);
    
   uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1 pwidth-1 0.5],'string','Select a time range to select or remove', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
   
    %select all and remove buttons
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.75 1.5 0.5],'string','From:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    tfromHndl = uicontrol( ...
        'Style','popup', ...
        'HorizontalAlignment', 'right', ...
        'Units','centimeters', ...
        'position',[2 pheight-1.8 2.5 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '0', ...
        'BackgroundColor', 'w');
    
   uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[5 pheight-1.75 1 0.5],'string','to:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
   ttoHndl = uicontrol( ...
        'Style','popup', ...
        'HorizontalAlignment', 'right', ...
        'Units','centimeters', ...
        'position',[6 pheight-1.8 2.5 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '0', ...
        'BackgroundColor', 'w');

    seltimeHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[8.5 pheight-1.8 2 0.6], ...
        'Parent',panel, ...
        'string', 'Select', ...
        'FontUnits', 'points', 'FontSize',10, ...
        'Callback','tppgui(''selall'');');
    deseltimeHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[10.5 pheight-1.8 2 0.6], ...
        'Parent',panel, ...
        'string', 'Remove', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','tppgui(''remall'');');
    
  
    uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-2.5 3.25 0.5],'string','Or select every ', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    everyTimeHndl = uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'right', ...
        'Units','centimeters', ...
        'position',[3.75 pheight-2.5 2 0.6], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '2', ...
        'BackgroundColor', 'w');
    uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[6 pheight-2.5 2.5 0.5],'string','time points ', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    selEveryTimeHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[8.5 pheight-2.55 2 0.6], ...
        'Parent',panel, ...
        'string', 'Select', ...
        'FontUnits', 'points', 'FontSize',10, ...
        'Callback','tppgui(''selevery'');');
   
    uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3.5  pwidth-1 0.5],'string','You can edit individual points directly here', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

     %list of time values to choose from
    tpTbl = uitable('units', 'centimeters', 'position', [0.5 0.5 2.75 pheight-4.5], ...
                    'fontunits', 'points', 'fontsize', 10, ...
                    'parent', panel);
    set(tpTbl, 'CellEditCallback', @time_click);
    
 
    %get the time points from file
    t_range = get(figHndl, 'Userdata');
    set(tpTbl, 'units', 'pixels')
    tblwidth = get(tpTbl, 'position');
    tblwidth = tblwidth(3);
    set(tpTbl, 'data', t_range, 'ColumnWidth', {[tblwidth* 0.3] [tblwidth* 0.45]}, 'ColumnEditable', [true false], 'ColumnName', [], 'RowName', []);
    set([ttoHndl tfromHndl], 'String', t_range(:,2));
    
    
    tmp = zeros(size(t_range, 1), 1);
    for i = 1:size(t_range, 1)
        tmp(i) = str2double(t_range{i,2});
    end
   t_range = tmp;
    
    %combine variable as user selected 
    numv = length(vars);
    new_vnames = cell(1, numv);
    new_lc = zeros(length(t_range), numv);
    
    clear thetheoryresults
    set(newFig, 'pointer', 'watch');
    load(fname, '-mat'); 
    set(newFig, 'pointer', 'arrow');
  
    for v = 1:numv
       if isscalar(vars{v})
           %record variable names
            new_vnames{v} = vnames{vars{v}};
            new_lc(:, v) = thetheoryresults.sol.y(:, vars{v});
       else
           tmp = thetheoryresults.sol.y(:, vars{v});
           new_lc(:, v) = sum(tmp, 2);
           vrs = vars{v};
           tmp = [];
           for j = 1:length(vrs)
               tmp = [tmp vnames{vrs(j)} '+'];
           end
           new_vnames{v} = tmp(1:end-1);
       end     
    end
    clear thetheoryresults
    
    axHndl = axes('Units','centimeters', ...
        'Position',[4 2 pwidth-4.5 pheight-6], ...
        'Parent',panel);
  
    uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[4 0.5 2 0.5],'string','Display:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    selplotHndl = uicontrol( ...
        'Style','popup', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[5.75 0.45 pwidth-6.25 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String',new_vnames, ...
        'Value', 1, ...
        'BackgroundColor', 'w', ...
        'Callback', @time_click);
    
    
     %OK and Cancel buttons
    
    OKHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-4.1 0.1 2 0.7], ...
        'Parent',newFig, ...
        'string', 'OK', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','tppgui(''ok'');');
    
    cancelHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.1 0.1 2 0.7], ...
        'Parent',newFig, ...
        'string', 'Cancel', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','tppgui(''cancel'');');
   
    
    tppgui('plotchange');
    
    set(newFig, 'visible', 'on');
    
    r = newFig; %uiwait function requires this function to return a value
    

    
elseif strcmp(action,'cancel')
        
    delete(gcf);
    
elseif strcmp(action,'selall')
    
    from_idx = get(tfromHndl, 'Value');
    to_idx = get(ttoHndl, 'Value');
    data = get(tpTbl, 'data');
    sel = cell2mat(data(:,1));
    sel(from_idx:to_idx)= true;
    sel = mat2cell(sel, ones(length(sel), 1));
    data = [sel data(:,2)];
    set(tpTbl, 'data', data);
    
    tppgui('plotchange');
    
elseif strcmp(action,'selevery')
    
    seln = get(everyTimeHndl, 'string');
    seln = sscanf(seln, '%f')';
    if isempty(seln)
       ShowError('Please enter a valid number.');
       uicontrol(everyTimeHndl);
       return;
    end
    seln = floor(seln);
    if ~seln
        seln = 1;
    end
    data = get(tpTbl, 'data');
    sel = cell2mat(data(:,1));
    to_select = 1:seln:length(sel);
    sel(:)= false;
    sel(to_select) = true;
    sel = mat2cell(sel, ones(length(sel), 1));
    data = [sel data(:,2)];
    set(tpTbl, 'data', data);
    
    tppgui('plotchange');
    
elseif strcmp(action,'remall')
    
    from_idx = get(tfromHndl, 'Value');
    to_idx = get(ttoHndl, 'Value');
    data = get(tpTbl, 'data');
    sel = cell2mat(data(:,1));
    sel(from_idx:to_idx)= false;
    sel = mat2cell(sel, ones(length(sel), 1));
    data = [sel data(:,2)];
    set(tpTbl, 'data', data);
    
    tppgui('plotchange');

elseif strcmp(action,'plotchange')
    
   %variable or timepoint changed
    
    %change variable plotted
    idx = get(selplotHndl, 'value');
    
    %get timepoints selected and not selected
    tidx = get(tpTbl, 'data');
    tidx = tidx(:,1);
    sel = find(cell2mat(tidx));
    notsel = find(~cell2mat(tidx));
    plot(axHndl, t_range(sel), new_lc(sel, idx), 'r.', 'ButtondownFcn', {@line_click, axHndl, tpTbl, t_range});
    hold on;
    plot(axHndl, t_range(notsel), new_lc(notsel, idx), '.', 'MarkerEdgeColor', [0.75 0.75 0.75], 'MarkerFacecolor', [0.75 0.75 0.75], 'ButtondownFcn', {@line_click, axHndl, tpTbl, t_range});
    set(axHndl, 'xlim', [t_range(1) t_range(end)]);
    hold off;
    
elseif strcmp(action,'ok')
    
    data = get(tpTbl, 'data');
    set(figHndl, 'Userdata', data);
    delete(gcf);
    
end


function line_click(ln, evnt, axHndl, tblHndl, xdata)

%called when users clicks on the plot to toggle a timepoint on/off

persistent marker

%find point that was clicked on
p = get(axHndl, 'CurrentPoint');
x = p(1,1);
y = p(1,2);

%find index of point that was clicked on
[eps, idx] = min(abs(xdata-x));
%idx is its row in the list box

sel_typ = get(gcbf,'SelectionType');

if strcmp(sel_typ, 'normal')
    %left click
    %select/deselect the point the user has clicked on
    
    %or do range if there is a marker

    data = get(tblHndl, 'data');
    
    if isempty(marker)
        data{idx,1} = ~data{idx, 1};
    else
        idx = sort([marker idx]);
        for i = idx(1):idx(2)
            data{i,1} = ~data{i, 1};
        end
        marker = [];
    end
    set(tblHndl, 'data', data);
    %update plot
    tppgui('plotchange');
    
elseif strcmp(sel_typ, 'alt')
    %right click
    %leave marker 
    marker = idx;
     %update plot
    tppgui('plotchange');
    %add marker
    hold on;
    plot(axHndl, xdata(idx), y, 'bo');
    hold off;
end




function time_click(tblHndl, evnt)

%update plot if user changes model variable or time point selected in the list

tppgui('plotchange');


%zoom axes
