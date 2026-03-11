function r = sa_leftpanel(action, varargin)

%Adds the controls to the left panel
global maincol btncol NO_FILE;

persistent panel resHndl tfromHndl ttoHndl parHndl scaleHndl perHndl forceHndl tauHndl taulblHndl selAllHndl clearHndl sdsHndl;
persistent exptsHndl analysisPanel;
persistent theModel;

r = [];

if strcmp(action, 'init')
    NO_FILE = '-none-';
    theModel = [];
    
   panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',varargin{2}, ...
        'HandleVisibility', 'on', ...
        'title', 'Data', ...
        'Parent', varargin{1});
    
    %create controls
    pheight = varargin{2}(4);
    pwidth = varargin{2}(3);

    %pre-selected analyses
    uicontrol('HorizontalAlignment', 'left', 'Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters', 'position', [0.5 pheight-1.3 pwidth/2-1 0.5],'string','Pre-selected analyses','BackgroundColor',maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10); 
    resHndl =uicontrol( ...
        'Style','popup', ...
        'Units','centimeters', ...
        'position',[pwidth/2 pheight-1.3 pwidth/2-0.5 0.5], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', {NO_FILE}, ...
        'call','sa_leftpanel(''changeanalysis'');');
    
    %table of experiments    
    uicontrol('HorizontalAlignment', 'left', 'Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 pheight-2.5 pwidth-1 0.5],'string','Select one or more of the following experiments','BackgroundColor',maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

   exptsHndl = uitable('units', 'centimeters','position', [0.5 pheight-6.2 pwidth-1 3.5], ...
        'columneditable', [true false false false false false], ...
        'columnname', {'', 'Expt', 'Time Series', 'Range', 'Per', 'Variables'}, ...
        'rowname', {}, ...
        'fontunits', 'points', 'fontsize', 10, ...
        'parent', panel, 'CellEditCallback','sa_leftpanel(''changeexpt'');');
    
    set(exptsHndl, 'units', 'pixels')
    tblwidth = get(exptsHndl, 'position');
    tblwidth = tblwidth(3);
    set(exptsHndl, 'columnwidth', {tblwidth*0.075 tblwidth*0.175 tblwidth*0.175 tblwidth*0.175  tblwidth*0.075 tblwidth * 0.3});
    

    %Select which pars from a multi selection list box
    uicontrol('Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 pheight-7.8 pwidth/2-0.5 1],'string','Select the Parameters to include','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    parHndl =uicontrol( ...
        'Style','listbox', ...
        'Units','centimeters', ...
        'position',[pwidth/2 pheight-12.6 pwidth/2-0.5 5.75], ...
        'min', 1, 'max', 10, ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', 'Model parameters', ...
        'call','sagui(''changePars'')');
    
    selAllHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-8.8 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Select All', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_leftpanel(''selAllParams'');');
    
    clearHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0.5 pheight-9.6 pwidth/2-1 0.6], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Clear', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','sa_leftpanel(''clearAllParams'');');
    
%auto select most important?????

    %Scaling options
    uicontrol('Parent',panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 pheight-13.675 pwidth/2-0.5 0.5],'string','Select a scaling mechanism','BackgroundColor', maincol, 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    scaleHndl = uibuttongroup('units', 'centimeters', 'SelectionChangeFcn', 'sagui(''changeScale'')', 'Position', [pwidth/2 pheight-13.75 pwidth/2-0.5 0.75], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    t1=uicontrol('Parent',scaleHndl,'string', '-' ,'Units','normalized','Style','togglebutton', 'position',[0/100 0/100 25/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol, 'Value', 1);
    t2=uicontrol('Parent',scaleHndl,'string', 'p' ,'Units','normalized','Style','togglebutton', 'position',[25/100 0/100 25/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    t3=uicontrol('Parent',scaleHndl,'string', 'yp' ,'Units','normalized','Style','togglebutton', 'position',[50/100 0/100 25/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    t4=uicontrol('Parent',scaleHndl,'string', 'zp' ,'Units','normalized','Style','togglebutton', 'position',[75/100 0/100 25/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    set(scaleHndl, 'UserData', [t1 t2 t3 t4]);

    %calculate sds
    sdsHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[pwidth/2 0.5 pwidth/2-0.5 0.75], ...
        'Interruptible','on', ...
        'Parent',panel, ...
        'string', 'Get SDS', ...
        'HandleVisibility', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Enable', 'off', ...
        'Callback','sagui(''calcsds'');');
    
    r = panel;
 %%=====================================================================   
 elseif strcmp(action, 'getfile')
    %return name of selected analysis file
    s = get(resHndl, 'String');
    n = get(resHndl, 'Value');
    r = s{n};
    if strcmp(r, NO_FILE);
        r = [];
    end
elseif strcmp(action, 'getexpts')
    %returns list of names of experiment files selected
    expts = get(exptsHndl, 'data');
    sel = {};
    for i = 1:size(expts, 1)
       if expts{i,1} 
           sel{end+1} = expts{i, 2};
       end
    end
    r = sel;
 %%====================================================================
elseif strcmp(action, 'getpars')
    %returns list of selected parameters when sds is generated
    r = get(parHndl, 'Value');
    if isempty(r)
        r = 0;
    end

%%=========================================================================
elseif strcmp(action, 'save')
    %save settings when program exits
    fp = varargin{1};
    
    fprintf(fp, '%d\n', get(resHndl, 'Value'));
%     v = get(exptsHndl, 'Value');
%     for i = 1:length(v)
%         fprintf(fp, '%d ', v(i));
%     end
%     fprintf(fp, '\n');
%     fprintf(fp, '%d\n', get(tfromHndl, 'Value'));
%     fprintf(fp, '%d\n', get(ttoHndl, 'Value'));
%     v = get(parHndl, 'Value');
%     for i = 1:length(v)
%         fprintf(fp, '%d ', v(i));
%     end
%     fprintf(fp, '\n');
% 
%     opts = get(scaleHndl, 'UserData');
%     for i =1:length(opts)
%         if get(opts(i), 'Value')
%             fprintf(fp, '%d\n', i);
%             break;
%         end
%     end
  
elseif strcmp(action, 'load')
%     numt = length(get(tfromHndl, 'String'));
%     numpar = length(get(parHndl, 'String'));
%     vals = varargin{1};
%     set(resHndl, 'Value', str2num(vals{1}));
%   
%     set(tfromHndl, 'Value', min(numt, str2num(vals{1})));
%     set(ttoHndl, 'Value', min(numt, str2num(vals{2})));
%     opts = get(scaleHndl, 'UserData');
%     set(opts(str2num(vals{3})), 'Value', 1);
%     selpar = str2num(vals{4});
%     m = find( selpar > numpar);
%     selpar(m) = [];
%     set(parHndl, 'Value', selpar);
%=====================================================================
elseif strcmp(action, 'selAllParams')
    str = get(parHndl, 'String');
    set(parHndl, 'Value', 1:length(str));
    sagui('changePars');
elseif strcmp(action, 'clearAllParams')
    set(parHndl, 'Value', []);
    sagui('changePars');
elseif strcmp(action, 'enableSDS')
    set(sdsHndl, 'Enable', varargin{1});
%=====================================================================
elseif strcmp(action, 'getscale')
    %returns selected scaling when sds is created
    opts = get(scaleHndl, 'UserData');
    for i =1:length(opts)
        if get(opts(i), 'Value')
            r = get(opts(i), 'String');
            return;
        end
    end
%======================================================================
elseif strcmp(action, 'newmodel')
    %called in init procedure and when user selects a model
    theModel = varargin{1};
    
    set(parHndl, 'Value', [], 'String', []);
    set(exptsHndl, 'data', {}, 'Userdata', []);
    set(resHndl, 'String', {NO_FILE});

    if ~isempty(theModel)
        %fill in list of experiments
        exptfiles = dir([theModel.dir, '/results/*.expt']);
        for j = 1:length(exptfiles)
            %read file to get its details
            fid_tmp = fopen([theModel.dir, '/results/' exptfiles(j).name], 'r');
            tmp_scan = textscan(fid_tmp, '%[^\n]');
            fclose(fid_tmp);
            cvs = tmp_scan{1};
            datafile = char(cvs(1));                     
            tvals = sscanf(cvs{2}, '%f %f %d %d');
            periodic = str2double(char(cvs(3)));
            vars = cell(0);
            for v = 4:length(cvs)
                if strcmp(cvs{v}, '--')
                   break;
                end
               vars{end+1} = sscanf(cvs{v}, '%f')';
            end
            if exist([theModel.dir, '/results/' datafile], 'file') == 2
                sa_leftpanel('addexptfile', getFileName(exptfiles(j).name), getFileName(datafile), tvals, periodic, vars);
            else
                %user has previously deleted the ts file this is based on
                delete([theModel.dir, '/results/' exptfiles(j).name]);
            end
            
        end
      
        %fill in model paramters
        plist = cell(theModel.pnum, 1);
        for i = 1:theModel.pnum
            plist{i} = sprintf('%s, %s', theModel.parn{i}, theModel.parnames{i});
        end
        %add dawn and dusk values
        for f = 1:length(theModel.force_type)
           plist{end+1} = sprintf('%s', [theModel.force_type(f).name ' dawn']); 
           plist{end+1} = sprintf('%s', [theModel.force_type(f).name ' dusk']); 
        end
        set(parHndl, 'String', plist);

        %fill in analysis files
        %these just pre-select expts, time range, scaling and parameters,
        %so are not neccesary to run sds as all these can be set by hand.
        files = dir([theModel.dir, '/results/*.an']);
        temp = cell(0);
        for j = 1:length(files)
            temp = [temp; {files(j).name(1:end-3)}];
        end
        if isempty(temp)
            temp = {NO_FILE};
        end
        set(resHndl, 'String', temp);
  %must make sure that an expt file listed in an analysis file exists
        
        %if no experiments, can't run sds
        if isempty(exptfiles)
            %no files
            set([resHndl parHndl selAllHndl clearHndl get(scaleHndl, 'UserData')], 'Enable', 'off');
         
        else
            set([resHndl  parHndl selAllHndl clearHndl get(scaleHndl, 'UserData')], 'Enable', 'on');          
        end
        if nargin > 2
            sa_leftpanel('changeanalysis',varargin{2});
        else
            sa_leftpanel('changeanalysis', 1);
        end
        
        if isempty(exptfiles)
            %can't do anything until an expt file created, so prompt user
            newexptgui('init', theModel);
        end
   else
        %no models, should never happen
        set([sdsHndl resHndl parHndl selAllHndl clearHndl get(scaleHndl, 'UserData')], 'Enable', 'off');      
    end
    
elseif strcmp(action, 'changeanalysis')
    %called when the model or analysis file changes
    %this can be at startup, or when the user changes them
    str = get(resHndl, 'String');
    if ~iscell(str)
        str = {str};
    end

    if nargin > 1
        %select a file at startup or when model changes
        fi = varargin{1};
        if ischar(fi)
            %called from theorygui with a file name to select, so find its
            %index
            fi = find(strcmp(str, fi));
            if isempty(fi)
                %missing file
                fi = 1;
            end
        end
        fi = min([fi length(str)]);
        set(resHndl, 'Value', fi);
    else
        %user has selected a file
        fi = get(resHndl, 'Value');
    end
    fname = str{fi};
    if strcmp(fname, NO_FILE);
        fname = [];
 %       tspan = [];
    else
        %valid file selected so fill in its settings
        fid_tmp = fopen([theModel.dir, '/results/' fname '.an'], 'r');
        tmp_scan = textscan(fid_tmp, '%[^\n]');
        fclose(fid_tmp);
        cvs = tmp_scan{1};
        %which expts to select
        expts = cvs{1};
        %get list from an file
        toselect = cell(0);
        [expt, remain] = strtok(expts, ';');
        toselect = [toselect; expt];
        while ~isempty(remain)
            [expt, remain] = strtok(remain, ';');
            toselect = [toselect; expt];          
        end
        %find these in list of expts
        selectIdx = [];
        expts = get(exptsHndl, 'data');
        for i = 1:size(expts,1)
           exptname = expts{i, 2};
           found = find(strcmp(toselect, exptname));
           if found
               expts{i,1} = true;
           else
               expts{i,1} = false;
           end
        end
        set(exptsHndl, 'data', expts);
        %parameters
        pars = sscanf(cvs{2}, '%f')';
        if ~pars
            pars = [];
        end
        set(parHndl, 'Value', pars);
        %scale
        sc = str2double(cvs{3});
        opt = get(scaleHndl, 'Userdata');
        set(opt(sc), 'Value', 1);
    end
    sa_leftpanel('changeexpt');
   
elseif strcmp(action, 'changeexpt')
    %called when selection of expts list changes
    %can be changed by user, or when analysis file changes
   
    %find which files are selected
    td = get(exptsHndl, 'data');
    if ~isempty(td)
        td = td(:,1);
    end
   
    if any(cell2mat(td))
         set(sdsHndl, 'enable', 'on');
    else
        %no files selected
        set(sdsHndl, 'enable', 'off');
    end
    
elseif strcmp(action, 'saveanalysis')
    
    %save controls in a new analysis file
    
    %first get file name
    fname = inputdlg('Select a name for the new analysis', 'New Anaysis');
    fname = char(fname);
    if ~isempty(fname)
        %check its a legal file name
        for i = 1:length(fname)
            if ~isstrprop(fname(i), 'alphanum') && ~strcmp('_', fname(i)) && ~strcmp('.', fname(i))
                ShowError('Please enter a file name consisting of alphanumeric characters, ''-'' or ''.''');
                return;
            end
        end
             
        if length(fname) > 3
            if ~strcmp('.an', fname(end-2:end))
                fname = [fname '.an'];
            end
        else
            fname = [fname '.an'];
        end
        shortname = fname;
        fname = fullfile(theModel.dir, 'results', fname);
      
        %check it doesn't exist
        if exist(fname, 'file') == 2
            response = questdlg('A file with this name already exists. Do you wish to replace this file?.','File already exists', 'OK', 'Cancel', 'Cancel') ;
            if strcmp(response, 'OK')
               delete(fname);
            else
                return;
            end
        end
        %experiments
        expts = get(exptsHndl, 'data');
        %parameters
        params = sa_leftpanel('getpars');
        %scaling
        sc = 1;
        opts = get(scaleHndl, 'UserData');
        for i =1:length(opts)
            if get(opts(i), 'Value')
                sc = i;
                break;
            end
        end
        %write file
        fid = fopen(fname, 'wt');
        if fid > 0
            for i = 1:size(expts, 1)
                if expts{i, 1}
                    fprintf(fid, '%s;', expts{i, 2});
                end
            end
            
            fprintf(fid, ';\n');
     
            for i = 1:length(params)
                fprintf(fid, '%d ', params(i));
            end
            fprintf(fid, '\n%d\n', sc);
            fclose(fid);
            
            %select new file
            shortname = getFileName(shortname);
            
            str = get(resHndl, 'String');
            if length(str) == 1 && strcmp(str{1}, NO_FILE)
                str = {shortname};
                found = 1;
            else 
                %add if not already present
                found = 0;
                for i = 1:length(str)
                    if strcmp(str{i}, shortname)
                        found = i;
                        break;
                    end
                end
                if ~found
                    str = [str; shortname];
                    found = length(str);
                end
            end
            set(resHndl, 'String', str, 'Value', found);
        else
            ShowError('Error creating the new file.','An error has occurred', true); 
        end
    end
    
elseif strcmp(action, 'addexptfile')
   
   exptfilename = varargin{1};
   datafilename = varargin{2};
   tvals = varargin{3};
   periodic = varargin{4};
   vars = varargin{5};
   
    %convert var indices to names
    for i = 1:length(vars)
        if isscalar(vars{i})
            vars{i} = theModel.vnames{vars{i}};
        else
            v = vars{i};
            tmp = [];
            for k = 1:length(v)
                tmp = [tmp theModel.vnames{v(k)} '+'];
            end
            vars{i} = tmp(1:end-1);
        end
    end
    %now create singleline listing al variables
    varline = [];
    for i = 1:length(vars)
        varline = [varline vars{i} ','];
    end
    varline = varline(1:end-1);

    sTime = sprintf('%-6.1f %-6.1f', tvals(1), tvals(2));
    if periodic
        sPer = 'Y';
    else
        sPer = 'N';
    end
    
    sVar = varline(1:end-1);

    tbldata = get(exptsHndl, 'data');
    newrow = {false, exptfilename, datafilename, sTime, sPer, varline};
    if isempty(tbldata)
        tbldata = newrow;
    else
        tbldata = [tbldata; newrow];
    end
    
    set(exptsHndl, 'data', tbldata);
    set([resHndl  parHndl selAllHndl clearHndl get(scaleHndl, 'UserData')], 'Enable', 'on');  
end


%==================================================================

function name = getFileName(fname)

%removes extension from fname

pos = strfind(fname, '.');
pos = pos(end)-1;
name = fname(1:pos);



%could save controls fo reach model so can be retored when switching back
%from anothe rkodel

%table of data files, showing force for each etc...