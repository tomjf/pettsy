function [df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn(t, ModelForce, CP, model_type)

%force definitions based on the content of get_force_expr()
%calculates derivative of the model force with respect to dawn and dusk at runtime
%second derivatives not yey implemented

if strcmp(model_type, 'oscillator')
	if nargout > 2
		[df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_oscillator(t, ModelForce, CP);
	else
		[df_ddawn, df_ddusk] = get_dforce_ddawn_oscillator(t, ModelForce, CP);
	end
else
	if nargout > 2
		[df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_signal(t, ModelForce, CP);
	else
		[df_ddawn, df_ddusk] = get_dforce_ddawn_signal(t, ModelForce, CP);
	end
end


function [df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_oscillator(t, ModelForce, CP)

df_ddawn = zeros(length(ModelForce),1);
df_ddusk = zeros(length(ModelForce),1);
if nargout > 2
	d2f_ddawn2 = zeros(length(ModelForce),1);
	d2f_ddusk2 = zeros(length(ModelForce),1);
	df_ddawn_ddusk = zeros(length(ModelForce),1);
	df_ddusk_ddawn = zeros(length(ModelForce),1);
end
for i = 1:length(ModelForce)
	dawn = ModelForce(i).dawn;
	dusk = ModelForce(i).dusk;
	forcename = ModelForce(i).name;
	switch forcename
		case 'photo'
			df_ddawn(i)=((24*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))^2 - 24)*(tanh(24*dusk - 24*t + 24*CP*floor(t/CP)) + 1))/4;
			df_ddusk(i)=((24*tanh(24*dusk - 24*t + 24*CP*floor(t/CP))^2 - 24)*(tanh(24*dawn - 24*t + 24*CP*floor(t/CP)) - 1))/4;
			if nargout > 2
				d2f_ddawn2(i)=-12*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))*(24*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))^2 - 24)*(tanh(24*dusk - 24*t + 24*CP*floor(t/CP)) + 1);
				d2f_ddusk2(i)=-12*tanh(24*dusk - 24*t + 24*CP*floor(t/CP))*(24*tanh(24*dusk - 24*t + 24*CP*floor(t/CP))^2 - 24)*(tanh(24*dawn - 24*t + 24*CP*floor(t/CP)) - 1);
				df_ddusk_ddawn(i)=-((24*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))^2 - 24)*(24*tanh(24*dusk - 24*t + 24*CP*floor(t/CP))^2 - 24))/4;
				df_ddawn_ddusk(i)=-((24*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))^2 - 24)*(24*tanh(24*dusk - 24*t + 24*CP*floor(t/CP))^2 - 24))/4;
			end
		case 'impulse'
			df_ddawn(i)=-exp(-4*(dawn - t + CP*floor(t/CP))^2)*(8*dawn - 8*t + 8*CP*floor(t/CP));
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=exp(-4*(dawn - t + CP*floor(t/CP))^2)*(8*dawn - 8*t + 8*CP*floor(t/CP))^2 - 8*exp(-4*(dawn - t + CP*floor(t/CP))^2);
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'hoffman'
			df_ddawn(i)=12*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))^2 - 12;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=-24*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))*(24*tanh(24*dawn - 24*t + 24*CP*floor(t/CP))^2 - 24);
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'sinewave'
			df_ddawn(i)=cos(dawn/(2*pi) + (2*pi*(t - CP*floor(t/CP)))/CP)/(4*pi);
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=-sin(dawn/(2*pi) + (2*pi*(t - CP*floor(t/CP)))/CP)/(8*pi^2);
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case '60'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case '100'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case '200'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'cts'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'noforce'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
	end
end


function [df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_signal(t, ModelForce, CP)

df_ddawn = zeros(length(ModelForce),1);
df_ddusk = zeros(length(ModelForce),1);
if nargout > 2
	d2f_ddawn2 = zeros(length(ModelForce),1);
	d2f_ddusk2 = zeros(length(ModelForce),1);
	df_ddawn_ddusk = zeros(length(ModelForce),1);
	df_ddusk_ddawn = zeros(length(ModelForce),1);
end
for i = 1:length(ModelForce)
	dawn = ModelForce(i).dawn;
	dusk = ModelForce(i).dusk;
	forcename = ModelForce(i).name;
	switch forcename
		case 'photo'
			df_ddawn(i)=((24*tanh(24*dawn - 24*t)^2 - 24)*(tanh(24*dusk - 24*t) + 1))/4;
			df_ddusk(i)=((24*tanh(24*dusk - 24*t)^2 - 24)*(tanh(24*dawn - 24*t) - 1))/4;
			if nargout > 2
				d2f_ddawn2(i)=-12*tanh(24*dawn - 24*t)*(24*tanh(24*dawn - 24*t)^2 - 24)*(tanh(24*dusk - 24*t) + 1);
				d2f_ddusk2(i)=-12*tanh(24*dusk - 24*t)*(24*tanh(24*dusk - 24*t)^2 - 24)*(tanh(24*dawn - 24*t) - 1);
				df_ddusk_ddawn(i)=-((24*tanh(24*dawn - 24*t)^2 - 24)*(24*tanh(24*dusk - 24*t)^2 - 24))/4;
				df_ddawn_ddusk(i)=-((24*tanh(24*dawn - 24*t)^2 - 24)*(24*tanh(24*dusk - 24*t)^2 - 24))/4;
			end
		case 'impulse'
			df_ddawn(i)=-exp(-4*(dawn - t)^2)*(8*dawn - 8*t);
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=exp(-4*(dawn - t)^2)*(8*dawn - 8*t)^2 - 8*exp(-4*(dawn - t)^2);
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'hoffman'
			df_ddawn(i)=12*tanh(24*dawn - 24*t)^2 - 12;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=-24*tanh(24*dawn - 24*t)*(24*tanh(24*dawn - 24*t)^2 - 24);
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'sinewave'
			df_ddawn(i)=cos(dawn/(2*pi) + (2*t*pi)/CP)/(4*pi);
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=-sin(dawn/(2*pi) + (2*t*pi)/CP)/(8*pi^2);
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case '60'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case '100'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case '200'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'cts'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
		case 'noforce'
			df_ddawn(i)=0;
			df_ddusk(i)=0;
			if nargout > 2
				d2f_ddawn2(i)=0;
				d2f_ddusk2(i)=0;
				df_ddusk_ddawn(i)=0;
				df_ddawn_ddusk(i)=0;
			end
	end
end
