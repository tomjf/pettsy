function writeODEfile(SBMLModel, Name, Species, Parameters, Forces, properties, hPanel)


%SBMLModel - structure created by libSBML from input file
%Name - SASSY name for model
%Species - Structure array of model variables created by SBML Toolbox
%functions
%Parameters - Structure array of model parameters created by SBML Toolbox
%functions
%Forces - cell array of forces, one row for each force. Col1 is smbl name,
%col2 is sassy name, col3 is type (photo, cts etc...), col4 and Col5 are
%dawn/dusk and col6 is 'p' or 'f' depending on whether force is defined as
%a parameter or function in sbml model
%properties is a list of sassy property names
%hPanel is a gui panel contaning controls corresponding to these properties


vari = cell(size(Species));
varsym = cell(size(Species));

for i = 1:length(Species)
    vari{i} = Species(i).sassy_vec_name; %y(n)
    varsym{i} = char(Species(i).Name);
end

sbml_par = {};sassy_par = {};

for p = 1:length(Parameters)
    
    if ~strcmp(char(Parameters(p).Name), Parameters(p).sassyname)
       sbml_par{end+1} = char(Parameters(p).Name);
       sassy_par{end+1} = Parameters(p).sassyname;
    end
    
end

wbHndl = waitbar(0.0,'Generating PeTTSy files...', 'Name', 'PeTTSy', 'pointer', 'watch', 'resize', 'off');
set(wbHndl, 'userdata', 0);
inc = 1/(length(Species) + 1);

fileID = fopen([Name '_model.m'], 'w');

fprintf(fileID,  'function dydt = f(t,y,p)\n\n');

if isfield(SBMLModel, 'sbml_file')
    sbml_file = SBMLModel.sbml_file;
else
    sbml_file = SBMLModel.id;
    
end

fprintf(fileID,  '%%Genereated from %s, %s\n\n', sbml_file, datestr(now));

fprintf(fileID,  'eval(p);\n\n');

%fprintf(fileID,  'dydt = [\n\n');

%model equations with parameters as symbolic names and species as vector y
%Taken from SBMLs reaction->Kineticlaw->math field

for i = 1:length(Species)
    
    str = ['Generating PeTTSy files... Writing model equation ' num2str(i)  ' of ' num2str(length(Species))];
    updatebar(wbHndl, inc, str);
   
    fprintf(fileID,  '%% %d - %s, %s\n' , i, char(Species(i).sassyname), Species(i).Description);
    if (Species(i).ChangedByReaction == true) 
         eqn = char(Species(i).KineticLaw);
    elseif (Species(i).ChangedByRateRule == true)
         eqn = char(Species(i).RateRule);
       
    else
        %assignment rules ignored as don't describe rate of change
        eqn = '0';
    end
    
    if ~strcmp(eqn, '0')
         %replace force function name with 'force'
         %replace other function calls with the function body
         eqn = replaceFunction(SBMLModel, Forces, eqn);
     
         %change power(a,b) to a^b       
         eqn = regexprep(eqn, 'power\(\s*([a-zA-Z_0-9]+)\s*,\s*([a-zA-Z_0-9]+)\s*)', '$1^$2');

         %ignore the compartment. Remove any instances were expressions are multiplied/divided by it
         eqn = regexprep(eqn, [Species(i).compartment '\s*[*]\s*'], '');
         eqn = regexprep(eqn, ['\s*[*]\s*' Species(i).compartment], '');
         eqn = regexprep(eqn, ['\s*[/]\s*' Species(i).compartment], '');      
         %gets rid of a*comp, comp*a and a/comp
         
          %replace species name with y(n) as in 'make()'
         eqn = (subs(eqn, str2sym(varsym), str2sym(vari)));
       
         %replace parameter name with any user edits
         eqn = (subs(eqn, str2sym(sbml_par), str2sym(sassy_par)));
           
    end;
    
    fprintf(fileID,  'dydt(%u) = %s;\n\n', i, char(eqn));
    
end; % for Numspecies

fprintf(fileID,  '\n\n');


updatebar(wbHndl, inc, 'Adding addition properties');

%default force type
if ~isempty(Forces)
    fprintf(fileID,  '%%%%%%force_type ');
    for f = 1:size(Forces, 1)
        
        fprintf(fileID, '%s %f %f', Forces{f,3}, Forces{f,4}, Forces{f,5});
        if f < size(Forces, 1)
             fprintf(fileID, ',');
        else
            fprintf(fileID, '\n\n');
        end
        
    end
end

%other properties

for p = 1:length(properties)
   
    ctrl = findobj(hPanel, 'Tag', properties{p});
   
    if ~isempty(ctrl)
        pval = [];
       if strcmp(get(ctrl, 'style'), 'edit')
           pval = get(ctrl, 'string');
       elseif  strcmp(get(ctrl, 'style'), 'popupmenu')
           str = get(ctrl, 'string');
           val = get(ctrl, 'value');
           pval = str{val};
       end
       if ~isempty(pval)
            fprintf(fileID,  '%%%%%%%s %s\n\n',  properties{p}, pval);
       end
    end
    
end

%finally, notes
notes = SBMLModel.notes;
notes = strrep(notes, '<notes>', '');
notes = strrep(notes, '</notes>', '');
notes = textscan(notes, '%s',  'delimiter', '\n');

for i = 1:length(notes{1})
    fprintf(fileID,  '%%%%%%info %s\n', notes{1}{i});
end


fclose(fileID);

delete(wbHndl);


return;


%==========================================================================


function returnValue =  replaceFunction(model, Forces, eqn)

%model - structure created by libSBML from input file
%parameters - Structure array of model parameters created by SBML Toolbox
%functions
%forces - cell array of forces, one row for each force. Col1 is smbl name,
%col2 is sassy name, col3 is type (photo, cts etc...), col4 and Col5 are
%dawn/dusk and col6 is 'p' or 'f' depending on whether force is defined as
%a parameter or function in sbml model
%eqn - a model equation in symbolic form

for f = 1:size(Forces,1)
   
    %for each force
    sbml_name = Forces{f,1};
    sassy_name = Forces{f,2};
    
    if strcmp(Forces{f, end}, 'p')
        %force is a parameter in sbml so replace with its sassy name
         %Replace its sbml parameter name, delimited by chars that can't appear in a name, or by start/end of eqn
         eqn = regexprep(eqn, ['(?<=[^0-9a-zA-Z_]|^)' sbml_name '(?=[^0-9a-zA-Z_\(]|$)'], sassy_name);
    else
        %force is a function in the sbml model
        %replace 'sbml_name(....)' with sassy name
     
        %NOTE force function parameters are dropped to conform to SASSY's force
        %restrictions.
        eqn = regexprep(eqn, ['(?<=[^0-9a-zA-Z_]|^)' sbml_name '(\([^)]*\))'], sassy_name);
        %This regex matches either the start of the eqn or a char that can't
        %be in func name (?<= means this is looked for but is not part of
        %the match so is not replaced), the function name and parentheses.
        
    end

end

%Finally replace functions that are not model forces.
%Here we need to replace function call with its body

for i = 1:length(model.functionDefinition)
    
    %replace 'funcname(....)' with its body
    
    if ~model.functionDefinition(i).isforce
        
        funcname = model.functionDefinition(i).id;
 
        [inputPars, funccall]=regexp(eqn, ['(?<=[^0-9a-zA-Z_]|^)' funcname '\(\s*(([a-zA-Z0-9_]+)\s*,?\s*)*\)'], 'tokens', 'match');
        
        if ~isempty(funccall)
            %func will be defined in the form 'lambda(...., str)'
            %str is the statement forming the function body and any preceeding
            %params are the function inputs that appear in str
            %Elements{end} will be the body, other elements are inputs
            Elements = GetArgumentsFromLambdaFunction( model.functionDefinition(i).math); 
            funcbody = ['(' Elements{end} ')'];
            
            for f = 1:length(funccall)
                
                %for each call to the function in this equation
                
                inputs = inputPars{f}{1};

                %repalce input param names by their corresponding values in function
                %call
                
                if ~isempty(inputs)
                    inputs = strtrim(regexp(inputs, '\s*,\s*', 'split'));
                    %inputs a cell array with 1 element for each input param
                    % funcbody = subs(funcbody, Elements{1:end-1}, inputs);
                    
                    %Won't work if a param in funcbody matches a bulit in matlab
                    %function name, eg length in locke_05 force. Not recognised as a
                    %sym name and subs crashes
                    
                    for j = 1:length(inputs)
                        funcbody = regexprep(funcbody, ['(?<=[\(*-/+\s])' Elements{j} '(?=[*-/+\s\)])'], inputs{j});
                    end
                    
                end
                
                %replace func call with its body
                %need
                eqn = strrep(eqn, funccall{f}, funcbody);
            end
        end
        
    end
    
end

returnValue = eqn;

return;


