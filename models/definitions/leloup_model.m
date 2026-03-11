function dydt = f(t, y, p)
   
% Goldbeter mammalian with Rev bit added in

eval(p);    
   
dydt = [ 
    
    % Per mRNA
    v_sP*y(15)^n/(K_AP^n + y(15)^n) - v_mP*y(1)/(K_mP + y(1)) - k_dmp*y(1);
    
    % Cry mRNA
    v_sC*y(15)^n/(K_AC^n + y(15)^n) - v_mC*y(2)/(K_mC + y(2)) - k_dmc*y(2);
    
    % Bmal1 mRNA
    v_sB*K_IB^m/(K_IB^m + y(19)^m) - v_mB*y(3)/(K_mB + y(3)) - k_dmb*y(3);

    % RevErb mRNA
    v_sR*y(15)^h/(K_AR^h + y(15)^h) - v_mR*y(4)/(K_mR + y(4)) - k_dmr*y(4);
    
    % Per protein (cytosol)
    k_sP*y(1) - V_1P*y(5)/(K_p + y(5)) + V_2P*y(7)/(K_dp + y(7))...
    + k_4*y(9) - k_3*y(5)*y(6) - k_dn*y(5);

    % Cry protein (cytosol)
    k_sC*y(2) - V_1C*y(6)/(K_p + y(6)) + V_2C*y(8)/(K_dp + y(8))...
    + k_4*y(9) - k_3*y(5)*y(6) - k_dnc*y(6);

    % Phosphorylated Per protein (cytosol)
    V_1P*y(5)/(K_p + y(5)) - V_2P*y(7)/(K_dp + y(7))...
    - v_dPC*y(7)/(K_d + y(7)) - k_dn*y(7);

    % Phosphorylated Cry protein (cytosol)
    V_1C*y(6)/(K_p + y(6)) - V_2C*y(8)/(K_dp + y(8))...
    - v_dCC*y(8)/(K_d + y(8)) - k_dn*y(8);

    % Per-Cry complex (cytosol)
    - V_1PC*y(9)/(K_p + y(9)) + V_2PC*y(11)/(K_dp + y(11))...
    - k_4*y(9) + k_3*y(5)*y(6) + k_2*y(10) - k_1*y(9) - k_dn*y(9);
    
    % Per-Cry complex (nucleus)
    - V_3PC*y(10)/(K_p + y(10)) + V_4PC*y(12)/(K_dp + y(12))...
    - k_2*y(10) + k_1*y(9) - k_7*y(15)*y(10) + k_8*y(17) - k_dn*y(10);

    %Phosphorylated Per-Cry complex (cytosol)
    V_1PC*y(9)/(K_p + y(9)) - V_2PC*y(11)/(K_dp + y(11))...
    - v_dPCC*y(11)/(K_d + y(11)) - k_dn*y(11);

    % Phosphorylated Per-Cry complex (nucleus)
    V_3PC*y(10)/(K_p + y(10)) - V_4PC*y(12)/(K_dp + y(12))...
    - v_dPCN*y(12)/(K_d + y(12)) - k_dn*y(12);


    % Bmal1 protein (cytosol)
    k_sB*y(3) - V_1B*y(13)/(K_p + y(13)) + V_2B*y(14)/(K_dp + y(14))...
    - k_5*y(13) + k_6*y(15) - k_dn*y(13);

    % Phosphorylated Bmal1 protein (cytosol)
    V_1B*y(13)/(K_p + y(13)) - V_2B*y(14)/(K_dp + y(14))...
    - v_dBC*y(14)/(K_d + y(14)) - k_dn*y(14);

    % Bmal1 protein (nucleus)
    - V_3B*y(15)/(K_p + y(15)) + V_4B*y(16)/(K_dp + y(16))...
    + k_5*y(13) - k_6*y(15) - k_7*y(15)*y(10) + k_8*y(17) - k_dnb*y(15);

    % Phosphorylated Bmal1 protein (nucleus)
    V_3B*y(15)/(K_p + y(15)) - V_4B*y(16)/(K_dp + y(16))...
    - v_dBN*y(16)/(K_d + y(16)) - k_dnb*y(16); %Louis changed to k_dnb too, seems logical

    % Per-Cry-Clock-Bmal1 complex (nucleus)
    - k_8*y(17) + k_7*y(15)*y(10) - v_dIN*y(17)/(K_d + y(17)) - k_dn*y(17);

    % RevErb protein (cytosol)
    k_sR*y(4) - k_9*y(18) + k_10*y(19) - v_dRC*y(18)/(K_d + y(18)) - k_dn*y(18);

    % RevErb protein (nucleus)
    k_9*y(18) - k_10*y(19) - v_dRN*y(19)/(K_d + y(19)) - k_dn*y(19);  
    
];


% =======================================================================
% the information below is written into the file name.info and is used to
% communicate whether the system is an oscillator or a signalling system,
% which ode solver method to use, the end time is teh system is a signal,
% the force type used from the file /shared/theforce and wherther the
% solutions should be non-negative or not. The %%% before
% each line is needed. Using %%%info lines it can also be used to store away
% other information. In this case the title of the model and the initial
% condition that is used.
%%%info Leloup-Goldbeter mammalian model
%%%positivity non-negative
%%%method matlab_non-stiff
%%%orbit_type oscillator
% =======================================================================


