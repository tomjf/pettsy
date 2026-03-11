function r = sa_plotstrengths(action, varargin)

global maincol btncol 
persistent parList plotList groupChk sortHndl scaleHndl; 
persistent pcList sealevelHndl sealevelChk normChk; %which pcs listbox
persistent panel selAllParHndl clearParHndl selAllPCHndl clearPCHndl;

persistent sortFirstHndl parOpt 

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
    
    %which type of plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth/2-0.5 0.5],'string','Select a plot type','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);    
    plotList = uicontrol('callback', 'sa_plotstrengths(''changeType'');', 'Parent',panel, 'String', 'Surface plot|3D bar chart|2D bar chart', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','popup', 'position',[pwidth/2 pheight-1.4 3.25 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 9,'BackgroundColor', 'w', 'Value', 1);
    groupChk = uicontrol('Parent',panel, 'String', 'Grouped', 'HorizontalAlignment', 'right', 'Units','centimeters','Style','checkbox', 'position',[pwidth/2+3.25 pheight-1.75 2.25 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 9,'BackgroundColor', maincol, 'Value', 0, 'Enable', 'off');

    %which parameters to plot
    parOpt = uibuttongroup('units', 'centimeters', 'SelectionChangeFcn','sa_plotstrengths(''changePar'');', 'Position', [0.5 pheight-5 pwidth/2-0.5 3], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    par1=uicontrol('HorizontalAlignment', 'right','Parent',parOpt,'string', 'Select Parameters to plot' ,'Units','normalized','Style','radiobutton', 'position',[0/100 75/100 1 25/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    par2=uicontrol('HorizontalAlignment', 'right','Parent',parOpt,'string', 'OR plot most important' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 1 25/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(parOpt, 'UserData', [par1 par2]);
    
    parList = uicontrol('enable', 'on', 'Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','Parameter', 'position',[pwidth/2 pheight-4 pwidth/2-0.5 1.9],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Value', 1);

    %select the params
    selAllParHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-3.4 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Select All', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotstrengths(''selAllPars'');');
    
    clearParHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-4 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Clear', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize',10, ...
        'Callback','sa_plotstrengths(''clearAllPars'');');
    
    sortHndl = uicontrol('enable', 'off', 'Parent',panel,'string', 'sort by 1st PC|sort by Max PC' ,'Units','centimeters','Style','popup', 'position',[pwidth/2+1.75 pheight-4.9 pwidth/2-2.25 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 9, 'Backgroundcolor','w', 'Value', 1);   
    sortFirstHndl = uicontrol('enable', 'off', 'HorizontalAlignment', 'right','Parent',panel,'string', '1' ,'Units','centimeters','Style','popup', 'position',[pwidth/2 pheight-4.9 1.75 0.5],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 9, 'Backgroundcolor','w', 'Value', 1);   

    
    %which pcs to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-6 pwidth/2-0.5 0.5],'string','Select Principal Components','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    pcList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','PC', 'position',[pwidth/2 pheight-7.4 pwidth/2-0.5 1.9],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
    selAllPCHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-6.8 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Select All', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotstrengths(''selAllPCs'');');
    
    clearPCHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-7.4 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Clear', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotstrengths(''clearAllPCs'');');
    
   
    
    %sea level
    sealevelChk = uicontrol('value', 0, 'enable', 'off','Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 0.25 pwidth-1 0.5],'string','Apply a sea level, plotting only heights above','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    sealevelHndl = uicontrol('enable', 'off','HorizontalAlignment', 'right','Parent',panel,'string', '0' ,'Units','centimeters','Style','edit', 'position',[pwidth-2 0.25 1.5 0.6],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor','w', 'Value', 1);   
   
    %Normalise
    normChk = uicontrol('value', 0, 'enable', 'off', 'Parent',panel ,'Style', 'checkbox','Units','centimeters','position',[0.5 1 pwidth-1 0.5],'string','Normalise values so that the maximum value is zero','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);   
   
    %raw, abs or log?
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-8.5 pwidth/2-0.5 0.6],'string','Select the values to use','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'normalized', 'FontSize', 0.6);
    scaleHndl = uibuttongroup('SelectionChangeFcn', {@update_scale,normChk, sealevelChk, sealevelHndl}, 'Units','centimeters','Position', [pwidth/2 pheight-8.5 pwidth/2-0.5 0.6], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    t1=uicontrol('Parent',scaleHndl,'string', 'raw data' ,'Units','normalized','Style','togglebutton', 'position',[0/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    t2=uicontrol('Parent',scaleHndl,'string', 'absolute' ,'Units','normalized','Style','togglebutton', 'position',[33/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    t3=uicontrol('Parent',scaleHndl,'string', 'log abs' ,'Units','normalized','Style','togglebutton', 'position',[66/100 0/100 33/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(scaleHndl, 'UserData', [t1 t2 t3]);
    
  
    
    r = panel;
elseif strcmp(action, 'name')
    r = 'Parameter Sensitivity Spectrum';
elseif strcmp(action, 'description')
    r = 'Plots the effect of each parameter on the principal components (strengths). Data can be plotted as a surface plot, or bar chart. Selecting a sea level will plot all values above this as relative values.';
elseif strcmp(action, 'fill')
   
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
    last_too_small = 0;
    if(sds.spec_all{1}(end)/sds.spec_all{1}(1)<1e-14)
        %dont plot last value if it is too small
        last_too_small = 1;
    end

    for k = 4:size(sds.U_all{1},2)-last_too_small % DAR changed this - took out the -1
        pcs = [pcs; strcat(num2str(k), {'th pc'})];
    end
    set(pcList, 'String', pcs, 'Value', 1:length(pcs));
    set(parList, 'String', sds.parnames, 'Value', 1:length(sds.parnames));
     pars = cell(1, length(sds.parnames));
    for k = 1:length(sds.parnames)
        pars{k} = num2str(k);
    end
    set(sortFirstHndl, 'String', pars, 'Value', length(sds.parnames));
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set([pcList parList sortFirstHndl], 'String', []);
    set(sortFirstHndl, 'String', '1', 'value', 1);
elseif strcmp(action, 'plot')
     sds = varargin{1}; cmb = varargin{2};     
     %read controls    
     ptype = get(plotList, 'Value');
     grp = get(groupChk, 'Value');
     
     opts = get(parOpt, 'UserData');
     if get(opts(1), 'Value')
          partoplot = get(parList, 'Value'); 
          numpars = length(partoplot);
     else
          partoplot = cell(2,1);
          partoplot{1} = get(sortHndl, 'Value');
          partoplot{2} = get(sortFirstHndl, 'Value');
          numpars = get(sortFirstHndl, 'Value');
     end 
     
     if numpars < 2 && ptype == 1
         ShowError('You must select two or more parameters for a surface plot.');
         return;
     end
     if isempty(partoplot)
         ShowError('Please select one or more parameters to plot.');
         return;
     end
     
     pctoplot = get(pcList, 'Value');
     if length(pctoplot) < 2 && ptype == 1 
         ShowError('Please select two or more principal components to plot.');
         return;
     end
     if isempty(pctoplot)
         ShowError('Please select one or more principal components to plot.');
         return;
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
     

     
     nm = get(normChk, 'Value');
     opts = get(scaleHndl, 'UserData');
     for i = 1:length(opts)
         if get(opts(i), 'Value')
             scl = i;
             break;
         end
     end
     
     if ptype == 1
         plotSurface(sds, partoplot, pctoplot, sl, slv, nm, scl, cmb)         
     elseif ptype == 2
         plotBar3D(sds, partoplot, pctoplot, sl, slv, nm, scl, cmb)
     else
         plotBar2D(sds, partoplot, pctoplot, sl, slv, nm, scl, grp, cmb)
     end
    
elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    %input arg 2 is whole contents of file, idx is where to start reading it
    %return value is where next plot type needs to start
    idx = varargin{1};
    vals = varargin{2};
    ptype = vals{idx};idx = idx + 1;
    grp = vals{idx};idx = idx + 1;
    partype = vals{idx};idx = idx + 1;
    srt = vals{idx};idx = idx + 1;
    sl = vals{idx};idx = idx + 1;
    slv = vals{idx};idx = idx + 1;
    nm = vals{idx};idx = idx + 1;   
    sc = vals{idx};idx = idx + 1;
    %The order they are set in must match the order they are written to file
    %in
    
    set(plotList, 'Value', str2double(ptype));
    
    
    set(groupChk, 'Value', str2double(grp));
    
    opts = get(parOpt, 'UserData');
    set(opts(str2double(partype)), 'Value', 1);
    set(sortHndl, 'Value', str2double(srt));
    
    set(sealevelChk, 'Value', str2double(sl));
    set(sealevelHndl, 'String', slv);
    set(normChk, 'Value', str2double(nm));
    
    
    opts = get(scaleHndl, 'UserData');
    set(opts(str2double(sc)), 'Value', 1);
    %return index value for next panel
    r = idx; 
    sa_plotstrengths('changeType');
    sa_plotstrengths('changePar');
elseif strcmp(action, 'save')
    %save control values to file
    %the order here must match the order they are loaded in, as above
    fp = varargin{1};

    fprintf(fp, '%d\n', get(plotList, 'Value'));
    fprintf(fp, '%d\n', get(groupChk, 'Value'));
    opts = get(parOpt, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            fprintf(fp, '%d\n', i);
            break;
        end
    end  
    fprintf(fp, '%d\n', get(sortHndl, 'Value'));
    
    fprintf(fp, '%d\n', get(sealevelChk, 'Value'));
    fprintf(fp, '%s\n', get(sealevelHndl, 'String'));
    fprintf(fp, '%d\n', get(normChk, 'Value'));
    
    opts = get(scaleHndl, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            fprintf(fp, '%d\n', i);
            break;
        end
    end
    
%========================================================================
elseif strcmp(action, 'selAllPars')
    str = get(parList, 'String');
    set(parList, 'Value', 1:length(str));
elseif strcmp(action, 'clearAllPars')
    set(parList, 'Value', []);
elseif strcmp(action, 'selAllPCs')
    str = get(pcList, 'String');
    set(pcList, 'Value', 1:length(str));
elseif strcmp(action, 'clearAllPCs')
    set(pcList, 'Value', []);
elseif strcmp(action, 'changeType')
    gp = get(plotList, 'Value');
    if gp == 3
       set(groupChk, 'Enable', 'on'); 
    else
        set(groupChk, 'Enable', 'off'); 
    end
elseif strcmp(action, 'changePar')
    ctrls = get(parOpt, 'Userdata');
    if get(ctrls(1), 'Value')
       set([selAllParHndl clearParHndl parList], 'Enable', 'on'); 
       set([ sortFirstHndl sortHndl], 'Enable', 'off'); 
    else
       set([selAllParHndl clearParHndl parList], 'Enable', 'off'); 
       set([ sortFirstHndl sortHndl], 'Enable', 'on'); 
    end
         
end

%=========================================================================
function plotSurface(sds, partoplot, pctoplot, sl, slv, nm, scl, cmb)

global plot_font_size

numplots = length(sds.strengths);
if cmb
    numplots = numplots+1;
end

if numplots == 1
    pos = get_size_of_figure();
else
    pos = [0.1 0.3 0.6 0.6];
end

for i = 1:numplots
    
    if i <= length(sds.strengths)
        zdata1 = sds.strengths{i};%(1:end-1,:);%remove last row (pc)
        exptname =  sds.exptnames{i};
    else
       zdata1 = sds.bigstrengths; 
       exptname = 'combined SDS';
    end
    
    if scl == 1
        tstr = [sds.mymodel ' PSS from ' exptname]; %shortened names
        zlbl = 'spectrum';
    elseif scl == 2
        tstr = [sds.mymodel ' Abs.  PSS from ' exptname]; %MD shortened names f
        zlbl = 'abs spectrum';
        zdata1 = abs(zdata1);
    else
        tstr = [sds.mymodel ' Log Abs. PSS from ' exptname]; %MD shortened names
        zlbl = 'log_{10} abs spectrum';
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
    
    if iscell(partoplot)
        %plotting best n pars after sorting
        
        if partoplot{1} == 1
            %sort by 1st pc
            firstPCs = zdata1(1,:);
            if scl == 1
                firstPCs=abs(firstPCs);  
            end
            zdata1 = zdata1(pctoplot, :);
            zdata1 = zdata1';   %transpose to sort by row
            %zdata col = lambda, row  = parameter(k)
            [firstPCs, parIdx] = sort(firstPCs, 'descend');
            zdata1 = zdata1(parIdx,:);
            parn = sds.parn(parIdx);
            zdata1 = zdata1'; %transposed back for plotting
        else
            %sort by max pc
            zdata1 = zdata1(pctoplot, :);
            zdata1 = zdata1';   %transpose to sort by row
            %zdata col = lambda, row  = parameter(k)
            zdatatemp=zeros(size(zdata1,1),size(zdata1,2)+1);
            for i=1:size(zdata1,1)
                if scl == 1
                    zdatatemp(i,:)=[max(abs(zdata1(i,:))) zdata1(i,:)];
                else
                    zdatatemp(i,:)=[max(zdata1(i,:)) zdata1(i,:)];%extra col is max pc for that param (row)
                end
            end
            [zdatatemp,parIdx]=sortrows(zdatatemp, -1);%sort parameters by max pc
            zdata1=zdatatemp(:,2:end);
            parn = sds.parn(parIdx);
            zdata1 = zdata1'; %transposed back for plotting
        end
        %select first n
        zdata1 = zdata1(:,1:partoplot{2});
        parn = parn(1:partoplot{2});
        
    else
        %plotting selected pars unsorted
        zdata1 = zdata1(pctoplot, partoplot);
        parn = sds.parn(partoplot);
    end
    
    
    
    newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Parameter Sensitivity Spectrum'],  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]);%MD background
    if i > length(sds.strengths)
       set(newfig, 'name', [get(newfig, 'name'), ' combined SDS']); 
    end
    
    pos(1) = pos(1)+ 0.1;
    pos(2) = pos(2)- 0.1;
    
    axes1 = axes( ...
        'CameraPosition',[323.9 106.9 14.26],...
        'CameraUpVector',[-8.324 -2.473 0.8154],...
        'Parent',newfig, ...
        'FontSize',12,...
        'Position', [10/100 10/100 80/100 75/100]);
    
    % Create surface plot
    surf1 = surf(zdata1, 'Parent', axes1);
    grid(axes1,'on');
    
    xlabel(texlabel('k_i'), 'FontSize', plot_font_size);
    xlim([1 length(parn)]);
    set(axes1, 'XTick', 1:length(parn));
    set(axes1, 'XTickLabel', parn);
    
    ylabel(texlabel('lambda_i'), 'FontSize', plot_font_size);
    ylim([1 length(pctoplot)]);
    set(axes1, 'YTick', 1:length(pctoplot));
    set(axes1, 'YTickLabel', pctoplot);
    
    zlabel(texlabel(zlbl), 'FontSize', plot_font_size);
    
    % Create colorbar
    colorbar1 = colorbar('peer',...
        axes1,'EastOutside',...
        'Box','on',...
        'FontSize',12);
    if sl
        lbls = get(gca, 'ZTickLabel');
        lbls = sscanf(lbls, '%f') + slv;
        set(gca, 'ZTickLabel', lbls);

        lbls = get(colorbar1, 'YTickLabel');
        lbls = sscanf(lbls, '%f') + slv;
        set(colorbar1, 'YTickLabel', lbls);
    end
    title(tstr, 'FontSize', plot_font_size);
end

%=========================================================================
function plotBar3D(sds, partoplot, pctoplot, sl, slv, nm, scl, cmb)
%strengths, normalise_strengths, add_sealevel, sealevel, panel, lg

global plot_font_size

numplots = length(sds.strengths);
if cmb
    numplots = numplots+1;
end

if numplots == 1
    pos = get_size_of_figure();
else
    pos = [0.1 0.3 0.6 0.6];
end

for i = 1:numplots
    
    if i <= length(sds.strengths)
        zdata1 = sds.strengths{i};
        exptname =  sds.exptnames{i};
    else
        zdata1 = sds.bigstrengths;
        exptname = 'combined SDS';
    end
    
    if scl == 1
        tstr = [sds.mymodel ' Parameter Sensitivity Spectrum from ' exptname];
        zlbl = 'spectrum';
    elseif scl == 2
        %strengths are always absolute. Set this way in master_svd6
        tstr = [sds.mymodel ' Absolute Parameter Sensitivity Spectrum ' exptname];
        zlbl = 'abs spectrum';
        zdata1 = abs(zdata1);
    else
        tstr = [sds.mymodel ' Log Absolute Parameter Sensitivity Spectrum ' exptname];
        zlbl = 'log_{10} abs spectrum';
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
    
    if iscell(partoplot)
        %plotting best n pars after sorting
        
        if partoplot{1} == 1
            %sort by 1st pc
            firstPCs = zdata1(1,:);
            if scl == 1
               firstPCs = abs(firstPCs);
            end
            zdata1 = zdata1(pctoplot, :);
            zdata1 = zdata1';   %transpose to sort by row
            %zdata col = lambda, row  = parameter(k)
            [firstPCs, parIdx] = sort(firstPCs, 'descend');
            zdata1 = zdata1(parIdx,:);
            parn = sds.parn(parIdx);
            zdata1 = zdata1'; %transposed back for plotting
        else
            %sort by max pc
            zdata1 = zdata1(pctoplot, :);
            zdata1 = zdata1';   %transpose to sort by row
            %zdata col = lambda, row  = parameter(k)
            zdatatemp=zeros(size(zdata1,1),size(zdata1,2)+1);
            for i=1:size(zdata1,1)
                if scl == 1
                    zdatatemp(i,:)=[max(abs(zdata1(i,:))) zdata1(i,:)];
                else
                    zdatatemp(i,:)=[max(zdata1(i,:)) zdata1(i,:)];%extra col is max pc for that param (row)
                end
            end
            [zdatatemp,parIdx]=sortrows(zdatatemp, -1);%sort parameters by max pc
            zdata1=zdatatemp(:,2:end);
            parn = sds.parn(parIdx);
            zdata1 = zdata1'; %transposed back for plotting
        end
        %select first n
        zdata1 = zdata1(:,1:partoplot{2});
        parn = parn(1:partoplot{2});
        
    else
        %plotting selected pars unsorted
        zdata1 = zdata1(pctoplot, partoplot);
        parn = sds.parn(partoplot);
    end
    
    cutoff = ceil(length(parn)/2);
    
    if length(pctoplot) == 1
        zdata1 = zdata1'; %If zdata1 is a vector, matlab rotates the plot
    end
    zrange = [min(0, min(min(zdata1))) max(max(zdata1))];
    
    newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Parameter Sensitivity Spectrum'],  'Units', 'normalized', 'position', pos);
    if i > length(sds.strengths)
       set(newfig, 'name', [get(newfig, 'name'), ' combined SDS']); 
    end
    
    pos(1) = pos(1)+ 0.1;
    pos(2) = pos(2)- 0.1;
    
%    axes1 = axes('FontSize',12,'Parent',newfig, 'Position', [10/100 55/100 80/100 35/100], 'DataAspectRatio', [0.1 0.15 0.15]);
    axes1 = axes('FontSize',12,'Parent',newfig, 'Position', [10/100 55/100 80/100 35/100]);
    if length(pctoplot) > 1
        hb1 = bar3(zdata1(:, 1:cutoff));
%        set(axes1,'DataAspectRatio',[0.05 0.1 0.15],'PlotBoxAspectRatio',[0.1 0.1 0.05]);
        set(axes1, 'XTick', 1:cutoff);
        set(axes1, 'XTickLabel', parn(1:cutoff));
        set(axes1, 'YTick', 1:length(pctoplot));
        set(axes1, 'YTickLabel', pctoplot);
        view([-37 30]);
    else
        %if plotting only 1 pc, matlab will reverse the x and y axes
        hb1 = bar3(zdata1(1:cutoff));
   %     set(axes1,'DataAspectRatio',[0.05 0.1 0.15],'PlotBoxAspectRatio',[0.1 0.1 0.05]);
        set(axes1, 'YTick', 1:cutoff);
        set(axes1, 'YTickLabel', parn(1:cutoff));
        set(axes1, 'XTick', 1:length(pctoplot));
        set(axes1, 'XTickLabel', pctoplot);
        %rotate so it looks the same
        view([233 30]);
    end
    
    set(hb1, 'FaceColor', [0.85 0.85 0.85]);
    grid(axes1,'on');
    title(tstr, 'FontSize', plot_font_size);
    
    if zrange(1) ~= zrange(2)
        zlim(axes1, zrange);
    end
    
    xlabel(texlabel('k_i'), 'fontsize', plot_font_size);
    ylabel(texlabel('lambda_i'), 'fontsize', plot_font_size);
    zlabel(texlabel(zlbl), 'fontsize', plot_font_size);
    
    if length(parn) > 1
        
      %  axes2 = axes('FontSize',12,'Parent',newfig, 'Position', [10/100 10/100 80/100 35/100],'DataAspectRatioMode', 'manual', 'DataAspectRatio', [0.1 0.15 0.15]);
        axes2 = axes('FontSize',12,'Parent',newfig, 'Position', [10/100 10/100 80/100 35/100]);
       
        if length(pctoplot) > 1
            hb2=bar3(zdata1(:, cutoff+1:end));
    %       set(axes1,'DataAspectRatio',[0.05 0.1 0.15],'PlotBoxAspectRatio',[0.1 0.1 0.05]);
            set(axes2, 'XTick', 1:size(zdata1 ,2) - cutoff);
            set(axes2, 'XTickLabel', parn(cutoff+1:end));
            set(axes2, 'YTick', 1:length(pctoplot));
            set(axes2, 'YTickLabel', pctoplot);
            view([-37 30]);
        else
            hb2=bar3(zdata1(cutoff+1:end));
  %         set(axes1,'DataAspectRatio',[0.05 0.1 0.15],'PlotBoxAspectRatio',[0.1 0.1 0.05]);
            set(axes2, 'YTick', 1:length(parn) - cutoff);
            set(axes2, 'YTickLabel', parn(cutoff+1:end));
            set(axes2, 'XTick', 1:length(pctoplot));
            set(axes2, 'XTickLabel', pctoplot);
            view([233 30]);
        end
        
        set(hb2, 'FaceColor', [0.85 0.85 0.85]);
        
        if zrange(1) ~= zrange(2)
            zlim(axes2, zrange);
        end
        
        xlabel(texlabel('k_i'), 'fontsize', plot_font_size);
        ylabel(texlabel('lambda_i'), 'fontsize', plot_font_size);
        zlabel(texlabel(zlbl), 'fontsize', plot_font_size);
        
        grid(axes2,'on');
    else
        axes2 = [];
    end
    
    %correct vertical scale
    if sl
        lbls = get(axes1, 'ZTickLabel');
        lbls = sscanf(lbls, '%f') + slv;
        set(axes1, 'ZTickLabel', lbls);
        if ~isempty(axes2)
            lbls = get(axes2, 'ZTickLabel');
            lbls = sscanf(lbls, '%f') + slv;
            set(axes2, 'ZTickLabel', lbls);
        end
    end
end
       
%=========================================================================
function plotBar2D(sds, partoplot, pctoplot, sl, slv, nm, scl, grp, cmb)


%strengths, normalise_strengths, add_sealevel, sealevel, panel, lg, dosort,
%dostack, numpcs, pnames, hm, numparams

%strength = sds.pscaledstrengths etc...

global plot_font_size
numpcs = length(pctoplot);
if ~grp && numpcs > 8
   ShowError('Too many graphs will be plotted! Please select fewer pcs, or group the plots.'); 
   h = [];
   return;
end

numplots = length(sds.strengths);
if cmb
    numplots = numplots+1;
end

if numplots == 1
    pos = get_size_of_figure();
else
    pos = [0.1 0.3 0.6 0.6];
end

for i = 1:numplots
    
    if i <= length(sds.strengths)
        zdata1 = sds.strengths{i};
        exptname = sds.exptnames{i};
    else
        zdata1 = sds.bigstrengths;
        exptname = 'combined SDS';
    end
    
    if scl == 1
        tstr = [sds.mymodel ' Parameter Sensitivity Spectrum from ' exptname];
        zlbl = 'spectrum';
    elseif scl == 2
        tstr = [sds.mymodel ' Absolute Parameter Sensitivity Spectrum ' exptname];
        zlbl = 'abs spectrum';       
        zdata1 = abs(zdata1);
    else
        tstr = [sds.mymodel ' Log Absolute Parameter Sensitivity Spectrum ' exptname];
        zlbl = 'log_{10} abs spectrum';
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
    
    if iscell(partoplot)
       %plotting best n pars after sorting
       %if using raw values, must still take abs value to find the most important 
        if partoplot{1} == 1
            %sort by 1st pc
            firstPCs = zdata1(1,:);
            if scl == 1
               firstPCs = abs(firstPCs);
            end
            zdata1 = zdata1(pctoplot, :);
            zdata1 = zdata1';   %transpose to sort by row
            %zdata col = lambda, row  = parameter(k)
            [firstPCs, parIdx] = sort(firstPCs, 'descend');
            zdata1 = zdata1(parIdx,:);
            parn = sds.parn(parIdx);
        else
            %sort by max pc
            zdata1 = zdata1(pctoplot, :);
            zdata1 = zdata1';   %transpose to sort by row
            %zdata col = lambda, row  = parameter(k)
            zdatatemp=zeros(size(zdata1,1),size(zdata1,2)+1);
            for i=1:size(zdata1,1)
                 if scl == 1
                     zdatatemp(i,:)=[max(abs(zdata1(i,:))) zdata1(i,:)];
                 else
                    zdatatemp(i,:)=[max(zdata1(i,:)) zdata1(i,:)];%extra col is max pc for that param (row)
                 end
            end
            [zdatatemp,parIdx]=sortrows(zdatatemp, -1);%sort parameters by max pc
            zdata1=zdatatemp(:,2:end);
            parn = sds.parn(parIdx);
        end
        %select first n
        zdata1 = zdata1(1:partoplot{2},:);
        parn = parn(1:partoplot{2});
        
    else
        %plotting selected pars unsorted
        zdata1 = zdata1(pctoplot, partoplot);
        parn = sds.parn(partoplot);
        zdata1 = zdata1';
    end
    newfig = figure('NumberTitle', 'off', 'Name', tstr,  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]);
    
    
    pos(1) = pos(1)+ 0.1;
    pos(2) = pos(2)- 0.1;

    if grp
        cv = ['y' 'r' 'b' 'g' 'c' 'm' 'k'];
        subplot(1,1,1);
        set(gca, 'Parent', newfig);
        axpos = get(gca, 'Position');
        axpos(1) = 7.5/100;axpos(3) = 88.725/100;
        axpos(2) = 0.15;axpos(4) = 0.7;
        set(gca, 'Position', axpos);
        hold on;
        %plot row = param, col = pc
        hb = bar(zdata1, 'grouped');
        leg = cell(0);
        for i = 1:length(hb)
            colour = cv(1+mod(pctoplot(i), length(cv)));
            leg = [leg ; {['pc ' num2str(pctoplot(i))]}];
            set(hb(i), 'FaceColor', colour);
        end
        
        xlabel('k_i', 'FontSize', plot_font_size);
        xlim([0 size(zdata1,1)+1]);
        
        
        set(gca, 'XTick', 1:size(zdata1,1), 'XTickLabel', {});
  %      set(gca, 'XTickLabel', parn, 'fontsize', plot_font_size);
        

        %label cols
        yv = get(gca, 'YLim');
        ytop = yv(2) + diff(yv)/30;
        ybottom = yv(1)-diff(yv)/10;
        for i = 1:length(parn)
            text('parent', gca, 'string', parn{i}, 'rotation', 90, 'position', [i ytop], 'fontsize', plot_font_size);
            text('parent', gca, 'string', parn{i}, 'rotation', 90, 'position', [i ybottom], 'fontsize', plot_font_size);
        end
        
        %correct the scale
        if sl
            lbls = get(gca, 'YTickLabel');
            lbls = sscanf(lbls, '%f') + slv;
            set(gca, 'YTickLabel', lbls, 'fontsize', plot_font_size);
        end
        ylabel(zlbl, 'FontSize', plot_font_size);
        set(gca,'YGrid', 'on');
        legend(leg);
        hold off;
    else
        num = 1;
        for pc = 1:length(pctoplot)  % for each pc
            subplot(numpcs,1,pc);
            set(gca, 'Parent', newfig);
            axpos = get(gca, 'Position');
            axpos(1) = 7.5/100;axpos(3) = 88.725/100;axpos(4) = axpos(4)-0.05;
            set(gca, 'Position', axpos);
            hold on;
            %np = size(zdata1,2);
            toplot = zdata1(:,pc);
            bar(toplot, 'r');
            if pc == length(pctoplot)
                xlabel('k_i', 'fontsize', plot_font_size);
            end
            xlim([0 length(toplot)+1]);
            set(gca, 'XTick', 1:length(toplot), 'XTickLabel', {});
%             if pc == length(pctoplot)
%                 set(gca, 'XTickLabel', parn, 'fontsize', plot_font_size);
%             else
%                 set(gca, 'XTickLabel', {});
%             end
            
            %label cols
            if pc == 1
                yv = get(gca, 'YLim');
                yv = yv(2) + diff(yv)/30;
                for ii = 1:length(toplot)
                    text('parent', gca, 'string', parn{ii}, 'rotation', 90, 'position', [ii yv], 'fontsize', plot_font_size);
                end
            elseif pc == length(pctoplot)
                yv = get(gca, 'YLim');
                yv = yv(1) - diff(yv)/3;
                for ii = 1:length(toplot)
                    text('parent', gca, 'string', parn{ii}, 'rotation', 90, 'position', [ii yv], 'fontsize', plot_font_size);
                end
            end
 
            if sl
                lbls = get(gca, 'YTickLabel');
                lbls = sscanf(lbls, '%f') + slv;
                set(gca, 'YTickLabel', lbls);
            end
         %   ylabel(zlbl, 'fontsize', plot_font_size);
            set(gca,'YGrid', 'on');
            legend({['pc ' num2str(pctoplot(pc))]});
            hold off;
            num = num+1;
        end
    end
    
end

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


