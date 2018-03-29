# Data trimming and analysis
Kishiyama
https://github.com/kisiyama

???
this is note for me.

---

## 2.1 Experiment design of Kishiyama(2018) (5 minutes, 10:45-10:55)
We have seen this.

<!---
???
check how note in comment works
-->
---

## 2.2 Analysis using R

見えてますか？
???
<!---
check how note in comment works
-->

### Data Structure (5 minutes)

* Downloading data from Github
* Opening the data with R

I'd like to use github to do that below,
because it is quite difficult to share code in PPT,
We start with trimming the data we just saw.

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

---

And they will look like this at the end:

```csv
"ParticipantName","SegmentName","FixationPointX","FixationPointY","GazeStart","GazeEnd","Order","List","ItemNo","Condition","AOI1","AOI2","AOI3","AOI4","AOI"
"P05","Segment 1",839,446,88,188,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",927,449,215,368,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",589,340,425,575,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",417,256,615,801,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",424,181,831,1048,"1","3","6","d","A","D","C","B",1
```

---
By contrast, as we have seen, the outputs from Tobii have

1. x y coordinate of the gaze event
    * but not AOI information
    > we need to specify the AOI from the coordinates
1. time stamp from the onset of the trial
    * but not the exact time when they focused on the area (GazeStart, GazeEnd)
1. mixed information of the gaze event type 
    * not only fixation but also saccade and unclassified
1. information from E-Prime(StudioEvent)
    * somehow we need to retrieve it from the row.

---
And look like this:

```tsv
ParticipantName SegmentName     SegmentStart    SegmentEnd      SegmentDuration RecordingTimestamp      StudioEvent     StudioEventData FixationIndex   SaccadeIndex    GazeEventType   GazeEventDuration       FixationPointX (MCSpx)  FixationPointY (MCSpx)  PupilLeft       PupilRight      
P05     Segment 1       51212   61655   10443   51212   SceneStarted    1 3 6 d A D C B         1       Saccade 63                                      
P05     Segment 1       51212   61655   10443   51213                           1       Saccade 63                      1.54    2.42    
P05     Segment 1       51212   61655   10443   51217                           1       Saccade 63                      1.70    2.00    
P05     Segment 1       51212   61655   10443   51220                                   Unclassified    3                       2.14    2.05    
P05     Segment 1       51212   61655   10443   51223                           2       Saccade 10                      1.59    2.05    
```

So, what should we do?

---
## Making some functions

We want to change how the data frame looks like,
but there are some problems.
1. We have to change a lot.
1. We need to apply the change to 792 files.`33*24=792`.

We can use *loop* to apply the changes to each file,
but how about the first one?
We are going to define these functions:

1. getDataFrameFromFileName()
   -> 3
1. reduceRawDataFrame()
   -> 50+
1. addGazeFlag()
   -> 40
1. extractStudioEventDataList()
   -> 5
1. addStudioEventDataList()
   -> 10+
1. filterOutBadTrials()
   -> 15

and there are more than 100 lines in total.
---
If we write every program as one big chunk of statements,
there must be a lot of problems.
If we make functions, it allows us to...

1. make our programs as a bunch of sub-steps
   * When any program seems too hard, just break the overall program into sub-steps.
1. reuse code instead of rewriting it.
   * and share some codes with your friend (as Chen-san did).
1. keep our variable namespace clean.
   * local variables only "live" as long as the function does.
1. test small parts of our program in isolation from the rest.
   * This is especially true in interpreted langaues, such as R, Python, Matlab, and so on.

So I would like to divide the program into separate--but cooperating--functions.
[Functions](https://www.cs.utah.edu/~germain/PPS/Topics/functions.html)

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
* purpose
* name for new function
* function `function` which returns a function
* argument(s) if you want.

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

Then, I would like to remove some columns
to make the problem simpler
1. Renaming columns for fixations
2. Adding Timestamps
3. Removing columns not needed
4. Extacting Fixation and Saccade (other than Unclassified)
5. Removing NA

```R
# We assign the data frame to `raw` for checking.
# We can check the contents using `head` function.
raw =  getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv")

reduceRawDataFrame <- function(raw){
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

    return(refined_column)
}

# Running the function definition and check if it works.
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

## Aggregate

Before moving on the next step,
I'd like to make sure that
everyone feel confortable with a function named `aggregate`.

Aggregate is a function in base R.
It aggregates the inputted data.frame (`x`),
1. making sub-data.frames (subset) defined by the `by` input parameter.
1. applying a function specified by the `FUN` parameter to each column of the subset

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
---

### LME (10 minutes)
[data analyzing](https://github.com/kisiyama/ntu-ut-ling-vwp/blob/master/script/data-analyzing.md)
---

### Misc-tips
---
