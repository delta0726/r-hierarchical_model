# ***********************************************************************************************
# Title     : ハイパーパラメータのチューニング
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/21
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/parameter_tuning.R
# ***********************************************************************************************


# ＜概要＞
# - GPboostが提供するハイパーパラメータチューニング関数を確認する
#   --- 最良パラメータのみが出力される
#   --- グリッドごとのパフォーマンスが見たい場合は個別実行が必要な模様


# ＜目次＞
# 0 準備
# 1 モデル設定
# 2 クロスバリデーションを用いたチューニング
# 2-1 小規模のチューニング
# 2-2 大規模のチューニング
# 2-3 メトリックを変更してチューニング
# 3 検証データを用いたチューニング


# 0 準備 ---------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(magrittr)
library(gpboost)


# データ準備
source("library/gpboost/demo/func/data_parameter_tuning.R")

# 変数確認
ls()

# データ確認
# --- 分類問題
data.frame(X, y, group) %>%
  set_colnames(c("X1", "X2", "y", "group")) %>%
  as_tibble()

# データ確認
y %>% table()
group %>% table()


# 1 モデル設定 -------------------------------------------------------------------------

# モデル定義
# --- ランダム効果モデル
# --- bernoulli_probitはバイナリ分類の際のデフォルト値
# --- オプティマイザーのパラメータを追加で設定
gp_model <- GPModel(group_data = group, likelihood = "bernoulli_probit")
gp_model$set_optim_params(params = list("optimizer_cov" = "gradient_descent"))

# データセットの定義
dtrain <- gpb.Dataset(data = X, label = y)

# 確認
dtrain %>% print()


# 2 クロスバリデーションを用いたチューニング -------------------------------------------------

# 2-1 小規模のチューニング -----------------------------------------------------

# パラメータ設定
params <-
  list(objective = "binary",
       verbose = 0,
       num_leaves = 2^10)

# チューニンググリッド設定
param_grid_small <-
  list(learning_rate = c(0.1, 0.01),
       min_data_in_leaf = c(20, 100),
       max_depth = c(5, 10),
       max_bin = c(255, 1000))

# チューニング
# --- num_try_random = NULL
set.seed(1)
opt_params <-
  param_grid_small %>%
    gpb.grid.search.tune.parameters(params = params,
                                    num_try_random = NULL,
                                    nfold = 4,
                                    data = dtrain,
                                    gp_model = gp_model,
                                    verbose_eval = 1,
                                    nrounds = 1000,
                                    early_stopping_rounds = 5,
                                    eval = "binary_logloss")

# 確認
opt_params %>% print()
opt_params %>% glimpse()


# 2-2 大規模のチューニング -----------------------------------------------------

# パラメータ設定
params <-
  list(objective = "binary",
       verbose = 0,
       num_leaves = 2^10)

# チューニンググリッド設定
param_grid_large <-
  list(learning_rate = c(0.5, 0.1, 0.05, 0.01),
       min_data_in_leaf = c(5, 10, 20, 50, 100, 200),
       max_depth = c(1, 3, 5, 10, 20),
       max_bin = c(255, 500, 1000, 2000))

# チューニング
# --- num_try_random = 10
# --- loglossで評価
set.seed(1)
opt_params <-
  param_grid_large %>%
    gpb.grid.search.tune.parameters(params = params,
                                    num_try_random = 10,
                                    nfold = 4,
                                    data = dtrain,
                                    gp_model = gp_model,
                                    verbose_eval = 1,
                                    nrounds = 1000,
                                    early_stopping_rounds = 5,
                                    eval = "binary_logloss")

# 確認
opt_params %>% print()
opt_params %>% glimpse()


# 2-3 メトリックを変更してチューニング ---------------------------------------------

# パラメータ設定
params <-
  list(objective = "binary",
       verbose = 0,
       num_leaves = 2^10)

# チューニング
# --- AUCで評価
# --- チューニンググリッドは2-2と同様のものを使用
set.seed(1)
opt_params <-
  param_grid_large %>%
    gpb.grid.search.tune.parameters(params = params,
                                    num_try_random = 5,
                                    nfold = 4,
                                    data = dtrain,
                                    gp_model = gp_model,
                                    verbose_eval = 1,
                                    nrounds = 1000,
                                    early_stopping_rounds = 5,
                                    eval = "auc")

# 確認
opt_params %>% print()
opt_params %>% glimpse()


# 3 検証データを用いたチューニング ----------------------------------------------------

# 検証データの選定
# --- 50％を使用
# --- チューニングの際にfolds引数に設定
set.seed(1)
test_ind <- sample.int(n, size = as.integer(0.5 * n))
folds <- list(test_ind)

# パラメータ設定
params <-
  list(objective = "binary",
       verbose = 0)

# チューニンググリッド設定
param_grid <-
  list(learning_rate = c(0.1, 0.01),
       min_data_in_leaf = c(20, 100),
       max_depth = c(5, 10),
       max_bin = c(255, 1000))

# チューニング
set.seed(1)
opt_params <-
  param_grid %>%
    gpb.grid.search.tune.parameters(params = params,
                                    num_try_random = 5,
                                    folds = folds,
                                    data = dtrain,
                                    gp_model = gp_model,
                                    verbose_eval = 1,
                                    nrounds = 1000,
                                    early_stopping_rounds = 5,
                                    eval = "binary_logloss")

# 確認
opt_params %>% print()
opt_params %>% glimpse()
