

function r = showModelPanel(varargin)


persistent myDir panel modelNameHndl levelHndl versionHndl txtHndl sbml_model
 
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
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Model details' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

    
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'Model name:' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2 panelwidth/2-0.5 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);

    modelNameHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[panelwidth/4 panelheight-2 panelwidth/2-0.5 0.7], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', []);
    
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'SBML Level:' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-3 (panelwidth-1)/4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    levelHndl=uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', '' ,'Units','centimeters','Style','text', ...
       'position',[panelwidth/4 panelheight-3 (panelwidth-1)/4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'SBML Version:' ,'Units','centimeters','Style','text', ...
       'position',[panelwidth/2 panelheight-3 (panelwidth-1)/4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    versionHndl=uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', '' ,'Units','centimeters','Style','text', ...
       'position',[3*panelwidth/4 panelheight-3 (panelwidth-1)/4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'Notes:' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-4 (panelwidth-1)/4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
  
    txtpos = [0.5 0.5 panelwidth-1 panelheight-4.5];
    [txtHndl, ~] = create_html_panel(panel, txtpos, '', true);
    
  
    data = [];
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        sbml_model = varargin{2};
        
        set(modelNameHndl, 'string', sbml_model.id);
        set(levelHndl, 'string', num2str(sbml_model.SBML_level));
        set(versionHndl, 'string', num2str(sbml_model.SBML_version));
        
        notes = regexprep(sbml_model.notes, '<[^>]*>', '');
        set(txtHndl, 'String', notes);
      
       
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 
    

    

elseif strcmp(action, 'gonext')

    %called when user click Next.
    r = [];
    
    sbml_model.sassyname = get(modelNameHndl, 'string');
    if isempty(regexp(sbml_model.sassyname, '^[a-zA-Z][a-zA-Z0-9_]*$', 'once'))
       
        ShowError('Please enter a valid model name consisting of alphanumeric characters and underscores, and beginning with an alphanumeric character.');
        return;
    end
    sbml_model.sassynotes = get(txtHndl, 'String');
    if iscell(sbml_model.sassynotes)
        sbml_model.sassynotes = strjoin(sbml_model.sassynotes, sprintf('\n'));
    end
    
    %analyse the model species
   
    
    Species = AnalyseSpeciesforSASSy(sbml_model);
   
    for i = 1:length(Species)
 
        if strcmp(char(Species(i).Name), sbml_model.species(i).id)
            Species(i).Description = sbml_model.species(i).name; %Species.Name will be the id attribute in xml file read by libSBML
        else
            Species(i).Description = char(Species(i).Name);
        end
        
        notes = regexprep(sbml_model.species(i).notes, '<[^>]+>', '');
        notes = strrep(notes, sprintf('\n'), '');
        if ~isempty(notes)
            notes = strtrim(notes);
            notes = notes(1:min(length(notes),100));
            Species(i).Description = [Species(i).Description ', ' notes];
        end
            
    end
    

    r{1} = sbml_model;
    r{2} = Species;
         
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










