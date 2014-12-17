Code book for the tidied Samsung data set
=========================================

### Experimental design
The experiments have been carried out with a group of 30 volunteers within an 
age bracket of 19-48 years. Each person performed six activities (WALKING, 
WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a 
smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer 
and gyroscope, we captured 3-axial linear acceleration and 3-axial angular 
velocity at a constant rate of 50Hz. The experiments have been video-recorded 
to label the data manually. The obtained dataset has been randomly partitioned 
into two sets, where 70% of the volunteers was selected for generating the 
training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying
noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 
50% overlap (128 readings/window). The sensor acceleration signal, which has 
gravitational and body motion components, was separated using a Butterworth 
low-pass filter into body acceleration and gravity. The gravitational force 
is assumed to have only low frequency components, therefore a filter with 
0.3 Hz cutoff frequency was used. From each window, a vector of features was 
obtained by calculating variables from the time and frequency domain.

### Raw data
To produce the tidy data set, we've started from the processed data sets 
available from here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.

The raw data help files talk about features. A feature is a processed 
measurement. 

The relevant data files are:

1. 'features.txt': List of all features that were recorded in the 
                   X_{train|test}.txt data set.
2. 'activity_labels.txt': Links the activity labels with their activity name.
3. 'train/X_train.txt': Training set with measurements. Each column represents one 
   feature.
4. 'train/y_train.txt': Training activity labels. 
5. 'train/subject_train.txt': Each row identifies the subject who performed the 
   activity for each window sample. Its range is from 1 to 30. 
6. 'test/X_test.txt': Test set with measurements. Each column represents one 
   feature.
7. 'test/y_test.txt': Test activity labels.
8. 'test/subject_text.txt': Each row identifies the subject who performed the 
   activity for each window sample. Its range is from 1 to 30.

Note that files 4 & 5 contain the same number of rows as file 3; and that files
7 & 8 contain the same number of rows as file 6. The labels in file 1 
correspond to the columns of files 3 and 6.

### Processed data
We've done the following processing on the data:

1. Cleanup of the column names (features.txt):
   * The column names were not unique; the variable with bandsEnergy in 
     the name were named identically instead of having one version for each 
     X, Y and Z axis
   * We changed the column labels to camelCase, and removed illegal characters
     like '-' and '(' or ')'
   * For readability, we wrote out the parts in the variable names in full: 
     time for t, freq for f, Magnitude for Mag, Accelerometer for Acc, 
     and Gyroscope for Gyr.
   * We removed all columns except those containing the mean or the standard 
     deviation.
2. Added the subject and the activity (converted to a factor variable)
   to the measurement data.
3. Merged the test and train data sets   
4. Summarised the data by computing the mean of each measurement grouped by
   subject and activity.

The resulting tidy set hence only contains the summary data grouped per subject
and activity.

### Field names

All the features are normalised values hence have no unit anymore.

The field names in the tidy data set can be categorised in the following groups:

   * time: time domain signals;
   * freq: frequency domain signals, obtained by passing the time domain data
           through a Fast Fourier Transform (FFT);

We describe the time domain variables in more details below, and group the 
frequency domain variables together rather than repeating the same explanation.

**subject**

Subject id from 1 to 30

   * subject

**activity**

Factor with 6 values: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, 
STANDING, LAYING

   * activity

**BodyAcceleration**

The time domain acceleration data was split into body and gravity acceleration 
signals; this is the body accelaration part. The measurements are made along 3 
axis, hence X, Y and Z components. For each measurement, the raw data contained 
the mean (Mean) and standard deviation (Std), which in the tidy data set are
averaged by subject and activity. 

   * timeBodyAccelerationMeanX
   * timeBodyAccelerationMeanY
   * timeBodyAccelerationMeanZ
   * timeBodyAccelerationStdX
   * timeBodyAccelerationStdY
   * timeBodyAccelerationStdZ
   
**GravityAcceleration**

The time domain acceleration data was split into body and gravity acceleration 
signals; this is the gravity accelaration part. The measurements are made along 3 
axis, hence X, Y and Z components. For each measurement, the raw data contained 
the mean (Mean) and standard deviation (Std), which in the tidy data set are
averaged by subject and activity. 
   
   * timeGravityAccelerationMeanX
   * timeGravityAccelerationMeanY
   * timeGravityAccelerationMeanZ
   * timeGravityAccelerationStdX
   * timeGravityAccelerationStdY
   * timeGravityAccelerationStdZ
   
**BodyAccelerationJerk**

Jerk movements are involuntary body movements. The next set of variables are 
measured using the body linear acceleration in the time domain. 
Again, we have measurements along the X, Y and Z axis. 
For each measurement, the raw data contained the mean (Mean) and standard 
deviation (Std), which in the tidy data set are averaged by subject and 
activity.

   * timeBodyAccelerationJerkMeanX
   * timeBodyAccelerationJerkMeanY
   * timeBodyAccelerationJerkMeanZ
   * timeBodyAccelerationJerkStdX
   * timeBodyAccelerationJerkStdY
   * timeBodyAccelerationJerkStdZ
   
**BodyGyroscope**

This section contains the time domain gyroscope data. The measurements are made 
along 3 axis, hence X, Y and Z components. For each measurement, the raw data 
contained the mean (Mean) and standard deviation (Std), which in the tidy data 
set are averaged by subject and activity. 

   * timeBodyGyroscopeMeanX
   * timeBodyGyroscopeMeanY
   * timeBodyGyroscopeMeanZ
   * timeBodyGyroscopeStdX
   * timeBodyGyroscopeStdY
   * timeBodyGyroscopeStdZ
   
**BodyGyroscopeJerk**   

Jerk movements are involuntary body movements. The next set of variables are 
measured using the angular velocity in the time domain. 
Again, we have measurements along the X, Y and Z axis. 
For each measurement, the raw data contained the mean (Mean) and standard 
deviation (Std), which in the tidy data set are averaged by subject and 
activity.

   * timeBodyGyroscopeJerkMeanX
   * timeBodyGyroscopeJerkMeanY
   * timeBodyGyroscopeJerkMeanZ
   * timeBodyGyroscopeJerkStdX
   * timeBodyGyroscopeJerkStdY
   * timeBodyGyroscopeJerkStdZ
   
**Magnitude**

The next set of variables contain the magnitude of the 3 three-dimensional 
signals calculated using the Euclidean norm. Please see the description above
for more details. For example, the timeBodyAccelerationJerkMagnitudeMean column
gives the mean magnitude computed by subject and by activity for the time domain
measurement of the jerk movement computed from the body part of the 
accelerometer signal.

   * timeBodyAccelerationMagnitudeMean
   * timeBodyAccelerationMagnitudeStd
   * timeGravityAccelerationMagnitudeMean
   * timeGravityAccelerationMagnitudeStd
   * timeBodyAccelerationJerkMagnitudeMean
   * timeBodyAccelerationJerkMagnitudeStd
   * timeBodyGyroscopeMagnitudeMean
   * timeBodyGyroscopeMagnitudeStd
   * timeBodyGyroscopeJerkMagnitudeMean
   * timeBodyGyroscopeJerkMagnitudeStd
   
**freq**

The next set of column headers are the frequency domain signals, obtained by 
passing the time domain data described above through a Fast Fourier Transform 
(FFT). For a more detailed description of each of the variables, see the 
corresponding section above. 

   * freqBodyAccelerationMeanX
   * freqBodyAccelerationMeanY
   * freqBodyAccelerationMeanZ
   * freqBodyAccelerationStdX
   * freqBodyAccelerationStdY
   * freqBodyAccelerationStdZ
   * freqBodyAccelerationJerkMeanX
   * freqBodyAccelerationJerkMeanY
   * freqBodyAccelerationJerkMeanZ
   * freqBodyAccelerationJerkStdX
   * freqBodyAccelerationJerkStdY
   * freqBodyAccelerationJerkStdZ
   * freqBodyGyroscopeMeanX
   * freqBodyGyroscopeMeanY
   * freqBodyGyroscopeMeanZ
   * freqBodyGyroscopeStdX
   * freqBodyGyroscopeStdY
   * freqBodyGyroscopeStdZ
   * freqBodyAccelerationMagnitudeMean
   * freqBodyAccelerationMagnitudeStd
   * freqBodyAccelerationJerkMagnitudeMean
   * freqBodyAccelerationJerkMagnitudeStd
   * freqBodyGyroscopeMagnitudeMean
   * freqBodyGyroscopeMagnitudeStd
   * freqBodyGyroscopeJerkMagnitudeMean
   * freqBodyGyroscopeJerkMagnitudeStd
