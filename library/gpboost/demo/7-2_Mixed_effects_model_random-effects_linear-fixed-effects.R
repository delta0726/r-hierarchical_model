# ***********************************************************************************************
# Title     : Grouped Random Effects Models
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/25
# URL       : https://glennwilliams.me/r4psych/mixed-effects-models.html
# ***********************************************************************************************


# ＜準備＞
# 0 準備
# 1 混合効果モデル（ランダム効果+線形固定効果）
# 2 Two crossed random effects and a random slope
# 3 2重ネストのランダム効果


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


# 1 混合効果モデル（ランダム効果+線形固定効果） ----------------------------------------------------

# *** モデル構築と学習を別に行う *******************************************

# モデル構築
gp_model <- GPModel(group_data = group)

# 学習
gp_model %>% fit(y = y_lin, X = X, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# *** モデル構築と学習を別に行う ******************************************

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group,
             y = y_lin, X = X,
             params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()



# 2 Two crossed random effects and a random slope --------------------------------

# *** モデル構築と学習を別に行う *******************************************

# モデル構築
# indicate that the random slope is for the first random effect
gp_model <- 
  GPModel(group_data = cbind(group, group_crossed),
          group_rand_coef_data = x, 
          ind_effect_group_rand_coef = 1)

# 学習
gp_model %>% fit(y = y_crossed_random_slope, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# *** モデル構築と学習を別に行う ******************************************

# モデル構築＆学習
# Alternatively, define and fit model directly using fitGPModel
gp_model <- 
  fitGPModel(group_data = cbind(group,group_crossed), 
             group_rand_coef_data = x, 
             ind_effect_group_rand_coef = 1, 
             y = y_crossed_random_slope, params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()


# 3 2重ネストのランダム効果 --------------------------------------------------------

# グループ作成
# --- 2重グループ
group_data <- cbind(group, group_nested)

# モデル構築＆学習
gp_model <-
  fitGPModel(group_data = group_data,
             y = y_nested,
             params = list(std_dev = TRUE))

# サマリー
gp_model %>% summary()
