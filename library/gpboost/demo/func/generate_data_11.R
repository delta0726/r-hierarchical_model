# ***********************************************************************************************
# Title     : シミュレーションデータの作成(boosting.R)
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/boosting.R
# ***********************************************************************************************



#--------------------Simulate data----------------

# Function
# --- Generate Non-Linear Data
f1d <- function(x) 1.7 * (1 / (1 + exp( - (x - 0.5) * 20)) + 0.75 * x)

# Vector
x <- seq(from = 0, to = 1, length.out = 200)

# Confirm
#plot(x, f1d(x), type = "l", lwd = 2, col = "red",main = "Mean function")

# Function
# --- Generate Data
sim_data <- function(n){
  X = matrix(runif(2 * n), ncol = 2)
  # mean function plus noise
  y = f1d(X[,1]) + rnorm(n, sd = 0.1)
  return(list(X = X, y = y))
}

# Simulate data
n <- 1000
set.seed(1)
data <- sim_data(2 * n)
Xtrain <- data$X[1:n,]
ytrain <- data$y[1:n]
Xtest <- data$X[1:n + n,]
ytest <- data$y[1:n + n]
