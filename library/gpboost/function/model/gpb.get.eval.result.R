# ***********************************************************************************************
# Function  : gpb.get.eval.result
# Objective :
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.get.eval.result
# ***********************************************************************************************


# ＜概要＞
# -


# ＜構文＞
# gpb.get.eval.result(booster, data_name, eval_name, iters = NULL,
#   is_err = FALSE)


# ＜引数＞
# - booster
# - data_name
# - eval_name
# - iters = NULL,
# - is_err = FALSE


# ＜目次＞
# 0 準備
# 1 モデル構築
# 2 データ抽出


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(agaricus.train, package = "gpboost")
data(agaricus.test, package = "gpboost")

# 訓練データの作成
train <- agaricus.train
dtrain <- train$data %>% gpb.Dataset(label = train$label)

# テストデータの作成
test <- agaricus.test
dtest <- dtrain %>% gpb.Dataset.create.valid(test$data, label = test$label)


# 1 モデル構築 -----------------------------------------------------------------------

# パラメータ設定
params <- list(objective = "regression", metric = "l2")

# 検証設定
valids <- list(test = dtest)

# 学習
model <-
  gpb.train(params = params, data = dtrain, nrounds = 5L,
            valids = valids, min_data = 1L, learning_rate = 1.0)


# 2 データ抽出 ------------------------------------------------------------------------

# Examine valid data_name values
model$record_evals %>% names() %>% setdiff("start_iter")

# Examine valid eval_name values for dataset "test"
model$record_evals[["test"]] %>% names()

# Get L2 values for "test" dataset
model %>%
  gpb.get.eval.result( "test", "l2")
