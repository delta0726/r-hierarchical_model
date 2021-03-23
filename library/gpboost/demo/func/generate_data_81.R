# ***********************************************************************************************
# Title     : シミュレーションデータの作成
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://glennwilliams.me/r4psych/mixed-effects-models.html
# ***********************************************************************************************



# Non-linear prior mean function for simulation in examples below
f1d <- function(x) 1/(1+exp(-(x-0.5)*10)) - 0.5
sim_non_lin_f <- function(n){
  X <- matrix(runif(2*n),ncol=2)
  f <- f1d(X[,1])
  return(list(X=X,f=f))
}

# --------------------Simulate data grouped random effects data----------------
n <- 1000 # number of samples
m <- 100 # number of groups
set.seed(1)

# Simulate random and fixed effects
group <- rep(1,n) # grouping variable
for(i in 1:m) group[((i-1)*n/m+1):(i*n/m)] <- i

b1 <- sqrt(0.5) * rnorm(m)
eps <- b1[group]
eps <- eps - mean(eps)
sim_data <- sim_non_lin_f(n=n)
f <- sim_data$f
X <- sim_data$X

# Simulate response variable
probs <- pnorm(f+eps)
y <- as.numeric(runif(n) < probs)
