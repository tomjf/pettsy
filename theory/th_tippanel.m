function r = th_tippanel(action, varargin)

persistent panel status mainFig txtHndl hideHndl clearHndl titleHndl previousMessages clear_highlight box_is_formatted htmlContent txtIsHtml;

global rightMenu bottomMenu mydir %need to remove check when panel closed

if strcmp(action, 'init')
    %create the panel, initially hidden in the top left corner of the gui
   
    mainFig = varargin{1};
   % maincol = get(mainFig, 'color');

    panel = uipanel('BorderType', 'etchedin', ...
        'Units','centimeters', ...
        'Position',[0 0 0.1 0.1], ...
        'visible', 'off', ...
        'Parent', mainFig);
    
    titleHndl = uicontrol('Parent',panel , ...
        'Style', 'text', 'horizontalalignment', 'left', ...
        'FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 10, ...
        'Units','centimeters', ...
        'position',[0 0 0.1 0.1], ...
        'string','Messages');

    [txtHndl, txtIsHtml] = create_html_panel(panel, [0 0 0.1 0.1], '', false);
    htmlContent = '';
    clearHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0 0 1 0.5], ...
        'string', 'Clear', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 8, ...
        'tooltipstring', 'Clear messages', ...
        'Callback','th_tippanel(''clear'');'); 
    
     hideHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0 0 0.5 0.5], ...
        'string', 'X', ...
        'BackgroundColor', 'r', ...
        'ForegroundColor', 'w', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Close messages window', ...
        'Callback','th_tippanel(''hide'');'); 
    
    status = 'hidden';
    previousMessages = [];
    clear_highlight = false;
    box_is_formatted = false;
    
    r = panel;
    
elseif strcmp(action, 'show')
    %model has been set at startup, or when user changed model menu
    
    pos = varargin{1};
    if strcmp(status, pos)
        %already shown in this place
        return;
    end

    if strcmp(pos, 'right')
        %extend figure by required amount
        formsize = get(mainFig, 'position');
        formsize(3) = 31;
        set(mainFig, 'position', formsize);
        
        if strcmp(status, 'bottom')
           %shrink height
            formsize(4)=18;
            %maintain position on screen
            formsize(2) = formsize(2)+4;
            set(mainFig, 'position', formsize);
            %shift panels upwards
            th_rightpanel('position');
            th_leftpanel('position');
            th_titlepanel('position');
        end
        set(panel, 'position', [formsize(3)-7 0.1 6.9 formsize(4)-0.4], 'visible', 'on');
        set(txtHndl, 'position', [0 0 6.8 formsize(4)-1]);
        set(titleHndl, 'position', [0.1 formsize(4)-1 4 0.5]);
        set(hideHndl, 'position', [6.3 formsize(4)-1 0.5 0.5]);
        set(clearHndl, 'position', [5.3 formsize(4)-1 1 0.5]);
    else
        %show at bottom
        %extend figure by required amount
        formsize = get(mainFig, 'position');
        formsize(4) = 22;
        %dont let it go off top of screen
        formsize(2) = formsize(2)-4;
        set(mainFig, 'position', formsize);
        %shift panels upwards
        th_rightpanel('position');
        th_leftpanel('position');
        th_titlepanel('position');
        if strcmp(status, 'right')
           %shrink width
           formsize(3)=24;
           set(mainFig, 'position', formsize);
        end 
        set(panel, 'position', [0.1 0.1 formsize(3)-0.2 3.9], 'visible', 'on');
        set(txtHndl, 'position', [0 0 formsize(3)-0.3 3.3]);
        set(titleHndl, 'position', [0.1 3.3 4 0.5]);
        set(hideHndl, 'position', [formsize(3)-0.8 3.3 0.5 0.5]);
        set(clearHndl, 'position', [formsize(3)-1.8 3.3 1 0.5]);
    end
    status = pos;
    box_is_formatted = true;
    
    
elseif strcmp(action, 'hide')
    
     if strcmp(status, 'hidden')
        return;
     end
        
     set(panel, 'position', [0 0 0.1 0.1], 'visible', 'off');
     set([titleHndl txtHndl], 'position', [0 0 0.1 0.1]);
     set(hideHndl, 'position', [0 0 0.5 0.5]);
     %shrink form
     formsize = get(mainFig, 'position');
     if strcmp(status, 'right')
         %shrink width
         formsize(3)=24;
         set(mainFig, 'position', formsize);
     else
         %shrink height
         formsize(4)=18;
         %maintain position on screen
         formsize(2) = formsize(2)+4;
         set(mainFig, 'position', formsize);
         %shift panels upwards
         th_rightpanel('position');
         th_leftpanel('position');
         th_titlepanel('position');
     end
    
     set([rightMenu bottomMenu], 'checked', 'off');
     status = 'hidden';
     
elseif strcmp(action, 'write')

    msg = varargin{1};
    level = varargin{2};

    %keep a record of messages to avoid repetitive ones
    if box_is_formatted && ~(length(msg) == length(previousMessages) && all(strcmp(msg, previousMessages)))

        %add text to content

        if clear_highlight
            %grey out text no longer relevant
            htmlContent = regexprep(htmlContent, 'color\s*=\s*"black"', 'color="#888888"');
            clear_highlight = false;
        end
        %add icon marker for next block of text
        icon = '';
        if level == 1
            icon = '[i] ';
        elseif level == 2
            icon = '[!] ';
        elseif level == 3
            icon = '[>] ';
        end


        if iscell(msg)
            msgtowrite = '';
            for i = 1:length(msg)
                msgtowrite = [msgtowrite  msg{i} '<br/>'];
            end
        else
            msgtowrite = msg;
        end

        %add new message
        htmlContent = [htmlContent '<div style="margin-top:5px"><font color="black">' icon msgtowrite '</font></div>'];
        try
            txtHndl.Data = htmlContent;
        catch
            set(txtHndl, 'String', regexprep(htmlContent, '<[^>]*>', ''));
        end
        previousMessages = msg;

    end

elseif strcmp(action, 'clear')

    htmlContent = '';
    try
        txtHndl.Data = '';
    catch
        set(txtHndl, 'String', '');
    end
    clear_highlight = true;
    previousMessages = [];
    
elseif strcmp(action, 'clear_highlight')
      %sets a flag that removes text highlighting before next text is added that will be
      %highlighted. Usually called in response to user actions that make
      %previously highlighted text no longer applicable. Text is not
      %unhighlighted in response to cascading messages produced by the gui
      %as all these may remain relevant.
       clear_highlight = true;
       
end 

%======================================================================
function scrollToEnd(txtHndl, pos)


%ensure latest lines are visible
if strcmp(pos, 'right')
    maxlines = 30;
else
    maxlines = 6;
end
str = get(txtHndl, 'string');
drawnow;
pause(0.1);%needed or scrolling won't work??
set(txtHndl, 'ListboxTop', max(1, length(str)-maxlines));


%======================================================================
function r = fixLineBreaks(msg, linelength)

 % Add line breaks by breaking strings into multiple cell array
 % elements
 % msg is a cell array of strings to be broken up to no more than
 % linelength chars
 
 msgtowrite = cell(0);
 for m = 1:length(msg)
     msgline = msg{m};
     if length(msgline) > linelength
         %break into words
         spaces  = find(msgline == ' ');
         spaces = [1 spaces length(msgline)];
         breaks = 0;
         for i = 1:length(spaces)
             %find last space that can fit onto a line
             if spaces(i) > breaks(end)+linelength
                 breaks = [breaks spaces(i-1)];
             end
         end
         breaks = [breaks length(msgline)];
         for i = 1:length(breaks)-1
             msgtowrite{end+1} = msgline(breaks(i)+1:breaks(i+1));
         end
     else
         %line not too long
         msgtowrite{end+1} = msgline;
     end
     
 end
 
 r = msgtowrite;

    

 %what about when moving to side view?? Need to put line breaks in
 %exisitng lines
%hash vals
%help buttons on the panels
%use ButtonDownFcn to generate messages whenclicking on controls


%xpp

%clear button, next button
