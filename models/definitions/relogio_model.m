function dydt = f(t, y, p)
   
% Relogio mammalian circadian clock

eval(p);    
   
dydt = [ 

kf_x1 * y(6) - kd_x1 * y(1) - d_x1 * y(1);

i_z4 * y(15) - e_x2 * y(2) - d_x2 * y(2);

i_z5 * y(16) - e_x3 * y(3) - d_x3 * y(3);

i_z6 * y(17) - d_x5 * y(4);

i_z7 * y(18) - d_x6 * y(5);

i_z8 * y(19) + kd_x1 * y(1) - kf_x1 * y(6) - d_x7 * y(6);

V_1 * (1 + a * (y(1)/t1)^b)/(1 + (((y(2) + y(3))/i1)^c) * ((y(1)/t1)^b) + (y(1)/t1)^b) - d_y1 * y(7);

V_2 * ((1 + d * (y(1)/t2)^e)/(1 + (((y(2) + y(3))/i2)^f) * ((y(1)/t2)^e) + (y(1)/t2)^e)) * (1/(1 + (y(4)/i21)^f1)) - d_y2 * y(8);

V_3 * (1 + g * (y(1)/t3)^v)/(1 + (((y(2) + y(3))/i3)^w) * ((y(1)/t3)^v) + (y(1)/t3)^v) - d_y3 * y(9);

V_4 * (1 + h * (y(1)/t4)^p)/(1 + (((y(2) + y(3))/i4)^q) * ((y(1)/t4)^p) + (y(1)/t4)^p) - d_y4 * y(10);

V_5 * (1 + kk * (y(5)/t5)^n)/(1 + ((y(4)/i5)^m) + ((y(5)/t5)^n)) - d_y5 * y(11);

p2 * y(8) + kd_z4 * y(15) + kd_z5 * y(16) - kf_z5 * y(12) * y(13) - kf_z4 * y(12) * y(14) - d_z1 * y(12);

p1 * y(7) + kd_z5 * y(16) + dp_z3 * y(14) - kf_z5 * y(12) * y(13) - p_z2 * y(13) - d_z2 * y(13);

p_z2 * y(13) + kd_z4 * y(15) - dp_z3 * y(14) - kf_z4 * y(12) * y(14) - d_z3 * y(14);

kf_z4 * y(14) * y(12) + e_x2 * y(2) - i_z4 * y(15) - kd_z4 * y(15) - d_z4 * y(15);

kf_z5 * y(13) * y(12) + e_x3 * y(3) - i_z5 * y(16) - kd_z5 * y(16) - d_z5 * y(16);

p3 * y(9) - i_z6 * y(17) - d_z6 * y(17);

p4 * y(10) - i_z7 * y(18) - d_z7 * y(18);

p5 * y(11) - i_z8 * y(19) - d_z8 * y(19);

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
%%%info Relogio model
%%%positivity non-negative
%%%method matlab_non-stiff
%%%orbit_type oscillator
% =======================================================================


