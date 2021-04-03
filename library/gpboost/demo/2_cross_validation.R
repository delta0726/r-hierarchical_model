# ***********************************************************************************************
# Title     : クロスバリデーション
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/cross_validation.R
# ***********************************************************************************************


# ＜概要＞
# -


# ＜目次＞
# 0 準備
# 1 ツリーブースティングでクロスバリデーション
# 2 カスタム損失関数を用いたクロスバリデーション
# 3 ツリーブースティングとランダム効果モデルの融合-1
# 4 ツリーブースティングとランダム効果モデルの融合-2


# 0 準備 ---------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(magrittr)
library(gpboost)


# データ準備
source("library/gpboost/demo/func/data_cross_validation.R")

# 変数確認
ls()

# クラス確認
data %>% class()
data %>% names()


# データ確認
data.frame(data$X, data$y) %>%
  set_colnames(c("X1", "X2", "y")) %>%
  as_tibble()

# パラメータ
n %>% print()

# 関数
f1d
sim_data



# 1 ツリーブースティングでクロスバリデーション ---------------------------------------

# ＜参考＞
# Metric Parameters
# https://lightgbm.readthedocs.io/en/latest/Parameters.html#metric


# データオブジェクト作成
dtrain <- data$X[1:n,] %>% gpb.Dataset(label = data$y[1:n])

# パラメータ設定
params <-
  list(learning_rate = 0.1,
       max_depth = 6,
       min_data_in_leaf = 5,
       objective = "regression_l2")


# ******** eval = "l2" ********

# クロスバリデーション
# --- eval = "l2"
bst <-
  gpb.cv(params = params,
         data = dtrain,
         nrounds = 100,
         nfold = 10,
         eval = "l2",
         early_stopping_rounds = 5)

# イテレーション
bst$record_evals$valid$l2$eval

# 最適イテレーション
bst$best_iter

# 最良スコア
bst$best_score


# ******** eval = "l1" ********

# クロスバリデーション
# --- eval = "l1"
bst <-
  gpb.cv(params = params,
         data = dtrain,
         nrounds = 100,
         nfold = 10,
         eval = "l1",
         early_stopping_rounds = 5)

# 最適イテレーション
bst$best_iter

# 最良スコア
bst$best_score


# 2 カスタム損失関数を用いたクロスバリデーション ---------------------------------------------

# データオブジェクト作成
dtrain <- gpb.Dataset(data$X[1:n,], label = data$y[1:n])

# パラメータ設定
params <-
  list(learning_rate = 0.1,
       max_depth = 6,
       min_data_in_leaf = 5,
       objective = "regression_l2")

# 関数定義
# --- カスタム損失関数
quantile_loss <- function(preds, dtrain) {
  alpha <- 0.95
  labels <- getinfo(dtrain, "label")
  y_diff <- as.numeric(labels - preds)
  dummy <- ifelse(y_diff<0,1,0)
  quantloss <- mean((alpha - dummy) * y_diff)
  return(list(name = "quant_loss", value = quantloss, higher_better = FALSE))
}

# クロスバリデーション
# --- カスタム損失関数を使用
bst <- gpb.cv(params = params,
              data = dtrain,
              nrounds = 100,
              nfold = 10,
              eval = quantile_loss,
              early_stopping_rounds = 5)

# 最適イテレーション
bst$best_iter

# 最良スコア
bst$best_score


# 3 ツリーブースティングとランダム効果モデルの融合-1 ---------------------------------------------

# データ準備
source("library/gpboost/demo/func/generate_data_22.R")

# モデル定義
# --- ランダム効果モデル
gp_model <- GPModel(group_data = group)

# データオブジェクト作成
dtrain <- gpb.Dataset(X, label = y)

# ハイパーパラメータ
params <-
  list(learning_rate = 0.05,
       max_depth = 6,
       min_data_in_leaf = 5,
       objective = "regression_l2",
       leaves_newton_update = FALSE)

# クロスバリデーション
# --- use_gp_model_for_validation = FALSE
bst <-
  gpb.cv(params = params,
         data = dtrain,
         gp_model = gp_model,
         nrounds = 100,
         nfold = 10,
         eval = "l2",
         early_stopping_rounds = 5)

# 最適イテレーション
bst$best_iter

# 最良スコア
bst$best_score


# 4 ツリーブースティングとランダム効果モデルの融合-2 ---------------------------------------------

# データ準備
source("library/gpboost/demo/func/generate_data_22.R")

# モデル定義
# --- ランダム効果モデル
gp_model <- GPModel(group_data = group)

# ハイパーパラメータ
params <-
  list(learning_rate = 0.05,
       max_depth = 6,
       min_data_in_leaf = 5,
       objective = "regression_l2",
       leaves_newton_update = FALSE)

# クロスバリデーション
# --- use_gp_model_for_validation = TRUE（デフォルト）
bst <-
  gpb.cv(params = params,
         data = dtrain,
         gp_model = gp_model,
         use_gp_model_for_validation = TRUE,
         nrounds = 100,
         nfold = 10,
         eval = "l2",
         early_stopping_rounds = 5)

# 最適イテレーション
bst$best_iter

# 最良スコア
bst$best_score
