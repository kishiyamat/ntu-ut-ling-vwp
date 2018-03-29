# [Data trimming and analysis](https://kisiyama.github.io/ntu-ut-ling-vwp/)

Kishiyama
https://github.com/kisiyama

---

# Analysis using R

## What kind of data can we get from the experiment?

* Downloading the data from Github
* Setting the working directory
* Opening the data with R <- *We are here!*

```R
getwd()
# setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")
file_name <- "npi_2017_New test_Rec 05_Segment 1.tsv"
data_frame <- read.table(file_name, head=T, sep="\t",
    na.string="NA", encoding="UTF-8")
head(data_frame)
```

???
So far, 
we have downloaded data from Github
and opened a software, R.

Now, let's see what kind of data we get.
To begin with, please make sure you are in the right directory.
you can check if you are in the correct folder
using a command getwd().
if it returns a different folder, please tell me or ask around.

Then, we assign a file name of an example file to a variable `file_name`
In the next line, we can use a function `read.table` for variable assignment.
Then, we can see the first several lines using `head` function.

---

## We can get...

```tsv
  ParticipantName SegmentName SegmentStart SegmentEnd SegmentDuration
1             P05   Segment 1        51212      61655           10443
2             P05   Segment 1        51212      61655           10443
3             P05   Segment 1        51212      61655           10443
4             P05   Segment 1        51212      61655           10443
  RecordingTimestamp  StudioEvent StudioEventData FixationIndex SaccadeIndex
1              51212 SceneStarted 1 3 6 d A D C B            NA            1
2              51213                                         NA            1
3              51217                                         NA            1
4              51220                                         NA           NA
  GazeEventType GazeEventDuration FixationPointX..MCSpx. FixationPointY..MCSpx.
1       Saccade                63                     NA                     NA
2       Saccade                63                     NA                     NA
3       Saccade                63                     NA                     NA
4  Unclassified                 3                     NA                     NA
  PupilLeft PupilRight  X
1        NA         NA NA
2      1.54       2.42 NA
3      1.70       2.00 NA
4      2.14       2.05 NA
>
nrow(data_frame)
> [1] 3135
```
for a trial.
Those are not exactly what we need... 

???
if you run the code,
you will see a data frame with a lot of columns.
those are what we can get from Tobii.
We can get this kind of data for each segment in a file.
But they are not exactly what we need.

We have segment start, segment end, and duration, but it doesn’t make sense.
we need to manipulate them, so that we can understand them.
Below them, we can see a column named studio event data.
We need more information to tell what these character means.

So those are not exactly what we were expecting.
so what kind of data do we want, then?

---

# Trimming

## What kind of data set do we need?

We have seen a raw data set,
but it is not ready to be analyzed.

To investigate the eye-movements, we need at least

1. the area where they focused (AOI)
1. the content on the area of interest (AOI1,AOI2,...)
1. the time when they focused on the area (GazeStart, GazeEnd)
1. the information about the participants (ParticipantName)
1. the condition of the trial (Condition)
1. the item in the trial (ItemNo)

And they will look like this at the end:

```csv
   ParticipantName SegmentName FixationPointX FixationPointY GazeStart GazeEnd
35             P05  Segment 10           1338            306       443     566
34             P05  Segment 10           1338            305       723     886
41             P05  Segment 10            320            699      1489    1642
30             P05  Segment 10            505            277      1869    1999
   Order List ItemNo Condition AOI1 AOI2 AOI3 AOI4 AOI
35     1   26     23         c    D    C    A    B   2
34     1   26     23         c    D    C    A    B   2
41     1   26     23         c    D    C    A    B   3
30     1   26     23         c    D    C    A    B   1
```

???
We have seen a raw data set,
but it is not ready to be analyzed.

To investigate the eye-movements, we need these information.
1. We have four areas, and we need to know which 
area they focused on.
1. we also need to know the content on the area of interest.
1. Information about time is also important to know when they focused on the area (GazeStart, GazeEnd)
When we analyze the data, we need to know who participated in the experiment, 
and which condition the trial is, and which item was used in the trial.

So, we need to make some changes on the raw data set.
Let's say we want to know the area they focused on.
But the data from tobii doesn't have AOI information
so somehow, we need to specify the AOI from the coordinates
and there are many changes we need to make.

So, what should we do?

---

## What should we do?

Some problems for organizing the data frame.

1. We have to take many steps
1. We need to apply the change to 792 files.`33*24=792`. <- `for loop`

### Steps we need to take

1. Getting data frame from a list of filenames
1. Making the data frame simpler
1. Adding when they start/end their fixation
1. Extracting studio event from a file
1. Adding the infomation to the data list

-> Making functions can be a good way.

???
We want to change how the data frame looks like,
but there are some problems.

We have to change a lot, and
we need to apply the changes over and over.

We can use *for loop* to apply the changes to each file
so the second one is not a big deal.
but how about the first one?
We have to...
1. get a data frame from a filenames
1. make the data frame smaller
1. add some timestamps when they start and end their fixation
1. extract and add studio event data from a file

Making functions can be a good way.

---

## Making some functions

### Why do we make functions?

Writing every program as one big chunk of statements has problems
Making functions allows us to...

1. make our programs as a bunch of sub-steps
1. reuse code instead of rewriting it.
1. keep our variable namespace clean.
1. test small parts of our program in isolation from the rest.

### Functions I made

We are going to define these functions:

1. [getDataFrameFromFileName()](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/gh-pages/script/data-trimming.r#L3-L7)
   -> 3
1. [reduceRawDataFrame()](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/gh-pages/script/data-trimming.r#L9-L67)
   -> 50+
1. [addGazeFlag()](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/gh-pages/script/data-trimming.r#L69-L108)
   -> 40
1. [extractStudioEventDataList()](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/gh-pages/script/data-trimming.r#L110-L116)
   -> 5
1. [addStudioEventDataList()](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/gh-pages/script/data-trimming.r#L118-L133)
   -> 10+

So I would like to divide the program into separate--but cooperating--functions.
[Functions](https://www.cs.utah.edu/~germain/PPS/Topics/functions.html)

![](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Function_machine2.svg/220px-Function_machine2.svg.png)

???
So why should we make functions?

If we write every program as one big chunk of statements,
there must be a lot of problems.
But if we make functions, it allows us to...
1. make our programs as a bunch of sub-steps
   * So, we can break the long program into sub-steps, when they seem tough, 
1. And we can reuse code instead of rewriting it.
   * and even share some codes with your others
Two more things.
1. We can keep our variable namespace clean, bacause local variables only "live" as long as the function does.
   * This may not sound like much, but keeping global namespace is important.
1. Finally, we can test small parts of our program.
   * This is especially true in interpreted langaues, such as R, Python, Matlab, and so on.

By making functions, I broke the long script into five steps.
And you can jump to the definition by clicking the name of the functions.

---

### Practice

```R
doubleMe <- function(argument){
    doubled_argument = argument * 2
    return((doubled_argument)) 
}
doubleMe(4)
```

To make a function, you need:

* Purpose
* Name for new function
* Function `function` which returns a function
* Argument(s) if you want.

???



---

## Getting data from file name

Let's make a function for the analysis.
> here, I'd like to get a data from file name.
> but I don't want to repeat calling `read.table`
> because it requires some arguments.
> So, I will make a simple function,
> so that we can read the data frame with a line.

```R
getDataFrameFromFileName <- function(file_name){
    data_frame <- read.table(file_name, head=T, sep="\t", 
    na.string="NA", encoding="UTF-8")
    return(data_frame)
}
```

---

```R
getwd()
# set dir to `result`
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")
head(getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv"))
  ParticipantName SegmentName SegmentStart SegmentEnd SegmentDuration
1             P05   Segment 1        51212      61655           10443
2             P05   Segment 1        51212      61655           10443
3             P05   Segment 1        51212      61655           10443
4             P05   Segment 1        51212      61655           10443
5             P05   Segment 1        51212      61655           10443
6             P05   Segment 1        51212      61655           10443
  RecordingTimestamp  StudioEvent StudioEventData FixationIndex SaccadeIndex
1              51212 SceneStarted 1 3 6 d A D C B            NA            1
2              51213                                         NA            1
3              51217                                         NA            1
4              51220                                         NA           NA
5              51223                                         NA            2
6              51227                                         NA            2
  GazeEventType GazeEventDuration FixationPointX..MCSpx. FixationPointY..MCSpx.
1       Saccade                63                     NA                     NA
2       Saccade                63                     NA                     NA
3       Saccade                63                     NA                     NA
4  Unclassified                 3                     NA                     NA
5       Saccade                10                     NA                     NA
6       Saccade                10                     NA                     NA
  PupilLeft PupilRight  X
1        NA         NA NA
2      1.54       2.42 NA
3      1.70       2.00 NA
4      2.14       2.05 NA
5      1.59       2.05 NA
6      1.53       2.03 NA
>
```

---

## Reducing data frame

Then, I would like to...

1. Rename columns for fixations
2. Add Timestamps
3. Remove columns not needed
4. Extact Fixation and Saccade (other than Unclassified)
5. Remove NA

[reduceRawDataFrame()](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/gh-pages/script/data-trimming.r#L9-L67)

---

```R
# We assign the data frame to `raw` for checking.
# We can check the contents using `head` function.
raw =  getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv")

# 1. Renaming two columns for fixations
# just selecting 
selected_column <- raw[,c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
    "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
    "FixationPointX..MCSpx.", "FixationPointY..MCSpx.", "PupilLeft", "PupilRight")]
# renaming some of them
renamed_column <- NULL
colnames(selected_column) <- c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
    "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
    "FixationPointX", "FixationPointY", "PupilLeft", "PupilRight")
renamed_column <- selected_column
```

---

```R
# 2. Adding Timestamps
# I would like to add Timestamps as new column
# run the code before explaining it
column_with_timestamp <- NULL
renamed_column$Timestamp <- renamed_column$RecordingTimestamp - renamed_column$SegmentStart
column_with_timestamp <- renamed_column
# head(column_with_timestamp)
# SegmentStart is the  onset of trial(51212)
# SegmentEnd is the offset of trial(61655)
# RecordingTimestamp is the recording points(51212 to 61655)
# Therefore, Timestamp -> 0 (51212-51212) to 10443(61655-51212)
```

---

```R
# 3. Removing columns not needed
# now we don't need some of them.
# because we have timestamp now.
# ~~SegmantStart, SegmentEnd, SegmentDuration, RecordingTimestamp, PupilLeft, PupilRight~~
selected_column <- column_with_timestamp[,c("ParticipantName", "SegmentName", "FixationIndex",
    "GazeEventType", "GazeEventDuration", "FixationPointX", "SaccadeIndex", "FixationPointY", "Timestamp")]

# 4. Extacting Fixation and Saccade (other than Unclassified)
selected_column <- selected_column[selected_column$GazeEventType != "Unclassified",]
# Now, if FixationIndex is an NA,
# the data in the row is about saccade.
# so we can replace the NA with SaccadeIndex.
selected_column$FixationIndex <- ifelse(is.na(selected_column$FixationIndex),
    selected_column$SaccadeIndex,
    selected_column$FixationIndex)

```

---

```R
# 5. Removing NA
# If the fixation point is NA, 
# that means that they didn't see the display.
# we replace NA with -1 so that we can tell that.
selected_column$FixationPointX <- ifelse(is.na(selected_column$FixationPointX),
    -1,
    selected_column$FixationPointX)
selected_column$FixationPointY <- ifelse(is.na(selected_column$FixationPointY),
    -1,
    selected_column$FixationPointY)

# data for Index is in FixationIndex
# So we can delete SaccadeIndex (see 4)
selected_column$SaccadeIndex <- NULL
refined_column <- selected_column

```
---

# Running the function definition and check if it works.
```R
raw =  getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv")
refined_data = reduceRawDataFrame(raw) 
head(raw)
head(refined_data)
```

So far, we have...
1. Renamed columns for fixations
2. Added Timestamps
3. Removed columns not needed
4. Extacted Fixation and Saccade (other than Unclassified)
5. Removed NA
[reduceRawDataFrame()](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/gh-pages/script/data-trimming.r#L9-L67)

---

## Aggregate

Before moving on the next step,
I'd like to make sure that
everyone feel confortable with a function named `aggregate`.

Aggregate is a function in base R.
It aggregates the inputted data.frame (`x`),
1. making sub-data.frames (subset) defined by the `by` input parameter.
1. applying a function specified by the `FUN` parameter to each column of the subset

---

Let's say we have a refined data, applying two functions.

```R
raw =  getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv")
refined_data = reduceRawDataFrame(raw) 
head(refined_data)
> head(refined_data,10)
   ParticipantName SegmentName FixationIndex GazeEventType GazeEventDuration
1              P05   Segment 1             1       Saccade                63
2              P05   Segment 1             1       Saccade                63
3              P05   Segment 1             1       Saccade                63
5              P05   Segment 1             2       Saccade                10
6              P05   Segment 1             2       Saccade                10
7              P05   Segment 1             2       Saccade                10
9              P05   Segment 1             3       Saccade                63
10             P05   Segment 1             3       Saccade                63
11             P05   Segment 1             3       Saccade                63
12             P05   Segment 1             3       Saccade                63
   FixationPointX FixationPointY Timestamp
1              -1             -1         0
2              -1             -1         1
3              -1             -1         5
5              -1             -1        11
6              -1             -1        15
7              -1             -1        18
9              -1             -1        25
10             -1             -1        28
11             -1             -1        31
12             -1             -1        35
```


---

Now, we are want to make it clear when the saccade/fixation starts and ends
1. find earliest timestamp in the event
    -> when the saccade/fixation starts
1. find latest timestamp in the event
    -> when the saccade/fixation ends 

So, what we need to do is
1. making sub-data.frames (subset) defined by
    1. Paticipant(we don't want to lose this info)
    1. Segment(we don't want to lose this info)
    1. FixationIndex
    1. GazeEventType
    1. (GazeEventDuration)
1. applying a function `min`/`max`
1. ... to Timestamp

Let's see if it works.

---


```R
min_table <- aggregate(
    x = refined_data$Timestamp,
    by = list(refined_data$ParticipantName, refined_data$SegmentName,
        refined_data$FixationIndex,refined_data$GazeEventType,
        refined_data$GazeEventDuration,
        refined_data$FixationPointX, refined_data$FixationPointY),
    FUN = min
)
# renaming
colnames(min_table) <- c("ParticipantName", "SegmentName",
    "FixationIndex", "GazeEventType", "GazeEventDuration",
    "FixationPointX", "FixationPointY", "GazeStart")
# re-ordering
min_table <- min_table[order(min_table$ParticipantName,
    min_table$SegmentName, min_table$GazeStart),]

# compare with the df before
head(min_table)
head(refined_data)
nrow(min_table)
# [1] 81
nrow(refined_data)
# [1] 2941
```

---

Using the function `aggregate`, we could get `GazeStart`
After gettin `GazeStart` and `GazeEnd`,
We are goin to extract them and append them to the data.

## Adding when a saccade/fixation starts/ends

Using `aggregate`, we are going to ...
1. make it clear when the fixation starts and ends
    1. find earliest timestamp in the event
        -> when the saccade/fixation starts
    1. find latest timestamp in the event
        -> when the saccade/fixation ends 

```R
head(refined_data)
addGazeFlag <- function(refined_data){
    # when the saccade/fixation starts
    min_table <- aggregate(
        x = refined_data$Timestamp,
        by = list(refined_data$ParticipantName, refined_data$SegmentName,
            refined_data$FixationIndex,refined_data$GazeEventType,
            refined_data$GazeEventDuration,
            refined_data$FixationPointX, refined_data$FixationPointY),
        FUN = min
    )
    colnames(min_table) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "FixationPointY", "GazeStart")
    min_table <- min_table[order(min_table$ParticipantName,
        min_table$SegmentName, min_table$GazeStart),]

    # when the saccade/fixation ends
    max_table <- aggregate(
        x = refined_data$Timestamp,
        by = list(refined_data$ParticipantName, refined_data$SegmentName,
        refined_data$FixationIndex,
        refined_data$GazeEventType, refined_data$GazeEventDuration,
        refined_data$FixationPointX, refined_data$FixationPointY),
        FUN = max
    )
    colnames(max_table) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "FixationPointY", "GazeEnd")
    max_table <- max_table[order(max_table$ParticipantName,
        max_table$SegmentName, max_table$GazeEnd),]

    # conbine min_table(GazeStart) and max_table(GazeEnd)
    # it is in the 8th column
    data_with_gaze_flag <- cbind(min_table, max_table[,8])

    colnames(data_with_gaze_flag) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration",
        "FixationPointX", "FixationPointY",
        "GazeStart", "GazeEnd")

    return(data_with_gaze_flag)
}
data_with_gaze_flag = addGazeFlag(refined_data)
head(data_with_gaze_flag)

   ParticipantName SegmentName FixationIndex GazeEventType GazeEventDuration
34             P05   Segment 1             1       Saccade                63
3              P05   Segment 1             2       Saccade                10
35             P05   Segment 1             3       Saccade                63
68             P05   Segment 1             1      Fixation               103
8              P05   Segment 1             4       Saccade                23
69             P05   Segment 1             2      Fixation               157
   FixationPointX FixationPointY GazeStart GazeEnd
34             -1             -1         0       5
3              -1             -1        11      18
35             -1             -1        25      85
68            839            446        88     188
8              -1             -1       191     211
69            927            449       215     368
```

So far, we have ... 
1. [got data frame from file name](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/feature-taiwan-setup/script/data-trimming.md#getting-data-from-file-name)
   * [how to make functions](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/feature-taiwan-setup/script/data-trimming.md#making-some-functions)
1. [made data simpler](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/feature-taiwan-setup/script/data-trimming.md#reducing-data-frame)
   * [what are data frames?]()
1. [made it clear when the fixation begins and ends](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/feature-taiwan-setup/script/data-trimming.md#adding-when-a-saccadefixation-startsends)
   * [what is the function *aggregate*?](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/feature-taiwan-setup/script/data-trimming.md#aggregate)

## Extracting information from E-Prime

We let E-Prime to send information about conditions and items.
We can find it in a column named `StudioEventData`

```R
file_name = "npi_2017_New test_Rec 05_Segment 1.tsv"
extractStudioEventDataList = function(file_name) {
    raw_data_frame = getDataFrameFromFileName(file_name)
    eventdata = raw_data_frame[1,]$StudioEventData
    StudioEventData = as.character(eventdata)
    list_of_eventdata = unlist(strsplit(StudioEventData, " "))
    return(list_of_eventdata)
}
```

## Adding the extracted information

We made a function which returns list of event data.
Then, we are going to add them to the data frame.

```R
addStudioEventDataList = function(list_of_eventdata, base_data_frame) { # Using matrix function, 
    # this make a matrix object, which has 
    # the same number of rows as the base data frame
    # the same number of cols as the event data
    mat_of_eventdata = matrix(data=list_of_eventdata,
        nrow=nrow(base_data_frame), ncol=length(list_of_eventdata), byrow=T)
    eventdata_data_frame = as.data.frame(mat_of_eventdata)
    colnames(eventdata_data_frame) = c("Order", "List", "ItemNo", "Condition",
        "AOI1", "AOI2", "AOI3", "AOI4")  

    # combine the base data frame and event data
    data_with_eventdata = cbind(base_data_frame, eventdata_data_frame)

    return(data_with_eventdata)
}
```

We are almost there!
We are going to apply the functions we made
for each files in the list.
So, We need to make a list of files.

## List of files

We need to make a list of files,
so that we can apply the functions we made to all files.

Data from Tobii has a format.
It looks like... 
`<project>_<test>_<participant>_<segment>.tsv`

This time it is `npi_2017_New test` and we 
1. set this pattern to the variable `file_pattern`
1. let R find the files with the pattern and set them to `data_list`
1. check if we correctly get the files

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

file_pattern <- "npi_2017_New test"
data_list <- list.files(pattern = file_pattern)
if (length(data_list) == 0){
    print('you might want to make some changes')
}else{
    print('loaded')
}
```

### filter out files without fixation

1. make a blank list for the files with fixation
1. read each `file_name` and check if it has fixation
1. append the data with fixation to `filtered_list` 

```R
# input: list
# output: list
filterOutBadTrials = function(data_list){
    # create a list
    filtered_list = as.list(NULL)
    for(file_name in data_list){
        trial = read.table(file_name, head=T, sep="\t",
            na.string="NA", encoding="UTF-8")
        fixations_in_trial = trial[trial$GazeEventType == "Fixation",]
        if(nrow(fixations_in_trial) == 0){
            warning(paste("Bad trial:",file_name))
        }else{
            filtered_list = append(filtered_list, file_name)
        }
    }
    if (length(filtered_list) == length(data_list)){
        message("there's no bad trial!")
    }
    return(filtered_list)
}

filtered_data_list = filterOutBadTrials(data_list)
```

## Main part
## integrate data in each segment and participants

For each file, we are going to

1. get a data frame from a file name
    * string -> data frame
1. add Timestamps and remove columns not needed
    * data frame -> data frame
1. make data simpler based on Fixation
    * data frame -> data frame
1. append information from E-prime

We are going to append the formatted data to the variable `data_all`

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

data_all <- NULL

# make sure the number of columns which we let E-primesend to Tobi
numcol = 8
i = 1
for(i in 1:length(filtered_data_list)){
    print(paste("now access to:", data_list[i]))
    raw_data_frame = getDataFrameFromFileName(as.character(data_list[i]))
    # head(raw_data_frame)
    reduced_data_frame = reduceRawDataFrame(raw_data_frame)
    # head(reduced_data_frame)
    data_with_gaze= addGazeFlag(reduced_data_frame)
    # head(data_with_gaze)
    list_of_eventdata = extractStudioEventDataList(as.character(data_list[i]))
    # head(list_of_eventdata )
    # check if numcol of StudioEventData is 8
    if (length(list_of_eventdata)!=numcol){
        warning(paste("Bad trial: ", data_list[i]))
    }
    data_with_eventdata = addStudioEventDataList(list_of_eventdata,data_with_gaze)
    # head(data_with_eventdata)
    data_all = rbind(data_all, data_with_eventdata)
    # head(data_all)
}

```

## Mapping x y coordiante to AOI
1. the area where they focused (AOI)

```R
# we need to have data_all globally

# split 1080*1920 into four panes.
#  1  2
#  3  4
data_all$AOI <- ifelse(data_all$FixationPointX >= 0 & data_all$FixationPointX < 960
    & data_all$FixationPointY >= 0 & data_all$FixationPointY < 540,
    1,
    0)
data_all$AOI <- ifelse(data_all$FixationPointX >= 960 & data_all$FixationPointX < 1920
    & data_all$FixationPointY >= 0 & data_all$FixationPointY < 540,
    2,
    data_all$AOI)
data_all$AOI <- ifelse(data_all$FixationPointX >= 0 & data_all$FixationPointX < 960
    & data_all$FixationPointY >= 540 & data_all$FixationPointY < 1080,
    3,
    data_all$AOI)
data_all$AOI <- ifelse(data_all$FixationPointX >= 960 & data_all$FixationPointX < 1920
    & data_all$FixationPointY >= 540 & data_all$FixationPointY < 1080,
    4,
    data_all$AOI)

# extract Fixation
data_with_fixation <-data_all[data_all$GazeEventType == "Fixation",]

# remove unneccessary infomation
data_with_fixation$GazeEventDuration <- NULL
data_with_fixation$StudioEventData <- NULL
data_with_fixation$FixationIndex <- NULL
data_with_fixation$GazeEventType <- NULL

# before
head(getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv"))
# after
head(data_with_fixation)

table(data_with_fixation$ParticipantName, data_with_fixation$SegmentName)

# savef as csv
# write.csv(data_with_fixation, "./csv/output.csv", row.names=F)
```

1. the area where they focused (AOI)
1. the content on the area of interest (AOI1,AOI2,...)
1. the time when they focused on the area (GazeStart, GazeEnd)
1. the information about the participants (ParticipantName)
1. the condition of the trial (Condition)
1. the item in the trial (ItemNo)

```R
# before
  ParticipantName SegmentName SegmentStart SegmentEnd SegmentDuration
1             P05   Segment 1        51212      61655           10443
2             P05   Segment 1        51212      61655           10443
3             P05   Segment 1        51212      61655           10443
4             P05   Segment 1        51212      61655           10443
5             P05   Segment 1        51212      61655           10443
6             P05   Segment 1        51212      61655           10443
  RecordingTimestamp  StudioEvent StudioEventData FixationIndex SaccadeIndex
1              51212 SceneStarted 1 3 6 d A D C B            NA            1
2              51213                                         NA            1
3              51217                                         NA            1
4              51220                                         NA           NA
5              51223                                         NA            2
6              51227                                         NA            2
  GazeEventType GazeEventDuration FixationPointX..MCSpx. FixationPointY..MCSpx.
1       Saccade                63                     NA                     NA
2       Saccade                63                     NA                     NA
3       Saccade                63                     NA                     NA
4  Unclassified                 3                     NA                     NA
5       Saccade                10                     NA                     NA
6       Saccade                10                     NA                     NA
  PupilLeft PupilRight  X
1        NA         NA NA
2      1.54       2.42 NA
3      1.70       2.00 NA
4      2.14       2.05 NA
5      1.59       2.05 NA
6      1.53       2.03 NA

# after
   ParticipantName SegmentName FixationPointX FixationPointY GazeStart GazeEnd
35             P05  Segment 10           1338            306       443     566
34             P05  Segment 10           1338            305       723     886
41             P05  Segment 10            320            699      1489    1642
30             P05  Segment 10            505            277      1869    1999
26             P05  Segment 10            365            199      2042    2219
25             P05  Segment 10            406            176      2239    2362
   Order List ItemNo Condition AOI1 AOI2 AOI3 AOI4 AOI
35     1   26     23         c    D    C    A    B   2
34     1   26     23         c    D    C    A    B   2
41     1   26     23         c    D    C    A    B   3
30     1   26     23         c    D    C    A    B   1
26     1   26     23         c    D    C    A    B   1
25     1   26     23         c    D    C    A    B   1
> 
```

---
### Graphing (10 minutes)
[data visualizing](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/master/script/data-visualizing.md)


we are going to see the eye-movements of participants
toward the target entity.

1. set up (set wd, import libs, and read data)

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")
# kishiyama for linux, kisiyama for windows
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

library(ggplot2)
library(reshape)
if(!require(lme4)){install.packages("lme4")}
if(!require(reshape)){install.packages("reshape")}
if(!require(reshape2)){install.packages("reshape2")}
if(!require(ggplot2)){install.packages("ggplot2")}
if(!require(knitr)){install.packages("knitr")}
if(!require(beepr)){install.packages("beepr")}
if(!require(lmerTest)){install.packages("lmerTest")}

data_all <- read.csv("./output.csv", header =T)
summary(data_all)
head(data_all)
```

1. digitalize the data

```R
# define the span for the graph here
span_begin <- 4100
span_end <- 5500

# Generating a sequence from span_begin to span_end by 20 ms.
pol_n2 <- seq(from=span_begin,to=span_end,20)

# make a table for binary data 
# nrow(data_all) == 20621
binary_data <- matrix(span_begin, nrow=nrow(data_all), ncol=length(pol_n2))
colnames(binary_data) <- pol_n2

# from span begin to end, check if there is gaze event
for (i in 1:length(pol_n2)){
    binary_data[,i] <- ifelse(
        (data_all$GazeStart < (span_begin + i * 20) &
        data_all$GazeEnd > (span_begin + i * 20)),
        1,
        0)}

# combine the binary data with all data
gr <- cbind(data_all, as.data.frame(binary_data))　

# AOIs has numbers . see the content in the AOI.
gr$Target <- ifelse(gr$AOI == 1, as.character(gr$AOI1), "BackGround")
gr$Target <- ifelse(gr$AOI == 2, as.character(gr$AOI2), gr$Target)
gr$Target <- ifelse(gr$AOI == 3, as.character(gr$AOI3), gr$Target)
gr$Target <- ifelse(gr$AOI == 4, as.character(gr$AOI4), gr$Target)

# participant,item, cond, AOI,Target,bin
gr<- gr[,c(1, 9, 10, 15, ncol(gr), 16:(ncol(gr)-1))]
head(gr)

# melt time binaries into one column.
gr2 <- melt(gr,id=c("ParticipantName", "ItemNo", "Condition", "AOI", "Target"))
gr2$variable <- as.numeric(as.character(gr2$variable))
gr2 <- gr2[order(gr2$ParticipantName, gr2$ItemNo),]

# in the recording of Tobii, count 1 if the AOI is seen in the 20m
# this causes many duplicates bacause of counting 0 for other AOIs.
# aggregate remove dups so that no dup in a bin
gr3 <-aggregate(
    gr2$value,
    by = list(gr2$ParticipantName, gr2$ItemNo, gr2$Condition,  gr2$AOI, gr2$Target, gr2$variable),
    FUN = sum,
    na.rm = TRUE)
colnames(gr3) = c("subj","item","cond", "AOI", "variable", "bin","value")
gr3$AOI <- NULL
head(gr3)

# gr3 has 2 columns: `variable` and `value`
# function `cast` makes
# 1. new cols based on levels in `variable` 
# 1. new rows based on levels in `value`
gr.temp <- cast(gr3)
head(gr.temp)

# N1_V1_t :A
# N1_V1_f :B
# N2_V1_t :C
# N2_V1_f :D
gr.temp$A <- ifelse(is.na(gr.temp$A),0,gr.temp$A)
gr.temp$B <- ifelse(is.na(gr.temp$B),0,gr.temp$B)
gr.temp$C <- ifelse(is.na(gr.temp$C),0,gr.temp$C)
gr.temp$D <- ifelse(is.na(gr.temp$D),0,gr.temp$D)

# If you need regard two(or more) area as one area,
# you might want to make some changes here.
# gr.temp$Combined <- gr.temp$TargetCompound + gr.temp$CompetitorCompound
# gr.temp$IrrelevantCompound <- gr.temp$IrrelevantCompoundA + gr.temp$IrrelevantCompoundB

# (t1) N1_V1_t (t2) N1_V1_f (t3) N2_V1_t (t4) N2_V1_f
gr.temp$t1 <- gr.temp$A
gr.temp$t2 <- gr.temp$B
gr.temp$t3 <- gr.temp$C
gr.temp$t4 <- gr.temp$D

# c: correct
# w: wrong
gr.temp$c <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$C, gr.temp$D)
gr.temp$w <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$D, gr.temp$C)

gr.temp$cn1 <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$A, gr.temp$B)
gr.temp$wn1 <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$B, gr.temp$A)

#aggregate for graph (Use t1~t4)
gra <- aggregate(
    gr.temp$c,
    by=list(gr.temp$bin, gr.temp$cond),
    mean)
colnames(gra) <- c("bin", "cond", "mean")

# a: NPI+AFF
# gra$cond <- ifelse((gra$cond == 1), "NPI_t_AFF_t", gra$cond)
# gra$cond <- ifelse((gra$cond == 2), "NPI_f_AFF_t", gra$cond)
# gra$cond <- ifelse((gra$cond == 3), "NPI_t_AFF_f", gra$cond)
# gra$cond <- ifelse((gra$cond == 4), "NPI_f_AFF_f", gra$cond)

# rename the cond name
library(ggplot2)
library(reshape)
library(plyr)
gra$cond=
    revalue(gra$cond,
        c("a"="NPI+AFF+:(sika->aru)",
        "b"="NPI-AFF+:(dake->aru)",
        "c"="NPI+AFF-:(sika->nai)",
        "d"="NPI-AFF-:(dake->nai)")
    )

# make a graph
d = data.frame(t = c(4100, 4700 , 5500),
          region = c("V1", "POL", "N2"))
g.Combined.Region6000 <-
    ggplot(data=gra, aes(x=bin, y=mean, colour = cond))+
    # we can draw some vertical lines
    geom_vline(data=d, mapping=aes(xintercept=t), linetype=3, color="black") +
    geom_text(data=d, mapping=aes(x=t, y=0.45, label=region),
        size=5, angle=90, vjust=-0.4, hjust=0 , color="#222222", family="mono") +
    # geom_line(aes(group=cond, color=cond, alpha = 0.99)) +
    geom_line(aes(group=cond, color=cond)) +
    # geom_point(aes(group=cond, color=cond)) +
    scale_x_continuous("Time") +
    scale_y_continuous(limits=c(0,0.5), name="Proportion of looks to target N2") +
    scale_color_discrete("Condition") +
    theme(axis.title.y = element_text(size = 16)) +
    theme(axis.title.x = element_text(size = 20)) +
    theme(legend.title = element_text(size = 16)) +
    theme(legend.text = element_text(size = 20))+
    # theme_bw() +
    theme_classic()+
    ggtitle("Proportion of gaze to N2 doing V1"
)  

ppi <- 600
g.Combined.Region6000
# png("../png/n2_target_full.png", width=12*ppi, height=6*ppi, res=ppi)
dev.copy(pdf, "../pdf/n2_v1_full.pdf")

dev.off()
```

---

### LME (10 minutes)
[data analyzing](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/master/script/data-analyzing.md)

1.  if(!require(<name>)){install.packages("<name>")}
    * it does "library(<name>)." if R doesn't have the package, R installs it.
1. knitr is awesome. Highly recommended!
    * [Knitr is Awesome!](https://www.r-bloggers.com/knitr-is-awesome/)
    * [Markdown table](https://stats.biopapyrus.jp/r/devel/md-table.html)
1. beepr allows you not to leave while waiting.
    * [beepr-stackoverflow](https://stackoverflow.com/questions/3365657/is-there-a-way-to-make-r-beep-play-a-sound-at-the-end-of-a-script)
1. set up (set wd, import libs, and read data)

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

# install package required.
if(!require(lme4)){install.packages("lme4")}
# if you're using WSL, you need to have some packages before.
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

library(lme4)
library(reshape)

data <- read.csv("./output.csv", header =T)
head(data)
# check its distribution
table(data$ParticipantName, data$Condition)
table(data$Condition)

# AOIs has numbers . see the content in the AOI.
# as same as the way we took in the visualization step
data$target <- ifelse(data$AOI == 1, as.character(data$AOI1), "BackGround")
data$target <- ifelse(data$AOI == 2, as.character(data$AOI2), data$target)
data$target <- ifelse(data$AOI == 3, as.character(data$AOI3), data$target)
data$target <- ifelse(data$AOI == 4, as.character(data$AOI4), data$target)

data <-data[order(data$ParticipantName, data$ItemNo, data$GazeStart),]
```

1. We want to extract the data in the region we are interested in.

```R
# define the span for the graph here
onset_var <- 4700
offset_var <- 5100
span <- offset_var - onset_var

# start lapse and end lapse
data$slapse <- data$GazeStart - onset_var
data$elapse <- data$GazeEnd - onset_var
head(data)

# The lapse(slapse) until the onset become negative values
# we will ignore the negatives later
# not taking them into account

#  slapse elapse
#1   -824   -670
#2   -603   -397
#3      3    173
#4    177    680
#5    926   1523
#6   1220   1603

data$slapse <- ifelse(data$slapse < 0, 0, data$slapse)
data$elapse <- ifelse(data$elapse >= span, span, data$elapse)

#  slapse elapse
#1      0   -199
#2      0    -10
#3      3      3
#4    177    177
#5    926   1000
#6   1220   1000

data$dur <- data$elapse - data$slapse
data$dur <- ifelse(data$dur < 0, 0, data$dur)

# by subtracting slapse from elapse,
# we can focus on the area with positive value(dur)

data <- data[,c("ParticipantName", "ItemNo", "target", "Condition", "slapse","elapse","dur")]
data <- data[order(data$ParticipantName,data$ItemNo,data$slapse),]

# CALUCULATING SUM (aggregation for each trial)
data <-aggregate(
    data$dur,
    by=list(data$ParticipantName, data$ItemNo, data$target, data$Condition),
    FUN=sum,
    na.rm=TRUE)
colnames(data) = c("subj","item","AOI","cond","sum")

# sort
data <- data[order(data$subj, data$item),]

# set colname "variable","value" to use cast()
colnames(data) = c("subj","item","variable","cond","value")
head(data)
# cast creates separate columns for each object fixated

data2 <- cast(data)
head(data2)

# replace NULL
data2$BackGround <- ifelse(is.na(data2$BackGround), 0, data2$BackGround)
data2$A<- ifelse(is.na(data2$A), 0, data2$A)
data2$B<- ifelse(is.na(data2$B), 0, data2$B)
data2$C<- ifelse(is.na(data2$C), 0, data2$C)
data2$D<- ifelse(is.na(data2$D), 0, data2$D)

data2$Target <- ifelse((data2$cond == "a" | data2$cond == "b"), data2$C, data2$D)
head(data2)

#  head(data2)
# # subj item cond   A   B BackGround   C D Target all      logit
# 1  P05    1    a   0 195          0  99 0     99 294 -0.6754027
# 2  P05    2    d   0 400          0   0 0      0 400 -6.6858609
# 3  P05    3    c 391   0          0   0 0      0 391 -6.6631327
# 4  P05    4    b   0   0          0 347 0    347 347  6.5439118
# 5  P05    5    a 328   0          0   0 0      0 328 -6.4876840
# 6  P05    6    d 101 223          0   0 0      0 324 -6.4754327

# calculate ALL column
data2$all <-  (data2$BackGround
              + data2$A
              + data2$B
              + data2$C
              + data2$D)

data2$logit <- log((data2$Target + 0.5) / (data2$all - data2$Target + 0.5))

# making 2 by 2
data2$npi <- ifelse(data2$cond == "a" | data2$cond == "c", 1, 0)
data2$aff <- ifelse(data2$cond == "a" | data2$cond == "b", 1, 0)

# scaling
data2$npi <- scale(data2$npi, scale=T)
data2$aff <- scale(data2$aff, scale=T)

# data2$logit<-data2$logit_c
tapply(data2$logit, list(data2$npi, data2$aff), mean)

sum(data2[data2$cond == "a",]$Target)
sum(data2[data2$cond == "b",]$Target)

if(!require(knitr)){install.packages("knitr")}
if(!require(lmerTest)){install.packages("lmerTest")}
if(!require(devtools)){install.packages("devtools")}
install_github("kisiyama/mudball",ref="master",force=TRUE)
require(mudball)

model <- lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
model_0 <- lmer(logit ~ npi * aff + (1 |subj) + (1 |item), data = data2)

best_model = mudball::step(model,beeping=T)
best_model_summary = lmerTest::summary(best_model)
fixed_effects = best_model_summary$coefficients
model_call = best_model_summary$call
log_name = "lmer.log"
write("#############################",file=log_name, append=TRUE)
write("",file=log_name, append=TRUE)
kable(fixed_effects, format = "markdown")
write("",file=log_name, append=TRUE)
write(as.character(model_call), file=log_name, append=TRUE)
write("#############################", file=log_name, append=TRUE)

m00wi  <-  lmer(logit ~ npi * aff + (1|subj) + (1|item), data = data2)
m00woi  <-  lmer(logit ~ npi + aff + (1|subj) + (1|item), data = data2)
m00won  <-  lmer(logit ~ aff + npi:aff + (1|subj) + (1|item), data = data2)
m00woa  <-  lmer(logit ~ npi + npi:aff + (1|subj) + (1|item), data = data2)

summary(m00wi)

# npi
anova(m00wi, m00won)
# aff
anova(m00wi, m00woa)
# npi:aff(interaction)
anova(m00wi, m00woi)
```

---

## Misc-tips

---

Thank you!
