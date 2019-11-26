function result=Thresh_Anal(task)
% Analyse the data from experiment 1 to determine the discrimination
% thresholds for each participant
% Inputs : task - a string e.g. A1 or C1
% Outputs : result = a structure containing useful information such as
%                 discrimination threshold
 %              : getRid = a vector of file numbers to be removed
 %              (staircasing failed in these participants)

%% Directory
files = dir; % get the files
for i = 1:length(files)
    if contains(files(i).name,task)
keep(i) = 1;
else
keep(i) = 0;
    end
end

files(keep==0) = [];

%% Loop through the files
for i = 1:length(files)
        if contains(files(i).name,task) % if the file contains the task name
        result(i).Name = files(i).name;  % initialize an output structure and save the name of each file to it
        [Answer,FeatVal,~,Reversal] = textread(files(i).name,'%n%n%n%n\n','delimiter',','); % read the CSV, don't store any of the variables yet
        ThresholdTemp=FeatVal(Reversal==1); % select the feature values for which there was a reversal
        result(i).Correct = mean(Answer); % save the percentage of correct responses, this is important for filtering
        result(i).DiscThresh=sum(ThresholdTemp(7:length(ThresholdTemp)))/length(ThresholdTemp(7:length(ThresholdTemp))); % average over the feature value of the last 13 reversals to find the discrimination threshold
        result(i).FeatVal=FeatVal'; % store the feature values shown to each ptp
        
        % Implement a version of the ratio test for the convergence of a
        % series
        tmp = result(i).FeatVal; % create a temporary variable matching the series of feature values
        tmp(end) = []; % when doing the ratio test, we look at the ratio of x-th and x+1-th value, which isn't valid for the last feature value
        tmp = [NaN tmp]; % prepend a number to match the structure
        tmp1 = result(i).FeatVal; % again create a temporary value matching the series of feature values
        % Note that at this point, the xth value of tmp is the x+1th value
        % of tmp
        result(i).Conv = mean(tmp1(length(tmp1)/2:end)./tmp(length(tmp)/2:end)); % now take the last half of each of the two series, looking at the ratio between the offset (tmp1) and normal (tmp) feature values, and look at the average. if this is great than 1 then the series does not converge, and the staircasing has failed
        
        
        % Another problem may be that the threshold is incorrectly
        % determined based on a very steep tail (weird participant
        % behaviour)
        LastThresh = find(result(i).FeatVal>=result(i).DiscThresh,1,'last'); % find the last trial where the feature value was above the calculated threshold
        Check = diff(result(i).FeatVal(LastThresh:end));  % find the difference in feature values between the time found above and the end of the experiment
        result(i).EndProb = 0; % initialize 
        if ~any(Check>0) && length(Check) > 1/7 * length(result(i).FeatVal)
            % if the feature value never goes above the calculated
            % threshold in the last 10 or so trials
            result(i).EndProb = 1; % it is unlikely that the participants have converged at this stage
        end
        end
    if (result(i).Correct<.707 & result(i).Conv>1) | result(i).EndProb==1
        result(i).discExclude = 1;
    end
end

%% Convergence criteria
% Exclude participants who dont reach the desired accuracy AND didn't
% converge (if participants didn't have the desired accuracy but converged,
% their data was deemed acceptable, but just with a very high discrimation
% threshold)
% OR had weird behaviour in the tails (in which case convergence
% won't mean anything, and accuracy is irrelevant)
%getRid = find(result.Correct<.707 & result.Conv>1 | result.EndProb==1); % return the indices where the participant didnt converge on the desired 70.7% 
