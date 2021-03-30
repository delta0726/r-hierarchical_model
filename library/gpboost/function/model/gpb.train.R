# ***********************************************************************************************
# Function  : gpb.train
# Objective : gpboostの学習を行う
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.train
# ***********************************************************************************************


# ＜概要＞
# - GPboostのトレーニングを行う関数


# ＜構文＞
# gpb.train(params = list(), data, nrounds = 100L, gp_model = NULL,
#   use_gp_model_for_validation = TRUE, train_gp_model_cov_pars = TRUE,
#   valids = list(), obj = NULL, eval = NULL, verbose = 1L,
#   record = TRUE, eval_freq = 1L, init_model = NULL, colnames = NULL,
#   categorical_feature = NULL, early_stopping_rounds = NULL,
#   callbacks = list(), reset_data = FALSE, ...)


# ＜引数＞
# - params                      ：lightgbmの学習パラメータ（gpboostを参照）
# - data                        ：学習データのgpb.Datasetオブジェクト
# - nrounds                     ：ブースティングの反復回数（=ツリーの数）
# - gp_model                    ：GPModelオブジェクト（ガウス過程および/またはグループ化された変量効果）
# - use_gp_model_for_validation ：TRUEの場合、検証データの予測を計算するためにガウス過程も使用（ツリーモデルに加えて）
# - train_gp_model_cov_pars     ：TRUEの場合、ガウス過程の共分散パラメーターはすべてのブースティング反復で推定
# - valids                      ：検証データのgpb.Datasetオブジェクト
# - obj                         ：目的関数を文字列orカスタムの目的関数で指定（gpboostを参照）
# - eval                        ：評価関数を文字列又は関数で指定（gpboostを参照）
# - verbose                     ：0(非表示) / 1(表示)
# - record                      ：TRUEの場合、メッセージをbooster$record_evalsに記録
# - eval_freq                   ：メッセージ出力頻度
# - init_model                  ：初期モデルの指定（gpb.Boosterオブジェクトの保存先）
# - colnames                    ：特徴量の列名（NULLの場合はデータセットのものを使用）
# - categorical_feature         ：
# - early_stopping_rounds       ：数値で指定、スコアが上昇してから停止までの回数
# - callbacks                   ：各イテレーションで適用されるコールバック関数をリストで指定
# - reset_data                  ：TRUEの場合、ブースターモデルが予測モデルに変換されメモリと元のデータセットを解放



# ＜目次＞
# 0 準備
# 1 ツリーブースティングとグループ化ランダム効果の結合
# 2 ツリーブースティングとガウス過程の結合
# 3 学習の際に検証データを使う


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 ツリーブースティングとグループ化ランダム効果の結合 ----------------------------------

# モデル構築
# --- ランダム効果
gp_model <- GPModel(group_data = group_data[,1], likelihood = "gaussian")

# データセット作成
dtrain <- gpb.Dataset(data = X, label = y)

# 学習
bst <-
  gpb.train(data = dtrain,
            gp_model = gp_model,
            nrounds = 16,
            learning_rate = 0.05,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 0)

# サマリー
gp_model %>% summary()

# 予測データの作成
pred <-
  bst %>%
    predict(data = X_test, group_data_pred = group_data_test[,1],
            predict_var = TRUE)

# データ確認
# --- ランダム効果(平均)
# --- ランダム効果(共分散)
# --- 固定効果
pred$random_effect_mean
pred$random_effect_cov
pred$fixed_effect

# 効果合計
pred$random_effect_mean + pred$fixed_effect


# 2 ツリーブースティングとガウス過程の結合 ------------------------------------------------

# モデル構築
# --- ガウス過程モデル
gp_model <-
  GPModel(gp_coords = coords, cov_function = "exponential",
          likelihood = "gaussian")

# データセット作成
dtrain <- gpb.Dataset(data = X, label = y)

# 学習
bst <-
  gpb.train(data = dtrain,
            gp_model = gp_model,
            nrounds = 16,
            learning_rate = 0.05,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 0)

# サマリー
gp_model %>% summary()

# 予測作成
pred <-
  bst %>%
    predict(data = X_test, gp_coords_pred = coords_test,
            predict_cov_mat =TRUE)

# データ確認
# --- ランダム効果(平均)
# --- ランダム効果(共分散)
# --- 固定効果
pred$random_effect_mean
pred$random_effect_cov
pred$fixed_effect

# 効果合計
pred$random_effect_mean + pred$fixed_effect


# 3 学習の際に検証データを使う --------------------------------------------------

# 訓練データの選択
# --- インデックスをランダムに指定
set.seed(1)
train_ind <- y %>% length() %>% sample.int(size = 250)

# 訓練データの作成
dtrain <- gpb.Dataset(data = X[train_ind,], label = y[train_ind])

# 検証データの作成
dtest <-
  dtrain %>%
    gpb.Dataset.create.valid(data = X[-train_ind,], label = y[-train_ind])

# 検証データセット
valids <- list(test = dtest)

# モデル構築
# --- ランダム効果モデル
gp_model <- GPModel(group_data = group_data[train_ind,1], likelihood = "gaussian")

# モデル追加設定
# Need to set prediction data for gp_model
gp_model$set_prediction_data(group_data_pred = group_data[-train_ind,1])

# 学習
# --- Training with validation data and
# --- use_gp_model_for_validation = TRUE
bst <-
  gpb.train(data = dtrain,
            gp_model = gp_model,
            nrounds = 100,
            learning_rate = 0.05,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 1,
            valids = valids,
            early_stopping_rounds = 10,
            use_gp_model_for_validation = TRUE)


# 最良イテレーション
bst$best_iter

# 最良スコア
bst$best_score

# プロット作成
# --- イテレーションごとのエラー量
bst$record_evals$test$l2$eval %>%
  unlist() %>%
  plot(1:length(.), ., type = "l", lwd = 2, col = "blue", xlab = "iteration",
       ylab = "Validation error", main = "Validation error vs. boosting iteration")


# 4 Do Newton updates for tree leaves ---------------------------------------------

# ＜備考＞
# - ｢3 学習の際に検証データを使う｣の続き

# 学習
# --- ニュートン更新ステップが実行
# --- leaves_newton_update = TRUE
bst <- gpb.train(data = dtrain,
                 gp_model = gp_model,
                 nrounds = 100,
                 learning_rate = 0.05,
                 max_depth = 6,
                 min_data_in_leaf = 5,
                 objective = "regression_l2",
                 verbose = 1,
                 valids = valids,
                 early_stopping_rounds = 5,
                 use_gp_model_for_validation = FALSE,
                 leaves_newton_update = TRUE)

# 最良イテレーション
bst$best_iter

# 最良スコア
bst$best_score

# プロット作成
# --- イテレーションごとのエラー量
bst$record_evals$test$l2$eval %>%
  unlist() %>%
  plot(1:length(.), ., type = "l", lwd = 2, col = "blue", xlab = "iteration",
       ylab = "Validation error", main = "Validation error vs. boosting iteration")


#--------------------GPBoostOOS algorithm: GP parameters estimated out-of-sample----------------

# モデル構築
gp_model <- GPModel(group_data = group_data[,1], likelihood = "gaussian")

# データ作成
dtrain <- gpb.Dataset(X, label = y)

# パラメータ設定
params <- list(learning_rate = 0.05,
               max_depth = 6,
               min_data_in_leaf = 5,
               objective = "regression_l2")

# ＜ステージ1＞
# クロスバリデーションで最良イテレーション回数を決定
# --- アウトオブサンプル(OOS)データで決定
cvbst <-
  gpb.cv(params = params,
         data = dtrain,
         gp_model = gp_model,
         nrounds = 100,
         nfold = 4,
         eval = "l2",
         early_stopping_rounds = 5,
         use_gp_model_for_validation = TRUE,
         fit_GP_cov_pars_OOS = TRUE)

# 最良イテレーション回数
cvbst$best_iter

# サマリー
gp_model %>% summary()

# ＜ステージ２＞
# 最良イテレーションを用いて学習
bst <- gpb.train(data = dtrain,
                 gp_model = gp_model,
                 nrounds = cvbst$best_iter,
                 learning_rate = 0.05,
                 max_depth = 6,
                 min_data_in_leaf = 5,
                 objective = "regression_l2",
                 verbose = 0,
                 train_gp_model_cov_pars = FALSE)

# サマリー
gp_model %>% summary()
