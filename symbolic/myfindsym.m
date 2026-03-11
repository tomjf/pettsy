function [s1, t1] = myfindsym(dif1, vp, vps);

% function dif = fastsubs(dif1, vp, vps);
%
% that function looks for variables which needs substitution
% and make substitution only for them
%
% dif1 - expression which needs substitution of variables
% vps - all new variables
% vp - all old variables
%
% dif - new expression

i = 0;
t1={};
s1={};

if dif1 == 0
    return
end

s = symvar(dif1);

for n = 1:length(s)
    t = char(s(n));
    for j=1:length(vp)
        if strcmp(t,vp{j})
            i=i+1;
            t1{i} = t;
            s1{i}=vps{j};
            break;
        end
    end
end

