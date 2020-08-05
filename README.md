# README EpicToolbox #

EpicToolbox is a Matlab toolbox for data processing of time series data. This can be used in different applications that require
manipulation of trial data that consist of time-series signals from multiple sources. e.g. processing rosbag files, motion capture and
wearable sensors.

The main concept is:
A trial is the base data object consisting of a matlab structure that contains tables with 1st column as timestamp (Header).
we call topics to the fields in the structure that define different time series signals from an experiment.

Use different functions in +Topics package to manipulate the information in a trial by doing different
operations to specific topics. These functions make the base of the code and all extra functionality should rely on this package.

### Installation###
* Requires:
* Matlab
* rosgenmsg
Run the install.m script to add the files to your Matlab path

### How this work?
The main data object is a trialdata which corresponds to a matlab structure
containing all the topics that represent trial information. e.g. trialdata. contains a table with Header and data columns Header corresponds to time.

All the functions take a trialdata as input and produce either trialdata or other
information as output. For more advanced functionality some functions also support receiving a cell array
of multiple trialdata.

Please check examples to learn more.
