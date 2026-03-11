function [fname, ftype, force, df, df2, df3] = get_force_expr(ft) 

%returns a series of force equations and their derivatives with respect to
%dawn and dusk

%ft is an integer
%force is the force equation
%ftype = 1 - force is constant, 0 - force is varying
%df(1) is dforce/ddawn, and df(2)is dforce/ddusk
%df2(1) is d2force/ddawn2 and df(2) is d2force/ddusk2
%df3(1) is (dforce/ddusk)/ddawn and df3(2) is (dforce/ddawn)/ddusk

%name is a descriptive name of the force type

%IMPORTANT
%Force expression can contain only the symbolic variables dawn, dusk, CP and t1,
%and any constants needed.

%force definition must not contain any y values or we can't correctly
%differentiate (dy/dp)/dy in file savedxb.m. ie dy/dp contains the symbolic expression
%dforce_ddawn. This is then differentiated with respect to y. This will give
%incorrect results if the symbolic expression includes y as the code won't
%know this when the model is made.
%So when dforce_ddawn is filled in at run time, it must not contain y(n).
%Instead put y(n) in the model equations if it should affect force
%Also, model jacobian would be calculated wrongly. The model equations
%contain the symbolic name 'force'. When they are differentiated with
%respect to y, if 'force' included y, this would give incorrect results

%Force must not contain any model parameters except dawn and dusk. This is
%becuase if it did, an the dpar matrix would not be calculated correctly.
%Here we are differentiating equation containing the symbolic name 'force'
%with respect to parameters, so force musn't contain any of these
%parameters as the code cannot know it does when the model is made.   

%if not, should be no cp either, ie dont use it for some other purpose

%called from writeforce and savexpp, launchxpp and make
global tsym
tsym = cellstr('t1');
syms dawn dusk t1 f CP; 

switch ft
    case 1
       fname = 'photo';% square wave, 24 just controls steepness of transition, not CP
       f = (tanh((t1-dawn)*24) + 1) * (-tanh((t1-dusk)*24)+1)/4;
    case 2
       fname = 'impulse';
       f = exp(-(t1-dawn)*(t1-dawn)*4);%spike at dawn
    case 3
        fname = 'hoffman';
        f = (tanh((t1-dawn)*24) + 1)/2; % goes from 0 to 1 sharply at dawn. 24 controls steepness
    case 4
        fname = 'sinewave';
        f = (sin(2*pi*t1/CP + dawn/(2*pi)) + 1) / 2; %CP sets period and dawn sets phase
    case 5
        fname = '60';
        c_over = 25;
        f = (1/2*(tanh(c_over*(t1-0))+1)).*(1/2*(1-tanh(c_over*(t1-5*60))))+(1/2*(tanh(c_over*(t1-60*60))+1)).*(1/2*(1-tanh(c_over*(t1-65*60))))+(1/2*(tanh(c_over*(t1-120*60))+1)).*(1/2*(1-tanh(c_over*(t1-125*60))))+(1/2*(tanh(c_over*(t1-180*60))+1)).*(1/2*(1-tanh(c_over*(t1-185*60))));
    case 6
        fname = '100';
        c_over = 25;
        f = (1/2*(tanh(c_over*(t1-0))+1)).*(1/2*(1-tanh(c_over*(t1-5*60))))+(1/2*(tanh(c_over*(t1-100*60))+1)).*(1/2*(1-tanh(c_over*(t1-105*60))))+(1/2*(tanh(c_over*(t1-200*60))+1)).*(1/2*(1-tanh(c_over*(t1-205*60))))+(1/2*(tanh(c_over*(t1-300*60))+1)).*(1/2*(1-tanh(c_over*(t1-305*60))));
    case 7
        fname = '200';
        c_over = 25;
        f = (1/2*(tanh(c_over*(t1-0))+1)).*(1/2*(1-tanh(c_over*(t1-5*60))))+(1/2*(tanh(c_over*(t1-200*60))+1)).*(1/2*(1-tanh(c_over*(t1-205*60))))+(1/2*(tanh(c_over*(t1-400*60))+1)).*(1/2*(1-tanh(c_over*(t1-405*60))))+(1/2*(tanh(c_over*(t1-600*60))+1)).*(1/2*(1-tanh(c_over*(t1-605*60))));
    case 8
        fname = 'cts';
        f = 1;
    case 9
        fname = 'noforce';
        f = 0;
    otherwise
       force = [];
       df = [];
       df2 = [];
       df3 = [];
       fname = [];
       ftype = [];
       return;
end

% if isnumeric(f) || isempty(strfind(findsym(f), 't1'))
%     ftype = 2;%constant as is not a function of time
% elseif ~isempty(strfind(findsym(f), 'CP'))
%     ftype = 1;%periodic as is a function of CP and time
% else
%     ftype = 0;%not constant, but not periodic either
% end

if isnumeric(f) || ~any(symvar(f) == str2sym('t1'))
    ftype = 1;%constant as is not a function of time
else
    ftype = 0;%not constant
end

if nargout > 2
    force = symtostring(f);
    if nargout > 3
        df = cell(2,1);df2 = cell(2,1);df3 = cell(2,1);
        df(1) = symtostring(diff(f, dawn));
        df(2) = symtostring(diff(f, dusk));
        if nargout > 4
            df2(1) = symtostring(diff(f, dawn, 2));
            df2(2) = symtostring(diff(f, dusk, 2));
            df3(1) = symtostring(diff(diff(f, dusk), dawn));
            df3(2) = symtostring(diff(diff(f, dawn), dusk));
        end
    end
end


%======================================

function s = symtostring(expr)

global  tsym  tstr 
%t1 to t???
expr = subs(expr,str2sym(tsym),str2sym(tstr));

if isnumeric(expr)
    s = num2str(expr);
else
    s = char(expr);
end
s = cellstr(s);


