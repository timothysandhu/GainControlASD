function [result]=Illus_Anal(result,PalaPlot)
%% Inputs - task identifier string, 'C2' or 'A2'
%         - result structure from the respective discrimiation portion
%  Check groups.mat in DATA/DataFiles for grouping info

%% Find the files
files = dir; % get the files
files([files.isdir]) = []; % remove anything irrelevant

%% Set up the Palamedes parameters
searchGrid.alpha = -1:0.01:1;  % initial search grid values for bias (alpha) and slope (beta). Gamma (guess rate), Lambda (lapse rate) fixed.
searchGrid.beta = 10.^[-1:.01:2];
searchGrid.gamma = .02;
searchGrid.lambda = .02;
paramsFree = [1 1 0 0]; % define which parameters are due to be estimated
PF = @PAL_Logistic; % use a logistic function
GofIts = 400; % define number of iterations for goodness of fit

%% Start the analysis loop
for file = 1:length(files)
    % Read in the data
    [Answer,FeatVal,~] = textread(files(file).name,'%n%n%n\n','delimiter',','); % load in the data
    StimLevels=unique(FeatVal)'; % find the 7 unique FeatVal values used in the experiment
    
    % Add to the result structure
    result(file).StimMinMax = [min(StimLevels),max(StimLevels)]; % record the minimum and maximum values of the stimulus level for each file, used later in exclusion
    
    % Get some useful information for the curve fittiing
    for i=1:length(StimLevels)
        NumCorr(i) = sum(Answer(FeatVal==StimLevels(i))); % find the number of correct responses at each stimulus level
        OutOfNum(i) = length(Answer(FeatVal==StimLevels(i))); % find the number of trials at each stimulus level
    end
    ProportionCorrectObserved=NumCorr./OutOfNum; % create a vector of proportion of correct responses
    result(file).RespMinMax = [min(ProportionCorrectObserved),max(ProportionCorrectObserved)];
    
    % Palamedes curve fitting
    [paramsValues,~,~,~] = PAL_PFML_Fit(StimLevels,NumCorr,OutOfNum,searchGrid,paramsFree,PF); % implement Palamedes
    result(file).bias = paramsValues(1); % save the bias for analysis
    result(file).slope = paramsValues(2); % save the slope for some filtering
    
    % Optional plotting
    if PalaPlot == 1
        clf
        StimLevelsFineGrain=min(StimLevels):max(StimLevels)./1000:max(StimLevels); % create some fine grained x axis values
        ProportionCorrectModel = PF(Pala(file).paramsValues,StimLevelsFineGrain); % pass the fine grained info into the PF for fine grained output
        figure('name',strcat('Maximum Likelihood Psychometric Function Fitting_File_',num2str(file))); % Give the title a figure
        axes % create a graphics object
        hold on % overlaying plots so leave hold on
        plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0 0 1],'linewidth',4); % plot the fine grained fit
        plot(StimLevels,ProportionCorrectObserved,'k.','markersize',40); % plot the actual stimulus levels
        set(gca, 'fontsize',16);
        set(gca, 'Xtick',StimLevels); % set the x tick labels as the raw stimulus values
        xlabel('Stimulus Intensity');
        ylabel('proportion correct');
        hold off
    end
    
    % Bootstrap
    [result(file).SE,result(file).paramsSim,~,result(file).converged] = PAL_PFML_BootstrapParametric(...
        StimLevels, OutOfNum, paramsValues, paramsFree, GofIts, PF,'searchGrid', searchGrid);
    result(file).sumConv = sum(result(file).converged==1); % record the number of simulations which converged
    
    % Goodness of fit metrixs
    [result(file).Dev result(file).pDev] = PAL_PFML_GoodnessOfFit(StimLevels, NumCorr, OutOfNum, ...
        paramsValues, paramsFree, GofIts, PF, 'searchGrid', searchGrid);
end
