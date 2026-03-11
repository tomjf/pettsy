function makegui(action)

persistent newFig panel makeHndl closeHndl mdlHndl txtHndl

if nargin < 1
    action = 'init';
    
end

if strcmp(action, 'init')
   
    newFig=figure('menubar', 'none', 'resize', 'off', 'Units', 'centimeters','Name','Install a new model' ,'NumberTitle','off','Visible','on', 'WindowStyle', 'modal'); 
    maincol = get(newFig, 'color');
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    figwidth = 10;
    figheight = 12;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    set(newFig, 'Units', 'centimeters', 'Position', [figleft figbottom figwidth figheight]);
    
    panelheight = figheight-1.25;panelwidth=figwidth-0.5;
    
    panel_pos = [0.25 1 figwidth-0.5  figheight-1.25];
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',panel_pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'on', ...
        'Parent', newFig);
    
    
    mydir = fileparts(mfilename('fullpath'));
    DefsDir = fullfile(mydir, 'definitions');
    
    models = dir(fullfile(DefsDir, '*_model.m'));
    modelnames = {models(:).name};
    modelnames = regexp(modelnames,'^([A-Za-z0-9_])+_model\.m$', 'tokens');
    names = cell(1, length(modelnames));
    
    names{1} = 'Select a model...';
    for m = 1:length(modelnames)
        names{m+1}=char(modelnames{m}{1});
    end

    %file name selection
    uicontrol('HorizontalAlignment', 'left','Parent', panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 panelheight-1.1 panelwidth-1 0.7],'string','Select your model definition file:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    mdlHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
               'string', names, 'value', 1, 'callback', 'makegui(''changemodel'');', ...
               'Units','centimeters','Style','popup', ...             
               'position',[0.5 panelheight-1.8 panelwidth-1 0.7],'Visible', 'on', ...
               'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
           
           
           
  txtpos = [0.5 0.5 panelwidth-1 panelheight-2.5];
  [txtHndl, txtIsHtml] = create_html_panel(panel, txtpos, '', false);
    
     makeHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-5.1 0.1 2.5 0.7], ...
        'Interruptible','on', ...
        'string', 'Install', ...
        'HandleVisibility', 'on', ...
        'Parent',newFig, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','makegui(''run'');');
    
    closeHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.6 0.1 2.5 0.7], ...
        'Interruptible','on', ...
        'string', 'Cancel', ...
        'HandleVisibility', 'on', ...
        'Parent',newFig, ...
        'FontUnits', 'points', 'FontSize',10, ...
        'Callback','delete(gcf);');  
    
   
    
elseif strcmp(action, 'changemodel')
    
    models = get(mdlHndl, 'string');
    modelnum = get(mdlHndl, 'value');
    modelname = models{modelnum};
    
    if strcmp(models{1}, 'Select a model...')
       if modelnum == 1
           return;
       end
       models(1) = [];
       set(mdlHndl, 'string', models, 'value', modelnum-1);
    end
    
    mydir = fileparts(mfilename('fullpath'));
    DefsDir = fullfile(mydir, 'definitions');
    
    modelfile = fullfile(DefsDir, [modelname '_model.m']);
    
    if exist(modelfile, 'file') ~= 2
        ShowError(['Cannot find definition file ' modelfile]);
        return;
    else
        
        model_info = ''; orbit_type = 'oscillator'; dim = 0; dydt = false;
        fp = fopen(modelfile, 'r');

        while ~feof(fp)
            str = fgets(fp);
            
            info=regexp(str, '^%%%info\s+(.)+$', 'tokens');
            if ~isempty(info)
                model_info = [model_info char(info{1}) sprintf('\n')];
            else
                info=regexp(str, '^%%%orbit_type\s+(.)+$', 'tokens');
                if ~isempty(info)
                   orbit_type =  char(info{1});
                elseif ~isempty(regexp(str, '^\s*dydt\(\d+\)\s*=', 'once'))
                    dim = dim+1;
                else
                    if ~isempty(regexp(str, '[', 'once'))
                        dydt=true;
                    end
                    if dydt == true && lineIsEquation(str) %not comment. Finds content of dydt = [...  ...];
                        dim = dim+1;
                    end
                    if ~isempty(regexp(str, ']', 'once'))
                        dydt=false;
                    end
                end
            end

        end
        fclose(fp);
        
        model_info = ['<html><div style="padding:5px"><p>' orbit_type ' model with ' num2str(dim) ' equations</p><p></p>' sprintf('\n')  model_info '</div></html>'];
        
        try
            txtHndl.Data = model_info;
        catch
            model_info = regexprep(model_info, '<[^>]*>', '');
            set(txtHndl, 'String', model_info);
        end

    end

    
elseif strcmp(action, 'run')
    
    models = get(mdlHndl, 'string');
    modelnum = get(mdlHndl, 'value');
    modelname = models{modelnum};
    
    mydir = fileparts(mfilename('fullpath'));
    DefsDir = fullfile(mydir, 'definitions');
    
    modelfile = fullfile(DefsDir, [modelname '_model.m']);
    
    if exist(modelfile, 'file') ~= 2
        ShowError(['Cannot find definition file ' modelfile]);
        return;
    end
    
    wbHndl = waitbar(0.0,'Installing the new model...', 'Name', 'PeTTSy', 'pointer', 'watch', 'resize', 'off', 'userdata', 0);
    newpath = make(modelname, [], wbHndl);  
    delete(wbHndl);
      
    if ~isempty(newpath) 
        %add to menu
        
        pettsy('addmodel', newpath);
        
        msgbox(['Model ' modelname ' installed successfully.'], 'PeTTSy - Install model');
    end
    
end

%==========================================================================

function r = lineIsEquation(str)

%tests if str2 is either an equations, or the end of n equation started on
%str1

%remove comment to simplify

str = regexprep(str, '%.*', '');
%extract anything between any [...]
str = regexprep(str, '.*\[', ''); %remove dydt = [
str = regexprep(str, ']', '');


if isempty(regexp(str, '\S', 'once'))
    r = false; %no non-whitespace
else
    if isempty(regexp(str, '\.\.\.', 'once')) && ~isempty(regexp(str, '\w', 'once'))
        r=true; %has letter or numbers but doesn't end in ...
    else
        r=false;
    end
end

     
    
    

