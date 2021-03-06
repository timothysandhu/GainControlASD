function [output,result] = Demo_Prep(result,Demo,task)
% Append the demographic information to the results structure
% Inputs
% result - result structure from previous scripts
% Demo - demographics file from OSF (.mat containing several variables)
% task - string, for labelling
%
% Outputs
% output - output structure with the relevant information MATLAB info
% result - the newly appended result structure

% Loop through the demographic info
for i = 1 : length(result)
    for j = 1 : length(result)
        if contains(result(i).Name,Demo(j).name) % if the names match
            result(i).group = Demo(j).group; % append the info
            result(i).ADOS = Demo(j).ADOS;
            result(i).Age = Demo(j).age;
            result(i).IQ = Demo(j).IQ;
            result(i).AQ = Demo(j).AQ;
        end
    end
    % Make a lot of vectors for later analysis
    ADOS(i) = result(i).ADOS;
    Age(i) = result(i).Age;
    IQ(i) = result(i).IQ;
    AQ(i) = result(i).AQ;
    disc(i) = result(i).DiscThresh;
    bias(i) = result(i).bias; 
    biasGroup(i) = result(i).group; 
    discGroup(i) = biasGroup(i);
    exclude(i) = ~isempty(result(i).exclude); 
    discExclude(i) = ~isempty(result(i).discExclude);
end

%% Do the exclusions - set to zero but only select values of 1 or 2
biasGroup(exclude)=0;
discGroup(discExclude) = 0;

%% Collect the data

% Collect ASC discrimination threshold information
output.ASC.disc = disc(discGroup==1);
output.ASC.dADOS = ADOS(discGroup==1);
output.ASC.dAQ = AQ(discGroup==1);
output.ASC.dAge = Age(discGroup==1);
output.ASC.dIQ = IQ(discGroup==1);

% Collect ASC surround suppression magnitude information
output.ASC.bias = bias(biasGroup==1);
output.ASC.ADOS = ADOS(biasGroup==1);
output.ASC.AQ = AQ(biasGroup==1);
output.ASC.Age = Age(biasGroup==1);
output.ASC.IQ = IQ(biasGroup==1);

% Collect NT discrimination threshold information
output.NT.disc = disc(discGroup==2);
output.NT.dAQ = AQ(discGroup==2);
output.NT.dAge = Age(discGroup==2);
output.NT.dIQ = IQ(discGroup==2);

% Collect NT surround suppression magnitude information
output.NT.bias = bias(biasGroup==2);
output.NT.AQ = AQ(biasGroup==2);
output.NT.Age = Age(biasGroup==2);
output.NT.IQ = IQ(biasGroup==2);

%% Prepare some CSV's for further analysis, for each of disc thresh and bias
% CSVs for estimation plots, formatted as two columns (ASC NT)
T1 = table(output.ASC.disc',[output.NT.disc';NaN(length(output.ASC.disc)-length(output.NT.disc),1)],'VariableNames',{'ASC','NT'}); writetable(T1,strcat('EstPlot_DiscThresh','_',task,'.csv'));
T2 = table(output.ASC.bias',[output.NT.bias';NaN(length(output.ASC.bias)-length(output.NT.bias),1)],'VariableNames',{'ASC','NT'}); writetable(T2,strcat('EstPlot_Bias','_',task,'.csv'));
% CSV for JASP, formatted as two columns, feature and group
T3 = table([output.ASC.bias';output.NT.bias'],[output.ASC.AQ';output.NT.AQ'],[ones(length(output.ASC.bias'),1);2*ones(length(output.NT.bias'),1)],'VariableNames',{'Bias','AQ','Group'}); writetable(T3,strcat('JASP_Bias','_',task,'.csv'))
T4 = table([output.ASC.disc';output.NT.disc'],[ones(length(output.ASC.disc'),1);2*ones(length(output.NT.disc'),1)],'VariableNames',{'Disc','Group'}); writetable(T4,strcat('JASP_DiscThresh','_',task,'.csv'))