function newtheorygui(action, varargin)

%call a function that provides feedback to this form
%displays a message and a progress bar

persistent optionsselected allow_reject_Xst;
persistent thelimitcycle newTheoryFig barHndl barInc txtHndl tm num_div interval maxWidth closeHndl runHndl paraHndl conditionHndl optionsPanel optionboxes

global PAR_ENV workersHndl 

if strcmp(action, 'init')

    thelimitcycle = varargin{1};
    %create figure,
    newTheoryFig=figure('menubar', 'none', 'resize', 'off', 'Units', 'centimeters','Name','New Analysis' ,'NumberTitle','off','Visible','on');
%'WindowStyle', 'modal', 
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    figwidth = 18;
    figheight = 12;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    set(newTheoryFig, 'Units', 'centimeters', 'Position', [figleft figbottom figwidth figheight]);

    % The panel
    panelheight = figheight-2.2;
    panelwidth = figwidth-0.2;
    panelHndl = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', get(newTheoryFig, 'Color'), ...
        'Units','centimeters', ...
        'Position',[0.1 2.1  panelwidth panelheight], ...
        'HandleVisibility', 'on', ...
        'Parent', newTheoryFig, 'Visible', 'on');
    
    %list box that will contain text
    pos = [0.4 1 panelwidth-0.8 panelheight-1.5];
     txtHndl=uicontrol( ...
                            'Style','listbox', ...
                            'Units','centimeters', ...
                            'position',pos, ...
                            'min', 1, 'max', 1, ...
                            'Parent',panelHndl, ...
                            'string', {' '}, ...
                            'value', [], ...
                            'min', 1, 'max', 10, ...
                            'enable', 'inactive', ...
                            'visible', 'off', ...
                            'FontUnits', 'points', 'FontSize', 10);
      
     %intially overlay with panel that will hold java tree contorl
     optionsPanel = uipanel('BorderType', 'etchedin', ...
        'Units','centimeters', ...
        'Position',pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'on', ...
        'Parent', panelHndl);
    
    %add field list
    
    optionboxes = zeros(1,8); %0 placeholder indicates a missing option not available for that time series
    
    uicontrol('HorizontalAlignment', 'left','Parent',optionsPanel ,'Style', 'text','Units','centimeters','position',[0.5  panelheight-2.5 panelwidth-2, 0.5],'string','Select the outputs you require:','BackgroundColor', get(optionsPanel, 'BackgroundColor'), 'ForegroundColor', 'k',  'FontUnits', 'points', 'FontSize', 10);
    %Userdata field holds handles of boxes that must also be set when current one changed
    %plus value to set boxes to
    %Tag is input param passed to theory if the box selected
    
    ctrlheight = 0.75;
    ctrlbottom = panelheight-2.5-ctrlheight;
   
    if strcmp(thelimitcycle.orbit_type, 'oscillator')
       
        
        optionboxes(1) = uicontrol( ...
            'Style','checkbox', 'Parent',optionsPanel, ...
            'Units','centimeters', 'position',[1 ctrlbottom  panelwidth-2, ctrlheight], ...
            'String', 'dy0/dpar in standard coordinate system', ...
            'Tag', 'getdy0dpar');
          ctrlbottom = ctrlbottom-ctrlheight;
        optionboxes(2) = uicontrol( ... %dxdm
                'Style','checkbox', 'Parent',optionsPanel, ...
                'Units','centimeters', 'position',[1 ctrlbottom panelwidth-2, ctrlheight], ...
                'String', 'Curves under the integral for dy0/dpar (dxdm)', ...
                'Userdata', {'getirc', 0}, ...
                'Tag', 'getdxdm');
          ctrlbottom = ctrlbottom-ctrlheight;
        if ~thelimitcycle.forced
            %unforced oscillator
   
            optionboxes(3) = uicontrol( ...
                'Style','checkbox', 'Parent',optionsPanel, ...
                'Units','centimeters', 'position',[1 ctrlbottom panelwidth-2.5, ctrlheight], ...
                'String', 'Infinitesimal response curves (irc)', ...
                'Userdata', {'getdxdm', 1}, ...
                'Tag', 'getirc');
              ctrlbottom = ctrlbottom-ctrlheight;
               optionboxes(4) = uicontrol( ...
                'Style','checkbox', 'Parent',optionsPanel, ...
                'Units','centimeters', 'position',[1 ctrlbottom panelwidth-2, ctrlheight], ...
                'String', 'Derivative of the period with respect to parameter (dperdpar)', ...
                'Tag', 'getdperdpar');
              ctrlbottom = ctrlbottom-ctrlheight;
        else
            %forced oscillator
             optionboxes(3) = uicontrol( ...
                'Style','checkbox', 'Parent',optionsPanel, ...
                'Units','centimeters', 'position',[1 ctrlbottom panelwidth-2, ctrlheight], ...
                'String', 'Phase infinitesimal response curves (ircphi)', ...
                'Tag', 'getirc');
              ctrlbottom = ctrlbottom-ctrlheight;
        end
    end
    optionboxes(5) = uicontrol( ...
        'Style','checkbox', 'Parent',optionsPanel, ...
        'Units','centimeters', 'position',[1 ctrlbottom panelwidth-2, ctrlheight], ...
        'String', 'Derivatives of the time series with respect to parameter (dgs)', ...
        'Userdata', {'getdphasedpar', 'getdypkdpar' 0}, ...
        'Tag', 'getdgsoutput');
    uicontrol('HorizontalAlignment', 'left','Parent',optionsPanel ,'Style', 'text','Units','centimeters','position',[1.5  ctrlbottom-ctrlheight panelwidth-3, ctrlheight],'string','required for sensitivity analysis','BackgroundColor', get(optionsPanel, 'BackgroundColor'), 'ForegroundColor', 'k',  'FontUnits', 'points', 'FontSize', 10, 'FontAngle', 'italic');

      ctrlbottom = ctrlbottom-2*ctrlheight;
    
    optionboxes(6) = uicontrol( ...
        'Style','checkbox', 'Parent',optionsPanel, ...
        'Units','centimeters', 'position',[1 ctrlbottom panelwidth-2.5, ctrlheight], ...
        'String', 'Derivatives of variable peak and trough times with respect to parameter (d[pk|tr]dpar)', ...
        'Userdata', {'getdgsoutput', 1}, ...
        'Tag', 'getdphasedpar');
      ctrlbottom = ctrlbottom-ctrlheight;
    
    optionboxes(7) = uicontrol( ...
        'Style','checkbox', 'Parent',optionsPanel, ...
        'Units','centimeters', 'position',[1 ctrlbottom panelwidth-2.5, ctrlheight], ...
        'String', 'Derivatives of variables with respect to parameter at peak and trough times (dy[pk|tr])', ...
        'Userdata', {'getdgsoutput', 1}, ...
        'Tag', 'getdypkdpar');
    
    if isempty(optionsselected)
        optionsselected = ones(1,length(optionboxes));
    end

    for i = 1:length(optionboxes)
        if optionboxes(i) > 0
            set(optionboxes(i), 'Value', optionsselected(i), 'min', 0, 'max', 1); 
            set(optionboxes(i), 'BackgroundColor', get(optionsPanel, 'BackgroundColor'), 'FontUnits', 'points', 'FontSize', 10, 'callback', @optChange); 
        end
    end
  
    %progress bar
    barHndl = uicontrol('style', 'text', 'Units','centimeters', 'Position', [0.4 0.2 0.1 0.6],'Parent',panelHndl, 'BackgroundColor', 'r', 'ForegroundColor', 'r' );
    maxWidth = figwidth-1;
    
    %option to allow user to reject Xst if condition number too large
    if strcmp(thelimitcycle.orbit_type, 'oscillator')
        conditionHndl = uicontrol( ...
            'Style','checkbox', ...
            'Units','centimeters', ...
            'position',[0.5 1 figwidth-1, 1], ...
            'HandleVisibility', 'on', ...
            'Parent',newTheoryFig, ...
            'String', 'Allow user to reject and recalculate Xst matrices', ...
            'Value', 1, ...
            'min', 0, 'max', 1, ...
            'BackgroundColor', get(newTheoryFig, 'Color'), ...
            'FontUnits', 'points', 'FontSize', 10);
        if ~isempty(allow_reject_Xst)
           set( conditionHndl, 'value', allow_reject_Xst) 
        end
    end
   
    %parallel env
    paraHndl = [];workersHndl=[];
    if  strcmp(thelimitcycle.orbit_type, 'oscillator')
        
        try
            all_profiles = parallel.clusterProfiles;
            pcs = [{'none'}, all_profiles];
            paraHndl = uicontrol( ...
                'Style','popup', ...
                'Units','centimeters', ...
                'position',[3 0.2 2.5 0.6], ...
                'HandleVisibility', 'on', ...
                'Parent',newTheoryFig, ...
                'String', pcs, ...
                'Value', 1, ...
                'callback', 'newtheorygui(''parchange'');', ...
                'FontUnits', 'points', 'FontSize', 10);
            uicontrol('HorizontalAlignment', 'left','Parent',newTheoryFig ,'Style', 'text','Units','centimeters','position',[0.5 0.15 2.5 0.6],'string','Parallel config','BackgroundColor', get(newTheoryFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
            uicontrol('HorizontalAlignment', 'left','Parent',newTheoryFig ,'Style', 'text','Units','centimeters','position',[5.75 0.15 1.5 0.6],'string','Workers','BackgroundColor', get(newTheoryFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
            
            maxw = max([thelimitcycle.dim length(thelimitcycle.par)]);
            workersHndl = uicontrol( ...
                'Style','popup', ...
                'Units','centimeters', ...
                'position',[7.25 0.2 2 0.6], ...
                'HandleVisibility', 'on', ...
                'Parent',newTheoryFig, ...
                'String', num2cell(1:maxw), ...
                'Value', 1, ...
                'enable', 'off', ...
                'FontUnits', 'points', 'FontSize', 10);
        catch err
            %ignore error, toolbox not installed or matlab older than
            %R2013b
        end
    end
    
    %close button
     closeHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.1 0.1 2 0.7], ...
        'Interruptible','on', ...
        'string', 'Cancel', ...
        'HandleVisibility', 'on', ...
        'Parent',newTheoryFig, ...
        'FontUnits', 'points', 'FontSize',10, ...
        'enable', 'on', ...
        'Callback','delete(gcf);'); 
    
    %run button
    runHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-4.1 0.1 2 0.7], ...
        'Interruptible','on', ...
        'string', 'Run', ...
        'HandleVisibility', 'on', ...
        'Parent',newTheoryFig, ...
        'FontUnits', 'points', 'FontSize',10, ...
        'enable', 'on', ...
        'Callback','newtheorygui(''start'');'); 
    
    uiwait(newTheoryFig);
    
  
elseif strcmp(action, 'start')
    
    %launch theory analysis
    
    outputs = {@newtheorygui};
    if strcmp(thelimitcycle.orbit_type, 'oscillator')
        if get(conditionHndl, 'value')
            outputs{2} = 'allow_reject_Xst';
        end
        allow_reject_Xst = get(conditionHndl, 'value');
    end
    
    %required outputs
    optionsselected = zeros(1,length(optionboxes));
    for i = 1:length(optionboxes)
        if optionboxes(i) > 0
            if(get(optionboxes(i), 'value'))
                outputs{end+1} = get(optionboxes(i), 'Tag');
                optionsselected(i) = 1;
            end
        end
    end
    if ~any(optionsselected)
        ShowError('You must select at least one output field');
        return;
        
    end
     
    set(optionsPanel, 'visible', 'off');
    set(txtHndl, 'visible', 'on');
    %pointer
    set(newTheoryFig, 'pointer', 'watch');
    set([closeHndl runHndl], 'enable', 'off');
    if strcmp(thelimitcycle.orbit_type, 'oscillator')
         set(conditionHndl, 'enable', 'off');
    end
    if ~isempty( paraHndl)
       set([paraHndl workersHndl] , 'enable', 'off');
    end
    
    %check for a parallel config selected
    
    PAR_ENV = '';
    if ~isempty(paraHndl)
        str = get(paraHndl, 'String');
        idx = get(paraHndl, 'Value');
        if idx > 1
            PAR_ENV = str(idx);%gets name of selected env
        end
    end
    
    barInc = 1; %number of large increments to complete the bar. 
                            %This should be the number of times
                            %progressform('progress', ...) is called 
    
    if strcmp(thelimitcycle.orbit_type, 'oscillator')
        if isempty(PAR_ENV)
            barInc = barInc +8;
        else
            barInc = barInc +4;
        end
        irc_selected = get(optionboxes(3), 'value');
        dgs_selected = get(optionboxes(5), 'value');
        if dgs_selected
             barInc = barInc + 2;
        end
        if thelimitcycle.forced && irc_selected
             barInc = barInc +1 + thelimitcycle.dim;
             %phase irc requires that getdgs and getphases be called
             if ~dgs_selected
                 barInc = barInc+2;
             end
        end
    else
        barInc = barInc +2;
        if ~isempty(PAR_ENV)
            barInc = barInc +2 ;
        end
    end

   
    
    interval = 2; %max length of time that bar takes to advance one large increment,
                            %under the control of the timer in seconds
                            %This should be a guess at the interval between
                            %calls to progressform('progress', ...)
                            
    %num_div is number of small steps in one large increment. Scale so each is approx 0.1 mm on
    %screen
    num_div = ceil(maxWidth/barInc)*10;
    
    %start timer
    %period cant have > 3 dp, or get a warning
    timer_period = str2double(sprintf('%.3f', (interval/num_div)));
    
    
    tm = timer('TimerFcn', {@timer_update, num_div, barHndl, barInc, maxWidth}, 'ExecutionMode', 'fixedRate', 'Period', timer_period, 'TasksToExecute', num_div);
    start(tm);
    
    drawnow;
   
    Runtheory(thelimitcycle, outputs);
    
    %finished
    stop(tm);
    delete(tm);
    pos = get(barHndl, 'position');
    pos(3) = maxWidth;
    set(barHndl, 'Position', pos);
    drawnow;   
   
    set(closeHndl, 'string', 'Close', 'enable', 'on');
    set(newTheoryFig, 'pointer', 'arrow');
    
  
elseif strcmp(action, 'progress') || strcmp(action, 'write')
    
    %called by theory functions
    
    %write text
    str = varargin{1};
    if ~isempty(str)
        lst = get(txtHndl, 'string');
        
        if strcmp(str, 'done') && strcmp(lst{end-1}(end-2:end), '...')
            %add 'done' to last line
            lst{end-1} = [lst{end-1} str];

        else
            %new line
            lst{end} = str; 
            lst{end+1} = ' '; %add extra blank line so scrolling works
        end

        set(txtHndl, 'string', lst, 'value', []);
        
        %ensure latest lines are visible
        set(txtHndl, 'ListboxTop', max(1, length(lst)-16));
    end
    
    if strcmp(action, 'progress')
        %increment bar
        ni = varargin{2};
        %move to end of current block (large increment), and reset timer for the next
        if strcmp(get(tm, 'Running'), 'on')
            stop(tm);
            num = get(tm, 'TasksExecuted');
            for i = 1:num_div-num
                timer_update(tm, [], num_div, barHndl, barInc, maxWidth)
            end
        end
        if ni < 0
            %go back a block if user reject Xst
            barlen = get(barHndl, 'Position');
            barlen(3) = max(barlen(3) + ni * maxWidth/barInc, 0.1);
            set(barHndl, 'Position', barlen);
            drawnow;
        end
        start(tm);
    end
    drawnow;
   
    
elseif strcmp(action, 'parchange')
    
    if get(paraHndl, 'value') > 1
        set(workersHndl, 'enable', 'on')
    else
        set(workersHndl, 'enable', 'off')
    end
    
    
end


%===========================================
function timer_update(~ ,data, num_div, barHndl, barinc, maxwidth)

barlen = get(barHndl, 'Position');
barlen(3) = min(barlen(3) + maxwidth /(barinc*num_div), maxwidth);
set(barHndl, 'Position', barlen);
drawnow;

%==============================================
function Runtheory(thetheoryresults, outputs)

global newtheory PAR_ENV workersHndl gui

gui = @newtheorygui;

display_message('Launching analysis...');
disp('Orbit being analysed is given by the following structure:');
disp(thetheoryresults);
newtheory = [];

try
    if ~isempty(PAR_ENV)
        NUM_LABS = get(workersHndl, 'value');
        display_message('Starting parallel environment...');
        parpool(char(PAR_ENV), NUM_LABS);
        display_message('done', 1);
    end

    r = gettheory(thetheoryresults, outputs);
    
catch err
    r = [];
   display_message('Error running the analysis');
   ShowError('Error running the analysis', err);
  
end

if ~isempty(PAR_ENV)
    display_message('Shutting down parallel environment...');
    try
        delete(gcp('nocreate'));
    catch
        %fails if it didn't open, ignore this
    end
    display_message('done',1);
end
gui = [];
if ~isempty(r)
    thetheoryresults.theory = r;
    %resave to file
    fname = thetheoryresults.myfile;
    %replace old file
    save(fname, 'thetheoryresults', '-mat');
    %set flag that indicated to theorygui that analysis was successful
    
    newtheory = r;
end

%==========================================================================

function optChange(src, event)

%called when user clicks a checkbox to select an output
return;
data =  get(src, 'Userdata');
if ~isempty(data) 
    response = data{end}; %whether to select or deselect target boxes
    targets = data(1:end-1);
    sel = get(src, 'value');
    
    if response && sel
        %select parent box when a child selected
        for c = 1:length(targets)
            set(findobj('Tag', targets{c}), 'value', 1);
        end
    elseif ~response && ~sel
        %de select child box when parent deselected
        for c = 1:length(targets)
            set(findobj('Tag', targets{c}), 'value', 0);
        end
    end
end
