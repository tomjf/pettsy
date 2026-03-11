
function [contentMathML, success, msg] = ODEToMathML(eqn, tryfix)

%PEB, Nov 2015
%Takes a simple text based ODE and returns it as MathML
%Also returns an error message if anything goes wrong


% The TextToMathML2 java class is based on SnuggleTeX, a free and open-source Java
% library for converting fragments of LaTeX to XML
% http://www2.ph.ed.ac.uk/snuggletex/documentation/overview-and-features.html
% 
% 
% SnuggleTeX is issued under a liberal 3-clause BSD license.
% 
%  SnuggleTeX Software License (BSD License)
% =========================================
% 
% Copyright (c) 2010, The University of Edinburgh.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice, this
%   list of conditions and the following disclaimer in the documentation and/or
%   other materials provided with the distribution.
% 
% * Neither the name of the University of Edinburgh nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
% ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
% ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
% SnuggleTex makes use of the Saxon XSLT processor, http://saxon.sourceforge.net/
% This is released under the Mozilla public license
% See https://www.mozilla.org/en-US/MPL/


contentMathML = '';
msg = '';
success = true;

if nargin < 2
    tryfix = false;
end

try
    txtToMathML = TextToMathML2();
    
    %Problem is that it won't support variables with more than one
    %character in their name. So 'force' is interpreted as f*o*r*c*e.
    %Additionally, '^' operator takes precedence, so ki^n is interpreted as k*(i^n)
    %Fix this by applying brackets to every sym name, ie now (k*i)^n. Then need to work out how
    %each sym with > 1 letter would have been written in MathML and replace
    %with what it should be.
    
    %remove underscores as these are interpreted as indicating a subscript in
    %MathML
    strrep(eqn, '_', '');
    
    %allowed functions : exp, ln/log, log/log10, sin, cos,tan,sinh, cosh,tanh
    
    allowedMatlabFuncs = {'exp', 'log', 'log10', 'sin', 'cos', 'tan', 'sinh', 'cosh', 'tanh', 'floor', 'ceil'};
    
    %Won't support function calls in equation
    func_names = regexp(eqn, '([a-zA-Z0-9_])+\(', 'tokens');
    sym_func_names = {};
    
    for i = 1:length(func_names)
        
        if ~isempty(func_names{i}) && any(strcmp(char(func_names{i}), allowedMatlabFuncs))
            sym_func_names{end+1} = char(func_names{i});
        else
            msg = 'Export to SBML does not support function calls in model equations other than the following built-in functions: exp, log, log10, sin, cos, tan, sinh, cosh, tanh, floor, ceil';
            success = false;
            return;
        end
    end
    
    sym_func_names = unique(sym_func_names);
    %Find all sym names
    sym_vars = symvar(eqn);
    sym_names = cell(1, length(sym_vars));
    for ii = 1:length(sym_vars)
        sym_names{ii} = char(sym_vars(ii));
    end
    sym_names{end+1} = 'pi'; %symvar doesnt find this so add it just in case
    
    %replace in equation, add brackets
    
    for i = 1:length(sym_names)
        
        %ensure sym nane is a full name, not part of a longer name before
        %replacing
        eqn = regexprep(eqn, ['(^|[^a-zA-Z0-9_])' sym_names{i} '([^a-zA-Z0-9_\(]|$)'], ['$1(' sym_names{i} ')$2']);
        
    end
    for i = 1:length(sym_func_names)
        
        %Must replace sin(x) with ((sin)(x))
        
        eqn = regexprep(eqn, ['(^|[^a-zA-Z0-9_])' sym_func_names{i} '\(([^)]+)\)'], ['$1((' sym_func_names{i} ')($2))']);
        
    end
    
    % looks like maybe a bug in saxon. Crashes caused by
    % -(expr1)-expr2, where expr1 is any expression,
    % -var-expr2, where var is a variable name or variable *|/ variable|number
    % expr2 takes the form x/y, x*y, (x+z)/(y-z) etc ...
    % Possible fixes are (-(expr1))-expr2 and -(expr1)-(expr2)
    
    %replace '-var' with '+(-var)'
    %replace '-(expr1)' with '+(-(expr1))'
    
    %same thing happens with two + operators
    
    %remove spaces to make it simpler
    
    eqn = strrep(eqn, ' ', '');
    
    if tryfix
        
        
        fixed_eqn = [];
        if eqn(1) ~= '-'
            [token, eqn] = strtok(eqn, '-');
            fixed_eqn = [fixed_eqn token]; %all up to but not including first -
        end
        
        while ~isempty(eqn)
            
            %eqn starts with -
            [eqn, fixed] = find_negative_expr(eqn(2:end)); %convert -var- to +(-var)- and -(...)- to +(-(...))-
            
            if fixed
                %-x has becom +(-x)
                [token, eqn] = strtok(eqn(3:end), '-');%token = x
                fixed_eqn = [fixed_eqn '+(-' token];
                
            else
                [token, eqn] = strtok(eqn, '-');
                fixed_eqn = [fixed_eqn '-' token];
            end
            
        end
        
        
    else
        fixed_eqn = eqn;
    end
    
    %Another problem is when an eqn begins with a plus and then another
    %plus after the first expression, eg +expr1+expr2..... it will
    %crash. Solution is simply to remove the unnesccessary +
    if fixed_eqn(1) == '+'
        fixed_eqn = fixed_eqn(2:end);
    end
    
    %Generate MathML
    markup = txtToMathML.convert(fixed_eqn);
    %Extract just content mathml
    content = regexp(char(markup), 'MathML-Content">(.*)<\/annotation-xml>', 'tokens', 'once');
    contentMathML = char(content);
    
    %Now need to work out how variables have been misinterpreted
    
    for i = 1:length(sym_names)
        
        sn = sym_names{i};
        
        if length(sn) > 1
            
            %work out what it will be. Include whitespace for regexp below
            %capture first block as this is th eamount of indentation required
            mathml_str = '<apply>\s*<times/>\s*';
            j=1;
            while j <= length(sn)
                
                if isstrprop(sn(j), 'digit')
                    mathml_str = [mathml_str '<cn>' sn(j)];
                    while j < length(sn)
                        if isstrprop(sn(j+1), 'digit')
                            mathml_str = [ mathml_str sn(j+1)];
                            j=j+1;
                        else
                            break;
                        end
                    end
                    mathml_str = [ mathml_str '</cn>\s*'];
                else
                    mathml_str = [mathml_str '<ci>' sn(j) '</ci>\s*'];
                end
                j=j+1;
            end
            mathml_str = [mathml_str '</apply>'];
           
            
            %what it should be
            if strcmp(sn, 'pi')
                correct_sn = '<pi/>';
            else
                correct_sn = ['<ci>' sn '</ci>'];
            end
            %Replace
            
            contentMathML = regexprep(contentMathML, mathml_str, correct_sn);
            
        end
        
    end
    
    for i = 1:length(sym_func_names)
        
        fn = sym_func_names{i};
        
        
        %work out what it will be. Include whitespace for regexp below
        %sin(...) will be 
%         <apply>
%             <times/>
%             <apply>
%                <times/>
%                <ci>s</ci>
%                <ci>i</ci>
%                <ci>n</ci>
%             </apply>
%             .....
%          </apply>

%       convert to

%       <apply>
%           <sin/>
%           ......
%       </apply>
        
        
        mathml_str = '<apply>\s*<times/>\s*<apply>\s*<times/>\s*';
        j=1;
        while j <= length(fn)
            
            if isstrprop(fn(j), 'digit')
                mathml_str = [mathml_str '<cn>' fn(j)];
                while j < length(fn)
                    if isstrprop(fn(j+1), 'digit')
                        mathml_str = [ mathml_str fn(j+1)];
                        j=j+1;
                    else
                        break;
                    end
                end
                 mathml_str = [ mathml_str '</cn>\s*'];
            else
                mathml_str = [mathml_str '<ci>' fn(j) '</ci>\s*'];
            end
            j=j+1;
        end
        mathml_str = [mathml_str '</apply>'];
        
        %what it should be
        if strcmp(fn, 'log')
            correct_sn = ['<apply><ln/>'];  
        elseif strcmp(fn, 'log10')
            correct_sn = ['<apply><log/>'];
        elseif strcmp(fn, 'ceil')
            correct_sn = ['<apply><ceiling/>'];
        else
            correct_sn = ['<apply><' fn '/>'];
        end
        %Replace
        
        contentMathML = regexprep(contentMathML, mathml_str, correct_sn);
        
    end
    
    msg = 'Completed successfully';
    return;
    
catch err
    
   msg = {err.message , [err.stack(1).file ' line ' num2str(err.stack(1).line)]};
   msg= regexprep(msg, '<[^>]+>', '');
   contentMathML = '';
   success = false;
    
end

%==========================================================================
function [result, fixed] = find_negative_expr(eqn)


result = [];

%returns everything the leaing minus applies to
%eg -4+a -> 4
% -b^2 - a -> b^2
% -(a+b)/(c*d)-1 -> (a+b)/(c*d)

i = 1;
openb = 0;
closeb = 0;

while i < length(eqn)
    
    result = [result eqn(i)];
    
    if result(end) == '('
        openb = openb+1;
    elseif result(end) == ')'
        closeb = closeb+1;
    end
    i = i+1;
    if (openb == closeb) && (eqn(i) == '+' || eqn(i) == '-')
        break;
    end
end
if  ~isempty(result) &&  ~all(isstrprop(result, 'digit')) && (eqn(i) == '-')
    
    %catches (...)-... and var-...
   
    result = ['+(-' result ')' eqn(i:end)];
    fixed=true;
    
else
    result = ['-' result eqn(i:end)]; %no fix needed
    fixed=false;
end
%no fix needed if next expression is a single value
%no fix needed if current expression is of the form n/a or n*a, where n is
%a number.





%=========================================================================

function outstr = insertStr(instr, idx, insertstr)

outstr = [instr(1:idx-1) insertstr instr(idx:end)];





 