# ***********************************************************************************************
# Function  : getinfo
# Objective : gpb.Datasetオブジェクトの要素を抽出する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/getinfo
# ***********************************************************************************************


# ＜概要＞
# - gpb.Datasetオブジェクトの要素を抽出する


# ＜構文＞
# getinfo(dataset, name, ...)


# ＜引数＞
# name: 取得する情報フィールドの名前


# ＜詳細＞
# 取得する情報フィールドのnameは次のいずれか
# - label     ：ラベルを指定
# - weight    ：重みの再スケールを実行
# - group     ：
# - init_score：初期スコアは、gpboostがブーストする基本予測


# ＜構文＞


# ＜目次＞
# 0 準備
# 1 gpb.Datasetの作成
# 2 データ情報の確認


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
dtrain <- train$data %>% gpb.Dataset(label = train$label)

# 確認
dtrain %>% print()
dtrain %>% names()

# データセットを明示的に構築
gpb.Dataset.construct(dtrain)


# 2 データ情報の確認 ------------------------------------------------------------

# ラベルの抽出
labels <- dtrain %>% getinfo("label")
labels %>% head(10)

# ラベルを変更してセット
dtrain %>% setinfo( "label", 1 - labels)

# ラベル抽出
# --- 変更を確認
labels2 <- dtrain %>% getinfo("label")
labels2 %>% head(10)

# 関数でチェック
all(labels2 == 1 - labels)
