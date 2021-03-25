# ***********************************************************************************************
# Title     : シミュレーションデータの作成(linear_Gaussian_process_mixed_effects_models.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/linear_Gaussian_process_mixed_effects_models.R
# ***********************************************************************************************


# Simulate data
n <- 200 # number of samples per cluster
set.seed(1)
coords <- cbind(runif(n),runif(n)) # locations (=features) for Gaussian process
coords <- rbind(coords,coords) # locations for second observation of GP (same locations)
# indices that indicate the GP sample to which an observations belong
cluster_ids <- c(rep(1,n),rep(2,n))
sigma2_1 <- 1^2 # marginal variance of GP
rho <- 0.1 # range parameter
sigma2 <- 0.5^2 # error variance
D <- as.matrix(dist(coords[1:n,]))
Sigma <- sigma2_1*exp(-D/rho)+diag(1E-20,n)
C <- t(chol(Sigma))
b_1 <- rnorm(2 * n) # simulate random effect
eps <- c(C %*% b_1[1:n], C %*% b_1[1:n + n])
xi <- sqrt(sigma2) * rnorm(2 * n) # simulate error term
y <- eps + xi
