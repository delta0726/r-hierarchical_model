# ***********************************************************************************************
# Function  : gpb.grid.search.tune.parameters
# Objective : ハイパーパラメータチューニングの実行関数
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.grid.search.tune.parameters
# ***********************************************************************************************


# ＜概要＞
# - ハイパーパラメータチューニングの実行関数
# - 最良パラメータのみが出力される（他の候補の情報は出力されない）


# ＜構文＞
# gpb.grid.search.tune.parameters(param_grid, data, params = list(),
#   num_try_random = NULL, nrounds = 100L, gp_model = NULL,
#   use_gp_model_for_validation = TRUE, train_gp_model_cov_pars = TRUE,
#   folds = NULL, nfold = 4L, label = NULL, weight = NULL, obj = NULL,
#   eval = NULL, verbose_eval = 1L, stratified = TRUE, init_model = NULL,
#   colnames = NULL, categorical_feature = NULL,
#   early_stopping_rounds = NULL, callbacks = list(), ...)


# ＜引数＞
# - param_grid                  ：チューニンググリッドをリストで指定
# - data                        ：訓練データのgpb.Datasetオブジェクト
# - params                      ：lightgbmの学習パラメータ（gpboostを参照、チューニング対象以外）
# - num_try_random              ：ランダムトライアル回数（NULLの場合は通常のグリッドサーチ）
# - nrounds                     ：ブースティングの反復回数（=ツリーの数）
# - gp_model                    ：GPModelオブジェクト（ガウス過程/グループ化ランダム効果）
# - use_gp_model_for_validation ：TRUEの場合、検証データの予測を計算するためにガウス過程も使用（ツリーモデルに加えて）
# - train_gp_model_cov_pars     ：TRUEの場合、ガウス過程の共分散パラメーターはすべてのブースティング反復で推定
# - folds                       ：事前に定義したFold
# - nfold                       ：CVの分割数
# - label                       ：ラベルをベクトルで指定
# - weight                      ：ウエイトをベクトルで指定
# - obj                         ：目的関数を指定（gpboostを参照）
# - eval                        ：評価関数を文字列又は関数で指定（gpboostを参照）
# - verbose_eval                ：0(非表示) / 1(表示)
# - stratified                  ：TRUEの場合、出力ラベルによる層別サンプリングによるクロスバリデーションを的よう
# - init_model                  ：初期モデルの指定（gpb.Boosterオブジェクトの保存先）
# - colnames                    ：特徴量の列名（NULLの場合はデータセットのものを使用）
# - categorical_feature         ：
# - early_stopping_rounds       ：数値で指定、スコアが上昇してから停止までの回数
# - callbacks                   ：各イテレーションで適用されるコールバック関数をリストで指定


# ＜目次＞
# 0 準備
# 1 データ確認
# 2 モデリング
# 3 チューニング準備
# 4 チューニング


# 0 準備 -------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 データ確認 -------------------------------------------------------------------------

# 変数確認
ls()

# データ確認
data.frame(X, y, group_data, coords) %>% as_tibble()
data.frame(X_test, group_data_test, coords_test) %>% as_tibble()


# 2 モデリング ------------------------------------------------------------------------

# モデル構築
# --- ランダム効果モデル
gp_model <- GPModel(group_data = group_data[,1], likelihood = "gaussian")

# データ作成
# --- 訓練データ
dtrain <- gpb.Dataset(X, label = y)

# パラメータ設定
params <- list(objective = "regression_l2")


# 3 チューニング準備 --------------------------------------------------------------------

# チューニンググリッド
param_grid <-
  list(learning_rate = c(0.1, 0.01),
       min_data_in_leaf = 20,
       max_depth = c(5, 10),
       num_leaves = 2^17,
       max_bin = c(255, 1000))

# 確認
param_grid %>% print()


# 4 チューニング ------------------------------------------------------------------------

# Parameter tuning using cross-validation and deterministic grid search
# --- num_try_random = NULL
set.seed(1)
opt_params <-
  gpb.grid.search.tune.parameters(param_grid = param_grid,
                                  params = params,
                                  num_try_random = NULL,
                                  nfold = 4,
                                  data = dtrain,
                                  gp_model = gp_model,
                                  verbose_eval = 1,
                                  nrounds = 1000,
                                  early_stopping_rounds = 5,
                                  eval = "l2")

# Parameter tuning using cross-validation and random grid search
# --- num_try_random = 4
set.seed(1)
opt_params <-
  gpb.grid.search.tune.parameters(param_grid = param_grid,
                                  params = params,
                                  num_try_random = 4,
                                  nfold = 4,
                                  data = dtrain,
                                  gp_model = gp_model,
                                  verbose_eval = 1,
                                  nrounds = 1000,
                                  early_stopping_rounds = 5,
                                  eval = "l2")


# 5 チューニング結果の確認 ----------------------------------------------------------------

# 確認
opt_params %>% print()
opt_params %>% names()


