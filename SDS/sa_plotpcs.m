function r = sa_plotpcs(action, varargin)

global maincol btncol plot_font_size
persistent varList; %which variables listbox
persistent pcList; %which parameters listbox
persistent scaleHndl; %raw abs or log
persistent panel selAllHndl clearlHndl divHndl;

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
    %which vars to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth/2-1 0.5],'string','Select the Variables to Plot','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    varList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-4 pwidth/2-0.5 3],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
    
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
        'Callback','sa_plotpcs(''selAllVars'');');
    
    clearHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-3.1 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Clear', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotpcs(''clearAllVars'');');
    
    %which pcs to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5.5 pwidth/2-1 1],'string','Select Principal Components','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    pcList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-7.5 pwidth/2-0.5 3],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
    
    %divide by time series??
    divHndl = uicontrol('Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-8.75 pwidth-1 0.5],'string','Divide principal components by variable time series','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    %raw, abs or log?
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 0.5 pwidth/2-1 0.5],'string','Select the values to plot','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    scaleHndl = uibuttongroup('Units','centimeters','Position', [pwidth/2 0.5 pwidth/2-0.5 0.6], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    t1=uicontrol('Parent',scaleHndl,'string', 'raw data' ,'Units','normalized','Style','togglebutton', 'position',[0/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    t2=uicontrol('Parent',scaleHndl,'string', 'absolute' ,'Units','normalized','Style','togglebutton', 'position',[33/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    t3=uicontrol('Parent',scaleHndl,'string', 'log abs' ,'Units','normalized','Style','togglebutton', 'position',[66/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(scaleHndl, 'UserData', [t1 t2 t3]);
    
    r = panel;
elseif strcmp(action, 'name')
    r = 'Principal Components';
elseif strcmp(action, 'description')
    r = 'Plots the principal components of the derivative of the solution variables with respect to parameter. Data can be divided by variable values and plotted as absolute or log absolute values.';

elseif strcmp(action, 'fillSDS')
    %called when sds changes. Fill in pcs
    sds = varargin{1};
    pcs = {'1st pc'};
    if size(sds.U_all{1},2) > 2
        pcs = [pcs; {'2nd pc'}];
        if size(sds.U_all{1},2) > 3
             pcs = [pcs; {'3rd pc'}];
        end
    end
    for k = 4:size(sds.U_all{1},2)
        pcs = [pcs; strcat(num2str(k), {'th pc'})];
    end
    set(pcList, 'String', pcs, 'Value', 1);
    %and variables
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
    set([pcList varList], 'String', []);
elseif strcmp(action, 'plot')
    sds = varargin{1}; 
    cmb = varargin{2};
    all_y = get(varList, 'Value');
    ycols = get(varList, 'Userdata');
    ysel = zeros(size(ycols,1), 1);
    ysel(all_y) = 1;
    ptoplot = get(pcList, 'Value'); %num axes 
     %scaling
     opts = get(scaleHndl, 'UserData');
     for i =1:length(opts)
         if get(opts(i), 'Value')
             scalev = i;
             break;
         end
     end
    %divide by time series??
    divts = get(divHndl, 'Value');
    if divts
        dv = ' / time series ';
    else
        dv = ' ';
    end
        
    if isempty(all_y)
        ShowError('Please select one or more variables to plot.');
    elseif isempty(ptoplot)
        ShowError('Please select one or more principal components to plot.');
    else
        %find which variables required for each dgs
        ytoplot = cell(length(sds.U_all),1);
        numplots = 0;
        for p = 1:length(sds.U_all)
            %cut selection down to this dgs
            ytoplot{p} = ycols(ysel & (ycols(:,1) == p), 2);
            if ~isempty(ytoplot{p}) 
                numplots = numplots + 1;
            end
        end
        %extra plot for combined dgs
        if ~isempty(sds.bigU) && cmb
            numplots = numplots + 1;
        end
 
        pnames = get(pcList, 'String');
        pnum = 0;
        for p = 1:length(sds.U_all)
            if ~isempty(ytoplot{p})
                pnum = pnum + 1;
                data = sds.U_all{p};
                lc = sds.lc{p};
                tspan = sds.t{p};
                len = length(tspan);
                vnames = sds.vnames{p};
                vnames = vnames(ytoplot{p});
                %create seperate figure for each dgs
                if numplots == 1
                     pos = get_size_of_figure();
                else
                    pos = [(pnum-1)/numplots 0 1/numplots 1];
                end
                newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Principal Components'],  'Units', 'normalized', 'position', pos, 'Color', [ 1 1 1]); %MD background
                p_count = 0;
                firstplot = 1;
                for i = ptoplot
                    p_count = p_count+1;
                    subplot(length(ptoplot),1,p_count);
                    hold on;
                    ma=0;mi=0;
                    yvals = ytoplot{p}';
                    y_count = 0;
                    for j = yvals
                        u=(data((j-1)*len+1:j*len,i)); 
                        if divts
                            u = u ./ lc(:,j);
                        end
                        if scalev == 2
                            u = abs(u);
                        elseif scalev == 3
                            u = log(abs(u)); 
                        end              
                        mi=min(mi,min(u));ma=max(ma,max(u));
                        y_count = y_count+1;
                        plot(tspan, u, get_plot_style(y_count) ,'LineWidth',2);
                    end
                    if mi ~= ma 
                        ylim([1.05*mi 1.05*ma]);
                    end
                    xlim([tspan(1) tspan(end)]);
                    ylabel(pnames{i}, 'FontSize', plot_font_size);
                    if sds.periodic(p)
                       per = ' Periodic ';
                    else
                        per = ' ';
                    end
                    
                    if firstplot
                        if scalev == 1
                            tstr = [sds.mymodel per ' Principal Components' dv 'from '  sds.exptnames{p}];
                        elseif scalev == 2
                            tstr = [sds.mymodel ' Absolute' per 'Principal Components' dv 'from ' sds.exptnames{p}];
                        else
                            tstr = [sds.mymodel ' Log Absolute' per 'Principal Components ' dv 'from ' sds.exptnames{p}];
                        end
                        title(tstr, 'FontSize', plot_font_size);
                        legend(gca, vnames);
                        firstplot = 0;
                    end
                    if p_count == length(ptoplot)
                        xlabel('Time', 'FontSize', plot_font_size);
                    end
                    hold off;
                end     %end of pc loop
                hold off;
            end
        end %end of plot loop
        
        %plot combined U if present
        if ~isempty(sds.bigU) && cmb
            leg = cell(0);
            pos = [(numplots-1)/numplots 0 1/numplots 1];
            newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Principal Components from combined SDS'],  'Units', 'normalized', 'position', pos, 'Color', [ 1 1 1]); %MD background
            p_count = 1;
           
            for i = ptoplot % creat an axis for each selected pc
                subplot(length(ptoplot),1,p_count);
 
                p_count = p_count+1;
                hold on;
                ma=0;mi=0;
                t1 = sds.t{1}(1);
                t2 = 0;
                y_count = 0;
                %plot selected variables for each dgs
                startpos = 1;               
                for p = 1:length(sds.U_all) %for each dgs in combined
                    lc = sds.lc{p};
                    tspan = sds.t{p};
                    dgs_len = size(sds.U_all{p}, 1);
                    endpos = startpos + dgs_len-1;
                    %extract this dgs's component from combined dgs
                    data = sds.bigU(startpos:endpos, i);
                    startpos = endpos+1;
                    len = length(tspan);
                    yvals = ytoplot{p}';
                    for j = yvals
                        u=(data((j-1)*len+1:j*len,:));
                        if divts
                            u = u ./ lc(:,j);
                        end
                        if scalev == 2
                            u = abs(u);
                        elseif scalev == 3
                            u = log(abs(u));
                        end
                        mi=min(mi,min(u));ma=max(ma,max(u));
                        t1 = min(t1, tspan(1));t2 = max(t2, tspan(end));
                        y_count = y_count +1;
                        plot(tspan, u,  get_plot_style(y_count),'LineWidth',2);
                        if i == ptoplot(1)
                            leg{end+1} = [char(sds.vnames{p}(j))];
                        end
                    end
                end%end of p loop

                %size plot
                if mi ~= ma
                    ylim([1.05*mi 1.05*ma]);
                end
                xlim([t1 t2]);
                
                ylabel(pnames{i}, 'FontSize', plot_font_size);

                if i == ptoplot(1)
                    if scalev == 1
                        tstr = [sds.mymodel ' Combined Principal Components' dv];
                    elseif scalev == 2
                        tstr = [sds.mymodel ' Combined Absolute Principal Components' dv];
                    else
                        tstr = [sds.mymodel ' Combined Log Absolute Principal Components' dv];
                    end
                    title(tstr, 'FontSize', plot_font_size);
                    legend(gca, leg);
                end
                if i == ptoplot(end)
                    xlabel('Time', 'FontSize', plot_font_size);
                end
                hold off;
            end     %end of i loop
            hold off;
        end %end of if ~isempty(sds.bigU)
    end
    
elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    %input arg 2 is whole contents of file, idx is where to start reading it
    %return value is where next plot type needs to start
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
elseif strcmp(action, 'selAllVars')
    str = get(varList, 'String');
    set(varList, 'Value', 1:length(str));
elseif strcmp(action, 'clearAllVars')
    set(varList, 'Value', []);
end

       
 
