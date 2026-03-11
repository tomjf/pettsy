function r = saveForcePanel(varargin)


persistent eqnHndl previewHndl dawnHndl duskHndl;
persistent myDir panel forcename cpHndl  previewBtnHndl;
global title_fontsize

action = varargin{1};
r = [];

if strcmp(action, 'init')

    %creates controls on the first panel
    myDir = varargin{2};
    pos = varargin{3};
    fig = varargin{4};
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', get(fig, 'Color'), ...
        'Units','centimeters', ...
        'Position',pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'off', ...
        'Parent', fig);
    
    panelwidth = pos(3);panelheight=pos(4);

     
    uicontrol('HorizontalAlignment', 'left','Parent', panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 panelheight-1.1 panelwidth-4 0.7],'string','Enter a force equation:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'),'FontUnits', 'points', 'FontSize', 10);
    eqnHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left','max', 10, 'min', 1, ...
        'Units','centimeters', ...
        'position',[0.5 panelheight-3.7 panelwidth-1 2.4], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 12,'FontName', 'FixedWidth', 'BackgroundColor', 'w',...
        'String', '');
    
     uicontrol('HorizontalAlignment', 'left','Parent', panel ,'Style', 'text', ...
         'Units','centimeters','position',[0.5 panelheight-5.5 panelwidth-1 1], ...
         'string','Here you can set values for force parameters and click Preview to see the effect', ...
         'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'),'FontUnits', 'points', 'FontSize', 10);
    
       uicontrol('Units','centimeters','position',[1 panelheight-6.6 2 0.7],'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','string','dawn:','BackgroundColor', get(fig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
       dawnHndl=uicontrol('Units','centimeters','position',[3 panelheight-6.5 1.5 0.7],'String', '0', 'HorizontalAlignment', 'right','Parent',panel ,'Style', 'edit','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);   
    
      uicontrol('Units','centimeters','position',[1 panelheight-7.6 2 0.7],'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','string','dusk:','BackgroundColor', get(fig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
       duskHndl=uicontrol('Units','centimeters','position',[3 panelheight-7.5 1.5 0.7],'String', '12', 'HorizontalAlignment', 'right','Parent',panel ,'Style', 'edit','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);   
    
    
       uicontrol('Units','centimeters','position',[6 panelheight-6.6 7 0.7],'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','string','Cycle period (CP) or length of simulation:','BackgroundColor', get(fig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
       cpHndl=uicontrol('Units','centimeters','position',[13 panelheight-6.5 1.5 0.7],'String', '24', 'HorizontalAlignment', 'right','Parent',panel ,'Style', 'edit','BackgroundColor', 'w', 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);   
 
       
       previewBtnHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[panelwidth/2-2 panelheight-8.6 4 0.7], ...
        'Parent',panel, ...
        'string', 'Preview', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','saveForcePanel(''preview'');');
       
       previewHndl = axes('parent', panel,'units', 'centimeters', 'position', [1 1.5 panelwidth-1.5 panelheight-10.7], 'xlim', [0 24], 'xtick', [0 4 8 12 16 20 24], 'ylim', [0 1], 'ytick', [0.25 0.5 0.75 1.0],'box', 'on');
        xlabel(previewHndl, 'Time');
    
    
   

    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        forcename = varargin{2};
        %nothing to set on this panel as it is the first
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on');  
    

elseif strcmp(action, 'gonext')
    
 %called when user click Next. Hides panel reads in file
 %returns [] if not valid


    r = [];
  
elseif strcmp(action, 'preview')
    
  ok = false;
    cla(previewHndl);
    
    force_eqn = get(eqnHndl, 'string');

    dawn = get(dawnHndl, 'string');
    dawn = str2double(dawn);
    if isempty(dawn) || dawn < 0
        ShowError('Please enter a positive numeric value for dawn.');
        uicontrol(dawnHndl);
        return;
    end
    dusk = get(duskHndl, 'string');
    dusk = str2double(dusk);
    if isempty(dusk) || dusk < 0
        ShowError('Please enter a positive numeric value for dusk.');
        uicontrol(duskHndl);
        return;
    end
    CP = get(cpHndl, 'string');
    CP = str2double(CP);
    if isempty(CP) || CP < 0
        ShowError('Please enter a positive numeric value for cycle period or length of simulation.');
        uicontrol(cpHndl);
        return;
    end
    
    [ok, tvals, forceval] = validForce(force_eqn, dawn, dusk, CP);
    if ok
        plot(previewHndl, tvals, forceval, 'Linewidth', 2);
        set(previewHndl, 'xlim', [tvals(1) tvals(end)]);
        
        if max(forceval) > 1 || min(forceval) < 0
           warndlg('Force goes outside the range [0 1]. You should apply a scaling factor.', 'New force'); 
        end
        r = force_eqn;
    end
   
    
    
    
elseif strcmp(action, 'goback')
    
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'finished')
    
    %save force
    
    force_eqn = saveForcePanel('preview');
    
    if isempty(force_eqn)
        return;
    end
    
   
    force_eqn = char(subs(str2sym(force_eqn), 't', 't1'));
    if force_eqn(end) ~= ';'
        force_eqn = [force_eqn ';'];
    end
    sassydir = fileparts(mfilename('fullpath'));

    forcedeffile = fullfile(sassydir, '..', 'symbolic', 'get_force_expr.m');
    
    fp1 = fopen(forcedeffile, 'r');
    fp2 = fopen([forcedeffile '.new' ], 'w');
    
    if fp1 > 0 && fp2 > 0
        
        %need to find end of switch statement
        numf = length(get_all_force_types());
        
        filecontents = cell(0);
        i = 1;
        while ~feof(fp1)
            filecontents{i} = fgets(fp1);
            i=i+1;
        end
         fclose(fp1);
        
        force_added = false;
        forcenum = -1;
        for i = 1:length(filecontents)
            
            if ~force_added
                fidx = regexp(filecontents{i}, '\s*case\s+(\d+)', 'tokens', 'once');
                %check last force added
                if ~isempty(fidx)
                    forcenum = str2double(char(fidx));
                end
                if strcmp(strtrim(filecontents{i}), 'otherwise')
                    %end of switch
                    
                    %expect this to be numf
                    
                    if forcenum == numf
                        %add extra case
                        
                        fprintf(fp2, '\tcase %d\n', forcenum+1);
                        fprintf(fp2, '\t\tfname = ''%s'';\n', forcename);
                        fprintf(fp2, '\t\tf = %s\n', force_eqn);
                        force_added = true;
                    else
                       ShowError('Unable to correctly interpret force definition file. This should be edited manually.'); 
                       fclose(fp2);return;
                    end
                    
                end
                
            end
            
            fprintf(fp2, '%s', filecontents{i});
        end
        
        fclose(fp2);
        
        %update file
        [ok ,msg] = movefile([forcedeffile '.new' ], forcedeffile);
        if ~ok
           ShowError(['There was an error writing to the force defintion file.' msg]); 
        end
        set(gcf, 'pointer', 'watch');
        writeforce();
        set(gcf, 'pointer', 'default');
        
    else
       ShowError('There was an error writing to the force defintion file.'); 
    end
    
elseif strcmp(action, 'isvisible')
    
    r = get(panel, 'visible');
    if strcmp(r, 'on')
        r = 1;
    else
        r = 0;
    end
end

%==========================================================================

function [ok, tvals, forceval] = validForce(force_eqn, dawn, dusk, CP)

ok = false; tvals = []; forceval = [];
%validate equation
try
    vars = symvar(force_eqn);
catch err
    ShowError('There was an error anaylsing your equation. Please check the syntax.', err);
    return;
end

badvars = [];
for vi = 1:length(vars)
    vname = char(vars(vi));
    if ~strcmp(vname, 'dawn') && ~strcmp(vname, 'dusk') && ~strcmp(vname, 'CP') && ~strcmp(vname, 't')
        badvars = [badvars vi];
    end
end


if ~isempty(badvars)
    bv = '';
    for i = 1:length(badvars)
        bv = [bv ' ' char(vars(badvars(i)))];
    end
    ShowError(['Unknown variable name:' bv]);
    return;
end

try
    varname = sym('dawn');
    d = diff(str2sym(force_eqn), varname);
    varname = sym('dusk');
    d = diff(str2sym(force_eqn), varname);
catch err
    ShowError(['Unable to calculate the derivative of this equation with respect to ' char(varname)], err);
    return;
    
end

tvals = [0:(CP/1000):CP];
forceval = zeros(1000,1);

try
    for i=1:length(tvals)
        t = tvals(i);
        forceval(i) = eval(force_eqn);
        if isinf(forceval(i)) || isnan(forceval(i))
            ShowError(['Discontinuity detected at time = ' num2str(t) ]);
            return;
        end
    end
    
catch err
    ShowError(['There was an error evaluating your equation at time = ' num2str(t) '. Please check the syntax.'], err);
    return;
end


ok = true;