# ***********************************************************************************************
# Title     : Parameter Estimated out-of-sample
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/26
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/GPBoost_algorithm.R
# ***********************************************************************************************


# ＜概要＞
# - 学習データと検証データを別々に指定する
#   --- 今回は検証データを乱数から生成している


# ＜学習＞
# 0 準備
# 1 モデリング
# 2 予測


# 0 準備 ---------------------------------------------------------------------------------

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

# 学習
bst <-
  gpboost(data = X,
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

# データの作成
# --- 予測用
set.seed(1)
ntest <- 5
Xtest <- matrix(runif(2 * ntest), ncol = 2)

# 座標データ
# --- 予測用
coords_test <- cbind(runif(ntest), runif(ntest)) / 10

# 確認
Xtest %>% print()
coords_test %>% print()

# 予測
pred <-
  bst %>%
    predict(data = Xtest, gp_coords_pred = coords_test, predict_cov_mat = TRUE)

# 結果確認
# --- Predicted (posterior) mean of GP
# --- Predicted (posterior) covariance matrix of GP
# --- Predicted fixed effect from tree ensemble
pred$random_effect_mean
pred$random_effect_cov
pred$fixed_effect
