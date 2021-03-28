# ***********************************************************************************************
# Function  : gpb.cv
# Objective : ブースティングの反復回数を決定するための相互検証関数
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.cv
# ***********************************************************************************************


# ＜概要＞
# -


# ＜構文＞
# gpb.cv（params = list(),data,nrounds = 100L,gp_model = NULL,
#   use_gp_model_for_validation = TRUE,fit_GP_cov_pars_OOS = FALSE,
#   train_gp_model_cov_pars = TRUE,folds = NULL,nfold = 4L,
#   label = NULL,weight = NULL,obj = NULL,eval = NULL,verbose = 1L,
#   record = TRUE,eval_freq = 1L,showsd = FALSE,stratified = TRUE,
#   init_model = NULL,colnames = NULL,categorical_feature = NULL,
#   Early_stopping_rounds = NULL,callbacks = list(),reset_data = FALSE,
#   delete_boosters_folds = FALSE,...）


# ＜引数＞
# params = list()
# data
# nrounds = 100L,g
# p_model = NULL
# use_gp_model_for_validation = TRUE
# fit_GP_cov_pars_OOS = FALSE
# train_gp_model_cov_pars = TRUE
# folds = NULL,nfold = 4L
# label = NULL
# weight = NULL
# obj = NULL
# eval = NULL
# verbose = 1L
# record = TRUE
# eval_freq = 1L
# showsd = FALSE
# stratified = TRUE
# init_model = NULL
# colnames = NULL
# categorical_feature = NULL
# Early_stopping_rounds = NULL
# callbacks = list()
# reset_data = FALSE
# delete_boosters_folds = FALSE,...）




# ＜アーリーストッピング＞
# - 定の検証セットでのモデルのパフォーマンスが数回の連続した反復で改善されない場合にプロセスを停止すること
# - params引数でearly_stopping_roundsの設定を有効にするとアーリーストッピングが適用される
#   --- デフォルトでは、すべてのメトリックが早期停止の対象と見なされます。
# - 早期停止の最初のメトリックのみを考慮したい場合は、paramsでfirst_metric_only = TRUEを渡します

# ＜目次＞
# 0 準備
# 1 関数実行


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")

# データ確認
X


# Create random effects model and dataset
gp_model <- GPModel(group_data = group_data[,1], likelihood="gaussian")
dtrain <- gpb.Dataset(X, label = y)
params <- list(learning_rate = 0.05,
               max_depth = 6,
               min_data_in_leaf = 5,
               objective = "regression_l2")
# Run CV
cvbst <- gpb.cv(params = params,
                data = dtrain,
                gp_model = gp_model,
                nrounds = 100,
                nfold = 4,
                eval = "l2",
                early_stopping_rounds = 5,
                use_gp_model_for_validation = TRUE)
print(paste0("Optimal number of iterations: ", cvbst$best_iter,
             ", best test error: ", cvbst$best_score))