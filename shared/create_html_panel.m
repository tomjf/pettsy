function [hndl, isHtml] = create_html_panel(parent, pos_cm, initialContent, editable)
%CREATE_HTML_PANEL Create an HTML-capable text panel using uihtml.
%
%   [hndl, isHtml] = create_html_panel(parent, pos_cm, initialContent, editable)
%
%   Creates a uihtml component for displaying HTML content. Falls back to a
%   plain-text uicontrol if uihtml is not available (pre-R2019b).
%
%   Inputs:
%     parent         - Parent figure or panel handle
%     pos_cm         - Position in centimeters [left bottom width height]
%     initialContent - Initial HTML string to display (can be empty '')
%     editable       - If true, use a plain-text edit control instead of uihtml
%                      (uihtml does not support editing)
%
%   Outputs:
%     hndl   - Handle to the created component
%              For uihtml: set hndl.Data = htmlString to update content
%              For uicontrol: use set(hndl, 'String', plainText) to update
%     isHtml - true if uihtml was created, false if fallback uicontrol
%
%   To update content after creation:
%     if isHtml
%         hndl.Data = newHtmlString;
%     else
%         set(hndl, 'String', regexprep(newHtmlString, '<[^>]*>', ''));
%     end

if nargin < 4
    editable = false;
end

isHtml = false;

if editable
    % Editable fields always use plain uicontrol (uihtml doesn't support editing)
    hndl = uicontrol( ...
        'Style', 'edit', ...
        'Units', 'centimeters', ...
        'Position', pos_cm, ...
        'Parent', parent, ...
        'BackgroundColor', 'w', ...
        'HorizontalAlignment', 'left', ...
        'Max', 10, 'Min', 0, ...
        'String', strip_html(initialContent), ...
        'FontUnits', 'points', 'FontSize', 9, 'FontName', 'SansSerif');
    return;
end

try
    % Try uihtml (R2019b+)
    mydir = fileparts(mfilename('fullpath'));
    templateFile = fullfile(mydir, 'resources', 'html_template.html');

    hndl = uihtml( ...
        'Parent', parent, ...
        'HTMLSource', templateFile, ...
        'Units', 'centimeters', ...
        'Position', pos_cm, ...
        'Data', initialContent);
    isHtml = true;
catch
    % Fallback to plain text uicontrol
    plainText = strip_html(initialContent);
    hndl = uicontrol( ...
        'Style', 'text', ...
        'Units', 'centimeters', ...
        'Position', pos_cm, ...
        'Parent', parent, ...
        'BackgroundColor', 'w', ...
        'HorizontalAlignment', 'left', ...
        'String', plainText, ...
        'FontUnits', 'points', 'FontSize', 9, 'FontName', 'SansSerif');
end

end

function plainText = strip_html(htmlStr)
%STRIP_HTML Remove HTML tags from a string
    if isempty(htmlStr)
        plainText = '';
    else
        plainText = regexprep(htmlStr, '<[^>]*>', '');
    end
end
