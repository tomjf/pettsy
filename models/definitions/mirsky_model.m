function dydt = f(t, y, p)
   
% Goldbeter mammalian with y(5) bit added in

eval(p);    
   
dydt = [ 
    
% mRNA concentrations
(v0p1 + v1p1 * ((y(21)^na1p1)/(KA1p1^na1p1 + y(21)^na1p1))) * ((KI1p1^NI1p1)/(KI1p1^NI1p1 + y(17)^NI1p1)) * ((KI2p1^NI2p1)/(KI2p1^NI2p1 + y(18)^NI2p1)) * ((KI3p1^NI3p1)/(KI3p1^NI3p1 + y(19)^NI3p1)) * ((KI4p1^NI4p1)/(KI4p1^NI4p1 + y(20)^NI4p1)) - kmp1 * y(1);

(v0p2 + v1p2 * ((y(21)^na1p2)/(KA1p2^na1p2 + y(21)^na1p2))) * ((KI1p2^NI1p2)/(KI1p2^NI1p2 + y(17)^NI1p2)) * ((KI2p2^NI2p2)/(KI2p2^NI2p2 + y(18)^NI2p2)) * ((KI3p2^NI3p2)/(KI3p2^NI3p2 + y(19)^NI3p2)) * ((KI4p2^NI4p2)/(KI4p2^NI4p2 + y(20)^NI4p2)) - kmp2 * y(2);

(v0c1 + v1c1 * ((y(21)^na1c1)/(KA1c1^na1c1 + y(21)^na1c1)) + v2c1 * ((y(16)^na2c1)/(KA2c1^na2c1 + y(16)^na2c1))) * ((KI1c1^(NI1c1))/(KI1c1^(NI1c1) + y(17)^(NI1c1))) * ((KI2c1^(NI2c1))/(KI2c1^(NI2c1) + y(18)^(NI2c1))) * ((KI3c1^(NI3c1))/(KI3c1^(NI3c1) + y(19)^(NI3c1))) * ((KI4c1^(NI4c1))/(KI4c1^(NI4c1) + y(20)^(NI4c1))) * ((KI5c1^(NI5c1))/(KI5c1^(NI5c1) + y(13)^(NI5c1))) - kmc1 * y(3);

(v0c2 + v1c2 * ((y(21)^na1c2)/(KA1c2^na1c2 + y(21)^na1c2)) + v2c2 * ((y(16)^na2c2)/(KA2c2^na2c2 + y(16)^na2c2))) * ((KI1c2^(NI1c2))/(KI1c2^(NI1c2) + y(17)^(NI1c2))) * ((KI2c2^(NI2c2))/(KI2c2^(NI2c2) + y(18)^(NI2c2))) * ((KI3c2^(NI3c2))/(KI3c2^(NI3c2) + y(19)^(NI3c2))) * ((KI4c2^(NI4c2))/(KI4c2^(NI4c2) + y(20)^(NI4c2))) * ((KI5c2^(NI5c2))/(KI5c2^(NI5c2) + y(13)^(NI5c2))) - kmc2 * y(4);

v1re * ((y(21)^(na1re))/(KA1re^(na1re) + y(21)^(na1re) )) * ((KI1re^(NI1re))/(KI1re^(NI1re) + y(17)^(NI1re))) * ((KI2re^(NI2re))/(KI2re^(NI2re) + y(18)^(NI2re))) * ((KI3re^(NI3re))/(KI3re^(NI3re) + y(19)^(NI3re))) * ((KI4re^(NI4re))/(KI4re^(NI4re) + y(20)^(NI4re))) - kmre * y(5);

(v0clk + v1clk * ((y(16)^na1clk)/(KA1clk^na1clk + y(16)^na1clk))) * ((KI1clk^(NI1clk))/(KI1clk^(NI1clk) + y(13)^(NI1clk))) - kmclk * y(6);

(v0b + v1b * ((y(16)^na1b)/(KA1b^na1b + y(16)^na1b))) * ((KI1b^(NI1b))/(KI1b^(NI1b) + y(13)^(NI1b))) - kmb * y(7);

(v0ro + v1ro * ((y(21)^(na1ro))/(KA1ro^(na1ro) + y(21)^(na1ro))) + v2ro * ((y(16)^na2ro)/(KA2ro^na2ro + y(16)^na2ro))) * ((KI1ro^(NI1ro))/(KI1ro^(NI1ro) + y(17)^(NI1ro))) * ((KI2ro^(NI2ro))/(KI2ro^(NI2ro) + y(18)^(NI2ro))) * ((KI3ro^(NI3ro))/(KI3ro^(NI3ro) + y(19)^(NI3ro))) * ((KI4ro^(NI4ro))/(KI4ro^(NI4ro) + y(20)^(NI4ro))) * ((KI5ro^(NI5ro))/(KI5ro^(NI5ro) + y(13)^(NI5ro))) - kmro * y(8);

% protein concentrations
tp1 * y(1) - ap1c1 * y(9) * y(11) - ap1c2 * y(9) * y(12) + dp1c1 * y(17) + dp1c2 * y(18) - kpp1 * y(9);

tp2 * y(2) - ap2c1 * y(10) * y(11) - ap2c2 * y(10) * y(12) + dp2c1 * y(19) + dp2c2 * y(20) - kpp2 * y(10);

tc1 * y(3) - ap1c1 * y(9) * y(11) - ap2c1 * y(10) * y(11) + dp1c1 * y(17) + dp2c1 * y(19) - kpc1 * y(11);

tc2 * y(4) - ap1c2 * y(9) * y(12) - ap2c2 * y(10) * y(12) + dp1c2 * y(18) + dp2c2 * y(20) - kpc2 * y(12);

tre * y(5) - kpre * y(13);

tclk * y(6) - aclkb * y(14) * y(15) + dclkb * y(21) - kpclk * y(14);

tb * y(7) - aclkb * y(14) * y(15) + dclkb * y(21) - kpb * y(15);

tro * y(8) - kpro * y(16);

% protein complexes
ap1c1 * y(9) * y(11) - dp1c1 * y(17);

ap1c2 * y(9) * y(12) - dp1c2 * y(18);

ap2c1 * y(10) * y(11) - dp2c1 * y(19);

ap2c2 * y(10) * y(12) - dp2c2 * y(20);

aclkb * y(14) * y(15) - dclkb * y(21);
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


