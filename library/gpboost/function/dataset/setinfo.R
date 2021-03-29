# ***********************************************************************************************
# Function  : setinfo
# Objective : gpb.Datasetオブジェクトの情報を取得します
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/setinfo
# ***********************************************************************************************


# ＜概要＞
# - gpb.Datasetオブジェクトに情報を設定


# ＜構文＞
# setinfo(dataset, name, info, ...)


# ＜引数＞
# name: 取得する情報フィールドの名前


# ＜詳細＞
# 取得する情報フィールドのnameは次のいずれか
# - label: ラベルを指定
# - weight: 重みの再スケールを実行
# - group:
# - init_score: 初期スコアは、gpboostがブーストする基本予測


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
dtrain <- gpb.Dataset(train$data, label = train$label)

# 確認
dtrain %>% print()
dtrain %>% names()

# データセットを明示的に構築
gpb.Dataset.construct(dtrain)


# 2 データ情報の確認 ------------------------------------------------------------

# ラベル抽出
labels <- dtrain %>% getinfo("label")
labels %>% head(10)

# ラベル設定の変更
dtrain %>% setinfo( "label", 1 - labels)

# ラベル抽出
# --- 変更確認
labels2 <- dtrain %>% getinfo("label")
labels2 %>% head(10)

# 比較
all.equal(labels2, 1 - labels)
