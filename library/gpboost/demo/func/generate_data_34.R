# ***********************************************************************************************
# Title     : シミュレーションデータの作成(linear_Gaussian_process_mixed_effects_models.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/linear_Gaussian_process_mixed_effects_models.R
# ***********************************************************************************************


# Simulate data
n <- 200 # number of samples
m <- 25 # number of categories / levels for grouping variable
group <- rep(1,n) # grouping variable
for(i in 1:m) group[((i-1)*n/m+1):(i*n/m)] <- i
set.seed(1)
coords <- cbind(runif(n),runif(n)) # locations (=features) for Gaussian process
sigma2_1 <- 1^2 # random effect variance
sigma2_2 <- 1^2 # marginal variance of GP
rho <- 0.1 # range parameter
sigma2 <- 0.5^2 # error variance
# incidence matrix relating grouped random effects to samples
Z1 <- model.matrix(rep(1,n) ~ factor(group) - 1)
set.seed(156)
b1 <- sqrt(sigma2_1) * rnorm(m) # simulate random effects
D <- as.matrix(dist(coords))
Sigma <- sigma2_2*exp(-D/rho)+diag(1E-20,n)
C <- t(chol(Sigma))
b_2 <- rnorm(n) # simulate random effect
eps <- Z1 %*% b1 + C %*% b_2
xi <- sqrt(sigma2) * rnorm(n) # simulate error term
y <- eps + xi