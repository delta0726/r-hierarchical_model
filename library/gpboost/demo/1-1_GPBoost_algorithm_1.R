# ***********************************************************************************************
# Title     : GPBoost_algorithm
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/GPBoost_algorithm.R
# ***********************************************************************************************


# ＜目次＞
# 0 準備
# 1 ツリーブースティングとグループランダム効果モデルの結合
# 2 検証データの使用/不使用の比較
# 3 クロスバリデーションで最良イテレーションを決定する
# 4 ニュートン更新でツリー学習


# 0 準備 ---------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(magrittr)
library(gpboost)


# データ準備
source("library/gpboost/demo/func/generate_data_41.R")

# 変数確認
ls()


# 1 ツリーブースティングとグループランダム効果モデルの結合 ----------------------------------


# *** モデル構築と学習を別に行う ***********************************************

# モデル構築
# --- ランダム効果モデル
gp_model <- GPModel(group_data = group)

# 学習
bst <-
  gpboost(data = X,
          label = y,
          gp_model = gp_model,
          nrounds = 15,
          learning_rate = 0.05,
          max_depth = 6,
          min_data_in_leaf = 5,
          objective = "regression_l2",
          verbose = 0,
          leaves_newton_update = FALSE)

# サマリー
gp_model %>% summary()


# *** モデル構築と学習を同時に行う ***********************************************

# データオブジェクト作成
dataset <- gpb.Dataset(data = X, label = y)

# モデル構築＆学習
bst <-
  gpb.train(data = dataset,
            gp_model = gp_model,
            nrounds = 15,
            learning_rate = 0.05,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 0)

# 予測
pred <- bst %>% predict(data = Xtest, group_data_pred = group_test)

# 予測データの構造
pred %>% glimpse()

# Compare fit to truth: random effects

pred_random_effect <- pred$random_effect_mean

b1 %>%
  plot(pred_random_effect, xlab="truth", ylab="predicted",
       main="Comparison of true and predicted random effects")

# プロット追加
# --- 45度線の追加
abline(a = 0, b = 1)

# Compare fit to truth: fixed effect (mean function)
pred_mean <- pred$fixed_effect

x <- seq(from = 0, to = 1, length.out = 200)

plot(x, f1d(x), type = "l", ylim = c(-0.25, 3.25), col = "red", lwd = 2,
     main = "Comparison of true and fitted value")
points(x_test, pred_mean, col = "blue", lwd = 2)
legend("bottomright", legend = c("truth", "fitted"),
       lwd=2, col = c("red", "blue"), bty = "n")


# 2 検証データの使用/不使用の比較 --------------------------------------------------

# モデル構築
# --- 訓練データのグループを抽出
gp_model <- GPModel(group_data = group[train_ind])
gp_model$set_prediction_data(group_data_pred = group[-train_ind])


# *** 検証データを使用 ****************************************

# 学習
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
            early_stopping_rounds = 5,
            use_gp_model_for_validation = TRUE)

# 最良イテレーション
bst$best_iter

# 最良テストエラー
bst$best_score

# プロット作成
bst$record_evals$test$l2$eval %>%
  unlist() %>%
  plot(1:length(.), ., type = "l", lwd = 2, col = "blue",
     xlab = "iteration", ylab = "Validation error",
       main = "Validation error vs. boosting iteration")


# *** 検証データを不使用 **************************************

# 学習
# --- use_gp_model_for_validation = FALSE
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
                 early_stopping_rounds = 5,
                 use_gp_model_for_validation = FALSE)

# 最良イテレーション
bst$best_iter

# 最良テストエラー
bst$best_score

# プロット作成
bst$record_evals$test$l2$eval %>%
  unlist() %>%
  plot(1:length(.), ., type = "l", lwd = 2, col = "blue",
     xlab = "iteration", ylab = "Validation error",
       main = "Validation error vs. boosting iteration")



# 3 クロスバリデーションで最良イテレーションを決定する --------------------------------

# モデル構築
# --- 訓練データのグループを抽出
gp_model <- GPModel(group_data = group)

# データオブジェクト作成
dataset <- gpb.Dataset(data = X, label = y)

# ツリーパラメータ
params <-
  list(learning_rate = 0.05,
       max_depth = 6,
       min_data_in_leaf = 5,
       objective = "regression_l2")

# クロスバリデーション
bst <-
  gpb.cv(params = params,
         data = dataset,
         gp_model = gp_model,
         use_gp_model_for_validation = TRUE,
         nrounds = 100,
         nfold = 10,
         eval = "l2",
         early_stopping_rounds = 5)

# 最良イテレーション
bst$best_iter


# 4 ニュートン更新でツリー学習-----------------------------------

# モデル構築
# --- 訓練データのグループを抽出
gp_model <- GPModel(group_data = group[train_ind])
gp_model$set_prediction_data(group_data_pred = group[-train_ind])

# 学習
# --- leaves_newton_update = TRUE
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
            early_stopping_rounds = 5,
            use_gp_model_for_validation = TRUE,
            leaves_newton_update = TRUE)

# 最良イテレーション
bst$best_iter

# 最良テストエラー
bst$best_score

# プロット作成
bst$record_evals$test$l2$eval %>%
  unlist() %>%
  plot(1:length(.), ., type = "l", lwd = 2, col = "blue",
       xlab = "iteration", ylab = "Validation error",
       main = "Validation error vs. boosting iteration")


# ＜参考＞
# gpboost()を使って学習
bst <-
  gpboost(data = dtrain,
          gp_model = gp_model,
          nrounds = 100,
          objective = "regression_l2",
          verbose = 1,
          leaves_newton_update = TRUE)


