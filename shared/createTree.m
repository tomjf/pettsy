%create tree-like selection control using a multi-select listbox
%replaces former JIDE CheckBoxTree (removed from modern MATLAB)

function varargout = createTree(action, varargin)

persistent listboxHndl fieldPaths;

if strcmp(action, 'init')

    % panel - uipanel to act as control container
    % pos - position, in pixels
    % timeSeriesData - structure to display the fields of
    % showDescriptions - non-zero means show descriptions next to field name
    % showSizes - non-zero means show dimensions next to field name

    panel = varargin{1};
    pos = varargin{2};
    timeSeriesData = varargin{3};
    showDescriptions = varargin{4};
    showSizes = varargin{5};

    % Build flat list of field paths with indentation
    [fieldPaths, fieldLabels] = flattenStructFields(timeSeriesData, '', 0, showDescriptions, showSizes);

    % Create multi-select listbox
    listboxHndl = uicontrol( ...
        'Style', 'listbox', ...
        'Units', 'pixels', ...
        'Position', pos, ...
        'Parent', panel, ...
        'String', fieldLabels, ...
        'Max', 2, 'Min', 0, ...
        'Value', [], ...
        'FontUnits', 'points', 'FontSize', 9, ...
        'FontName', 'FixedWidth');

    varargout{1} = listboxHndl;

elseif strcmp(action, 'get_selected')

    % Retrieve selected field paths
    if isempty(listboxHndl) || ~isvalid(listboxHndl)
        varargout{1} = {};
        return;
    end

    selectedIdx = get(listboxHndl, 'Value');
    selectedPaths = cell(length(selectedIdx), 1);

    for s = 1:length(selectedIdx)
        selectedPaths{s} = fieldPaths{selectedIdx(s)};
    end

    varargout{1} = selectedPaths;

elseif strcmp(action, 'clear')

    if ~isempty(listboxHndl) && isvalid(listboxHndl)
        delete(listboxHndl);
    end
    listboxHndl = [];
    fieldPaths = {};

end

%==========================================================================

function [paths, labels] = flattenStructFields(data, parentPath, depth, showDescriptions, showSizes)
% Recursively flatten struct fields into indented list entries
% Returns cell arrays of field paths and display labels

paths = {};
labels = {};

types = {'logical', 'char', 'numeric', 'cell', 'struct', 'function_handle'};

datanames = fieldnames(data);

indent = repmat('  ', 1, depth);

for i = 1:length(datanames)
    fieldName = datanames{i};
    field = data.(fieldName);
    isStruct = false;

    pathToNode = fieldName;
    if ~isempty(parentPath)
        pathToNode = [parentPath '.' pathToNode];
    end

    if showSizes
        % Get type info
        fieldType = '';
        for t = 1:length(types)
            if isa(field, types{t})
                fieldType = types{t};
                break;
            end
        end
        fieldSize = size(field);
        fieldSizeStr = printFieldSize(fieldSize);
        if strcmp(fieldType, 'cell')
            if max(fieldSize) == 1
                typeStr = ['{' field{1} '}'];
            else
                typeStr = ['{' fieldSizeStr ' cell array}'];
            end
        elseif strcmp(fieldType, 'struct')
            typeStr = ['[' fieldSizeStr ' struct]'];
            isStruct = true;
        elseif strcmp(fieldType, 'char')
            if max(fieldSize) == 1
                if length(field) <= 25
                    typeStr = ['''' field ''''];
                else
                    typeStr = ['''' field(1:15) '...' field(end-5:end) ''''];
                end
            else
                typeStr = ['[' fieldSizeStr ' char array]'];
            end
        elseif strcmp(fieldType, 'function_handle')
            typeStr = '@function_handle';
            field = char(field);
        else
            % numeric
            if max(fieldSize) == 1
                typeStr = ['[' num2str(field(1)) ']'];
            else
                typeStr = ['[' fieldSizeStr ' numeric]'];
            end
        end
        typeStr = [': ' typeStr];
    else
        typeStr = '';
        if isstruct(field)
            isStruct = true;
        end
    end

    % Add description if requested
    descStr = '';
    if showDescriptions
        desc = getFieldDescription(pathToNode);
        if ~isempty(desc)
            descStr = ['  (' desc ')'];
        end
    end

    % Build display label
    label = [indent fieldName typeStr descStr];

    % Add to lists
    paths{end+1} = ['.' pathToNode];
    labels{end+1} = label;

    if isStruct
        % Recursively add children
        [childPaths, childLabels] = flattenStructFields(field, pathToNode, depth + 1, showDescriptions, showSizes);
        paths = [paths childPaths];
        labels = [labels childLabels];
    end
end

%==========================================================================

function str = getFieldDescription(name)

persistent fieldDescriptions;

if isempty(fieldDescriptions)
    fieldDescriptions = {};
    mydir = fileparts(mfilename('fullpath'));
    fname = fullfile(mydir, 'field_desc.txt');
    fid = fopen(fname);
    if fid > 0
        fieldDescriptions = textscan(fid, '%s %s', 'Delimiter', '\t', 'MultipleDelimsAsOne', 1);
        fclose(fid);
    end
end

str = '';
for f = 1:length(fieldDescriptions{1})
    if strcmp(fieldDescriptions{1}{f}, name)
        str = fieldDescriptions{2}{f};
        return;
    end
end

%==========================================================================

function fs = printFieldSize(fieldSize)

fs = '';
for i = 1:length(fieldSize)
    fs = [fs num2str(fieldSize(i))];
    if i < length(fieldSize)
        fs = [fs 'x'];
    end
end
