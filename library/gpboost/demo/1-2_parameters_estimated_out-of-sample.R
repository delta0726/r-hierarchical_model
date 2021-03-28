# ***********************************************************************************************
# Title     : Combine tree-boosting and Gaussian process model
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/26
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/GPBoost_algorithm.R
# ***********************************************************************************************


# ＜学習＞
# 0 準備
# 1 モデリング
# 2 予測


# 0 準備 ---------------------------------------------------------------------------------

# ワークスペースクリア
rm(list = ls())

# ライブラリ
library(tidyverse)
library(magrittr)
library(gpboost)


# データ準備
source("library/gpboost/demo/func/generate_data_42.R")

# 変数確認
ls()


# 1 モデリング -------------------------------------------------------------------------

# モデル構築
gp_model <- GPModel(gp_coords = coords, cov_function = "exponential")


# パラメータの設定
# --- The default optimizer for covariance parameters is Fisher scoring.
# --- This can be changed to e.g. Nesterov accelerated gradient descent as follows:
# re_params <- list(optimizer_cov = "gradient_descent", lr_cov = 0.05,
#                   use_nesterov_acc = TRUE, acc_rate_cov = 0.5)
# gp_model$set_optim_params(params=re_params)


# 学習
bst <- gpboost(data = X,
               label = y,
               gp_model = gp_model,
               nrounds = 8,
               learning_rate = 0.1,
               max_depth = 6,
               min_data_in_leaf = 5,
               objective = "regression_l2",
               verbose = 0)

# サマリー
gp_model %>% summary()


# 2 予測 -------------------------------------------------------------------------

# Make predictions
set.seed(1)
ntest <- 5
Xtest <- matrix(runif(2 * ntest), ncol = 2)

# prediction locations (=features) for Gaussian process
coords_test <- cbind(runif(ntest), runif(ntest)) / 10


# 予測
pred <-
  bst %>%
    predict(data = Xtest, gp_coords_pred = coords_test, predict_cov_mat = TRUE)


# 結果確認
print("Predicted (posterior) mean of GP")
pred$random_effect_mean
print("Predicted (posterior) covariance matrix of GP")
pred$random_effect_cov
print("Predicted fixed effect from tree ensemble")
pred$fixed_effect

