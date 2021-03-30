# ***********************************************************************************************
# Function  : gpb.get.eval.result
# Objective : gpb.Boosterオブジェクトから要素を抽出する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.get.eval.result
# ***********************************************************************************************


# ＜概要＞
# - gpb.Boosterオブジェクトから要素を抽出する


# ＜構文＞
# gpb.get.eval.result(booster, data_name, eval_name, iters = NULL, is_err = FALSE)


# ＜引数＞
# - booster     ：gpb.Boosterオブジェクト
# - data_name   ：データカテゴリの名前(names()で出力される項目)
# - eval_name   ：出力項目の名前
# - iters       ：評価結果を取得する反復の整数ベクトル（NULLの場合、すべての反復の評価結果）
# - is_err      ：TRUEは、代わりに評価エラーを返す


# ＜目次＞
# 0 準備
# 1 モデル構築
# 2 データ抽出
# 3 gpb.Boosterの中身


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)
library(Hmisc)

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

# データ確認
model %>% glimpse()
model %>% names()

# 抽出データの名前を確認
model$record_evals %>% names()
model$record_evals[["test"]] %>% names()

# データ抽出
model %>%
  gpb.get.eval.result( "test", "l2")

# リストツリーで確認
model$record_evals %>% list.tree(5)


# 3 gpb.Boosterの中身 -------------------------------------------------------------------------

# クラス確認
model %>% class()

# 要素確認
# --- save以降はメソッド
model %>% names()

# 出力確認
model$raw
model$record_evals
model$params
model$best_score
