# ***********************************************************************************************
# Title     : シミュレーションデータの作成(GPBoost_algorithm.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/GPBoost_algorithm.R
# ***********************************************************************************************

n <- 5000 # number of samples
m <- 500  # number of groups
# Simulate grouped random effects
group <- rep(1,n) # grouping variable
for(i in 1:m) group[((i-1)*n/m+1):(i*n/m)] <- i
b1 <- rnorm(m)
eps <- b1[group]
# Simulate fixed effects
# Function for non-linear mean. Two covariates of which only one has an effect
f1d <- function(x) 1.7*(1/(1+exp(-(x-0.5)*20))+0.75*x)
X <- matrix(runif(2*n),ncol=2)
f <- f1d(X[,1]) # mean
# Observed data
xi <- sqrt(0.01) * rnorm(n) # simulate error term
y <- f + eps + xi
# Partition data into training and validation data
train_ind <- sample.int(n,size=900)
dtrain <- gpb.Dataset(data = X[train_ind,], label = y[train_ind])
dvalid <- gpb.Dataset.create.valid(dtrain, data = X[-train_ind,], label = y[-train_ind])
valids <- list(test = dvalid)
# Test data for prediction
group_test <- 1:m
x_test <- seq(from=0,to=1,length.out=m)
Xtest <- cbind(x_test,rep(0,length(x_test)))