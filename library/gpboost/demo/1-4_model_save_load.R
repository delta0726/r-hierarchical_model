# ***********************************************************************************************
# Title     : モデル(ブースター)の保存/ロード
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/26
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/GPBoost_algorithm.R
# ***********************************************************************************************


# ＜概要＞
# - gpb.BoosterオブジェクトをJSON形式で保存/ロードする


# ＜目次＞
# 0 準備
# 1 ベースモデルの作成
# 2 モデルの保存＆ロード
# 3 結果比較


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


# 1 ベースモデルの作成 ----------------------------------------------------------------------

# モデル構築
# --- 訓練データのグループを抽出
gp_model <- GPModel(group_data = group, likelihood = "gaussian")

# 学習
bst <-
  gpboost(data = X,
          label = y,
          gp_model = gp_model,
          nrounds = 15,
          learning_rate = 0.05,
          max_depth = 6,
          min_data_in_leaf = 5,
          objective = "regression_l2",
          verbose = 0)

# 予測
pred <-
  bst %>%
    predict(data = Xtest, group_data_pred = group_test, predict_var= TRUE)


# 2 モデルの保存＆ロード -----------------------------------------------------------------

# モデル保存
bst %>% gpb.save(filename = "library/gpboost/demo/model/test_saved_model.json")

# モデルロード
bst_loaded <- gpb.load(filename = "library/gpboost/demo/model/test_saved_model.json")


# 3 結果比較 -----------------------------------------------------------------

# 予測
# --- ロードモデルを使用
pred_loaded <-
  bst_loaded %>%
    predict(data = Xtest, group_data_pred = group_test, predict_var= TRUE)

# 結果比較
sum(abs(pred$fixed_effect - pred_loaded$fixed_effect))
sum(abs(pred$random_effect_mean - pred_loaded$random_effect_mean))
sum(abs(pred$random_effect_cov - pred_loaded$random_effect_cov))
