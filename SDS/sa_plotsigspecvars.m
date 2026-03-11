function r = sa_plotsigspecvars(action, varargin)

global maincol plot_font_size
persistent sortHndl nHndl; 
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
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth-4 0.5],'string','Number of singular values to consider','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    whichvaluesList = uicontrol('Parent',panel, 'String', '1', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','popup', 'position',[pwidth-2.5 pheight-1.25 2 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Value', 1);
    
    %sort checkbox
    sortHndl=uicontrol('Style','checkbox', 'Units','centimeters', 'position',[0.5 pheight-2.75 pwidth-1 0.5],'min', 0, 'max', 1, ...
        'string', 'Sort variables and plot only the most important' , 'Parent',panel,'FontUnits', 'points', 'FontSize', 10, 'BackgroundColor', maincol, 'tooltipstring', 'Check to plot only the most important variables');

    %first n popup
    nHndl=uicontrol('string', 'n', 'Style','popup', 'Units','centimeters', 'position', [pwidth-2.5 pheight-2.6 2 0.5],'min', 0, 'max', 1, ...
        'Parent',panel,'FontUnits', 'points', 'FontSize', 10);
     
    r = panel;
elseif strcmp(action, 'name')
    r = 'Singular Value Analysis Plot';
elseif strcmp(action, 'description')
    r = 'Compares the singular values when considering all model variables, and when excluding each in turn. Mean differences are calculated across the selected number of singular values, giving a measure of the importance of each variable.';
elseif strcmp(action, 'fill')
    %fill control values in response to changing results file
   
elseif strcmp(action, 'fillSDS')
    %called when sds changes.
    sds = varargin{1};
    str = cell(0);
    for i = 1:size(sds.U_all{1}, 2)
       str = [str; num2str(i)]; 
    end
    set(whichvaluesList, 'String', str, 'Value', i);
    set(nHndl, 'string', [1:sum(sds.dim)], 'value', max(sds.dim));
    
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set([nHndl whichvaluesList], 'String', '1', 'Value', 1);  
  
elseif strcmp(action, 'plot')
    sds = varargin{1};
    cmb = varargin{2};
    numtoplot = get(whichvaluesList, 'Value');
    varstoplot = get(nHndl, 'Value');
    dosort = get(sortHndl, 'Value');
    
    
    if length(sds.spec_all) == 1
        pos = get_size_of_figure();
    else
        pos = [0 0.3 0.6 0.6];
    end
   for i =1:length(sds.spec_all);
        newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Singular Value Analysis - ' sds.exptnames{i}],  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]); %MD background
        sig_all = sds.spec_all{i};
        sig_all = sig_all(1:numtoplot);
        sig_missing = sds.sigma_missing_var{i};
        vnames = sds.vnames{i};
        
        %calculate mean difference for each variable
        sig_diff = [];
        for v = 1:length(vnames)
            sig_diff(v) = mean(abs(sig_missing{v}(1:numtoplot)-sig_all));
        end
        if dosort
            [sig_diff idx] = sort(sig_diff,'descend');
            sig_diff = sig_diff(1:min(varstoplot, length(sig_diff)));
        else
            idx = 1:length(sig_diff);
        end
        %bar plot for this dgs
        bar(sig_diff);
        
        set(gca, 'xticklabel', []);
        xlim([0 length(sig_diff)+1]);
        yv = get(gca, 'YLim');
        set(gca,'xtick', [1:length(sig_diff)]);
        set(gca,'YGrid', 'on');
        
        %label cols
        if length(sig_diff) > 6
            %vertical text to save space
            for v = 1:length(sig_diff)
                text('parent', gca, 'string', vnames{idx(v)}, 'rotation', 90, 'position', [v yv(1)-diff(yv)/10], 'fontsize', plot_font_size);
            end
        else
            xticks = cell(0);
            for v = 1:length(sig_diff)
                xticks = [xticks, vnames{idx(v)}];
            end
            set(gca, 'xticklabel', xticks, 'fontsize', plot_font_size);
        end
        
       title(sds.exptnames{i}, 'FontSize', plot_font_size);
       xlabel('Missing variable', 'FontSize', plot_font_size);
        ylabel(['Mean difference in first ' num2str(numtoplot) ' singular values'], 'FontSize', plot_font_size);
       
      pos(1) = pos(1)+0.05;
      pos(2) = max(0, (pos(2)-0.05));
   end
    
   if cmb
       sig_all = sds.bigspec;
       sig_all = sig_all(1:numtoplot);
       newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Singular Value Analysis - Combined SDS'],  'Units', 'normalized', 'position', pos);
       sig_missing = sds.bigsigma_missing_var;
       
       %calculate mean difference for each variable
       sig_diff = [];
       bigvnames = cell(0);
       for i =1:length(sds.spec_all);
            for v = 1:length(sds.vnames{i})
                bigvnames{end+1} = sds.vnames{i}{v};
            end
       end
       
       for v = 1:length(bigvnames)
           sig_diff(v) = mean(abs(sig_missing{v}(1:numtoplot)-sig_all));
       end
       if dosort
           [sig_diff idx] = sort(sig_diff,'descend');
           sig_diff = sig_diff(1:varstoplot);
       else
           idx = 1:length(sig_diff);
       end
       %bar plot for this dgs
       bar(sig_diff);
       
       set(gca, 'xticklabel', []);
       xlim([0 length(sig_diff)+1]);
       yv = get(gca, 'YLim');
       set(gca,'xtick', [1:length(sig_diff)]);
       set(gca,'YGrid', 'on');
       
       %label cols
       if length(sig_diff) > 6
           %vertical text to save space
           for v = 1:length(sig_diff)
               text('parent', gca, 'string', bigvnames{idx(v)}, 'rotation', 90, 'position', [v yv(1)-diff(yv)/10], 'fontsize', plot_font_size);
           end
       else
           xticks = cell(0);
           for v = 1:length(sig_diff)
               xticks = [xticks, bigvnames{idx(v)}];
           end
           set(gca, 'xticklabel', xticks, 'fontsize', plot_font_size);
       end
       
       title('Combined SDS', 'FontSize', plot_font_size);
       xlabel('Missing variable', 'FontSize', plot_font_size);
       ylabel(['Mean difference in first ' num2str(numtoplot) ' singular values'], 'FontSize', plot_font_size);
       
   end

elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    idx = varargin{1};
    vals = varargin{2};
    s = str2double(vals{idx});
    idx = idx + 1;
    srt = str2double(vals{idx});
    idx = idx + 1;
    n = str2double(vals{idx});
    idx = idx + 1;
 
    %The order they are set in must match the order they are written to file
    %in
    set(whichvaluesList, 'value', 2);
    set(sortHndl, 'value', srt);
    set(nHndl, 'value', n);
 
    %return index value for next panel
    r = idx; 
elseif strcmp(action, 'save')
    %save control values to file
    %the order here must match the order they are loaded in, as above
    fp = varargin{1};

    fprintf(fp, '%d\n', get(whichvaluesList, 'Value'));
    fprintf(fp, '%d\n', get(sortHndl, 'Value'));
    fprintf(fp, '%d\n', get(nHndl, 'Value'));
end
