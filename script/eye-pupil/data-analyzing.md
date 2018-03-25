# data-analyzing

## 導入
<!--
ワードだけは使わない。PPとエクセルは使っていきましょう。
テキストでデザインとかむずいし、視覚効果を狙うものはGUIで操作したほうが楽。
アウトラインはこうしてMDで作って問題ない。
-->

先行研究と修論、本分析を述べます。
話す時間は３０分位を貰えれば。

### 先行研究

*
*
*

### 修論(Structural Predictions by Agreement Errors)

*
*
*

### 今回の分析

多すぎて終わらないし、VWPで一通りの支持は得られているので。
分析するポイントはN個に絞る。
目的とかの説明

まず、仮説は何だったっけ？
V2のNEGを予測するのか、という話。
POLが終わった後のTimeの役割を見る、とか。

来なかった時のびっくりは再現できてそう。
かといって、しかないのないで楽になっている気配もなし。
ただ、関係節が続いた時の変化は。


* NPIによるNEGの予測
    * NPIの後にNEGが来なかった時、TMEが発生するか(Yoshida の話)
        * NPIの後にNEGが入力されなかった場合、処理負荷が発生するはず
            * POL の入力に対して
                * (4100--4700:ている)
        * 文が終わらなかった時、処理負荷が軽減するはず
            * N2 の入力に対して
                * (4700--5500)
    * NPIの後にNEGが入力された場合
        * NPIの後にNEGがきた時、処理負荷が減るはず
            * POL の入力に対して
        * 文が終わらなかった時、処理負荷がかかるはず
            * N2 の入力に対して
    * 再分析の結果、NEGが予測されるか
        * 「しか」条件は「だけ」条件と比較して NEG の入力の負荷が減る
            * V2 の入力に対して
                * 傾きも分析に加える

### 瞳孔経分析とは

#### メリット

#### デメリット

#### 実例


## 被験者のデータ

まず、なんらかの有意差を取得してから。

* 割合変化の分析方法
* 眼球運動の際は、「見られていた時間」の比率を対数変換していた。
* 今回はどうすべきか。


* 見どころ
  * 「しか＋ある」の時、瞳孔はどうなる？
  * 関係節だと分かった時、再分析が必要となった時
    * cdは否定を含む関係節だから、純粋に面倒そう
  * V2 の分析だけど、時間帯によって **バラバラ**
    * 「ない」を200msと仮定する。
    * Duration - 200 とする。
  * まずは他の部分を調査…。
    * そもそも、分析の方針を決めないとどうしようもない。
    * まずはプロットしましょう。
      * 何をプロットしますか？
      * 各ms時におけるパーセントをプロットしましょう。
      * パーセントのプロットを対数に変換したら、正規分布に近づくかな？
      * 近づいたら lme つかえるかも。
        * そもそも lme が仮定している分布は正規分布だけだっけだっけ？
        * 何にせよ、正規分布っぽくはある。

* パラメトリック手法 OR ノンパラメトリック手法
  * LME がパラメトリックならば、分布に前提を設けている。

* どこからどこの区間を分析するのか
  * 各被験者、各アイテム、各条件ごとに割合を加算？
  * 眼球運動の場合は、特定のAOIを見ていた時間を足していた。

* Time を変数に入れられれば、傾きもとらえた分析ができそう。
* V2 で平均を取ると傾きを反映しない。反映させるためには、timeを変数に入れて。
    * time で後半を赤、前半を青というふうに色分けして
    * RGBのRとBを変えれば良い。
* 中村くんのsANT分析を思い出しながら。
* アイテムごとの分布も表示する。
  * 輝度が高い条件、低い条件を。
  * fixationのデータ、見られている対象の絵、その絵の輝度と明度、瞳孔のサイズ、も分析に入れられそう。

* どういう研究に使われてきた分析なのか
    1. 陳さんもまだ分析されていないということで、まだ知見が溜まっていない前提で。

* 外れ値の処理

bdが上がり調子。少なくともaは違う。

* 瞳孔分析のメリット
    1. 認知的処理の実時間の指標が得られる（傾きが分析できる）
    1. 顕著な行動パターンを示す閾値に達しない影響の指標も得られる（デジタル）
      * アナログ
    1. 課題を邪魔しない、invasiveではない
    1. 頭の動きの結果などに影響されない
* 瞳孔分析のデメリット
    1. あくまでも副次的(ERPとは違う。)
    1. 一定して観測しなければならない
    1. 指標が難しい
    1. 他の要因がある（アイテムの明度、輝度など）

* 先行研究で欠けていたこと
    1. baseline
        * 赤で書かれた文字は「赤」と答えなくてはならない。
        その条件で、「"青"の場合」と「"ほげ(letter string)"や"赤(color-congruent)"の場合」で、
        baseline は「"ほげ"や"赤"のような場合」とし、"青"が大きな瞳孔経が観察。これの何が問題か。
        * non-word と word といったlexical informationだけでなく meaning も違い、どちらを、
        あるいはその両方を反映しているかはしれない。
        * phonology や 文字の形 による坂もしれない。
    * だから、色でない語彙をベースラインとして使用する。（例えば、"人"のような）
    1. time course data.
        * 先行研究の中では、単に平均化してしまっただけのものも有る。
一つ論文を書けるレベルで徹底的に分析する。

* 各試行にあった、音声呈示前の2000msの平均をもとめた。
* 最初から時間も変数に入れてしまおう。

* V2の後半は問題の難易度も反映しちゃってそう。

mean(selected_data[selected_data$Timestamp==5000 & selected_data$Condition=="c",]$PupilDilationRate,na.rm=T)
mean(selected_data[selected_data$Timestamp==7500 & selected_data$Condition=="d",]$PupilDilationRate,na.rm=T)
mean(selected_data[selected_data$Timestamp==7500 & selected_data$Condition=="a",]$PupilDilationRate,na.rm=T)

N2onset同じ200msの部分
しかある、にとっては再分析の結果が見れる部分、
しかない、にとっては再分析が必要となる部分、

POLのoffset部分
しかある、にとっては予測外
しかない、にとっては予測内
POLの400msを分析内に。最初の200は「て」だから。

```r

setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil")
getwd()
load("../csv/data_frame_with_pupil_dilation_rate.dat")
data = data_frame_with_pupil_dilation_rate

library(lme4)
library(reshape)

head(data)

#バランスを確認
table(data$ParticipantName, data$Condition)
table(data$Condition)

onset_var = 4300
offset_var = 4700
span = offset_var - onset_var

data$slapse = data$GazeStart - onset_var
data$elapse = data$GazeEnd - onset_var

# 例： onset1からでしたら0,
# data$slapse = data$GazeStart - 0
# data$elapse = data$GazeEnd - 0

# onset2からでしたらdata$onset2
# data$slapse = data$GazeStart - data$onset2
# data$elapse = data$GazeEnd - data$onset2

# そうしたら、onset以前の部分は負数になって、
# 後で時間区間の長さを調整する部分と合わせて0以下は0と入れ替えられて処理しないことになる

  #  slapse elapse
  #1   -824   -670
  #2   -603   -397
  #3      3    173
  #4    177    680
  #5    926   1523
  #6   1220   1603


# onset内の時間区間の長さを調整
# 仮に onset の時間から引いたら、0スタートでnエンドになる。
# n はオンセットからの時間区間となる。
data$slapse = ifelse(data$slapse < 0, 0, data$slapse)
data$elapse = ifelse(data$elapse >= span, span, data$elapse)
# 上の場合、開始点は0（当たり前だのクラッカー）,終了点は800 となる。

# 例：開始点は0,終了点は1000
# -> 0以下は0で入れ替え、1000以上は1000で入れ替えます
# 相殺してしまうと、概念上slapseとelapse以外の点が外されてしまします。（すごい技！）
# data$slapse = ifelse(data$slapse < 0, 0, data$slapse)
# data$elapse = ifelse(data$elapse >= 1000, 1000, data$elapse)

　　　　　　　　　　　　　　　　　　　　　　　　#  slapse elapse
　　　　　　　　　　　　　　　　　　　　　　　　#1      0   -199
　　　　　　　　　　　　　　　　　　　　　　　　#2      0    -10
　　　　　　　　　　　　　　　　　　　　　　　　#3      3      3
　　　　　　　　　　　　　　　　　　　　　　　　#4    177    177
　　　　　　　　　　　　　　　　　　　　　　　　#5    926   1000
　　　　　　　　　　　　　　　　　　　　　　　　#6   1220   1000

# 時間内の比率を見るから、durだけを見ていい（開始点と終了点はもう無視していい）
# どれくらいの時間見ていたか、という点に興味が有る。ｌ
# わかりづらいけど、途中まで進まえると分かりやすいかもしれない。
data$dur = data$elapse - data$slapse
# 万が一0以下（オーバーした区間）を除外
data$dur = ifelse(data$dur < 0, 0, data$dur)

#必要なコラムだけを残ります
data = data[,c("ParticipantName", "ItemNo", "target", "Condition", "slapse","elapse","dur")]
data = data[order(data$ParticipantName,data$ItemNo,data$slapse),]

#CALUCULATING SUM (aggregation for each trial)
#同じ区間の中もし別に他の注視時間があれば全部合算する。
data =aggregate(
    data$dur,
    by=list(data$ParticipantName, data$ItemNo, data$target, data$Condition),
    FUN=sum,
    na.rm=TRUE)
colnames(data) = c("subj","item","AOI","cond","sum")

#sort
data = data[order(data$subj, data$item),]
#"variable","value"に書き換えないと、cast()が実行できません
colnames(data) = c("subj","item","variable","cond","value")

# cast creates separate columns for each object fixated
# 各絵に分けたら、それぞれの絵にどれくらい見ているのか、
# 後で分けて計算しやすい。（いちいち取り出すではなく、コラム単位で計算できる）

# cast 関数が無い。
data2 = cast(data)

# replace NULL
# ここはどのような列を作っているかにもよります。
data2$BackGround = ifelse(is.na(data2$BackGround), 0, data2$BackGround)
data2$A= ifelse(is.na(data2$A), 0, data2$A)
data2$B= ifelse(is.na(data2$B), 0, data2$B)
data2$C= ifelse(is.na(data2$C), 0, data2$C)
data2$D= ifelse(is.na(data2$D), 0, data2$D)

# たぶん、data2$Aとかの列にはその文節で見られている時間が記録されている。
# だから、data2$Target みたいなのを作って上げればいいはず。

# N1 V1 AFF N2 -> N2 V1 が正解
# TODO ここおかしい。たぶん、

data2$Target = ifelse((data2$cond == "a" | data2$cond == "b"), data2$C, data2$D)

# calculate ALL column
data2$all =  (data2$BackGround
              + data2$A
              + data2$B
              + data2$C
              + data2$D)

# ここ、a,b,コレクト、ロング、にしたほうが良さそう。

# 検証したい絵の条件はここで変更
# 条件が一つの絵のみの場合

data2$logit = log((data2$Target + 0.5) / (data2$all - data2$Target + 0.5))

# 条件がC(N2がV1をしている絵)の場合

# 条件が２つ以上の絵の場合
#data2$Competitor_TargetCompound = data2$CompetitorCompound + data2$TargetCompound
#data2$logit = log((data2$Competitor_TargetCompound + 0.5) / (data2$all - data2$Competitor_TargetCompound + 0.5))

# たぶん、該当する文節でのgazeの割合を見ている。
# 基本四つのパタン.odds率を計算。0.5は微調整（分母が0でしたら計算できなくなります。）
# data2$logit_c = log((data2$C + 0.5) / (data2$all - data2$C + 0.5))
# data2$logit_a = log((data2$A + 0.5) / (data2$all - data2$A + 0.5))
# data2$logit_b = log((data2$B + 0.5) / (data2$all - data2$B + 0.5))
# data2$logit_d = log((data2$D + 0.5) / (data2$all - data2$D + 0.5))

# 下位条件を付けます
# wo-ni の奴やで。
data2$npi = ifelse(data2$cond == "a" | data2$cond == "c", 1, 0)
data2$aff = ifelse(data2$cond == "a" | data2$cond == "b", 1, 0)

#中心化
# data2$npi = scale(data2$npi, scale=F)
# data2$aff = scale(data2$aff, scale=F)
data2$npi = scale(data2$npi, scale=T)
data2$aff = scale(data2$aff, scale=T)

#転換しやすいため
#logit1:Competitor_TargetCompound
#logit2:TargetCompound
#logit3:CompetitorCompound
#logit4:TargetSimplex

# data2$logit=data2$logit_c
tapply(data2$logit, list(data2$npi, data2$aff), mean)

sum(data2[data2$cond == "a",]$Target)
sum(data2[data2$cond == "b",]$Target)

# 存在するものは、２つの要因と、予測変数。
# まず、最大モデルと最小モデルを求める。

# data
# dependent :ｙ
# ...: predictor
# rondom1: subj
# rondom2: item

# selectLmeModel = function(dependent, fix1, fix2, rondom1, rondom2){
#   m10 = lmer(
#     dependent ~ fix1 * fix2
#     + (1 + fix1 + fix2 + fix1:fix2 |rondom1)
#     + (1 + fix1 + fix2 + fix1:fix2 |rondom2))
#   # ランダム変数名と固定変数名を取得して、それを予測式から外す関数が必要
#   summary(m10)
#   print(VarCorr(m10), comp=c("Variance"))
#   capture.output(print(VarCorr(m10), comp=c("Variance")))
#
#   length(capture.output(print(VarCorr(m10), comp=c("Variance"))))
#
#   modelvar = print(VarCorr(m10), comp=c("Variance","Std.Dev"))
#   print(modelvar)
#   m00 = lmer(dependent ~ fix1 * fix2 + (1 | rondom1) + (1 | rondom2))
#   anova(m10, m00)
# }
#
# selectLmeModel(data2$logit, data2$npi, data2$aff, data2$subj, data2$item)

#   m00 = lmer(dependent ~ fix1 * fix2 + (1 | rondom1) + (1 | rondom2))
#   anova(m10, m00)

# # #汎用性LMEモデル
m10 = lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# m09 = lmer(logit ~ npi * aff + (1 + aff+npi:aff |subj) + (1 + npi*aff |item), data = data2)
m00 = lmer(logit ~ npi * aff + (1 |subj) + (1 |item), data = data2)

anova(m10, m00)

# m10wi = lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# m10woi = lmer(logit ~ npi + aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# anova(m10wi, m10woi)
# m10 = lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# m10 = lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)



# m10_noccor = lmer(logit ~ npi * aff + (1 + npi*aff ||subj) + (1 + npi*aff || item), REML=F, data = data2)

# # # conv
# m09 = lmer(logit ~ npi * aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
#
# m08 = lmer(logit ~ npi * aff + (1 + aff |subj) + (1 + npi*aff |item), data = data2)
# m07 = lmer(logit ~ npi * aff + (1 + aff |subj) + (1 + npi+aff |item), data = data2)
# m06 = lmer(logit ~ npi * aff + (1 + aff |subj) + (1 + npi |item), data = data2)
# m07 = lmer(logit ~ npi * aff + (1 + aff + npi:aff |subj) + (1 + npi:aff |item), data = data2)
# # conv
# m06 = lmer(logit ~ npi * aff + (1 + npi:aff |subj) + (1 + npi:aff |item), data = data2)
#
# # signif
# anova(m09,m06)
#
# m09wi = lmer(logit ~ npi * aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
# m09woi = lmer(logit ~ npi + aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
# m09won = lmer(logit ~ aff * npi:aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
# m09woa = lmer(logit ~ npi + npi:aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
#
#anova(m09wi, m09woi)
#
# m08 =     lmer(logit ~ aff * npi:aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08wi  =  lmer(logit ~ npi * aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08woi  =  lmer(logit ~ npi + aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08won  =  lmer(logit ~ aff + npi:aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08woa  =  lmer(logit ~ npi + npi:aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)

# m09wi = lmer(logit ~ npi * aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
# m09woi = lmer(logit ~ npi + aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
# m09won = lmer(logit ~ aff + npi:aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
# m09woa = lmer(logit ~ npi + npi:aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
#
# summary(m09wi)
#
# # npi
# anova(m09wi, m09won)
#
# # aff
# anova(m09wi, m09woa)
#
# # npi:aff(interaction)
# anova(m09wi, m09woi)
#
m00wi  =  lmer(logit ~ npi * aff + (1|subj) + (1|item), data = data2)
m00woi  =  lmer(logit ~ npi + aff + (1|subj) + (1|item), data = data2)
m00won  =  lmer(logit ~ aff + npi:aff + (1|subj) + (1|item), data = data2)
m00woa  =  lmer(logit ~ npi + npi:aff + (1|subj) + (1|item), data = data2)

summary(m00wi)

# npi
anova(m00wi, m00won)

# aff
anova(m00wi, m00woa)

# npi:aff(interaction)
anova(m00wi, m00woi)

# みねみんのスライドに
# backward stepwise の方法が書いてあったので参照。
#
# latex(m00, file='',booktabs=T,dcolumn=T)
# library(xtable)
```
