function pettsy(varargin)

% PeTTSy, Perturbation Theory Toolbox Software for Systems
% by 
% Copyright (C) 2015 Mirela Domijan, Paul Brown, Boris Shulgin, David Rand
% and University of Warwick
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


%ppi = get(0, 'screenpixelsperinch');
%set(0, 'screenpixelsperinch', 90)
%will display gui good size on 13 inch apple retina display
%see www.mathworks.com/matlabcentral/newsreader/view_thread/6836
%in general, ppi = ppi * desired width / actual width

global mydir
global plot_font_size

plot_font_size=16;

if nargin == 0 || strcmp(varargin{1}, 'init')  %initialisation
    
    %assume libSBML installed and ldconfig run and LD_LIBRARY_PATH set on linux, DYLD_LIBARY_PATH set on Mac and path set on
    %Windows as described at http://sbml.org/Software/libSBML/5.11.0/docs/formatted/cpp-api/libsbml-accessing.html
    %section 1
    
    
    if ispc
        
    else
        libSBMLPath = '/usr/local/lib'; 
        if exist(libSBMLPath, 'dir')
            addpath(libSBMLPath);
        end
    end
    
    
    mydir = fileparts(mfilename('fullpath'));
    
    if ~isdeployed
        if ~strcmp(pwd, mydir)
            error('The application should be launched from its installation directory.');
        end
        addpath(genpath(pwd));
    end
    
    wbHndl = waitbar(0.05,'Searching for models...', 'Name', 'PeTTSy', 'pointer', 'watch', 'resize', 'off');
    
    %find installed models
    paths = {[mydir '/models/oscillator']; [mydir '/models/signal']};
    listOfModels = getlistofmodels(wbHndl, paths);
    %find aall modesl with theoretical data models, each has its own folder
    %if ~isempty(listOfModels)
        UserEvent('init', listOfModels, wbHndl);
   % else
    %    ShowError('There are no models!');
    %end
    
    delete(wbHndl);
    
else
    UserEvent(varargin);
end


%=============================================
function UserEvent(varargin)

global mainFig_th CurrentModel_th menuHndls_th panelwidth panelheight rightMenu bottomMenu mydir aboutMenu;
persistent titlePanel leftPanel rightPanel tipPanel;

global plot_font_size
plot_font_size = 16;

args = varargin{1};
if iscell(args)
    action = args{1};
else
    action = args;
end

if strcmp(action,'init')
    
    try
        
        CurrentModel_th = [];
        listOfModels = varargin{2};
        wbHndl = varargin{3};
        waitbar((length(listOfModels)+1)/(length(listOfModels)+3),wbHndl, 'Generating figure...');
        
        %create figure
        mainFig_th=figure('resize', 'off', 'menubar', 'none' ,'Name','PeTTSy' ,'NumberTitle','off','Visible','off', 'CloseRequestFcn', 'pettsy(''close'')');
        
        %size it in cm and centre it on screen
        set(0,'Units','centimeters')
        screen_size = get(0,'ScreenSize');
        figwidth = 24;
        figheight = 18;
        %allow for tip window
        if (screen_size(3)/screen_size(4)) < 1.25
            loc = 'bottom';
            figleft = max((screen_size(3) - figwidth)/2, 0);
            figbottom = max((screen_size(4) - (figheight+4))/2, 0);
        else
            loc = 'right';
            figleft = max((screen_size(3) - (figwidth+7))/2, 0);
            figbottom = max((screen_size(4) - figheight)/2, 0);
        end
     
        pos = [figleft figbottom figwidth figheight];
        set(mainFig_th, 'Units', 'centimeters', 'Position', pos);
        maincol = get(mainFig_th, 'Color');
        
        waitbar((length(listOfModels)+2)/(length(listOfModels)+3),wbHndl, 'Loading settings...');
        
        %define panels
        %  uicontrol('HorizontalAlignment', 'left','Parent',mainFig_th ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.3 figheight-0.5 1.1 0.5],'string','Model','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        frmPos=[0.1 figheight-1.7 figwidth-0.2 1.5];
        titlePanel = th_titlepanel('init', mainFig_th, frmPos, 'Model');
        % uicontrol('HorizontalAlignment', 'left','Parent',mainFig_th ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.3 figheight-2.2 2.1 0.5],'string','Time Series','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        frmPos=[0.1 0.1 figwidth/2-0.15 figheight-2];
        leftPanel = th_leftpanel('init', mainFig_th, frmPos, 'Time Series');
        % uicontrol('HorizontalAlignment', 'left','Parent',mainFig_th ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[figwidth/2+0.25 figheight-2.2 1.4 0.5],'string','Plotting','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
        
        %tip panel, hidden
        tipPanel = th_tippanel('init', mainFig_th);
        
        frmPos=[figwidth/2+0.05 0.1 figwidth/2-0.15 figheight-2];
        rightPanel = th_rightpanel('init', mainFig_th, frmPos, 'Plotting');

        %file menu
        fileMenu = uimenu('Label', 'File');
        
        uimenu(fileMenu, 'Label', 'Export data', 'callback', 'th_leftpanel(''export'');');
        uimenu(fileMenu, 'Label', 'Exit', 'callback', 'pettsy(''close'');');
        
        %create model selection menu and select initial model
        
        mdlMenu = uimenu('Label', 'Model');
        oscMenu = uimenu(mdlMenu, 'Label', 'Oscillator', 'tag', 'oscillator_menu');
        sigMenu = uimenu(mdlMenu, 'Label', 'Signal',  'tag', 'signal_menu');
        
        uimenu(mdlMenu, 'Label', 'Install existing model', 'callback', 'pettsy(''makemodel'');', 'separator', 'on');
        uimenu(mdlMenu, 'Label', 'Import model from SBML', 'callback', 'pettsy(''sbmlmodel'');');
        uimenu(mdlMenu, 'Label', 'Export model to SBML', 'callback', 'pettsy(''exportsbmlmodel'');');
        uimenu(mdlMenu, 'Label', 'Create new model', 'callback', 'pettsy(''newmodel'');', 'separator', 'on');
        menuHndls_th = [];
        for i = 1:length(listOfModels)
            if strcmp(listOfModels(i).type, 'oscillator')
                m = oscMenu;
            elseif strcmp(listOfModels(i).type, 'signal')
                m = sigMenu;
            end
            tmp = uimenu(m, 'Label', listOfModels(i).name, 'Checked', 'off', 'callback', 'pettsy(''ModelMenuChanged'');', 'UserData', listOfModels(i));
            menuHndls_th = [menuHndls_th; tmp];
        end
        
        forceMenu = uimenu('Label', 'Force');
        uimenu(forceMenu ,'Label', 'Install new force', 'callback', 'pettsy(''newforce'');');
        
        %show tips
        helpMenu = uimenu('Label', 'Help');
        aboutMenu = uimenu(helpMenu, 'Label', 'About PeTTSy', 'callback', 'pettsy(''about'');');
        rightMenu = uimenu(helpMenu, 'Label', 'Tip Window - right', 'callback', 'pettsy(''tipwindow'', ''right'');', 'separator', 'on');
        bottomMenu = uimenu(helpMenu, 'Label', 'Tip Window - bottom', 'callback', 'pettsy(''tipwindow'', ''bottom'');');
        
        
        
        % Show the figure
        waitbar(1,wbHndl,'Loading settings...');
        
        %Read control setting if file exists
  
        set(mainFig_th,'Visible','on');
        drawnow;
        pettsy('tipwindow', loc);
        th_tippanel('write', '<b><font color=#000000>Welcome to PeTTSy</font></b><br/>', 0);
        %specifying font colour here, overrides highlight removal, ensuring
        %that heading is never grayed out.
        th_tippanel('clear_highlight'); %ensures icon printed when model details are printed next
        LoadSettings; %This function must set the menu and CurrentModel_th
   
    catch err
        ShowError('There was an error starting PeTTSy', err);
    end
    
   
    
    %show tips by default
    %decide on position according to screen size
    %fig is 4*3, if screen is too, put it at bottom, else for widesceen
    %monitors, put it at side
    
elseif strcmp(action, 'about')
    
    aboutgui;
    
elseif strcmp(action, 'makemodel')
    
    makegui;
  
elseif strcmp(action, 'nomodel')
    
    %called at startup if no models installed
    th_tippanel('write', 'There are no models currently installed. Go to the Model menu to install an exisiting model definition or import an SBML model.', 3);
    th_leftpanel('nomodel');
    
elseif strcmp(action, 'addmodel')
    
    %called from sbml gui and makegui
    modelpath = args{2};
    if ispc
        str=regexp(modelpath, '^(.)*\\([^\\]+)\\?$', 'tokens', 'once');
    else
        str=regexp(modelpath, '^(.)*/([^/]+)/?$', 'tokens', 'once');
    end
    modelpath = str{1};
    newmodelname = str{2};

    
    
    if ~isempty(strfind(modelpath, 'oscillator'))
        menu = findobj(mainFig_th, 'tag', 'oscillator_menu');
    else
        menu = findobj(mainFig_th, 'tag', 'signal_menu');
    end
    
    %get its details
    modelDetails = getlistofmodels([], {modelpath}, 'all', newmodelname);
    oldmenu=findobj(menu, 'Label', newmodelname);
    if ~isempty(oldmenu)       
        menuHndls_th(menuHndls_th == oldmenu) = [];
        delete(oldmenu);
    end
    newmenu = uimenu(menu, 'Label', newmodelname, 'Checked', 'off', 'callback', 'pettsy(''ModelMenuChanged'');', 'UserData', modelDetails);
    
    firstModel =  isempty(menuHndls_th);   
    menuHndls_th = [menuHndls_th; newmenu];
    
    if firstModel
       %no model selected so select this one
       pettsy('ModelMenuChanged', newmenu);
        
    end

    
elseif strcmp(action, 'newforce')
    
    forcegui;


elseif strcmp(action, 'tipwindow')
    
    pos = args{2};
    th_tippanel('show', pos);
    if strcmp(pos, 'right')
        set(rightMenu, 'checked', 'on');
        set(bottomMenu, 'checked', 'off');
    else
        set(rightMenu, 'checked', 'off');
        set(bottomMenu, 'checked', 'on');
    end
    
elseif strcmp(action, 'newmodel')
    
    %will run make function via a gui
    msgbox('Feature not yet implemented');
    
elseif strcmp(action, 'close')
    SaveSettings;
    delete(gcf);
    
elseif strcmp(action, 'ModelMenuChanged') 
    
    %called when user selects a new model via menu
    
    if length(args) == 1
        selItem = gcbo;
    else
        selItem = args{2}; %programatically selecting a model
    end
    %check the selected item and uncheck the others
    set(selItem, 'Checked', 'on');
    for i = 1:length(menuHndls_th)
        if menuHndls_th(i) ~= selItem
            set(menuHndls_th(i), 'Checked', 'off');
        end
    end
    th_tippanel('clear');
    ChangeModelName(selItem);

elseif strcmp(action, 'FilesChanged') 
    %called by leftpanel when users creates or deletes a time series
    files = varargin{1}{2};
    for i = 1:length(menuHndls_th)
       if strcmp(get(menuHndls_th(i), 'Label'), CurrentModel_th.name)
           model = get(menuHndls_th(i), 'Userdata');
           model.files = files;
           set(menuHndls_th(i), 'Userdata', model);
           break;
       end
    end
    CurrentModel_th.files = files; 

elseif strcmp(action, 'sbmlmodel')
    
    if exist('TranslateSBML.m', 'file') == 0
        
        msgbox('PeTTSy is unable to find libSBML on your MATLAB path.', 'PeTTSy');
        return;
        
    elseif exist('isValidSBML_Model.m', 'file') == 0
        
         msgbox('PeTTSy is unable to find the SBML toolbox on your MATLAB path.', 'PeTTSy');
         return;
    end
    
    sbmlgui;
    
elseif strcmp(action, 'exportsbmlmodel')
    
    if ~isempty(CurrentModel_th)
       
        exportsbmlgui('init', CurrentModel_th);
        
    else
        
        msgbox('There is no model to export yet.', 'PeTTSy');
        
    end

end
    
%============================================
function ChangeModelName(mdl)

%called in init procedure and when user selects a model via menu
%mdl is either the name of the selected model, or a menu item selected
%fi the index of a results file to pre-select. It is either read from the
%ini file, or if there is no ini file at
%startup, or when the user changes the model, it is set to 1

global CurrentModel_th
global menuHndls_th

if ischar(mdl)
    %name so find menu item. Called in this way at startup
    modelname = mdl;
    mdl = [];
    for i = 1:length(menuHndls_th)
       if strcmp(get(menuHndls_th(i), 'Label'), modelname)
           mdl = menuHndls_th(i);
           break;
       end
    end
end

if ~isempty(mdl)
    CurrentModel_th = get(mdl, 'UserData'); 
else
   %no model selected
   CurrentModel_th = [];
end

th_titlepanel('newmodel', CurrentModel_th);
th_leftpanel('newmodel', CurrentModel_th);


%==============================================
function SaveSettings()

%saves control settings to file so they can be restored next time
global CurrentModel_th;

fid = fopen('pettsy.ini', 'wt');
%model name
if ~isempty(CurrentModel_th)
    fprintf(fid, '%s\n', CurrentModel_th.name);
else
    fprintf(fid, '0\n');
end
%results file
th_leftpanel('save', fid);
fclose(fid);

%==============================================
function LoadSettings()
%return;
%read the file created above and restores the vlaues.
%Will only work if the the control creation routines have not been edited
%since the file was created

%if no file found, sets defaults
global menuHndls_th;
done = 0;
% if exist('SA5Gui.ini', 'file') == 2
%     try
%         cvs = textread('SA5Gui.ini', '%[^\n]');
%         model = char(cvs(1));
%         resfile = str2double(cvs(2));
%         %check appropriate menu item
%         for i = 1:length(menuHndls_th)
%             if strcmp(get(menuHndls_th(i), 'Label'), model) 
%                 set(menuHndls_th(i), 'Checked', 'on');
%                 ChangeModelName(menuHndls_th(i), resfile);
%                 th_rightpanel('load', cvs(3:end));
%                 done = 1;
%                 break;
%             end
%         end         
%     catch
%         %ShowError(['The control setting file was not in the correct format. Default settings will be applied. ', lasterr]);
%     end
% end
if ~done
   %sets defaults
   if ~isempty(menuHndls_th)
       set(menuHndls_th(1), 'Checked', 'on');
       ChangeModelName(get(menuHndls_th(1), 'Label'));
   else
       pettsy('nomodel');
   end
end




% figpos = get(src, 'position');
% 
% pos = get(titlepanel, 'position');
% pos(1) = 0.1;
% pos(2) = figpos(4)-1.7;
% set(titlepanel, 'position', pos);
% 
% pos = get(leftpanel, 'position');
% pos(1) = 0.1;
% pos(2) = figpos(4)-17.9;
% pwidth = pos(3);
% set(leftpanel, 'position', pos);
% 
% pos = get(rightpanel, 'position');
% pos(1) = pwidth+0.2;
% pos(2) = figpos(4)-17.9;
% set(rightpanel, 'position', pos);



%========================================================

%update plot panesl when running theory
