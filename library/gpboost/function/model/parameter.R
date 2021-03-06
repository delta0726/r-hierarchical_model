# ***********************************************************************************************
# Function  : parameter
# Objective : GPboostで使用するパラメータ
# Created by: Owner
# Created on: 2021/04/08
# URL       : https://github.com/fabsig/GPBoost/blob/master/docs/Main_parameters.rst
# ***********************************************************************************************



# ＜目次＞
# 1 ツリーブースティングのパラメータ
# 1-1 num_iteration
# 1-2 learning_rate
# 1-3 max_depth
# 1-4 min_data_in_leaf
# 1-5 num_leaves
# 1-6 train_gp_model_cov_pars
# 1-7 use_gp_model_for_validation
# 1-8 leaves_newton_update
# 1-9 lambda_l1 / lambda_l2
# 1-10 max_bin
# 1-11 boosting
# 1-12 num_threads
# 1-13 early_stopping_round
# 1-14 max_delta_step


# 2 ガウス過程とランダム効果のパラメータ
# 2-1 likelihood
# 2-2 group_data
# 2-3 group_rand_coef_data
# 2-4 ind_effect_group_rand_coef
# 2-5 gp_coords
# 2-6 gp_rand_coef_data
# 2-7 cov_function
# 2-8 cov_fct_shape
# 2-9 vecchia_approx
# 2-10 num_neighbors
# 2-11 vecchia_ordering
# 2-12 vecchia_pred_type
# 2-13 num_neighbors_pred
# 2-14 cluster_ids

# 3 目的に応じたソリューション
# 3-1 訓練スピードを上げる設定
# 3-2 推測精度を向上させる
# 3-3 過学習対策の設定


# 1 ツリーブースティングのパラメータ ------------------------------------------------------

# ＜ポイント＞
# - ツリーはnum_leaves又はmax_depthに達するまで、情報ゲインを最大化するリーフノードを分割して成長
#   --- max_depthでツリーをコントロールする場合はを調整する場合は、num_leavesに大きな値に設定するのが安全


# 1-1 num_iteration -------------------------------------------------

# ＜ポイント＞
# 別名       ：nrounds
# デフォルト値：100
# 入力値     ：整数
# 制約条件    ：num_iterations >= 0

# ＜概要＞
# - ブースティングのイテレーション回数
# - 特に回帰設定の場合、間違いなく最も重要な調整パラメーター


# 1-2 learning_rate -------------------------------------------------

# ＜ポイント＞
# 別名       ：shrinkage_rate / eta
# デフォルト値：0.1
# 入力値     ：ダブル型
# 制約条件    ：learning_rate >= 0

# ＜概要＞
# - 減衰パラメータ
# - 値が小さいほど予測精度が高いが、多くのブースティング反復が必要となり計算時間が必要
#   --- num_leavesの値が高すぎると過学習となり、低すぎると未学習となる
# - max_depthのパラメータと一緒に調整する


# 1-3 max_depth -------------------------------------------------

# ＜ポイント＞
# 別名       ：なし
# デフォルト値：-1
# 入力値     ：整数値
# 制約条件   ：なし

# ＜概要＞
# - ツリーの木の深さ
# - 0以下は制限なしを意味する（NULLを入力してもよい）
# - 学習に対して強い制約となるので、他のパラメータと併せてチューニングする


# 1-4 min_data_in_leaf -----------------------------------------------

# ＜ポイント＞
# 別名       ：min_data_per_leaf / min_data / min_child_samples
# デフォルト値：20
# 入力値     ：整数値
# 制約条件   ：min_data_in_leaf > 0

# ＜概要＞
# - 決定木のノード(葉)の最小データ数を指定
# - 値が大きいと決定木が深く育つのを抑えるため過学習を抑制する（逆に未学習となる場合もある）
# - min_data_in_leafは訓練データのレコード数とnum_leavesに大きく影響される


# 1-5 num_leaves -----------------------------------------------------

# ＜ポイント＞
# 別名       ：min_data_per_leaf / min_data / min_child_samples
# デフォルト値：31
# 入力値     ：整数値
# 制約条件   ：1 < num_leaves <= 131072

# ＜概要＞
# - 決定木の複雑度を調整（決定木の葉の最大数）
# - num_leavesの値が高すぎると過学習となり、低すぎると未学習となる
# - ひとつの分割だけがあるとノードは2つになり、もう一回分割が起こるとノードは3になる
#   --- 分割数 + 1 だけ末端ノードは生成される
# - floor(2^max_depth * 0.7)などで指定するケースが多い


# 1-6 train_gp_model_cov_pars -----------------------------------------

# ＜ポイント＞
# 別名       ：なし
# デフォルト値：TRUE
# 入力値     ：TRUE / FALSE
# 制約条件   ：なし

# ＜概要＞
# - ガウス過程/変量効果モデルの共分散パラメーターは、GPBoostアルゴリズムのすべてのブースティング反復でトレーニング


# 1-7 use_gp_model_for_validation -----------------------------------------

# ＜ポイント＞
# 別名       ：なし
# デフォルト値：TRUE
# 入力値     ：TRUE / FALSE
# 制約条件   ：なし

# ＜概要＞
# - GPBoostアルゴリズムを使用するときに、検証データの予測を計算するためにガウス過程/変量効果モデルも使用


# 1-8 leaves_newton_update ------------------------------------------------

# ＜ポイント＞
# 別名       ：なし
# デフォルト値：FALSE
# 入力値     ：TRUE / FALSE
# 制約条件   ：なし

# ＜概要＞
# - TRUEなら勾配ステップの後に木の葉に対してニュートン更新ステップが実行
# - ガウスデータのGPBoostアルゴリズムにのみ適用され、非ガウスデータには使用できません。


# 1-9 lambda_l1 / lambda_l2 -----------------------------------------------

# ＜ポイント＞
# 別名       ：reg_alpha(l1) / reg_lambda(2)
# デフォルト値：0
# 入力値     ：ダブル型
# 制約条件   ：lambda_l1 >= 0.0

# ＜概要＞
# - TRUEなら勾配ステップの後に木の葉に対してニュートン更新ステップが実行
# - ガウスデータのGPBoostアルゴリズムにのみ適用され、非ガウスデータには使用できない
# - デフォルトでは 0.1 ぐらいを使うことが多い
# - L1正則化にあたるのであまり大きな値を使用するとかなり重要な変数以外を無視するようなモデルになってしまう
#   --- 精度を求めている場合あまり大きくしないほうが良い


# 1-10 max_bin -----------------------------------------------------------

# ＜ポイント＞
# 別名       ：なし
# デフォルト値：255
# 入力値     ：整数値
# 制約条件   ：max_bin > 1

# ＜概要＞
# - 一つの分岐に入るデータ数の最大値を指定
# - 小さい数を指定することで強制的なデータ間の分離を可能にして精度を上げることができる
#   --- 大きな数を指定することにより一般性を強めることができる
#   --- 結果として過学習抑制につながる


# 1-11 boosting ------------------------------------------------------------

# ＜ポイント＞
# 別名       ：boosting_type, boost
# デフォルト値：gbdt
# 入力値     ：文字列


# ＜概要＞
# - gbdt ：従来の勾配ブースティング決定木
# - rf   ：ランダムフォレスト
# - dart ：ドロップアウトは複数の加法回帰ツリーを使用
# - goss ：勾配ベースの片側サンプリング

# ＜注意事項＞
# -  基本は勾配ブースティングをしたいのでデフォルトの gbdt を使うと良い


# 1-12 num_threads ---------------------------------------------------------

# ＜ポイント＞
# 別名       ：num_thread, nthread, nthreads, n_jobs
# デフォルト値：0
# 入力値     ：整数値

# ＜注意事項＞
# - デフォルトの0はOpenMPのデフォルトのスレッド数を意味する
#   --- 最高の速度を得るには、これをスレッドの数ではなく、実際のCPUコアの数に設定
# - データセットが小さい場合は、大きく設定しすぎないでください（オーバーヘッドでかえって遅い）
# - 並列学習の場合は全てののCPUコアを使用しない（ネットワーク通信のパフォーマンスが低下する）


# 1-13 early_stopping_round -----------------------------------------------

# ＜ポイント＞
# 別名       ：early_stopping_rounds / early_stopping / n_iter_no_change
# デフォルト値：0
# 入力値     ：整数値

# ＜注意事項＞
# - <= 0は、無効にすることを意味します
# - 最後の検証からnラウンドでメトリックが改善されない場合にトレーニングを停止


# 1-14 max_delta_step -----------------------------------------------------

# ＜ポイント＞
# 別名       ：max_tree_output / max_leaf_output
# デフォルト値：0
# 入力値     ：ダブル型

# ＜注意事項＞
# - 木の葉の最大出力を制限するために使用
# - <= 0は、無効にすることを意味します
# - 葉の最終的な最大出力はlearning_rate * max_delta_stepとなる


# 2 ガウス過程とランダム効果のパラメータ ----------------------------------------------------------

# 2-1 likelihood ----------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：gaussian
# 入力値     ：文字列
# 入力候補   ：gaussian, bernoulli_probit(=binary), bernoulli_logit, poisson, gamma

# ＜概要＞
# -


# 2-2 group_data ---------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：gaussian
# 入力値     ：2次元配列 / 行列

# ＜概要＞
# - グループ化された変量効果のグループレベルのラベル


# 2-3 group_rand_coef_data ----------------------------------------------------

# ＜ポイント＞
# デフォルト値：None
# 入力値     ：2次元配列 / 行列

# ＜概要＞
# - グループ化されたランダム係数の共変量データ


# 2-4 ind_effect_group_rand_coef ------------------------------------------------

# ＜ポイント＞
# デフォルト値：None
# 入力値     ：2次元配列 / 行列

# ＜概要＞
# - すべてのランダム係数を「ベース」切片のグループ化されたランダム効果に関連付けるインデックス
# - カウントは1から始まります。


# 2-5 gp_coords -----------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：None
# 入力値     ：2次元配列 / 行列

# ＜概要＞
# - ガウス過程の座標（特徴）


# 2-6 gp_rand_coef_data ----------------------------------------------------------

# ＜ポイント＞
# デフォルト値：None
# 入力値     ：2次元配列 / 行列

# ＜概要＞
# - ガウス過程のランダム係数の共変量データ


# 2-7 cov_function --------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：exponential
# 入力値     ：文字列
# 入力候補   ：exponential, gaussian, matern, powered_exponential

# ＜概要＞
# - ガウス過程のランダム係数の共変量データ


# 2-8 cov_fct_shape --------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：0
# 入力値     ：ダブル型
# 入力候補   ：exponential, gaussian, matern, powered_exponential

# ＜概要＞
# - 共分散関数の形状パラメーター


# 2-9 vecchia_approx -------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：False
# 入力値     ：TRUE / FALSE

# ＜概要＞
# - TRUEの場合、Vecchia近似が使用されます


# 2-10 num_neighbors -------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：30
# 入力値     ：整数型

# ＜概要＞
# - Vecchia近似のパラメーター


# 2-11 vecchia_ordering -------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：none
# 入力値     ：文字列
# 入力候補   ：none, random

# ＜概要＞
# - Vecchia近似で使用される順序


# 2-12 vecchia_pred_type -------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：order_obs_first_cond_obs_only
# 入力値     ：文字列
# 入力候補   ：order_obs_first_cond_obs_only / order_obs_first_cond_all
#           ：order_pred_first / latent_order_obs_first_cond_all

# ＜概要＞
# order_obs_first_cond_obs_only：観測データが最初に順序付けられ、隣接データは観測ポイントのみ
# order_obs_first_cond_all     ：観測データが最初に順序付けられ、すべてのポイントから隣接データが選択されます（観測+予測）
# latent_order_obs_first_cond_obs_only：予測データが最初に順序付けられます
# latent_order_obs_first_cond_all：潜在プロセスと観測データのVecchia近似が最初に順序付けられ、すべての点から近傍が選択されます


# 2-13 num_neighbors_pred -------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：Null
# 入力値     ：integer or Null

# ＜概要＞
# - 予測を行うためのVecchia近似の近傍の数


# 2-14 cluster_ids -------------------------------------------------------------

# ＜ポイント＞
# デフォルト値：Null
# 入力値     ：ベクトル or NULL

# ＜概要＞
# - 変量効果/ガウス過程の独立した実現を示すID /ラベル（同じ値=同じプロセスの実現）



# 3 目的に応じたソリューション -------------------------------------------------------------------

# 3-1 訓練スピードを上げる設定 ------------------------------------------------------

# - bagging_fraction（初期値1.0）とbagging_freq（初期値0）を使う
# - feature_fraction（初期値1.0）で特徴量のサブサンプリングを指定
# - 小さいmax_bin（初期値 255）を使う
# - save_binary（初期値 False）を使う
# - 分散学習を使う（公式ガイドはこちら）


# 3-2 推測精度を向上させる -----------------------------------------------------------

# - 大きいmax_bin（初期値255）を使う
# - 小さいlearning_rate(初期値0.1)と大きいnum_iterations(初期値100)を使う
# - 大きいnum_leaves（初期値31）を使う
# - 訓練データのレコード数を増やす（可能であれば）


# 3-3 過学習対策の設定 ---------------------------------------------------------------

# - 小さいmax_binを使う（初期値255）
# - 小さいnum_leavesを使う（初期値31）
# - min_data_in_leaf（初期値20）とmin_sum_hessian_in_leaf(初期値1e-3)を使う
# - bagging_fraction（初期値1.0）とbagging_freq（初期値0）を使う
# - feature_fraction（初期値1.0）で特徴量のサブサンプリングを指定
# - 訓練データのレコード数を増やす（可能であれば）
# - lambda_l1（初期値0.0）、lambda_l2（初期値0.0）、min_gain_to_split（初期値0.0）で正則化を試す
# - max_depth（初期値-1）を指定して決定木が深くならないよう調整する

