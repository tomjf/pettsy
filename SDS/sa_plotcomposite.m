function r = sa_plotcomposite(action, varargin)

global maincol btncol 
persistent sensList txtHndl axHndl varHndl;
persistent pcList sealevelChk sealevelHndl normChk scaleHndl sortChk; %which parameters listbox
persistent panel highlightHndl thresholdHndl;

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
    sensList = uibuttongroup('Units','centimeters', 'SelectionChangeFcn','sa_plotcomposite(''changeType'');', 'Position', [pwidth/2 pheight-2.15 pwidth/2-0.25 1.25], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    s1=uicontrol('HorizontalAlignment', 'right', 'Parent',sensList,'string', 'sig_j * U_j,m' ,'Units','normalized','Style','radiobutton', 'position',[0/100 50/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    str = {'\sigma_jU_{j}';'\partial \sigma_jU_{j} / \partial t'};
    set(s1, 'UserData', str);   
    s2=uicontrol('HorizontalAlignment', 'right','Parent',sensList,'string', 'f(i,m)' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    str = {'|\sigma_jU_{j}| * max |W_j|';'|\partial \sigma_jU_{j} / \partial t| * max |W_j|'};
    set(s2, 'UserData', str);  
    set(sensList, 'UserData', [s1 s2]);
    
    axHndl = axes('Units','centimeters', 'parent', panel, 'position', [pwidth/2-0.25 pheight-3.1 pwidth/2-0.25 0.5], 'xtick', [], 'ytick', [], 'color', 'none', 'box', 'off', 'visible', 'off');
    xlim([0 1]); ylim([0 1]);
    txtHndl = text(0,0.6, 'text', 'parent', axHndl, 'visible', 'on');
    
    %which pc to plot
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-4.1 pwidth/2-0.5 0.5],'string','Select a Principal Component','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    pcList = uicontrol('Parent',panel, 'Units','centimeters','Style','popup', 'String','1st pc', 'position',[pwidth/2 pheight-4 pwidth/2-0.5 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
   
    %which var to plot
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5.1 pwidth/2-0.5 0.5],'string','Select a Variable','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    varHndl = uicontrol('Parent',panel, 'Units','centimeters','Style','popup', 'String','y1', 'position',[pwidth/2 pheight-5 pwidth/2-0.5 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
   
    %highlight regions
    highlightHndl = uicontrol('Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-6.1 pwidth/2-0.5 0.5],'string','Highlight regions above','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    thresholdHndl = uicontrol('HorizontalAlignment', 'right','Parent',panel,'string', '50' ,'Units','centimeters','Style','edit', 'position',[pwidth/2 pheight-6.1 0.75 0.6],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor','w', 'Value', 1);
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2+0.9 pheight-6.1 4 0.5],'string','% of the global max','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    
    %strengths
    %sea level
    sealevelChk = uicontrol('enable', 'off','Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-8.85 pwidth-1 0.5],'string','Apply a sea level, plotting only heights above','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    sealevelHndl = uicontrol('enable', 'off', 'HorizontalAlignment', 'right','Parent',panel,'string', '0' ,'Units','centimeters','Style','edit', 'position',[pwidth-2 pheight-8.85 1.5 0.6],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor','w', 'Value', 1);   
   
    %Normalise
    normChk = uicontrol('enable', 'off', 'Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-8.1 pwidth-1 0.5],'string','Normalise strengths so that the maximum value is zero','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);   
   
    %raw, abs or log?
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-7.1 pwidth/2-0.5 0.5],'string','Select strength values to use','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    scaleHndl = uibuttongroup('SelectionChangeFcn', {@update_scale,normChk, sealevelChk, sealevelHndl},'Units','centimeters','Position', [pwidth/2 pheight-7.1 pwidth/2-0.5 0.6], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    t1=uicontrol('Parent',scaleHndl,'string', 'raw data' ,'Units','normalized','Style','togglebutton', 'position',[0/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    t2=uicontrol('Parent',scaleHndl,'string', 'absolute' ,'Units','normalized','Style','togglebutton', 'position',[33/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    t3=uicontrol('Parent',scaleHndl,'string', 'log abs' ,'Units','normalized','Style','togglebutton', 'position',[66/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(scaleHndl, 'UserData', [t1 t2 t3]);
    
    %sort parameters
    sortChk = uicontrol('Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-9.6 pwidth-1 0.5],'string','Sort strengths by size','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
     
    sa_plotcomposite('changeType');
    
    r = panel;
elseif strcmp(action, 'name')
    r = 'Composite plot';
elseif strcmp(action, 'description')
    r = 'Plots selected variable and its sensitivity to the selected principal component, and the derivative of the sensitivity. Also plots the parameter sensitivity spectrum (strengths) of effect of the parameters on the principle component.';
% elseif strcmp(action, 'fill')
%     %fill control values in response to changing results file
%     lc = varargin{1};
%     %fill in variable names and select first by default
%     set(varHndl, 'String', lc.vnames, 'Value', 1);  
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
     %fill in variable names
    vnames = cell(0);
    ycols = [];
    for i = 1:length(sds.vnames)
        vnames = [vnames sds.vnames{i}];
        ycols = [ycols; (ones(length(sds.vnames{i}),1)*i) (1:length(sds.vnames{i}))'];
    end
    %record which dgs each variable belongs to 
    set(varHndl, 'String', vnames, 'Value', 1, 'Userdata', ycols);
    
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set(pcList, 'String', '1st pc');
    set(varHndl, 'String', 'y1');
elseif strcmp(action, 'plot')
    sds = varargin{1}; cmb = varargin{2};
    %get user controls and verify their values
    opts = get(sensList, 'UserData');
    for i = 1:length(opts)
      if get(opts(i), 'Value')
          stype = i;
          tl = get(opts(i), 'Userdata');
          break;
      end
    end
    vnum = get(varHndl, 'Value');
    which_var = get(varHndl, 'Userdata');
    varnum = which_var(vnum, 2); 
    Unum = which_var(vnum, 1); 
    
    pcnum = get(pcList, 'Value');
    hl = get(highlightHndl, 'Value');
    if hl 
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
    else
        thr = [];
    end
    
    sl = get(sealevelChk, 'Value');
    %validate
    if sl
        slv = get(sealevelHndl, 'String');
        %make sure it is numeric
        badnum = 0;
        if isempty(slv)
            badnum = 1;
        elseif ~isstrprop(slv(1), 'digit') && slv(1) ~= '-'
            badnum = 1;
        else
            for i = 2:length(slv)
                if ~isstrprop(slv(i), 'digit') && ~strcmp('.', slv(i))
                    badnum = 1;
                end
            end
            dps = find(slv == '.');
            if (size(dps,2) > 1)
                badnum = 1;
            end
        end
        if badnum
            ShowError('Please enter a number for sea level.');
            uicontrol(sealevelHndl);
            return;
        end
        slv = str2double(slv);
    else
        slv = [];
    end

    srt = get(sortChk, 'Value');
    nm = get(normChk, 'Value');
    
    opts = get(scaleHndl, 'UserData');
    for i = 1:length(opts)
        if get(opts(i), 'Value')
            scl = i;
            break;
        end
    end

   plot_comp(sds, stype, tl, Unum, varnum, pcnum, hl, thr, sl, slv, srt, nm, scl, cmb);

elseif strcmp(action, 'synch')
    %set a control value

elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    %input arg 2 is whole contents of file, idx is where to start reading it
    %return value is where next plot type needs to start
    idx = varargin{1};
    vals = varargin{2};
    senstype = vals{idx};idx = idx + 1;
    var = vals{idx};idx = idx + 1;
    nm = vals{idx};idx = idx + 1;
    srt = vals{idx};idx = idx + 1;
    hl = vals{idx};idx = idx + 1;
    thr = vals{idx};idx = idx + 1;
    sc = vals{idx};idx = idx + 1;
    sl = vals{idx};idx = idx + 1;
    slv = vals{idx};idx = idx + 1;
   
    
    opts = get(sensList, 'UserData');
    set(opts(str2double(senstype)), 'Value', 1);
    numvar = length(get(varHndl, 'String'));
    var = str2double(var);
    m = find( var > numvar);
    var(m) = [];
    set(varHndl, 'Value', var);
    set(normChk, 'Value', str2double(nm));
    
    set(sortChk, 'Value', str2double(srt));
    set(highlightHndl, 'Value', str2double(hl));
    set(thresholdHndl, 'String', thr);

    opts = get(scaleHndl, 'UserData');
    set(opts(str2double(sc)), 'Value', 1);
    set(sealevelChk, 'Value', str2double(sl));
    set(sealevelHndl, 'String', slv);
    
    sa_plotcomposite('changeType');
    
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
   fprintf(fp, '%d\n', get(varHndl, 'Value'));
   fprintf(fp, '%d\n', get(normChk, 'Value'));
   fprintf(fp, '%d\n', get(sortChk, 'Value'));
   fprintf(fp, '%d\n', get(highlightHndl, 'Value'));
   fprintf(fp, '%s\n', get(thresholdHndl, 'String')); 
   opts = get(scaleHndl, 'UserData');
   for i = 1:length(opts)
      if get(opts(i), 'Value')
          fprintf(fp, '%d\n', i);
          break;
      end
   end
   fprintf(fp, '%d\n', get(sealevelChk, 'Value'));
   fprintf(fp, '%s\n', get(sealevelHndl, 'String'));
   

%========================================================================
elseif strcmp(action, 'changeType')
   opts = get(sensList, 'UserData');
   for i = 1:length(opts)
      if get(opts(i), 'Value')
          t = i;
          break;
      end
   end
   
   if t == 1
       set(txtHndl,'String', '\sigma_jU_{j} will be plotted');
   else
       set(txtHndl,'String', '|\sigma_jU_{j}| * max |W_j| will be plotted');
   end
end


%==========================================================================
function plot_comp(sds, stype, tl, Unum, varnum, pcnum, hl, thr, sl, slv, srt, nm, scl, cmb)
    
%plot for the seperate dgs and the same dgs takenfrom the combined sds
global plot_font_size

if cmb
    numplots = 2;
else
    numplots = 1;
end
    
for p = 1:numplots
    %calculate sensitivity and find global max
    if p == 1
        U = sds.U_all{Unum};
        V = sds.V_all{Unum};
        sig = sds.spec_all{Unum};
        S = sds.strengths{Unum};    
        name = [sds.mymodel ' Composite Plot from '  sds.exptnames{Unum}];

    else
        %extract requested var from combined plot
        startpos = 1;
        for i = 1:Unum-1
           startpos = startpos + size(sds.U_all{i}, 1); 
        end
        endpos = startpos + size(sds.U_all{Unum}, 1) - 1;
        U = sds.bigU(startpos:endpos, :);
        V = sds.bigV;
        sig = sds.bigspec;
        S = sds.bigstrengths;       
        name = [sds.mymodel ' Composite Plot from '  sds.exptnames{Unum} ' from combined SDS'];
    end
    
    tspan = sds.t{Unum}; 
    vn = sds.vnames{Unum};
    vn = vn{varnum};
    y = sds.lc{Unum}(:,varnum);
    
    for i=1:size(U,2)
        U(:,i)=sig(i)*U(:,i);
    end
    U1 = U;
    
   %get global max for highlighting
    
    if stype == 2
        W = inv(V);
        for i=1:size(U1,2)
            U1(:,i) = abs(U1(:,i)) * max(abs(W(i,:))); % U set to be fi,m
        end
    end
   Umax = max(max(abs(U1)));
    
    %extract pc * var combination required
    
    tlen = length(tspan);
    %extract PC
    U = U(:,pcnum);
    U = U((varnum-1)*tlen+1:varnum*tlen);
    %this is sigma*U at present
    
    %interpolate for heat map
    %make sure timepoints equally spaced
     th = (tspan(end)-tspan(1))/(length(tspan)-1);
     ti = [tspan(1):th:tspan(end)];
     Ui = interp1(tspan, U, ti);
     
    %data for heat map of derivatives
    %must take derivative of interpolated data
    dU = derv(Ui);
    
    %multiply by Wij if required
    if stype == 2  
        Wij = max(abs(W(pcnum,:)));
        U = abs(U) * Wij;
        Ui = abs(Ui) * Wij;
        dU = abs(dU) * Wij; 
    end
    
    
    pnames = sds.parn;
    
    if numplots == 1 
        pos = get_size_of_figure();
    elseif p == 1
        pos = [0 0 0.5 1];
    else
        pos = [0.5 0 0.5 1];
    end
    
    newfig = figure('NumberTitle', 'off', 'Name', name,  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]); %MD background
    
    tstr = [sds.mymodel ' Composite plot of variable ' vn ' and PC ' num2str(pcnum)];
    if hl
        tstr = [tstr ', highlighting regions above ' num2str(thr*100) '% of the global max ' num2str(Umax)];
    end
    uicontrol('Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'normalized','FontSize',0.5,'Position',[7.5/100 95/100 88.725/100 5/100],'String',tstr ,'BackgroundColor', get(gcf, 'Color'));    
    
    %heat map
    pos = [7.5/100 84/100 88.725/100 5/100];
    axes('Parent', newfig, 'Position',pos);
    
   
    imagesc(ti,[],Ui);
    
    set(gca, 'YTickLabel', [], 'YTick', [], 'XTickLabel', [], 'XTick', [],'FontSize', plot_font_size); %MD fontsize
    title(tl{1},  'Units','normalized','FontUnits', 'normalized','FontSize',0.5,'HorizontalAlignment','center','BackgroundColor', get(gcf, 'Color'));
    %add threshold
    if hl
        valsAbove = find(abs(Ui)>(thr * Umax));
        pt = 1;
        while pt <= length(valsAbove)
            numVals = 1;
            for num = 1:length(valsAbove)-pt
                if valsAbove(pt+ num) ~= (valsAbove(pt) + num)
                    break;
                end
                numVals = numVals + 1;
            end
            lblStart = (valsAbove(pt) - 0.5) / length(ti);
            lblEnd = (valsAbove(pt + numVals -1)+0.5) / length(ti);
            lblwidth = lblEnd - lblStart;
            lblleft = lblStart;
            lblleft = pos(1) + lblleft * pos(3);
            lblleft = lblleft - (lblwidth/(numVals*2));
            lblwidth = lblwidth * pos(3);
            lblpos = [lblleft pos(2) lblwidth pos(4)/2];
            uicontrol('Parent', newfig,'Units','normalized', 'Style', 'tex', 'String', '', 'BackgroundColor', 'm', 'Position', lblpos, 'TooltipString', char(strcat({'Region over '}, num2str((thr * Umax)))));
            pt = pt + numVals;
        end
    else
        valsAbove = [];
    end
    
    %same data plotted
    pos = [7.5/100 66.5/100 88.725/100 12.5/100];
    axes('Parent', newfig, 'Position',pos);
    plot(ti,Ui, 'b');
    xlim([ti(1) ti(end)]);
    hold on;
    ylabel(tl{1}, 'fontsize', plot_font_size);
    %add threshold
    %need to recalculate as this is for uninterpolated data - NO
%     if hl
%         valsAbove = find(abs(U)>(thr * Umax));
%     else
%         valsAbove = [];
%     end
    if ~isempty(valsAbove)
        plot(ti(valsAbove), Ui(valsAbove), 'Linestyle', 'none', 'Marker', 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor', 'b');
    end
    hold off;
    
   
     
    pos = [7.5/100 52.5/100 88.725/100 5/100];
    axes('Parent', newfig, 'Position',pos);
    imagesc(ti, [], dU);
    set(gca, 'YTickLabel', [], 'YTick', [], 'XTickLabel', [], 'XTick', []);
    
    title(tl{2}, 'Units','normalized','FontUnits', 'normalized','FontSize',0.5,'HorizontalAlignment','center','BackgroundColor', get(gcf, 'Color'));
    
    
    % time series
    pos = [7.5/100 35/100 88.725/100 12.5/100];
    axes('Parent', newfig, 'Position',pos);
    plot(tspan,y, 'g');
    hold on;
    ylabel('y', 'fontsize', plot_font_size);
    xlim([tspan(1) tspan(end)]);
    %add pc region over threshold
    yi = interp1(tspan, y, ti);
    if ~isempty(valsAbove)
        plot(ti(valsAbove), yi(valsAbove), 'Linestyle', 'none', 'Marker', 'o', 'MarkerFaceColor','none', 'MarkerEdgeColor', 'g');
    end
    xlabel('Time', 'fontsize', 12);
    hold off;
    
    %strengths
    zdata1 = S;
    
    if scl == 1
        zlbl = 'S';
    elseif scl == 2
        zlbl = '|S|';
        zdata1 = abs(zdata1);
    else
        zlbl = 'log_{10}|S|';
        warning off MATLAB:log:logOfZero;
        zdata1 = log10(abs(zdata1));%+ and - values
        warning on MATLAB:log:logOfZero;
    end
    
    if nm
        zdata1 = zdata1-max(max(zdata1));%shifted down x axis so peak  is zero
    end
    if sl
        zdata1=max(zdata1,slv);%anyhtin gbelow sea level set to sea level
        zdata1=zdata1-slv;%sea level set to zero, so z data1 shows height above seal level, all positive
    end
    
    pos = [7.5/100 10/100 88.725/100 12/100];
    
    np = size(zdata1,2);
    axes1 = axes('Parent',newfig, 'Position', pos);
    
    toplot = zdata1(pcnum,:);
    
    if srt
        %sort strengths by size,
        [toplot, idx] = sort(toplot,'descend');
    else
        idx = 1:np;
    end
    bar(toplot, 'r');
    %label cols
    yv = get(gca, 'YLim');
    yv = yv(2) + diff(yv)/25;
    
    for i = 1:length(toplot)
        text('parent', gca, 'string', pnames(idx(i)), 'rotation', 90, 'position', [i yv], 'fontsize', 12);
    end
    
    %correct the scale
    if sl
        lbls = get(gca, 'YTickLabel');
        lbls = sscanf(lbls, '%f') + slv;
        set(gca, 'YTickLabel', lbls);
    end
    xlabel('k_i', 'fontsize', plot_font_size);
    xlim([0 np+1]);
    ylabel(zlbl, 'fontsize', plot_font_size);
    set(axes1,'YGrid', 'on');
  
end


%========================================================
 
 function r = derv(v)
 
 %return derivative of vector v
 
 %first add extra point by linear extrapolation
 v(end + 1) = v(end) + v(end) - v(end - 1);
 r = diff(v);
 
 %This function doesn't need to kno wtime values as it is onyl ever called
 %with interpolated data, so all dt are equal.
 
 %=========================================================================

function update_scale(group, event, norm, sealevel, sealevelbox)

%disable normalise and sea level if raw data is selected. THis is because
%selecting these options with raw you will lose the information about sign

% For example, let me  take raw values, x=[-3 0.1 0.2]. I am interested in 
% ordering by size, not sign, so matlab function order gives me the wrong info
% - it ranks the first value of x as the lowest value.  
% If I now take log10 of absolute value, I get  log10(abs(x))=[0.4771, -1,-0.6990]
% and now, ordering is again correct: it will point out that the first value as
% the largest and second value as lowest. Normalization of log10(abs(x)) 
% doesn't change the ordering, as it just shifts the values down to [0, -1.4771, -1.1761]. 

opt = event.NewValue;
if strcmp(get(opt, 'string'), 'raw data')
    %checkboxes
    set([sealevel norm], 'value', 0, 'enable', 'off');
    %text box
    set(sealevelbox, 'enable', 'off');
    
else
    %checkboxes
    set([sealevel norm], 'enable', 'on');
    %text box
    set(sealevelbox, 'enable', 'on');
end
