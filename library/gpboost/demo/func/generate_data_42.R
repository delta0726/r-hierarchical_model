# ***********************************************************************************************
# Title     : シミュレーションデータの作成(GPBoost_algorithm.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/GPBoost_algorithm.R
# ***********************************************************************************************


# --------------------Simulate data----------------
# Function for non-linear mean. Two covariates of which only one has an effect
f1d <- function(x) 1.7*(1/(1+exp(-(x-0.5)*20))+0.75*x)
set.seed(2)
n <- 200 # number of samples
X <- matrix(runif(2*n),ncol=2)
y <- f1d(X[,1]) # mean
# Add Gaussian process
sigma2_1 <- 1^2 # marginal variance of GP
rho <- 0.1 # range parameter
sigma2 <- 0.1^2 # error variance
coords <- cbind(runif(n),runif(n)) # locations (=features) for Gaussian process
D <- as.matrix(dist(coords))
Sigma <- sigma2_1*exp(-D/rho)+diag(1E-20,n)
C <- t(chol(Sigma))
b_1 <- rnorm(n) # simulate random effect
eps <- C %*% b_1
xi <- sqrt(sigma2) * rnorm(n) # simulate error term
y <- y + eps + xi # add random effects and error to data
