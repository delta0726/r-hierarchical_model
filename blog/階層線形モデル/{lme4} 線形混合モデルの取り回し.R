# ***********************************************************************************************
# Title     : {lme4} 線形混合モデルの取り回し
# Objective : TODO
# Created by: Owner
# Created on: 2021/03/20
# URL       : https://qiita.com/kilometer/items/2c786cca50357c0b9b1e
# ***********************************************************************************************


# ＜概要＞
# - tidyr::nest()とlme4を連携して線形混合モデルを扱う
# - カテゴリごとの線形回帰はggplot2では簡単に作成されるが、{lme4}ではその構造をモデル化する


# ＜目次＞
# 0 準備
# 1 カテゴリごとの散布図
# 2 モデルの準備


# 0 準備 -----------------------------------------------------------------------------------

# ライブラリ
library(tidyverse)
library(tidyquant)
library(lme4)


# データ確認
iris %>% as_tibble()
iris %>% glimpse()


# 1 カテゴリごとの散布図 ---------------------------------------------------------------------

# ＜ポイント＞
# - Speciesに共通した相関傾向を固定効果、そこからの種ごとの変動をランダム効果として取り扱う
# - 階層化された相関関係を取り扱う回帰分析を混合モデルと呼ぶ


# プロット作成
# --- カテゴリごとの散布図
# --- カテゴリごとに切片も傾きも異なる
iris %>%
  ggplot(aes(Sepal.Width, Petal.Length, color = Species))+
    geom_point()+
    geom_smooth(method = "lm", se = F)


# 2 モデルの準備 ---------------------------------------------------------------------------

# ＜ポイント＞
# - 以下のように設定してモデリングを行う
#   --- Y: Petal.Length  X: Sepal.Width  Group: Species


# モデル1
# --- 切片と傾きに共分散を仮定した種ごとのランダム効果
model1 <- function(data)
  lmer(Petal.Length ~ Sepal.Width + (Sepal.Width|Species), data = data)

# モデル2
# --- 切片を固定効果のみにし、傾きにランダム効果を導入
model2 <- function(data)
  lmer(Petal.Length ~ Sepal.Width + (0 + Sepal.Width|Species), data = data)

# モデル3
# --- 傾きを固定効果のみにし、切片にランダム効果を導入
model3 <- function(data)
    lmer(Petal.Length ~ Sepal.Width + (1|Species), data = data)

# モデル4
# --- 傾きと切片にそれぞれ独立のランダム効果を導入
model4 <- function(data)
    lmer(Petal.Length ~ Sepal.Width + (1|Species) + (0 + Sepal.Width|Species), data = data)

# モデル5
# --- null model（ベンチマーク）
model5 <- function(data)
    lmer(Petal.Length ~ 1 + (1|Species), data = data)

# モデルをまとめる
listed_lmer <- list(model1, model2, model3, model4, model5)



# 3 モデルの当てはめ ---------------------------------------------------------------------------

# モデル学習
# --- データ分割は行っていない
dat <-
  iris %>%
    nest() %>%
    bind_rows(., ., ., ., .) %>%
    rownames_to_column("id_model") %>%
    mutate(model = map2(data, listed_lmer, ~.y(.x))) %>%    # それぞれ当てはめ
    mutate(AIC = map_dbl(model, ~extractAIC(.) %>% .[[2]]), # AIC抽出
           deviance = map_dbl(model, REMLcrit),             # 逸脱度
           dev_exp = 1 - deviance / deviance[5],            # Deviance explained
           fixef = map(model, fixef),                       # 固定効果
           ranef = map(model, ranef),                       # ランダム効果
           predict = map2(model, data, ~predict(.x, .y)))   # 予測値

# 確認
dat %>% print()


# 4 モデル選択 --------------------------------------------------------------------------------

# AICでランキング
# --- モデル1 > モデル4 >...
dat %>% select(id_model, AIC) %>% arrange(AIC)

# 上位のAIC
dat$AIC[c(1, 4)]

# 残差
dat$dev_exp[1]


# 5 可視化 -----------------------------------------------------------------------------------

# ＜ポイント＞
# - モデル1とモデル4が有効性が高いことを確認したが、カテゴリごとの線形回帰と似たものとなっている
#   --- lme4が階層ごとにモデリングできていることを示している


# プロット作成
# --- グループごとに各モデルを表示
# --- Nullモデルに対してどんな変化があるかを確認
dat %>%
  select(id_model, data, predict) %>%
  unnest() %>%
  unite(tag, c(Species, id_model), sep = "_", remove = F) %>%
  ggplot(aes(x = Sepal.Width))+
    geom_point(aes(y = Petal.Length, shape = Species))+
    geom_path(aes(y = predict, group = tag, color = id_model), size = 2, alpha = 0.6)+
    theme_tq()+
    theme(strip.background = element_rect(color = "white"))

# プロット作成
# --- グループごとに各モデルを表示（黒線）
# --- カテゴリごとの線形回帰（色線）
dat %>%
  select(id_model, data, predict) %>%
  unnest() %>%
  unite(tag, c(Species, id_model), sep = "_", remove = F) %>%
  ggplot(aes(x = Sepal.Width))+
    geom_point(aes(y = Petal.Length, color = Species, shape = Species))+
    geom_path(aes(y = predict, group = tag), size = 2, alpha = 0.6)+
    geom_smooth(aes(y = Petal.Length, color = Species), method = "lm", se = F)+
    theme_tq()+
    theme(strip.background = element_rect(color = "white"),
          strip.text = element_text(size = 21))+
    facet_wrap(~id_model, scales = "free", nrow = 2)

