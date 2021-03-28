# ***********************************************************************************************
# Function  : GPBoost_data
# Objective : サンプルデータセットを名前空間にロード
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/GPBoost_data
# ***********************************************************************************************


# ＜概要＞
# y: 応答変数
# X: 特徴量行列（訓練データ）
# group_data: カテゴリカルグループ行列（訓練データ）
# coords: 空間座標行列（訓練データ）
# X_test: 特徴量行列（検証データ）
# group_data_test: 空間座標行列（検証データ）
# coords_test: 空間座標行列（検証データ）


# ＜目次＞
# 0 準備
# 1 データ型
# 2 データ確認


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 データ型 -------------------------------------------------------------------

# 訓練データ
y %>% class()
X %>% class()
group_data %>% class()
coords %>% class()

# 検証データ
X_test %>% class()
group_data_test %>% class()
coords_test %>% class()


# 2 データ確認 -------------------------------------------------------------------

# 訓練データ
y %>% as_tibble()
X %>% as_tibble()
group_data %>% as_tibble()
coords %>% as_tibble()

# 検証データ
X_test %>% as_tibble()
group_data_test %>% as_tibble()
coords_test %>% as_tibble()
