# ***********************************************************************************************
# Function  : GPModel
# Objective : ガウス過程および/またはグループ化された変量効果を持つ混合効果モデルを含むGPModelを作成する
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/GPModel
# ***********************************************************************************************


# ＜概要＞
# - ガウス過程および/またはグループ化された変量効果を持つ混合効果モデルを含むGPModelを作成する


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
# - group_data           ：グループ情報をベクトルで指定
# - group_rand_coef_data ；グループ化されたランダム係数の共変量データ
# - ind_effect_group_rand_coef = NULL
# - gp_coords            ：ガウス過程の座標(特徴)を持つ行列
# - gp_rand_coef_data    ：ガウス過程のランダム係数の共変量データ
# - cov_function         ：ガウス過程の共分散関数を指定する文字列
# - cov_fct_shape        ：共分散関数の形状パラメーターを指定する数値
# - vecchia_approx       ：TRUEの場合はVecchia近似が使用されます（デフォルトはFALSE）
# - num_neighbors        ：Vecchia近似の近傍の数を指定する整数
# - vecchia_ordering     ：Vecchia近似で使用される順序を指定する文字列
# - vecchia_pred_type    ：予測に使用されるVecchia近似のタイプを指定する文字列
# - num_neighbors_pred   ：予測を行うためのVecchia近似の近傍の数を指定する整数
# - cluster_ids          ：変量効果/ガウス過程の独立した実現を示すID /ラベルを持つベクトル
# - free_raw_data        ：TRUEの場合、データは初期化後にRで解放されます。
# - likelihood           ：応答変数の尤度関数を指定する文字列（デフォルトは"gaussian"）


# ＜アーリーストッピング＞
# - 定の検証セットでのモデルのパフォーマンスが数回の連続した反復で改善されない場合にプロセスを停止すること
# - params引数でearly_stopping_roundsの設定を有効にするとアーリーストッピングが適用される
#   --- デフォルトでは、すべてのメトリックが早期停止の対象と見なされます。
# - 早期停止の最初のメトリックのみを考慮したい場合は、paramsでfirst_metric_only = TRUEを渡します


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
group_data[,1] %>% print()
group_data[,1] %>% table()

# モデル定義
gp_model <- GPModel(group_data = group_data[,1], likelihood = "gaussian")


# 2 ガウス過程モデル ----------------------------------------------------------------

#
coords

# モデル定義
gp_model <- GPModel(gp_coords = coords, cov_function = "exponential",
                    likelihood="gaussian")


# 3 ガウス過程モデルにランダム効果を結合 ------------------------------------------------

# モデル定義
gp_model <- GPModel(group_data = group_data, gp_coords = coords,
                    cov_function = "exponential", likelihood = "gaussian")


# 4 gp_modelの中身 ----------------------------------------------------------------

# データ構造の確認
gp_model %>% glimpse()

# オブジェクトの確認
gp_model %>% names()
gp_model %>% attributes()

