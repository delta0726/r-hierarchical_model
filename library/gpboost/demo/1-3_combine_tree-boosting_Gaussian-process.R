# ***********************************************************************************************
# Title     : GPBoost OOS algorithm: GP parameters estimated out-of-sample
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/26
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/GPBoost_algorithm.R
# ***********************************************************************************************


# ＜目次＞
# 0 準備
# 1 モデル構築
# 2 クロスバリデーション
# 3 メイン学習


# 0 準備 ---------------------------------------------------------------------------------

# ワークスペースクリア
rm(list = ls())

# ライブラリ
library(tidyverse)
library(magrittr)
library(gpboost)


# データ準備
source("library/gpboost/demo/func/generate_data_41.R")

# 変数確認
ls()


# 1 モデル構築 ----------------------------------------------------------------------------

# モデル構築
# --- 訓練データのグループを抽出
gp_model <- GPModel(group_data = group)

# データオブジェクト作成
dataset <- gpb.Dataset(X, label = y)


# 2 クロスバリデーション ------------------------------------------------------------------

# ハイパーパラメータ設定
params <-
  list(learning_rate = 0.05,
       max_depth = 6,
       min_data_in_leaf = 5,
       objective = "regression_l2")

# クロスバリデーション
# --- 最良イテレーション(best_iter)を決定
# --- OOSにフィッティング（fit_GP_cov_pars_OOS = TRUE）
cvbst <-
  gpb.cv(params = params,
         data = dataset,
         gp_model = gp_model,
         nrounds = 100,
         nfold = 4,
         eval = "l2",
         early_stopping_rounds = 5,
         fit_GP_cov_pars_OOS = TRUE)

# 最良イテレーション
cvbst$best_iter


# 3 メイン学習 ------------------------------------------------------------------

# モデルサマリー
# --- モデル開始前の確認
gp_model %>% summary()

# CV結果を用いて学習
bst <-
  gpb.train(data = dataset,
            gp_model = gp_model,
            nrounds = cvbst$best_iter,
            learning_rate = 0.05,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 0,
            train_gp_model_cov_pars = FALSE)

# モデルサマリー
# --- モデル実行後の確認
# --- 変化なし
gp_model %>% summary()


