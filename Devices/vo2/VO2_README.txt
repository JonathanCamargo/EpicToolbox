This file concerns VO2_Parse.m and VO2_Read.m

VO2_Read.m has one input "Patient_Name" (Self explanatory). It identifies files with the extension '.xlsx' in the current directory (this will be changed later when there is a designated folder for experimental data). It then takes the filename, numerical, text, and raw data and puts them in a structure. The structure is then saved as a .mat file. 

VO2_Parse.m has two inputs, the Patient_Name and Patient_Weight_kg (also self explanatory). It then calls VO2_Read.m and loads in the .mat file. The data is then graphed and saved as a .png file, and general info about the experiment (i.e. the mean metabolic rate for each trial, whether the trial failed or succeeded) is saved in a .txt file in the current folder. 