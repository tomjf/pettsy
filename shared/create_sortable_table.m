function result = create_sortable_table(hTable, colwidths, selection)

%hTable is the matlab table
%colwidths a vector of column width expressed as proportions (0 to 1)
%selection is a flag to indicate if table needs a column with checkboxes to
%allow user to select entries

%other table properties are set in Matlab

%output argument is true for success, false for failure

result = false;

try
    pxpos = getpixelposition(hTable);
    totalWidth = pxpos(3) - 30;

    % Build column widths array
    if selection
        % First column is a narrow checkbox column
        widths = cell(1, length(colwidths) + 1);
        widths{1} = 25;
        for c = 1:length(colwidths)
            widths{c+1} = max(fix(totalWidth * colwidths(c)), 20);
        end
    else
        widths = cell(1, length(colwidths));
        for c = 1:length(colwidths)
            widths{c} = max(fix(totalWidth * colwidths(c)), 20);
        end
    end

    set(hTable, 'ColumnWidth', widths);

    % Enable column sorting if supported (R2022a+)
    try
        set(hTable, 'ColumnSortable', true);
    catch
        % ColumnSortable not available in this MATLAB version
    end

catch err
    ShowError('Table formatting error', err);
    return;
end

result = true;
