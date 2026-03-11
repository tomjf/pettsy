function sagui(varargin)

%To launch this gui, go to its directory and enter
%'sagui'.  
%Select the model you want from the list in the top left. This then fills
%the Simulation list with all the available files. Select one of these and
%some basic informatoin about the data in this file will be dispalyed in
%the boxes below. Select Plot Type and click  Plot to draw the graph. 
%A number of controls appear below the plot, depending on what type of plot
%it is. If you adjust these then click Plot again to see the effect.
%Click Print Preview to remove all controls and display the plot for
%printing. Check Print to file and select a file type, or leave this unchecked to
%print to a printer. Clicking Close in print mode restores the GUI to its
%normal state.

if nargin == 0 
    varargin{1} = 'init';
end
UserEvent(varargin);

%%%%%%%%%%%%%%%%%add directory to path
%=============================================
function UserEvent(varargin)

global titlePanel_sa;
global leftPanel_sa;
global mainFig_sa;
global btncol maincol
global listOfModels_sa;
global CurrentModel_sa;
global menuHndls exptMenu newanalysisMenu wbHndl;
global SDSdata
global plot_font_size

plot_font_size=16;

args = varargin{1};
if iscell(args)
    action = args{1};
else
    action = args;
end

if strcmp(action,'init')
    
   wbHndl = waitbar(0.05,'Searching for models...', 'Name', 'Sensitivity Analysis', 'pointer', 'watch', 'resize', 'off');
   paths = {'models/oscillator';  'models/signal'};
   listOfModels_sa = getlistofmodels(wbHndl, paths, 'theory');
   %find all modesl with theoretical data models, each has its own folder
   if isempty(listOfModels_sa)
       ShowError('There are no models with any time series derivatives available! Please use PeTTSy to generate soem data first.');
       delete(wbHndl);
       return;
   end
  
    waitbar((length(listOfModels_sa)+1)/(length(listOfModels_sa)+3),wbHndl, 'Generating figure...');

    %create figure
    mainFig_sa=figure('resize', 'off', 'menubar', 'none' ,'Name','Sensitivity Analysis' ,'NumberTitle','off','Visible','off', 'CloseRequestFcn', 'sagui(''close'')');
    
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    figwidth = 24;
    figheight = 18;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    
    pos = [figleft figbottom figwidth figheight];
    set(mainFig_sa, 'Units', 'centimeters', 'Position', pos);
    
    maincol = get(mainFig_sa, 'Color');
    
    %set constants and global variables
    btncol = [0.8 0.8 0.8];
    btnLen=0.125;
    btnWid=0.125;
    PlotFuncs = {'sa_plottseries'; 'sa_plotderivative'; 'sa_plotpcs'; 'sa_plotsensitivity'; 'sa_plottseriessens'; 'sa_plotsigspec'; 'sa_plotsigspecvars'; 'sa_plotstrengths'; 'sa_plotscatter'; 'sa_plotcomposite'};
               
    CurrentModel_sa = [];
                   
    %define panels
    frmPos=[0.1 figheight-1.7 figwidth-0.2 1.5];
    titlePanel_sa = sa_titlepanel('init', mainFig_sa, frmPos);
    %uicontrol('HorizontalAlignment', 'left','Parent',mainFig_sa ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.3 figheight-0.5 1.1 0.5],'string','Model','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    
    
    waitbar((length(listOfModels_sa)+2)/(length(listOfModels_sa)+3),wbHndl, 'Loading settings...');
  %  uicontrol('HorizontalAlignment', 'left','Parent',mainFig_sa ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.3 figheight-2.2 0.9 0.5],'string','Data','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    frmPos=[0.1 0.1 figwidth/2-0.15 figheight-2];
    leftPanel_sa = sa_leftpanel('init', mainFig_sa, frmPos);
   
    
    frmPos=[figwidth/2+0.05 0.1 figwidth/2-0.15 figheight-2];
    rightPanel_sa = sa_rightpanel('init', mainFig_sa, frmPos, PlotFuncs);
  %  uicontrol('HorizontalAlignment', 'left','Parent',mainFig_sa ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[figwidth/2+0.25 figheight-2.2 1.4 0.5],'string','Plotting','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);


    
    %file menu
    fileMenu = uimenu('Label', 'File');
    saveMenu = uimenu(fileMenu, 'Label', 'Export data', 'callback', 'sagui(''export'');');
    
    newanalysisMenu = uimenu(fileMenu, 'Label', 'Save Analysis Settings', 'callback', 'sagui(''newanalysis'');');

    exitMenu = uimenu(fileMenu, 'Label', 'Exit', 'callback', 'sagui(''close'');');
     %create model selecton menu and select initial model
    mdlMenu = uimenu('Label', 'Model');
    oscMenu = uimenu(mdlMenu, 'Label', 'Oscillator');
    sigMenu = uimenu(mdlMenu, 'Label', 'Signal');
    menuHndls = [];
    for i = 1:length(listOfModels_sa)
        if strcmp(listOfModels_sa(i).type, 'oscillator')
            m = oscMenu;
        elseif strcmp(listOfModels_sa(i).type, 'signal')
            m = sigMenu;
        end
        tmp = uimenu(m, 'Label', listOfModels_sa(i).name, 'Checked', 'off', 'callback', 'sagui(''ModelMenuChanged'');', 'UserData', listOfModels_sa(i));
        menuHndls = [menuHndls; tmp];
    end
    exptMenu = uimenu('Label', 'Experiment');
    newMenu = uimenu(exptMenu, 'Label', 'New', 'callback', 'sagui(''newexpt'');');
   
    %Read control setting if file exists
    
    % Show the figure
    set(mainFig_sa,'Visible','on');
    
    waitbar(1,wbHndl,'Loading settings...');
    % LoadSettings; %This function must set the menu and CurrentModel_sa
    delete(wbHndl);
    
    if length(args) > 1
        %pre-select a model and also maybe an analysis file
        mdl = args{2};
        for i = 1:length(menuHndls)
            if strcmp(get(menuHndls(i), 'Label'), mdl)
                set(menuHndls(i), 'Checked', 'on');
                break;
            end
        end
        if length(args) > 2
            fi = args{3};
            ChangeModelName(mdl, fi);
        else
            ChangeModelName(mdl);
        end
    else
        %sets defaults
        mdl = get(menuHndls(1), 'Label');
        set(menuHndls(1), 'Checked', 'on');
        ChangeModelName(mdl);
    end

elseif strcmp(action, 'close')
    %SaveSettings;
    delete(gcf);
    
elseif strcmp(action, 'ModelMenuChanged')  
   %called when user selects a new model
   ModelMenuChanged;

elseif strcmp(action, 'newexpt')
    
    %create new expt file
    
    newexptgui('init', CurrentModel_sa);
    
%=======================================================================
%these cause plot button to be disabled
%elseif strcmp(action, 'changeTime') || strcmp(action, 'changePars') || strcmp(action, 'changeScale')
 %   SetButtons(0);
elseif strcmp(action, 'calcsds')
    %re-calc sds
    SetSDS;
elseif strcmp(action, 'plot')
    DoPlot
%====================================================================
elseif strcmp(action, 'viewParams')
    
    paramdescgui(CurrentModel_sa);

elseif strcmp(action, 'viewVars')
    
     vardescgui(CurrentModel_sa);
   
%====================================================================    
elseif strcmp(action, 'auto')
    AutoPlot(args);

elseif strcmp(action, 'synch')
    SynchCtrls(args);
    
elseif strcmp(action, 'export')
    %write sds data to worksoace
    
     %save data to workspsace
    
    if ~isempty(SDSdata)
        
        exportSDS(SDSdata);
        
    else
        uiwait(msgbox('There is nothing to export yet. Please click ''Get SDS'' to perform SVD analysis.','Export data'));
    end
    
%     if ~isempty(SDSdata)
%         [FileName,PathName] = uiputfile('*.mat','Save SDS as', [SDSdata.mymodel 'SDS.mat']) ;
%         if ~isequal(FileName, 0)
%             save(fullfile(PathName, FileName), 'SDSdata');
%         end
%     else
%         ShowError('There is nothing to export yet.');
%     end
elseif strcmp(action, 'newanalysis')
    
    %save control settings in a new .an file
    sa_leftpanel('saveanalysis');
    
end

%============================================
function ModelMenuChanged

%called only whe user clicks the menu
global menuHndls;
%Detects which menu item the user has selected
selItem = gcbo;
%check the selected item and uncheck the others
set(selItem, 'Checked', 'on');
for i = 1:length(menuHndls)
   if menuHndls(i) ~= selItem;
       set(menuHndls(i), 'Checked', 'off');
   end
end
ChangeModelName(selItem);

%============================================
function ChangeModelName(mdl, varargin)

%called in init procedure and when user selects a model
%mdl is either the name of the selected model, or a menu item selected
%fi the index of a results file to pre-select. It is either specified on
%the comand line, read from the ini file, or if there is no ini file at
%startup, or when the user changes the model, it is set to 1

global CurrentModel_sa SDSdata
global menuHndls exptMenu newanalysisMenu

if ischar(mdl)
    %name so find menu item. Called in this way at startup
    modelname = mdl;
    mdl = [];
    for i = 1:length(menuHndls)
       if strcmp(get(menuHndls(i), 'Label'), modelname)
           mdl = menuHndls(i);
           break;
       end
    end
end

if ~isempty(mdl)
    CurrentModel_sa = get(mdl, 'UserData'); 
    set([newanalysisMenu exptMenu], 'enable', 'on');
else
   %no model selected
   CurrentModel_sa = [];
   set([newanalysisMenu exptMenu], 'enable', 'off');
end
sa_rightpanel('nodata');
sa_titlepanel('newmodel', CurrentModel_sa);
if nargin > 1
    sa_leftpanel('newmodel', CurrentModel_sa, varargin{1});
else
    sa_leftpanel('newmodel', CurrentModel_sa);
end

SDSdata = [];
SetButtons(0);

%==============================================
function SetButtons(gotSDS)

%called when sds is created, or one of the sds params, scaling or
%time is changed

%if getSDS is non-zeros then we have the sds structure and it corresponds to
%the current control settings, so disable Calculate button and allow
%plotting

%If one of the controls or the results file changes, disable plotting and
%allow a new sds to be calculated.

global SDSdata;

if gotSDS
    if isempty(SDSdata.bigU)
        cmb = 0;
    else
        cmb = 1;
    end
    sa_rightpanel('enableplot', 'on', cmb);
 %   sa_leftpanel('enableSDS', 'off');
else
    sa_rightpanel('enableplot', 'off', 2);
  %  sa_leftpanel('enableSDS', 'on');
end


%============================================
function DoPlot()
 %called when user clicks plot
global SDSdata;

if ~isempty(SDSdata)
    sa_rightpanel('plot', SDSdata);
end

%==============================================
function SaveSettings()

%saves control settings to file so they can be restored next time
global CurrentModel_sa;

fid = fopen('SA5Gui.ini', 'wt');
%model name
if ~isempty(CurrentModel_sa)
    fprintf(fid, '%s\n', CurrentModel_sa.name);
else
    fprintf(fid, '0\n');
end
%results file, periodic, timepsan, scale , parameters
sa_leftpanel('save', fid);
%plottype and plot specific controls
sa_rightpanel('save', fid);
fclose(fid);

%==============================================
function LoadSettings()
%return;
%read the file created above and restores the vlaues.
%Will only work if the the control creation routines have not been edited
%since the file was created

%if no file found, sets defaults
global menuHndls;
done = 0;
% if exist('SA5Gui.ini', 'file') == 2
%     try
%         cvs = textread('SA5Gui.ini', '%[^\n]');
%         model = char(cvs(1));
%         resfile = str2double(cvs(2));
%         %check appropriate menu item
%         for i = 1:length(menuHndls)
%             if strcmp(get(menuHndls(i), 'Label'), model) 
%                 set(menuHndls(i), 'Checked', 'on');
%                 ChangeModelName(menuHndls(i), resfile);
%                 sa_rightpanel('load', cvs(3:end));
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
   set(menuHndls(1), 'Checked', 'on');
   ChangeModelName(get(menuHndls(1), 'Label'));
end

%===================================================
function SetSDS()

%Here create the combined dgs matrix, and also the list of variable names
%that will represent the columns of this matrix

%for each expt selected
    %read lc from file listed in expt file
    %periodic or non-per?
    %remove/combine cols accordong to expts file
%interplotate timepoints so all match and per equal?
%combine into one dgs matrix
%select parmeters(rows)
%scaling

%an expt file defines
%   data file
%   per vs nonper dgs to be read from file
%   how to combine the variable in the dgs matrix

%in addition we need to use the controls to define the following (same for
%all expts)
%   time window to extract from dgs
%   params to use
%   scaling
%Analysis files set all these, as well as selecting expt files



global SDSdata CurrentModel_sa mainFig_sa

SDSdata = [];
thetheoryresults = [];
sa_rightpanel('nodata');

which_pars = sa_leftpanel('getpars');
if ~which_pars
    ShowError('Please select some parameters to include!');
    return;
end
scaling =  sa_leftpanel('getscale');

expts = sa_leftpanel('getexpts');
if isempty(expts)
    ShowError('Please select one or more experiments to analyse!');
    return;
end


all_dgs = cell(length(expts),1);
all_vnames = cell(length(expts),1);
all_periodic = [];
all_newlc = cell(length(expts),1);
all_newdy = cell(length(expts),1);
all_files = cell(length(expts),1);
all_t = cell(length(expts),1);
all_force = cell(length(expts),1);
all_force_names = cell(length(expts),1);
all_tend = cell(length(expts),1);
all_par = cell(length(expts),1);


%for each selected experiment
for e = 1:length(expts)
    set(mainFig_sa, 'pointer', 'watch');
    fid_tmp = fopen([CurrentModel_sa.dir, '/results/' char(expts(e)), '.expt'], 'r');
    tmp_scan = textscan(fid_tmp, '%[^\n]');
    fclose(fid_tmp);
    cvs = tmp_scan{1};
    datafile = char(cvs(1));

    periodic = str2double(char(cvs(3)));

    vars = cell(0);
    for i = 4:length(cvs)
        if strcmp(char(cvs(i)), '--')
           break;
        end
        vars{i-3} = sscanf(char(cvs(i)), '%f')';
    end
    tidx = [];
    cvs = cvs(i+1:end);
    for j = 1:length(cvs)
        if str2double(char(cvs(j)))
            tidx = [tidx j];
        end
    end
    
    %read the dgs specified
    clear thetheoryresults;
    CurrentFile = [CurrentModel_sa.dir, '/results/', datafile];
    if exist(CurrentFile, 'file') == 2
        load(CurrentFile, '-mat'); 
        if exist('thetheoryresults', 'var') == 1
            if ~isfield(thetheoryresults, 'theory')
                ShowError('Cannot find the theoretical data in the selected file.');
                set(mainFig_sa, 'pointer', 'arrow');
                return;         
            end
        else
            %error data not in file
            ShowError(['Cannot find the data in the selected file ' datafile '.']);
            set(mainFig_sa, 'pointer', 'arrow');
            return;
        end
    else
         %missing file
         ShowError(['Cannot find the selected file ' datafile ' defined in experiment ' expts{e} '.']);
          set(mainFig_sa, 'pointer', 'arrow');
         return;
    end
    %found dgs in file
    if periodic
        if ~isfield(thetheoryresults.theory, 'periodic_dgs')
            ShowError(['Cannot find periodic dgs in the selected file ' datafile '.']);
             set(mainFig_sa, 'pointer', 'arrow');
            return;
        else
            dgs = thetheoryresults.theory.periodic_dgs;
        end
    else
        if ~isfield(thetheoryresults.theory, 'nonper_dgs')
            ShowError(['Cannot find non-periodic dgs in the selected file ' datafile '.']);
            set(mainFig_sa, 'pointer', 'arrow');
            return;
        else
            dgs = thetheoryresults.theory.nonper_dgs;
        end
    end  
    
    %select the required parameters
    
    try
        dgs = dgs(tidx, :, which_pars);
        
        %select the required columns (variables)
        %dgs is time * var * Param
        numt = size(dgs ,1); numv = length(vars); nump = size(dgs, 3);
        
        % if dim*numt < pnum it will crash
        if (numt * numv) < nump
            ShowError(['It is not possible to carry out SVD on the selected experiment ' datafile ' over the time range ' num2str(thetheoryresults.sol.x(tidx(1))) ' to ' ...
                num2str(thetheoryresults.sol.x(tidx(end))) ' as the product of the number of timepoints and the number of model variables must be at least equal to the number ' ...
                'of selected parameters. Try extending the time range or reducing the number of parameters.' ]);
            set(mainFig_sa, 'pointer', 'arrow');
            return;
        end
        
        new_dgs = zeros(numt, numv, nump); new_lc = zeros(numt, numv); new_dy = zeros(numt, numv);
        vnames = cell(1, numv);
        new_t = thetheoryresults.sol.x(tidx);
        
        new_force_name = cell(0);
        new_force = [];
        if ~isempty(thetheoryresults.force)
            new_force = thetheoryresults.force(tidx,:);
            for f = 1:length(thetheoryresults.forceparams)
                new_force_name{f} =  char(thetheoryresults.forceparams(f).force);
            end
        end
        
        if strcmp(CurrentModel_sa.type, 'signal')
            tend = thetheoryresults.tend;
        else
            tend = thetheoryresults.per;
        end
        par = thetheoryresults.par;
        
        %combine and eliminate variables from dgs and limit cycle
        for v = 1:numv
            if isscalar(vars{v})
                new_dgs(:, v, :) = dgs(:, vars{v}, :);
                %record variable names
                vnames{v} = CurrentModel_sa.vnames{vars{v}};
                if length(expts) > 1
                    vnames{v} = [expts{e} ':' vnames{v}];
                end
                new_lc(:, v) = thetheoryresults.sol.y(tidx, vars{v});
                new_dy(:, v) = thetheoryresults.sol.dy(tidx, vars{v});
            else
                tmp = dgs(:, vars{v}, :);
                new_dgs(:, v, :) = sum(tmp, 2);
                tmp = thetheoryresults.sol.y(tidx, vars{v});
                new_lc(:, v) = sum(tmp, 2);
                tmp = thetheoryresults.sol.dy(tidx, vars{v});
                new_dy(:, v) = sum(tmp, 2);
                
                %record variable names (could save these in expt file instead)
                vrs = vars{v};
                tmp = [];
                for j = 1:length(vrs)
                    tmp = [tmp CurrentModel_sa.vnames{vrs(j)} '+'];
                end
                vnames{v} = tmp(1:end-1);
                if length(expts) > 1
                    vnames{v} = [expts{e} ':' vnames{v}];
                end
            end
        end
        
        %scaling
        %apply y or z scaling
        if strcmp(scaling, 'p')
            for pp=1:nump
                new_dgs(:,:,pp)=new_dgs(:,:,pp) * thetheoryresults.par(which_pars(pp));
            end
        elseif strcmp(scaling, 'yp')
            %y scaled is scaled by amp of  variable
            for xx=1:numv
                amp = max(new_lc(:,xx)) - min(new_lc(:,xx));
                if amp==0 amp=1; end
                new_dgs(:,xx,:)=new_dgs(:,xx,:)/amp;
            end
            for pp=1:nump
                new_dgs(:,:,pp)=new_dgs(:,:,pp) * thetheoryresults.par(which_pars(pp));
            end
        elseif strcmp(scaling, 'zp')
            %z scaled is scaled by amp of dgs for that var*par combination
            for xx=1:numv
                for pp=1:nump
                    amp = max(new_dgs(:,xx,pp))- min(new_dgs(:,xx,pp));% gives a coln vector with the amp of each row of z
                    if amp==0 amp=1; end
                    new_dgs(:,xx,pp)=new_dgs(:,xx,pp)/amp * thetheoryresults.par(which_pars(pp));
                end
            end
        end
    catch
        ShowError(['There was an error processing the time series file '  datafile '. Did you delete and re-create it since defining experiment ' char(expts(e)) '?']);
        set(mainFig_sa, 'pointer', 'arrow');
        return;
    end
    %combine together
    all_dgs{e} = new_dgs;
    all_vnames{e} = vnames;
    all_periodic(e) = periodic;
    all_newlc{e} = new_lc;
    all_newdy{e} = new_dy;
    all_files{e} = expts{e};
    all_t{e} = new_t;
    all_force{e} = new_force;
    all_force_names{e} = new_force_name;
    all_tend{e} = tend;
    all_par{e} = par;
end

             
try
    SDSdata = master_svd6(scaling, all_dgs);
    SDSdata.mymodel = CurrentModel_sa.name;
    SDSdata.mymodeltype = CurrentModel_sa.type;
    SDSdata.which_pars=which_pars;
 
    
 %add force params
    pnames = thetheoryresults.parn(which_pars); pdesc = thetheoryresults.parnames(which_pars);
    plist = cell(length(pnames), 1);
    for i = 1:length(pnames)
        plist{i} = sprintf('%s, %s', pnames{i}, pdesc{i});
    end
    SDSdata.parn = pnames;
    SDSdata.parnames = plist;
    SDSdata.scaling = scaling; %not used
  
    
    SDSdata.vnames = all_vnames; 
    
    
    SDSdata.periodic = all_periodic;
    SDSdata.lc = all_newlc;
    SDSdata.vector_field = all_newdy;
    SDSdata.exptnames = all_files;  %name of underlying expt files
    SDSdata.t = all_t;
    SDSdata.force = all_force;%used only in plottseries
    SDSdata.forcename = all_force_names;%not used, but should be in plottseries??
    if strcmp(CurrentModel_sa.type, 'signal')
        SDSdata.tend = all_tend;    %not used
    else
        SDSdata.per = all_tend;%not used
    end
    SDSdata.par = all_par;%not used
  
    %plot specific controls
    sa_rightpanel('fillPlotSDSCtrls', SDSdata);
catch err
    ShowError('An error occurred generating the SDS data! ', err);
    set(mainFig_sa, 'pointer', 'arrow');
    SDSdata = [];
end
clear thetheoryresults;
SetButtons(~isempty(SDSdata));
set(mainFig_sa, 'pointer', 'arrow');

%=========================================
function AutoPlot(args)


ShowError('This feature not working at present');
return;

global PlotTypePanels_sa;

switch(args{2})
    case ('comp')
        %scaling, threshold and timespan set automatically to synchronise
        %with heat map plot.
        pt = ChangePlotType('Composite Plot');
        ctrls = get(PlotTypePanels_sa(pt), 'UserData');
        pc = args{3};
        var = args{4};
        %now need to set pc and var controls accoring to the heat map that
        %was clicked on
        for j = 1:length(ctrls)
            if strcmp(get(ctrls(j), 'Style'), 'popupmenu')
                if strcmp(get(ctrls(j), 'Tag'), 'pc')
                    set(ctrls(j), 'Value', pc);
                elseif strcmp(get(ctrls(j), 'Tag'), 'var')
                    set(ctrls(j), 'Value', var);
                end
            end
        end
        DoPlot;
end

%============================================
function SynchCtrls(args)
return;
global PlotTypePanels_sa;
%find which control has changed
panel = args{2};
ctrl = args{3};
ctrls = get(PlotTypePanels_sa(panel), 'UserData');
newValue = [];
for c = 1:length(ctrls)
    if get(ctrls(c), 'UserData') == ctrl
       if strcmp(get(ctrls(c), 'Style'), 'edit')
           newValue = get(ctrls(c), 'String');
       else
            newValue = get(ctrls(c), 'Value');
       end
       break;
    end
end
if isempty(newValue)
    warning('Attempting to synchronise to unknown control');
    return;
end
%find all other other controls in same group and synchronise them
for p = 1:length(PlotTypePanels_sa)
    if p ~= panel
        ctrls = get(PlotTypePanels_sa(p), 'UserData');
        for c = 1:length(ctrls)
            if get(ctrls(c), 'UserData') == ctrl
                if strcmp(get(ctrls(c), 'Style'), 'edit')
                    set(ctrls(c), 'String', newValue);
                else
                    set(ctrls(c), 'Value', newValue);
                end
            end
        end
    end
end

%==================================================================

function name = getFileName(fname)

%removes extension from fname

pos = strfind(fname, '.');
pos = pos(end)-1;
name = fname(1:pos);

%disabling plot buttom too much, but not when changing expt????

%put expt file name in table, and use this in figure instead of exptidx,
%which might chagne if new expts files added

%delete expt file, but what if they are named in an analysis file?

%======================================================================

function exportSDS(SDSData)

%copy SDS to workspace

%user enters a name for variable
name = char(inputdlg('Select a name for the SDS variable', 'Export Data'));
if isempty(name)
    return;
end
%check its a legal variable name
if ~isstrprop(name(1), 'alpha')
     ShowError('MATLAB variable names must begin with a letter.');
     return;
end
for i = 2:length(name)
   if ~isstrprop(name(i), 'alphanum') && ~strcmp('_', name(i))
       ShowError('MATALB variable names must consist of alphanumeric characters and underscores only.');
       return;
    end
end

%modify name if necessary to ensure it is unique,ie doesn't
%overwrite an exisiting variable

%generate a unique var name stored in base workspace variable
%'varname'
evalin('base', ['varname = genvarname(''' name ''', who);']);
%retrieve this
varname = evalin('base', 'varname');
%execute on base workspace, store results in variable called this
assignin('base', varname, SDSData);
%remove string variable 'varname'
evalin('base', 'clear varname');
%done
uiwait(helpdlg(['SVD exported to the MATLAB workspace as variable ''' varname ''''],'Export Data'));


