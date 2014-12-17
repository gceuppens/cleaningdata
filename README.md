Getting and Cleaning Data Course Project
========================================

Introduction
------------
The code book contains a general description of the data set, the processing 
done and the resulting tidy data set. This README focusses on how the analysis 
script works and zooms in on some of the processing details.

Description of the analysis script
----------------------------------
The processing of the Samsung data resulting in the tidy data set is done using
the run_analysis.R script.

###downloadData

Downloads the zip file from the Coursera web site and unzips the data if not
done already.

###readColumnHeaders

This function reads in the column headers from the features.txt document. It 
returns the cleaned up column headers as a character vector.

According to the course lectures, names of variables should be:

   - All lower case when possible
   - Descriptive (Diagnosis versus Dx)
   - Not duplicated
   - Not have underscores or dots or white spaces

(See lecture notes on 'Editing Text Variables' last slide)

Note that the first requirement coupled with the 4th would result in 
unreadable column names and hence both together are clearly non sensical.
This was confirmed by TA David Hood here:
https://class.coursera.org/getdata-016/forum/thread?thread_id=76

I've therefore chosen to use camelCase for the headers.

The variable names listed in the file features.txt cannot be used straight 
away as column names for the measurements. They contain characters like ',', 
'(', ')' and '-' which will pose difficulties if we'd like to use them to 
address columns in R data frames.

We have therefore done the following clean up of the column headers:

1. Remove all litteral '()'
2. Remove all '(', ')', ',', and '-'
3. Remove multiple Body as in BodyBody
4. Replace initial t with time and f with freq
5. Make long readable names:

   * "Acc" --> "Acceleration"
   * "Gyro" --> "Gyroscope"
   * "Mag" --> "Magnitude"
6. Convert to camelCase so mean becomes Mean and std becomes Std

In the script this was done using an intermediate step with underscore but the
general principles are described above.

There is an even bigger issue in that the variable names are not unique. This 
can be tested using the following R code (where columnNames is the vector of 
column names read from the features.txt file)
```
# If there are no duplicate entries, the following number should be zero:
# Unfortunately it's not zero but 561 - 477 -> 84
duplicateEntryCount <- length(columnNames) - length(unique(columnNames))

# Create a list of the indices of each unique column name in the overall list
# of column names. This list will give for each column name, the row numbers 
# where that name can be found in columnNames. When there are multiple entries 
# for that unique name, the length of the list will be > 1. 
tmp <- sapply(unique(columnNames), function(el) which(columnNames == el))
# Find out how many names occur more than once; this is 42
duplicateNames <- tmp[sapply(tmp, function(el) length(el) > 1)]
n <- length(duplicateNames)
# We can see by inspecting duplicateNames that each row has 3 entries; this
# can also be seen by
min(sapply(duplicateNames, length))  # 3
max(sapply(duplicateNames, length))  # 3
```
The problem lies in the variables with bandsEnergy in the name. There should be
an X, Y and Z version of those variables, but that label is missing.  
Of the 42 variables that occur more than once, we need 2x42 extra variables (
we've counted one of X,Y,Z, but we need 3 so 2 more of each variable). The 
count then matches: 

* unique names: 477
* missing names: 2x42 = 84
* total names: 561

We've added code that fixes the non unique variables by appending X, Y and Z. 
This is done using 2 nested lapply commands, which I've documented liberally 
to explain what happens. Note also the use of the <<- scope operator!

###readActivityLabels
This function reads in the activity labels from the file activity_labels.txt.
It returns the activity labels as a data table.

###readData
This function reads the main data set, and returns the complete data set 
including headers, subject and activities (as factors) as a data table.

Inputs:

   - dataType: is either 'test' or 'train'
   - columnHeaders: are the headers for the X_{dataType}.txt data set

Note that we pass in the column headers as an argument, to avoid processing
the column headers twice.

The function does the following:

1. Load the activity labels & convert into factor. The activity labels
    are in an aptly named file "y_{dataType}.txt". 
2. Load the main data set from "X_{dataType}.txt". 
3. Set the column names using the column headers passed as an argument to 
   the function.
4. Merge the tables. We don't need merge() for this at all, because both
   data.frame and data.table support auto merging if you add tables in the
   constructor argument list. We are effectively pasting the subjects and
   activities columns (as data frames/tables) together with the main data
   table.

###main
This is the core part of the analysis, and does the following steps:    
    
1. Download the zip file if not already done so. We store the zip file in
   the data directory and unzip it.
2. Read the column headers first; we want to do this upfront because we need
   the headers for both the train and the test data sets.
3. Read the train and the test data sets.
4. Merge the two data sets.
5. Remove the columns that we don't want; keeping only the mean and standard 
   deviation for the following columns in the **original** data set:
   
    * tBodyAcc-XYZ
    * tGravityAcc-XYZ
    * tBodyAccJerk-XYZ
    * tBodyGyro-XYZ
    * tBodyGyroJerk-XYZ
    * tBodyAccMag
    * tGravityAccMag
    * tBodyAccJerkMag
    * tBodyGyroMag
    * tBodyGyroJerkMag
    * fBodyAcc-XYZ
    * fBodyAccJerk-XYZ
    * fBodyGyro-XYZ
    * fBodyAccMag
    * fBodyAccJerkMag
    * fBodyGyroMag
    * fBodyGyroJerkMag
   
   There are 8 variables with 3 axis values, and 9 variables with magnitudes, 
   for which we want mean and standard deviation, so in total (8 * 3 + 9) * 2 or
   66 distinct variables. 
   
   We prepare the required columns from the list of all column headers 
   using a grep statement. The selection is done using standard data.table
   syntax when column indices are given. This requires the use of with=FALSE.
   
6. Compute the tidy data set, in the long format. The requested data is the 
   mean of each column, grouped by subject and activity. We do this using the 
   plyr package. 
   
7. Write the tidy data set to a text file in csv format. The file name is 
   "tidydata.txt"

Note that the run_analysis.R file calls main directly when the file is sourced.
