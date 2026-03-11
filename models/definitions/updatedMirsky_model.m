function dydt = f(t,y,p)

% Updated Mirsy model using ChIP-Seq data (but no D-box)

eval(p);

dydt = [
    
% mRNA concentrations
(v0p1 + v1p1*((y(21)^na1p1)/(KA1p1^na1p1 + y(21)^na1p1)) + v2p1*((y(14)^na2p1)/(KA2p1^na2p1 + y(14)^na2p1))) * ((KI1ap1^ni1ap1)/(KI1ap1^ni1ap1 + y(17)^ni1ap1)*(KI1bp1^ni1bp1)/(KI1bp1^ni1bp1 + y(18)^ni1bp1)*(KI1cp1^ni1cp1)/(KI1cp1^ni1cp1 + y(19)^ni1cp1)*(KI1dp1^ni1dp1)/(KI1dp1^ni1dp1 + y(20)^ni1dp1)*(KI2p1^ni2p1)/(KI2p1^ni2p1 + y(13)^ni2p1)) - kmp1*y(1);

(v0p2 + v1p2*((y(21)^na1p2)/(KA1p2^na1p2 + y(21)^na1p2)) + v2p2*((y(14)^na2p2)/(KA2p2^na2p2 + y(14)^na2p2))) * ((KI1ap2^ni1ap2)/(KI1ap2^ni1ap2 + y(17)^ni1ap2)*(KI1bp2^ni1bp2)/(KI1bp2^ni1bp2 + y(18)^ni1bp2)*(KI1cp2^ni1cp2)/(KI1cp2^ni1cp2 + y(19)^ni1cp2)*(KI1dp2^ni1dp2)/(KI1dp2^ni1dp2 + y(20)^ni1dp2)*(KI2p2^ni2p2)/(KI2p2^ni2p2 + y(13)^ni2p2)) - kmp2*y(2);

(v0c1 + v1c1*((y(21)^na1c1)/(KA1c1^na1c1 + y(21)^na1c1)) + v2c1*((y(14)^na2c1)/(KA2c1^na2c1 + y(14)^na2c1))) * ((KI1ac1^ni1ac1)/(KI1ac1^ni1ac1 + y(17)^ni1ac1)*(KI1bc1^ni1bc1)/(KI1bc1^ni1bc1 + y(18)^ni1bc1)*(KI1cc1^ni1cc1)/(KI1cc1^ni1cc1 + y(19)^ni1cc1)*(KI1dc1^ni1dc1)/(KI1dc1^ni1dc1 + y(20)^ni1dc1)*(KI2c1^ni2c1)/(KI2c1^ni2c1 + y(13)^ni2c1)) - kmc1*y(3);

(v0c2 + v1c2*((y(21)^na1c2)/(KA1c2^na1c2 + y(21)^na1c2))) * ((KI1ac2^ni1ac2)/(KI1ac2^ni1ac2 + y(17)^ni1ac2)*(KI1bc2^ni1bc2)/(KI1bc2^ni1bc2 + y(18)^ni1bc2)*(KI1cc2^ni1cc2)/(KI1cc2^ni1cc2 + y(19)^ni1cc2)*(KI1dc2^ni1dc2)/(KI1dc2^ni1dc2 + y(20)^ni1dc2)*(KI2c2^ni2c2)/(KI2c2^ni2c2 + y(13)^ni2c2)) - kmc2*y(4);

(v1rev*((y(21)^na1rev)/(KA1rev^na1rev + y(21)^na1rev)) + v2rev*((y(14)^na2rev)/(KA2rev^na2rev + y(14)^na2rev))) * ((KI1arev^ni1arev)/(KI1arev^ni1arev + y(17)^ni1arev)*(KI1brev^ni1brev)/(KI1brev^ni1brev + y(18)^ni1brev)*(KI1crev^ni1crev)/(KI1crev^ni1crev + y(19)^ni1crev)*(KI1drev^ni1drev)/(KI1drev^ni1drev + y(20)^ni1drev)*(KI2rev^ni2rev)/(KI2rev^ni2rev + y(13)^ni2rev)) - kmrev*y(5);

(v0ror + v1ror*((y(21)^na1ror)/(KA1ror^na1ror + y(21)^na1ror)) + v2ror*((y(14)^na2ror)/(KA2ror^na2ror + y(14)^na2ror))) * ((KI1aror^ni1aror)/(KI1aror^ni1aror + y(17)^ni1aror)*(KI1bror^ni1bror)/(KI1bror^ni1bror + y(18)^ni1bror)*(KI1cror^ni1cror)/(KI1cror^ni1cror + y(19)^ni1cror)*(KI1dror^ni1dror)/(KI1dror^ni1dror + y(20)^ni1dror)*(KI2ror^ni2ror)/(KI2ror^ni2ror + y(13)^ni2ror)) - kmror*y(6);

(v0clk + v2clk*((y(14)^na2clk)/(KA2clk^na2clk + y(14)^na2clk))) * ((KI2clk^ni2clk)/(KI2clk^ni2clk + y(13)^ni2clk)) - kmclk*y(7);

(v0bmal + v2bmal*((y(14)^na2bmal)/(KA2bmal^na2bmal + y(14)^na2bmal))) * ((KI2bmal^ni2bmal)/(KI2bmal^ni2bmal + y(13)^ni2bmal)) - kmbmal*y(8);

% protein concentrations
tp1 * y(1) - ap1c1 * y(9) * y(11) - ap1c2 * y(9) * y(12) + dp1c1 * y(17) + dp1c2 * y(18) - kpp1 * y(9);

tp2 * y(2) - ap2c1 * y(10) * y(11) - ap2c2 * y(10) * y(12) + dp2c1 * y(19) + dp2c2 * y(20) - kpp2 * y(10);

tc1 * y(3) - ap1c1 * y(9) * y(11) - ap2c1 * y(10) * y(11) + dp1c1 * y(17) + dp2c1 * y(19) - kpc1 * y(11);

tc2 * y(4) - ap1c2 * y(9) * y(12) - ap2c2 * y(10) * y(12) + dp1c2 * y(18) + dp2c2 * y(20) - kpc2 * y(12);

trev * y(5) - kprev * y(13);

tror * y(6) - kpror * y(14);

tclk * y(7) - acb * y(15) * y(16) + dcb * y(21) - kpclk * y(15);

tbmal * y(8) - acb * y(15) * y(16) + dcb * y(21) - kpbmal * y(16);

% dimers
ap1c1 * y(9) * y(11) - dp1c1 * y(17);

ap1c2 * y(9) * y(12) - dp1c2 * y(18);

ap2c1 * y(10) * y(11) - dp2c1 * y(19);

ap2c2 * y(10) * y(12) - dp2c2 * y(20);

acb * y(15) * y(16) - dcb * y(21);
];
