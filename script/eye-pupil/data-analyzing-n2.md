# Data analysis

これは pupil-dilation の分析だが、気持ちてきにはこれをそのまま台湾大のワークショップに転用したい。
baseline を決めて rate の値を観察します。ターゲットは4700ms手前のスパイク。あと、全体の曲線を３時間数で捉える。
瞳孔の反映には750msから1500msかかると言われている。750msを

## Prerequisite

### Todo

1. 必要なパッケージを `require`
1. 作業するディレクトリの確認と設定

```R
# install package required.
if(!require(lme4)){install.packages("lme4")}
if(!require(reshape)){install.packages("reshape")}
if(!require(reshape2)){install.packages("reshape2")}
if(!require(ggplot2)){install.packages("ggplot2")}
if(!require(knitr)){install.packages("knitr")}
if(!require(beepr)){install.packages("beepr")}
if(!require(lmerTest)){install.packages("lmerTest")}
# if(!require(magrittr)){install.packages("magrittr")}
if(!require(devtools)){install.packages("devtools")}
install_github("kisiyama/mudball",ref="master",force=TRUE)
require(mudball)

# ディレクトリを設定
getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil/tsv")
load("../csv/pupil_dilation_rate_data.dat")
```

### Tips

1.  if(!require(<name>)){install.packages("<name>")}
    * it does "library(<name>)." if R doesn't have the package, R installs it.
1. library に対して、require は読み込みに失敗した時にサインを出す
1. knitr is awesome. Highly recommended!
    * [Knitr is Awesome!](https://www.r-bloggers.com/knitr-is-awesome/)
    * [Markdown テーブル](https://stats.biopapyrus.jp/r/devel/md-table.html)
1. beepr allows you not to leave while waiting.
    * [beepr-stackoverflow](https://stackoverflow.com/questions/3365657/is-there-a-way-to-make-r-beep-play-a-sound-at-the-end-of-a-script)

```R
# PupilDilationRate に対して必要な情報のみに絞る
data_all = pupil_dilation_rate_data
pupil_data = aggregate(
    x=data_all$PupilDilationRate,
    by=list(
        data_all$Timestamp,
        data_all$Condition,
        data_all$ItemNo,
        data_all$ParticipantName
    ),
    FUN=mean,
    na.rm=TRUE)
colnames(pupil_data) =
    c("Timestamp", "Condition", "Item", "Participant", "PupilDilationRate")
pupil_data$Condition =
    factor(pupil_data$Condition, levels=c("a","b","c","d"))

#バランスを確認
table(pupil_data$Participant, pupil_data$Condition)
table(pupil_data$Condition)

# 下位条件を付けます
pupil_data$npi =
    ifelse(pupil_data$Condition == "a" | pupil_data$Condition == "c",
        1, 0)
pupil_data$aff =
    ifelse(pupil_data$Condition == "a" | pupil_data$Condition == "b",
        1, 0)

#中心化
pupil_data$npi = scale(pupil_data$npi, scale=T)
pupil_data$aff = scale(pupil_data$aff, scale=T)
pupil_data$PupilDilationRate=scale(pupil_data$PupilDilationRate)
# pupil_data$Timestamp = scale(pupil_data$Timestamp)
# ここのタイミングでするとループで回して検定するときに面倒なことになる。
scaled_data = pupil_data
save(scaled_data, file="../../csv/scaled_data.dat")
# Timestamp はスケールされていない
# やっぱりスケールしないとエラーが出る気がする。
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil/tsv")
load("../../csv/scaled_data.dat")

# 興味あるところから整理
# NPI mismatch の前後に興味がある。
# 前回の切り出しだと解釈が難しい。
# wo の後ろに200msのブランクが確かあったはず。正直それが何を示すかは知らぬが。
check_spans = list(
    c(4300,4500),c(4300,4700),
    c(4500,4900),c(4500,5100),
    c(4700,4900),c(4700,5100),
    c(4900,5100),c(4700,5100),
    c(5500,5700),c(5500,5900)
)
for(check_span in check_spans){
  begin = check_span[1]
  end = check_span[2]
  selected_data = scaled_data[
      scaled_data$Timestamp >= begin &
      scaled_data$Timestamp <= end,]
  selected_data$Timestamp = scale(selected_data$Timestamp)
  data = selected_data
   model = lmer(PupilDilationRate ~ npi*aff+
           (1+npi*aff|Participant) +
           (1+npi*aff|Item), data=data)
#  model = lmer(PupilDilationRate ~ npi*aff*Timestamp +
#          (1+npi*aff*Timestamp|Participant) +
#          (1+npi*aff*Timestamp|Item), data=data)
  best_model = mudball::step(model,beeping=T)
  best_model_summary = lmerTest::summary(best_model)
  fixed_effects = best_model_summary$coefficients
  model_call = best_model_summary$call
  log_name = "lmer.log"
  write("#############################",file=log_name, append=TRUE)
  write("",file=log_name, append=TRUE)
  write(sprintf("Result between %s--%s:",check_span[1],check_span[2]),
    file=log_name, append=TRUE)
  write("",file=log_name, append=TRUE)
  write(kable(fixed_effects, format = "markdown"),
    file=log_name, append=TRUE)
  write("",file=log_name, append=TRUE)
  write(as.character(model_call), file=log_name, append=TRUE)
  write("#############################", file=log_name, append=TRUE)
}
```
