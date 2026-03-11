function r = newForcePanel(varargin)


persistent nameHndl txtHndl msg;
persistent myDir panel;
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

    %file name selection
    uicontrol('HorizontalAlignment', 'left','Parent', panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 panelheight-1.1 panelwidth-1 0.7],'string','Enter a force name consisting of up to 12 alphanumeric characters:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', title_fontsize);
    
     nameHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[0.5 panelheight-2 panelwidth-1 0.7], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, 'BackgroundColor', 'w',...
        'String', 'newforce');
    
    % information contorl is a java html viewer
    
    
   msg = fileread(fullfile(myDir, 'readme.txt'));
    
    txtpos = [0.5 0.5 panelwidth-1 panelheight-3];
    [txtHndl, ~] = create_html_panel(panel, txtpos, msg, false);
    
   

    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        data = varargin{2};
        %nothing to set on this panel as it is the first
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on');  
    

elseif strcmp(action, 'gonext')
    
 %called when user click Next. Hides panel reads in file
 %returns [] if not valid


    r = [];
  
    %read selected data file
    forceName = get(nameHndl, 'String');
    
    if length(forceName) > 12
        
        ShowError('Please enter a name of not more than 12 characters');
        uicontrol(nameHndl);
        return;
    end
    
    if ~isempty(regexp(forceName, '[^a-zA-Z0-9]', 'once'))
       ShowError('Please enter a name consisting of only alphanumeric characters'); return;
    end
    
    existing_forces = get_all_force_types();
    
    if any(strcmp(existing_forces, forceName))
         ShowError([' A force with the name ' forceName ' already exists']);
         uicontrol(nameHndl);
         return;
    end
    
    set(panel, 'visible', 'off');
    r = forceName;
    
    
elseif strcmp(action, 'goback') 
   
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'isvisible') 
    
    r = get(panel, 'visible');
    if strcmp(r, 'on')
        r = 1;
    else
        r = 0;
    end
end
