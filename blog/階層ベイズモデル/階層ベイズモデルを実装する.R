# ***********************************************************************************************
# Title     : 階層ベイズモデルを実装する：lme4とbrmsパッケージを用いたマルチレベルモデルの基礎
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : http://ryotamugiyama.com/wp-content/uploads/2016/01/hierarchicalbeyes.html
# ***********************************************************************************************


# ＜概要＞
# - 階層線形モデルにベイズを導入した｢階層ベイズモデル｣を学ぶ





# ＜目次＞
# 1 準備
# 2 データ加工
# 3 プロットで見る線形回帰モデル
# 4 線形回帰モデルで当てはめ
# 5 ランダム切片モデルで当てはめ


# 1 準備 ------------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(broom)
library(lme4)
library(lmerTest)
library(optimx)
library(boot)
library(sjPlot)
library(sjmisc)
library(sjlabelled)
library(brms)
library(conflicted)

# コンフリクト解消
conflict_prefer("filter", "dplyr")
conflict_prefer("lmer", "lme4")
conflict_prefer("add_case", "sjmisc")
conflict_prefer("ar", "brms")
conflict_prefer("as_factor", "sjlabelled")
conflict_prefer("chol2inv", "Matrix")
conflict_prefer("expand", "Matrix")
conflict_prefer("lag", "dplyr")
conflict_prefer("ngrps", "brms")
conflict_prefer("pack", "Matrix")
conflict_prefer("Position", "base")
conflict_prefer("rcond", "Matrix")
conflict_prefer("replace_na", "sjmisc")
conflict_prefer("step", "lmerTest")
conflict_prefer("unpack", "Matrix")

# データロード
widedata <- read_csv("blog/csv/Language.csv")

# データ確認
widedata %>% print()
widedata %>% glimpse()


# 2 データ加工 ------------------------------------------------------------------------------

# 生徒数が10人未満の学校を除外し、かつ500ケースを無作為に抽出したデータを作成
set.seed(111)
subdata <-
  widedata %>%
    select(ID:LangScore6) %>%
    subset(school != 1 & school != 7 & school != 17 & school != 24 & school != 28 & school != 29) %>%
    sample_n(size = 500)

# wideデータをlongデータに変換し、変数"id"を作成
longdata <-
  subdata %>%
    gather(time, score, LangScore1:LangScore6) %>%
    rename("id" = ID) %>%
    arrange(id)

# 文字列の削除
longdata$time <-
  as.numeric(gsub("LangScore","",longdata$time))

# データ確認
longdata %>% print()
longdata %>% glimpse()

# カテゴリ確認
longdata %>% map(table)


# 3 プロットで見る線形回帰モデル --------------------------------------------------------------

# ＜ポイント＞
# - id/schoolごとに個人が割り当てられており、時系列にスコア計測をしている
#   --- 各個人のscoreの推移を確認


# id抽出
# --- 10ケースを無作為抽出
set.seed(123)
rand <- longdata$id %>% unique() %>% sample(10)

# データ確認
# --- idごとに学校が異なる
longdata %>% filter(id %in% rand)

# プロット作成
# --- idごとにtimeごとのスコアの推移を確認
# --- timeの経過にしたがってscoreが上向きになっている
longdata %>%
  filter(id %in% rand) %>%
  ggplot(aes(x = time, y = score)) +
    geom_point() +
    ylim(150, 250) +
    geom_smooth(method = "lm", formula = y ~ x) +
    facet_wrap("id")


# 4 線形回帰モデルで当てはめ --------------------------------------------------------------

# ＜ポイント＞
# - 線形モデルを当てはめ
#   --- 同一個人を複数回にわたって観察したというデータの構造を無視

# 線形モデルの推定
m1 <- lm(score ~ time, data = longdata)

# 結果を出力
m1 %>% summary()
m1 %>% tidy()
m1 %>% glance()

# プロット作成
# --- 時点ごとの記録のため特徴的な散布図
longdata %>%
  filter(id %in% rand) %>%
  ggplot(aes(x = time, y = score)) +
    geom_point() +
    ylim(150, 250) +
    geom_smooth(method = "lm", formula = y ~ x)


# 5 ランダム切片モデルで当てはめ ---------------------------------------------------------

# ＜ポイント＞
# - 切片のみのモデルを推定するとはすなわち，従属変数の総分散のうち，どの程度が生徒レベル（レベル2）の分散であり，どの程度が時点×生徒レベル（レベル1）の分散であるかを分割することを意味しています．

# 切片のみモデルの推定
model0 <-
  lmer(score ~ 1 + (1 | id), data = longdata,
       REML = FALSE, na.action = na.omit)

# 推定結果を出力
model0 %>% summary()


# 級内相関係数
# --- 従属変数の総分散のうち，生徒レベル(レベル2)と生徒レベル(レベル1)の分散比で定義
icc <- 206.76/(206.76 + 93.43)
icc

# 独立変数timeを追加
model1 <-
  lmer(score ~ 1 + time + (1 | id),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

# 推定結果を出力
model1 %>% summary()


# ランダム切片・ランダム傾きモデル ----------------------------


# timeの係数にランダム効果を認める
model2 <-
  lmer(score ~ 1 + time + (1 + time | id),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

# 結果を出力
model2 %>% summary()


# モデル間でLoglikelihood testをして適合度を検定
anova(model0, model1, model2)

#
model2nocor <-
  lmer(score ~ 1 + time + (1 | id) + (-1 + time|id),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

model2nocor %>% summary()


# 5 階層ベイズモデル -----------------------------------------------------------------

# 5-1 事前分布を指定しないで推定 -------------------------------------------


# brm関数を使って推定
model2b <-
  brm(score ~ 1 + time + (1 + time | id),
      data    = longdata,
      prior   = NULL, # 事前分布を指定。NULLと記述した場合は一様分布
      chains  = 4,    # chainの回数を指定
      iter    = 1000, # 繰り返しの回数を指定
      warmup  = 500   # ウォームアップの回数を指定
      )


# 結果の出力
model2b %>% summary()


# パラメータの分布を確認
model2b %>% plot()


# パラメータとパラメータの標準誤差をプロット
model2b %>% stanplot()



# 事前分布を指定してベイズ推定 --------------------------------------------

# brm関数を使って推定
# 係数に正規分布を指定。変数の係数ごとにべつべつに別々に指定することもできる。
model2b <-
  brm(score ~ 1 + time + (1 + time | id),
      data    = longdata,
      prior   = c(set_prior("normal(0,10)", class = "b")),
      chains  = 4,
      iter    = 1000,
      warmup  = 500)

model3 <-
  lmer(score ~ 1 + (1 | id) + (1 | school),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

model3 %>% summary()

model4 <-
  lmer(score ~ 1 + time + (1 | id) + (1 | school),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

model4 %>% summary()


# ランダム切片・ランダム傾きモデル ----------------------------

# Student-level random-slope model
model5 <-
  lmer(score ~ 1 + time + (1 + time | id) + (1 | school),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

# School-level random-slope model
model6 <-
  lmer(score ~ 1 + time + (1 | id) + (1 + time | school),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

# Student-level and School-level random-slope model
model7 <-
  lmer(score ~ 1 + time + (1 + time | id) + (1 + time | school),
       data      = longdata,
       REML      = FALSE,
       na.action = na.omit)

anova(model4, model5, model7)


model7 %>% summary()


# 6.3 Baysian Estimation ベイズ推定 --------------------------------


# ベイズモデルを推定
model7b <-
  brm(score ~ 1 + time + (1 + time | id) + (1 + time | school),
      data    = longdata,
      prior   = c(set_prior("normal(0,10)", class = "b")), # 係数に正規分布を指定。
      chains  = 4, #chainの回数を指定
      iter    = 1000,  #繰り返しの回数を指定
      warmup  = 500 #ウォームアップの回数を指定
      )

## 推定結果を出力
model7b %>% summary()


# パラメータの分布を確認
model7b %>% plot()


