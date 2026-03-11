
function r = getSBMLFilePanel(varargin)


persistent dataFileHndl browseDataFileHndl txtHndl msg;
persistent myDir panel;
global title_fontsize

action = varargin{1};
r = [];

if strcmp(action, 'init')

    %creates controls on the first panel
    myDir = varargin{2};
    pos = varargin{3};
    fig = varargin{4};
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', get(fig, 'Color'), ...
        'Units','centimeters', ...
        'Position',pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'off', ...
        'Parent', fig);
    
    panelwidth = pos(3);panelheight=pos(4);

    %file name selection
    uicontrol('HorizontalAlignment', 'left','Parent', panel ,'Style', 'text','FontWeight', 'bold','Units','centimeters','position',[0.5 panelheight-1.1 panelwidth-4 0.7],'string','Select your model SBML file:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', title_fontsize);
    dataFileHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[0.5 panelheight-2 panelwidth-4 0.7], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', []);
    
    set(dataFileHndl, 'BackgroundColor', 'w');
    browseDataFileHndl =uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'position',[panelwidth-3.5  panelheight-2 3 0.7], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', 'Browse ...', ...
        'call','getSBMLFilePanel(''selectfile'');');
    
    % information contorl is a java html viewer
    
    
   msg = fileread(fullfile(myDir, 'readme.txt'));
    
    txtpos = [0.5 0.5 panelwidth-1 panelheight-3];
    [txtHndl, ~] = create_html_panel(panel, txtpos, msg, false);
    
   

    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        data = varargin{2};
        %nothing to set on this panel as it is the first
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on');  
    
    
elseif strcmp(action, 'selectfile')
    
    %launch dialog box to select a file
    title = 'Select a file:';
    
    [FileName,PathName] = uigetfile('*.xml; SBML files (*.xml)',title);
    
    if ~isequal(FileName, 0)
       %valid file selected
       set(dataFileHndl, 'String', fullfile(PathName, FileName));
    end
    
elseif strcmp(action, 'gonext')
    
 %called when user click Next. Hides panel reads in file
 %returns [] if not valid


    r = [];
  
   
    %read selected data file
    fileName = get(dataFileHndl, 'String');
    if isempty(fileName)
        ShowError('You must select an SBML file!', 'No file selected', false);
        return;
    elseif exist(fileName, 'file') ~= 2
        ShowError('The selected file does not exist!', 'Bad file selection', false);
        return;
    end
    
    [~, shortfname, ext] = fileparts(fileName);
    %use libSBML function to read file into structure
   
    
    try
        SBMLModel = TranslateSBML(fileName); %Use libSBML function
        if isValidModel(SBMLModel)
            SBMLModel.sbml_file = [shortfname ext];  
            r = SBMLModel;
            set(panel, 'visible', 'off');
        end
        
    catch
        ShowError('Bad file selection', true);
        return;
    end

    
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

%==========================================================================

function v = isValidModel(SBMLModel)

%This function is based on WriteODEFunction from the SBMLToolbox, version 4.1.0
%modified by Paul Brown, University of Warwick, 2015, where indicated

%Original Copyright notice for WriteODEFunction.m below


%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2009-2012 jointly by the following organizations:
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EBML-EBI), Hinxton, UK
%
% Copyright (C) 2006-2008 jointly by the following organizations:
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. University of Hertfordshire, Hatfield, UK
%
% Copyright (C) 2003-2005 jointly by the following organizations:
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. Japan Science and Technology Agency, Japan
%     3. University of Hertfordshire, Hatfield, UK
%
% SBMLToolbox is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution.
%----------------------------------------------------------------------- -->

v = false;

% check input is an SBML model
if (~isValidSBML_Model(SBMLModel))
    ShowError('Cannot create a valid SBMLModel structure from the content of this file.');return;
end;

if SBMLModel.SBML_level < 2
   ShowError(['PeTTSy requires SBML Level 2 or higher. This model appears to be level 1']);return; 
end

% -------------------------------------------------------------
% check that we can deal with the model

for i=1:length(SBMLModel.parameter)
    if (SBMLModel.parameter(i).constant == 0)
        ShowError('SBML model contains one or more varying parameters');return;
    end;
end;

if SBMLModel.SBML_level > 2
    if ~isempty(SBMLModel.conversionFactor)
        ShowError('SBML model contains a conversion factor');return;
    end;
    for i=1:length(SBMLModel.species)
        if ~isempty(SBMLModel.species(i).conversionFactor)
            ShowError('SBML model contains a conversion factor');return;
        end;
    end;
end;

for i=1:length(SBMLModel.compartment)
    if (SBMLModel.compartment(i).constant == 0)
        ShowError('SBML model contains a varying compartment');return;
    end;
end;
if (length(SBMLModel.species) == 0)
    ShowError('SBML model does not conain any species');return;
end;

%%PEB modified thid bit . SASSy doesn't use events

if length(SBMLModel.event) > 0
    ShowError('SBML model contains one or more events');
end
for i=1:length(SBMLModel.rule)
    if (strcmp(SBMLModel.rule(i).typecode, 'SBML_ASSIGNMENT_RULE'))
        ShowError('SBML model contains one or more assignment rules');return;
    end
    if (strcmp(SBMLModel.rule(i).typecode, 'SBML_ALGEBRAIC_RULE'))
        ShowError('SBML model contains one or more algebraic rules');return;
    end
end
%%PEB =================================================

for i=1:length(SBMLModel.reaction)
    if (SBMLModel.reaction(i).fast == 1)
        ShowError('SBML model contains one or more fast reactions');return;
    end;
end;
if (length(SBMLModel.compartment) > 1)
    ShowError('SBML model contains multiple compartments');return;
end;


if ((SBMLModel.SBML_level == 2 &&SBMLModel.SBML_version > 1) || ...
        (SBMLModel.SBML_level > 2))
    if (length(SBMLModel.constraint) > 0)
        ShowError('SBML model contains one or more constraints');return;
    end;
end;

v= true;



