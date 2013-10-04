noisecloud
==========

feature database for fMRI ICA components

This package has been developed from original scripts, so please contact 
vsochat@stanford.edu with bug reports.

INSTALLATION**
1. Download base scripts from:

Extract these scripts in a handy dandy location, cd to that location, and add them to your path:
addpath(genpath(pwd))

2. You must have spm installed and added to your path.

PREPROCESSING **

1. Preprocessing your data and ICA are up to you, to be done with your software package of choice.
You will likely want include bandpass filtering your data, and registering all subjects to a standard template.

2. To extract spatial features relevant to different regions of interest and matter types, you will need to 
register the provided templates in the "mr" folder to the standard template that you data is registered to. 
You should add paths to these images under "noisecloud_setup."

3. If you performed ICA with FSL, you can select the .ica directories as your input, and the script will
find the thresholded Z-stat images as well as the corresponding timeseries text files (t*.txt).
If you have not used FSL, you must select these files manually.  An example image and timeseries file are
provided under "example"


FEATURE EXTRACTION**

1. The main function that you want to run is "noisecloud."  You can use it as follows:

[ features_norm, feature_labels, row_labels ] = noisecloud

to return a list of normalized features, corresponding labels (columns), and component IDs (rows). 
You will be asked to select FSL .ica directories, atlas images (that must be coregistered to the same standard 
template as your data), as well as specify the TR.  The subject IDs will be extracted from the folder name.  
Change the script prep/read_fsldirs.m to edit specifics of the paths, etc.


CLASSIFIER**

1. You will need to have a set of labels to distinguish noise/not-noise, or some network of interest/~network of interest.
If you processed your data with FSL, you can use the label networks gui under "prep/label-good-bad-gui" to create
a .mat file with both image labels and names.  If not, use prep/noisecloud_create_labels as a guide to create
this .mat file.



JUST DOWNLOAD FEATURES**

The script noisecloud_download has been provided to just download feature extraction scripts into the temp folder.  For
each spatial feature script (noisecloud_spatial_*.m, the scripts take as input the 3D spatial map.  For each temporal
feature script (noisecloud_temporal_*.m) the scripts take as input the timeseries as a single vector.



CONTRIBUTING **
To create your own file (with some custom of features) you can use this interface: 

ADDING FEATURES: Please submit novel feature scripts to THIS LINK, and be sure to follow THIS STANDARD FORMAT. A template feature script has been provided in this package to give you guidance.


QUESTIONS **
 
vsochat@stanford.edu