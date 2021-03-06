# ***********************************************************************************************
# Function  : gpb.Dataset.construct
# Objective : データセットを明示的に構築
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.Dataset.construct
# ***********************************************************************************************


# ＜概要＞
# - データセットを明示的に構築
# - 実行によりいくつかの設定が行われているようだ（中身不明）


# ＜構文＞
# gpb.Dataset.construct(dataset)


# ＜引数＞
# - dataset: gpb.Datasetオブジェクト


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
dtrain <- train$data %>% gpb.Dataset(label = train$label)

# 明示的にデータセットを作成
# --- colnames / handle / version で入力値に変化あり
gpb.Dataset.construct(dtrain)
