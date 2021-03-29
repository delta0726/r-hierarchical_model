# ***********************************************************************************************
# Function  : fit
# Objective : 
# Created by: Owner
# Created on: 2021/03/28
# URL       : https://www.rdocumentation.org/packages/gpboost/versions/0.5.0/topics/fit
# ***********************************************************************************************


# ＜概要＞
# - fitメソッドのジェネレータ関数


# ＜構文＞
# fit(gp_model, y, X, params, fixed_effects = NULL)


# ＜引数＞
# - gp_model     ；GPModelオブジェクト
# - y            ：応答変数データを含むベクトル
# - X            ：固定効果の共変量データを含む行列（=線形回帰項）
# - params       ：パラメータ
# - fixed_effects：トレーニング中に固定されたままのオプションの外部固定効果のベクトル


# ＜パラメータ＞
# optimizer_cov       ：共分散パラメーターの推定に使用されるオプティマイザー
# optimizer_coef      ：線形回帰係数の推定に使用されるオプティマイザー
# maxit               ：最適化アルゴリズムの最大反復回数（デフォルト= 1000）
# delta_rel_conv      ：パラメーターの相対的な変化がこの値を下回る場合は最適化を停止（デフォルト= 1E-6）
# init_coef           ：回帰係数の初期値（デフォルト= NULL）
# init_cov_pars       ：ガウス過程と変量効果の共分散パラメーターの初期値（デフォルト= NULL）
# lr_coef             ：勾配降下法が使用されている場合の固定効果回帰係数の学習率（デフォルト=0.1）
# lr_cov              ：共分散パラメーターの学習率（デフォルト値はモードによって異なる）
# use_nesterov_acc    ：TRUEの場合Nesterovアクセラレーションが使用
# acc_rate_coef       ：Nesterov加速の回帰係数の加速率
# acc_rate_cov        ：Nesterov加速の共分散パラメーターの加速率
# momentum_offset     ：最初に運動量が適用されなかった反復の数（デフォルト=2）
# trace               ：TRUEの場合、勾配の値がいくつかの反復で出力
# convergence_criterion ：最適化アルゴリズムを終了するために使用される収束基準
# std_dev               ：TRUEの場合、標準偏差が共分散パラメーターに対して計算

