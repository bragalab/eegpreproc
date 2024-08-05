# EEGPREPROC

The primary purpose EEGPREPROC directory is to create preprocessed data files for individual iEEG raw datasets, utilizing Quest Computing resources. preprocess_EEG.m will take a raw data folder as an input, launch an interactive program in matlab that utilizing several helper functions, and save preprocessed data a processed data directory. As this is an interactive program, it will require user input, running EEGQC on the dataset first will help with making dthese decisions.

# Requirements

The raw data directory must be organized by .../ProjectID/SubjectID/SessionID/RunID/DateTimeID, which must contain raw dataCSC and NEV files at the DateTimeID level, and a channellabels.txt file at the SessionID level. This text file describes the electrodes for the given patient and session, with the following structure, with one row for each CSC file.

Name Type Dimension1 Dimension2 CSC# JackboxLetter Jackbox Number
A1     D      15           1    CSC1       A              1
A2     D      15           1    CSC2       A              2
.      .       .           .      .        .              .
.      .       .           .      .        .              .
.      .       .           .      .        .              .
.      .       .           .      .        .              .

You will also need to have matlab/r2020b or later and R/4.0.3 installed, as well as the EEGQC toolbox.

# Usage
Within MATLAB, within the eegpreproc toolbox directory:

preprocess_EEG(rawdatapath)

# Troubleshooting

If the directory structure is different then what is listed in requirements, or you are receiving path related errors, then you may need to update code relating to paths within preprocess_EEG.m, and  eegqc/load_dataCSC.m.

Another major source of errors comes from the formatting and electrode naming within channellabels.txt, which will cause load_dataCSC.m to either crash or create a file that causes downstream errors. Check your channellabels.txt file or edit load_dataCSC.m to be able to handle your electrode labeling conventions.

This toolbox is currently only designed to preprocess data with the TaskID: STIM. preprocess_EEG.m still needs to be built out for other datatypes.



