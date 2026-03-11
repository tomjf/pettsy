function [prod,prod_phi, fsols, tb] = product_bw(lc, allow_reject_Xst, getProd, getProdphi) %MD---don't need reltol anymore.

%
%lc the limit cycle structure
%
% prod - Y(p)Y(s)^-1 product
% prod_phi{i,j}
global PAR_ENV

global  dim sysjac solver


check_condition_number = allow_reject_Xst;
prod_phi = {};
prod = {};
fsols = {};
tb = [];

tspan = lc.sol.x;  %DAR problem is here

dim = lc.dim;
sysjac = str2func([lc.name,'_jac']);

%% MD calculating Xst for phase IRCs

% calculating Xst by using forward and backward solutions.
% fsols= are forward solutions,  X(t0,s) where s is from t0 to t1.
% rsols= are backward solutions, X(s,t1) where s is from t0 to t1.  t0 and t1 are the end points of a time interval (below we have 70 times intervals of the original [0, p] interval)
%tb time intervals

numTimeIntervals =70;%98;%70;% 100;% 97;
tic
 display_message('    Calculating forward and backward solutions...');
 %uses lc.odesol
[fsols, rsols, tb] = mintegrate(lc,dim,tspan,sysjac,numTimeIntervals, 'solver', solver);% last entry is number of time intervals into which we split the interval 0 to p. Here it is set to 70.
tt=toc;
display_message('    done');
str = sprintf('    fsols and rsols have been calculated in %.*f seconds',2,tt);
display_message(str);

%condition numbers are a measure of whether time interval 's' is fine
%enough. CN = 1/eigenvalue. Big CN means close to singular matrix. Give use
%chance to go back and use smaller 's'
if check_condition_number
    %condition numbers are a measure of whether time interval 's' is fine
    %enough. CN = 1/eigenvalue. Big CN means close to singular matrix. Give use
    %chance to go back and use smaller 's'
    while condition_numbers(fsols,rsols,tb,numTimeIntervals) == true
        %exit loop when user accepts value and condition_number() returns
        %false;
        %ask user for new time interval
        answer = inputdlg('Enter a larger number of time blocks','PeTTSy');
        if isempty(answer)
            %cancel clicked so accept current condition numbers
            break;
        else
            numTimeIntervals = str2double(answer{1});
            while isempty(numTimeIntervals)
                %non-numeric text entered
                answer = inputdlg('Enter a larger number of time blocks','PeTTSy');
                if isempty(answer)
                    break; %User clicks cancel so accept last value
                end
                numTimeIntervals = str2double(answer{1});
            end
            if isempty(answer)
                break; %User clicks cancel so accept last value
            else
                tic;
                %reset bar
                if ~isempty(PAR_ENV)
                    display_message('', -3);
                else
                    display_message('', -7);
                end
                display_message('    Calculating forward and backward solutions...');
                [fsols, rsols, tb] = mintegrate(lc,dim,tspan,sysjac,numTimeIntervals, 'solver', solver);
                tt=toc;
                display_message('    done');
                str = sprintf('    fsols and rsols have been calculated in %.*f seconds',2,tt);
                display_message(str);
            end
        end
    end
    
end
display_message('    Calculating X_st...');

[times,matrices]=newXst(0,tspan(end),tb,fsols,rsols);%MD: 'matrices' are  X(s,p) for s from  0 to p, 'times' is  s.
%take out repeating X(s,p)'s
[times,index]=unique(times,'first');
matrices=matrices(index,:);
display_message('done');

if getProd
    tic
    display_message('    Calculating product matrices...');
    %%MD 24.09 changing how prod{i} are calculated:
    prod = cell(1,length(tspan));
    Xsp=interp1(times,matrices,tspan);%X(s,p) evaluated on tspan interval.
    v=zeros(dim);
    for i=1:length(tspan)
        v(:) = Xsp(i,:);
        prod{i} = v;
    end
    clear  Xsp
    tt=toc;
    display_message('done');
    str = sprintf('    Product matrices have been calculated in %.*f seconds',2,tt);
    display_message(str);
end

if getProdphi
    tic
    display_message(str,1);
    display_message('    Calculating product matrices for phases...');
    %Find all peak times
    peaks=[];
    for i = 1:dim
        if ~isempty(lc.peaks{i})
            peaks = [peaks lc.peaks{i}];
        end
    end
    
    %MD extend timespan to 9000+ points and include these peak times
  
    tspan_ext=[(tspan(1):(tspan(end)-tspan(1))/9000:tspan(end)),  peaks];
    %removing repeats and correcting ordering  
    tspan_ext=unique(tspan_ext,'first');

 
    %PEB edited this to get rid of peak dimemsion of prodi and prodi_mx.
    %prodi= cell(1, length(pta));
    %prodi_mx= cell(size(matrices,2), length(pta));
    
    times_ext=[times,peaks];
    matrices=interp1(times,matrices,times_ext);
    [times,index]=unique(times_ext,'first');
    matrices=matrices(index,:);
    
    prodi= cell(0);
    prodi_mx= cell(size(matrices,2),1);
    prod_phi=cell(length(tspan_ext),length(peaks));
    
    v=zeros(dim);
    for i=1:length(times)
            v(:)=matrices(i,:);
            prodi_mx{i}=v; %turns 'matrices' from vectors into actual matrices.
    end
    
    for s=1:length(peaks)
        display_message(['    ' num2str(s)]);
       % phi=peaks(s);
        index_phi= find(tspan_ext==peaks(s));
       
        %if phi=0 or phi=p then, X(s,p+phi) for s from phi to phi+p is just
        %X(s,p) for s from 0 to p.
        if peaks(s)==tb(1) || peaks(s)==tb(end)
            Xsphi=interp1(times,matrices,tspan_ext);
         
            for i=1:length(tspan_ext)
                v(:) = Xsphi(i,:);
                prod_phi{i,s} = v;  %this is just X(s,p) for s from 0 to p on interval tspan_ext.
            end
            
            clear Xsphi
            
            %if phi is not 0 nor p:
            % evaluating X(s,p+phi_i) where s runs from phi_i to p+phi_i is done in two steps:
            % (1) X(s,p+phi_i)  where s runs from p to p+phi_i is the matrix X(s,phi_i) where s runs from 0 to phi_i.
            % (2) X(s,p+phi_i) where s runs from phi_i to p  is equal to matrix X(0,phi_i)*X(s,p) where s runs from phi_i to p.
        else
            
            [timesA,matricesA]=newXst_deltat(0,peaks(s),tb,fsols,rsols,lc,sysjac); % otherwise, matricesA are X(s,phi_i) and timesA are s from 0 to phi_i.
            %note X(s,phi_i) is X(tt, phi_i+p) where tt runs from p to phi_i+p.
            
            
            v(:)=matricesA(1,:);
            prodi{1}=v; %X(0,phi) matrix.
            %remove repeats
            [timesA,index]=unique(timesA,'first');
            matricesA=matricesA(index,:);
  
            %X(s,phi) evaluated for s from 0 to phi on time interval tspan_ext.
            SS2=interp1(timesA,matricesA,tspan_ext(1:index_phi-1));
            
            kfin=nnz(times<=peaks(s));
            %next to calculate X(s,p+phi) where s runs from phi to p.
            timesB=times(kfin:end);
            
            %timesB=[phi,times(kfin+1:size(matrices,2))];
            matricesB=zeros(size(timesB,2),dim^2);
            
         
            
            %calculating X(s,phi+p) from s larger than phi but less than p.
            for i=1:length(timesB)
                v=prodi{1}*prodi_mx{i+kfin-1}; %  X(s,p+phi)= X(0,phi)*X(s,p).
                matricesB(i,:)=v(:);
            end
            
            
            %X(s,phi+p) evaluated for s from phi to p evaluated at time subinterval of tspan_ext.
            SS1=interp1(timesB,matricesB,tspan_ext(index_phi:end));
            
            %X(s,phi+p) evaluated for s from phi to p+phi evaluated at time interval tspan_ext.
            SS_concat=[SS2;SS1];
            
            
            for i=1:length(tspan_ext)
                v(:)=SS_concat(i,:);
                prod_phi{i,s}=v; %turning the X(s,phi_i+p) back into matrices.
            end
            
        end
    end
    clear prodi
    clear prodi_mx
    tt=toc;
    display_message('    done');
    str = sprintf('    Product matrices for phases have been calculated in %.*f seconds',2,tt);
  
end

return

