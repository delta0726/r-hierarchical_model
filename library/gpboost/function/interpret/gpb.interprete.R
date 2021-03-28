# ***********************************************************************************************
# Function  : gpb.interprete
# Objective : rawscore予測寄与度のコンポーネントを計算する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.interprete
# ***********************************************************************************************


# ＜概要＞
# - rawscore予測の特徴寄与コンポーネントを計算する


# ＜構文＞
# gpb.interprete(model, data, idxset, num_iteration = NULL)


# ＜目次＞
# 0 準備
# 1 データ確認
# 2 モデル構築
# 3 予測寄与度の取得


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

# 訓練データ
train <- agaricus.train
dtrain <- gpb.Dataset(train$data, label = train$label)

# 情報の設定
setinfo(dtrain, "init_score", rep(Logit(mean(train$label)), length(train$label)))

# 検証データ
test <- agaricus.test


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
            nrounds = 3L)


# 3 予測寄与度の取得 -----------------------------------------------------------------

# 予測寄与度の計算
tree_interpretation <- gpb.interprete(model, test$data, 1L:5L)

# データ確認
tree_interpretation %>% print()
tree_interpretation %>% glimpse()










