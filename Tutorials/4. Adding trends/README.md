###Setting up the environment

This tutorial will show you how to use exogenous trends into an SFC model, using the model SIMEX as an example.

Before doing any modelling, we need to load the package in the R environment. 
```{r}
library(PKSFC)
```

The, you need to download the attached 'SIMEX.txt' file and save it in the folder of your choice. Make sure to set the working directory where you saved the downloaded file. In command line this looks like this but if you use RStudio, you can use the graphical interface as well (Session>Set Working Directory>Choose Directory)
```{r, eval=FALSE}
setwd("pathToYourDirectory")
```

###Loading the model

The first thig to do is to load the model.
```{r}
simex<-sfc.model("SIMEX.txt",modelName="SIMplest model")
```

We are now ready to simulate the model
```{r}
datasimex<-simulate(simex)
```

Let's plot some results
```{r}
plot(simex$time,datasimex$baseline[,"Yd"],type="l",xlab="",ylab="",lty=2)
lines(simex$time,datasimex$baseline[,"Yd_e"],lty=3)
lines(simex$time,vector(length=length(simex$time))+datasimex$baseline["2010","Yd"])
legend(x=1970,y=50,legend=c("Disposable Income","Expected Disposable Income","Steady State"),
                                               lty=c(2,3,1),bty="n")
```

Let's imagine now, that instead of using a constant value for the propensities to consume you want to introduce a moving value, say a sinusoidal around their initial value. We can generate a new scenario with trended values using the option `trends` as follows:
```{r}
vars= c("alpha1","alpha2")
trend = matrix(0,nrow=66,ncol=2)
trend[,1] = 0.6+0.1*sin(0.1*seq(1:66))
trend[,2] = 0.4+0.1*cos(0.1*seq(1:66))
simex <- sfc.addScenarioTrend(simex,vars=list(vars),trends=list(trend))
```

We can then simulate the baseline and the scenario and look at the corresponding results:
```{r}
datasimex = simulate(simex)
matplot(simex$time,cbind(datasimex$baseline[,c("Yd","Yd_e")],datasimex$scenario_1[,c("Yd","Yd_e")]),type="l",lty=c(2,3,2,3),col=c(1,1,2,2),xlab="",ylab="")
lines(simex$time,vector(length=length(simex$time))+datasimex$baseline["2010","Yd"])
legend(x=1955,y=50,legend=c("Disposable Income","Expected Disposable Income","Steady State","Disposable Income, Sinusoidal scenario","Expected Disposable Income, Sinusoidal scenario"), lty=c(2,3,1,2,3),col=c(1,1,1,2,3),bty="n")
```

Let's say now that you don't quite know the exact value of the tax rate and want to run Monte Carlo simulations around the mean value adding a certain stochasticity around it. In order to do so, we are going to change the `baselineMat` argument of the model and change it for each Monte Carlo simulation. The `baselineMat` is the matrix that contains the values for each parameter and each variable and for each period of simulation. In a way, it is the matrix that will be filled as the simulations run. These are the first 10 lines for the `simex` model:
```{r}
library(knitr)
kable(simex$baselineMat[1:10,c("alpha1","alpha2","G_d","theta")])
```

We can see that in the baseline model, the value of the parameters are constant. Now we can change this by loading the model with a trend. This is done like this
```{r}
simex<-sfc.model("SIMEX.txt",modelName="SIMplest model", trends=trend, trendsVars=vars)
kable(simex$baselineMat[1:10,c("alpha1","alpha2","G_d","theta")])
```

We can see that the first ten values are now changing through time. Let's get back to our exercise and try to change the value of the tax rate (`theta` parameter). We are going to record only the value for disposable income (`Yd`) and expected disposable income (`Yd_e`) for simplicity. We are going to use a normal distribution with mean equal to 0.2 (the standard value of the tax rate in SIMEX) with a standard deviation of 0.025. To extract random value out of a normal distribution, we use the function `rnorm(n,mean=a, sd=b)` where `n` is the number of extractions, `a` is the mean and `b` is the standard deviation.  
```{r}
simex<-sfc.model("SIMEX.txt",modelName="SIMplest model", trends=trend, trendsVars=vars)
MC=30
Yes=matrix(NA,nrow=length(simex$time),ncol=MC)
Yds=matrix(NA,nrow=length(simex$time),ncol=MC)
for(i in 1:MC){
	simex$baselineMat[,"theta"]=rnorm(length(simex$time),mean=0.2,sd=0.025)
	datasimex=simulate(simex)
	Yes[,i]=datasimex$baseline[,"Yd_e"]
	Yds[,i]=datasimex$baseline[,"Yd"]
}
matplot(simex$time,Yds,type='l',lty=2,col=1,xlab="",ylab="")
lines(simex$time,rowMeans(Yds),lwd=2,col=2)
lines(simex$time,rowMeans(Yes),lwd=2,col=3)
grid()
```

The black dashed lines are the values of disposable income for each of the Monte Carlo simulation while the red solid one is the average of disposable income over all the simulation and the green solid one is the average of expected disposable income.