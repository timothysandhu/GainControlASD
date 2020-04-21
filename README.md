# GainControlASD
Contains the MATLAB code for the analysis of the data presented in Sandhu et al, 2019 https://wellcomeopenresearch.org/articles/4-208/v1#ref-42

This repo contains several scripts, which are essentially 4 recursive functions to analyse the data (each of the functions uses the output of the previous, appending more information).
Set your working directory to each of the raw data sub folders.
Note that you will have to change your working directory when going from Thresh_Anal to Illus_Anal, ensuring to keep the result variable in your workspace.
     
     1) result = Thresh_Anal('task') takes in the raw discrimination threshold data and returns an output with the thresholds and some exclusion criteria. Note that task should be a string 'A1' or 'C1'.
     
     2) result = Illus_Anal('task',result,plot) takes in the output from Thresh_Anal and adds further fields to the result structre. Allows for plotting of the psychometric curves. Note that task should be a string 'A2' or 'C2'.
     
     3) result = CleanUp(result) performs further exclusions based on model fitting. Uses the output from Illus_Anal 
     
     4) [output,result] = Demo_Prep(result,demographics,task) takes in the output from CleanUp and adds some demographic information. Additionally, this function prepares the csv's required for analysis in JASP and for the online Estimation plots GUI. 

