# ***********************************************************************************************
# Function  : agaricus.test
# Objective : サンプルデータセットを名前空間にロード
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/agaricus.test
# ***********************************************************************************************


# ＜概要＞
# - このデータセットは、元々MushroomデータセットであるUCI Machine LearningRepositoryからのもの
# - dataはスパース行列になっている


# ＜目次＞
# 0 準備
# 1 データ確認


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(agaricus.test)


# 1 データ確認 -------------------------------------------------------------------

# データ
agaricus.test$data
agaricus.test$data %>% class()

# ラベル
agaricus.test$label
agaricus.test$label %>% table()
