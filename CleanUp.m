function [illus_result] = CleanUp(illus_result)
%% Data clean up

%% Define some parameters
BootTol = .95; % if less than 95% of the bootstrapped results converged, we want to exclude
NBoot = 400; % we used 400 simulations for the bootstrapping
slopes = [illus_result.slope];

% For each file
for i = 1:length(illus_result)
    % First, exclude based on discrimation threshold
    if illus_result(i).discExclude == 1
        illus_result(i).exclude = 1;
    end
    
    % Look at the max and min percentage correct
    if illus_result(i).RespMinMax(1)>0.5 % if they are getting more than half of responses right at the hardest level
        illus_result(i).exclude = 1;
    end
    
    if illus_result(i).RespMinMax(2)<0.5 % if they are getting less than 50% of the easiest level right
        illus_result(i).exclude = 1;
    end
    
    % If the slope estimate is very high, the fits become more
    % problematic (only ~90% of the fits are succesful, slips below 95% criterion),
    % put back in those more than 2sd above the mean slope
    reinclude = find(slopes < (mean(slopes)-2*std(slopes)) | slopes > (mean(slopes)+2*std(slopes)));
    
    % Recalculate the bootstrap parameters without the failed fits
    illus_result(i).cleanSE = illus_result(i).SE(1); % Replicate the SE field from Palamedes (actually relates to the standard deviation of the simulated bias)
    illus_result(i).Bias = illus_result(i).paramsSim(illus_result(i).converged==1,1); % Get the simulated
    if illus_result(i).sumConv/NBoot > BootTol || sum(logical(ismember(reinclude,i)))% if more than 95% of the bootstrapping was successful and we aren't reincluding it
        ss{i} = sum((illus_result(i).Bias-mean(illus_result(i).Bias)).^2); % calculate SSE, variance, and SD according to Palamedes scripts
        variance{i} = ss{i}/(length(illus_result(i).Bias)-1);
        sd{i} = sqrt(variance{i});
        illus_result(i).cleanSE = sd{i};
    else
        illus_result(i).exclude = 1; % mark them as excluded
    end
    %% Implement Wright et al 2018 exclusion criteria for standard errors
    if ~isnan(illus_result(i).cleanSE(1))
        % Palamedes gives you the SD of the simulated FeatVal estimates
        illus_result(i).stdErr = illus_result(i).cleanSE(1)/sqrt(NBoot); % calculate a standard error
        illus_result(i).confInt = [illus_result(i).bias-(1.96*illus_result(i).stdErr),illus_result(i).bias+(1.96*illus_result(i).stdErr)]; % calculate a 95% confidence interval with a true SE
        if (illus_result(i).confInt(1) < illus_result(i).StimMinMax(1)) || (illus_result(i).confInt(2) > illus_result(i).StimMinMax(2)) % if the standard error of the cleaned parameter estimate is outside of the range of presented stimuli, exclude
            illus_result(i).exclude = 1;
        end
    end
end