# ***********************************************************************************************
# Function  : gpb.plot.interpretation
# Objective : 予測寄与度(Breakdown)を棒グラフとしてプロットする
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.plot.interpretation
# ***********************************************************************************************


# ＜概要＞
# - 予測寄与度(Breakdown)を棒グラフとしてプロットする
# - LIME分析


# ＜構文＞
# gpb.plot.interpretation(tree_interpretation_dt, top_n = 10L, cols = 1L,
#   left_margin = 10L, cex = NULL)


# ＜引数＞
# - tree_interpretation_dt ：gpb.interprete()から出力されたdata.tableオブジェクト
# - top_n                  ：出力する上位N個の特徴量
# - measure                ：出力項目を指定（Grain/Cover/Frequency）
# - left_margin            ：
# - cex                    ：


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
data(agaricus.test, package = "gpboost")

# 関数定義
# --- ロジット関数
Logit <- function(x) log(x / (1.0 - x))


# 1 データ確認 -------------------------------------------------------------------

# データセット作成
labels <- agaricus.train$label
dtrain <- gpb.Dataset(agaricus.train$data, label = labels)


# データ確認
labels %>% mean() %>% Logit() %>% rep(length(labels))

# 追加設定
# --- init_scoreの設定
setinfo(dtrain, "init_score", rep(Logit(mean(labels)), length(labels)))


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

# 予測寄与度の計算
tree_interpretation <-
  gpb.interprete(model = model,
                 data = agaricus.test$data,
                 idxset = 1L:5L)

# 確認
tree_interpretation %>% glimpse()
tree_interpretation %>% print()
tree_interpretation %>% class()

# プロット作成
tree_interpretation[[1L]] %>%
  gpb.plot.interpretation(top_n = 3L)
