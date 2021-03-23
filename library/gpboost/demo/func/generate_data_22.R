# ***********************************************************************************************
# Title     : シミュレーションデータの作成(cross_validation.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/cross_validation.R
# ***********************************************************************************************


# Simulate data
f1d <- function(x) 1.7*(1/(1+exp(-(x-0.5)*20))+0.75*x)
set.seed(1)
n <- 1000 # number of samples
X <- matrix(runif(2*n),ncol=2)
y <- f1d(X[,1]) # mean
# Add grouped random effects
m <- 25 # number of categories / levels for grouping variable
group <- rep(1,n) # grouping variable
for(i in 1:m) group[((i-1)*n/m+1):(i*n/m)] <- i
sigma2_1 <- 1^2 # random effect variance
sigma2 <- 0.1^2 # error variance
# incidence matrix relating grouped random effects to samples
Z1 <- model.matrix(rep(1,n) ~ factor(group) - 1)
b1 <- sqrt(sigma2_1) * rnorm(m) # simulate random effects
eps <- Z1 %*% b1
xi <- sqrt(sigma2) * rnorm(n) # simulate error term
y <- y + eps + xi # add random effects and error to data
