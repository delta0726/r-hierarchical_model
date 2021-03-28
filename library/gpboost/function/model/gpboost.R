# ***********************************************************************************************
# Function  : gpboost
# Objective : PBoostモデルをトレーニングするためのシンプルなインターフェイス
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpboost
# ***********************************************************************************************


# ＜概要＞
# - PBoostモデルをトレーニングするためのシンプルなインターフェイス


# ＜構文＞
# gpboost(data, label = NULL, weight = NULL, params = list(),
#   nrounds = 100L, gp_model = NULL, use_gp_model_for_validation = TRUE,
#   train_gp_model_cov_pars = TRUE, valids = list(), obj = NULL,
#   eval = NULL, verbose = 1L, record = TRUE, eval_freq = 1L,
#   early_stopping_rounds = NULL, init_model = NULL, colnames = NULL,
#   categorical_feature = NULL, callbacks = list(), ...)


# ＜引数＞
# - data          ：特徴量を行列で指定
# - label         ：ラベルをベクトルで指定
# - weight        ：ウエイトをベクトルで指定
# - params        ：
# - nrounds       ：ブースティングの反復回数（=ツリーの数）
# - gp_model      ：
# - use_gp_model_for_validation ：TRUE,
# - train_gp_model_cov_pars     ：TRUE,
# - valids        ：
# - obj           ：目的関数を文字またはカスタムの目的関数で指定。
# - eval        ：
# - verbose        ：
# - record        ：
# - eval_freq        ：
# - early_stopping_rounds        ：
# - init_model        ：
# - colnames        ：
# - categorical_feature        ：
# - callbacks        ：


# ＜params引数＞
# - learning_rate     ：収縮または減衰パラメーターとも呼ばれる学習率（デフォルト= 0.1）
# - num_leaves        ：ツリー内の葉の数（デフォルト= 31）
# - min_data_in_leaf  ：リーフあたりのサンプルの最小数（デフォルト= 20
# - max_depth         ：ツリーの最大深度（デフォルト= NULL）
# - leaves_newton_update   ：TRUEに設定するとグラデーションステップの後に木の葉のニュートン更新ステップが実行
#                          ：（GPBoostアルゴリズムのみ）
# - train_gp_model_cov_pars：TRUEの場合、ガウス過程の共分散パラメーターは、ブーストの反復ごとに推定
# - use_gp_model_for_validation：TRUEの場合、検証データの予測を計算するためにガウス過程にも使用されます
# - use_nesterov_acc
# - nesterov_acc_rate
# - oosting
# - num_threads Number of threads


# ＜目的関数＞
# - regression
# - regression_l1
# - regression_l2
# - huber
# - binary
# - lambdarank
# - multiclass
# - multiclass


# ＜アーリーストッピング＞
# - 定の検証セットでのモデルのパフォーマンスが数回の連続した反復で改善されない場合にプロセスを停止すること
# - params引数でearly_stopping_roundsの設定を有効にするとアーリーストッピングが適用される
#   --- デフォルトでは、すべてのメトリックが早期停止の対象と見なされます。
# - 早期停止の最初のメトリックのみを考慮したい場合は、paramsでfirst_metric_only = TRUEを渡します


# ＜ソリューション＞
# 事例1： ツリーブースティングとランダム効果モデルの結合
# 事例2： ツリーブースティングとガウス過程モデルの結合


# ＜目次：事例1＞
# 0 準備
# 1 ツリーブースティングとランダム効果モデルの結合
# 2 ツリーブースティングとガウス過程モデルの結合


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 ツリーブースティングとランダム効果モデルの結合 --------------------------------------

# グループ情報の確認
group_data[,1] %>% print()
group_data[,1] %>% table()

# ランダム効果モデル
# --- グループ情報を指定
gp_model <- GPModel(group_data = group_data[,1], likelihood = "gaussian")

# オプティマイザー変更
# The default optimizer for covariance parameters for Gaussian data is Fisher scoring.
# For non-Gaussian data, gradient descent is used.
# Optimizer properties can be changed as follows:
# re_params <- list(optimizer_cov = "gradient_descent", use_nesterov_acc = TRUE)
# gp_model$set_optim_params(params=re_params)
# Use trace = TRUE to monitor convergence:
# re_params <- list(trace = TRUE)
# gp_model$set_optim_params(params=re_params)


# モデル学習
bst <- gpboost(data = X,
               label = y,
               gp_model = gp_model,
               nrounds = 16,
               learning_rate = 0.05,
               max_depth = 6,
               min_data_in_leaf = 5,
               objective = "regression_l2",
               verbose = 0)

# サマリー確認
gp_model %>% summary()


# 予測データの作成
pred <-
  bst %>%
    predict(data = X_test,
            group_data_pred = group_data_test[,1],
            predict_var= TRUE)

# データ確認
pred %>% print()
pred %>% names()


# 予測の平均
# 予測のバリアンス
# 固定効果
# 合計
pred$random_effect_mean
pred$random_effect_cov
pred$fixed_effect
pred$random_effect_mean + pred$fixed_effect



# 2 ツリーブースティングとガウス過程モデルの結合 ----------------------------------------

# ガウス過程モデルの構築
gp_model <-
  GPModel(gp_coords = coords,
          cov_function = "exponential",
          likelihood = "gaussian")

# 学習
bst <-
  gpboost(data = X,
          label = y,
          gp_model = gp_model,
          nrounds = 8,
          learning_rate = 0.1,
          max_depth = 6,
          min_data_in_leaf = 5,
          objective = "regression_l2",
          verbose = 0)

# サマリー確認
gp_model %>% summary()

# 予測データの作成
pred <-
  bst %>%
    predict(data = X_test,
            gp_coords_pred = coords_test,
            predict_cov_mat =TRUE)

# データ構造
pred %>% print()
pred %>% names()

# データ確認
# --- Predicted (posterior) mean of GP
# --- Predicted (posterior) covariance matrix of GP
# --- Predicted fixed effect from tree ensemble
# --- Sum them up to otbain a single prediction
pred$random_effect_mean
pred$random_effect_cov
pred$fixed_effect
pred$random_effect_mean + pred$fixed_effect