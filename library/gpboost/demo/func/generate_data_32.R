# ***********************************************************************************************
# Title     : シミュレーションデータの作成(linear_Gaussian_process_mixed_effects_models.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/linear_Gaussian_process_mixed_effects_models.R
# ***********************************************************************************************


n <- 200 # number of samples
set.seed(2)
coords <- cbind(runif(n),runif(n)) # locations (=features) for Gaussian process
sigma2_1 <- 1^2 # marginal variance of GP
rho <- 0.1 # range parameter
sigma2 <- 0.5^2 # error variance
D <- as.matrix(dist(coords))
Sigma <- sigma2_1*exp(-D/rho)+diag(1E-20,n)
# Sigma <- sigma2_1*exp(-(D/rho)^2)+diag(1E-20,n)# different covariance function
C <- t(chol(Sigma))
b_1 <- rnorm(n) # simulate random effect
xi <- sqrt(sigma2) * rnorm(n) # simulate error term
y <- C %*% b_1 + xi
# Add linear regression term
X <- cbind(rep(1,n),runif(n)) # design matrix / covariate data for fixed effect
beta <- c(3,3) # regression coefficients
y_lin <- C %*% b_1 + xi + X%*%beta # add fixed effect to observed data
# Simulate spatially varying coefficient (random coefficient) model data
Z_SVC <- cbind(runif(n),runif(n)) # covariate data for random coeffients
colnames(Z_SVC) <- c("var1","var2")
# simulate SVC random effect
b_2 <- rnorm(n)
b_3 <- rnorm(n)
# Note: for simplicity, we assume that all GPs have the same covariance parameters
y_svc <- C %*% b_1 + Z_SVC[,1] * C %*% b_2 + Z_SVC[,2] * C %*% b_3 + xi