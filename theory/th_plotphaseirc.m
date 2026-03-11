function r = th_plotphaseirc(action, varargin)
%    th_tippanel('write', 'You have selected to plot the infinitesimal response curves for variable phases (peak times).', 0);

persistent paramsHndl  selAlltHndl clearAlltHndl varHndl
persistent  plotTypeHndl scaleHndl panel ircdata peakNumHndl table_is_formatted


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
    
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 3 0.5],'string','Select a variable','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    varHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[3.8 pheight-1.45 4.2 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotphaseirc(''changevar'');', ...
        'String', {'variables'});
    
    peakNumHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[8 pheight-1.45 (pwidth-8.5) 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'callback', 'th_plotphaseirc(''changepeak'');', ...
        'String', {'1'});
    
    %select/deselect all
    selAlltHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[4 pheight-2.5 (pwidth-4.5)/2 0.6], ...
        'Parent',panel, ...
        'string', 'Select all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Select all parameters', ...
        'Callback','th_plotphaseirc(''selall'');');
    clearAlltHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[4+(pwidth-4.5)/2 pheight-2.5 (pwidth-4.5)/2 0.6], ...
        'Parent',panel, ...
        'string', 'Clear all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Clear selections', ...
        'Callback','th_plotphaseirc(''clearall'');');
    
    %parameters to choose
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-2.5 3.25 0.5],'string','Select parameters','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    
    paramsHndl = uitable('units', 'centimeters','position', [0.5 1.5 (pwidth-1) pheight-4.25], ...
        'columneditable', [true false false false false], ...
        'columnname', {'', 'Parameter',  'Max Adv', 'Max Del', 'Phase Chng'}, ...
        'rowname', {}, 'rowstriping', 'off', 'backgroundcolor', [1 1 1], ...
        'fontunits', 'points', 'fontsize', 10, ...
        'parent', panel);
    set(paramsHndl, 'units', 'pixels')
    tblwidth = get(paramsHndl, 'position');
    colwidth = (tblwidth(3)-30)/4;
    set(paramsHndl, 'columnwidth', {25 colwidth colwidth colwidth  colwidth});
  

    
     %scaling
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 0.5 1.25 0.5],'string','Scale','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    scaleHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[2 0.6 pwidth/2-3.5 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '.', ...
        'tooltipstring', 'This represents the length of the Y axis', ...
        'Value', 1);
   
      uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2-1.25 0.5 3 0.5],'string','Select plot type:','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
      plotTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[pwidth/2+1.5 0.6 pwidth/2-1.8 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', {'Line plots' 'Single line plot'}, ...
        'callback', @typeChange, ...
        'Value', 1);
    
   table_is_formatted = false;
    
    r = panel;
    
elseif strcmp(action, 'name')
    
    r  = 'Phase IRC';
    
elseif strcmp(action, 'show')
    
    set(panel, 'visible', 'on');
    drawnow;
    %Customise table. Have to wait until table is visible to get java
    %object
    if ~table_is_formatted
        %just do this once
        colwidths = [0.25 0.25 0.25 0.25];
        selectable = true;
        table_is_formatted = create_sortable_table(paramsHndl, colwidths, selectable);
    end
    
    
elseif strcmp(action, 'hide')
    
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'description')
    
    r = 'Plots the infinitesimal response curves of the phases of the variables with respect to parameters, of a forced limit cycle with a fixed period.';
    
elseif strcmp(action, 'changevar')
    
    var = get(varHndl, 'Value');
    if ~isempty(ircdata)
        is_visible = strcmp(get(panel, 'Visible'), 'on');
         th_tippanel('clear_highlight');
        ChangeVar(var, ircdata, paramsHndl, peakNumHndl, is_visible);
    end
    
elseif strcmp(action, 'changepeak')
    
    if ~isempty(ircdata)
        varnum = get(varHndl, 'value');
        is_visible = strcmp(get(panel, 'Visible'), 'on');
        th_tippanel('clear_highlight');
        ChangePeak(peakNumHndl, ircdata, paramsHndl, varnum, is_visible);
    end
    
elseif strcmp(action, 'changefile')
    %called when ts file changes.
    model = varargin{1};
    ircdata = varargin{2};
    
    th_plotphaseirc('newtheory', model);
    
elseif strcmp(action, 'newtheory')
    
    model = varargin{1};
    if nargin > 2
        %running theory on current file, not selecting a ne wfile
        ircdata = varargin{2};
    end
    
    if IsValid(model, ircdata)
        set(varHndl, 'string', model.vnames, 'value', 1);
        is_visible = strcmp(get(panel, 'Visible'), 'on');
        ChangeVar(1, ircdata, paramsHndl, peakNumHndl, is_visible);
        
        %fill in scale values mused for y axis/colourbar
        upper =ircdata.per;
        %should use max advance/delay instead??
        
        if upper >= 1
            sf=1;
            while upper > 10
                upper = upper/10;
                sf=sf*10;
            end
        else
            sf=1;
            while upper < 1
                upper = upper*10;
                sf=sf/10;
            end
        end
        %upper now between 1 and 10
        
        upper = ceil(upper)*sf;
        div=upper/10;
        
        scales = cell(0);
        scales{1} = 'auto';
        for i = div:div:upper
            scales{end+1} = num2str(i);
        end
        set(scaleHndl, 'string', scales, 'value', 1);
       
    else
        set(paramsHndl, 'data', {});
        set(scaleHndl, 'string', '...', 'value' ,1);
        set([peakNumHndl varHndl], 'string', '...');
    end
    
elseif strcmp(action, 'selall')
    
    tblData = get(paramsHndl, 'Data');
    tblData(:,1) = {true};
    set(paramsHndl, 'Data', tblData);

elseif strcmp(action, 'clearall')

    tblData = get(paramsHndl, 'Data');
    tblData(:,1) = {false};
    set(paramsHndl, 'Data', tblData);
    
elseif strcmp(action, 'plot')
    
    model = varargin{1};
    data = varargin{2};
    [p fname] = fileparts(data.myfile);
    
    %get parameters
    paramstoplot = [];
    params = get(paramsHndl, 'data');
    if isempty(params)
        ShowError('The selected variable has no phase IRC becasue its time series has no peaks. Please select a different variable.');
        return; 
    end
    
    for p = 1:size(params, 1)
        if params{p, 1}
            paramstoplot = [paramstoplot p];
        end
    end
    if isempty(paramstoplot)
        ShowError('You must select one or more parameters to plot');
        return;
    end
    %get variable
    vartoplot = get(varHndl, 'value');
    peaktoplot = get(peakNumHndl, 'value');
    str = get(peakNumHndl, 'string');
    if (peaktoplot > 1) && (peaktoplot == length(str))
        peaktoplot = str{peaktoplot}; % 'all
    end
    
    
    doplot(data, paramsHndl, paramstoplot, vartoplot, peaktoplot, scaleHndl, plotTypeHndl, fname, model.name);
    
elseif strcmp(action, 'set')
    return;
    %set control values from settings file read at startup
    idx = varargin{1};
    vals = varargin{2};
    
    psel = str2double(vals{idx});
    idx = idx + 1;
    pv = vals{idx};
    idx = idx + 1;
    iv = vals{idx};
    idx = idx + 1;
    so = str2double(vals{idx});
    idx = idx + 1;
    srt = str2double(vals{idx});
    idx = idx + 1;
    scl = str2double(vals{idx});
    idx = idx + 1;
    pt = str2double(vals{idx});
    idx = idx + 1;
    
    set(paramsHndl, 'value', psel);
    params = get(paramsHndl, 'data');
    for p = 1:size(params, 1)
        params{p, 1} = psel(p);
    end
    set(paramsHndl, 'data', params);
    
    set(peakValHndl, 'string', pv);
    set(intvalHndl, 'string', iv);
    set(scaleHndl, 'value', scl);
    set(plotTypeHndl, 'value', pt);
    
    %return index value for next panel
    r = idx;
elseif strcmp(action, 'save')
    return;
    %save control values to file
    %the order here must match the order they are loaded in, as above
    fp = varargin{1};
    p = get(paramsHndl, 'data');
    for i = 1:size(p, 1)
        if p{i, 1}
            fprintf(fp, '1 ');
        else
            fprintf(fp, '0 ');
        end
    end
    fprintf(fp, '\n');
    
    v = get(peakValHndl, 'string');
    fprintf(fp, '%f\n', v);
    v = get(intvalHndl, 'string');
    fprintf(fp, '%f\n', v);
    
    v =get(scaleHndl, 'value');
    fprintf(fp, '%d\n', v);
    
    v = get(plotTypeHndl, 'value');
    fprintf(fp, '%d\n', v);
    
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
        %can be false to suppress message at startup, or true when user
        %changes plot
        showMsg = varargin{3};
    else
        showMsg = true;
    end
    %messages
    if r
        if showMsg < 3
            %startup or user selects this plot type
            th_tippanel('write', 'You have selected to plot the infinitesimal response curves for variable phases (peak times).', 0);
            dataChangeMsg(peakNumHndl);
            typeChange(plotTypeHndl, []);
        elseif showMsg == 3
            %user selects a new file
            dataChangeMsg(peakNumHndl)
            typeChange(plotTypeHndl, []);
        else
            %theory run on current file
            dataChangeMsg(peakNumHndl)
            typeChange(plotTypeHndl, []);
        end
    
    else
        msg = 'Phase IRC plotting is not available ';
        if ~strcmp(model.orbit_type, 'oscillator')
            msg = [msg 'as the selected model is not an oscillator.'];
        elseif isempty(data)
            msg = [msg 'as the data cannot be found.'];
        elseif ~data.forced
            msg = [msg 'as the selected limit cycle is unforced.'];
        elseif ~isfield(data, 'theory')
            msg = [msg 'as derivatives have not been calculated for the selected file.'];
        end
        th_tippanel('write', msg,  2);
    end
end

%==========================================================================

function doplot(data, paramsHndl, paramstoplot, vartoplot, peaktoplot, scaleHndl, plotTypeHndl, fname, modelname)

global phase_plot_styles;
global plot_font_size

%find order in which rows of table are displayed
tblData = get(paramsHndl, 'Data');
sorted_idx = (1:size(tblData,1))';

%extract required data
if ischar(peaktoplot)
    %all
    ircphi = data.theory.ircphi{vartoplot};
    peaktime = data.peaks{vartoplot};
    ircs = cell(length(peaktime), 1);
    bs = cell(length(peaktime), 1);
    for p = 1:length(peaktime)
        %remove unwanted params
        ircs{p} = ircphi{p}.data(:, paramstoplot);
        bs{p}.y = ircphi{p}.bs.y(paramstoplot);
        bs{p}.t = ircphi{p}.bs.t;
    end
    ircphi = ircphi{end};
    %title
    tstr = [data.vnames{vartoplot} ' Phase Infinitesimal Response Curve of all peaks'];
else
    ircphi = data.theory.ircphi{vartoplot}{peaktoplot};
    peaktime = data.peaks{vartoplot}(peaktoplot);
    ircs = ircphi.data(:, paramstoplot);
    bs.y = ircphi.bs.y(paramstoplot);
    bs.t = ircphi.bs.t;
    %title
    tstr = [data.vnames{vartoplot} ' Phase Infinitesimal Response Curve'];
    if length(data.theory.ircphi{vartoplot}) > 1
        tstr = [tstr ' of peak ' num2str(peaktoplot)];
    end
end

integrals = ircphi.integrals(paramstoplot);
maxAdvances = ircphi.maxAdvances(paramstoplot);
maxDelays = ircphi.maxDelays(paramstoplot);

tspan = data.theory.ircphi_t; %data.sol.x;
par = data.par(paramstoplot);
parn = data.parn(paramstoplot);
pdesc = data.parnames(paramstoplot);
for p = 1:length(parn)
    pdesc{p} = [parn{p} ', ' pdesc{p}];
end

%parameters
plottype = get(plotTypeHndl, 'value'); plotnames = get(plotTypeHndl, 'string');
plottype = plotnames{plottype};
s = get(scaleHndl, 'Value');
str = get(scaleHndl, 'String');


if s==1
   %auto scaling
   ColourRange = max([maxAdvances abs(maxDelays)]);
   if ColourRange == 0 %no selected param has any phase change
       ColourRange = str2double(str{2});
   end
else
    ColourRange = str2double(str{s});
end


if ~strcmp(plottype, 'Single line plot')
    %sort them to get the order they appear in table if doing seperate
    %plot
    %sorted_idx(n) is the position in the sorrted table of the nth parameter of the unsorted list, ie the order in data.par
    selected_sorted_idx = [];
    for p = paramstoplot
        %p is position in unsorted table that a selected paramerer sppears
        %at. Find its index in the current, possibly sorted table
        selected_sorted_idx = [selected_sorted_idx sorted_idx(p)];
    end
    %sort selections to thi sorder
    [~, new_idx] = sort(selected_sorted_idx);
    integrals = integrals(new_idx);
    maxAdvances = maxAdvances(new_idx);
    maxDelays = maxDelays(new_idx);
    
    if iscell(ircs)
        for p = 1:length(ircs)
            ircs{p} = ircs{p}(:,new_idx);
            bs{p}.y =  bs{p}.y(new_idx);
        end
    else
        ircs = ircs(:,new_idx);
        bs.y =  bs.y(new_idx);
    end
    par = par(new_idx);
    parn = parn(new_idx);
    pdesc = pdesc(new_idx);
    
end


unscaled_ircs = ircs;

%color map for heat maps
if strcmp(plottype, 'Heat map')
    cmap = colormap;
    cmap_max=size(cmap,1);%probably 64
    if iscell(ircs)
        for p = 1:length(ircs)
            %we want all elements of irc to be on a scale defined by colourrange
            ircs{p} = ircs{p} * (cmap_max/2) / ColourRange;
            %shift data so that 0 appears in centre of colourmap
            ircs{p} = ircs{p} + cmap_max/2;
            %colourange cant be > cmp_max/2
        end
    else
        %we want all elements of irc to be on a scale defined by colourrange
        ircs = ircs * (cmap_max/2) / ColourRange;
        %shift data so that 0 appears in centre of colourmap
        ircs = ircs + cmap_max/2;
        %colourange cant be > cmp_max/2
    end
end

%create figure
%size it in cm and centre it on screen
pos = get_size_of_figure('cm');
newfig = figure('NumberTitle', 'off', 'Units', 'centimeters', 'Position', pos, 'Color', [1 1 1]);
figwidth = pos(3);figheight = pos(4);

%determine size and position of plots
ptop = figheight-1.5;
pbottom = 0.5;
pleft= 3;
pwidth = figwidth-9;
numplots = length(paramstoplot)+1; % plus one for LD

if ~strcmp(plottype, 'Single line plot')
    numlines = 5 * numplots + 4;
    lineheight = (ptop - pbottom)/numlines;
    sep = lineheight;   %gap between plots
    vwidth = 4 * sep;   %height of each plot
    nexttop = ptop - vwidth;
    %headings
    uicontrol('String', 'Range', 'FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 10, 'Style', 'text','Units','centimeters','position',[(pleft+pwidth)+1.5 ptop 1.5 0.5], 'HorizontalAlignment', 'left', 'BackgroundColor', get(gcf, 'Color'));
    uicontrol('String', 'Phase Ch', 'FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 10, 'Style', 'text','Units','centimeters','position',[(pleft+pwidth)+3 ptop 4 0.5],'HorizontalAlignment', 'left', 'BackgroundColor', get(gcf, 'Color'));
else
    vwidth = 1.5;   %will be height of the time series plot at bottom
    sep = 0.5;
    nexttop = vwidth+3*sep;
end

%phase_plot_styles = {'k-', 'b-', 'r-', 'g-', 'c-', 'm-', 'k:', 'b:', 'r:', 'g:', 'c:', 'm:', 'k--', 'b--', 'r--', 'g--', 'c--', 'm--'};


%plot the ircs
count=1;h=[];
uicontrol('String', tstr, 'FontUnits', 'points', 'FontSize', plot_font_size, 'Style', 'text','Units','centimeters','position',[pleft ptop+0.5 pwidth 0.5], 'HorizontalAlignment', 'center', 'BackgroundColor', get(gcf, 'Color'));

for i = 1:numplots-1
    
    if strcmp(plottype, 'Heat map')
        if iscell(ircs)
            divider = sep/length(ircs); %space between subplots (same var, different peak)
            subplot_height = (vwidth-divider*(length(ircs)-1))/length(ircs);
            axlower = nexttop + vwidth - subplot_height;
            for p = 1:length(ircs)
                axpos = [pleft,axlower,pwidth,subplot_height];
                Y = ircs{p}(:,i);
                unscaled_Y = unscaled_ircs{p}(:,i);
                bsplot.y = bs{p}.y(i);
                bsplot.t = bs{p}.t;
                h(count)=axes('units', 'centimeters', 'Position',axpos);
                
                image(tspan,[],Y','ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(p)], unscaled_Y, tspan, bsplot});
                xlim([tspan(1) tspan(end)]);
                %mark time of discontinuity
                pos = [(pleft + (bsplot.t/tspan(end) * pwidth)) axlower 0.05 subplot_height];
                uicontrol('Units','centimeters', 'Style', 'text', 'String', '', 'BackgroundColor', 'k', 'Position', pos);

                axlower = axlower - (subplot_height+divider);
                count=count+1;
            end
            
        else
            axpos = [pleft,nexttop,pwidth,vwidth];
            Y = ircs(:,i);
            unscaled_Y = unscaled_ircs(:,i);
            bsplot.y = bs.y(i);
            bsplot.t=bs.t;
            h(count)=axes('units', 'centimeters', 'Position',axpos);
            image(tspan,[],Y','ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(peaktoplot)], unscaled_Y, tspan, bsplot});
            xlim([tspan(1) tspan(end)]);
            %mark time of discontinuity
            pos = [(pleft + (bsplot.t/tspan(end) * pwidth)) nexttop 0.05 vwidth];
            uicontrol('Units','centimeters', 'Style', 'text', 'String', '', 'BackgroundColor', 'k', 'Position', pos);
            
            count=count+1;
        end
    elseif strcmp(plottype, 'Line plots')

        legend_str = cell(0);
        if iscell(ircs)
            Y = [];
            unscaled_Y = [];
            bsplot = [];
            plottitle = [pdesc{i} ', all peaks'];
            for p = 1:length(ircs)
                Y = [Y ircs{p}(:,i)];
                unscaled_Y = [unscaled_Y unscaled_ircs{p}(:,i)];
                bstmp.y = bs{p}.y(i);
                bstmp.t = bs{p}.t;
                bsplot = [bsplot bstmp];
                legend_str{end+1} = ['Peak ' num2str(p)];
            end
        else   %these are the same for line plots
            Y = ircs(:,i);
            unscaled_Y = unscaled_ircs(:,i);
            bsplot.y = bs.y(i);
            bsplot.t = bs.t;
            plottitle = [pdesc{i} ', peak ' num2str(peaktoplot)];
        end
        h(count)=axes('units', 'centimeters','Position',[pleft,nexttop,pwidth,vwidth], 'ButtonDownFcn', @th_plotircdata, 'UserData', {plottitle, unscaled_Y, tspan, bsplot} );
        hold on;
        for p = 1:size(Y,2)
            %plot style and legend for each peak of parameter i
            if size(Y,2) > 1
                linetitle = [pdesc{i} ', peak ' num2str(p)];
            else
                linetitle = [pdesc{i} ', peak ' num2str(peaktoplot)];
            end
            ls = get_plot_style(p);
            
            %bs point is a discontinuity in the irc. plot seperate curves
            %for before and after this point
            bs_idx = find(tspan == bsplot(p).t);
            %create plot with 2 y axes
            x1 = tspan(1:bs_idx-1); y1 = Y(1:bs_idx-1,p)'; %first part of irc,on primary y axis
            x2 = bsplot(p).t; y2 = bsplot(p).y; %bs point will go on secondary y axis
            [ax, series1, series2] = plotyy(x1, y1, x2, y2, 'plot');
            set(series1, 'Color', ls(1), 'Linestyle', ls(2:end), 'LineWidth', 2, 'ButtonDownFcn', @th_plotircdata, 'UserData', {linetitle, unscaled_Y(:,p), tspan, bsplot(p), p});
            %mark bs with a circle the same color as line
            set(series2, 'Marker', 'o', 'MarkerFaceColor', ls(1), 'MarkerEdgeColor', ls(1), 'LineStyle', 'none', 'ButtonDownFcn', @th_plotircdata, 'UserData', {linetitle, unscaled_Y(:,p), tspan, bsplot(p), p});
            %don't show in legend
            set(get(get(series2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            
            hold on;
            %add second part of irc, after time of bs point, excluding it
            %from legend
            series3 = plot(ax(1), tspan(bs_idx:end),Y(bs_idx:end,p)',ls, 'LineWidth', 2, 'ButtonDownFcn', @th_plotircdata, 'UserData', {linetitle, unscaled_Y(:,p), tspan, bsplot(p), p});
            set(get(get(series3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            %join 2 parts of irc with dotted , interpolated to give 10 points
            join_t = [tspan(bs_idx-1) tspan(bs_idx)];
            join_t = [join_t(1):diff(join_t)/10:join_t(2)];
            join_y = interp1(tspan(bs_idx-1:bs_idx), Y(bs_idx-1:bs_idx,p), join_t);
            series4 = plot(ax(1), join_t,join_y,[ls(1) ':'],  'LineWidth', 1, 'ButtonDownFcn', @th_plotircdata, 'UserData', {linetitle, unscaled_Y(:,p), tspan, bsplot(p), p});
            set(get(get(series4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            %ensure point is at correct time by matching x axes
            xlim(ax(1), [tspan(1) tspan(end)]);
            xlim(ax(2), [tspan(1) tspan(end)]);
            
            %y labels
            set(get(ax(1),'Ylabel'),'String','\Delta\phi', 'FontSize', plot_font_size)
            if p == 1
                set(get(ax(2),'Ylabel'),'String','bs', 'FontSize', plot_font_size)
            end
            set(ax, 'YTickMode', 'auto');
            set(ax, 'xtick', []);
            set(ax, 'XTickLabel',{''});
            if p > 1
                set(ax(2), 'ytick', []);
                set(ax(2), 'YTickLabel',{''}); 
            end
            hold on;
        end
        if ~isempty(legend_str) && i == (numplots-1)
            hl=legend(h(count), legend_str);
            
        end
        %the ax(1) returned by each call to plotyy will be this handle
        ylim(h(count), [-ColourRange ColourRange]);
        
        %xlim([tspan(1) tspan(end)]);
        hold off
        count=count+1;
    else
        %one plot for each peak/all params
        %colours and legend names
        
        ps = get_plot_style(i);
        if iscell(ircs)
            %create on set of axes for each peak
            axheight = ((figheight-nexttop-2.5)-(sep*(length(ircs)-1)))/length(ircs);
            axlower = figheight-1.5-axheight;
            for p=1:length(ircs)    %scaled and unscaled the same for line plots
                if i == 1  %create axes for each peak
                    h(p) = axes('units', 'centimeters','Position',[pleft,axlower,pwidth,axheight]);
                    axlower = axlower-(axheight+sep);
                end
                Y = ircs{p}(:,i);
                unscaled_Y =  unscaled_ircs{p}(:,i);
                bsplot.y = bs{p}.y(i);
                bsplot.t = bs{p}.t;
                %this point is a discontinuity in the irc. plot seperate curves
                %for before and after this point
                bs_idx = find(tspan == bsplot.t);
                %create plot with 2 y axes
                x1 = tspan(1:bs_idx-1); y1 = Y(1:bs_idx-1)'; %first part of irc,on primary y axis
                x2 = bsplot.t; y2 = bsplot.y; %bs point will go on secondary y axis
                [ax, series1, series2] = plotyy(h(p), x1, y1, x2, y2, 'plot');
                secondary_y{p}(i) = ax(2);
                set(series1, 'Color', ps(1), 'Linestyle', ps(2:end), 'LineWidth', 2, 'ButtonDownFcn', @th_plotircdata, 'UserData',  {[pdesc{i} ' , Peak ' num2str(p)], unscaled_Y, tspan, bsplot, i});
                %mark bs with a circle the same color as line
                set(series2, 'Marker', 'o', 'MarkerFaceColor', ps(1), 'MarkerEdgeColor', ps(1), 'LineStyle', 'none', 'ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(peaktoplot)], unscaled_Y, tspan, bsplot, i});
                %don't show in legend
                set(get(get(series2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                
                hold on;
                %add second part of irc, after time of bs point, excluding it
                %from legend
                series3 = plot(ax(1), tspan(bs_idx:end),Y(bs_idx:end)',ps, 'LineWidth', 2, 'ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(p)], unscaled_Y, tspan, bsplot, i});
                set(get(get(series3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                %join 2 parts of irc with dotted , interpolated to give 10 points
                join_t = [tspan(bs_idx-1) tspan(bs_idx)];
                join_t = [join_t(1):diff(join_t)/10:join_t(2)];
                join_y = interp1(tspan(bs_idx-1:bs_idx), Y(bs_idx-1:bs_idx), join_t);
                series4 = plot(ax(1), join_t,join_y,[ps(1) ':'], 'LineWidth', 1, 'ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(p)], unscaled_Y, tspan, bsplot, i});
                set(get(get(series4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                
                %y labels
                set(get(ax(1),'Ylabel'),'String','\Delta\phi', 'FontSize', plot_font_size)
                ylim(ax(1), [-ColourRange ColourRange]);
                set(ax(1), 'YTickMode', 'auto', 'ygrid', 'on');
                
                %ensure point is at correct time by matching x axes
                xlim(ax(1), [tspan(1) tspan(end)]);
                xlim(ax(2), [tspan(1) tspan(end)]);
                set(ax, 'XTick' ,[floor(tspan(1)):3:floor(tspan(end))]);
                set(ax, 'XTickLabel',{''});
                
                if i == (numplots-1)
                    %set all seconday y axes on each plot to same scale
                    set(get(secondary_y{p}(1),'Ylabel'),'String','bs', 'FontSize', plot_font_size);
                    ylims = [];
                    for axnum = 1:length(secondary_y{p})
                        ylims = [ylims; get(secondary_y{p}(axnum), 'ylim')];
                    end
                    set(secondary_y{p}, 'ylim', [min(ylims(:,1)) max(ylims(:,2))]);
                    set(secondary_y{p}, 'YTickMode', 'auto');
                    set(secondary_y{p}(2:end), 'ytick', []);
                    set(secondary_y{p}(2:end), 'YTickLabel',{''});
                    
                    %label axis with peak number
                    pos =  get(secondary_y{p}(1), 'position');
                    pos = [(pos(1) + pos(3) -2) (pos(2) + pos(4) - 0.5) 2 0.5];
                    uicontrol('String', ['Peak ' num2str(p)], 'FontUnits', 'points', 'FontSize', plot_font_size, 'Style', 'text','Units','centimeters','position', pos, 'BackgroundColor', 'w');
                end
                
            end
        else
            %In this mode plotyy is used to create multiple plots on the
            %same seconday y axis. This results in lots of different axes
            %being overlaid rather than just one re-used like for the
            %primary axis. Therefore need to keep a list of all seconday
            %axes and scale them all the same at the end

            if i == 1 
                %first time series, so create the single axes
                h = axes('units', 'centimeters','Position',[pleft,nexttop+1,pwidth,figheight-nexttop-2.5]);
            end
            Y = ircs(:,i);
            unscaled_Y =  unscaled_ircs(:,i);
            bsplot.y = bs.y(i);
            bsplot.t = bs.t;
            %this point is a discontinuity in the irc. plot seperate curves
            %for before and after this point
            bs_idx = find(tspan == bsplot.t);
            %create plot with 2 y axes
            x1 = tspan(1:bs_idx-1); y1 = Y(1:bs_idx-1)'; %first part of irc,on primary y axis
            x2 = bsplot.t; y2 = bsplot.y; %bs point will go on secondary y axis
            [ax, series1, series2] = plotyy(x1, y1, x2, y2, 'plot');
            secondary_y(i) = ax(2);
            set(series1, 'Color', ps(1), 'Linestyle', ps(2:end), 'LineWidth', 2, 'ButtonDownFcn', @th_plotircdata, 'UserData',  {[pdesc{i} ' , Peak ' num2str(peaktoplot)], unscaled_Y, tspan, bsplot, i});
            %mark bs with a circle the same color as line
            set(series2, 'Marker', 'o', 'MarkerFaceColor', ps(1), 'MarkerEdgeColor', ps(1), 'LineStyle', 'none', 'ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(peaktoplot)], unscaled_Y, tspan, bsplot, i});
            %don't show in legend
            set(get(get(series2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            
            hold on;
            %add second part of irc, after time of bs point, excluding it
            %from legend
            series3 = plot(ax(1), tspan(bs_idx:end),Y(bs_idx:end)',ps, 'LineWidth', 2, 'ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(peaktoplot)], unscaled_Y, tspan, bsplot, i});
            set(get(get(series3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            %join 2 parts of irc with dotted , interpolated to give 10 points
            join_t = [tspan(bs_idx-1) tspan(bs_idx)];
            join_t = [join_t(1):diff(join_t)/10:join_t(2)];
            join_y = interp1(tspan(bs_idx-1:bs_idx), Y(bs_idx-1:bs_idx), join_t);
            series4 = plot(ax(1), join_t,join_y,[ps(1) ':'], 'LineWidth', 1, 'ButtonDownFcn', @th_plotircdata, 'UserData', {[pdesc{i} ' , Peak ' num2str(peaktoplot)], unscaled_Y, tspan, bsplot, i});
            set(get(get(series4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

            %y labels
            set(get(ax(1),'Ylabel'),'String','\Delta\phi', 'FontSize', plot_font_size)
            ylim(ax(1), [-ColourRange ColourRange]);
            set(ax(1), 'YTickMode', 'auto', 'ygrid', 'on');
            
            %ensure point is at correct time by matching x axes
            xlim(ax(1), [tspan(1) tspan(end)]);
            xlim(ax(2), [tspan(1) tspan(end)]);
            set(ax, 'XTick' ,[floor(tspan(1)):3:floor(tspan(end))]);
            set(ax, 'XTickLabel',{''});
            if i == (numplots-1)
                %set all seconday y axes to same scale
                set(get(secondary_y(1),'Ylabel'),'String','bs', 'FontSize', plot_font_size);
                ylims = [];
                for axnum = 1:length(secondary_y)
                    ylims = [ylims; get(secondary_y(axnum), 'ylim')];
                end
                set(secondary_y, 'ylim', [min(ylims(:,1)) max(ylims(:,2))]);
                set(secondary_y, 'YTickMode', 'auto');
                set(secondary_y(2:end), 'ytick', []);
                set(secondary_y(2:end), 'YTickLabel',{''});
            end
        end
        if i == (numplots-1)
            %add legend when reaching the last series
            hl = legend(h(1), parn);
            set(hl,'Units','centimeters','Position',[pleft+pwidth+1.5 nexttop+1 4 figheight-nexttop-2.5]);
            hold off
        end
        count=count+1;
    end
    if ~strcmp(plottype, 'Single line plot')
        pos = [0.25 (2*nexttop+vwidth)/2-0.25 0.75 0.5];
        uicontrol('HorizontalAlignment', 'left','FontUnits', 'points', 'TooltipString',pdesc{i}, 'Style', 'text','Units','centimeters','Position',pos,'FontSize',10,'String',parn{i},'ButtonDownFcn', str,'BackgroundColor', get(gcf, 'Color'));
        unscaledmin = sprintf('%4.1f', maxDelays(i));
        unscaledmax = sprintf('%4.1f', maxAdvances(i));
        scale = [unscaledmin, '-', unscaledmax];
        pos = [(pleft+pwidth)+1.5 (2*nexttop+vwidth)/2-0.25 1.5 0.5];
        k2=uicontrol('HorizontalAlignment', 'left','FontUnits', 'points', 'TooltipString', scale, 'Style', 'text','Units','centimeters','Position',pos,'FontSize',10,'String',scale,'ButtonDownFcn', str,'BackgroundColor', get(gcf, 'Color'));
        pos = [(pleft+pwidth)+3 (2*nexttop+vwidth)/2-0.25 1.5 0.5];
        ci = num2str(integrals(i), '%4.1f');
        k3=uicontrol('FontUnits', 'points', 'TooltipString', ci, 'Style', 'text','Units','centimeters','Position',pos,'FontSize',10,'String',ci,'ButtonDownFcn', str,'BackgroundColor', get(gcf, 'Color'));
        
        nexttop=nexttop-vwidth-sep;
    end
end

if strcmp(plottype, 'Heat map')
    set(h(count-1),'Box','off');
    set(h(count-1),'YTickLabel',[]);
    set(h(1:count-1),'Visible','off');
elseif strcmp(plottype, 'Single line plot')
    nexttop=1.5;
end

%plot the time series to givea phase reference

hld = axes('units', 'centimeters', 'Position',[pleft,nexttop,pwidth,vwidth], 'Color', 'none');

yvals = data.sol.y(:,vartoplot);
tspan = data.sol.x;
plot(hld, tspan, yvals, 'r', 'LineWidth', 2);
%ymax = max(data.sol.y(:, data.varnum));
hold on;
%mark the peak(s)
for p = 1:length(peaktime)
    peaksize = interp1(tspan, yvals, peaktime(p));
    plot(hld, peaktime(p), peaksize, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerSize', 8);
    hold on;
end

force = data.force/max(data.force);
force = force * max(yvals);
plot(hld, tspan, force, 'b', 'LineWidth', 2);
hold off;
set(hld,'Box','off');
set(hld,'YTickLabel',[], 'YTick',[]);
set(get(hld,'XLabel'),'String',['Phase of variable ' data.vnames{vartoplot} ', plus external force'], 'FontSize', 12);
%ymax = max(data.force);
%set(get(hld,'XLabel'),'String','External force');

xlim([tspan(1) tspan(end)]);
axlen = floor(tspan(end))- floor(tspan(1));
h = (axlen-mod(axlen,10)) / 10;
set(hld, 'XTick' ,[floor(tspan(1)):h:floor(tspan(end))]);

%ylim([0 ymax])
pos = [0.5 nexttop 1.5 0.5];
%uicontrol('HorizontalAlignment', 'left','FontUnits', 'points', 'TooltipString', 'Phase', 'Style', 'text','Units','centimeters','Position',pos,'FontSize',10,'String','Phase','BackgroundColor', get(gcf, 'Color'));


%colour bar for heat maps
if strcmp(plottype, 'Heat map')
    h_all = axes('units', 'centimeters', 'Position',[0.5 nexttop figwidth-2 ptop-nexttop],'Visible','off');
    set(gcf,'CurrentAxes',h_all)
    cb = colorbar('FontUnits', 'points', 'fontsize', 12 ,'YTickMode', 'manual', 'YTickLabelMode', 'manual','YTickLabel', [],'YTick', []);
    
    %place tickmarks
    %get num sig figs for labels
    div=ColourRange/10;
    tmp = div;
    
    sf=0;
    if tmp >= 1;
        sig_figs = 0;
    else
        while tmp < 1
            tmp = tmp*10;
            sf=sf+1;
        end
        sig_figs = sf;
    end
    
    %upper now between 1 and 10
    % ColourRange = ceil(ColourRange)*sf;
    
    realticks=[-ColourRange:div:ColourRange];
    
    %     if ColourRange < 12
    %         realticks = [-ColourRange:0.5:ColourRange];
    %     elseif ColourRange < 18
    %         realticks = [-ColourRange:1:ColourRange];
    %     else
    %         realticks = [-ColourRange:2:ColourRange];
    %     end
    %make sure same number of actual ticks in correct places
    yticks = [];
    for i = 1:length(realticks)
        yticks = [yticks; (realticks(i) + ColourRange) * (cmap_max/(2*ColourRange))];
    end
    set(cb, 'YTickLabel', []);
    set(cb, 'YTick', []);
    set(cb, 'YTick', yticks);
    ylabels = cell(length(yticks),1);
    for i =1:size(ylabels,1)
        ylabels{i} = num2str(realticks(i), ['%4.' num2str(sig_figs) 'f']);%problem with dp
    end
    
    set(cb, 'YTickLabel', ylabels);
    text('FontUnits', 'points','Position',[1.14 0.6],'FontSize',10,'String','Phase Advance', 'Rotation', 90);
    text('FontUnits', 'points','Position',[1.14 0.25],'FontSize',10,'String','Phase Delay', 'Rotation', 90);
    
end

%labels
set(newfig, 'name', [tstr ' from ' modelname ', ' fname]);


%=========================================================================

function  v = IsValid(mdl, ts, showMsg)

%to be a valid plot type, model must be oscillator,
%time series must be forced and theoretical analysis must
%have been done.

%reason is the cause of this function being called. It can be
%a) this plot type selected by user
%b) new ts file selected
%c) theoretical data added to current file

v = ~isempty(mdl) && strcmp(mdl.orbit_type, 'oscillator') && ~isempty(ts) &&  ts.forced && isfield(ts, 'theory') && isfield(ts.theory, 'ircphi');

%=========================================================================

function typeChange(src, evnt)

str = get(src, 'string');
i = get(src, 'value');
msg = [];

switch str{i}
    case 'Heat maps'
        msg = 'You have opted to plot each parameter as a heat map where colour represents phase change';
    case 'Line plots'
        msg = 'You have opted to plot each parameter on a separate XY plot';
    case 'Single line plot'
        msg = 'You nave opted to plot all paramaters on a single XY plot';
end

if ~isempty(msg)
    th_tippanel('clear_highlight');
    th_tippanel('write', msg, 1);
end


%=========================================================================

function  FillParamsTable(hTable, results, irc)

%called only by ChangePeak

user_data = get(hTable, 'Userdata');

if isempty(irc)
    set(hTable, 'data', {});
else
    tblData =  get(hTable, 'data');
    if ~isempty(tblData) && strcmp(user_data.model, results.name);
        %check that we haven't just changed the model. Ignore previous
        %selections if we have.
        sel = cell2mat(tblData(:,1));
    else
        sel = zeros(1, length(results.parn));
    end
    maxAdvances = irc.maxAdvances;
    maxDelays = irc.maxDelays;
    integrals = irc.integrals;
    %values are sorted as text
    maxAdvancesTxt = createSortableColumn(maxAdvances);
    maxDelaysTxt = createSortableColumn(maxDelays);
    integralsTxt = createSortableColumn(integrals);
    
    params = cell(length(results.parn), 5);
    for p = 1:length(results.parn)
        if sel(p)
            params(p, :) = {true ['<html><pre>' results.parn{p} ', ' results.parnames{p}] maxAdvancesTxt{p} maxDelaysTxt{p} integralsTxt{p}};
        else
            params(p, :) = {false ['<html><pre>' results.parn{p} ', ' results.parnames{p}] maxAdvancesTxt{p} maxDelaysTxt{p} integralsTxt{p}};
        end
    end

    user_data.model = results.name;
    set(hTable, 'data', params, 'UserData', user_data);
    
    %sorting resets on data change with native MATLAB uitable
end

 

%=========================================================================

function ChangeVar(varnum, results, paramsTable, peakNumHndl, is_visible)

%retrieve data for selected var
%called in response to user changing variable
%called when new results file selected
%called when theory run on current file

if isfield(results, 'theory') && isfield(results.theory, 'ircphi')
    numpeaks = length(results.theory.ircphi{varnum});
    
    if numpeaks > 0
        if numpeaks > 1
            %will have extra entry for 'all peaks'
            numpeaks = numpeaks-1;
        end
        str = cell(0);
        for p = 1:numpeaks
            str{p} = ['peak ' num2str(p)];
        end
        if numpeaks > 1
            str{end+1} = 'all';
        end
    else
        str = {'NA'};    %variable with no peak in its time series
    end
    set(peakNumHndl, 'string', str, 'value', 1);
    %peak 1 by default
end
ChangePeak(peakNumHndl, results, paramsTable, varnum, is_visible)


%=========================================================================

function ChangePeak(peakNumHndl, results, paramsTable, varnum, is_visible)

%called in response to user action only or when above called. This is when
%user select a new variable, or a new file, or runs theory.
try
    irc = results.theory.ircphi{varnum};
    pk = get(peakNumHndl, 'value');
    ps = get(peakNumHndl, 'string');
    if strcmp(ps{pk}, 'NA')
        irc = [];
    elseif strcmp(ps{pk}, 'all')
        irc = irc{end};
    else
        irc = irc{pk};
    end
    if is_visible
        dataChangeMsg(peakNumHndl);
    end
    
catch err
    irc =  [];
end

FillParamsTable(paramsTable, results, irc)




%==========================================================================

function dataChangeMsg(peakNumHndl)

%called by ChangePeak() to display messages when 

pk = get(peakNumHndl, 'value');
ps = get(peakNumHndl, 'string');
if ~strcmp(ps{pk}, 'all')
    if length(ps) > 1
        th_tippanel('write', ['You are currently viewing data for peak number ' num2str(pk) ' only in the time series for this multiphasic variable.'],1);
    else
        th_tippanel('write', 'You are currently viewing data for peak in the time series for this monophasic variable.', 1);
    end
else
    th_tippanel('write', 'You are currently viewing data for all peaks found in the time series for this multiphasic variable. Maximum advances and delays are the maxima across all peaks. Integrals are summed across all peaks.', 1);
end



