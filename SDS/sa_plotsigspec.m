function r = sa_plotsigspec(action, varargin)

global maincol plot_font_size
persistent normChk; %normalise? checkbox
persistent panel whichvaluesList

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
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth*0.6 0.5],'string','Number of singular values to plot','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    whichvaluesList = uicontrol('Parent',panel, 'String', '1', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','popup', 'position',[pwidth*0.6+0.5 pheight-1.5 2.25 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10,'BackgroundColor', 'w', 'Value', 1);
    %normalise? checkbox
    normChk = uicontrol('Parent',panel, 'String', 'Normalise the values', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','checkbox', 'position',[0.5 pheight-2.25 pwidth-1 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10,'BackgroundColor', maincol, 'Value', 0);
    set(normChk, 'UserData', 13, 'callback', 'sagui(''synch'',13);');
     
    r = panel;
elseif strcmp(action, 'name')
    r = 'Singular Spectrum Plot';
elseif strcmp(action, 'description')
    r = 'Plots log10 of the singular values, with an option to normalise so that the largest has a value of one.';
elseif strcmp(action, 'fill')
    %fill control values in response to changing results file
   
elseif strcmp(action, 'fillSDS')
    %called when sds changes.
    sds = varargin{1};
    str = cell(0);
    for i = 2:size(sds.U_all{1}, 2)
       str = [str; num2str(i)]; 
    end
    set(whichvaluesList, 'String', str, 'Value', i-1);
    
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set(whichvaluesList, 'String', 'sigma', 'Value', 1);   
elseif strcmp(action, 'plot')
    sds = varargin{1};
    cmb = varargin{2};
    numtoplot = get(whichvaluesList, 'Value')+ 1;
    nm = get(normChk, 'Value');
    warning off MATLAB:log:logOfZero;
    
    colours = {'c' 'b' 'r' 'g' 'm'};
    pos = get_size_of_figure();
    newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Singular Spectrum'],  'Units', 'normalized', 'position',  pos, 'Color', [1 1 1]); %MD background
    leg = cell(0);
    hold on
    for i = 1:length( sds.spec_all)
        spec = sds.spec_all{i};
        if nm
            spec=spec/spec(1);
        end      
        plot(1:numtoplot, log10(spec(1:numtoplot)), ['--o' colours{mod(i, 5)+1}], 'LineWidth', 2, 'MarkerSize', 10);
        leg{end+1} = [ sds.exptnames{i} ', slope = ' num2str(sds.slope_spec_all{i})];
    end
    
    if ~isempty(sds.bigspec) && cmb
        spec = sds.bigspec;
        if nm
            spec=spec/spec(1);
        end     
        plot(1:numtoplot, log10(spec(1:numtoplot)), '--ok', 'LineWidth', 2, 'MarkerSize', 10);
        leg{end+1} = ['Combined, slope = ' num2str(sds.bigslope_spec)];
    end
    
    if nm
        tstr = [sds.mymodel ' Normalised Singular Spectrum Plot'];
    else
        tstr = [sds.mymodel ' Singular Spectrum Plot'];
    end
    
    title(tstr, 'FontSize', plot_font_size); 
    xlim([1 numtoplot]);
    set(gca, 'xtick', [1:numtoplot],'FontSize', plot_font_size); %MD fontsize
    %ylim([log10(spec(numtoplot)) log10(spec(1))]);
    xlabel('Singular Value Index', 'FontSize', plot_font_size);
    ylabel('log_{10} Singular Value', 'FontSize', plot_font_size);
    legend(leg);
    hold off
 
    warning on MATLAB:log:logOfZero;
    
elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    idx = varargin{1};
    vals = varargin{2};
    nm = vals{idx};
    idx = idx + 1;
    %The order they are set in must match the order they are written to file
    %in
    set(normChk, 'Value', str2double(nm));
    %return index value for next panel
    r = idx; 
elseif strcmp(action, 'save')
    %save control values to file
    %the order here must match the order they are loaded in, as above
    fp = varargin{1};
    v = get(normChk, 'Value');
    fprintf(fp, '%d\n', v);
end
