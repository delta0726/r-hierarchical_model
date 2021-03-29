# ***********************************************************************************************
# Function  : gpboost
# Objective : PBoostモデルをトレーニングするためのシンプルなインターフェイス
# Created by: Owner
# Created on: 2021/03/30
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpboost
# ***********************************************************************************************


# ＜概要＞
# - GPBoostモデルをトレーニングするためのシンプルなインターフェイス
# - ツリーブースティングはLightGBMの設定と重複する


# ＜構文＞
# gpboost(data, label = NULL, weight = NULL, params = list(),
#   nrounds = 100L, gp_model = NULL, use_gp_model_for_validation = TRUE,
#   train_gp_model_cov_pars = TRUE, valids = list(), obj = NULL,
#   eval = NULL, verbose = 1L, record = TRUE, eval_freq = 1L,
#   early_stopping_rounds = NULL, init_model = NULL, colnames = NULL,
#   categorical_feature = NULL, callbacks = list(), ...)


# ＜引数＞
# - data                  ：学習データのgpb.Datasetオブジェクト
# - label                 ：ラベルをベクトルで指定
# - weight                ：ウエイトをベクトルで指定
# - params                ：モデルのパラメータ（後述）
# - nrounds               ：ブースティングの反復回数（=ツリーの数）
# - gp_model              ：GPModelオブジェクト（ガウス過程および/またはグループ化された変量効果）
# - use_gp_model_for_validation ：TRUEの場合、検証データの予測を計算するためにガウス過程も使用（ツリーモデルに加えて）
# - train_gp_model_cov_pars     ：TRUE,
# - valids                ：検証データのgpb.Datasetオブジェクト
# - obj                   ：目的関数を文字列orカスタムの目的関数で指定（後述）
# - eval                  ：評価関数を文字列又は関数で指定（後述）
# - verbose               ：0(非表示) / 1(表示)
# - record                ：TRUEは、メッセージをbooster$record_evalsに記録します
# - eval_freq             ：メッセージ出力頻度
# - early_stopping_rounds ：早期停止をアクティブにする。 少なくとも1つの検証データと1つのメトリックが必要
# - init_model            ：初期モデルの指定（gpb.Boosterオブジェクトの保存先）
# - colnames              ：特徴量の列名（NULLの場合はデータセットのものを使用）
# - categorical_feature   ：
# - callbacks             ：各反復で適用されるコールバック関数のリスト


# ＜パラメータ：params＞
# - learning_rate          ：収縮または減衰パラメーターとも呼ばれる学習率（デフォルト= 0.1）
# - num_leaves             ：ツリー内の葉の数（デフォルト= 31）
# - min_data_in_leaf       ：リーフあたりのサンプルの最小数（デフォルト= 20
# - max_depth              ：ツリーの最大深度（デフォルト= NULL）
# - leaves_newton_update   ：TRUEに設定するとグラデーションステップの後に木の葉のニュートン更新ステップが実行
#                          ：（GPBoostアルゴリズムのみ）
# - train_gp_model_cov_pars：TRUEの場合、ガウス過程の共分散パラメーターは、ブーストの反復ごとに推定
# - use_gp_model_for_validation：TRUEの場合、検証データの予測を計算するためにガウス過程にも使用されます
# - use_nesterov_acc       ：TRUEに設定すると、Nesterovアクセラレーションでブーストを実行（デフォルト= FALSE）
# - nesterov_acc_rate      ：Nesterov加速ブースティングの運動量ステップの加速率（デフォルト= 0.5）
# - oosting                ：gbdt/rf/dart/goss （gbdのみガウス過程ブーストで実行可能）
# - num_threads            ：スレッドの数（最高の速度を得るには実際のCPUコアの数に設定）


# ＜目的関数：obj＞
# - regression    ：回帰
# - regression_l1 ：平均絶対誤差(MAE)
# - regression_l2 ：平均二乗誤差(MSE)
# - huber         ：huber損失（MAEとMSEのいいとこ取り）
# - binary        ：2値分類
# - lambdarank    ：ランク学習
# - multiclass    ：マルチクラス分類


# ＜評価関数＞
# - None                ：  (string, not a None value) means that no metric will be registered, aliases: na, null, custom
# - l1                  ： absolute loss, aliases: mean_absolute_error, mae, regression_l1
# - l2                  ： square loss, aliases: mean_squared_error, mse, regression_l2, regression
# - rmse                ： root square loss, aliases: root_mean_squared_error, l2_root
# - quantile            ： Quantile regression
# - mape                ：MAPE loss, aliases: mean_absolute_percentage_error
# - huber               ： Huber loss
# - fair                ： Fair loss
# - poisson             ： negative log-likelihood for Poisson regression
# - gamma               ： negative log-likelihood for Gamma regression
# - gamma_deviance      ： residual deviance for Gamma regression
# - tweedie             ： negative log-likelihood for Tweedie regression
# - ndcg                ： NDCG： aliases: lambdarank, rank_xendcg, xendcg, xe_ndcg, xe_ndcg_mart, xendcg_mart
# - map,                ： MAP aliases: mean_average_precision
# - auc                 ： AUC
# - average_precision   ： average precision score
# - binary_logloss      ： log loss, aliases: binary
# - binary_error： for one sample: 0 for correct classification, 1 for error classification
# - auc_mu              ： AUC-mu
# - multi_logloss       ： log loss for multi-class classification, aliases: multiclass, softmax, multiclassova, multiclass_ova, ova, ovr
# - multi_error         ： error rate for multi-class classificatio
# - cross_entropy       ： cross-entropy (with optional linear weights), aliases: xentropy
# - cross_entropy_lambda： “intensity-weighted” cross-entropy, aliases: xentlambda
# - kullback_leibler    ： Kullback-Leibler divergence, aliases: kldiv


# [参考：Light GBM]
# https://lightgbm.readthedocs.io/en/latest/Parameters.html#metric


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
# 1 データ確認
# 2 ツリーブースティングとランダム効果モデルの結合
# 3 ツリーブースティングとガウス過程モデルの結合


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 データ確認 --------------------------------------------------------------------

# グループ情報の確認
# --- 訓練データ
group_data[,1] %>% print()
group_data[,1] %>% table()

# グループ情報の確認
# --- 検証データ
group_data_test[,1] %>% print()
group_data_test[,1] %>% table()


# 2 ツリーブースティングとランダム効果モデルの結合 --------------------------------------

# ランダム効果モデル
# --- group_dataを指定
gp_model <-
  GPModel(group_data = group_data[,1],
          likelihood = "gaussian")

# モデル学習
bst <-
  gpboost(data = X,
          label = y,
          gp_model = gp_model,
          nrounds = 16,
          learning_rate = 0.05,
          max_depth = 6,
          min_data_in_leaf = 5,
          objective = "regression_l2",
          verbose = 0)

# データ確認
gp_model %>% print()

# サマリー
# --- 誤差量
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

# 出力要素の確認
# --- ランダム効果の平均
# --- ランダム効果のバリアンス
# --- 固定効果
# --- ランダム効果 + 固定効果
pred$random_effect_mean
pred$random_effect_cov
pred$fixed_effect
pred$random_effect_mean + pred$fixed_effect



# 3 ツリーブースティングとガウス過程モデルの結合 ----------------------------------------

# ガウス過程モデルの構築
# --- gp_coordsを設定
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

# 出力要素の確認
# --- ランダム効果の平均
# --- ランダム効果のバリアンス
# --- 固定効果
# --- ランダム効果 + 固定効果
pred$random_effect_mean
pred$random_effect_cov
pred$fixed_effect
pred$random_effect_mean + pred$fixed_effect
