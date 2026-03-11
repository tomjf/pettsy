function dydt = f(t, y, p)
   
% Abo Circadian Model

eval(p);    
   
dydt = [ 
    % mRNAs
    % ----------------------------------------------------
    
    % 1 Per mRNA
    -dm_per * y(1) + (vmax_per * (1 + fold_per * (y(12)/ka_per_cb)^hill_per_cb))/(1 + ((y(12)/ka_per_cb)^hill_per_cb) * (1 + (y(11)/ki_per_pc)^hill_per_pc));
    
    % 2 Cry mRNA
    -dm_cry * y(2) + (1/(1 + (y(8)/ki_cry_rev)^hill_cry_rev)) * (vmax_cry * (1 + fold_cry * ((y(12)/ka_cry_cb)^hill_cry_cb))/(1 + ((y(12)/ka_cry_cb)^hill_cry_cb) * (1 + (y(11)/ki_cry_pc)^hill_cry_pc)));
    
    % 3 RevErb mRNA
    -dm_rev * y(3) + (vmax_rev * (1 + fold_rev * (y(12)/ka_rev_cb)^hill_rev_cb))/(1 + ((y(12)/ka_rev_cb)^hill_rev_cb) * (1 + (y(11)/ki_rev_pc)^hill_rev_pc));
    
    % 4 Ror mRNA
    -dm_ror * y(4) + (vmax_ror * (1 + fold_ror * (y(12)/ka_ror_cb)^hill_ror_cb))/(1 + ((y(12)/ka_ror_cb)^hill_ror_cb) * (1 + (y(11)/ki_ror_pc)^hill_ror_pc));
    
    % 5 Bmal1 mRNA
    -dm_bmal * y(5) + (vmax_bmal * (1 + fold_bmal * (y(9)/ka_bmal_ror)^hill_bmal_ror))/(1 + (y(8)/ki_bmal_rev)^hill_bmal_rev + (y(9)/ka_bmal_ror)^hill_bmal_ror);
    
    % Proteins
    % ---------------------------------------------------------------------
    
    % 6 PER protein
    -dp_per * y(6) + kp_per * y(1) - kass_pc * y(6) * y(7) + kdiss_pc * y(11);
    
    % 7 CRY protein
    -dp_cry * y(7) + kp_cry * y(2) - kass_pc * y(6) * y(7) + kdiss_pc * y(11);
    
    % 8 REVERB protein
    -dp_rev * y(8) + kp_rev * y(3);

    % 9 ROR protein
    -dp_ror * y(9) + kp_ror * y(4);

    % 10 BMAL1 protein
    -dp_bmal * y(10) + kp_bmal * y(5) - kass_cb * y(10) + kdiss_cb * y(12);
    
    % Protein complexes
    % ----------------------------------------------------
    
    % 11 PER-CRY complex
    -d_pc * y(11) + kass_pc * y(6) * y(7) - kdiss_pc * y(11);
    
    % 12 CLOCKBMAL1 complex
    -d_cb * y(12) + kass_cb * y(10) - kdiss_cb * y(12);
 
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
%%%info Abo Circadian model
%%%positivity non-negative
%%%method matlab_non-stiff
%%%orbit_type oscillator
% =======================================================================