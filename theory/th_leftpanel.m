function r = th_leftpanel(action, varargin)

%Adds the controls to the left panel

global mydir newtsfilename newtheory

persistent panel myPos fromTop lblHndl  xppHndl resHndl runHndl delHndl runTheoryHndl mainFig exportHndl svdHndl
persistent  axHndl dateHndl forceHndl solverHndl lengthHndl
persistent theModel tsData


r = [];

if strcmp(action, 'init')
    
    mainFig = varargin{1};
    maincol = get(mainFig, 'color');
    myPos = varargin{2};
    tstr = varargin{3};
    pheight = myPos(4);
    pwidth = myPos(3);
    
    %measure height from to of figure
    %so we can keep this constant if figure increases in height
    figheight= get(mainFig, 'position');
    figheight = figheight(4);
    fromTop = figheight-(myPos(2)+myPos(4));
    %draw controls
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',myPos, ...
        'HandleVisibility', 'on', ...
        'title', 'Time Series', ...
        'Parent', mainFig);
 
    
    lblPos(1) = 0.2;
    lblPos(2) = pheight-0.7; %MD July 2015 pheight-0.4;
    lblPos(3) = 2.1;
    lblPos(4) = 0.5;
    
%     lblHndl =  uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',lblPos,'string',tstr,'BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);

    ctrlheight = pheight-1.5;
    %list of results files
    uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left', 'FontWeight', 'bold','Units','centimeters','position',[0.5 ctrlheight pwidth/2-0.5 0.5],'string','Select a time series:','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    
    ctrlheight = ctrlheight-1;
    runHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 ctrlheight (pwidth-1)/2 0.7], ...
        'string', 'New...', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Create a new time series', ...
        'Callback','th_leftpanel(''run'');');  %new limit cycle button

     delHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 ctrlheight-0.8 (pwidth-1)/2 0.7], ...
        'string', 'Delete', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'enable', 'off', ...
        'tooltipstring', 'Delete selected file', ...
        'Callback','th_leftpanel(''del'');'); 
    
    exportHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 ctrlheight-1.6 (pwidth-1)/2 0.7], ...
        'string', 'Export', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'enable', 'off', ...
        'tooltipstring', 'Save selected data to workspace', ...
        'Callback','th_leftpanel(''export'');'); 
    
    
    ctrlheight = ctrlheight-2.5;
    resHndl=uicontrol( ...
        'Style','listbox', ...
        'Units','centimeters', ...
        'position',[(pwidth+0.5)/2 ctrlheight (pwidth-1.5)/2 4], ...
        'min', 1, 'max', 1, ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'call','th_leftpanel(''changefile'');');
    
    
    %preview
    ctrlheight = ctrlheight-0.85;
    uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[0.5 ctrlheight pwidth/2-0.5 0.5],'string','Preview','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10, 'Fontweight', 'bold');
    
    ctrlheight = ctrlheight-0.6;
    uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[0.75 ctrlheight pwidth/4 0.5],'string','Date:','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    dateHndl = uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[pwidth/4-0.25 ctrlheight 3 0.5],'string','','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    
    uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[(pwidth+0.5)/2 ctrlheight pwidth/4 0.5],'string','Solver:','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    solverHndl = uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[(pwidth+0.5)/2+pwidth/4 ctrlheight 2 0.5],'string','','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    
    ctrlheight = ctrlheight-0.6;
%    uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[0.75 ctrlheight pwidth/4 0.5],'string','Force:','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
   % forceHndl = uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[0.75+pwidth/4 ctrlheight 2 0.5],'string','','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    
    uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[(pwidth+0.5)/2 ctrlheight pwidth/4 0.5],'string','Length:','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    lengthHndl = uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[(pwidth+0.5)/2+pwidth/4 ctrlheight 2 0.5],'string','','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10);
    
    ctrlheight = ctrlheight-5.25;
    %preview plot
    axHndl = axes('Parent',panel ,'xtick', [], 'ytick', [], 'box', 'on',  'color', 'w', 'units', 'centimeters', 'position', [0.75 ctrlheight pwidth-1.5 4.75]);
    
    %run theory
    ctrlheight = ctrlheight-1.5;
    uicontrol('Parent',panel ,'Style', 'text', 'horizontalalignment', 'left','Units','centimeters','position',[0.5 ctrlheight pwidth/2-0.5 0.5],'string','Analysis','BackgroundColor', maincol, 'ForegroundColor', 'k', 'FontUnits', 'points', 'FontSize', 10, 'Fontweight', 'bold');

    runTheoryHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5+(pwidth-1)/4 ctrlheight (pwidth-1)/2 0.7], ...
        'string', 'Derivatives...', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Calculate derivatives, IRCs etc... on the selected time series', ...
        'Callback','th_leftpanel(''runtheory'');');%run theory
    
    %launch sensitivityanalysisgui
    ctrlheight = ctrlheight-0.8;
    svdHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5+(pwidth-1)/4 ctrlheight (pwidth-1)/2 0.7], ...
        'string', 'SVD...', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Launch Sensitivity Analysis on the current model', ...
        'Callback','th_leftpanel(''runsvd'');');
    
    %launch xpp on this model
    ctrlheight = ctrlheight-0.8;
    xppHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5+(pwidth-1)/4 ctrlheight (pwidth-1)/2 0.7], ...
        'string', 'Launch XPPAUT...', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Launch XPP on the selected model and time series', ...
        'Callback','th_leftpanel(''xpp'');');%run xppaut

    theModel = [];
    tsData = [];
    
    r = panel;
    
elseif strcmp(action, 'position')
    
    %called when figure resized. Ensures absolute position is maintained
    set(panel, 'visible', 'off');
    figheight= get(mainFig, 'position');
    figheight = figheight(4);
    pos = myPos;
    pos(2) = figheight-(fromTop+myPos(4));
    set(panel, 'position', pos);
    set(panel, 'visible', 'on');

    %%=========================================================================
elseif strcmp(action, 'save')
    %save settings when program exits
    fp = varargin{1};
    fprintf(fp, '%d\n', get(resHndl, 'Value'));
    
elseif strcmp(action, 'load')

    vals = varargin{1};
    vals = sscanf(vals{1}, '%f')';
    if length(get(resHndl, 'string')) >= vals
        set(resHndl, 'Value', vals);
    end
   
  
    %======================================================================
    
elseif strcmp(action, 'nomodel')
    
    %disable controls
    
   set([ runHndl   delHndl exportHndl runTheoryHndl svdHndl xppHndl ], 'enable', 'off');
    
    
elseif strcmp(action, 'newmodel')
    %called in init procedure and when user selects a model
    
    theModel = varargin{1};

    %empty list of time series mat files
    set(resHndl, 'String', []);
    
    if ~isempty(theModel)
        set([xppHndl runHndl], 'enable', 'on');

        set(resHndl,  'String', theModel.files, 'Value', max(1, length(theModel.files)));
        
        if theModel.hastheory
             set(svdHndl, 'enable', 'on');
        else
             set(svdHndl, 'enable', 'off');
        end
       % if ~isempty(theModel.files)
        %    set(resHndl, 'Value', []);
        %end
        str = ['The current model is ' theModel.name '. '];
        if strcmp(theModel.type, 'signal')
            str = [str 'This is a signal solution type model'];
        else
            str = [str 'This is an oscillator model, meaning that the generated time series will be limit cycles.'];
        end
        th_tippanel('write', {str, 'Click the View buttons in the Model panel at the top to view descriptions of the model parameters and variables'}, 0)
    else
        %no models, 
        set([xppHndl runHndl], 'enable', 'off');
        th_tippanel('write', 'No model selected. To proceed you must first select a model from the Model menu', 2);

    end
    th_leftpanel('changefile_newmodel');
    
elseif strcmp(action, 'changefile') || strcmp(action, 'changefile_newmodel')
    
    %new model or new ts file selected, or a new ts file just created or
    %deleted
    
    message = cell(0); 
    tsData = [];
    hasfiles=false;
    gotfile=false;
    gotdata=false;
    clear_highlight = false;
    message_level = 0;
    
    if nargin > 1
        %new file created, so select the specified file
        fnum = varargin{1};
    else
        %user has just selected a file, or one just deleted in which case dont need to set,or a
        %new model has just been chosen and first file set initally
        fnum = 0;
        if strcmp(action, 'changefile')
            th_tippanel('clear');
        end
    end
    set(mainFig, 'pointer', 'watch');drawnow;
    
    s = get(resHndl, 'String');
    fnum = min(fnum, length(s));
    hasfiles = ~isempty(s);
    
    if hasfiles
        if fnum
            %select the required file
            set(resHndl, 'value', fnum);
            gotfile = true;
        else
            %user has just selected a file if this not empty
             fnum = get(resHndl, 'Value');
             gotfile = ~isempty(fnum);
        end
        if gotfile
            %file selected
            %try to load the time series
            fname = s{fnum};
            CurrentFile = fullfile(theModel.dir, 'results', fname);
            tsData = load(CurrentFile, '-mat');    %file must contain the structure
            if isempty(tsData) %structure not found
                ShowError('Cannot find data in the selected file.');
            elseif length(fieldnames(tsData)) ~= 1 %> 1 variable in file
                tsData = [];
                ShowError('The selected file is not in the correct format.');
            else
                %good structure found in file
                f = fieldnames(tsData);
                tsData = getfield(tsData, f{1});
                tsData.myfile = CurrentFile;     %where this data was read from. Will be written back to same place later
                gotdata = true;
            end
        end
    end
    
    %update controls
    if gotfile
        set([exportHndl delHndl], 'enable', 'on');
    else
        set([exportHndl delHndl], 'enable', 'off');
    end
    if gotdata
        set(runTheoryHndl, 'enable', 'on');
        set(dateHndl, 'string', tsData.date);
        set(solverHndl, 'string', tsData.solver{1});
        set(lengthHndl, 'string', num2str(tsData.sol.x(end)-tsData.sol.x(1)));
        %plot preview
        plot(axHndl, tsData.sol.x, [tsData.sol.y (tsData.force * max(max(tsData.sol.y))) ]);
        xlim(axHndl, [tsData.sol.x(1) tsData.sol.x(end)]);
        set(axHndl, 'xtick', [], 'ytick', []);
        set(mainFig, 'name', ['PeTTSy - ' char(strcat(upper(theModel.orbit_type(1)), theModel.orbit_type(2:end), {' Model '}, theModel.name, {', File '}, fname))]);
    else
        set([exportHndl runTheoryHndl], 'enable', 'off');
        set([dateHndl forceHndl solverHndl lengthHndl], 'string', '');
        set(mainFig, 'name', 'PeTTSy - No Current File');
        plot(axHndl, 0, 0);
        set(axHndl, 'xtick', [], 'ytick', []);
    end
    
    %messaging
    if hasfiles
        if gotfile
            if gotdata
                th_tippanel('write', 'There are several actions you can take with the selected time series file:', 0);
                th_tippanel('write', 'Click Export to export the file contents to the MATLAB workspace', 3);
                if ~isfield(tsData, 'theory')
                    th_tippanel('write', 'Click Derivatives in the Analysis section to calculate derivatives of the variables with respect to parameter, together with IRCs and period derivatives for oscillator models. This will allow you to perform sensitivity analysis', 3);
                else
                    th_tippanel('write', 'Click SVD in the Analysis section to perform sensitivity analysis on the time series', 3);
                end
                th_tippanel('write', 'Select a plot type from the right hand panel to view the file contents', 3);
                th_tippanel('write', 'Alternatively, select a different file or click New... to generate a new time series.', 0);
            else
                th_tippanel('write', {'This time series file is not correctly formatted.', 'Select a different file, or click the New... button on the left hand panel to generate a new file'}, 2);
            end
        else
            th_tippanel('write', 'Select a time series file or click the New... button on the left hand panel to generate a new one', 1);
        end
    else
        th_tippanel('write', 'To proceed you must first generate a time series file',0);
        th_tippanel('write', 'Click the New... button on the left hand panel', 3);
    end

    set(mainFig, 'pointer', 'arrow');drawnow;
    th_rightpanel('changefile', theModel, tsData);
   
    
elseif strcmp(action, 'numfiles')
    
    %returns number of time series files for this model
    
    str = get(resHndl, 'string');
    r = length(str);
    
elseif strcmp(action, 'run')
    
    %new time series

    newtsfilename = [];
    %this gui generates a new file
    newcyclegui('init', theModel);
    if ~isempty(newtsfilename)
        %add to controls
        theModel.files{end+1} = newtsfilename;
        set(resHndl, 'String', theModel.files);
        th_tippanel('clear_highlight');
        th_tippanel('write', 'A new time series file has been created', 1);
        th_leftpanel('changefile', length(theModel.files));
        pettsy('FilesChanged', theModel.files);

        %add name of new file to database of files
        dbfile = fullfile(theModel.dir, 'results', 'results.db');
        if exist(dbfile, 'file') == 2
            fc = load(dbfile, '-mat');
            db = fc.db;
            s.name = newtsfilename;
            s.theory = false;
            db = [db s];
        else
            db.name = newtsfilename;
            db.theory = false;
            db = {db};
        end
        save(dbfile, 'db', '-mat');
        
    end
    
    
elseif strcmp(action, 'runtheory')
    
    %analyse time series
    if isfield(tsData, 'theory')
        r = questdlg('This time series has already undergone analysis. Do you wish to replace the data?','Replace Data','Yes', 'No', 'No');
        if strcmp(r, 'No')
            return;
        end
    end
    newtheory = [];
    %this giu runs theory and saves results
    newtheorygui('init', tsData); 
    if ~isempty(newtheory)
        %was run succesfully
        tsData.theory=newtheory;
        th_tippanel('clear_highlight');
        th_rightpanel('newtheory', theModel, tsData);
        if isfield(newtheory, 'periodic_dgs') ||  isfield(newtheory, 'nonper_dgs')
            %record in database if theory.dgs added to this file
            [pth, fname ext] = fileparts(tsData.myfile);
            dbfile = fullfile(theModel.dir, 'results', 'results.db');
            fc = load(dbfile, '-mat');
            db = fc.db;
            for i = 1:length(db)
                if strcmp(db{i}.name, [fname ext])
                    db{i}.theory = true;
                    %save this so SAGUI knows which files have derrivative data
                    %in them
                    save(dbfile, 'db', '-mat');
                    break;
                end
            end
            theModel.hastheory = true;
            set(svdHndl, 'enable', 'on');
            th_tippanel('write', 'Calculations completed successfully. You can now perform sensitivity analysis on this file by clicking SVD in the Analysis section', 1);
        else
            th_tippanel('write', 'Calculations completed successfully', 1);
        end
    end
    
elseif strcmp(action, 'runsvd')
    
    sagui('init', theModel.name);

elseif strcmp(action, 'del')
    
    %delete selected time series
    idx = get(resHndl, 'value');
    if ~isempty(idx)
        
        answer = questdlg('Are you sure you wish to delete the selected file?','PeTTSy', 'Yes', 'No', 'No');
        
        if strcmp(answer, 'No')
            return;
        end
        
        fnames = get(resHndl, 'string');
        if idx <= length(fnames)
            fname = fnames{idx};
            %delete file
            delete(fullfile(theModel.dir, 'results', fname));
            %remove from database
            hastheory = false;
            dbfile = fullfile(theModel.dir, 'results', 'results.db');
            if exist(dbfile, 'file') == 2
                fc = load(dbfile, '-mat');
                db = fc.db;
                todel = [];
                for i = 1:length(db)
                    if strcmp(db{i}.name, fname)
                        todel = i;
                    elseif db{i}.theory
                        %note if model still has dgs data, even after this
                        %file deleted
                        hastheory = true;
                    end
                end
                db(todel) = [];
                save(dbfile, 'db', '-mat');
            end
            
            %remove from list
            fnames(idx) = [];
            if get(resHndl, 'value') > length(fnames)
                set(resHndl, 'string', fnames, 'value', length(fnames));
            else
                set(resHndl, 'string', fnames);
            end
            theModel.files = fnames;
            theModel.hastheory = hastheory;
            if hastheory
               set(svdHndl, 'enable', 'on');
            else
                set(svdHndl, 'enable', 'off');
            end
            pettsy('FilesChanged', fnames);
            %new file selected, if there is one
            th_leftpanel('changefile');
            
        end
    end
    
elseif strcmp(action, 'export')
    
    %save data to workspsace
    
    if ~isempty(tsData)
        
        exportgui('init', tsData);
        
    else
        uiwait(msgbox('There is nothing to export yet. Please select a time series file, or click New to create a new time series.','Export data'));
    end
    
elseif strcmp(action, 'xpp')
    
    %launch xpp on the current model
    if exist(fullfile(theModel.dir, 'xpp', [theModel.name '.eqn']), 'file') == 2
        uiwait(launchXPP('init', tsData, theModel));
    else
        ShowError(['The file ' theModel.name '.eqn does not exist. You must re-install the model to fix this.' ]);
    end
    
end