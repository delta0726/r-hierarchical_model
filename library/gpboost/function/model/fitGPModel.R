# ***********************************************************************************************
# Function  : fitGPModel
# Objective : モデル定義と学習を同時に行う
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/fitGPModel
# ***********************************************************************************************


# ＜概要＞
# - モデル定義と学習を同時に行う
# - GPmodel() + fit()


# ＜構文＞
# fitGPModel(group_data = NULL, group_rand_coef_data = NULL,
#   ind_effect_group_rand_coef = NULL, gp_coords = NULL,
#   gp_rand_coef_data = NULL, cov_function = "exponential",
#   cov_fct_shape = 0, vecchia_approx = FALSE, num_neighbors = 30L,
#   vecchia_ordering = "none",
#   vecchia_pred_type = "order_obs_first_cond_obs_only",
#   num_neighbors_pred = num_neighbors, cluster_ids = NULL,
#   free_raw_data = FALSE, likelihood = "gaussian", y, X = NULL,
#   params = list())


# ＜引数＞
# - group_data                 ：グループ情報（ベクトル/行列）
# - group_rand_coef_data       ：グループ化されたランダム係数の共変量データ（ベクトル/行列）
# - ind_effect_group_rand_coef ：
# - gp_coords                  ：ガウス過程の特徴座標(行列)
# - gp_rand_coef_data          ：ガウス過程のランダム係数の共変量データ（ベクトル/行列）
# - cov_function               ：ガウス過程の共分散関数（文字列）
# - cov_fct_shape              ：共分散関数の形状パラメーター（数値）
# - vecchia_approx             ：TRUEの場合、Vecchia近似が使用されます(TRUE/FALSE)
# - num_neighbors              ：Vecchia近似の近傍の数を指定する整数
# - vecchia_ordering           ：Vecchia近似で使用される順序を指定（文字列）
# - vecchia_pred_type          ：予測に使用されるVecchia近似のタイプ（文字列）
# - num_neighbors_pred         ：予測を行うためのVecchia近似の近傍の数（整数）
# - cluster_ids                ：変量効果/ガウス過程の独立した実現を示すID /ラベルを持つベクトル
# - free_raw_data              ：TRUEの場合、データは初期化後にRで解放(TRUE/FALSE)
# - likelihood                 ：応答変数の尤度関数を指定する文字列（デフォルトは"gaussian"）
# - y                          ：応答変数データを含むベクトル
# - X                          ：固定効果の共変量データを含む行列（=線形回帰項）
# - params                     ：lightgbmの学習パラメータ（gpboostを参照）


# ＜目次＞
# 0 準備
# 1 Grouped random effects model: single-level random effect
# 2 Mixed effects model: random effects and linear fixed effects-
# 3 Two crossed random effects and a random slope
# 4 Gaussian process model
# 5 Gaussian process model with linear mean function
# 6 Gaussian process model with Vecchia approximation
# 7 Gaussian process model with random coefficents
# 8 Combine Gaussian process with grouped random effects


# 0 準備 ---------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 Grouped random effects model: single-level random effect----------------------

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group_data[,1], y = y, likelihood = "gaussian",
             params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()

# 予測
pred <-
  gp_model %>%
    predict(group_data_pred = group_data_test[,1], predict_var = TRUE)

# データ確認
# --- 平均
# --- 分散
# --- 行分散行列
pred$mu %>% print()
pred$var %>% print()
pred$cov %>% print()


# 2 Mixed effects model: random effects and linear fixed effects----------------

# 切片項の追加
X1 <- rep(1, length(y)) %>% cbind(X)

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group_data[,1], likelihood="gaussian",
             y = y, X = X1, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# 3 Two crossed random effects and a random slope--------------------------------

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group_data, likelihood = "gaussian",
             group_rand_coef_data = X[,2],
             ind_effect_group_rand_coef = 1,
             y = y, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# 4 Gaussian process model -------------------------------------------------------

# モデル構築＆学習
gp_model <-
  fitGPModel(gp_coords = coords, cov_function = "exponential",
             likelihood = "gaussian", y = y, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()

# 予測
pred <-
  gp_model %>%
    predict(gp_coords_pred = coords_test, predict_cov_mat = TRUE)

# Predicted (posterior/conditional) mean of GP
pred$mu
pred$cov



# 5 Gaussian process model with linear mean function -------------------------------

# 切片項の追加
X1 <- rep(1, length(y)) %>% cbind(X)

# モデル構築＆学習
gp_model <-
  fitGPModel(gp_coords = coords, cov_function = "exponential",
             likelihood = "gaussian", y = y, X = X1,
             params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# 6 Gaussian process model with Vecchia approximation --------------------------------

# モデル構築＆学習
gp_model <-
  fitGPModel(gp_coords = coords, cov_function = "exponential",
             vecchia_approx = TRUE, num_neighbors = 30,
             likelihood = "gaussian", y = y)

# サマリー
gp_model %>% summary()


# 7 Gaussian process model with random coefficents --------------------------------

# モデル構築
gp_model <-
  GPModel(gp_coords = coords, cov_function = "exponential",
          gp_rand_coef_data = X[,2], likelihood = "gaussian")

# 学習
gp_model %>% fit(y = y, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# Alternatively, define and fit model directly using fitGPModel
gp_model <-
  fitGPModel(gp_coords = coords, cov_function = "exponential",
             gp_rand_coef_data = X[,2], y = y,
             likelihood = "gaussian", params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# 8 Combine Gaussian process with grouped random effects --------------------------------

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group_data, gp_coords = coords,
             cov_function = "exponential", likelihood = "gaussian",
             y = y, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()
