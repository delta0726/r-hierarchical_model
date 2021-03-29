# ***********************************************************************************************
# Function  : gpb.Dataset
# Objective : gpb.Datasetオブジェクトを作成する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.Dataset
# ***********************************************************************************************


# ＜概要＞
# - {gpboost}で使用するgpb.Datasetオブジェクトを作成


# ＜構文＞
# gpb.Dataset(data, params = list(), reference = NULL, colnames = NULL,
#   categorical_feature = NULL, free_raw_data = FALSE, info = list(), ...)


# ＜引数＞
# - matrix              ：matrix型又はdgCMatrix型(疎データ)
# - params              ：パラメータのリスト
# - reference           ：
# - colnames            ：
# - categorical_feature ：
# - free_raw_data       ：構築後に生データを解放する必要がある場合はTRUE
# - info                ：


# ＜目次＞
# 0 準備
# 1 データセットを作成


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
dtrain %>% print()
dtrain %>% names()
