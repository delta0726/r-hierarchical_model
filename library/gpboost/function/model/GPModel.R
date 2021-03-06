# ***********************************************************************************************
# Function  : GPModel
# Objective : ガウス過程および/またはグループ化された変量効果を持つ混合効果モデルを含むGPModelを作成する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/GPModel
# ***********************************************************************************************


# ＜概要＞
# - ガウス過程またはグループ化変量効果を持つ混合効果モデルを含むGPModelを作成する
#   --- 両方を同時に適用することも可能


# ＜構文＞
# GPModel(group_data = NULL, group_rand_coef_data = NULL,
#   ind_effect_group_rand_coef = NULL, gp_coords = NULL,
#   gp_rand_coef_data = NULL, cov_function = "exponential",
#   cov_fct_shape = 0, vecchia_approx = FALSE, num_neighbors = 30L,
#   vecchia_ordering = "none",
#   vecchia_pred_type = "order_obs_first_cond_obs_only",
#   num_neighbors_pred = num_neighbors, cluster_ids = NULL,
#   free_raw_data = FALSE, likelihood = "gaussian")


# ＜引数＞
# - group_data                ：グループ情報（ベクトル/行列）
# - group_rand_coef_data      ：グループ化されたランダム係数の共変量データ（ベクトル/行列）
# - ind_effect_group_rand_coef：
# - gp_coords                 ：ガウス過程の特徴座標(行列)
# - gp_rand_coef_data         ：ガウス過程のランダム係数の共変量データ（ベクトル/行列）
# - cov_function              ：ガウス過程の共分散関数（文字列）
# - cov_fct_shape             ：共分散関数の形状パラメーター（数値）
# - vecchia_approx            ：TRUEの場合、Vecchia近似が使用されます(TRUE/FALSE)
# - num_neighbors             ：Vecchia近似の近傍の数を指定する整数
# - vecchia_ordering          ：Vecchia近似で使用される順序を指定（文字列）
# - vecchia_pred_type         ：予測に使用されるVecchia近似のタイプ（文字列）
# - num_neighbors_pred        ：予測を行うためのVecchia近似の近傍の数（整数）
# - cluster_ids               ：変量効果/ガウス過程の独立した実現を示すID /ラベルを持つベクトル
# - free_raw_data             ：TRUEの場合、データは初期化後にRで解放(TRUE/FALSE)
# - likelihood                ：応答変数の尤度関数を指定する文字列（デフォルトは"gaussian"）


# ＜ガウス過程の共分散関数：cov_function＞
# - exponential         ：指数カーネル関数
# - gaussian            ：ガウスカーネル
# - matern              ：Matern相互共分散関数
# - powered_exponential ：


# ＜目次＞
# 0 準備
# 1 ランダム効果モデル（シングルレベルのランダム効果）
# 2 ガウス過程モデル
# 3 ガウス過程モデルにランダム効果を結合
# 4 gp_modelの中身


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 ランダム効果モデル（シングルレベルのランダム効果）-----------------------------------

# データ確認
# --- グループ情報
group_data[,1] %>% print()
group_data[,1] %>% table()

# モデル定義
gp_model <- GPModel(group_data = group_data[,1], likelihood = "gaussian")


# 2 ガウス過程モデル ----------------------------------------------------------------

# データ確認
# --- 空間座標
coords %>% head()

# モデル定義
gp_model <- GPModel(gp_coords = coords, cov_function = "exponential",
                    likelihood = "gaussian")


# 3 ガウス過程モデルにランダム効果を結合 ------------------------------------------------

# データ確認
# --- グループ情報
# --- 空間座標
group_data[,1] %>% table()
coords %>% head()

# モデル定義
gp_model <- GPModel(group_data = group_data, gp_coords = coords,
                    cov_function = "exponential", likelihood = "gaussian")


# 4 gp_modelの中身 ----------------------------------------------------------------

# データ構造の確認
gp_model %>% glimpse()

# オブジェクトの確認
gp_model %>% names()
gp_model %>% attributes()
