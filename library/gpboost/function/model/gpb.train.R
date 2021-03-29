# ***********************************************************************************************
# Function  : gpb.train
# Objective : gpboostの学習を行う
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.train
# ***********************************************************************************************


# ＜概要＞



# ＜構文＞
# gpb.train(params = list(), data, nrounds = 100L, gp_model = NULL,
#   use_gp_model_for_validation = TRUE, train_gp_model_cov_pars = TRUE,
#   valids = list(), obj = NULL, eval = NULL, verbose = 1L,
#   record = TRUE, eval_freq = 1L, init_model = NULL, colnames = NULL,
#   categorical_feature = NULL, early_stopping_rounds = NULL,
#   callbacks = list(), reset_data = FALSE, ...)

# ＜引数＞
# - params = list()
# - data, nrounds = 100L
# - gp_model = NULL,
# - use_gp_model_for_validation = TRUE
# - train_gp_model_cov_pars = TRUE,
# - valids = list()
# - obj = NULL
# - eval = NULL
# - verbose = 1L,
# - record = TRUE
# - eval_freq = 1L
# - init_model = NULL
# - colnames = NULL,
# - categorical_feature = NULL
# - early_stopping_rounds = NULL,
# - callbacks = list()
# - reset_data = FALSE



# ＜目次＞
# 0 準備
# 1 Combine tree-boosting and grouped random effects model


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 Combine tree-boosting and grouped random effects model ----------------

# モデル構築
# --- ランダム効果
gp_model <- GPModel(group_data = group_data[,1], likelihood = "gaussian")

# データセット作成
dtrain <- gpb.Dataset(data = X, label = y)

# Train model
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
pred$random_effect_mean # Predicted mean
pred$random_effect_cov # Predicted variances
pred$fixed_effect # Predicted fixed effect from tree ensemble
# Sum them up to otbain a single prediction
pred$random_effect_mean + pred$fixed_effect



# 2 Combine tree-boosting and Gaussian process model----------------

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
pred$random_effect_mean # Predicted (posterior) mean of GP
pred$random_effect_cov # Predicted (posterior) covariance matrix of GP
pred$fixed_effect # Predicted fixed effect from tree ensemble
# Sum them up to otbain a single prediction
pred$random_effect_mean + pred$fixed_effect


#--------------------Using validation data-------------------------
set.seed(1)
train_ind <- sample.int(length(y),size=250)
dtrain <- gpb.Dataset(data = X[train_ind,], label = y[train_ind])
dtest <- gpb.Dataset.create.valid(dtrain, data = X[-train_ind,], label = y[-train_ind])
valids <- list(test = dtest)
gp_model <- GPModel(group_data = group_data[train_ind,1], likelihood="gaussian")
# Need to set prediction data for gp_model
gp_model$set_prediction_data(group_data_pred = group_data[-train_ind,1])
# Training with validation data and use_gp_model_for_validation = TRUE
bst <- gpb.train(data = dtrain,
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
print(paste0("Optimal number of iterations: ", bst$best_iter,
             ", best test error: ", bst$best_score))
# Plot validation error
val_error <- unlist(bst$record_evals$test$l2$eval)
plot(1:length(val_error), val_error, type="l", lwd=2, col="blue",
     xlab="iteration", ylab="Validation error", main="Validation error vs. boosting iteration")


#--------------------Do Newton updates for tree leaves---------------
# Note: run the above examples first
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
print(paste0("Optimal number of iterations: ", bst$best_iter,
             ", best test error: ", bst$best_score))
# Plot validation error
val_error <- unlist(bst$record_evals$test$l2$eval)
plot(1:length(val_error), val_error, type="l", lwd=2, col="blue",
     xlab="iteration", ylab="Validation error", main="Validation error vs. boosting iteration")


#--------------------GPBoostOOS algorithm: GP parameters estimated out-of-sample----------------
# Create random effects model and dataset
gp_model <- GPModel(group_data = group_data[,1], likelihood="gaussian")
dtrain <- gpb.Dataset(X, label = y)
params <- list(learning_rate = 0.05,
               max_depth = 6,
               min_data_in_leaf = 5,
               objective = "regression_l2")
# Stage 1: run cross-validation to (i) determine to optimal number of iterations
#           and (ii) to estimate the GPModel on the out-of-sample data
cvbst <- gpb.cv(params = params,
                data = dtrain,
                gp_model = gp_model,
                nrounds = 100,
                nfold = 4,
                eval = "l2",
                early_stopping_rounds = 5,
                use_gp_model_for_validation = TRUE,
                fit_GP_cov_pars_OOS = TRUE)
print(paste0("Optimal number of iterations: ", cvbst$best_iter))
# Estimated random effects model
# Note: ideally, one would have to find the optimal combination of
#               other tuning parameters such as the learning rate, tree depth, etc.)

# サマリー
gp_model %>% summary()

# Stage 2: Train tree-boosting model while holding the GPModel fix
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
