# ***********************************************************************************************
# Title     : Grouped Random Effects Models
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/25
# URL       : https://glennwilliams.me/r4psych/mixed-effects-models.html
# ***********************************************************************************************


# ＜準備＞
# 0 準備
# 1 モデル構築と学習を別に行う
# 2 モデルを指定して直接学習する
# 3 学習の際にオプティマイザーを別途指定する
# 4 optim()を用いて学習する
# 5 予測
# 6 プロット表示


# 0 準備 ---------------------------------------------------------------------------------

# ワークスペースクリア
rm(list = ls())

# ライブラリ
library(tidyverse)
library(magrittr)
library(gpboost)


# データ準備
source("library/gpboost/demo/func/generate_data_31.R")

# 変数確認
ls()

# データ確認
tibble(y = y, group = group)
group %>% table()


# 1 モデル構築と学習を別に行う -----------------------------------------------------------------

# モデル構築
gp_model <- GPModel(group_data = group)

# 学習
gp_model %>% fit(y = y, params = list(std_dev = TRUE))

# 結果サマリー
gp_model %>% summary()


# 2 モデルを指定して直接学習する ----------------------------------------------------------------

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group,
             y = y,
             params = list(std_dev = TRUE))

# 結果サマリー
gp_model %>% summary()


# 3 学習の際にオプティマイザーを別途指定する -------------------------------------------------------

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group, y = y,
             params = list(optimizer_cov = "gradient_descent",
                           lr_cov = 0.1, use_nesterov_acc = TRUE,
                           maxit = 100, std_dev = TRUE, trace = TRUE))

# 結果サマリー
gp_model %>% summary()

# Evaluate negative log-likelihood
gp_model$neg_log_likelihood(cov_pars = c(sigma2, sigma2_1), y = y)


# 4 optim()を用いて学習する -------------------------------------------------------------------

# モデル構築
gp_model <- GPModel(group_data = group)

# 学習（最適化）
optim(par = c(1, 1), fn = gp_model$neg_log_likelihood, y = y, method = "Nelder-Mead")


# 5 予測 ------------------------------------------------------------------------------------

# モデル構築＆学習
# --- 最終的な予測を出力するモデル
gp_model <- fitGPModel(group_data = group, y = y, params = list(std_dev = TRUE))

# 予測
group_test <- 1:m
pred <- gp_model %>% predict(group_data_pred = group_test)


# 6 プロット表示 -------------------------------------------------------------------------------

# プロット作成
# Compare true and predicted random effects
b %>%
  plot(pred$mu, xlab = "truth", ylab = "predicted",
       main = "Comparison of true and predicted random effects")

# 45度線の追加
abline(a = 0, b = 1)

# Also predict covariance matrix
group_test = c(1, 1, 2, 2, -1, -1)
pred <- gp_model %>% predict(group_data_pred = group_test, predict_cov_mat = TRUE)
pred$mu# Predicted mean
pred$cov# Predicted covariance

