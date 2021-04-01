# ***********************************************************************************************
# Title     : R for Psych
# Chapter   : {lme4} 線形混合モデルの取り回し
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://glennwilliams.me/r4psych/mixed-effects-models.html
# ***********************************************************************************************


# ＜課題＞
# - データ全体を使用した分析ではデータ全体における観測値の｢独立性｣を前提としている
#   --- この仮定に違反することがよくあり、テストの解釈に関して深刻な問題を引き起こす可能性がある


# ＜線形混合モデルにおける仮定の緩和＞
# 1 回帰勾配の均一性：
# - 混合効果モデルは勾配の変動を直接モデル化できる
#   --- 条件間で勾配が類似していると仮定する必要はない
#   --- 全体で回帰する場合には非現実的な仮定だった

# 2 独立性の仮定：
# - 混合効果モデルは同じ人が複数の時点で複数の測定値を提供する場合も処理できる
#   --- 同じ人を観測すると独立性の仮定が疑われる
#   --- 傾きと接点を独立に定義できるため

# 3 完全なデータ：
#  - 欠損値処理が必要ない
#   --- 従来の線形モデルでは欠損値を含む観測値は削除していた
#   --- 混合効果モデルでは利用可能なものに基づいて欠測データを推定できる


# ＜準備＞
# 0 準備
# 1 lme4の記法
# 2 階層線形モデルのパターン
# 2-1 切片/傾きが固定効果
# 2-2 切片のみランダム効果
# 2-3 傾きのみランダム効果
# 2-4 切片/傾きともにランダム効果
# 3 ランダム効果の構造
# 3-1 クロスデータ
# 3-2 ネストデータ
# 3-3 ｢クロス｣か｢ネスト｣の判断が難しい場合
# 3-4 ランダム効果の様々な表現
# 4 部分プーリング
# 4-1 完全プーリングの回帰係数をグループごとに当てはめる
# 4-2 プーリングなしの回帰係数をグループごとに当てはめる
# 4-3 部分プーリングの回帰係数をグループごとに当てはめる
# 4-4 特定のプロットを確認
# 5 階層モデルの出力結果の解釈
# 5-1 パラメータ推定とp値の算出
# 5-2 モデル選択
# 6 一般化階層モデル


# 0 準備 --------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(magrittr)
library(lme4)
library(broom.mixed)
library(languageR)


# データ準備
sleep_groups <- read_csv("book/R_for_psych/data/sleep_study_with_sim_groups.csv")
sleep_study <- read_csv("book/R_for_psych/data/sleep_study_with_sim.csv")


# データ確認
sleep_groups %>% as_tibble()
sleep_groups %>% glimpse()

sleep_study %>% as_tibble()
sleep_study %>% glimpse()


# グループ確認
sleep_groups %>% select(-Reaction) %>% map(table)
sleep_study %>% select(-Reaction) %>% map(table)



# 1 lme4の記法 ------------------------------------------------------------------

# ＜ポイント＞
# - (x | group)でxに指定したものがランダムとなる
# - (1 | group)とした場合は切片がランダムとなり、(x1 | group)とした場合は変数x1がランダムとなる
# - (0 + x1 | group)とすると変数1はランダムだが、切片は固定となる


# 1 ランダム切片のみ（random intercept）
# subjectsをランダム効果として，｜の前の”１”は切片になる．
# a ~ b + ( 1 | group)

# ランダム傾きのみ(random slope)
# ”｜ subjects”の前の”b”が傾きで，”0”を付け加えることでランダム切片は無し，ということになる
# a ~ b + (0 + b | group)

# ランダム切片/ランダム傾きの両方
# ”｜ subjects ”の前の”1 + b”で切片と傾き両方採用．”0”を付け加えることでランダム切片は無しということになる．
# また，ただ”b”と表記しても”1 + b”と同じことになる．式は以下の通り．
# a ~ b + (1 + b | group)
# a ~ b + ( b | group)



# 2 階層線形モデルのパターン --------------------------------------------------------

# 2-1 切片/傾きが固定効果 ----------------------------------------------

# ＜ポイント＞
# - 切片/傾きの両方を固定効果とするということは切片/傾きを一意に決めるということ（通常の線形回帰モデル）
# - グループごとの傾向があって、階層モデルで推定する必要があることを確認


# 線形回帰モデルの定義
# --- Y: Reaction
# --- X: Days
# --- 傾き：15.4  切片: 371.4
lm(Reaction ~ Days, data = sleep_groups)

# プロット作成
# --- Xは離散的に定義されている
# --- 複数グループのデータを含む
# --- グループごとの傾向が強い
sleep_groups %>%
  ggplot(mapping = aes(x = Days, y = Reaction)) +
    geom_point(na.rm = T, aes(col = Group), alpha = 0.5) +
    geom_smooth(method = "lm", na.rm = T, col = "black", se = F) +
    scale_y_continuous(limits = c(180, 1020)) +
    scale_x_continuous(breaks = seq(1:10) - 1) +
    theme(legend.position = "top")


# 2-2 切片のみランダム効果 ----------------------------------------------

# ＜ポイント＞
# - 切片をランダム効果(傾きを固定効果)とするので、切片のみグループごとに決定される
#   --- グループごとに平行な線ができる


# モデル定義
# --- ランダム切片モデル
# --- ランダム効果にするものを(x | Group)で指定する
# --- 切片をランダム効果とする場合はx=1とする
intercepts_model <- lmer(Reaction ~ Days + (1 | Group), data = sleep_groups)

# 回帰係数の抽出
# --- グループごとの切片と傾き
# --- 切片のみグループ別に値が異なる
model_coefs <-
  intercepts_model %>%
    coef() %>%
    use_series(Group) %>%
    rename(Intercept = `(Intercept)`, Slope = Days) %>%
    rownames_to_column("Group")

# 元データと結合
sleep_groups_rani <-
  sleep_groups %>%
    left_join(model_coefs, by = "Group")

# プロット作成
# --- 切片がグループごとに決定されている
# --- 傾きは一意に決定されている
model_coef_plot <-
  sleep_groups_rani %>%
    ggplot(aes(x = Days, y = Reaction,colour = Group)) +
    geom_point(na.rm = T, alpha = 0.5) +
    geom_abline(aes(intercept = Intercept, slope = Slope,colour = Group), size = 1.5) +
    scale_y_continuous(limits = c(180, 1020)) +
    scale_x_continuous(breaks = seq(1:10) - 1) +
    theme(legend.position = "top")

# プロット表示
model_coef_plot %>% print()


# 2-3 傾きのみランダム効果 ----------------------------------------------

# ＜ポイント＞
# - 傾きをランダム効果(切片を固定効果)とするので、傾きのみグループごとに決定される
#   --- 同じ切片を通って、グループごとに傾きの異なる線ができる


# モデル定義
# --- ランダム傾きモデル
# --- 切片を固定する場合は(0 + x1 | Group)とする
model <- lmer(Reaction ~ Days + (0 + Days | Group), data = sleep_groups)

# 回帰係数の抽出
# --- グループごとの切片と傾き
# --- 傾きのみグループ別に値が異なる
model_coefs <-
  model %>%
    coef() %>%
    use_series(Group) %>%
    rename(Intercept = `(Intercept)`, Slope = Days) %>%
    rownames_to_column("Group")

# 元データと結合
sleep_groups_rans <-
  sleep_groups %>%
    left_join(model_coefs, by = "Group")

# プロット更新
# --- データセットを入れ替えてプロット作成
# --- 切片が固定、傾きはランダムに決定
model_coef_plot %+% sleep_groups_rans


# 2-4 切片/傾きともにランダム効果 ----------------------------------------------

# ＜ポイント＞
# - 切片と傾きを両方ともランダム効果とするので、傾きと傾きの両方がグループごとに決定される


# モデル定義
# --- ランダム切片/傾きモデル
# --- 切片をランダムにする場合は(1 + x1 | Group)とする
model <- lmer(Reaction ~ Days + (1 + Days | Group), data = sleep_groups)


# 回帰係数の抽出
# --- グループごとの切片と傾き
# --- 傾きのみグループ別に値が異なる
model_coefs <-
  model %>%
    coef() %>%
    use_series(Group) %>%
    rename(Intercept = `(Intercept)`, Slope = Days) %>%
    rownames_to_column("Group")

# 元データと結合
sleep_groups_ranis <-
  sleep_groups %>%
    left_join(model_coefs, by = "Group")

# プロット更新
# --- データセットを入れ替えてプロット作成
# --- 切片/傾きともにランダム
model_coef_plot %+% sleep_groups_ranis



# 3 ランダム効果の構造 --------------------------------------------------------

# ＜概要＞
# - 階層データを作成する際に｢クロスデータ｣と｢ネストデータ｣で記法が異なる
#   --- クロスデータ：(x1 | Group1) + (x1 | Group2)
#   --- ネストデータ：(x1 | Group1/Group2)


# 3-1 クロスデータ ----------------------------------------------------

# ＜ポイント＞
# - カテゴリカルデータが完全にネストしているわけではない
# - {lme4}ではグループごとに項を作っていく記法を用いる
#   --- (1 | Group1) + (1 | Group2)


# データ作成
crossed_data <- tibble(
  Subject = rep(1:2, 5),
  Item = rep(1:5, each = 2),
  Condition = c(rep(c("A", "B"), 2), rep(c("B", "A"), 3)),
  Response = rnorm(n = 10, mean = 100, sd = 10)
)

# データ確認
# --- Item(1/2/3/4/5)はSubject(1/2)のそれぞれに含まれる（クロスデータ）
# --- ItemとSubjectが独立項目であることにより発生
crossed_data %>% print()
crossed_data %>% group_by(Subject, Item) %>% tally()

# モデル定義
# --- ランダム切片モデル
# --- グループが2つ
lmer(Response ~ Condition + (1 | Subject) + (1 | Item), data = crossed_data)



# 3-2 ネストデータ -----------------------------------------------------

# ＜ポイント＞
# - カテゴリカルデータが完全にネストしている
# - {lme4}ではグループを｢/｣で統合していく記法を用いる
#   --- (1 | Group1/Group2/Group3)


# データ作成
nested_data <- tibble(
  Student = seq(1:10),
  Class = rep(seq(1:5), 2),
  School = c(rep(1, 5), rep(2, 5)),
  Intervention = rep(c("yes", "no"), 5),
  Outcome = rnorm(n = 10, mean = 200, sd = 20)
)


# データ確認
# --- Class(1/2/3/4/5)はSchool(1/2)ごとに名前は一緒でも性質は異なる（ネストデータ）
# --- Studentに関しては完全に独立なので、上位グループにネストされている形になる
nested_data %>% print()
nested_data %>% group_by(School, Class, Student) %>% tally()

# モデル定義
# --- ランダム切片モデル
# --- グループが2つ
lmer(Outcome ~ Intervention + (1 | School/Class/Student), data = nested_data,
     control = lmerControl(check.nobs.vs.nlev = "ignore",
                           check.nobs.vs.rankZ = "ignore",
                           check.nobs.vs.nRE = "ignore"))


# 3-3 ｢クロス｣か｢ネスト｣の判断が難しい場合 --------------------------------------

# ＜ポイント＞
# - ｢クロス｣か｢ネスト｣の判断が難しいグループデータも存在する
#   --- その場合はグループを結合することがソリューションとなる
#   --- 以下の2例は結果が一致


# データ加工
# --- グループ情報を統合
nested_data2 <-
  nested_data %>%
    mutate(Class_ID = paste(School, Class, sep = "_"))

# 例1：ネストデータとして扱う
lmer(Outcome ~ Intervention + (1 | School/Class_ID), data = nested_data2,
     control = lmerControl(check.nobs.vs.nlev = "ignore",
                           check.nobs.vs.rankZ = "ignore",
                           check.nobs.vs.nRE = "ignore"))

# 例2：クロスデータとして扱う
lmer(Outcome ~ Intervention + (1 | School) + (1 | Class_ID), data = nested_data2,
     control = lmerControl(check.nobs.vs.nlev = "ignore",
                           check.nobs.vs.rankZ = "ignore",
                           check.nobs.vs.nRE = "ignore"))



# 3-4 ランダム効果の様々な表現 ----------------------------------------------------

# 複数グループの階層モデル
# --- 階層ごとのアイテムが1つ
lmer(
  Outcome ~ Condition +
    (1 + Condition | Subject) +
    (1 + Condition | Item),
  data = data
)

# 複数グループの階層モデル
# --- 階層ごとのアイテムが複数で同じ
lmer(
  Outcome ~ Condition + Block +
    (1 + Condition + Block | Subject) +
    (1 + Condition + Block | Item),
  data = data
  )

# 複数グループの階層モデル
# --- 階層ごとのアイテムが複数で異なる
lmer(
  Outcome ~ Condition + Block +
    (1 + Condition + Block | Subject) +
    (1 + Condition | Item),
  data = data
  )

# 切片のみランダム/傾きがランダムが混在
lmer(
  Outcome ~ Condition +
    (1 | Subject) +
    (1 + Condition | Item),
  data = data
  )

# 相互効果を含む場合に表現
lmer(
  Outcome ~ factor_A * factor_B +
    (1 + factor_A * factor_B | Subject) +
    (1 + factor_A * factor_B | Item),
  data = data
  )


# 4 部分プーリング -------------------------------------------------------------

# ＜ポイント＞
# - ｢プーリング｣とはデータの持つカテゴリを無視して全体で処理することをいう
# - 階層モデルで扱うべきものを線形モデルで扱うことも問題点を確認する
# - 部分プーリングにより、混合効果モデルが欠落データをどのように考慮できるかを確認


# ＜参考＞
#  Plotting partial pooling in mixed-effects models
# - https://www.tjmahr.com/plotting-partial-pooling-in-mixed-effects-models/


# 4-1 完全プーリングの回帰係数をグループごとに当てはめる ----------------------

# ＜ポイント＞
# - 完全プーリングとは全体で線形回帰すること


# データ確認
sleep_study %>% print()
sleep_study %>% select(Subject, Days) %>% map(table)

# モデル定義
# --- 完全なプーリングを使用してデータに適合
# --- 通常の線形回帰
complete_pooling <- lm(Reaction ~ Days, data = sleep_study)

# 回帰係数の取得
complete_pooling_coefs <- complete_pooling %>% coef()

# プロット作成
# --- 線形回帰に信頼区間を追加（上記の線形回帰と同じ）
sleep_study %>%
  ggplot(aes(x = Days, y = Reaction)) +
  geom_abline(aes(intercept = complete_pooling_coefs[1],
                  slope = complete_pooling_coefs[2]), colour = "#F8766D", size = 1.5) +
  stat_summary(fun.data = "mean_se", geom = "pointrange", na.rm = T, colour = "#F8766D")

# データフレーム作成
# --- Subjectごとに完全プーリングの回帰係数を設定
complete <-
  tibble(Subject = seq(1:21),
         Intercept = complete_pooling_coefs[[1]],
         Slope = complete_pooling_coefs[[2]],
         Model = "complete_pooling")

# データ結合
# --- 元データに回帰係数を結合
model_coefs <-
  sleep_study %>%
    left_join(complete, by = "Subject")

# プロット作成
# --- 完全プーリングで推定した回帰係数をグループごとに適用
pooling_plot <-
  model_coefs %>%
    ggplot(aes(x = Days, y = Reaction, colour = Model)) +
    geom_abline(aes(intercept = Intercept, slope = Slope, colour = Model), size = 1.5) +
    geom_point(na.rm = T) +
    facet_wrap(~Subject)

# プロット確認
# --- 傾きが散布図を捉えていない
# --- グループによってサンプル数が少ないものもある
pooling_plot %>% plot()


# 4-2 プーリングなしの回帰係数をグループごとに当てはめる ----------------------

# ＜ポイント＞
# - 完全プーリングとは切片/傾きをランダム効果として扱うこと
#   --- 固定効果なし


# モデル定義
# --- 線形階層モデル（プーリングなし）
no_pooling <- lmer(Reaction ~ Days | Subject, data = sleep_study)

# 回帰係数の取得
# --- グループ別
no_pooling_coefs <-
  no_pooling %>%
    coef() %>%
    use_series(Subject) %>%
    rename(Intercept = `(Intercept)`, Slope = Days)

# 確認
no_pooling_coefs %>% head()

# データフレーム作成
# --- Subjectごとにプーリングなしの回帰係数を設定
none <-
  tibble(Subject = seq(1:21),
         Intercept = no_pooling_coefs$Intercept,
         Slope = no_pooling_coefs$Slope,
         Model = "no_pooling")

# データ結合
# --- 元データに回帰係数を結合
# --- 全体プーリング + プーリングなし
model_coefs <-
  sleep_study %>%
    left_join(bind_rows(complete, none), by = "Subject")

# プロット作成
# --- 完全プーリングとプーリングなしは印象が異なる
pooling_plot %+% model_coefs


# 4-3 部分プーリングの回帰係数をグループごとに当てはめる -------------------------

# ＜ポイント＞
# - 部分プーリングとは切片/傾きをランダム効果として扱うこと
#   --- 固定効果あり


# モデル定義
# --- 線形階層モデル（部分プーリング）
partial_pooling <- lmer(Reaction ~ Days + (Days | Subject), data = sleep_study)

# 回帰係数の取得
# --- グループ別
partial_pooling_coefs <-
  partial_pooling %>%
    coef() %>%
    use_series(Subject)

# データフレーム作成
# --- Subjectごとに部分プーリングの回帰係数を設定
# --- データ結合
all_pools <-
  tibble(Subject = seq(1:21),
         Intercept = partial_pooling_coefs$`(Intercept)`,
         Slope = partial_pooling_coefs$Days,
         Model = "partial_pooling") %>%
    left_join(sleep_study, by = "Subject") %>%
    bind_rows(model_coefs)

# プロット作成
# --- プーリングなしと部分プーリングは印象がほぼ同じ
pooling_plot %+% all_pools


# 4-4 特定のプロットを確認 --------------------------------------------------

subset_pools <- all_pools %>% filter(Subject %in% c(1, 2, 19, 20))
pooling_plot %+% subset_pools



# 5 階層モデルの出力結果の解釈 -----------------------------------------------------

# 5-1 パラメータ推定とp値の算出 --------------------------------

# データ準備
# --- languageR::lexdecデータセットを使用
# ---
lex_dec <-
  lexdec %>%
    as_tibble() %>%
    select(Subject, Trial, Word, NativeLanguage, RT) %>%
    mutate(lang_c = (lex_dec$NativeLanguage == "English") - mean(lex_dec$NativeLanguage == "English"))

# データ確認
lex_dec %>% head()
lex_dec %>% glimpse()


# モデル定義
# --- ランダム切片のみ
lexdec_mod <- lmer(RT ~ lang_c + (1 | Subject) + (1 | Word), data = lex_dec, REML = F)

# モデル確認
lexdec_mod %>% summary()

# p値の算出
lexdec_mod %>%
  tidy("fixed") %>%
  mutate(p_value = 2 * (1 - pnorm(abs(statistic))))


# 5-2 モデル選択 ----------------------------------------------------

# モデル定義
lexdec_mod_reduced <- lmer(RT ~ 1 + (1 | Subject) + (1 | Word), data = lex_dec, REML = F)

# ANOVA分析
anova(lexdec_mod, lexdec_mod_reduced)


lexdec_slope <- lmer(RT ~ lang_c + (1 | Subject) + (lang_c || Word), data = lex_dec, REML = F)
lexdec_slope_cov <- lmer(RT ~ lang_c + (1 | Subject) + (lang_c | Word), data = lex_dec, REML = F)
anova(lexdec_mod, lexdec_slope, lexdec_slope_cov)


summary(lexdec_mod)
summary(lexdec_slope)
summary(lexdec_slope_cov)

nelder_mod <- lmer(
  RT ~ lang_c + (1 | Subject) + (lang_c | Word),
  data = lex_dec, REML = F,
  control = lmerControl(optimizer = "Nelder_Mead")
  )
boby_mod <- lmer(
  RT ~ lang_c + (1 | Subject) + (lang_c | Word),
  data = lex_dec, REML = F,
  control = lmerControl(optimizer = "bobyqa")
     )


# 6 一般化階層モデル -----------------------------------------------------

# ＜ポイント＞
# - 一般化混合効果モデルはyまたはxが正規分布していない場合に適用される
#    --- バイナリ応答データのロジスティック回帰など
#    --- これらのモデルは一般化線形モデルと同じロジックを使用し、解釈は混合効果モデルと非常によく似ている
#    --- ただし、モデルから直接固定効果係数のp値が計算される

#
glmer(
  DV_binom ~ # binomial dependent variable
    A * B + # fixed effects
    (A * B | subject) + (A * B | item), # random effects
  family = binomial, # family: type of distribution
  data = data,
  glmerControl(optimizer = "bobyqa") # options; notice glmerControl (not lmer)
  )


# ウエイト指定
glmer(
  DV_prop ~ # dependent variable as a proportion
    A * B + # fixed effects
    (A * B | subject) + (A * B | item), # random effects
  family = binomial, # family: type of distribution
  weights = N_observations, # number of observations making up the proportion
  data = data,
  glmerControl(optimizer = "bobyqa")# options; notice glmerControl (not lmer)
  )


glmer(
  DV_successes/N_observations ~ # calculate proportion
    A * B + # fixed effects
    (A * B | subject) + (A * B | item), # random effects
  family = binomial, # family: type of distribution
  weights = N_observations, # number of observations making up the proportion
  data = data,
  glmerControl(optimizer = "bobyqa") # options; notice glmerControl (not lmer)
  )


