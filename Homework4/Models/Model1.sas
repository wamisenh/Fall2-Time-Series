ods trace on;
/* THIS HAS LOWEST AIC logarithmic trend 5 Fourier terms fit with an ARMA(1,1)(12,0)*/
title "Model 1: THIS HAS LOWEST AIC: Logarithmic trend 5 Fourier terms fit with an ARMA(1,1)(12,0)";
proc arima data=ts.pm_t_all;
   identify var=pm2 crosscor=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 logt);
   estimate input=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 logt) p=(1)(12) q=(1);
   forecast lead=6 out=model1;
run;
quit;
title;
ods trace off;

title "Ljung-Box test for Whitenoise in residuals on training data";
proc arima data=model1;
	identify var=residual whitenoise=ignoremiss;
run;
quit;

data model1;
	merge model1 ts.pm_all;
	t=_n_;
	APE=abs((pm2-forecast)/pm2);
	AE=abs(pm2-forecast);
	sAPE=(abs(forecast-pm2))/((pm2+forecast)/2);
	SE=(pm2-forecast)**2;
run;

title "MAPE on Training Data";
proc means data=model1;
	var ape AE sAPE SE;
	where t <= 54;
run;
title;

title "MAPE on Forecast";
proc means data=model1;
	var ape ae sape se;
	where t > 54;
run;
title;



proc sgplot data=model1;
	series x=t y=residual;
	series x=t y=pm2;
	series x=t y=forecast;
run;
