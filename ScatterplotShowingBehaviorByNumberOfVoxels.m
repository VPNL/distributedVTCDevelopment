% This script creates a scatter plot showing behavioral performance
% (reading, face recognition) by number of selective voxels (for words or
% faces, respectively)
clear all
close all

%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';
% Enter file Name:
% (1) for the number of word-selective voxels in lh lateral VTC and link to
% reading test:
% 'tableBrainBehave_Words_lh_vtc_lateral_selective_8categories_union_wrmt3_pseudo_nrSelectiveVxls'
% or for the number of adult-face selective voxels in rh lateral VTC and
% the link to the CFMT:
% (2)
% 'tableBrainBehave_AdultFaces_rh_vtc_lateral_selective_8categories_union_CFMT_Adults_nrSelectiveVxls'
fileName = 'tableBrainBehave_AdultFaces_rh_vtc_lateral_selective_8categories_union_CFMT_Adults_nrSelectiveVxls';

% Load tbl
load([dataDir fileName])

% extract relevant variables from filename
test = char(extractAfter(fileName, 'union_'));
hemiStr = extractBefore(fileName, '_vtc');
category = char(extractBetween(hemiStr, '_', '_'));
hemi = extractAfter(hemiStr, [category '_']);

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
allsubj = unique(tblnoID.subj);
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

 
xlabel('nr selective Voxels'); 
ylim([0 102])

if contains(test, 'wrmt3')
    ylabel('reading score (%)'); 
     
    xlim([0 3500]);
    set(gca, 'XTick', [ 1000 2000 3000])
    set(gca,'XTicklabel', {'1000', '2000', '3000'},'FontSize',18 )
    
elseif contains(test, 'CF')
    ylabel('Cambridge Face Test score (%)'); 
        
    xlim([0 1500]);
    set(gca, 'XTick', [ 500 1000 1500])
    set(gca,'XTicklabel', {'500', '1000', '1500'},'FontSize',18 )
    
end
set(gca, 'YTick', [ 0 20 40 60 80 100])
set(gca,'YTicklabel', [0 20 40 60 80 100 ],'FontSize',18 )

title(sprintf('%s %s - %s', hemi, test, category), 'Interpreter', 'none')
set(gcf, 'color', 'w')

%% save plot
figureName = sprintf('ScatterPlot_BehaviorBynrSelectiveVoxels_%s_%s_%s', category, hemi, test);
 print(fullfile(figuresDir, figureName), '-dpng', '-r200')

