function r = sa_plotsensitivity(action, varargin)

global maincol btncol 
persistent sensList txtHndl axHndl varHndl derivHndl;
persistent pcList; %which parameters listbox
persistent panel selAllHndl clearlHndl divHndl limHndl sortHndl colourHndl highlightHndl thresholdHndl ptHndl colourList;

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
    sensList = uibuttongroup('Units','centimeters','SelectionChangeFcn','sa_plotsensitivity(''changeType'');', 'Position', [pwidth/2 pheight-2.15 pwidth/2-0.25 1.25], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    s1=uicontrol('HorizontalAlignment', 'right','Parent',sensList,'string', 'sig_j * U_j' ,'Units','normalized','Style','radiobutton', 'position',[0/100 50/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    s2=uicontrol('HorizontalAlignment', 'right','Parent',sensList,'string', 'f(i,m)' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(sensList, 'UserData', [s1 s2]);
    %plot the derivative
    derivHndl = uicontrol('callback','sa_plotsensitivity(''changeType'');', 'Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-3 pwidth/2-1 0.5],'string','Plot the derivative','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

  
    axHndl = axes('Units','centimeters','parent', panel, 'position', [pwidth/2-0.25 pheight-3.1 pwidth/2-0.25 0.5], 'xtick', [], 'ytick', [], 'color', 'none', 'box', 'off', 'visible', 'off');
    xlim([0 1]); ylim([0 1]);
    txtHndl = text(0,0.6, 'text', 'parent', axHndl, 'visible', 'on');
    
    %which pcs to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-4.5 pwidth/2-1 1],'string','Select Principal Components','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    pcList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-5.25 pwidth/2-0.5 1.75],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
   
     
    %which vars to plot, all or the most important
    varHndl = uibuttongroup('Units','centimeters','Position', [0.5 pheight-6.5 pwidth/2 1.25], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    r1=uicontrol('HorizontalAlignment', 'right','Parent',varHndl,'string', 'Show all variables' ,'Units','normalized','Style','radiobutton', 'position',[0/100 50/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    r2=uicontrol('HorizontalAlignment', 'right','Parent',varHndl,'string', 'Show those exceeding' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(varHndl, 'UserData', [r1 r2]);
    
    limHndl = uicontrol('HorizontalAlignment', 'right','Parent',panel,'string', '5' ,'Units','centimeters','Style','edit', 'position',[pwidth/2  pheight-6.5 0.75 0.6],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor','w', 'Value', 1);
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2+0.9  pheight-6.5 4 0.5],'string','% of the global max','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    
    %sort variables within by size?
    sortHndl = uicontrol('Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-7.25 pwidth-1 0.5],'string','Sort variables by importance','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    %highlight regions
    highlightHndl = uicontrol('Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-8 pwidth/2-0.5 0.5],'string','Highlight regions above','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    thresholdHndl = uicontrol('HorizontalAlignment', 'right','Parent',panel,'string', '50' ,'Units','centimeters','Style','edit', 'position',[pwidth/2  pheight-8 0.75 0.6],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor','w', 'Value', 1);
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[pwidth/2+0.9  pheight-8 4 0.5],'string','% of the global max','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    %show peaks and troughs of time series
    ptHndl = uicontrol('Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 pheight-8.75 pwidth-1 0.5],'string','Superimpose variable time series peaks and troughs','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);   
    %colour scaling
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 0.5 pwidth/2-0.5 0.5],'string','Scaling for the colour maps','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    colourList = uicontrol('Parent',panel, 'Units','centimeters','Style','popup','Max', 1, 'Min', 0, 'String','scale by maxima|scale by amplitude|scale all equally|scale to fill colour space', 'position',[pwidth/2 0.5 pwidth/2-0.5 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Value', 1);
    
    sa_plotsensitivity('changeType');
    
    r = panel;
elseif strcmp(action, 'name')
    r = 'Sensitivity Heat Map';
elseif strcmp(action, 'description')
    r = 'Plots the sensitivity of the variables of the solution to the principal components versus time. The peaks and troughs of the variable time sreies can be superimposed.';
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
    sds = varargin{1};
    cmb = varargin{2};
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
    if vartype == 2
        %limt is a percentage
        limt = get(limHndl, 'String');
        %make sure it is numeric
        badnum = 0;
        if isempty(limt)
            badnum = 1;
        elseif ~isstrprop(limt(1), 'digit')
            badnum = 1;
        else
            for i = 2:length(limt)
                if ~isstrprop(limt(i), 'digit') && ~strcmp('.', limt(i))
                    badnum = 1;
                end
            end
            dps = find(limt == '.');
            if (size(dps,2) > 1)
                badnum = 1;
            end
        end
        if badnum
            ShowError('Please enter a number for percentage.');
            uicontrol(limHndl);
            return;
        end
        limt = str2double(limt);
        limt = min(limt, 100);
        limt = limt / 100;
    else
        limt = [];
    end
    
    srt = get(sortHndl, 'Value');
    hl = get(highlightHndl, 'Value');
    
    %threshold is a percentage
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
    
    pt = get(ptHndl, 'Value');
    colour = get(colourList, 'Value');
    
    pcstoplot = get(pcList, 'Value');
    
    if isempty(pcstoplot)
        ShowError('Please select one or more principal components to plot.');
    else
        pc_heatmap4(sds, stype, vartype, limt, hl, thr, tl, deriv, srt, colour, pcstoplot, pt, cmb);
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
    limt = vals{idx};idx = idx + 1;
    srt = vals{idx};idx = idx + 1;
    hl = vals{idx};idx = idx + 1;
    thr = vals{idx};idx = idx + 1;
    pt = vals{idx};idx = idx + 1;
    colour = vals{idx};idx = idx + 1;
    
    opts = get(sensList, 'UserData');
    set(opts(str2double(senstype)), 'Value', 1);
    set(derivHndl, 'Value', str2double(deriv));
    opts = get(varHndl, 'UserData');
    set(opts(str2double(var)), 'Value', 1);
    set(limHndl, 'String', limt);
    set(sortHndl, 'Value', str2double(srt));
    set(highlightHndl, 'Value', str2double(hl));
    set(thresholdHndl, 'String', thr);
    set(ptHndl, 'Value', str2double(pt));
    set(colourList, 'Value', str2double(colour));
    
    sa_plotsensitivity('changeType');
    
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
    fprintf(fp, '%s\n', get(limHndl, 'String'));
    fprintf(fp, '%d\n', get(sortHndl, 'Value'));
    fprintf(fp, '%d\n', get(highlightHndl, 'Value'));
    fprintf(fp, '%s\n', get(thresholdHndl, 'String'));
    fprintf(fp, '%d\n', get(ptHndl, 'Value'));
    fprintf(fp, '%d\n', get(colourList, 'Value'));

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


%==========================================================================
function pc_heatmap4(sds, stype, vartype, limt, hl, thr, tl, deriv, srt, colourtype, pcstoplot, pt, cmb)

% this function plots the heatmap in the paper. It calculates for which pcs
% and which variables there is a pc-var pair whose amplitude is greater
% than tol_ratio*max(abs(U1))and then plots these using a colormap to show
% amplitude. U1 is the matrix U with the ith column scaled by sigma_i
%
% it also plots a black bar at the minimum of the time-series for the
% particular variable and a white bar for the maximum

%find variable peaks and troughs if these are to b esuperimposed

global plot_font_size

maxmin_scale = 0;
amplitude_scale = 0;
no_scaling = 0;
fill_scale = 0;

if colourtype == 1
    maxmin_scale = 1;
elseif colourtype == 2  
    amplitude_scale = 1;
elseif colourtype == 3
    no_scaling = 1;
else
   fill_scale = 1;
end

w_pcs = pcstoplot;
numpcs=length(w_pcs);
numcolours =length(colormap);%probably 64

% adjust parameters below to move the heatmaps

% heat rectangle
hr_left=20/100;
hr_width=55/100;
hr_top = 90/100;
hr_height= hr_top - 7.5/100;

maxHeight = 1; %0.025; % was0.045; %of text labels
fontsize = 0.65;

numplots = length(sds.U_all);

if ~isempty(sds.bigU) && cmb
    numplots = numplots * 2;
end

pnum = 0;

for p = 1:length(sds.U_all);
    
    soln = sds.lc{p};
    tspan = sds.t{p};
    var_names = sds.vnames{p};
    U = sds.U_all{p};
    sig = sds.spec_all{p};
    V = sds.V_all{p};
    sublen=length(tspan);

    if pt
        %find minima and maxima of time series
        [peaks, troughs] = GetPeaksandTroughs(soln, tspan);  
    else
        troughs = [];
        peaks = [];
    end
    
    [U1, U1i, ti, globalmax, globalmin, globalamp] = GetSensitivity(stype, U, sig, V, deriv, size(soln,2), tspan);
 %min is set to 0 after amp clacluated   
    [nvar, w_vars] = VarsToPlot(w_pcs, vartype, size(soln,2), U1, limt, sublen);
    
    if sum(nvar) > 50
        ShowError(['Too many variables were selected to display for plot ' sds.exptnames{p} '. If you selected all variables, try selecting fewer principal components. Otherwise, try setting a higher threshold for display.']);
        continue;
    end
    if sum(nvar) == 0
        ShowError(['No variables were selected to display for plot ' sds.exptnames{p} '. Try selecting a different principal component, or select all variables.']);
        continue;
    end
    
    if srt
        %sort vars within pc according to their scale
        w_vars = SortVars(w_pcs, maxmin_scale, w_vars, sublen, U1, globalmax, globalmin); 
    end

    [vwidth, sep, bsep] = GetHeight(nvar, numpcs, hr_height);
  
    %ensure text is centered vertically
    %if few plots, font is reduced in size to not too long
    lblHeight = min(vwidth, maxHeight);
    
    %create a figure for this dgs
    pnum = pnum + 1;
    newfig = CreateFigure(sds.mymodel, numplots, pnum, hr_left, hr_width, hr_top, lblHeight, fontsize);
    figData = tspan;
    h = [];
    nexttop= hr_top - vwidth;
    count = 1;
    
    %plot heatmaps
    for i=1:numpcs %for each pc
        
        for j=w_vars{i}%for each var in pc
            
            % extract the time-series for the jth variable of the ith pc
            
            %save real timepoints forplotting whenuser click on heat map
            Y = U1((j-1)*sublen+1:j*sublen,w_pcs(i));
            figData = [figData Y];
            
            %plot using interpolated data
            Yi = U1i((j-1)*sublen+1:j*sublen,w_pcs(i));
            %create axes
            pos = [hr_left,nexttop,hr_width,vwidth];
            h(count)=axes('Parent', newfig, 'Position',pos);
            callbackstr = strcat('sa_plotsensdata(', num2str(w_pcs(i)), ',' ,num2str(j), ',''', var_names{j} , ''',  ''', char(tl), ''',', num2str(count+1), ');');
            set(h(count),'ButtonDownFcn', callbackstr);        
            
            %scale according to users selection.
            [Yscaled, scale] = ScaleData(Yi, globalamp, globalmax, globalmin, stype, numcolours, maxmin_scale, amplitude_scale, no_scaling, fill_scale);
            
            % this draws the heat map
           
            image(ti,[],Yscaled','ButtonDownFcn', callbackstr);
             % add the labels to left and right
            
            pos = [hr_left/10,nexttop,hr_left*0.9,lblHeight];
            k1=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',['PC ' num2str(w_pcs(i)) ', ' var_names{j}], 'TooltipString',char(['PC ' num2str(w_pcs(i)) ', ' var_names{j}]) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));
            pos = [hr_left + hr_width + 0.01,nexttop, 0.05,lblHeight];
            k2=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',num2str(scale,'%5.2f'), 'TooltipString',char(num2str(scale,'%5.2f')) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));
            pos = [hr_left + hr_width + 0.06,nexttop, 0.05,lblHeight];
            k3=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',[num2str(max(Y),'%5.2f')], 'TooltipString',char(num2str(max(Y),'%5.2f')) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));
            pos = [hr_left + hr_width + 0.11,nexttop, 0.05,lblHeight];
            k4=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',[num2str(min(Y),'%5.2f')], 'TooltipString',char(num2str(min(Y),'%5.2f')) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));
              
            
            %mark values above threshold
            if hl
                MarkThreshold(Yi, thr * globalamp, newfig, ti, get(h(count),'Position'));
            end
            
            % the next bit is about drawing the black and white lines to mark
            % the phases of maxima and minima
            if pt
                MarkPeaksandTroughs(Y, peaks, troughs, newfig, tspan, get(h(count),'Position'), j);
            end
   %say if periodic to distinguish expts               
            if count == 1
                tstr = [sds.mymodel ' Sensitivity, ' tl ' from ' sds.exptnames{p}, ', max value ' num2str(globalamp)];
                uicontrol('Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',plot_font_size,'Position',[hr_left,hr_top,hr_width,1-hr_top],'String',tstr ,'BackgroundColor', get(gcf, 'Color'));
            end
        
            nexttop=nexttop-vwidth-sep;
            count = count+1;
        end
        nexttop=nexttop+sep-bsep;
    end

    xlabel('Time','FontSize',plot_font_size);
    set(h(1:end-1),'Visible','off');
    set(h(end),'Box','off');
    set(h(end),'YTickLabel',[]);

    AddColourBar(newfig, numcolours, globalmax, globalmin, globalamp, maxmin_scale, fill_scale, stype);
    set(newfig, 'Userdata', figData);
end

%now plot combined
if ~isempty(sds.bigU) && cmb
    sig = sds.bigspec;  
    V = sds.bigV;
    startpos = 1;   
    for p = 1:length(sds.U_all);
        
        soln = sds.lc{p};
        tspan = sds.t{p};
        var_names = sds.vnames{p};       
        dgs_len = size(sds.U_all{p}, 1);
        endpos = startpos + dgs_len-1;
        %extract this dgs's component from combined dgs
        U = sds.bigU(startpos:endpos, :);
        startpos = endpos+1;       
        sublen=length(tspan);

        if pt
            %find minima and maxima of time series
            [peaks, troughs] = GetPeaksandTroughs(soln, tspan);
        else
            troughs = [];
            peaks = [];
        end

        [U1, U1i, ti, globalmax, globalmin, globalamp] = GetSensitivity(stype, U, sig, V, deriv, size(soln,2), tspan);
        %min is set to 0 after amp clacluated
        [nvar, w_vars] = VarsToPlot(w_pcs, vartype, size(soln,2), U1, limt, sublen);

        if sum(nvar) > 50
            ShowError(['Too many variables were selected to display for the plot of '  sds.exptnames{p} ' from the combined SDS. If you selected all variables, try selecting fewer principal components. Otherwise, try setting a higher threshold for display.']);
            continue;
        end
        if sum(nvar) == 0
            ShowError(['No variables were selected to display for the plot of '  sds.exptnames{p} ' from the combined SDS. Try selecting a different principal component, or select all variables.']);
            continue;
        end
        
        if srt
            %sort vars within pc according to their scale
            w_vars = SortVars(w_pcs, maxmin_scale, w_vars, sublen, U1, globalmax, globalmin);
        end

        [vwidth, sep, bsep] = GetHeight(nvar, numpcs, hr_height);

        %ensure text is centered vertically
        %if few plots, font is reduced in size to not too long
        lblHeight = min(vwidth, maxHeight);

        %create a figure for this dgs
        pnum = pnum + 1;
        newfig = CreateFigure(sds.mymodel, numplots, pnum, hr_left, hr_width, hr_top, lblHeight, fontsize);
        set(newfig, 'name', [get(newfig, 'name') ' combined SDS']); %MD fontsize
        
        figData = tspan;
        h = [];
        nexttop= hr_top - vwidth;
        count = 1;

        %plot heatmaps
        for i=1:numpcs %for each pc

            for j=w_vars{i}%for each var in pc
                
                % extract the time-series for the jth variable of the ith pc
                %save real timepoints forplotting whenuser click on heat
                %map
                Y = U1((j-1)*sublen+1:j*sublen,w_pcs(i));
                figData = [figData Y];
                
                 %plot using interpolated data
                Yi = U1i((j-1)*sublen+1:j*sublen,w_pcs(i));
                %create axes
                pos = [hr_left,nexttop,hr_width,vwidth];
                h(count)=axes('Parent', newfig, 'Position',pos);
                callbackstr = strcat('sa_plotsensdata(', num2str(w_pcs(i)), ',' ,num2str(j), ',''', var_names{j} , ''',  ''', char([tl ' from combined SDS']), ''',', num2str(count+1), ');');
                set(h(count),'ButtonDownFcn', callbackstr);

                %scale according to users selection.
                [Yscaled, scale] = ScaleData(Yi, globalamp, globalmax, globalmin, stype, numcolours, maxmin_scale, amplitude_scale, no_scaling, fill_scale);

                % this draws the heat map
              
                image(ti,[],Yscaled','ButtonDownFcn', callbackstr);
                % add the labels to left and right

             %   pos = [hr_left/4,nexttop,hr_left-0.1,lblHeight];
                pos = [hr_left/10,nexttop,hr_left*0.9,lblHeight];
                k1=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',['PC ' num2str(w_pcs(i)) ', ' var_names{j}], 'TooltipString',char(['PC ' num2str(w_pcs(i)) ', ' var_names{j}]) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));
                pos = [hr_left + hr_width + 0.01,nexttop, 0.05,lblHeight];
                k2=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',num2str(scale,'%5.2f'), 'TooltipString',char(num2str(scale,'%5.2f')) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));
                pos = [hr_left + hr_width + 0.06,nexttop, 0.05,lblHeight];
                k3=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',[num2str(max(Y),'%5.2f')], 'TooltipString',char(num2str(max(Y),'%5.2f')) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));
                pos = [hr_left + hr_width + 0.11,nexttop, 0.05,lblHeight];
                k4=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String',[num2str(min(Y),'%5.2f')], 'TooltipString',char(num2str(min(Y),'%5.2f')) , 'ButtondownFcn', callbackstr,'BackgroundColor', get(gcf, 'Color'));


                %mark values above threshold
                if hl
                    MarkThreshold(Yi, thr * globalamp, newfig, ti, get(h(count),'Position'));
                end

                % the next bit is about drawing the black and white lines to mark
                % the phases of maxima and minima
                if pt
                    MarkPeaksandTroughs(Y, peaks, troughs, newfig, tspan, get(h(count),'Position'), j);
                end

                if count == 1
                    tstr = [sds.mymodel ' Sensitivity, ' tl ' of ' sds.exptnames{p}, ' from the combined SDS, max value ' num2str(globalamp)];
                    uicontrol('Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',plot_font_size,'Position',[hr_left,hr_top,hr_width,1-hr_top],'String',tstr ,'BackgroundColor', get(gcf, 'Color'));
                end

                nexttop=nexttop-vwidth-sep;
                count = count+1;
            end
            nexttop=nexttop+sep-bsep;
        end

        xlabel('Time');
        set(h(1:end-1),'Visible','off');
        set(h(end),'Box','off');
        set(h(end),'YTickLabel',[]);

        AddColourBar(newfig, numcolours, globalmax, globalmin, globalamp, maxmin_scale, fill_scale, stype);
        set(newfig, 'Userdata', figData);
    end
end
 
%========================================================
 
 function r = derv(v, t)
 
 %return derivative of vector v
 
 %first add extra point by linear extrapolation
 v(end + 1) = v(end) + v(end) - v(end - 1);
 t(end + 1) = t(end) + t(end) - t(end - 1);
 dv = diff(v);
 dt = diff(t);
 r = dv ./ dt;

%========================================================
 
function [peaks, troughs] = GetPeaksandTroughs(soln, tspan)

 %find minima and maxima
 troughs = cell(0);
 peaks = cell(0);
 for v = 1:size(soln, 2)
     pk = [];
     tr = [];
     %note wont find peaks and troughs where there are 2 adjacent
     %min or max values.
     %this will find all peaks and troughsd, whereas theory onl y finds the
     %first
     for tp = 2:length(tspan) -1  %for each timepoint
         if (soln(tp,v) > soln(tp-1,v)) && (soln(tp,v) > soln(tp+1,v))
             pk = [pk tp];
         elseif (soln(tp,v) < soln(tp-1,v)) && (soln(tp,v) < soln(tp+1,v))
             tr = [tr tp];
         end
     end
     troughs{v} = tr;
     peaks{v} = pk;
 end
         
%========================================================
 
function [U1, U1i, ti, globalmax, globalmin, globalamp] = GetSensitivity(stype, U, sig, V, deriv, dim, tspan)
  
    % inputs
    % stype, flag toindicate formula for sensitivity
    % U pc values
    % sig singular values
    % V rest of output fron SVD
    % deriv flag toindicate whether to use derivative of sensitivity
    % dim num model variables
    % tspan timepoints selected by user
    
    % Outputs
    % U1 sensitivty 
    % U1i sensitivity interpolated over tspan wit hequally spaced points
    % ti, the equally spaced timepoints
    % Other outputs are max/min values
    
    % U1 is used for diaplying ther raw data and in the plot command
    % but U1i is needed for heat maps as these assume evenly spaced
    % timepoints
    
    
     th = (tspan(end)-tspan(1))/(length(tspan)-1);
     ti = tspan(1):th:tspan(end);

     sublen = length(tspan);
                  
    if stype == 1
        W = [];
    else
        W = inv(V);
    end

    U=U(:,1:end-1); % ignore last column
    
    [cn,rn]=size(U);

    %%
    U1=zeros(size(U));
    U1i=zeros(size(U));
    
    for i=1:rn
        U1(:,i)=sig(i)*U(:,i); %sensitivity is sigma*U
    end
    
    for i=1:rn %for each pc
        for j = 1:dim %for each variable
            Y = U1((j-1)*sublen+1:j*sublen,i);%for each time series
            %interpolate at this point
            Yi = interp1(tspan, Y, ti);
  %   s.y = Y;s.Yi=Yi;s.ti=ti;s.tspan=tspan;
   %  save('s.mat', 's');
            if deriv
                U1i((j-1)*sublen+1:j*sublen,i) = derv(Yi, ti); % d(sigma*U)/dt , was abs(derv(Y));
                U1((j-1)*sublen+1:j*sublen,i) = derv(Y, tspan);
            else
                U1i((j-1)*sublen+1:j*sublen,i) = Yi;    %interpolated sigma*U
            end
        end
        if ~isempty(W)
            Wij = max(abs(W(i,:)));
            %U1 is |U1| * |Wij|
            U1(:,i) = abs(U1(:,i)) * Wij;
            U1i(:,i) = abs(U1i(:,i)) * Wij;
        end
    end

    globalmax = max(max(U1));
    globalmin = min(min(U1));%used for colourbar
    globalamp = max(abs(globalmax), abs(globalmin));%used for threshold
    globalmin = min(globalmin, 0);
   
    
%=========================================================
function [nvar, w_vars] = VarsToPlot(w_pcs, vartype, dim, U1, limt, sublen)
    
    
    nvar = zeros(length(w_pcs), 1);    %total number of plots
    
    for i=1:length(w_pcs)
        w_vars{i}=[];
    end
    if vartype == 1
        % show all variables for selected pcs
        for i=1:length(w_pcs)
            w_vars{i}= 1:dim;
            nvar(i)=length(w_vars{i});
        end
    else
        m=max(max(abs(U1)));
        tol=limt*m;
        %find vars which exceed tol
        for i=1:length(w_pcs)
            temp=[];
            for j = 1:dim
                if max(abs(U1((j-1)*sublen+1:j*sublen,w_pcs(i))))>tol
                    temp=[temp j];
                end
            end
            w_vars{i}=temp;
            nvar(i)=length(w_vars{i});
        end
    end
    
%=============================================================
function srt_vars = SortVars(w_pcs, maxmin_scale, w_vars, sublen, U1, gmax, gmin)
    
    %sort vars within pc according to their scale
    srt_vars = cell(size(w_vars));
    
    for pc = 1:length(w_pcs)
        scales = [];
        if maxmin_scale
            for v=w_vars{pc}%for each var in pc calc its scale
                Y = U1((v-1)*sublen+1:v*sublen,w_pcs(pc));
                if max(Y)>abs(min(Y));
                    scales = [scales max(Y)/gmax];
                else
                    scales = [scales abs(min(Y))/abs(gmin)];
                end
            end
        else
            for v=w_vars{pc}%for each var in pc calc its scale
                scales = [scales max(abs(U1((v-1)*sublen+1:v*sublen,w_pcs(pc))))];
            end
        end
        %sort elements of W_vars{pc} according to scale
        [scales idx] = sort(scales, 'descend');
        sv = w_vars{pc};
        sv = sv(idx);
        srt_vars{pc} = sv;
    end
    
%====================================================================

    function [vwidth, sep, bsep] = GetHeight(nvar, numpcs, hr_height)
    
    vwidth = 4; 
    bsep = 4;   
    
    total_height=zeros(1,numpcs);
    numblocks = 0;
    for i=1:numpcs
        total_height(i)=nvar(i)*vwidth;
        if nvar(i)
            numblocks = numblocks+1;
            if nvar(i) >= 2
                total_height(i) = total_height(i) + (nvar(i)-1);
            end
        end
    end
    theight=sum(total_height)+(numblocks-1)*bsep;
    
    sep = hr_height/theight;
    bsep = bsep * sep;
    vwidth = vwidth * sep;
   
    
%================================================================
    
function newfig = CreateFigure(mymodel, numplots, pnum, hr_left, hr_width, hr_top, lblHeight, fontsize)
    
    if numplots == 1
        pos = get_size_of_figure();
    else
       tp = (0.4*(pnum-1)/(numplots-1));
       pos = [tp 0.4-tp-0.05 0.6 0.6];
    end
   
    
    newfig = figure('NumberTitle', 'off', 'Name', [mymodel ' Sensitivity'],  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]); %MD background

    pos = [hr_left + hr_width + 0.01,hr_top, 0.035,lblHeight];
    k2=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String','ratio','BackgroundColor', get(gcf, 'Color'));
    %need to align text to bottom of box. Can onyl do this by getting
    %extent property and reducing height of box to fit height of text
    extent = get(k2, 'extent');
    newpos = [pos(1) pos(2) extent(3) extent(4)]; %extent(4) id height of the font
    set(k2, 'position', newpos);
    
    pos = [hr_left + hr_width + 0.06,hr_top, 0.035,lblHeight];
    k3=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String','max','BackgroundColor', get(gcf, 'Color'));
    extent = get(k3, 'extent');
    newpos = [pos(1) pos(2) extent(3) extent(4)]; %extent(4) id height of the font
    set(k3, 'position', newpos);
    
    pos = [hr_left + hr_width + 0.11,hr_top, 0.035,lblHeight];
    k4=uicontrol('tag', num2str(get(gcf, 'Color')), 'Style', 'text',  'Units','normalized','Parent',newfig,'FontUnits', 'points','FontSize',11,'Position',pos,'HorizontalAlignment','left','String','min','BackgroundColor', get(gcf, 'Color'));
    extent = get(k4, 'extent');
    newpos = [pos(1) pos(2) extent(3) extent(4)]; %extent(4) id height of the font
    set(k4, 'position', newpos);
    
%===============================================================
    
function [Yscaled, scale] = ScaleData(Y, globalamp, globalmax, globalmin, stype, numcolours, maxmin_scale, amplitude_scale, no_scaling, fill_scale)
        
    Yamp = max(abs(Y));
    %This block determines how the colours are scaled
    %It was added in this version of the file. Not found in pc_heatmap3.m

    if maxmin_scale %DAR
        % this scaling works as follows the maximum and minimum values
        % gmax and gmin of U1 are found. Then for each Y we work our
        % whether the amplitide of its maximum or minimum is bigger -
        % if it is the maximum (resp. minimim) then Y is scaled so that
        % its maximum (resp. minimum) equals gmax (resp. gmin).
        if max(Y)>abs(min(Y));
            scale = max(Y)/globalmax; %re-scaled according to largest value in U1, not just those to be plotted. Won't afect relative sizes         
        else
            scale = abs(min(Y))/abs(globalmin);                
        end
        Yscaled = (Y / scale - globalmin) * numcolours/(globalmax-globalmin);
    end
    if amplitude_scale %DAR
        % this scaling works as follows: the maximum value
        % globalamp of abs(U1) is found. Then for each Y we scale Y so
        % that its amplitude i.e max(abs(Y)) equals globalamp then we
        % map this to the colormap with the full 0 to 64 range corresponding
        % to the range -globalamp to globalamp.
        scale = Yamp/globalamp;
        Yscaled = (Y / scale + globalamp) * numcolours/(2*globalamp);
    end
    if no_scaling %DAR this is unscaled case where all are scaled the same
        % in this scaling all Y's are scaled by the same factor
        % numcolours/globalamp = numcolours/globalamp and then thet are all
        % mapped to the colormap on the scale from -globalamp to globalamp with 0
        % going to the color 32.
        scale = Yamp/globalamp;
        Yscaled = Y * numcolours/(2*globalamp);
        %We need zero to correspond to 32
        Yscaled = Yscaled + numcolours/2;
    end
    if fill_scale %DAR good for blowing up all fi,m's
        scale = Yamp/globalamp;
        Yscaled = (Y / Yamp) * numcolours; %now -64 to +64
        if stype == 1
           %now 0 to 64
            Yscaled = Yscaled/2 +numcolours/2;
        end
    end
    
%================================================================
function MarkThreshold(Y, threshold, newfig, tspan, pos)
    
    
    sublen = length(tspan);
    
    valsAbove = find(abs(Y)>threshold);
    pt = 1;
    while pt <= length(valsAbove)
        numVals = 1;
        %find a set of consecutive Y values that are above threshold
        for num = 1:length(valsAbove)-pt
            if valsAbove(pt+ num) ~= (valsAbove(pt) + num)
                break;
            end
            %length of bar
            numVals = numVals + 1;
        end
        %assumes evenly spaced timepoints
        lblStart = (valsAbove(pt) - 0.5) / sublen;
        lblEnd = (valsAbove(pt + numVals -1)+0.5) / sublen;
        lblwidth = lblEnd - lblStart;
        lblleft = lblStart;
        lblleft = pos(1) + lblleft * pos(3);
        lblleft = lblleft - (lblwidth/(numVals*2));
        lblwidth = lblwidth * pos(3);
        lblpos = [lblleft pos(2) lblwidth pos(4)/2];
        hp = uicontrol('Parent', newfig,'Units','normalized', 'Style', 'tex', 'String', '', 'BackgroundColor', 'm', 'Position', lblpos, 'TooltipString', char(strcat({'Region over '}, num2str(threshold))));
        pt = pt + numVals;
    end
    
%===============================================================
function MarkPeaksandTroughs(Y, peaks, troughs, newfig, tspan, pos, j)
    
    
    if ~isempty(peaks)
        peaktimes = peaks{j};   %these are index values
        for pt = 1:length(peaktimes)
            %add white bar for each peak with tooltip showing time and
            %size
            if peaktimes(pt) > 0 && peaktimes(pt) <= length(tspan)
                vmax = strcat(num2str(tspan(peaktimes(pt))), {'h, '}, num2str(Y(peaktimes(pt))));
                lblwidth = pos(3)/150;
                lblleft = (tspan(peaktimes(pt)) - tspan(1)) / (tspan(end)-tspan(1));
                lblleft = pos(1) + lblleft * pos(3);
                lblleft = lblleft - (lblwidth/2);
                lblpos = [lblleft pos(2) lblwidth pos(4)];
                hp = uicontrol('Parent', newfig,'Units','normalized', 'Style', 'tex', 'String', '', 'BackgroundColor', 'w', 'Position', lblpos, 'TooltipString', char(vmax));
            end
        end
    end

    if ~isempty(troughs)
        troughtimes = troughs{j};   %these are index values
        for tt = 1:length(troughtimes)
            %add black bar for each trough with tooltip showing time and
            %size
            if troughtimes(tt) > 0 && troughtimes(tt) <= length(tspan)
                vmin = strcat(num2str(tspan(troughtimes(tt))), {'h, '}, num2str(Y(troughtimes(tt))));
                lblwidth = pos(3)/150;
                lblleft = (tspan(troughtimes(tt)) - tspan(1)) / (tspan(end)-tspan(1));
                lblleft = pos(1) + lblleft * pos(3);
                lblleft = lblleft - (lblwidth/2);
                lblpos = [lblleft pos(2) lblwidth pos(4)];
                hp = uicontrol('Parent', newfig,'Units','normalized', 'Style', 'tex', 'String', '', 'BackgroundColor', 'k', 'Position', lblpos, 'TooltipString', char(vmin));
            end
        end
    end
    
%====================================================================
function AddColourBar(newfig, numcolours, globalmax, globalmin, globalamp, maxmin_scale, fill_scale, stype)      
       
    h_all = axes('Parent', newfig, 'Position',[0 0.05 0.975 0.9],'Visible','off'); % pos = [left, bottom, width height]
    set(gcf,'CurrentAxes',h_all)

    cb = colorbar('Tag', '', 'YTickMode', 'manual', 'YTickLabelMode', 'manual','YTickLabel', [],'YTick', []);
    yticks = [8:numcolours/8:numcolours];
%     newylabels = yticks / numcolours * globalamp * 2; %scale is -ymax to +ymax
%     newylabels = newylabels - globalamp;

    if maxmin_scale
        CMmax =globalmax;
        CMmin=globalmin;
    else
        CMmax =globalamp;
        if fill_scale && stype == 2 %derivative
            CMmin = 0;
        else
            CMmin=-globalamp;
        end
    end
    newylabels = (CMmax - CMmin)*yticks/numcolours + CMmin; %DAR

    ylabels = cell(length(newylabels),1);
    for i =1:size(ylabels,1)
        ylabels{i} = num2str(newylabels(i), '%4.2f');
    end
    if verLessThan('matlab', '8.4')
        %Ticks are on a scale of 1 to 64
        set(cb, 'YTick', yticks);
    else
        %R2014b
       %Here Limits is by default [0 1], meaning display all 64 colours of colourmap
       %A normalized scale instead
       set(cb, 'YTick', yticks/numcolours);
    end
    set(cb, 'YTickLabel', ylabels, 'FontSize', 11);
   
