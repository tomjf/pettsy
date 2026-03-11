function dydt = f(t, y, p)
   
% Goldbeter mammalian with Rev bit added in

eval(p);    
   
dydt = [ 
    
    % mRNA of Per, Cry and Bmal1
    % ----------------------------------------------------
    
    % 1 Mp  (Per mRNA) 
    (vsp+amp*force) * y(14)^n / (y(14)^n + kap^n) - vmp * y(1) / (y(1) + kmp) - kdmp * y(1); 

    % 2 Mc  (Cry mRNA)
    vsc * y(14)^n / (y(14)^n + kac^n) - vmc * y(2) / (y(2) + kmc) - kdmc * y(2);
    
    % 3 Mb  (Bmal1 mRNA)
    vsb * kib^m / (y(14)^m + kib^m) - vmb * y(3) / (y(3) + kmb) - kdmb * y(3);
    
    
    % Phosphorilated and nonphosphorylated proteins PER and CRY in cytosol
    % ---------------------------------------------------------------------
  
    % 5 Pc  (PER)    
    ksp*y(1) - v1p * y(4)/(kp + y(4)) + v2p * y(6)/(kdp + y(6))+...
        k_4 * y(8) - k_3 * y(4)*y(5) - kdn * y(4);
       
    % 6 Cc  (CRY)    
    ksc*y(2) - v1c * y(5)/(kp + y(5)) + v2c * y(7)/(kdp + y(7))+...
        k_4 * y(8) - k_3 * y(4)*y(5) - kdnc * y(5);

    % 7 Pcp  (PER-p)    
    v1p*y(4)/(kp + y(4))- v2p * y(6)/(kdp + y(6))-vdpc*y(6)/(kd + y(6))-kdn * y(6);

    % 8 Ccp  (CRY-p)    
    v1c*y(5)/(kp + y(5)) - v2c * y(7)/(kdp + y(7))-vdcc*y(7)/(kd + y(7))-kdn * y(7);
 
        
    % Phosphorilated and nonphosphorylated proteins PER-CRY complex
    % ---------------------------------------------------------------------
   
    % 9 PCc (PER-CRY cytosol)
    -v1pc*y(8)/(kp+y(8))+vdpc*y(10)/(kdp+y(10))-k_4*y(8)+k_3*y(4)*y(5)+k_2*y(9)-...
        k_1*y(8)-kdn*y(8);
    
    
    % 10 PCn (PER-CRY nucleus)
    -v3pc*y(9)/(kp+y(9))+v4pc*y(11)/(kdp+y(11))-k_2*y(9)+k1*y(8)-k_7*y(14)*y(9)+...
        k_8*y(16)-kdn*y(9);
    
    % 11 PCcp (PER-CRY-p cytosol)
    v1pc*y(8)/(kp+y(8))-vdpc*y(10)/(kdp+y(10))-vdpcc*y(10)/(kd+y(10))-kdn*y(10);
    
    % 12 PCnp (PER-CRY-p nucleus)
    v3pc*y(9)/(kp+y(9))-v4pc*y(11)/(kdp+y(11))-vdpcn*y(11)/(kd+y(11))-kdn*y(11);
   
    % Phosphorilated and nonphosphorylated protein BMAL1
    % ---------------------------------------------------------------------
   
    % 13 Bc  (BMAL1 cytosol) 
    ksb*y(3)-v1b*y(12)/(kp+y(12))+v2b*y(13)/(kdp+y(13))-k_5*y(12)+k_6*y(14)-kdn*y(12);
    
    % 14 Bcp (BMAL1-p cytosol)
    v1b * y(12)/(kp+y(12))-v2b*y(13)/(kdp+y(13))-vdbc*y(13)/(kd+y(13))-kdn*y(13);
    
    % 15 Bn  (BMAL1 nucleus) 
    -v3b*y(14) / (kp + y(14)) + v4b * y(15) / (kdp + y(15))+...
        k_5 * y(12) - k_6 * y(14) - k_7*y(14)*y(9) + k_8 * y(16) - kdn * y(14);
    
    
    % 16 Bnp (BMAL1-p nucleus)
    v3b*y(14) / (kp + y(14)) - v4b * y(15) / (kdp + y(15))-...
         vdbn * y(15)/(kd + y(15)) - kdn * y(15);
    
    % Inactive complex PER-CRY=CLOCK-BMAL1
    % ---------------------------------------------------------------------
   
    % 16 In (PER-CRY-CLOCK-BMAL1)
    -k_8 * y(16) + k_7 * y(14)*y(9) - vdin * y(16) / (kd + y(16)) - kdn * y(16);
    
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


