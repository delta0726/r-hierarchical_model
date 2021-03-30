# ***********************************************************************************************
# Function  : gpb.cv
# Objective : ブースティングの反復回数を決定するためのクロスバリデーション
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/gpb.cv
# ***********************************************************************************************


# ＜概要＞
# - ブースティングのイテレーション回数とベストスコアを決定するためのクロスバリデーション


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
# - params                      ：lightgbmの学習パラメータ（gpboostを参照）
# - data                        ：訓練データのgpb.Datasetオブジェクト
# - nrounds                     ：ブースティングの反復回数（=ツリーの数）
# - gp_model                    ：GPModelオブジェクト（ガウス過程/グループ化ランダム効果）
# - use_gp_model_for_validation ：TRUEの場合、検証データの予測を計算するためにガウス過程も使用（ツリーモデルに加えて）
# - fit_GP_cov_pars_OOS         ：TRUEの場合、共分散パラメーターは最適な反復回数を使用した検証データのサOOS予測を使用して推定
# - train_gp_model_cov_pars     ：TRUEの場合、ガウス過程の共分散パラメーターはすべてのブースティング反復で推定
# - folds                       ：事前に定義したFold
# - nfold                       ：CVの分割数
# - label                       ：ラベルをベクトルで指定
# - weight                      ：ウエイトをベクトルで指定
# - obj                         ：目的関数を指定（gpboostを参照）
# - eval                        ：評価関数を文字列又は関数で指定（gpboostを参照）
# - verbose                     ：0(非表示) / 1(表示)
# - record                      ：TRUEは、メッセージをbooster$record_evalsに記録します
# - eval_freq                   ：メッセージ出力頻度
# - showsd                      ：TRUEの場合、クロスバリデーションの標準偏差を表示
# - stratified                  ：TRUEの場合、出力ラベルによる層別サンプリングによるクロスバリデーションを的よう
# - init_model                  ：初期モデルの指定（gpb.Boosterオブジェクトの保存先）
# - colnames                    ：特徴量の列名（NULLの場合はデータセットのものを使用）
# - categorical_feature         ：
# - Early_stopping_rounds       ：数値で指定、スコアが上昇してから停止までの回数
# - callbacks                   ：各イテレーションで適用されるコールバック関数をリストで指定
# - reset_data                  ：TRUEの場合、ブースターモデルが予測モデルに変換されメモリと元のデータセットが解放。
# - delete_boosters_folds       ：TRUEの場合、foldごとののブースターが削除


# ＜アーリーストッピング＞
# - 定の検証セットでのモデルのパフォーマンスが数回の連続した反復で改善されない場合にプロセスを停止すること
# - params引数でearly_stopping_roundsの設定を有効にするとアーリーストッピングが適用される
#   --- デフォルトでは、すべてのメトリックが早期停止の対象と見なされます。
# - 早期停止の最初のメトリックのみを考慮したい場合は、paramsでfirst_metric_only = TRUEを渡します


# ＜目次＞
# 0 準備
# 1 データ確認
# 2 モデリング
# 3 クロスバリデーション
# 4 出力内容


# 0 準備 -------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(gpboost)
library(Hmisc)

# データロード
data(GPBoost_data, package = "gpboost")


# 1 データ確認 -------------------------------------------------------------------

# メインデータ
X %>% as_tibble()
y %>% as_tibble()

# グループデータ
group_data %>% as_tibble()


# 2 モデリング ------------------------------------------------------------------

# モデル構築
# --- ランダム効果モデル
gp_model <- GPModel(group_data = group_data[, 1], likelihood = "gaussian")

# データセットの作成
dtrain <- gpb.Dataset(data = X, label = y)

# パラメータ設定
# --- LightGBM
params <- list(learning_rate = 0.05,
               max_depth = 6,
               min_data_in_leaf = 5,
               objective = "regression_l2")


# 3 クロスバリデーション ------------------------------------------------------------

# CVの実行
cvbst <-
  gpb.cv(params = params,
         data = dtrain,
         gp_model = gp_model,
         nrounds = 100,
         nfold = 4,
         eval = "l2",
         early_stopping_rounds = 5,
         use_gp_model_for_validation = TRUE)


# 4 出力内容 ----------------------------------------------------------------------

# 結果確認
cvbst %>% print()
cvbst %>% names()

# ブースター
# --- delete_boosters_folds = TRUE の場合は格納されない
cvbst$boosters %>% list.tree(3)

# イテレーション回数
cvbst$best_iter

# 最良スコア
cvbst$best_score

# 評価履歴
cvbst$record_evals %>% list.tree(5)

