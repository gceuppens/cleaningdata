#
# Constants for use in the script
#
# Path to the unzipped data; we append this to the file names using the 
# file.path() function to get the actual file name.
DATAPATH <- "./UCI HAR Dataset"

# Required packages
require(data.table)

###############################################################################
#
# Download the zip file and unzip if not done already
#
# Returns: (nothing)
#
###############################################################################
downloadData <- function() {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "

    localZipName <- "dataset.zip"
    # Check if the file has already been downloaded
    if (!file.exists(localZipName)) {
        # Note: on Windows you may want to remove method = "curl"!
        # This code has been written on a Mac and not tested on Windows
        download.file(fileUrl, destfile = localZipName, method = "curl")
        
        # Write down meta data of the download
        library(tools)       # md5sum
        metaDataFile <- file.path(paste(basename(localZipName), 
                                        "-metadata.txt", sep = ""))
        sink(metaDataFile)
        print("Download date:")
        print(Sys.time() )
        print("Download URL:")
        print(fileUrl)
        print("Downloaded file Information")
        print(file.info(localZipName))
        print("Downloaded file md5 Checksum")
        print(md5sum(localZipName))
        sink()    
    }
    
    # Unzip the file if not yet done
    if (!file.exists(DATAPATH)) {
        unzip(localZipName, overwrite = FALSE)
    }    
}

###############################################################################
#
# This function reads in the column headers from the features.txt document
# 
# Returns: column headers (cleaned)
#
###############################################################################
readColumnHeaders <- function() {    
    featuresFileName <- file.path(DATAPATH, "features.txt")
    features <- fread(featuresFileName, header = FALSE)
    setnames(features, c("index", "name"))  # set column header
    # We're only interested in the names
    columnNames <- features[,name]

    # Clean up the column names according to the following principles:
    # Names of variables should be
    #   - All lower case when possible
    #   - Descriptive (Diagnosis versus Dx)
    #   - Not duplicated
    #   - Not have underscores or dots or white spaces
    # (See lecture notes on 'Editing Text Variables' last slide)
    # Note that the first requirement coupled with the 4th would result in 
    # unreadable column names and hence both together are clearly non sensical.
    # This was confirmed by TA David Hood here:
    # https://class.coursera.org/getdata-016/forum/thread?thread_id=76
    # I've therefore chosen to use camelCase for the headers.
    
    # We get rid of the '(', ')', ',', and '-' tokens in the names because
    # these are not allowed as column names. For the moment we leave the 
    # underscores to facilitate extraction of columns later on and for
    # readability. 
    # 1: remove all litteral '()'
    columnNames <- gsub("()", "", columnNames, fixed = TRUE)
    # 2: replace all '(', ')', ',', and '-' for now by '_'
    columnNames <- gsub("[(),-]", "_", columnNames)
    # 3: remove trailing _ at the end of the word
    columnNames <- gsub("_$", "", columnNames)
    # 4: Remove multiple BodyBody
    columnNames <- gsub("BodyBody", "Body", columnNames)
    # 5: Replace initial t with time and f with freq
    columnNames <- gsub("^t", "time", columnNames)
    columnNames <- gsub("^f", "freq", columnNames)
    # 6: Make long readable names
    columnNames <- gsub("Acc", "Acceleration", columnNames)
    columnNames <- gsub("Gyro", "Gyroscope", columnNames)
    columnNames <- gsub("Mag", "Magnitude", columnNames)
    # 7: We're only interested in mean and std so camelCase them now
    columnNames <- gsub("mean", "Mean", columnNames)
    columnNames <- gsub("std", "Std", columnNames)
    # 8: Now remove all the _
    columnNames <- gsub("_", "", columnNames)

    # Note that the column names are not unique (see the readme file). Get the
    # list of names that occur multiple times.
    # Create a list of the indices of each unique column name in the overall list
    # of column names. This list will give for each column name, the row numbers 
    # where that name can be found in columnNames. When there are multiple entries 
    # for that unique name, the length of the list will be > 1. 
    tmp <- sapply(unique(columnNames), function(el) which(columnNames == el))
    # This is the list of duplicate names
    duplicateNames <- tmp[sapply(tmp, function(el) length(el) > 1)]
    # We will now add an X, Y and Z to the duplicate names and use that new 
    # name to update the columnNames vector. We do this using 2 nested lapply:
    lapply(seq_along(duplicateNames), 
           function(i) {
               # name is the duplicate variable name
               name <- names(duplicateNames)[[i]]; 
               # indices is the vector of indices where the duplicate entries
               # can be found in columnNames
               indices <- duplicateNames[[i]]; 
               lapply(seq_along(indices), 
                      function(idx) {
                          # idx will go from 1:3 (3 duplicates for each entry
                          # in the list); and indices[idx] will be each of the
                          # indices where the duplicate values are situated 
                          # in columnNames. Note the use of the <<- operator!
                          columnNames[indices[idx]] <<- 
                              # For each idx in 1:3, take one of X,Y,Z and 
                              # append it to the name
                              paste0(name, "_", c("X", "Y", "Z")[idx])
                      } # end of inner function
               ) # end of inner lapply
           } # end of outer function 
    ) # end of outer lapply
    
    # Return the cleaned up column names
    columnNames
}

###############################################################################
#
# Read the activity labels
#
# Returns: data.table with activity labels
#
###############################################################################
readActivityLabels <- function() {
    fileName <- file.path(DATAPATH, "activity_labels.txt")
    # Create data.table from file
    labels <- fread(fileName, header = FALSE)
    setnames(labels, c("index", "name"))  # set column header
    setkey(labels, index) # index is the key of the table
    labels
}

###############################################################################
#
# Read main data set
#
# Input:
#   - dataType: is either 'test' or 'train'
#   - columnHeaders: are the headers of the X_{dataType}.txt data set
# Returns: data.table 
#
###############################################################################
readData <- function(dataType, columnHeaders) {    
    # Load the subjects
    fileName <- file.path(DATAPATH, dataType, 
                          paste0("subject_", dataType, ".txt"))
    subjects <- fread(fileName, header = FALSE)
    setnames(subjects, "subject")

    # Load the activity labels & convert into factor. The activity labels
    # are in an aptly named file y_{dataType}.txt. The guys doing this 
    # experiment must have had a brain freeze when they cooked up these files...
    fileName <- file.path(DATAPATH, dataType, 
                          paste0("y_", dataType, ".txt"))
    activities <- fread(fileName, header = FALSE)
    setnames(activities, "activity")
    labels <- readActivityLabels() # read activity labels from disk
    # Convert activity column to factor - data.table syntax
    activities[, activity := factor(activities$activity, levels = labels$index, 
                                    labels = labels$name, ordered = TRUE)]
    
    # Load the main measurements
    fileName <- file.path(DATAPATH, dataType, 
                          paste0("X_", dataType, ".txt"))
    # I tried to use fread to load the data but then R bombs out every time
    # data <- fread(fileName, header = FALSE)
    # So use read.table instead but cast the result in a data.table
    data <- data.table(read.table(fileName, header = FALSE))
    setnames(data, columnHeaders)
    
    # Merge the tables. We don't need merge() for this at all, because both
    # data.frame and data.table support auto merging if you add tables in the
    # constructor argument list. We are effectively pasting the subjects and
    # activities columns (as data frames/tables) together with the big data
    # table.
    mergedTable <- data.table(subjects, activities, data)
    
    # Return the merged table
    mergedTable
}    
 
###############################################################################
#
# Main processing of the analysis
#
###############################################################################
main <- function() {
    # Download the zip file if not already done so. We will store the zip file in
    # the data directory and unzip it.
    downloadData()
    
    # Read the column headers first; we want to do this upfront because we need
    # the headers for both the train and the test data sets
    columnHeaders <- readColumnHeaders()
    
    # Read the train data set
    trainData <- readData("train", columnHeaders)
    
    # Read the test data set
    testData <- readData("test", columnHeaders)
    
    # Merge the two data sets
    mergedData <- rbind(trainData, testData)
    
    # Remove the columns that we don't want
    # The column should start with either time or freq, followed by any number of
    # tokens (.*?), followed by either Mean (but not when Mean is followed by F 
    # to exclude the MeanFreq ones) or by Std
    desiredColumns <- grep("(^time|^freq)(.*?)(((Mean)([^F]|$))|Std)", 
                           columnHeaders)
    
    # Only take the columns that we need i.e. those with Mean and Std as well as
    # the first 2 columns giving subject and activity. Note we need to add 2 to 
    # the grep result because we've added 2 columns in the beginning.
    mergedData <- mergedData[, c(1:2, desiredColumns + 2), with = FALSE]
    
    # Set the key for quick processing. Primary is subject, secondary is activity.
    setkey(mergedData, subject, activity)
    
    # Compute the tidy data set, in the long format. The requested data is the 
    # mean of each column, grouped by subject and activity
    require(plyr)
    tidyData <- ddply(mergedData, .(subject, activity), colwise(mean))
    
    # Write out to text file in csv format to avoid the Windows Notepad misery
    write.table(tidyData, file = "tidydata.txt", row.name = FALSE, sep = ",")
}

###############################################################################
#
# Run the main script
#
###############################################################################
main()

