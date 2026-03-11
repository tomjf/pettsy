function dydt = f(t, y, p)
   
% Becker-Weimann model

eval(p);    
   
dydt = [
    v_1b * (y(7)^s + c) / (k_1b^s * (1 + (y(3)/k_1i)^p + (y(7)^s + c))) - k_1d * y(1);

    k_2b * y(1)^q - k_2t * y(2) + k_3t * y(3) - k_2d * y(2);

	k_2t * y(2) - k_3t * y(3) - k_3d * y(3);

	v_4b / (k_4b + (y(8)/k_4i)^u) - k_4d * y(4);

	k_5b * y(4) - k_5t * y(5) + k_6t * y(6) - k_5d * y(5);

	k_5t * y(5) - k_6t * y(6) - k_6a * y(6) + k_7a * y(7) - k_6d * y(6);

	k_6a * y(6) - k_7a * y(7) - k_7d * y(7);

    v_8b * (y(7)^r + c) / (k_8b^r * (1 + (y(3)/k_8i)^v + (y(7)^r + c))) - k_8d * y(8);

];


% =======================================================================
% the information below is written into the file name.info and is used to
% communicate whether the system is an oscillator or y(1) signalling system,
% which ode solver method to use, the end time is teh system is y(1) signal,
% the force type used from the file /shared/theforce and wherther the
% solutions should be non-negative or not. The %%% before
% each line is needed. Using %%%info lines it can also be used to store away
% other information. In this case the title of the model and the initial
% condition that is used.
%%%info Becker-Weimann mammalian model
%%%positivity non-negative
%%%method matlab_non-stiff
%%%orbit_type oscillator
% =======================================================================


