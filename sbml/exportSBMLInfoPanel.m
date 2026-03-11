
function r = exportSBMLInfoPanel(varargin)


persistent   txtHndl msg model;
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

   
    % information contorl is a java html viewer
    
    
   msg = fileread(fullfile(myDir, 'export.txt'));
    
    txtpos = [0.5 0.5 panelwidth-1 panelheight-1];
    [txtHndl, ~] = create_html_panel(panel, txtpos, msg, false);
    

    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        model = varargin{2};
        %nothing to set on this panel as it is the first
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on');  
    
    
    
elseif strcmp(action, 'gonext')
    
 %called when user click Next. Hides panel reads in file
 %returns [] if not valid

   set(panel, 'visible', 'off');
    r = model;
  

    
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

% Hyperlink callback no longer needed - uihtml handles links via browser natively

