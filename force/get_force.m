function force = get_force(t, ModelForce, CP, model_type)

%force definitions based on the content of get_force_expr()
%calculates force value at runtime

if strcmp(model_type, 'oscillator')
	force = get_force_oscillator(t, ModelForce, CP);
else
	force = get_force_signal(t, ModelForce, CP);
end


function force = get_force_oscillator(t, ModelForce, CP)

force = zeros(length(ModelForce),1);
for i = 1:length(ModelForce)
	dawn = ModelForce(i).dawn;
	dusk = ModelForce(i).dusk;
	forcename = ModelForce(i).name;
	switch forcename
		case 'photo'
			force(i)=-((tanh(24*dawn - 24*t + 24*CP*floor(t/CP)) - 1)*(tanh(24*dusk - 24*t + 24*CP*floor(t/CP)) + 1))/4;
		case 'impulse'
			force(i)=exp(-4*(dawn - t + CP*floor(t/CP))^2);
		case 'hoffman'
			force(i)=1/2 - tanh(24*dawn - 24*t + 24*CP*floor(t/CP))/2;
		case 'sinewave'
			force(i)=sin(dawn/(2*pi) + (2*pi*(t - CP*floor(t/CP)))/CP)/2 + 1/2;
		case '60'
			force(i)=(tanh(25*t - 25*CP*floor(t/CP))/2 + 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 7500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 90000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 97500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 180000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 187500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 270000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 277500)/2 + 1/2);
		case '100'
			force(i)=(tanh(25*t - 25*CP*floor(t/CP))/2 + 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 7500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 150000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 157500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 300000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 307500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 450000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 457500)/2 + 1/2);
		case '200'
			force(i)=(tanh(25*t - 25*CP*floor(t/CP))/2 + 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 7500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 300000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 307500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 600000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 607500)/2 + 1/2) - (tanh(25*CP*floor(t/CP) - 25*t + 900000)/2 - 1/2)*(tanh(25*CP*floor(t/CP) - 25*t + 907500)/2 + 1/2);
		case 'cts'
			force(i)=1;
		case 'noforce'
			force(i)=0;
	end
end


function force = get_force_signal(t, ModelForce, CP)

force = zeros(length(ModelForce),1);
for i = 1:length(ModelForce)
	dawn = ModelForce(i).dawn;
	dusk = ModelForce(i).dusk;
	forcename = ModelForce(i).name;
	switch forcename
		case 'photo'
			force(i)=-((tanh(24*dawn - 24*t) - 1)*(tanh(24*dusk - 24*t) + 1))/4;
		case 'impulse'
			force(i)=exp(-4*(dawn - t)^2);
		case 'hoffman'
			force(i)=1/2 - tanh(24*dawn - 24*t)/2;
		case 'sinewave'
			force(i)=sin(dawn/(2*pi) + (2*pi*t)/CP)/2 + 1/2;
		case '60'
			force(i)=(tanh(25*t)/2 + 1/2)*(tanh(7500 - 25*t)/2 + 1/2) - (tanh(90000 - 25*t)/2 - 1/2)*(tanh(97500 - 25*t)/2 + 1/2) - (tanh(180000 - 25*t)/2 - 1/2)*(tanh(187500 - 25*t)/2 + 1/2) - (tanh(270000 - 25*t)/2 - 1/2)*(tanh(277500 - 25*t)/2 + 1/2);
		case '100'
			force(i)=(tanh(25*t)/2 + 1/2)*(tanh(7500 - 25*t)/2 + 1/2) - (tanh(150000 - 25*t)/2 - 1/2)*(tanh(157500 - 25*t)/2 + 1/2) - (tanh(300000 - 25*t)/2 - 1/2)*(tanh(307500 - 25*t)/2 + 1/2) - (tanh(450000 - 25*t)/2 - 1/2)*(tanh(457500 - 25*t)/2 + 1/2);
		case '200'
			force(i)=(tanh(25*t)/2 + 1/2)*(tanh(7500 - 25*t)/2 + 1/2) - (tanh(300000 - 25*t)/2 - 1/2)*(tanh(307500 - 25*t)/2 + 1/2) - (tanh(600000 - 25*t)/2 - 1/2)*(tanh(607500 - 25*t)/2 + 1/2) - (tanh(900000 - 25*t)/2 - 1/2)*(tanh(907500 - 25*t)/2 + 1/2);
		case 'cts'
			force(i)=1;
		case 'noforce'
			force(i)=0;
	end
end
