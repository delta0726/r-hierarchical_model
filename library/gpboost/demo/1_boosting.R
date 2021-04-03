# ***********************************************************************************************
# Title     : Boosting
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://github.com/fabsig/GPBoost/blob/master/R-package/demo/boosting.R
# ***********************************************************************************************



# ＜目次＞
# 0 準備
# 1 gpboost関数に行列データを指定して学習
# 2 gpboost関数に独自オブジェクトを指定して学習
# 3 gpb.train関数に独自オブジェクトを指定して学習
# 4 verbose引数を指定して学習
# 5 予測データの作成
# 6 プロット確認
# 7 検証データセットを用いた学習
# 8 マルコフ連鎖ブースティング


# 0 準備 ---------------------------------------------------------------------------------

# ワークスペースクリア
rm(list = ls())

# ライブラリ
library(tidyverse)
library(magrittr)
library(gpboost)


# データ準備
source("library/gpboost/demo/func/data_boosting.R")

# 変数確認
ls()

# クラス確認
Xtrain %>% class()
ytrain %>% class()

# データ確認
data.frame(Xtrain, ytrain) %>% set_colnames(c("X1", "X2", "y")) %>% as_tibble()
data.frame(Xtest, ytest) %>% set_colnames(c("X1", "X2", "y")) %>% as_tibble()


# 1 gpboost関数に行列データを指定して学習 ---------------------------------------------

# モデル学習
# --- 行列でデータを指定
bst <- gpboost(data = Xtrain,
               label = ytrain,
               nrounds = 40,
               learning_rate = 0.1,
               max_depth = 6,
               min_data_in_leaf = 5,
               objective = "regression_l2",
               verbose = 0)


# 2 gpboost関数に独自オブジェクトを指定して学習 -----------------------------------------

# 独自オブジェクトの定義
dtrain <- gpb.Dataset(data = Xtrain, label = ytrain)

# モデル学習
# --- 独自オブジェクトでデータを指定
bst <-
  gpboost(data = dtrain,
          nrounds = 40,
          learning_rate = 0.1,
          max_depth = 6,
          min_data_in_leaf = 5,
          objective = "regression_l2",
          verbose = 0)


# 3 gpb.train関数に独自オブジェクトを指定して学習 -----------------------------------------

# 独自オブジェクトの定義
dtrain <- gpb.Dataset(data = Xtrain, label = ytrain)

# モデル学習
bst <-
  gpb.train(data = dtrain,
            nrounds = 40,
            learning_rate = 0.1,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 0)


# 4 verbose引数を指定して学習 ----------------------------------------------------------

# モデル学習
# --- verboseあり
bst <-
  dtrain %>%
    gpboost(nrounds = 40,
            learning_rate = 0.1,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 1)


# 5 予測データの作成 -------------------------------------------------------------------

# 予測
pred <- bst %>% predict(data = Xtest)

# 確認
pred %>% as_tibble()

# モデル精度の検証
err <- mean((ytest-pred) ^ 2)
print(paste("test-RMSE =", err))


# 6 プロット確認 -------------------------------------------------------------------

# 正解データ
# --- ベクトル
# --- プロット用
x <- seq(from = 0, to = 1, length.out = 200)
Xtest_plot <- x %>% cbind(rep(0, length(x)))

# 予測データの作成
pred_plot <- bst %>% predict(data = Xtest_plot)

# プロット
plot(x, f1d(x),
     type = "l", ylim = c(-0.25, 3.25), col = "red", lwd = 2,
     main = "Comparison of true and fitted value")
lines(x, pred_plot, col = "blue", lwd = 2)
legend("bottomright", legend = c("truth", "fitted"),
       lwd=2, col = c("red", "blue"), bty = "n")


# 7 検証データセットを用いた学習 --------------------------------------------------------

# データオブジェクト作成
dtrain <- gpb.Dataset(data = Xtrain, label = ytrain)
dtest <- gpb.Dataset.create.valid(dtrain, data = Xtest, label = ytest)
valids <- list(test = dtest)


# eval引数をデフォルトで使用 ************************************

# モデル構築
bst <-
  gpb.train(data = dtrain,
            nrounds = 100,
            learning_rate = 0.1,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 1,
            valids = valids,
            early_stopping_rounds = 5)

# 確認
bst %>% print()

# 最適イテレーション
bst$best_iter


# eval引数を指定 **********************************************

# モデル構築
# --- eval引数を変更
bst <-
  gpb.train(data = dtrain,
            nrounds = 100,
            learning_rate = 0.1,
            max_depth = 6,
            min_data_in_leaf = 5,
            objective = "regression_l2",
            verbose = 1,
            valids = valids,
            eval = c("l2", "l1"),
            early_stopping_rounds = 5)

# 確認
bst %>% print()

# 最適イテレーション
bst$best_iter


# 8 マルコフ連鎖ブースティング -------------------------------------------------

# データオブジェクト作成
dtrain <- gpb.Dataset(data = Xtrain, label = ytrain)
dtest <- gpb.Dataset.create.valid(dtrain, data = Xtest, label = ytest)
valids <- list(test = dtest)

# モデル学習
# --- eval引数を変更
bst <- gpb.train(data = dtrain,
                 nrounds = 100,
                 learning_rate = 0.01,
                 max_depth = 6,
                 min_data_in_leaf = 5,
                 objective = "regression_l2",
                 verbose = 1,
                 valids = valids,
                 early_stopping_rounds = 5,
                 use_nesterov_acc = TRUE)

# 正解データ
# --- ベクトル
# --- プロット用
x <- seq(from = 0, to = 1, length.out = 200)
Xtest_plot <- x %>% cbind(rep(0, length(x)))

# 予測データの作成
pred_plot <- predict(bst, data = Xtest_plot)

# プロット作成
plot(x, f1d(x), type = "l",ylim = c(-0.25, 3.25), col = "red", lwd = 2,
     main = "Comparison of true and fitted value")
lines(x, pred_plot, col = "blue", lwd = 2)
legend("bottomright", legend = c("truth", "fitted"),
       lwd=2, col = c("red", "blue"), bty = "n")
