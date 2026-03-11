function newexptgui(action, varargin)

persistent newExptFig fileHndl OKHndl cancelHndl perOpt model perdgs nonperdgs
persistent tfromHndl ttoHndl varTbl opTbl nameHndl tpHndl

if strcmp(action,'init')
    
    %draw figure
    model = varargin{1};
    
    newExptFig=figure('resize', 'off', 'menubar', 'none' ,'Name',[model.name ' - New Experiment'] ,'NumberTitle','off','Visible','off', 'windowstyle', 'modal');
    
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    
    figwidth = 14;
    figheight = 12;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    
    pos = [figleft figbottom figwidth figheight];
    set(newExptFig, 'Units', 'centimeters', 'Position', pos);
    maincol = get(newExptFig, 'Color');
    
    frmPos=[0.1 0.9 figwidth-0.2 figheight-1];
    
    pheight = frmPos(4);
    pwidth = frmPos(3);
  
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',frmPos, ...
        'HandleVisibility', 'on', ...
        'visible', 'on', ...
        'Parent', newExptFig);
    
    %OK and Cancel buttons
    
    OKHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-4.1 0.1 2 0.7], ...
        'Parent',newExptFig, ...
        'string', 'OK', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','newexptgui(''ok'');');
    
    cancelHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.1 0.1 2 0.7], ...
        'Parent',newExptFig, ...
        'string', 'Cancel', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','newexptgui(''cancel'');');
    
    %select a time series file
    str = model.files;
    
    uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.1 pwidth/2-0.5 0.5],'string','Select a time series file:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    fileHndl =uicontrol( ...
        'Style','popup', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[pwidth/2 pheight-1 pwidth/2-0.5 0.5], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', str, ...
        'BackgroundColor', 'w', ...
        'Callback','newexptgui(''changefile'');');
 
    %info about file table

    %periodic or non periodic dgs
    
    perOpt = uibuttongroup('Units','centimeters', 'Position', [0.5 pheight-2.5 pwidth-1 1], 'Parent',panel, 'Backgroundcolor',maincol, 'bordertype', 'none' );
    perdgs=uicontrol('HorizontalAlignment', 'right', 'Parent',perOpt,'string', 'Use periodic dgs' ,'Units','normalized','Style','radiobutton', 'position',[0/100 0/100 50/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    nonperdgs=uicontrol('HorizontalAlignment', 'right','Parent',perOpt,'string', 'Use Non-periodic dgs' ,'Units','normalized','Style','radiobutton', 'position',[50/100 0/100 50/100 1],'HandleVisibility', 'on','Visible', 'on','FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    
    if strcmp(model.type, 'oscillator')
        set([perdgs nonperdgs], 'enable', 'on');
    else
        set(nonperdgs, 'Value', 1);
        set([perdgs nonperdgs], 'enable', 'off');
    end
    
    
    %time span from file
     uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3.25 pwidth/2-0.2 0.5],'string','Select a time range', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
     uicontrol( 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3.75 1.5 0.5],'string','From:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
     tfromHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[2 pheight-3.75 1.5 0.5],'string','from', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
     uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[3.5 pheight-3.75 1.5 0.5],'string','to:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
     ttoHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[4.5 pheight-3.75 1.5 0.5],'string','to', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);


    %timepoint pruning
    tpHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[pwidth/2 pheight-3.8 1.5 0.6], ...
        'Parent',panel, ...
        'string', 'Edit...', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','newexptgui(''tpp'');');
    
    %How to combine variables
    uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-4.75 pwidth-1 0.5],'string','Map the time series variables to the outputs to be analysed:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    varTbl = uitable('units', 'centimeters','position', [0.5 pheight-9 pwidth/2-0.75 4], ...
        'columneditable', [false true], ...
        'columnname', {'Variable', 'Output index'}, ...
        'fontunits', 'points', 'fontsize', 10, ...
        'parent', panel);
   
    opTbl = uitable('units', 'centimeters', 'position', [pwidth/2+0.25 pheight-9 pwidth/2-0.75 4], ...
        'columnname', {'Outputs'}, ...
        'fontunits', 'points', 'fontsize', 10, ...
        'parent', panel);
    set([opTbl varTbl], 'units', 'pixels')
    set(varTbl, 'CellEditCallback', {@varchange, opTbl});
 

    %name for new expt
    uicontrol('FontWeight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-10 pwidth-1 0.5],'string','Enter a name for the new experiment:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    nameHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[0.5 pheight-10.6 pwidth/2-0.5 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', [], ...
        'BackgroundColor', 'w');
    
    if ~isempty(model.files)
        newexptgui('changefile');
        set(newExptFig, 'visible', 'on');
        uiwait(newExptFig);
    else
       ShowError('You must first create a time series file for this model and perform the theoretical analysis.');
       delete(gcf);
    end
    
elseif strcmp(action,'cancel')
    
    delete(gcf);
    
elseif strcmp(action,'ok')
    
    %get the selected results file
    files = get(fileHndl, 'string');
    fname = files(get(fileHndl, 'value'));
  
    %per/non-per?
    per = get(perdgs, 'Value');
    
    %time range
    tp = get(newExptFig, 'Userdata');
    timeVals = cell2mat(tp(:,1));
   tfrom_idx = find(timeVals, 1, 'first');
   tto_idx = find(timeVals , 1, 'last');
   tfrom = str2double(tp{tfrom_idx, 2});
   tto = str2double(tp{tto_idx, 2});
 
    %variables
 
    vars = get(opTbl, 'Userdata');
    if isempty(vars)
        ShowError('You must select at least one variable to output!');
        return;
    end
    
    %expt file name
    exptname = get(nameHndl, 'String');
    if isempty(exptname)
        ShowError('Please enter a file name consisting of alphanumeric characters, ''-'' or ''.''');
        uicontrol(nameHndl)
        return;
    end
    
    %check legal file name and doesn't already exist
    for i = 1:length(exptname)
        if ~isstrprop(exptname(i), 'alphanum') && ~strcmp('_', exptname(i)) && ~strcmp('.', exptname(i))
            ShowError('Please enter a file name consisting of alphanumeric characters, ''-'' or ''.''');
            uicontrol(nameHndl);
            return;
        end
    end
    if length(exptname) < 5
        exptname = [exptname '.expt'];
    elseif ~strcmp(exptname(end-4:end), '.expt')
         exptname = [exptname '.expt'];   
    end
    if exist(fullfile(model.dir, 'results', exptname), 'file') == 2
        ShowError(['The experiment file ' exptname ' already exists. Please choose another name.']);
        uicontrol(nameHndl);
        return;
    end
    
    %ok so make new file and close form
    fid = fopen(fullfile(model.dir, 'results', exptname), 'wt');
    
    if fid < 0
        ShowError(['Error creating the new file ' exptname], true);
    else
        
        fprintf(fid, '%s\n', char(fname));
        fprintf(fid, '%f %f %d %d\n', tfrom, tto, tfrom_idx, tto_idx);
        fprintf(fid, '%d\n', per);
        for i = 1:length(vars)
            if ~isempty(vars{i})
                for j = 1:length(vars{i})
                    fprintf(fid, '%d ', vars{i}(j));
                end
                fprintf(fid, '\n');
            end
        end
        fprintf(fid, '--\n');
        for i = 1:length(timeVals)
           fprintf(fid, '%d\n', timeVals(i)); 
        end
        
        fclose(fid);
        sa_leftpanel('addexptfile', exptname(1:end-5), char(fname), [tfrom, tto, tfrom_idx, tto_idx], per, vars);
   
        delete(gcf);
    end
    
 
elseif strcmp(action,'changefile')
    
    %read time series to see if it is forced and howlong it is
    fname =  get(fileHndl, 'string');
    fname = fname{get(fileHndl, 'Value')};
    fname = fullfile(model.dir, 'results', fname);
    clear thetheoryresults
    set(newExptFig, 'pointer', 'watch');
    load(fname, '-mat'); 
    set(newExptFig, 'pointer', 'arrow');

    
    %update peridic options
    try  
        if strcmp(model.type, 'oscillator')
            if thetheoryresults.forced
                set(perdgs, 'value', 1);
                set([perdgs nonperdgs], 'enable', 'off')
            else
                %unforced oscillator so can be per or non-per
                set([perdgs nonperdgs], 'enable', 'on')
            end
        end
        
        %set default time, whole time series
        str = cell(length(thetheoryresults.sol.x), 2);
        for i = 1:length(thetheoryresults.sol.x)
            str{i,1} = true;
            str{i,2} =  sprintf('%6.2f', thetheoryresults.sol.x(i));
        end
        set(tfromHndl, 'string', str{1,2});
        set(ttoHndl, 'string', str{end,2});
        set(newExptFig, 'userdata', str);
        
        %variables
        data = cell(thetheoryresults.dim, 2);
        idxs = cell(1,thetheoryresults.dim);
        ud = cell(1,thetheoryresults.dim);
        for i = 1:thetheoryresults.dim
            data{i, 1} = thetheoryresults.vnames{i};
            data{i, 2} = i;
            idxs{i} = num2str(i);
            ud{i} = i;
        end
        idxs = ['0', idxs];
        
        tblwidth = get(varTbl, 'position');
        tblwidth = tblwidth(3);
        if size(data, 1) > 6
            tblwidth = tblwidth*0.9;
        end
        set(varTbl, 'data', data, 'columnformat', {'char' idxs}, 'columnwidth', {tblwidth*0.46 tblwidth*0.35});
        set(opTbl, 'data', data(:,1), 'Userdata', ud,'columnwidth', {tblwidth*0.81});
        
        clear thetheoryresults
        
    catch
        ShowError('This file does not contain the theoretical analysis.');
        set(OKHndl, 'enable', 'off');
        return;
    end
     set(OKHndl, 'enable', 'on');
  
elseif strcmp(action,'tpp')
    
    %launch timepoint pruning form, passing it the current control values
    fname =  get(fileHndl, 'string');
    fname = fname{get(fileHndl, 'Value')};
    fname = fullfile(model.dir, 'results', fname);
    vars = get(opTbl, 'Userdata');
    to_remove = [];
    for i = 1:length(vars)
        if isempty(vars{i})
            to_remove = [to_remove i ];
        end
    end
    vars(to_remove) = [];
    uiwait(tppgui('init', vars, model.vnames, newExptFig, fname));
    
    tp = get(newExptFig, 'Userdata');
    tv = cell2mat(tp(:,1));
    set(tfromHndl, 'string', tp{find(tv, 1, 'first'), 2});
    set(ttoHndl, 'string', tp{find(tv, 1, 'last'), 2});
    drawnow;
    
end

%========================================================

function varchange(vartable, eventdata, optable)

%update optable
data = get(vartable, 'data');
opnames = cell(size(data, 1), 1);
opidx = cell(size(data, 1), 1);
varnames = cell(size(data, 1), 1);
varidx = zeros(size(data, 1), 1);

for i = 1:size(data, 1)
    varidx(i) = data{i, 2};
    varnames{i} = data{i,1};
end

for i = 1:length(opidx)
    opidx{i} = find(varidx == i);
    for j = 1:length(opidx{i})
        opnames{i} = [opnames{i} varnames{opidx{i}(j)}];
        if j < length(opidx{i})
            opnames{i} = [opnames{i} '+'];
        end
    end
end
%eliminate blank rows
toremove = [];
for i = 1:length(opidx)
    if isempty(opidx{i})
        toremove = [toremove i];
    end
end
%opidx(toremove) = [];
%opnames(toremove) = [];
tblwidth = get(optable, 'position');
tblwidth = tblwidth(3);
if size(opnames, 1) > 6
    tblwidth = tblwidth*0.9;
end
set(optable, 'data', opnames, 'Userdata', opidx, 'columnwidth', {tblwidth*0.81});

%sort, update idx > numrows?


%check what the min number of timepoints is, depends onnum vars an ps
%selected t *v must be >= p