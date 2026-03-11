function dydt = f(t, y, p)
   
% Jolley et al model

eval(p);    
   
dydt = [ 
    
    1 / (1 + (chi_1 * y(8))^n) - eta_ma * y(1);

    (chi_2 * y(6))^n / (1 + (chi_2 * y(6))^n + (chi_3 * y(10))^n) - eta_mb * y(2);
    
    ((chi_4 * y(6))^n / (1 + (chi_4 * y(6))^n + (chi_7 * y(10))^n) + (chi_5* y(7))^n / (1 + (chi_5 * y(7))^n + (chi_6 * y(9))^n)) - eta_mc * y(3);

    1 / (1 + (chi_8 * y(8))^n) - eta_md * y(4);

    (chi_9 * y(7))^n / (1 + (chi_9 * y(7))^n + (chi_10 * y(9))^n) - eta_me * y(5);

% protein concentrations

    y(1) - eta_pA * y(6);

    y(2) - eta_pB * y(7);

    y(3) - eta_pC * y(8);

    y(4) - eta_pD * y(9);

    y(5) - eta_pE * y(10);
    
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
%%%info Jolley clock model
%%%positivity non-negative
%%%method matlab_non-stiff
%%%orbit_type oscillator
% =======================================================================


