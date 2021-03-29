# ***********************************************************************************************
# Function  : gpb.Dataset.set.reference
# Objective : 検証データを使用する場合に、トレーニングデータへの参照を設定する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.Dataset.set.reference
# ***********************************************************************************************


# ＜概要＞
# - 検証データを使用する場合に、トレーニングデータへの参照を設定する


# ＜構文＞
# gpb.Dataset.set.reference(dataset, reference)


# ＜引数＞
# - dataset: gpb.Datasetオブジェクト
# - reference:


# ＜目次＞
# 0 準備
# 1 データセットを作成
# 2 データ設定の参照


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
dtest <- gpb.Dataset(test$data, test = test$label)

# 確認
# --- reference: NULL
dtest


# 2 データ設定の参照 --------------------------------------------------------------

# 明示的にデータセットを作成
gpb.Dataset.set.reference(dtest, dtrain)

# 確認
# --- reference: gpb.Dataset, R6
dtest