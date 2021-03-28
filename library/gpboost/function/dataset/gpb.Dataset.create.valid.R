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
# - dataset: gpb.Datasetオブジェクト（訓練データ）
# - data: matrix型又はdgCMatrix型(疎データ)


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

# データセットの作成
# --- 訓練データ
train <- agaricus.train
dtrain <- gpb.Dataset(train$data, label = train$label)

# データセットの作成
# --- テストデータ
test <- agaricus.test
dtest <- gpb.Dataset.create.valid(dtrain, test$data, label = test$label)


# 確認
dtest %>% print()
