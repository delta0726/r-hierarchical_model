# ***********************************************************************************************
# Function  : gpb.Dataset.set.categorical
# Objective : gpb.Datasetオブジェクトにカテゴリ情報(グループ情報)を設定する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.Dataset.set.categorical
# ***********************************************************************************************


# ＜概要＞
# - gpb.Datasetオブジェクトにカテゴリ情報(グループ情報)を設定する


# ＜構文＞
# gpb.Dataset.set.categorical(dataset, categorical_feature)


# ＜引数＞
# - dataset: gpb.Datasetオブジェクト
# - categorical_feature:


# ＜目次＞
# 0 準備
# 1 データセットを作成
# 2 カテゴリ情報を設定


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(agaricus.train, package = "gpboost")


# 1 データセットを作成 --------------------------------------------------------------

# データセットの作成
train <- agaricus.train
dtrain <- gpb.Dataset(train$data, label = train$label)

# 確認
# --- categorical_feature: NULL
dtrain


# 2 カテゴリ情報を設定 --------------------------------------------------------------

# 明示的にデータセットを作成
gpb.Dataset.set.categorical(dtrain, 1L:2L)

# 確認
# --- categorical_feature: 1 2
dtrain
