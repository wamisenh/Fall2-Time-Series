/* linear trend Seasonal dummies fit with an ARMA(1,2)(12,0)*/
title "Model4: Linear trend Seasonal Dummies fit with an ARMA(1,2)(12,0)";
proc arima data=ts.pm_t_all;
	identify var=pm2 crosscor=(jan feb mar apr may jun jul aug sep oct nov t);
	estimate input=(jan feb mar apr may jun jul aug sep oct nov t) p=(1)(12) q=(1);
	forecast lead=6 out=model4;
run;
quit;
title;


title "Ljung-Box test for Whitenoise in residuals on training data"; 
proc arima data=model4;
	identify var=residual whitenoise=ignoremiss;
run;
quit;

data model4;
	merge model4 ts.pm_all;
	t=_n_;
	APE=abs((pm2-forecast)/pm2);
	AE=abs(pm2-forecast);
	sAPE=(abs(forecast-pm2))/((pm2+forecast)/2);
	SE=(pm2-forecast)**2;
run;

title "MAPE on Training Data";
proc means data=model4;
	var ape AE sAPE SE;
	where t <= 54;
run;
title;

title "MAPE on Forecast";
proc means data=model4;
	var ape ae sape se;
	where t > 54;
run;
title;

proc sgplot data=model4;
	series x=t y=residual;
	series x=t y=pm2;
	series x=t y=forecast;
run;
