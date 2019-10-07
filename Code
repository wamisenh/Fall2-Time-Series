libname ts "Z:/Desktop/IAA/Time Series 2";

*ADF test for stationarity about the season;
proc arima data=ts.pm_t plots=all;
	identify var=pm2 stationarity=(adf=2 dlag=12); 
run;
quit;
*conclusion: stationary about the season, so we will model the season;

*extract month from date column to use for dummy vars;
data pm_t;
set ts.pm_t;
month = month(date);
run;

*Fit dummy vars;
data season;
set pm_t;
if month=1 then seas1=1; else seas1=0;
if month=2 then seas2=1; else seas2=0;
if month=3 then seas3=1; else seas3=0;
if month=4 then seas4=1; else seas4=0;
if month=5 then seas5=1; else seas5=0;
if month=6 then seas6=1; else seas6=0;
if month=7 then seas7=1; else seas7=0;
if month=8 then seas8=1; else seas8=0;
if month=9 then seas9=1; else seas9=0;
if month=10 then seas10=1; else seas10=0; 
if month=11 then seas11=1; else seas11=0; 
run;
      
*check fit of dummy variables;
proc arima data=season plots=all;
identify var=pm2 crosscorr=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11); 
estimate input=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11);
forecast back=12 lead=12 out=season_adj;
run;
quit;

*examine trend stationarity;
proc arima data=work.season_adj plot=all;
    identify var=residual nlag=10 stationarity=(adf=2);
run;
Quit;

*conclusion: stationary about the trend; 


*fit trend line for the linear trend;

proc arima data=season plot=all;
identify var=pm2 crosscorr=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 date) stationarity=(adf=2) ; 
estimate input=(seas1 seas2 seas3 seas4 seas5 seas6 seas7 seas8 seas9 seas10 seas11 date);
forecast back=12 lead=12 out=final;
run;
quit;

/*run selection criteria to determine best ARMA model */
*MINIC criteria;
proc arima data=final plot(unpack); 
identify var=residual nlag=12 minic P=(0:12) Q=(0:12);
run; 
quit;

*SCAN selection;
proc arima data=final plot(unpack); 
identify var=residual nlag=12 scan P=(0:12) Q=(0:12);
run; 
quit;

*ESACF selection;
proc arima data=final plot(unpack); 
identify var=residual nlag=12 esacf P=(0:12) Q=(0:12);
run; 
quit;
 
