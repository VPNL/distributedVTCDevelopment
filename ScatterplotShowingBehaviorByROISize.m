% This script creates a scatter plot showing behavioral performance
% (reading, face recognition) by the ROI size of word and face-selective
% ROIS (lh_pOTS_words or rh_pFus_faces)
clear all
close all

%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';
% Enter file Name:
% (1) for the size of the word-selective ROI in lh lateral VTC and the link to
% reading test:
% 'table_Words_ROIsPlusBehavior'
% or for the size of the face-selective ROI rh lateral VTC and
% the link to the CFMT:
% (2)
% 'table_AdultFaces_ROIsPlusBehavior'
fileName = 'table_AdultFaces_ROIsPlusBehavior';

% Load tbl
load([dataDir fileName])

% extract relevant variables from filename
category = char(extractBetween(fileName, 'table_', '_ROI'));
if strcmp(category, 'Words')
    hemi = 'lh';
elseif strcmp(category, 'AdultFaces')
    hemi = 'rh';
end
tblnoID = tbl_noSubjID;

% remove subjeccts with nan (subj, who never had the ROI)
tblnoID(any(ismissing(tblnoID),2),:) = [];

%% Run Linear mixed model
% Random slopes model
lme = fitlme(tblnoID, 'matchedBehavioralData ~ nrSelectiveVoxels + (nrSelectiveVoxels| subj)')

figure(1)  
set(gcf, 'Position', [0 0 600 500]);

% Create CI for slope matching those produced in R
tblnew = table();
tblnew.nrSelectiveVoxels=linspace(min(tblnoID.nrSelectiveVoxels),max(tblnoID.nrSelectiveVoxels))';
tblnew.subj = repmat({'a'},100,1);
[ypred, yCI, DF] = predict(lme, tblnew);
yfit_meanline = polyval([lme.Coefficients.Estimate(2) lme.Coefficients.Estimate(1)], [min(tblnoID.nrSelectiveVoxels),max(tblnoID.nrSelectiveVoxels)] );  
eb = errorbar3(tblnew.nrSelectiveVoxels', ypred', [yCI(:,1)'; yCI(:,2)'] , 1, [0.8 0.8 0.8]);
hold on
% finally plot overall regression line
r2=line(tblnew.nrSelectiveVoxels, ypred, 'Color', [0.5 0.5 0.5]);
r2.LineWidth=5;
hold on


%  plot individual data on top
allsubj = unique(tblnoID.subj, 'stable');

colors1 = brewermap(11, 'PiYG');  
colors2 = brewermap(11, 'PuOr'); 
colors3 = brewermap(9, 'RdYlBu'); 

colors = [colors1; colors2; colors3];


% also plot individual lines on top
[re, names] = randomEffects(lme);

% Find values for each subject and plot in one color
for sd = 1:length(allsubj)
    sub = allsubj{sd};

    colIndexBehave = find(strcmp(tblnoID.Properties.VariableNames, 'matchedBehavioralData'), 1);

    behaveVals = tblnoID{strcmp(tblnoID.subj,sub), colIndexBehave};
    colIndexnrSelectiveVoxelsData = find(strcmp(tblnoID.Properties.VariableNames, 'nrSelectiveVoxels'), 1);
    nrSelectiveVoxelsVals = tblnoID{strcmp(tblnoID.subj,sub), colIndexnrSelectiveVoxelsData};

    sc= scatter( nrSelectiveVoxelsVals, behaveVals, 60,  'filled', 'MarkerFaceColor', colors(sd,:), 'MarkerEdgeColor', colors(sd, :), 'MarkerFaceAlpha', 0.5);  
       
    hold on
    
     % random intercept value´, find for given subj
    indxSubValues = find(strcmp(names.Level, sub));
    RE_Int = re(indxSubValues(1));
    
    RE_Slope = re(indxSubValues(2));
    
    % plot individual lines
    y = polyval( [( lme.Coefficients.Estimate(2) + RE_Slope), ( lme.Coefficients.Estimate(1) + RE_Int)], [min(nrSelectiveVoxelsVals) max(nrSelectiveVoxelsVals)]);
    pl= plot([min(nrSelectiveVoxelsVals) max(nrSelectiveVoxelsVals)],y);
    pl.Color = colors(sd,:);
    pl.LineWidth = 2;

    clearvars sub RE_Int RE_slope
    clearvars behaveVals categorysVals sub
end


%% format plot
box off
set(gcf, 'Color', 'w')

 
xlabel('ROI size'); 
ylim([0 102])

if contains(category, 'Words')
    ylabel('reading score (%)'); 
     
    xlim([0 1300]);
    set(gca, 'XTick', [ 500 1000 ])
    set(gca,'XTicklabel', {'500','1000' },'FontSize',18 )
    
elseif contains(category, 'Faces')
    ylabel('Cambridge Face Test score (%)'); 
        
    xlim([0 1000]);
    set(gca, 'XTick', [ 200 400 600 800 1000])
    set(gca,'XTicklabel', {'200', '400', '600','800', '1000'},'FontSize',18 )
    
end
set(gca, 'YTick', [ 0 20 40 60 80 100])
set(gca,'YTicklabel', [0 20 40 60 80 100 ],'FontSize',18 )

title(sprintf('%s %s', hemi, category), 'Interpreter', 'none')
set(gcf, 'color', 'w')

%% save plot
figureName = sprintf('ScatterPlot_BehaviorBynrROISize_%s_%s', category, hemi);
 print(fullfile(figuresDir, figureName), '-dpng', '-r200')

