function results=find_oscillator_cycle(model, t0,y0, par, results, odeopts)

%t0 is shift value

global  mtype varnum shift numTimepoints gui CP ModelForce solver 


tolper = 2e-6;

%Period is expected to be less than this. If not, system gives up ans
%assumes that it will not oscillate
MAX_PER = 10000;

disp('Relaxing to the limit cycle now...');
if ~isempty(gui)
    feval(gui,'progress', 'Relaxing to the limit cycle now...');
end

global yvals tvals lastpeak  maxIdx periods;  
%global as shared by events function
%events function makes it quit as soon as 3 consistent periods found for every variable
%consistent defined as min period is at least 90% of max period

odeopts  = odeset(odeopts, 'MaxStep', 50);
tic
[t,y0] = feval(str2func(solver), str2func(model.name), [t0 t0 + MAX_PER], y0, odeopts,{par, ModelForce, CP});
toc
%find var with largest amp
%ignore first half in case of initial very high value
len = floor(length(t));
y0 = y0(floor(len/2):end,:);
[maxamp maxIdx] = max(max(y0)-min(y0));
y0 = y0(end,:);
%now runs until has 3 consistent periods for this variable only
odeopts  = odeset(odeopts, 'Events', @findpeakevent, 'MaxStep', MAX_PER/4);
yvals = [];tvals = []; lastpeak = 0;periods = [];
tic
[t,y0] = feval(str2func(solver), str2func(model.name), [t0 t0 + MAX_PER*4], y0, odeopts, {par, ModelForce, CP});
y0 = y0(end,:);

maxIdx = 0; %tells event function to look at all variables, except for any that are flat
yvals = [];tvals = []; lastpeak = zeros(length(y0), 1);periods = cell(length(y0), 1);
[t,y0] = feval(str2func(solver), str2func(model.name), [t0 t0 + MAX_PER*4], y0, odeopts,{par, ModelForce, CP});
toc
y0 = y0(end,:);
odeopts  = odeset(odeopts, 'Events', []);


% MAX_PER=1000;
% [t,y0] = feval(str2func(method), str2func(model.name), [t0 t0 + MAX_PER*4], y0, odeopts,par, ModelForce, CP);
% if t(end) >= (MAX_PER*4)
%     if ~isempty(gui)
%         feval(gui,'write', ['ERROR: System does not oscillate with a period under ' num2str(MAX_PER) '. Try better parameter values']);
%     end
%     disp('System does not oscillate. Try better parameter values');
%     clear periods ts lastpeak
%     results =[];
%     return;
% end

if any(isnan(y0))
    str = 'Numerical overflow. Please choose better parameter values.';
    disp(str);
    if ~isempty(gui)
        feval(gui,'progress', str);
    end
   ShowError(str);
   results = [];
   return;
end

tic
%now rerfine results
if results.forced
    per = CP;
    if varnum < 0
        varnum = 1;
    end
     % run for one period of  the force; 
    [t,y] = feval(str2func(solver), str2func(model.name), [t0 (t0 + per)], y0, odeopts,{par, ModelForce, CP});
    eps = norm(y(1,:) - y(end,:));  %square root of sum of squares
else
    %get period
    if varnum < 0
        %user didn't specify which var to use to define phase, so use one
        %with the longest period, this avoids choosing a biphasic var
        for i = 1:length(periods)
            if length(periods{i}) >= 3
                per(i) = max(periods{i}(end-2:end));
            else
                per(i) = 0;
            end
        end
        [per varnum] = max(per);
    else
        per = max(periods{varnum}(end-2:end));
    end
    %find consecutive troughs
    if per ==0
        str = 'System appears not to oscillate but to be in a steady state. Please try different parameters or initial conditions.';
        disp(str);
        if ~isempty(gui)
            feval(gui,'progress', str);
        end
        ShowError(str);
        results = [];
        return;
        
    end
    te = t0+per*3;

 
    [t, y, per, eps] = getcycle(model.name, [t0 te], y0, par, varnum, odeopts, mtype, shift);
end

clear yvals tvals lastpeak maxIdx periods

str=sprintf('eps=%e',eps);
disp(str);
if ~isempty(gui)
    feval(gui,'progress', str);
end

 bestt = t;
 besty = y;
 besteps = eps;
 bestper = per;

%eps is difference between start and end values
% if difference between first and last poin of periodic solution
% is larger then given precision then it tries to relax
% to the limit cycle and calculate that difference once more
cnum = 0;
if eps > tolper
    % trying to relax starting from the last point
    % integrating for 10 more supposed periods

    while eps > tolper 
        cnum = cnum + 1;
        tspan1 = [t(end), t(end) + per*3];
        y1 = y(end,:);
        [t, y] = feval(str2func(solver), str2func(model.name), tspan1, y1, odeopts,{par, ModelForce, CP});
        %run for another 3 periods

        y1 = y(end,:);
        % and tries to find periodic solution again
        if results.forced
            [t,y] = feval(str2func(solver), str2func(model.name), [t0 (t0 + per)], y1, odeopts,{par, ModelForce, CP});
            eps = norm(y(1,:) - y(end,:));
        else
            [t, y, per, eps] = getcycle(model.name, [t0 t0 + 3*per], y1, par, varnum, odeopts, mtype, shift);
        end
        str=sprintf('eps=%e (tnum=%d)',eps,cnum);
        disp(str);
        if ~isempty(gui)
            feval(gui,'progress', str);
        end
        if eps < besteps
            bestt = t;
            besty = y;
            besteps = eps;
            bestper = per;
        end
        if cnum >= 10 %give up 
            break;
        end
    end
end
toc
for i = cnum+1:10
    if ~isempty(gui)
         feval(gui,'progress');
    end
end

t = bestt;
y = besty;
eps = besteps;
per = bestper;
str = sprintf('best eps=%e',eps);
disp(str);
if ~isempty(gui)
    feval(gui,'write', str);
end
%% ==============================================
% do boundary solver stuff
%  ==============================================
%must remove duplicate timepoints or bvs fails
tic
toRemove = find(diff(t) == 0);
t(toRemove) = [];
y(toRemove,:) = [];
%now try to improve solution with bvs
disp('Applying boundary value solver...');
if ~isempty(gui)
    feval(gui,'write', 'Applying boundary value solver...');
end
solinit.x = t';   %rinit represents a 24 hour time series
solinit.y = y';  %note transpose
lastwarn('');
cnum = 0;
sol = [];
bvopts = bvpset('NMax', floor(10*length(t)*size(y,2)));
while (eps > tolper) || (cnum == 0)
    cnum = cnum + 1;
    try
        sol = bvp4c(model.name, @bc, solinit,bvopts,{par, ModelForce, CP});
        [msgstr msgid] = lastwarn;
        if (~strcmp(msgid, ''))
            %warning
            if ~isempty(gui)
                feval(gui,'write', msgstr);
            end
            if strcmp(msgid, 'MATLAB:bvp4c:RelTolNotMet')
                nm = bvpget(bvopts, 'NMax');
                nm = nm * 1.5;
                bvopts = bvpset(bvopts, 'NMax', nm);
            else
                disp(msgstr);
                if ~isempty(gui)
                   feval(gui,'write', msgstr);
                end
                break;
            end
        end
        t = sol.x';
        y = sol.y';
        eps = norm(y(1,:) - y(end,:));
        solinit.x = sol.x;
        solinit.y = sol.y;
    catch ME
        %error
        msgstr = ME.message;
        disp(msgstr);
        if ~isempty(gui)
            feval(gui,'write', msgstr);
        end
        break;
    end
    if cnum >= 5
        break;
    end
end

if isempty(sol)
    disp('Boundary value solver failed');
    if ~isempty(gui)
        feval(gui,'progress', 'Boundary value solver failed');
    end
    sol = feval(str2func(solver), str2func(model.name), [t(1), t(end)], y(1,:), odeopts,{par, ModelForce, CP});
    yp = zeros(size(sol.y, 1), length(sol.x));
    for i = 1:length(sol.x)
        yp(:, i) = feval(str2func(model.name), sol.x(i), sol.y(:,i),{par, ModelForce, CP});
    end
    sol.yp = yp;
    eps = norm(sol.y(:,1)' - sol.y(:,end)');
else
   disp('Boundary value solver succeeded');
    if ~isempty(gui)
        feval(gui,'progress', 'Boundary value solver succeeded');
    end
    per = sol.x(end)-sol.x(1);
end
if eps > tolper
    if ~isempty(gui)
        feval(gui,'write', ['system is not on the limit cycle eps = ', num2str(eps)]);
    end
    if ~isempty(gui)
        feval(gui,'write', ['Unable to meet the required tolerance of ', num2str(tolper)]);
    end
    disp(['system is not on the limit cycle eps = ', num2str(eps)]);
    disp(['Unable to meet the required tolerance of ', num2str(tolper)]);
    results = [];
    return;
else
    str = {'Limit cycle found successfully';['Boundary values error = ' num2str(eps)]; ['Period = ' num2str(per)]};
    disp(str{1});
    disp(str{2});
    disp(str{3});
    if ~isempty(gui)
        feval(gui,'write', str{1});
        feval(gui,'write', str{2});
        feval(gui,'write', str{3});
    end
    %danger here is that bvs may have introduced negative values
    %the will be very smal so can be removed
    if strcmp(model.positivity,'non-negative')
        sol.y = max(real(sol.y), 0);
    else
        sol.y = real(sol.y);
    end
    if isfield(sol, 'yp')
        sol.yp = real(sol.yp); %BVS output contains this field
    else
        
    end
end 
toc

%% ==============================================
% do phase stuff
%  ==============================================
disp 'Calculating phases...';%if any phases are last point, set to first
if ~isempty(gui)
    feval(gui,'write', 'Calculating phases...');
end
tic
%find all peaks and troughs
peaks = cell(model.vnum, 1);
%vv= cell(model.vnum, 1);
%vva= cell(model.vnum, 1);
troughs = cell(model.vnum, 1);
for i = 1:size(sol.y, 1)
    data = sol.y(i,:);
    s=1;
    max_ind=[];
    min_ind=[];
    for t=2:length(sol.x)-1
        if (data(t) > data(t-1)) && (data(t) > data(t+1))
         %   peaks{i} = [peaks{i} sol.x(t)]; %MD  take ou
            s=t;
            max_ind=[max_ind s];
        %    system=str2func(model.name); % MD check derivative at peaks{i}
         %   dydt = feval(system,sol.x(s),sol.y(:,s)',par, ModelForce, CP);
          %  value=dydt(i);
          %  vv{i}=[vv{i} value];
        elseif (data(t) < data(t-1)) && (data(t) < data(t+1))
           % troughs{i} = [troughs{i} sol.x(t)];
            s=t;
            min_ind=[min_ind s];
        end
    end
    %mtype = [] for forced models
    if ~isempty(max_ind) %MD new to calculate peaks and troughs. Uses getmaximum and getminimum files.
        for j=1:length(max_ind)
            f1 = str2func('getmaximum');
            ynul=sol.y(:,max_ind(j)-1)'; %MD for some reason data is returned as a complex value with imaginary part 0.
            %imaginary part seems to cause problems when using odezero.m (in
            %ode45 method in getmaximum.
            
            
            [tp,yp] = feval(f1,model.name, [sol.x(max_ind(j)-1) sol.x(max_ind(j)+1)], ynul, par, i, odeopts);
            peaks{i}(j)=tp(end);
            % MD ths is just a test to check the derivative at max value
            % system=str2func(model.name);
            %  dydt = feval(system,tp(end),yp(end,:)',par, ModelForce, CP);
            %   value=dydt(i);
            %  vva{i}=[vva{i} value];

        end
        
    elseif any(diff(data)) %Not flat, peak must be at start/end point
        
        f1 = str2func('getmaximum');
        ynul=sol.y(:,end-1)';
        [tp,yp] = feval(f1,model.name, [sol.x(end-1) sol.x(end)+sol.x(2)-sol.x(1)], ynul, par, i, odeopts);
        peaks{i}=tp(end);
        
         %PB Theres a problem here. If first timestep
         %(sol.x(2)-sol.x(1)) is larger than the last, (sol.x(end) - sol.x(end-1)), then tspan goes beyond the 
         %integration time series so getmaximum could return a value beyond
         %the time series. This will happen if the variable is flat and it
         %just returns the end point sol.x(end)+sol.x(2)-sol.x(1)
         
         if tp(end) <= sol.x(end)
             %OK here
              peaks{i}=tp(end);
         else
              peaks{i} = sol.x(end);
     
         end
        
    end
    
    
    if ~isempty(min_ind)
        for j=1:length(min_ind)
            f1 = str2func('getminimum');
            ynul=sol.y(:,min_ind(j)-1)';
            [tp,yp] = feval(f1,model.name, [sol.x(min_ind(j)-1) sol.x(min_ind(j)+1)], ynul, par, i, odeopts);
            troughs{i}(j)=tp(end);
            % MD ths is just a test to check  the derivative at min value
            %    system=str2func(model.name);
            %      dydt12 = feval(system,tp(end),yp(end,:)',par, ModelForce, CP);
            %      value=dydt12(i);
            %     vva{i}=[vva{i} value];
        end
    elseif any(diff(data)) %Not flat, peak must be at start/end point
        
        f1 = str2func('getminimum');
        ynul=sol.y(:,end-1)';
        [tp,yp] = feval(f1,model.name, [sol.x(end-1) sol.x(end)+sol.x(2)-sol.x(1)], ynul, par, i, odeopts);
        
        if tp(end) <= sol.x(end)
             %OK here
              troughs{i}=tp(end);
         else
              troughs{i} = sol.x(end);
     
         end
        
    end
 
    % MD take out below as it relates to old way of calculating peaks and
    % troughs
  %  if (i == varnum) && strcmp(mtype, 'max') && isempty(peaks{i})
  %      %could miss a peak if it is exactly at start of limit cycle
  %      peaks{i} = sol.x(1);
  %  elseif (i == varnum) && strcmp(mtype, 'min') && isempty(troughs{i})
  %      troughs{i} = sol.x(1);
  %  end
  
  
end
toc
%==========================================================================
%At this point look for variables that aren't really oscillating. They may be flat
%but due to numerical error there are often very tiny oscillations


%Find max amplitude by comparing peaks to surrounding trough and and vice
%versa. All variables should have a value of not less than 1% of that for
%the variable with the largest value

%Any variable that fails this test, then check how many peaks and troughs
%it has. If it has 5 times the number that the variable with the lowest
%has, then reject this variable. Delete its peaks and troughs

max_amp = zeros(size(sol.y, 1), 1);
num_cycles = [];
for y = 1:size(sol.y, 1)
    pt = peaks{y};
    tt = troughs{y};
    if ~isempty(pt) && ~isempty(tt)
        time_points = sort([pt tt]);
        time_index = zeros(size(time_points));
        for t = 1:length(time_points)
            [~, tidx] = min(abs(sol.x-time_points(t)));
            time_index(t) = tidx;
        end
        num_cycles =[num_cycles length(time_points)];
        y_series = sol.y(y, time_index);
        if length(y_series) == 2
            %only one peak and one trough
            max_amp(y) = abs(diff(y_series));
        else
            amp = [];
            for j = 2:length(y_series)-1
                %for each peak/trough work out max amp
                amp = [amp (y_series(j) - (y_series(j-1)+y_series(j+1))/2)];
            end
            max_amp(y) = max(abs(amp));
        end
    end
end

largest_max_amp = max(max_amp);
amp_too_small = find(max_amp<(largest_max_amp/100));
least_cycles = min(num_cycles); %almost certainly two, ie one peak and one trough
too_many_cycles = find(num_cycles >= (5 * least_cycles));
flat_vars = intersect(amp_too_small, too_many_cycles);

if ~isempty(flat_vars)
    flat_vars=flat_vars(:)';
    for i = flat_vars
        peaks{i} = [];troughs{i} = []; 
    end
end

%==========================================================================


%% ==============================================
% increase numTimepoints if necessary
%  ==============================================
numTimepoints = max(floor(length(sol.x)/2),numTimepoints);
if mod(numTimepoints,2) == 0
    str = sprintf('An odd number of timepoints is required. There will be %d',numTimepoints + 1 );
    numTimepoints = numTimepoints + 1;
    disp(str);
else
    str = sprintf('There will be %d timepoints',numTimepoints);
end
if ~isempty(gui)
    feval(gui,'progress', str);
end

%%
results.plotting_timescale=model.plotting_timescale;
%get required evenly spaced timepoints
h = per / (numTimepoints-1);
t = sol.x(1):h:sol.x(end);
if mod(length(t) ,2) == 0   %may be needed due to numerical error
    t(end+1) = sol.x(end);
end


%results.odesol used in mintegrate/newXst_detat/fint/bint2 for oscillator
%calc_int2t/integrate_d_traj_dk/integrate_d_traj_dk/par for signal

%results.sol used in 

results.odesol = sol;%solution returned by the solver
sol = interpsol(sol, t)';
results.sol.y = sol;%solution with evenly spaced timepoints

vector_field = zeros(size(sol));

%Find derivatives of the solution
for i=1:length(t)
    vector_field(i,:)=feval(str2func(model.name),t(i),sol(i,:), {par, ModelForce, CP}); %DAR June08
end
results.sol.dy = vector_field;


f = plusforce(model, t, ModelForce, CP);
results.force = f;
if ~results.forced
    ts = t(1);            % sets time back to zero ????DAR
else
    ts = 0;
end
results.sol.x = (t - ts)';
for i = 1:model.vnum
    troughs{i} = troughs{i} - ts;
    troughs{i} = mod(troughs{i}, per);
    peaks{i} = peaks{i} - ts;
    peaks{i} = mod(peaks{i}, per);
end
results.peaks = peaks;
results.troughs = troughs;
results.odesol.x = results.odesol.x - ts;
results.per =  per;


results.par = par;
results.parn = model.parn;
results.parnames = model.parnames;
if length(results.parnames) < length(results.parn)
    results.parnames{end+1} = ' ';
end

%-------------------------------------------------------------------------
%add the dawn and dusk values
%-------------------------------------------------------------------------
for f = 1:length(results.forceparams)
    results.par = [results.par; results.forceparams(f).dawn; results.forceparams(f).dusk];
    results.parn = [results.parn; [results.forceparams(f).force '.dawn']; [results.forceparams(f).force '.dusk']];
    results.parnames = [results.parnames; [results.forceparams(f).force '.dawn']; [results.forceparams(f).force '.dusk']];
end

results.dim = model.vnum;
results.vnames = model.vnames;
if ~results.forced
    results.varnum = varnum;
else
    results.varnum = [];
end
results.orbit_type = 'oscillator';


return;

%-------------------------------------------------------------------------
function per =  getper(t,y)
    
%find minima of y
troughs = [];
for i = 2:length(y)-1
    if (y(i) < y(i-1)) && (y(i) < y(i+1))
        troughs = [troughs; t(i)];
    end
end
if length(troughs)>=2
    per = mean(diff(troughs));
else
    per = 0;
end

%-------------------------------------------------------------------------
function f = bc(ya, yb, p, ftype, cp)
%aded by PEB for bvs
f = ya - yb;    %state y must have same value at time a and time b, ie a limit cycle
%a is start, b is end

%%%%%%%%%this must be able to find a non limit cycle, eg perturb a
%%%%%%%%%parameter from the lc and run for one period