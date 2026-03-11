

function r = showExportModelPanel(varargin)


persistent myDir panel modelNameHndl   txtHndl model titleHndl
 
global title_fontsize
 
action = varargin{1};
r = [];

if strcmp(action, 'init')

    %creates controls on the first panel
    myDir = varargin{2};
    pos = varargin{3};
    fig = varargin{4};
    
    maincol = get(fig, 'Color');
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'off', ...
        'Parent', fig);
    
    panelwidth = pos(3);panelheight=pos(4);
   
   titleHndl =uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Model details' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

    
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'SBML model name:' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2 4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   modelNameHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'Model name' ,'Units','centimeters','Style','edit', ...
       'position',[4.5 panelheight-2 5 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    
  
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'You can add to the  SBML model->notes field here:' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-3 (panelwidth-1) 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
  
    txtpos = [0.5 0.5 panelwidth-1 panelheight-3.5];
    [txtHndl, ~] = create_html_panel(panel, txtpos, '', true);
    
  
    data = [];
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        model = varargin{2};
        
        set(titleHndl, 'string', ['Exporting the ' model.type ' model ' model.name]);
        set(modelNameHndl, 'string', model.name);
        notes = '';
        
        fname = fullfile(model.dir, [model.name '.info']);
        file = fopen(fname, 'r');
        %everything after first line before row of ======
        while ~feof(file)
            line = fgets(file);
            if length(line) > 7
                if strncmp('%%%info',line,7)
                    notes = [notes ' ' line(8:end)];
                end
            end
            
        end
        fclose(file);
        
        set(txtHndl, 'String', notes);
      
       
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 
    
  
    

elseif strcmp(action, 'gonext')

    %called when user click Next.
    r = [];
    model.notes = get(txtHndl, 'String');
    if iscell(model.notes)
        model.notes = strjoin(model.notes, sprintf('\n'));
    end
    model.notes = fixXMLString(model.notes);

    model.sbmlname = get(modelNameHndl, 'string');
    if isempty(regexp(model.sbmlname, '^[a-zA-Z_][a-zA-Z0-9_]*$', 'once'))
        ShowError('The model name will be mapped to the SBML id attribute, and so must consist of alphanumeric characters and underscores, and cannot begin with a digit.');
        return; 
    end
   

    r = model;
        
    set(panel, 'visible', 'off');
  
    
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
