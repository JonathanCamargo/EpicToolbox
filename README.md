# README EpicToolbox #

EpicToolbox is a Matlab toolbox for data processing of time series data. This can be used in different applications that require
manipulation of trial data that consist of time-series signals from multiple sources. e.g. processing rosbag files, motion capture and
wearable sensors.

The main concept is:
A trial is the base data object consisting of a matlab structure that contains tables with 1st column as timestamp (Header).
we call topics to the fields in the structure that define different time series signals from an experiment.

Use different functions in +Topics package to manipulate the information in a trial by doing different
operations to specific topics. These functions make the base of the code and all extra functionality should rely on this package.

### Installation
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

### License

The MIT License (MIT) Copyright (c) 2020 Jonathan Camargo <jon-cama@gatech.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Acknowledgments

Many thanks to Krishan Bhakta, Will Flanagan and Noel Csomay-Shanklin for their contributions to some of the functions in this repository.
