
# 2. Data trimming and analysis (by Kishiyama) (10:45-12:30)

## 2.1 Experiment design of Kishiyama(2018) (5 minutes, 10:45-10:50)
> Short introduction of the design and prediction in Kishiyama (2018))
どんなデザインでどんなデータが出力できるのか。
いつ、なにをどれくらい見るはずだ、という仮説を立てて検証したい。

## 2.2 Analysis using R

### Data Structure (5 minutes)
- What kind of data do we get?
- We can define it in Tobii Studio. we need some settings. Unless we filter some of them out, outputs from tobii are going to be huge. Wait... does it mean that if we do that correctly here, we dont need trimming?
- example
- make module
- What kind of data do we **want**?
- example
- but how? -> trimming??
### Trimming (10 minutes)
- もともとのデータ
それをどうしたいか
どういうステップを踏みたいか
それぞれの関数の説明
それを全てのファイルに適用してまとめる。

なんで関数を使うか
-> ネストを少なくできる。

- tips
* file I/O とボトルネックの説明
* ボトルネックの検索方法
* time関数

### Graphing (10 minutes)
- グラフの作り方
- 変数名の変更 tips
- magrittrとか？　式が見やすくなる
- でも正直excelで良いかな...
### LME (10 minutes)
- つーかそもそもデータの読み込みからかな？
- backward な方法
- beepr()
- 待つの嫌い。let me know...
- 処理に挟むだけで分かる

### Misc-tips

* Camel OR snake
* capital を関数名か変数名かで分ける
* Readble code
* 読みやすいコードの定番
* 忘年会の古本交換会に参加したら３冊かぶる
* pdfで読める
* global は変数名が喧嘩しやすいから長く、local は短く
* 実験刺激の作り方は最終日に譲った方が全体のバランスがよさそう
* how to find bottle neck
## 疑問

* 必要なパッケージとか、ディレクトリの設定とかはいつするべきか
* 毎回するべき。明示的であればあるほどいい。
* なんでmarkdown で書くの？
* Pandocの整形時にコードハイライトが使えて~~カッコいい~~分かりやすいから

## 要望

octaveとかもメンションしたい

# eye-tracking-lme

markdown-preview-plus を Atom に導入。
https://qiita.com/kouichi-c-nakamura/items/5b04fb1a127aac8ba3b0

eye-tracking の実験で得たデータを解析するためのスクリプト。

# Rules
* やっぱり名前にオペレーターは入れてはならない
* 相変わらず aggregate がわからない。
  * Splits the data into subsets, computes summary statistics for each, and returns the result in a convenient form.
  * aggregate:	(…を)集合する、集める、集団とする
  * filter みたいな機能を持っているらしい。
  * help("aggregate") でどうぞ

* 命名責任を放棄してはならない
* 関数化して例外処理を組み込みましょう
* 三項演算子は可読性を下げるため使わない
  * と思いきや、三項演算子を使わないと置き換えができない仕様
* インデントは4スペース
* 読めば分かる点はコメントをかかない。
* 変数はスネークケースで、関数とクラスはキャメルで、カラム名はアッパーキャメルケース
* code は syntax が似ている python 指定。
* データと、そのデータを使うロジックは、一つのクラスにまとめる
* 一つ一つのオブジェクトの役割は単純にする
* 複雑な処理は、オブジェクトを組み合わせて実現する
* [R の S4 クラス、メソッド入門](http://www.okadajp.org/RWiki/?S4%20クラスとメソッド入門)
* 最初に目的、最後に補足。
* x<-"chen_practice_New test_B_P001_Segment 1.tsv"
* 変数名はcamelCaseかsnake_caseで。

```bash
pandoc -V documentclass=ltjarticle -V geometry:margin=1in --number-sections --latex-engine=lualatex --filter pandoc-citeproc data-trimming.md -o data-trimming.pdf
```
ディレクトリじゃできないから、ちゃんと移ってから実行する

```bash
pandoc -V documentclass=ltjarticle -V geometry:margin=1in --number-sections --latex-engine=lualatex --filter pandoc-citeproc head-entity-ratio.md -o head-entity-ratio.pdf
```
