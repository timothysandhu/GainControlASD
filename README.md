# GainControlASD
Contains the MATLAB code for the analysis of the data presented in Sandhu et al, 2019 (doi:)

This repo contains several folders: 

Data : raw data csv files split by task (C = orientation, A = luminance, 1 = discrimination threshold, 2 = surround suppression)

Demographics : an Excel spreadsheet and a .mat file with anonymous demographic information

Code : 4 recursive functions to analyse the data (each of the functions uses the output of the previous, appending more information)
     1) result = Thresh_Anal('task') takes in the raw discrimination threshold data and returns an output with the thresholds and some exclusion criteria. Note that task should be a string 'A1' or 'C1'.
     2) result = Illus_Anal('task',result,plot) takes in the output from Thresh_Anal and adds further fields to the result structre. Allows for plotting of the psychometric curves. Note that task should be a string 'A2' or 'C2'.
     3) result = CleanUp(result) performs further exclusions based on model fitting. Uses the output from Illus_Anal 
     4) [output,result] = Demo_Prep(result,demographics,task) takes in the output from CleanUp and adds some demographic information. Additionally, this function prepares the csv's required for analysis in JASP and for the online Estimation plots GUI. 
