# README EpicToolbox #

This is the repository for the matlab code for data processing all the code should try 
to use this functions.

The concept is:

A trial is the base data object consisting of a matlab structure that contains tables with 1st column as timestamp (Header).

we call topics to the fields in the structure that define different time series signals from an experiment.

Use different functions in +Topics package to manipulate the information in a trial by doing different
operations to specific topics. These functions make the base of the code and all extra functionality should rely on this package.

In the other folders create functions to execute trial manipulation that is typical for the pipelines
and are not as generic as the ones provided by +Topics.

### What is this repository for? ###

* Quick summary
* Version 0.1

### How do I get set up? ###

* Requires:

* Matlab

* rosgenmsg


## How to commit ##
```bash
#Set up new workspace (folder)
mkdir folderName

git clone https://USERNAME@bitbucket.org/epiclab/gui.git
#Everytime you want to edit anything
git pull origin master
#*edit any file*
git add *
git commit -m "MESSAGE"
git pull origin master
git push origin master

```

### Contribution guidelines ###
* Please readme the TODO.txt and contribute

### Who do I talk to? ###

* Krishan Bhakta <kbhakta3@gatech.edu>
* Jonathan Camargo <jon-cama@gatech.edu>

### How this work?
The main data object is a trialdata which corresponds to a matlab structure
containing all the topics that represent trial information.

e.g. trialdata.Ankle.JointState contains a table with Header and data columns
Header corresponds to time.

All the functions take a trialdata as input and produce either trialdata or other
information as output.
 
For more advance functionality some functions also support receiving a cell array
of multiple trialdata.

Please check examples to learn more.
