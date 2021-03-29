# ***********************************************************************************************
# Function  : gpb.importance
# Objective : 変数重要度指標(Gain/Cover/Frequency)を計算する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.importance
# ***********************************************************************************************


# ＜概要＞
# - 変数重要度指標(Gain/Cover/Frequency)を計算する


# ＜構文＞
# gpb.importance(model, percentage = TRUE)


# ＜引数＞
# - percentage： パーセンテージで出力（デフォルト=TRUE）


# ＜出力＞
# - 特徴量ごとにGain/Cover/Frequencyが出力される
# - data.tableオブジェクトで出力される


# ＜目次＞
# 0 準備
# 1 データ確認
# 2 モデル構築
# 3 変数重要度分析


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(agaricus.train, package = "gpboost")


# 1 データ確認 -------------------------------------------------------------------

# データ確認
train <- agaricus.train
train %>% names()

# データセット作成
dtrain <- train$data %>% gpb.Dataset(label = train$label)

# 確認
dtrain %>% print()
dtrain %>% names()


# 2 モデル構築 -------------------------------------------------------------------

# パラメータ設定
params <-
  list(objective = "binary",
       learning_rate = 0.1,
       max_depth = -1L,
       min_data_in_leaf = 1L,
       min_sum_hessian_in_leaf = 1.0)

# モデル構築
model <-
  gpb.train(params = params,
            data = dtrain,
            nrounds = 5L)


# 3 変数重要度分析 -----------------------------------------------------------------

# 変数重要度の計算
tree_imp1 <- model %>% gpb.importance(percentage = TRUE)
tree_imp2 <- model %>% gpb.importance(percentage = FALSE)

# クラス確認
tree_imp1 %>% class()

# 確認
tree_imp1 %>% print()
tree_imp2 %>% print()
