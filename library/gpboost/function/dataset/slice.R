# ***********************************************************************************************
# Function  : slice
# Objective : gpb.Datasetオブジェクトの情報を取得します
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/getinfo
# ***********************************************************************************************


# ＜概要＞
# - gpb.Dataset元のgpb.Datasetオブジェクトの指定された行を含む新しいを取得します


# ＜構文＞
# slice(dataset, idxset, ...)


# ＜引数＞
# dataset: gpb.Datasetオブジェクト


# ＜目次＞
# 0 準備
# 1 gpb.Datasetの作成
# 2 データセットのスライス


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(agaricus.train, package = "gpboost")


# データ確認
agaricus.train %>% class()
agaricus.train %>% glimpse()


# 1 gpb.Datasetの作成 ------------------------------------------------------------

# データセット作成
train <- agaricus.train
dtrain <- gpb.Dataset(train$data, label = train$label)

# 確認
dtrain %>% print()
dtrain %>% names()


# 2 データセットのスライス ------------------------------------------------------------

# スライス
# --- スライス後にデータセットを再定義
dsub <-
  dtrain %>%
    slice(seq_len(42L)) %>%
    gpb.Dataset.construct()

# データ確認
labels <- getinfo(dsub, "label")
labels %>% length()