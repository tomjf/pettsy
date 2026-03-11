function r = sa_plotscatter(action, varargin)

global maincol btncol 
persistent varList; %which variables listbox
persistent parList; %which parameters listbox
persistent panel selAllHndl clearlHndl derList derlbl;
persistent pars pcs

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
    
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth/2-1 0.5],'string','Derivatives with repect to','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);    
    derList = uibuttongroup('Units','centimeters','SelectionChangeFcn','sa_plotscatter(''changeType'');', 'Position', [pwidth/2 pheight-2.15 pwidth/2-0.25 1.25], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    d1=uicontrol('HorizontalAlignment', 'right','Parent',derList,'string', 'Parameter' ,'Units','normalized','Style','radiobutton', 'position',[0/100 50/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    d2=uicontrol('HorizontalAlignment', 'right', 'Parent',derList,'string', 'Principal component' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 1 50/100],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(derList, 'UserData', [d1 d2]);
    
    
    %which vars to plot
    uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3.2 pwidth/2-1 0.5],'string','Select the Variables to Plot','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    varList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-5.7 pwidth/2-0.5 3],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
    
    %select the variables
    selAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-4.2 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Select All', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotscatter(''selAllVars'');');
    
    clearHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-4.8 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Clear', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_plotscatter(''clearAllVars'');');
    
    %which params/pcs to plot
    derlbl = uicontrol('Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-7.2 pwidth/2-1 1],'string','','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    parList = uicontrol('Parent',panel, 'Units','centimeters','Style','listbox','Max', 10, 'Min', 0, 'String','', 'position',[pwidth/2 pheight-9.2 pwidth/2-0.5 3],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10);
         
    pcs = [];pars = [];
    sa_plotscatter('changeType');
    r = panel;
    
elseif strcmp(action, 'name')
    r = 'Amp/Phase Derivative Scatter';
elseif strcmp(action, 'description')
    r = 'Produces a scatter plot of the derivative of the solution amplitude with respect to parameter or PC, versus the derivative of the solution period/phase with respect to parameter or PC.';
% elseif strcmp(action, 'fill')
%     %fill control values in response to changing results file
%     lc = varargin{1};
%     %fill in variable names and select all by default
%     set(varList, 'String', lc.vnames, 'Value', 1:length(lc.vnames));
elseif strcmp(action, 'fillSDS')
    %called when sds changes. 
    sds = varargin{1};
     %fill in variable names and select all by default
    vnames = cell(0);
    ycols = [];
    for i = 1:length(sds.vnames)
        vnames = [vnames sds.vnames{i}];
        ycols = [ycols; (ones(length(sds.vnames{i}),1)*i) (1:length(sds.vnames{i}))'];
    end
    %record which dgs each variable belongs to 
    set(varList, 'String', vnames, 'Value', [1:length(vnames)], 'Userdata', ycols);
    
    pars = sds.parnames;
     
    %list pcs
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

    sa_plotscatter('changeType');
elseif strcmp(action, 'unfill')
    %empties control values when there is no file selected
    set([parList varList], 'String', []);
elseif strcmp(action, 'plot')
    
     sds = varargin{1};
     cmb = varargin{2};
     
     all_y = get(varList, 'Value');
     ptoplot = get(parList, 'Value'); %num axes
     opts = get(derList, 'UserData');
     pt = [];
     for i =1:length(opts)
         if get(opts(i), 'Value')
             pt = i;
             break;
         end
     end
     
     if isempty(all_y)
         ShowError('Please select one or more variables to plot.');
     elseif isempty(ptoplot)
         ShowError('Please select one or more parameters or principal components to plot.');
     else        
         %do the plot
         ycols = get(varList, 'Userdata');
         ysel = zeros(size(ycols,1), 1);
         ysel(all_y) = 1;
         ytoplot = cell(length(sds.main_deriv),1);
         numplots = 0;
         for p = 1:length(sds.main_deriv)
             %cut selection down to this dgs
             ytoplot{p} = ycols(ysel & (ycols(:,1) == p), 2);
             if ~isempty(ytoplot{p})
                 numplots = numplots + 1;
             end
         end
        if ~isempty(sds.bigU) && cmb && pt == 2
            numplots = numplots * 2;
        end
         PlotScatter(pt, sds, ytoplot, ptoplot, cmb, numplots);
     end
    
elseif strcmp(action, 'synch')
    %set a control value
    
elseif strcmp(action, 'set')
    %set control values from settings file read at startup
    %input arg is whole contents of file, idx is where to start reading it
    %return value if where next plot type needs to start
    idx = varargin{1};
    vals = varargin{2};
    vars = vals{idx};
    idx = idx + 1;
    deriv = vals{idx};
    idx = idx + 1;
    %The order they are set in must match the order they are written to file
    %in
    numvar = length(get(varList, 'String'));
    vars = sscanf(vars, '%f')';
    m = find( vars > numvar);
    vars(m) = [];
    set(varList, 'Value', vars);
    opts = get(derList, 'UserData');
    set(opts(str2double(deriv)), 'Value', 1);
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
    opts = get(derList, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            fprintf(fp, '%d\n', i);
            break;
        end
    end
%========================================================================
elseif strcmp(action, 'selAllVars')
    str = get(varList, 'String');
    set(varList, 'Value', 1:length(str));
elseif strcmp(action, 'clearAllVars')
    set(varList, 'Value', []);
elseif strcmp(action, 'changeType')
    ctrls = get(derList, 'Userdata');
    if get(ctrls(1), 'Value')
        set(parList, 'String', pars);
        set(derlbl, 'String', 'Select the Parameters to Plot');
    else
        set(parList, 'String', pcs);
        set(derlbl, 'String', 'Select the Principal Components to Plot');
    end
end

%=========================================================================
function PlotScatter(plot_type, sds, ytoplot, numpcs, cmb, numplots)

global plot_font_size

pnum = 1;
for p = 1:length(sds.U_all)
    
    if ~isempty(ytoplot{p})
        numvar = ytoplot{p}';
        ts = sds.lc{p};%was lc.sol.y;
        tspan = sds.t{p};
        if plot_type == 2   %pcs
            data = sds.U_all{p};
        else
            data = sds.main_deriv{p};
        end
        
        vector_field = sds.vector_field{p};
        
        dim = size(vector_field, 2);
        
        g = zeros(size(data,2),dim); %DAR June08
        gd = zeros(size(data,2),dim); %DAR June08
        for i=1:size(data,2)
            for m=1:dim
                Uim=data((m-1)*length(tspan)+1:m*length(tspan),i);%pc for var m, param i
                solim = ts(:,m); %time series for m
                dsolim = vector_field(:, m); %g_dot time series for m  %DAR June08
                % dydt = feval(system,tspan,y1(j,:),lc.par);
                %dsolim = diff(ts(:,m))./diff(tspan); %apprx derivative of time series
                %dsolim(end+1) = dsolim(end);
                if ~sds.periodic(p) %DAR June08
                    dsolim = dsolim.*tspan;
                end
                g(i,m)=dot(Uim,solim)/(dot(solim,solim));%g is sum of (pc * ts)/sqrt(sum of pc^2 * sum of ts^2)
                gd(i,m)=dot(Uim,dsolim)/(dot(dsolim,dsolim));%gd is sum of (pc * dydt)/sqrt(sum of pc^2 * sum of dydt^2)
            end
        end
        xmin=min(min(g(numpcs,:)));
        ymin=min(min(gd(numpcs,:)));
        xmax=max(max(g(numpcs,:)));
        ymax=max(max(gd(numpcs,:)));
        
        if numplots == 1
             pos = get_size_of_figure();
        else
            pos = [(pnum-1)/numplots 0 1/numplots 1];
            pnum = pnum+1;
        end
        newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Solution Derivatives from ' sds.exptnames{p}],  'Units', 'normalized', 'position', pos, 'Color', [1 1 1]); %MD background
        
        scatter(g(1,:),gd(1,:),'w');%g is labelled amp, gd period/phase
        hold on;
        plot([xmin xmax],[0 0],'k');
        plot([0 0],[ymin ymax],'k');
        
        col=['k', 'r' 'g' 'b' 'c' 'm' 'y'];
        textcol=['w', 'w' 'k' 'w' 'k' 'w' 'k']; %DAR 9June08
        %g is amp, gd phase
        for i=numpcs
            for m=numvar
                str=sprintf('%d',m);
                text(g(i,m),gd(i,m),str,'BackgroundColor', col(1 + mod(i,length(col))),'EdgeColor',col(1 + mod(i,length(col))),'Color',textcol(1 + mod(i,length(col)))); %DAR 9June08
            end;
        end
        hold off;
        if xmax > xmin
            xlim([xmin xmax]);
        end
        if ymax > ymin
            ylim([ymin ymax]);
        end
        if plot_type == 2%pcs
            xlabel('Amplitude dAmp/d  \lambda_i', 'FontSize', plot_font_size);
            ylabel('Period/Phase d  \phi /d  \lambda_i', 'FontSize', plot_font_size);
        else %dgs
            xlabel('Amplitude dAmp/dk_i', 'FontSize', plot_font_size);
            ylabel('Period/Phase d  \phi /dk_i', 'FontSize', plot_font_size);
        end
        grid on;  %DAR June08
        
        for i=numpcs
            if plot_type == 2
                str=sprintf('pc %d',i);
            else
                str=sprintf('%s', sds.parn{i});
            end
            text(1.02*xmax,ymax -((ymax-ymin)/20 *i),str,'BackgroundColor', col(1 + mod(i,length(col))),'EdgeColor',col(1 + mod(i,length(col))),'Color',textcol(1 + mod(i,length(col)))); %DAR 9June08
        end
    end
end

if plot_type == 2 && cmb
    %combined plot only exists if pcs selected
    startpos = 1;
    for p = 1:length(sds.U_all)      
        if ~isempty(ytoplot{p})
            numvar = ytoplot{p}';
            ts = sds.lc{p};%was lc.sol.y;
            tspan = sds.t{p};
            dgs_len = size(sds.U_all{p}, 1);
            endpos = startpos + dgs_len-1;
            %extract this dgs's component from combined dgs
            data = sds.bigU(startpos:endpos, :);
            startpos = endpos+1;
            
            vector_field = sds.vector_field{p};
            dim = size(vector_field, 2);
            
            g = zeros(size(data,2),dim); %DAR June08
            gd = zeros(size(data,2),dim); %DAR June08
            for i=1:size(data,2)
                for m=1:dim
                    Uim=data((m-1)*length(tspan)+1:m*length(tspan),i);%pc for var m, param i
                    solim = ts(:,m); %time series for m
                    dsolim = vector_field(:,m); %g_dot time series for m  %DAR June08
                    % dydt = feval(system,tspan,y1(j,:),lc.par);
                    %dsolim = diff(ts(:,m))./diff(tspan); %apprx derivative of time series
                    %dsolim(end+1) = dsolim(end);
                    if ~sds.periodic(p) %DAR June08
                        dsolim = dsolim.*tspan;
                    end
                    g(i,m)=dot(Uim,solim)/(dot(solim,solim));%g is sum of (pc * ts)/sqrt(sum of pc^2 * sum of ts^2)
                    gd(i,m)=dot(Uim,dsolim)/(dot(dsolim,dsolim));%gd is sum of (pc * dydt)/sqrt(sum of pc^2 * sum of dydt^2)
                end
            end
            xmin=min(min(g(numpcs,:)));
            ymin=min(min(gd(numpcs,:)));
            xmax=max(max(g(numpcs,:)));
            ymax=max(max(gd(numpcs,:)));
            
            pos = [(pnum-1)/numplots 0 1/numplots 1];
            pnum = pnum+1;
            
            newfig = figure('NumberTitle', 'off', 'Name', [sds.mymodel ' Solution Derivatives from ' sds.exptnames{p}  ' from combined SDS'],  'Units', 'normalized', 'position', pos);
            
            scatter(g(1,:),gd(1,:),'w');%g is labelled amp, gd period/phase
            hold on;
            plot([xmin xmax],[0 0],'k');
            plot([0 0],[ymin ymax],'k');
            
            col=['k', 'r' 'g' 'b' 'c' 'm' 'y'];
            textcol=['w', 'w' 'k' 'w' 'k' 'w' 'k']; %DAR 9June08
            %g is amp, gd phase
            for i=numpcs
                for m=numvar
                    str=sprintf('%d',m);
                    text(g(i,m),gd(i,m),str,'BackgroundColor', col(1 + mod(i,length(col))),'EdgeColor',col(1 + mod(i,length(col))),'Color',textcol(1 + mod(i,length(col)))); %DAR 9June08
                end;
            end
            hold off;
            if xmax > xmin
                xlim([xmin xmax]);
            end
            if ymax > ymin
                ylim([ymin ymax]);
            end
            xlabel('Amplitude dAmp/d  \lambda_i', 'FontSize', plot_font_size);
            ylabel('Period/Phase d  \phi /d  \lambda_i', 'FontSize', plot_font_size);
            grid on;  %DAR June08
            
            for i=numpcs
                str=sprintf('pc %d',i);
                text(1.02*xmax,ymax -((ymax-ymin)/20 *i),str,'BackgroundColor', col(1 + mod(i,length(col))),'EdgeColor',col(1 + mod(i,length(col))),'Color',textcol(1 + mod(i,length(col)))); %DAR 9June08
            end
            
        end
    end
end