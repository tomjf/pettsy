function r = exportParametersPanel(varargin)


persistent myDir panel tblHndl model  pFileHndl
 
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
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Model parameters' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

     uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['The model parameters will be converted to SBML parameters.'], ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2.5 panelwidth-1 1.2],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string' ,'Select a file to provide their values:', 'units','centimeters','Style','text', ...
       'position',[0.5 panelheight-3 (panelwidth-1)/2 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    pFileHndl=uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', {'-none-'} , 'value', 1, 'Units','centimeters','Style','popup', ...
       'position',[panelwidth/2 panelheight-2.9 4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['You can edit the description and value columns below.'], ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-4 panelwidth-1 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   
    
   tblpos = [0.5 0.5 panelwidth-1 panelheight-4.5];
   tblwidth = tblpos(3);
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
  tblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos, ...
       'ColumnName', {'Name', 'Description', 'Value'}, 'ColumnWidth', {tblwidth*0.2 tblwidth*0.5 tblwidth*0.2}, 'ColumnEditable', [false true true]);

   
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        model = varargin{2};
       
        tbldata = cell(length(model.parn), 3);
        for s = 1:length(model.parn)
           
           tbldata{s, 1} = model.parn{s}; 
           tbldata{s, 2} = model.parnames{s}; 
           tbldata{s, 3} = model.parv(s); 
        end
       
        set(tblHndl, 'data', tbldata);
        
        pfiles = {'-none-'};
        f = dir(fullfile(model.dir, '*.pv'));
      
        for i = 1:length(f)
            pfiles{end+1} = f(i).name;
        end

       
        set(pFileHndl, 'string', pfiles);
        set(pFileHndl, 'callback', {@SelPFile, tblHndl, model});
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 

elseif strcmp(action, 'gonext')

    %called when user click Next.
   r = [];
    
    tbldata = get(tblHndl, 'data');
    
    %record user edits, 
    
    for p = 1:size(tbldata, 1)
        
       model.parnames{p} = fixXMLString(tbldata{p,2});
 
        if isnan(tbldata{p,3}) || ~isnumeric(tbldata{p,3}) || isempty(tbldata{p,3});
            ShowError(['Row ' num2str(p) ', please enter a numeric value.']);
            return;
        end
        model.parv(p) = tbldata{p,3};
       
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

%============================================
function SelPFile(hFile, event, hTbl, model)

%user has chosen an initial cond file


fname = get(hFile, 'String');
idx = get(hFile, 'value');
fname = fname{idx};

tblData = get(hTbl, 'data'); 

if strcmp(fname, '-none-')
    %no p file, so fill in default  values
   
    tblData(:,3) = num2cell(model.parv);
  
else
    %read selected file
    fid_tmp = fopen(fullfile(model.dir, fname), 'r');
    tmp_scan = textscan(fid_tmp, '%f');
    fclose(fid_tmp);
    pvals = tmp_scan{1};
    if length(pvals) ~= size(tblData, 1)
        ShowError('The selected parameters file is invalid.');
        return; 
    end  
    
    tblData(:,3) = num2cell(pvals);
end

set(hTbl, 'data', tblData);
    







