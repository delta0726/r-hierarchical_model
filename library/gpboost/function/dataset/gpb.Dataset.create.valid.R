# ***********************************************************************************************
# Function  : gpb.Dataset.create.valid
# Objective : トレーニングデータに従って検証データを作成
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.Dataset.create.valid
# ***********************************************************************************************


# ＜概要＞
# - トレーニングデータに従って検証データを作成


# ＜構文＞
# gpb.Dataset.create.valid(dataset, data, info = list(), ...)


# ＜引数＞
# - dataset： gpb.Datasetオブジェクト（訓練データ）
# - data   ： matrix型又はdgCMatrix型(疎データ)
#  -info   ： gpb.Datasetオブジェクトの情報リスト


# ＜目次＞
# 0 準備
# 1 データセットを作成


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(agaricus.train, package = "gpboost")
data(agaricus.test, package = "gpboost")


# 1 データセットを作成 --------------------------------------------------------------

# 訓練データの作成
train <- agaricus.train
dtrain <- train$data %>% gpb.Dataset(label = train$label)

# 検証データの作成
# --- 訓練データの設定に基づいて作成
test <- agaricus.test
dtest <-dtrain %>% gpb.Dataset.create.valid(test$data, label = test$label)

# 確認
dtest %>% print()
