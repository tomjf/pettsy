function r = th_plotirc(action, varargin)

persistent paramsHndl selpeakHndl peakValHndl selintHndl intvalHndl selAlltHndl clearAlltHndl
persistent plotTypeHndl scaleHndl panel table_is_formatted
    
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
    
    %parameters to choose
    uicontrol('horizontalalignment', 'left', 'Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 (pwidth-1) 0.5],'string','Select parameters','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);

     %select/deselect all
    selAlltHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[4 pheight-1.5 (pwidth-4.5)/2 0.6], ...
        'Parent',panel, ...
        'string', 'Select all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Select all parameters', ...
        'Callback','th_plotirc(''selall'');');
    clearAlltHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[4+(pwidth-4.5)/2 pheight-1.5 (pwidth-4.5)/2 0.6], ...
        'Parent',panel, ...
        'string', 'Clear all', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Clear selections', ...
        'Callback','th_plotirc(''clearall'');');
    
    paramsHndl = uitable('units', 'centimeters','position', [0.5 1.5 (pwidth-1) pheight-3.6], ...
        'columneditable', [true false  false false false], ...
        'columnname', {'', 'Param', 'Max Adv', 'Max Del', 'Int'}, ...
        'rowname', {},  'rowstriping', 'off', 'backgroundcolor', [1 1 1], ...
        'fontunits', 'points', 'fontsize', 10, ...
        'parent', panel);
    set(paramsHndl, 'units', 'pixels')
    tblwidth = get(paramsHndl, 'position');
    colwidth = (tblwidth(3)-30)/4;
    set(paramsHndl, 'columnwidth', {25 colwidth colwidth colwidth  colwidth});

    

    %scaling
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 0.5 1.25 0.5],'string','Scale:','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
    scaleHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[2 0.6 pwidth/2-3.5 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', '.', ...
        'tooltipstring', 'This represents the range of values covered by the colour map, or the length of the Y axis', ...
        'Value', 1);
   
      uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2-1.25 0.5 3 0.5],'string','Select plot type:','BackgroundColor', maincol, 'FontUnits', 'points', 'FontSize', 10);
      plotTypeHndl=uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[pwidth/2+1.5 0.6 pwidth/2-1.8 0.5], ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', {'Heat maps' 'Line plots' 'Single line plot'}, ...
        'callback', @typeChange, ...
        'tooltipstring', 'Plot parameters as heatmaps or XY plots', ...
        'Value', 1);
    
    table_is_formatted = false;

    r = panel;
    
elseif strcmp(action, 'name')
    
    r  = 'Infinitesimal Response Curve';
    
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
    
    r = 'Plots the infinitesimal response curves of the parameters of a limit cycle. These can be displayed as heat maps or line plots. The final plot provides a reference to the phase of the limit cycle.';

elseif strcmp(action, 'changefile')
    %called when ts file changes.
    model = varargin{1};
    data = varargin{2};

   th_plotirc('newtheory', model, data);
   
elseif strcmp(action, 'newtheory')  
   
   model = varargin{1};
   data = varargin{2};

   if IsValid(model, data)
       
       FillParamsTable(paramsHndl, data);
       
        %fill in scale values mused for y axis/colourbar
          %fill in scale values mused for y axis/colourbar
       upper =data.per;
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
   toplot = [];
   params = get(paramsHndl, 'data');
   for p = 1:size(params, 1)
      if params{p, 1}
          toplot = [toplot p];
      end
   end
   if isempty(toplot)
      ShowError('You must select one or more parameters to plot');
      return; 
   end
   
   doplot(data, toplot, paramsHndl, scaleHndl, plotTypeHndl, fname, model.name);
    
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
    set(sortOrderHndl, 'value', so);
    set(sortHndl, 'value', srt);
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
    
    v =get(sortOrderHndl, 'value');
    fprintf(fp, '%d\n', v);
    v =get(sortHndl, 'value');
    fprintf(fp, '%d\n', v);
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
        %can be false to suppress message at startup
        showMsg = varargin{3};
    else
        showMsg = true;
    end
    
   
     if r
         if showMsg
             th_tippanel('write', 'You have selected to plot the infinitesimal response curve data from the selected time series', 0);
             typeChange(plotTypeHndl, []);
         end
     else
         msg = 'IRC plotting is not available ';
         if ~strcmp(model.orbit_type, 'oscillator')
             msg = [msg 'as the selected model is not an oscillator.'];
         elseif isempty(data)
             msg = [msg 'as the data cannot be found.'];
         elseif data.forced
             msg = [msg 'as the period of the selected limit cycle is fixed by a periodic external force.'];
         elseif ~isfield(data, 'theory')
             msg = [msg 'as derivatives have not been calculated for the selected file.'];
         end
         
         th_tippanel('write', msg,  2);
    end

end

%==========================================================================

function doplot(data, toplot, paramsHndl, scaleHndl, plotTypeHndl, fname, modelname)

%global phase_plot_styles;
global plot_font_size

%find order in which rows of table are displayed
tblData = get(paramsHndl, 'Data');
sorted_idx = (1:size(tblData,1))';

%extract required data
ircs = data.theory.irc.data(:, toplot);
tspan = data.sol.x;
par = data.par(toplot);
parn = data.parn(toplot);
pdesc = data.parnames(toplot);
for p = 1:length(parn)
    pdesc{p} = [parn{p} ', ' pdesc{p}];
end
integrals = data.theory.irc.integrals(toplot);
maxAdvances = data.theory.irc.maxAdvances(toplot);
maxDelays = data.theory.irc.maxDelays(toplot);

%sort them to get the order they appear in table
%sorted_idx(n) is the position in the sorrted table of the nth parameter of the unsorted list, ie the order in data.par
selected_sorted_idx = [];
for p = toplot
    %p is position in unsorted table that a selected paramerer sppears
    %at. Find its index in the current, possibly sorted table
    selected_sorted_idx = [selected_sorted_idx sorted_idx(p)];
end
%sort selections to thi sorder
[~, new_idx] = sort(selected_sorted_idx);
maxAdvances = maxAdvances(new_idx);
integrals = integrals(new_idx);
maxDelays = maxDelays(new_idx);
ircs = ircs(:,new_idx);
par = par(new_idx);
parn = parn(new_idx);
pdesc = pdesc(new_idx);
            

plottype = get(plotTypeHndl, 'value');
s = get(scaleHndl, 'Value');
str = get(scaleHndl, 'String');
if s==1
   %auto scaling
   ColourRange = max([maxAdvances; abs(maxDelays)]);
   if ColourRange == 0 %no selected param has any phase change
       ColourRange = str2double(str{2});
   end
else
    ColourRange = str2double(str{s});
end
tstr = 'Infinitesimal Response Curve';

unscaled_ircs = ircs;

%color map for heat maps
if plottype == 1
    
        
      
        cmap = colormap;
        cmap_max=size(cmap,1);%probably 64
        %we want all elements of irc to be on a scale defined by colourrange
        ircs = ircs * (cmap_max/2) / ColourRange;
        %shift data so that 0 appears in centre of colourmap
        ircs = ircs + cmap_max/2;
        %colourange cant be > cmp_max/2
        
        %ircs now on a scale 0..64, assuming no vlaue is greater than
        %ColourRange
       
end
%create figure
%size it in cm and centre it on screen
 pos = get_size_of_figure('cm');
newfig = figure('NumberTitle', 'off', 'Units', 'centimeters', 'Position', pos, 'Color', [1 1 1]);
figwidth = pos(3);figheight = pos(4);
 
%determine size and position of plots
ptop = figheight-1;
pbottom = 0.5;

pleft= 3.25;
pwidth = figwidth-9.75;
numplots = length(toplot)+1; % plus one for LD

if plottype < 3
    numlines = 5 * numplots + 4;
    lineheight = (ptop - pbottom)/numlines;
    sep = lineheight;   %gap between plots
    vwidth = 4 * sep;   %height of each plot
    nexttop = ptop - vwidth;
    %headings
    uicontrol('String', 'Range', 'FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 10, 'Style', 'text','Units','centimeters','position',[(pleft+pwidth)+0.5 ptop 1.5 0.5], 'HorizontalAlignment', 'left', 'BackgroundColor', get(gcf, 'Color'));
    uicontrol('String', 'Integral', 'FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 10, 'Style', 'text','Units','centimeters','position',[(pleft+pwidth)+2 ptop 1.5 0.5],'HorizontalAlignment', 'left', 'BackgroundColor', get(gcf, 'Color'));
else
    vwidth = 1.5;   %will be height of the time series plot at bottom
    sep = 0.5;
    nexttop = vwidth+3*sep;
end

%phase_plot_styles = {'k-', 'b-', 'r-', 'g-', 'c-', 'm-', 'k:', 'b:', 'r:', 'g:', 'c:', 'm:', 'k--', 'b--', 'r--', 'g--', 'c--', 'm--'};


%plot the ircs
count=1;h=[];
uicontrol('String', tstr, 'FontUnits', 'points', 'FontSize',  plot_font_size, 'Style', 'text','Units','centimeters','position',[pleft ptop+0.25 pwidth 0.5], 'HorizontalAlignment', 'center', 'BackgroundColor', get(gcf, 'Color'));

for i = 1:numplots-1
    
    if plottype == 1
        h(count)=axes('units', 'centimeters', 'Position',[pleft,nexttop,pwidth,vwidth]);
        Y = ircs(:,i);
        unscaled_Y = unscaled_ircs(:,i);
        image(tspan,[],Y','ButtonDownFcn', @th_plotircdata, 'UserData', {pdesc{i}, unscaled_Y, tspan});
        xlim([tspan(1) tspan(end)]);
       
    elseif plottype == 2
        Y = ircs(:,i);
        unscaled_Y = unscaled_ircs(:,i);
        h(count)=axes('units', 'centimeters','Position',[pleft,nexttop,pwidth,vwidth],  'ButtonDownFcn', @th_plotircdata, 'UserData', {pdesc{i}, unscaled_Y, tspan} );      
      %  plot([tspan(1) tspan(end)], [0 0], 'r:');
        hold on;
        plot([tspan(1) tspan(end)], [0 0], 'r:');
        hold on;
        plot(tspan,Y', 'LineWidth', 2);
        ylim([-ColourRange ColourRange]);
        xlim([tspan(1) tspan(end)]);
        set(gca, 'XTick' ,[floor(tspan(1)):3:floor(tspan(end))]);
        set(gca, 'XTickLabel',{''});
        set(gca, 'YTickMode', 'auto');
        ylabel('\Delta\phi', 'FontSize', plot_font_size);
        hold off;
    else
        if i == 1   %first plot
            h = axes('units', 'centimeters','Position',[pleft,nexttop+0.5,pwidth,figheight-nexttop-1.5]);
            hold on
            ylim([-ColourRange ColourRange]);
            ylabel('\Delta\phi', 'FontSize', plot_font_size);
            xlim([tspan(1) tspan(end)]);
            set(h, 'XTick' ,[floor(tspan(1)):3:floor(tspan(end))]);
            set(h, 'XTickLabel',{''});
            set(gca, 'ygrid', 'on');
        end
        %colours and legend names
        Y = ircs(:,i);
        unscaled_Y = unscaled_ircs(:,i);
        plot(tspan, Y', get_plot_style(i), 'LineWidth', 2, 'ButtonDownFcn', @th_plotircdata, 'UserData', {pdesc{i}, unscaled_Y, tspan});
        if i == (numplots-1)
            hl = legend(h, parn);
            set(hl,'Units','centimeters','Position',[pleft+pwidth+0.5 nexttop+0.5 4 figheight-nexttop-1.5]);
            hold off
        end
    end
    if plottype < 3
        unscaledmin = sprintf('%4.1f', maxDelays(i));
        unscaledmax = sprintf('%4.1f', maxAdvances(i));
        scale = [unscaledmin, '-', unscaledmax];
        pos = [0.5 nexttop 1.5 0.5];
        k1=uicontrol('HorizontalAlignment', 'left','FontUnits', 'points', 'TooltipString',pdesc{i}, 'Style', 'text','Units','centimeters','Position',pos,'FontSize',10,'String',parn{i},'ButtonDownFcn', str,'BackgroundColor', get(gcf, 'Color'));
        pos = [(pleft+pwidth)+0.5 nexttop 1.5 0.5];
        if length(scale) > 9
            fsize = 8;
        else
            fsize=10;
        end
        k2=uicontrol('HorizontalAlignment', 'left','FontUnits', 'points', 'TooltipString', scale, 'Style', 'text','Units','centimeters','Position',pos,'FontSize',fsize,'String',scale,'ButtonDownFcn', str,'BackgroundColor', get(gcf, 'Color'));
        pos = [(pleft+pwidth)+2 nexttop 1.5 0.5];
        ci = num2str(integrals(i), '%4.1f');
        k3=uicontrol('FontUnits', 'points', 'TooltipString', ci, 'Style', 'text','Units','centimeters','Position',pos,'FontSize',10,'String',ci,'ButtonDownFcn', str,'BackgroundColor', get(gcf, 'Color'));
        nexttop=nexttop-vwidth-sep;
        count=count+1;
    end 
end

if plottype < 3
%    set(h(count-1),'Box','off');
 %   set(h(count-1),'YTickLabel',[]);
    if plottype == 1
        set(h(1:count-1),'Visible','off');
    end
else
    nexttop=1.5;
end

%plot the time series to givea phase reference
hld = axes('units', 'centimeters', 'Position',[pleft,nexttop,pwidth,vwidth], 'Color', 'none');
set(hld,'Box','off');
set(hld,'YTickLabel',[]);

if ~isempty(data.varnum)
    plot(hld, tspan, data.sol.y(:, data.varnum), 'r', 'LineWidth', 2);
    ymax = max(data.sol.y(:, data.varnum));
    set(get(hld,'XLabel'),'String',['Phase of variable ' data.vnames{data.varnum}], 'FontSize', 12);
else
    plot(hld, tspan, data.force, 'r', 'LineWidth', 2);
    ymax = max(data.force);
    set(get(hld,'XLabel'),'String','External force', 'FontSize', 12);
end
xlim([tspan(1) tspan(end)]);

axlen = floor(tspan(end))- floor(tspan(1));
h = (axlen-mod(axlen,10)) / 10;
set(hld, 'XTick' ,[floor(tspan(1)):h:floor(tspan(end))]);
ylim([0 ymax])
pos = [0.5 nexttop 1.5 0.5];
%uicontrol('HorizontalAlignment', 'left','FontUnits', 'points', 'TooltipString', 'Phase', 'Style', 'text','Units','centimeters','Position',pos,'FontSize',10,'String','Phase','BackgroundColor', get(gcf, 'Color'));


%colour bar for heat maps
if plottype == 1
    h_all = axes('units', 'centimeters', 'Position',[0.5 nexttop figwidth-2 ptop-nexttop],'Visible','off');
    set(gcf,'CurrentAxes',h_all)
   
    cb = colorbar( 'fontsize', 11 ,'YTickMode', 'manual', 'YTickLabelMode', 'manual','YTickLabel', [],'YTick', []);

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
    realticks=[-ColourRange:div:ColourRange];
    
    if ~verLessThan('matlab', '8.4')
               
        %in R20014b and later, colorbar CLim property has gone. Has been
        %replaced by a Limis property that behaves differently. This is by
        %default [0 1], meaning display all of colormap. [0 2] gives a cb
        %with the top half all the max color (eg dark red for jet
        %colormap)
        
        %In older versions cb has a CLim property that will be equal to [1
        %cmap_size]. In R2014b and later this has been replaced by
        %'Limits' property that is by default [0 1], meaning display all of the 
        %colormap. Goin glower than this would reduce the colours shown.
        %As IRC has been scaled to map to cmap_size [1..64], 
        %we need to correct this so correct colors are displayed.
        
        %map realticks to scale 0..1
        yticks = [];
        for i = 1:length(realticks)
            yticks = [yticks; (realticks(i)+ColourRange)/(2*ColourRange)];
        end
        
        set(cb, 'LimitsMode', 'manual', 'Limits', [0 1]); %just to make sure
        
    else
        
        yticks = [];
        for i = 1:length(realticks)
            yticks = [yticks; (realticks(i) + ColourRange) * (cmap_max/(2*ColourRange))];
        end

    end
   
    %make sure same number of actual ticks in correct places
   
    set(cb, 'YTickLabel', []);
    set(cb, 'YTick', []);
    set(cb, 'YTick', yticks);
    ylabels = cell(length(yticks),1);
    for i =1:size(ylabels,1)
        ylabels{i} = num2str(realticks(i), ['%4.' num2str(sig_figs) 'f']);
    end

    set(cb, 'YTickLabel', ylabels);
    text('FontUnits', 'points','Position',[1.14 0.6],'FontSize',12,'String','Phase Advance', 'Rotation', 90);
    text('FontUnits', 'points','Position',[1.14 0.25],'FontSize',12,'String','Phase Delay', 'Rotation', 90);

end

 %labels
 set(newfig, 'name', [tstr 'from ' modelname ', ' fname]);
 
 
%=========================================================================
    
function  v = IsValid(mdl, ts, showMsg)

 %to be a valid plot type, model must be oscillator,
 %time series must be unforced and theoretical analysis must
 %have been done.
 
 %reason is the cause of this function being called. It can be
 %a) this plot type selected by user
 %b) new ts file selected
 %c) theoretical data added to current file
 
 v = ~isempty(mdl) && strcmp(mdl.orbit_type, 'oscillator') && ~isempty(ts) &&  ~ts.forced && isfield(ts, 'theory') && isfield(ts.theory, 'irc');
 
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

function  FillParamsTable(hTable, results)

%called only by ChangePeak

user_data = get(hTable, 'Userdata');

if isfield(results, 'theory') && isfield(results.theory, 'irc')
    irc = results.theory.irc;
else
    irc = [];
end

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




