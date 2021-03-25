# ***********************************************************************************************
# Title     : シミュレーションデータの作成(linear_Gaussian_process_mixed_effects_models.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/linear_Gaussian_process_mixed_effects_models.R
# ***********************************************************************************************



# --------------------Simulate data----------------
n <- 1000 # number of samples
# Simulate single level grouped random effects data
m <- 100 # number of categories / levels for grouping variable
group <- rep(1,n) # grouping variable
for(i in 1:m) group[((i-1)*n/m+1):(i*n/m)] <- i
sigma2_1 <- 1^2 # random effect variance
sigma2 <- 0.5^2 # error variance
set.seed(1)
b <- sqrt(sigma2_1) * rnorm(m) # simulate random effects
eps <- b[group]
xi <- sqrt(sigma2) * rnorm(n) # simulate error term
y <- eps + xi # observed data for single level grouped random effects model
# Simulate data for linear mixed effects model
X <- cbind(rep(1,n),runif(n)) # design matrix / covariate data for fixed effects
beta <- c(3,3) # regression coefficients
y_lin <- eps + xi + X%*%beta # add fixed effects to observed data
# Simulate data for two crossed random effects and a random slope
x <- runif(n) # covariate data for random slope
n_obs_gr <- n/m # number of samples per group
group_crossed <- rep(1,n) # grouping variable for second crossed random effect
for(i in 1:m) group_crossed[(1:n_obs_gr)+n_obs_gr*(i-1)] <- 1:n_obs_gr
sigma2_2 <- 0.5^2 # variance of second random effect
sigma2_3 <- 0.75^2 # variance of random slope for first random effect
b_crossed <- sqrt(sigma2_2) * rnorm(n_obs_gr) # second random effect
b_random_slope <- sqrt(sigma2_3) * rnorm(m) # simulate random effects
y_crossed_random_slope <- b[group] + # observed data = sum of all random effects
  b_crossed[group_crossed] + x * b_random_slope[group] + xi
# Simulate data for two nested random effects
m_nested <- 200 # number of categories / levels for the second nested grouping variable
group_nested <- rep(1,n)  # grouping variable for nested lower level random effects
for(i in 1:m_nested) group_nested[((i-1)*n/m_nested+1):(i*n/m_nested)] <- i
b_nested <- 1. * rnorm(m_nested) # nested lower level random effects
y_nested <- b[group] + b_nested[group_nested] + xi # observed data

