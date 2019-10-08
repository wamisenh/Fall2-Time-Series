libname ts "C:\Users\bjsul\Documents\NCSU\MSA\Fall\Time-Series\Homework\Homework4";

data ts.pm_v ts.pm_t ts.pm_all;
	set ts.raleigh2_month (rename=Daily_Mean_PM2_5_Concentration=pm2);
	pi=constant("pi");
	t=_n_; *trend var;
	tsq=t**2; *trend squared;
	logt=log(t); *log trend;
	s1=sin(2*pi*1*_n_/12);
	c1=cos(2*pi*1*_n_/12);
	s2=sin(2*pi*2*_n_/12);
	c2=cos(2*pi*2*_n_/12);
	s3=sin(2*pi*3*_n_/12);
	c3=cos(2*pi*3*_n_/12);
	s4=sin(2*pi*4*_n_/12);
	c4=cos(2*pi*4*_n_/12);
	s5=sin(2*pi*5*_n_/12);
	c5=cos(2*pi*5*_n_/12);
	s6=sin(2*pi*6*_n_/12);
	c6=cos(2*pi*6*_n_/12);
	***Seasonal DumDums below***;
	if month(date)=1 then jan=1; else jan=0;
	if month(date)=2 then feb=1; else feb=0;
	if month(date)=3 then mar=1; else mar=0;
	if month(date)=4 then apr=1; else apr=0;
	if month(date)=5 then may=1; else may=0;
	if month(date)=6 then jun=1; else jun=0;
	if month(date)=7 then jul=1; else jul=0;
	if month(date)=8 then aug=1; else aug=0;
	if month(date)=9 then sep=1; else sep=0;
	if month(date)=10 then oct=1; else oct=0;
	if month(date)=11 then nov=1; else nov=0;
	if month(date)=12 then dec=1; else dec=0;
	***Split into training and validation***;
	if _n_ < 55 then output ts.pm_t;
	else output ts.pm_v;
	output ts.pm_all;
run;
/*
proc arima data=ts.pm_t;
	identify var=pm2 stationarity=(adf=3);
run;
quit;

* doing this to detrend the data;
*estimates linear trend;
proc arima data=ts.pm_t out=lintrend;
	identify var=pm2 crosscor=(t tsq logt);
	estimate input=t;
	forecast lead=6;
run;
quit;

*merges with the training data, calculates detrended data;
data lintrend;
	merge work.lintrend ts.pm_t;
	dtpm2=pm2-forecast;
run;

proc arima data=lintrend;
	identify var=dtpm2 stationarity=(adf=2 dlag=12);
run;
quit;

proc arima data=ts.pm_t out=exptrend;
	identify var=pm2 crosscor=(t tsq logt);
	estimate input=(t tsq);
	forecast lead=6;
run;
quit;

data exptrend;
	merge work.exptrend ts.pm_t;
	dtpm2=pm2-forecast;
run;

proc arima data=ts.pm_t out=logtrend;
	identify var=pm2 crosscor=(t tsq logt);
	estimate input=logt;
	forecast lead=6;
run;
quit;

data logtrend;
	merge work.logtrend ts.pm_t;
	dtpm2=pm2-forecast;
run;
*/


/*check for stationarity, seasonally stationary*/ 
title "Check for Seasonal Stationarity";
proc arima data=ts.pm_t plot(unpack);
	identify var=pm2 stationarity=(adf=2 dlag=12);
run;
quit;
title;

/* linear trend 5 Fourier terms fit with an ARMA(1,1)(12,0)*/
title "Model2: Linear trend 5 Fourier terms fit with an ARMA(1,1)(12,0)";
proc arima data=ts.pm_t;
   identify var=pm2 crosscor=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 t);
   estimate input=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 t) p=(1)(12) q=(1);
run;
quit;
title;

data pm_t_all;
	set ts.pm_all;
	if t>54 then pm2=.;
run;

ods trace on;
/* THIS HAS LOWEST AIC logarithmic trend 5 Fourier terms fit with an ARMA(1,1)(12,0)*/
title "Model 1: THIS HAS LOWEST AIC: Logarithmic trend 5 Fourier terms fit with an ARMA(1,1)(12,0)";
proc arima data=pm_t_all;
   identify var=pm2 crosscor=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 logt);
   estimate input=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 logt) p=(1)(12) q=(1);
   forecast lead=6 out=model1;
run;
quit;
title;
ods trace off;

data model1;
	merge model1 ts.pm_all;
	t=_n_;
	ape=abs((pm2-forecast)/pm2);
run;

proc means data=model1;
	var ape;
	where t <= 54;
run;

proc sgplot data=model1;
	series x=t y=residual;
	series x=t y=pm2;
	series x=t y=forecast;
run;

/* Model 3: logarithmic trend 3 Fourier terms fit with an ARMA(1,1)(12,0)*/
title "Model3: Logarithmic trend 3 Fourier terms fit with an ARMA(1,1)(12,0)";
proc arima data=ts.pm_t;
   identify var=pm2 crosscor=(s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 logt);
   estimate input=(s1 c1 s2 c2 s3 c3 logt) p=(1,9)(12) q=(1);
run;
quit;
title;

/* linear trend Seasonal dummies fit with an ARMA(1,2)(12,0)*/
title "Model4: Linear trend Seasonal Dummies fit with an ARMA(1,2)(12,0)";
proc arima data=ts.pm_t;
	identify var=pm2 crosscor=(jan feb mar apr may jun jul aug sep oct nov t);
	estimate input=(jan feb mar apr may jun jul aug sep oct nov t) p=(1)(12) q=(1);
run;
quit;
title;

/* logarithmic trend Seasonal dummies fit with an ARMA(1,2)(12,0)*/
title "Model 5 Logarithmic trend Seasonal dummies fit with an ARMA(1,2)(12,0)";
proc arima data=ts.pm_t;
	identify var=pm2 crosscor=(jan feb mar apr may jun jul aug sep oct nov logt);
	estimate input=(jan feb mar apr may jun jul aug sep oct nov logt) p=(1)(12) q=(1);
run;
quit;
