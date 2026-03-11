function r = sa_plottseriessens(action, varargin)

global maincol
persistent sensList txtHndl axHndl varHndl derivHndl normChk;
persistent pcList panel thresholdHndl;


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
    %definition of sensitivity  
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth/2-1 0.5],'string','Sensitivity is defined as','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);    
    sensList = uibuttongroup('Units','centimeters','SelectionChangeFcn','sa_plottseriessens(''changeType'');', 'Position', [pwidth/2 pheight-2.15 pwidth/2-0.25 1.25], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    s1=uicontrol('HorizontalAlignment', 'right','Parent',sensList,'string', 'sig_j * U_j' ,'Units','normalized','Style','radiobutton', 'position',[0/100 50/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    s2=uicontrol('HorizontalAlignment', 'right','Parent',sensList,'string', 'f(i,m)' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(sensList, 'UserData', [s1 s2]);
    %plot the derivative
    derivHndl = uicontrol('callback','sa_plottseriessens(''changeType'');', 'Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-3 pwidth/2-1 0.5],'string','Plot the derivative','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
  
    axHndl = axes('Units','centimeters','parent', panel, 'position', [pwidth/2-0.5 pheight-3.1 pwidth/2-0.25 0.5], 'xtick', [], 'ytick', [], 'color', 'none', 'box', 'off', 'visible', 'off');
    xlim([0 1]); ylim([0 1]);
    txtHndl = text(0,0.6, 'text', 'parent', axHndl, 'visible', 'on');   
    
    %which pcs to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5 pwidth/2-1 1.5],'string','Select the PCs to use when overlaying sensitivity on the time series','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    pcList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-6.25 pwidth/2-0.5 2.75],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize',10);

    %which vars to plot, all or the most important
    varHndl = uibuttongroup('Units','centimeters','Position', [0.5 1.25 pwidth-1 1.25], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    r1=uicontrol('HorizontalAlignment', 'right','Parent',varHndl,'string', 'Show all variables' ,'Units','normalized','Style','radiobutton', 'position',[0/100 50/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    r2=uicontrol('HorizontalAlignment', 'right','Parent',varHndl,'string', 'Show only those with sensitivity overlaid' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(varHndl, 'UserData', [r1 r2]);
    
    %highlight regions
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 2.75 pwidth/2-0.5 0.5],'string','Overlay sensitivity exceeding','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    thresholdHndl = uicontrol('HorizontalAlignment', 'right','Parent',panel,'string', '50' ,'Units','centimeters','Style','edit', 'position',[pwidth/2 2.75 0.75 0.6],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor','w', 'Value', 1);
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2+0.9 2.75 pwidth/2-1.4 0.5],'string','% of the global max','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
   
    %normalize the time series
    normChk = uicontrol('Parent',panel, 'String', 'Normalise the time series', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','checkbox', 'position',[0.5 0.5 pwidth-1 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10,'BackgroundColor', maincol, 'Value', 0);
     
    sa_plottseriessens('changeType');
    
    r = panel;
elseif strcmp(action, 'name')
    r = 'Time Series with Sensitivity';
elseif strcmp(action, 'description')
    r = 'Plots the variable time series, overlaying time regions where the sensitivity of the variables to particular principal components exceeds a specified value.';
elseif strcmp(action, 'fill')
    %fill control values in response to changing results file
    
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
    for k = 4:size(sds.U_all{1},2)-1
        pcs = [pcs; strcat(num2str(k), {'th pc'})];
    end
    set(pcList, 'String', pcs, 'Value', 1);
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set(pcList, 'String', []);
elseif strcmp(action, 'plot')
    sds = varargin{1};cmb = varargin{2};
    %get user controls and verify their values
    opts = get(sensList, 'UserData');
    for i = 1:length(opts)
      if get(opts(i), 'Value')
          stype = i;
          tl = get(opts(i), 'String');
          break;
      end
    end
    deriv = get(derivHndl, 'Value');
    if deriv
       tl = [tl ' derivative']; 
    end
    opts = get(varHndl, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            vartype = i;
            break;
        end
    end
    
    %threshold is a percentage    
    thr = get(thresholdHndl, 'String');
    %make sure it is numeric
    badnum = 0;
    if isempty(thr)
        badnum = 1;
    elseif ~isstrprop(thr(1), 'digit')
        badnum = 1;
    else
        for i = 2:length(thr)
            if ~isstrprop(thr(i), 'digit') && ~strcmp('.', thr(i))
                badnum = 1;
            end
        end
        dps = find(thr == '.');
        if (size(dps,2) > 1)
            badnum = 1;
        end
    end
    if badnum
        ShowError('Please enter a number for percentage.');
        uicontrol(thresholdHndl);
        return;
    end
    thr = str2double(thr);
    thr = min(thr, 100);
    thr = thr / 100;
    
    pcstoplot = get(pcList, 'Value');
    nm = get(normChk, 'Value');
    
    if isempty(pcstoplot)
        ShowError('Please select one or more principal components to plot.');
    else
        pc_time_series(sds, stype, vartype, thr, tl, deriv, pcstoplot, nm, cmb);
    end    
                       
elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    %input arg 2 is whole contents of file, idx is where to start reading it
    %return value is where next plot type needs to start
    idx = varargin{1};
    vals = varargin{2};
    senstype = vals{idx};idx = idx + 1;
    deriv = vals{idx};idx = idx + 1;
    var = vals{idx};idx = idx + 1;
    thr = vals{idx};idx = idx + 1;
    nm = vals{idx};idx = idx + 1;
    
    opts = get(sensList, 'UserData');
    set(opts(str2double(senstype)), 'Value', 1);
    set(derivHndl, 'Value', str2double(deriv));
    opts = get(varHndl, 'UserData');
    set(opts(str2double(var)), 'Value', 1);
    set(thresholdHndl, 'String', thr);
    set(normChk, 'Value', str2double(nm));
    
    sa_plottseriessens('changeType');
    
    %The order they are set in must match the order they are written to file
    %in
    %return index value for next panel
    r = idx; 
elseif strcmp(action, 'save')
    %save control values to file
    %the order here must match the order they are loaded in, as above
   fp = varargin{1};
   opts = get(sensList, 'UserData');
   for i = 1:length(opts)
      if get(opts(i), 'Value')
          fprintf(fp, '%d\n', i);
          break;
      end
   end
   fprintf(fp, '%d\n', get(derivHndl, 'Value'));
    opts = get(varHndl, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            fprintf(fp, '%d\n', i);
            break;
        end
    end
    fprintf(fp, '%s\n', get(thresholdHndl, 'String'));
    fprintf(fp, '%d\n', get(normChk, 'Value'));

%========================================================================
elseif strcmp(action, 'changeType')
   opts = get(sensList, 'UserData');
   for i = 1:length(opts)
      if get(opts(i), 'Value')
          t = i;
          break;
      end
   end
   deriv = get(derivHndl, 'Value');
   if t == 1
       if deriv
           set(txtHndl,'String', '\partial \sigma_jU_{j} / \partial t will be plotted');
       else
           set(txtHndl,'String', '\sigma_jU_{j} will be plotted');
       end
   else
       if deriv
           set(txtHndl,'String', '|\partial \sigma_jU_{j} / \partial t| * max |W_j| will be plotted');
       else
           set(txtHndl,'String', '|\sigma_jU_{j}| * max |W_j| will be plotted'); 
       end
   end
end

%=========================================================================
function h = pc_time_series(sds, stype, vartype, thr, tl, deriv,pcstoplot, nml, cmb)

%This function plots model variable time series, and overlays the time
%regions where the variables are most important for any principle component

%plots all model variables which have any pc with a max value greater than 
%tol * the max value for all pcs
%overlays the pc values in regions where they are greater than a threshold.
%
global plot_font_size

colours = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 0 0 0; 0.5 0.5 0.5; ...
            0.75 0.25 0.25; 0.25 0.75 0.25; 0.25 0.25 0.75; 1 0.5 0.5; 0.5 0.5 1; ...
            0.5 0 0; 0 0.5 0; 0 0 0.5; 0.75 0.75 0.25; 0.25 0.75 0.75; 0.75 0.25 0.75;];
nc = size(colours, 1);
mstyles = {'o';'s'; 'd';'^';'v';'>';'<'; 'p';'h';'+'; 'x'; '*'};
nm = length(mstyles);

numplots = length(sds.U_all);

if ~isempty(sds.bigU) && cmb
    numplots = numplots * 2;
end

pnum = 0;
threshold = thr;
 
for p = 1:length(sds.lc)
    tspan = sds.t{p};
    y = sds.lc{p};
    U = sds.U_all{p};
    sig = sds.spec_all{p};
    V = sds.V_all{p};
    nvars = size(y,2);
    var_names = sds.vnames{p};
   
    if stype == 1
        W = [];
    else
        W = inv(V);
    end
    U=U(:,1:end-1); % ignore last column
    [cn,rn]=size(U);
    sublen=cn/nvars;%num timepoints
    
    U1=zeros(size(U));
    for i=1:rn
        U1(:,i)=sig(i)*U(:,i);
    end
    U2 = U1;
    %U1 columns represent principle components
    %They consist of stacked time series, one for each variable
    if ~isempty(W)
        %W columns are parameters
        %W rows are principle components
        %multiply sig_i*U_i by max parameter value from pc i
        for i=1:rn
            U1(:,i) = abs(U1(:,i)) * max(abs(W(i,:))); % U1 set to be fi,m
        end
    end
    %U1 is sigma * U or |sigma * U| * |Wij|
    %%
    %calculate derivative if user requested it
    % DAR put this section in front of sorting section so that right U1 is sorted
    if deriv
        for i=1:rn
            for j = 1:nvars
                Y = U2((j-1)*sublen+1:j*sublen,i);%for each time series
                if ~isempty(W)
                    Wij = max(abs(W(i,:)));
                    % Y = Y / Wij;
                    dY = derv(Y, tspan);
                    %disp(i);disp(j);disp(max(abs(dY)));
                    %U1 is |derivative(sigma * U)| * |Wij|
                    U1((j-1)*sublen+1:j*sublen,i) = abs(dY) * Wij; % U1 changed
                else
                    %U1 is derivative of sigma * U
                    U1((j-1)*sublen+1:j*sublen,i) = derv(Y, tspan); % was abs(derv(Y));
                end
            end
        end
    end

    tol = threshold * max(max(abs(U1)));
    pnum = pnum + 1;
    if numplots == 1
        pos = get_size_of_figure();
    else
       tp = (0.4*(pnum-1)/(numplots-1));
       pos = [tp 0.4-tp-0.1 0.6 0.6];
    end
    
    newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Sensitivity'],  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]); %MD background
    
    h = axes('Parent', newfig);
    hold on;
    if nml
        for c = 1:size(y,2) %scale each time series so they have a mean of 1
            y(:,c) = y(:,c) / mean(y(:,c));
        end
    end
    if nml
        tstr = [sds.mymodel, ' Normalised Time Series from ', sds.exptnames{p}, ' with sensitivity ' tl ' overlaid where exceeding ' num2str(threshold) ' of ' num2str(max(max(abs(U1))))];
    else
        tstr = [sds.mymodel, ' Time Series from ', sds.exptnames{p}, ' with sensitivity ' tl ' overlaid where exceeding ' num2str(threshold) ' of ' num2str(max(max(abs(U1))))];
    end
    
    numPlotted = [];
    leg = cell(0);
 
    for v = 1:nvars
        %for each variable
        for p = pcstoplot%test which pcs to overlay
            % extract the time-series for the vth variable of the pth pc
            UY = (U1((v-1)*sublen+1:v*sublen,p));
            valsAbove = find(abs(UY)>tol);
            %plot the time series
            line_style = get_plot_style(v);
            if (~isempty(valsAbove) || vartype == 1) && (isempty(find(numPlotted==v, 1)));
                plot(h, tspan, y(:,v), line_style, 'LineWidth', 2);
                leg = [leg; var_names{v}];
                numPlotted = [numPlotted v];
            end
            if ~isempty(valsAbove)
                cms = mstyles{mod(p,nm)};
                plot(h, tspan(valsAbove), y(valsAbove, v), 'Linestyle', 'none', 'Marker', cms, 'MarkerFaceColor','none', 'MarkerEdgeColor', line_style(1), 'MarkerSize', 10);
                leg = [leg; strcat(cnum(p), {' pc'});];
            end
        end
    end
    if ~isempty(numPlotted)
        legend(leg, 'location', 'best');
        xlim([tspan(1) tspan(end)]);
        title(tstr, 'FontSize', plot_font_size);
        xlabel('Time', 'FontSize', plot_font_size);ylabel('Model Variable', 'FontSize', plot_font_size);
        hold off;
    else
        ShowError(['No variables were selected for the plot ' sds.exptnames{p} '. Try opting to plot all variables, reducing the overlay threshold, or selecting different principal components.']);
        delete(newfig);
    end
    
end

if ~isempty(sds.bigU) && cmb
    sig = sds.bigspec;
    V = sds.bigV;
    if stype == 1
        W = [];
    else
        W = inv(V);
    end
    startpos = 1;
    for p = 1:length(sds.U_all);
        tspan = sds.t{p};
        y = sds.lc{p};
        nvars = size(y,2);
        var_names = sds.vnames{p};
        
        dgs_len = size(sds.U_all{p}, 1);
        endpos = startpos + dgs_len-1;
        %extract this dgs's component from combined dgs
        U = sds.bigU(startpos:endpos, :);
        startpos = endpos+1;       
        sublen=length(tspan);
        
        U=U(:,1:end-1); % ignore last column
        [cn,rn]=size(U);
        
        U1=zeros(size(U));
        for i=1:rn
            U1(:,i)=sig(i)*U(:,i);
        end
        U2 = U1;
        %U1 columns represent principle components
        %They consist of stacked time series, one for each variable
        if ~isempty(W)
            %W columns are parameters
            %W rows are principle components
            %multiply sig_i*U_i by max parameter value from pc i
            for i=1:rn
                U1(:,i) = abs(U1(:,i)) * max(abs(W(i,:))); % U1 set to be fi,m
            end
        end
        %U1 is sigma * U or |sigma * U| * |Wij|
        %%
        %calculate derivative if user requested it
        % DAR put this section in front of sorting section so that right U1 is sorted
        if deriv
            for i=1:rn
                for j = 1:nvars
                    Y = U2((j-1)*sublen+1:j*sublen,i);%for each time series
                    if ~isempty(W)
                        %remove W before calculating derivative
                        Wij = max(abs(W(i,:)));
                        % Y = Y / Wij;
                        dY = derv(Y, tspan);
                        %disp(i);disp(j);disp(max(abs(dY)));
                        %U1 is |derivative(sigma * U)| * |Wij|
                        U1((j-1)*sublen+1:j*sublen,i) = abs(dY) * Wij; % U1 changed
                    else
                        %U1 is derivative of sigma * U
                        U1((j-1)*sublen+1:j*sublen,i) = derv(Y, tspan); % was abs(derv(Y));
                    end
                end
            end
        end
        
        tol = threshold * max(max(abs(U1)));
        pnum = pnum + 1;
        if numplots == 1
            pos = get_size_of_figure();
        else
            tp = (0.4*(pnum-1)/(numplots-1));
            pos = [tp 0.4-tp-0.1 0.6 0.6];
        end
        
        newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Sensitivity combined SDS'],  'Units', 'normalized', 'position', pos);
        
        h = axes('Parent', newfig);
        hold on;
        if nml
            for c = 1:size(y,2) %scale each time series so they have a mean of 1
                y(:,c) = y(:,c) / mean(y(:,c));
            end
        end
        if nml
            tstr = [sds.mymodel, ' Normalised Time Series from ', sds.exptnames{p}, ' with sensitivity ' tl ' overlaid where exceeding ' num2str(threshold) ' of ' num2str(max(max(abs(U1))))];
        else
            tstr = [sds.mymodel, ' Time Series from ', sds.exptnames{p}, ' with sensitivity ' tl ' overlaid where exceeding ' num2str(threshold) ' of ' num2str(max(max(abs(U1))))];
        end
        
        numPlotted = [];
        leg = cell(0);
        
        for v = 1:nvars
            %for each variable
             line_style = get_plot_style(v);
            for p = pcstoplot%test which pcs to overlay
                % extract the time-series for the vth variable of the pth pc
                UY = (U1((v-1)*sublen+1:v*sublen,p));
                valsAbove = find(abs(UY)>tol);
                %plot the time series
                if (~isempty(valsAbove) || vartype == 1) && (isempty(find(numPlotted==v, 1)));
                    plot(h, tspan, y(:,v), line_style, 'LineWidth', 2);
                    leg = [leg; var_names{v}];
                    numPlotted = [numPlotted v];
                end
                if ~isempty(valsAbove)
                    cms = mstyles{mod(p,nm)};
                    plot(h, tspan(valsAbove), y(valsAbove, v), 'Linestyle', 'none', 'Marker', cms, 'MarkerFaceColor','none', 'MarkerEdgeColor', line_style(1), 'MarkerSize', 10);
                    leg = [leg; strcat(cnum(p), {' pc'});];
                end
            end
        end
        if ~isempty(numPlotted)
            legend(leg, 'location', 'best');
            xlim([tspan(1) tspan(end)]);
            title(tstr, 'FontSize', plot_font_size);
            xlabel('Time', 'FontSize', plot_font_size);ylabel('Model Variable', 'FontSize', plot_font_size);
            hold off;
        else
            ShowError(['No variables were selected for the plot ' sds.exptnames{p} ' from combined SDS. Try opting to plot all variables, reducing the overlay threshold, or selecting different principal components.']);
            delete(newfig);
        end      
    end
end

return;

%===================================
function s = cnum(i)

if i == 1
    s = 'st';
elseif i == 2
    s = 'nd';
elseif i == 3
    s = 'rd';
else
    s = 'th';
end
s = {[num2str(i), s]};

%========================================================
 
 function r = derv(v, t)
 
 %return derivative of vector v
 
 %first add extra point by linear extrapolation
 v(end + 1) = v(end) + v(end) - v(end - 1);
 t(end + 1) = t(end) + t(end) - t(end - 1);
 dv = diff(v);
 dt = diff(t);
 r = dv ./ dt;

    
    