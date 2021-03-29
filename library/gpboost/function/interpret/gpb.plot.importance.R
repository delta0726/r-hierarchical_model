# ***********************************************************************************************
# Function  : gpb.plot.importance
# Objective : 計算された特徴の重要度を棒グラフとしてプロット
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.plot.importance
# ***********************************************************************************************


# ＜概要＞
# - 計算された特徴の重要度(ゲイン/カバー/頻度)を棒グラフとしてプロット


# ＜構文＞
# gpb.plot.importance(tree_imp, top_n = 10L, measure = "Gain",
#   left_margin = 10L, cex = NULL)


# ＜引数＞
# - tree_imp    ：gpb.importance()から出力されたdata.tableオブジェクト
# - top_n       ：出力する上位N個の特徴量
# - measure     ：出力項目を指定（Grain/Cover/Frequency）
# - left_margin ：
# - cex         ：


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

# データ
train <- agaricus.train
dtrain <- train$data %>% gpb.Dataset(label = train$label)


# 2 モデル構築 -------------------------------------------------------------------

# パラメータ設定
params <-
  list(objective = "binary",
       learning_rate = 0.1,
       min_data_in_leaf = 1L,
       min_sum_hessian_in_leaf = 1.0)

# モデル構築
model <-
  gpb.train(params = params,
            data = dtrain,
            nrounds = 5L)


# 3 変数重要度分析 -----------------------------------------------------------------

# 変数重要度の計算
tree_imp <- model %>% gpb.importance(percentage = TRUE)

# 確認
tree_imp %>% print()
tree_imp %>% class()

# プロット作成
tree_imp %>%
  gpb.plot.importance(top_n = 5L, measure = "Gain")
