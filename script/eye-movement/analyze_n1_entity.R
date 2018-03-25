# eye-movement-overall

## Analysis of gaze to N1

getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main")

library(lme4)
library(reshape)

data <- read.csv("./csv/output.csv", header =T)
head(data)
#バランスを確認
table(data$ParticipantName, data$Condition)
table(data$Condition)

#実際のAOIの名前をマッピングします　
data$target <- ifelse(data$AOI == 1, as.character(data$AOI1), "BackGround")
data$target <- ifelse(data$AOI == 2, as.character(data$AOI2), data$target)
data$target <- ifelse(data$AOI == 3, as.character(data$AOI3), data$target)
data$target <- ifelse(data$AOI == 4, as.character(data$AOI4), data$target)

data <-data[order(data$ParticipantName, data$ItemNo, data$GazeStart),]


#onset時間点：どのonsetから切り揃えるでしょうか
# d = data.frame(t = c(2000 , 2800 , 3300 , 3500 , 4100, 4700 , 5500),
#           region = c(""   , "N1" , "NPI", ""   , "V1", "POL", "N2"))
onset_var <- 4700
offset_var <- 5100
span <- offset_var - onset_var

data$slapse <- data$GazeStart - onset_var
data$elapse <- data$GazeEnd - onset_var

# 例： onset1からでしたら0,
# data$slapse <- data$GazeStart - 0
# data$elapse <- data$GazeEnd - 0

# onset2からでしたらdata$onset2
# data$slapse <- data$GazeStart - data$onset2
# data$elapse <- data$GazeEnd - data$onset2

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
data$slapse <- ifelse(data$slapse < 0, 0, data$slapse)
data$elapse <- ifelse(data$elapse >= span, span, data$elapse)
# 上の場合、開始点は0（当たり前だのクラッカー）,終了点は800 となる。

# 例：開始点は0,終了点は1000
# -> 0以下は0で入れ替え、1000以上は1000で入れ替えます
# 相殺してしまうと、概念上slapseとelapse以外の点が外されてしまします。（すごい技！）
# data$slapse <- ifelse(data$slapse < 0, 0, data$slapse)
# data$elapse <- ifelse(data$elapse >= 1000, 1000, data$elapse)

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
data$dur <- data$elapse - data$slapse
# 万が一0以下（オーバーした区間）を除外
data$dur <- ifelse(data$dur < 0, 0, data$dur)

#必要なコラムだけを残ります
data <- data[,c("ParticipantName", "ItemNo", "target", "Condition", "slapse","elapse","dur")]
data <- data[order(data$ParticipantName,data$ItemNo,data$slapse),]

#CALUCULATING SUM (aggregation for each trial)
#同じ区間の中もし別に他の注視時間があれば全部合算する。
data <-aggregate(
    data$dur,
    by=list(data$ParticipantName, data$ItemNo, data$target, data$Condition),
    FUN=sum,
    na.rm=TRUE)
colnames(data) = c("subj","item","AOI","cond","sum")

#sort
data <- data[order(data$subj, data$item),]
#"variable","value"に書き換えないと、cast()が実行できません
colnames(data) = c("subj","item","variable","cond","value")

# cast creates separate columns for each object fixated
# 各絵に分けたら、それぞれの絵にどれくらい見ているのか、
# 後で分けて計算しやすい。（いちいち取り出すではなく、コラム単位で計算できる）

# cast 関数が無い。
data2 <- cast(data)

# replace NULL
# ここはどのような列を作っているかにもよります。
data2$BackGround <- ifelse(is.na(data2$BackGround), 0, data2$BackGround)
data2$A<- ifelse(is.na(data2$A), 0, data2$A)
data2$B<- ifelse(is.na(data2$B), 0, data2$B)
data2$C<- ifelse(is.na(data2$C), 0, data2$C)
data2$D<- ifelse(is.na(data2$D), 0, data2$D)

# たぶん、data2$Aとかの列にはその文節で見られている時間が記録されている。
# だから、data2$Target みたいなのを作って上げればいいはず。

# N1 V1 AFF N2 -> N2 V1 が正解
# TODO ここおかしい。たぶん、

# data2$Target <- ifelse((data2$cond == "a" | data2$cond == "b"), data2$C, data2$D)

# calculate ALL column
data2$all <-  (data2$BackGround
              + data2$A
              + data2$B
              + data2$C
              + data2$D)

# ここ、a,b,コレクト、ロング、にしたほうが良さそう。

# 検証したい絵の条件はここで変更
# 条件が一つの絵のみの場合

data2$logit <- log((data2$A + 0.5) / (data2$all - data2$A + 0.5))

# 条件がC(N2がV1をしている絵)の場合

# 条件が２つ以上の絵の場合
#data2$Competitor_TargetCompound <- data2$CompetitorCompound + data2$TargetCompound
#data2$logit <- log((data2$Competitor_TargetCompound + 0.5) / (data2$all - data2$Competitor_TargetCompound + 0.5))

# たぶん、該当する文節でのgazeの割合を見ている。
# 基本四つのパタン.odds率を計算。0.5は微調整（分母が0でしたら計算できなくなります。）
# data2$logit_c <- log((data2$C + 0.5) / (data2$all - data2$C + 0.5))
# data2$logit_a <- log((data2$A + 0.5) / (data2$all - data2$A + 0.5))
# data2$logit_b <- log((data2$B + 0.5) / (data2$all - data2$B + 0.5))
# data2$logit_d <- log((data2$D + 0.5) / (data2$all - data2$D + 0.5))

# 下位条件を付けます
# wo-ni の奴やで。
data2$a<- ifelse(data2$cond == "a", 1, 0)
data2$b<- ifelse(data2$cond == "b", 1, 0)
data2$c<- ifelse(data2$cond == "c", 1, 0)

#中心化
# data2$npi <- scale(data2$npi, scale=F)
# data2$aff <- scale(data2$aff, scale=F)
data2$a<- scale(data2$a, scale=T)
data2$b<- scale(data2$b, scale=T)
data2$c<- scale(data2$c, scale=T)

#転換しやすいため
#logit1:Competitor_TargetCompound
#logit2:TargetCompound
#logit3:CompetitorCompound
#logit4:TargetSimplex

# data2$logit<-data2$logit_c
tapply(data2$logit, list(data2$a, data2$b, data2$c), mean)

# t = -2.1276, df = 387.55, p-value = 0.034
# どの時点にピークを迎えたか、というのも指標にならないか。
# すくなくとも、
# N2を聞く前に単節の構造を放棄している様に見える。
# ピークがどこにくるか。
#
# 「ない」の分析は4500時点で構造を変えている。

# # #汎用性LMEモデル
install.packages("devtools")
require(devtools)
install_github("kisyaman/mudball",force=TRUE)
require(mudball)

model = lmer(logit ~ a+b+c + (1+a+b+c|subj) + (1+a+b+c|item), data = data2)
models = mudball::step(model,beeping=T)

m00 <- lmer(logit ~ a+b+c + (1 |subj) + (1+a |item), data = data2)
summary(m00)


m00_a <- lmer(logit ~ b+c + (1 |subj) + (1+a |item), data = data2)
m00_b <- lmer(logit ~ a+c + (1 |subj) + (1+a |item), data = data2)
m00_c <- lmer(logit ~ a+b + (1 |subj) + (1+a |item), data = data2)

# a
anova(m00, m00_a)

# b
anova(m00, m00_b)

# c
anova(m00, m00_c)


# bに対するa

model = lmer(logit ~ a+b + (1+a+b|subj) + (1+a+b|item), data = data2)
models = mudball::step(model,beeping=T)
m00 <- lmer(logit ~ a+b + (1 |subj) + (1 |item), data = data2)
summary(m00)
m00_a <- lmer(logit ~ b + (1 |subj) + (1 |item), data = data2)
# a
anova(m00, m00_a)


# bに対するc
# c
model = lmer(logit ~ c+b + (1+c+b|subj) + (1+c+b|item), data = data2)
models = mudball::step(model,beeping=T)
m00 <- lmer(logit ~ c+b + (1 |subj) + (1 |item), data = data2)
summary(m00)
m00_c <- lmer(logit ~ b + (1 |subj) + (1 |item), data = data2)
anova(m00, m00_c)



sum(data2[data2$cond == "a",]$A)
sum(data2[data2$cond == "b",]$A)
sum(data2[data2$cond == "c",]$A)
sum(data2[data2$cond == "d",]$A)

t.test(data2[data2$cond == "a",]$A,data2[data2$cond == "b",]$A)
t.test(data2[data2$cond == "a",]$A,data2[data2$cond == "c",]$A)
t.test(data2[data2$cond == "a",]$A,data2[data2$cond == "d",]$A)

