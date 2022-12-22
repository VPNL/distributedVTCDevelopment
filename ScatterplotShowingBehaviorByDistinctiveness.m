% This script creates a scatter plot showing behavioral performance
% (reading, face recognition) by category distinctiveness (for words or
% faces, respectively)
close all

%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';
% Enter file Name:
% (1)
% 'tableBrainBehave_Words_lh_vtc_lateral_selective_8categories_union_wrmt3_pseudo'
% or
% (2) tableBrainBehave_AdultFaces_rh_vtc_lateral_selective_8categories_union_CFMT_Adults
fileName = 'tableBrainBehave_Words_lh_vtc_lateral_selective_8categories_union_wrmt3_pseudo';

% Load tbl
load([dataDir fileName])

% extract relevant variables from filename
test = char(extractAfter(fileName, 'union_'));
hemiStr = extractBefore(fileName, '_vtc');
category = char(extractBetween(hemiStr, '_', '_'));
hemi = extractAfter(hemiStr, [category '_']);

%% Run Linear mixed model
% Random slopes model
lme = fitlme(tblnoID, 'matchedBehavioralData ~ distinctiveness + (distinctiveness| subj)')

figure(1)  
set(gcf, 'Position', [0 0 600 500]);

% Create CI for slope matching those produced in R
tblnew = table();
tblnew.distinctiveness=linspace(min(tblnoID.distinctiveness),max(tblnoID.distinctiveness))';
tblnew.subj = repmat({'a'},100,1);
[ypred, yCI, DF] = predict(lme, tblnew);
yfit_meanline = polyval([lme.Coefficients.Estimate(2) lme.Coefficients.Estimate(1)], [min(tblnoID.distinctiveness),max(tblnoID.distinctiveness)] );  
eb = errorbar3(tblnew.distinctiveness', ypred', [yCI(:,1)'; yCI(:,2)'] , 1, [0.8 0.8 0.8]);
hold on
% finally plot overall regression line
r2=line(tblnew.distinctiveness, ypred, 'Color', [0.5 0.5 0.5])
r2.LineWidth=5;
hold on



%  plot individual data on top
allsubj = unique(tblnoID.subj);
colors1 = cbrewer('qual', 'Set3', 12); colors3 = cbrewer('qual', 'Set1', 9); colors2 = cbrewer('qual', 'Dark2', 8);
colors = [colors1; colors2; colors3];


% also plot individual lines on top
[re, names] = randomEffects(lme);

% Find values for each subject and plot in one color
for sd = 1:length(allsubj)
    sub = allsubj{sd};

    colIndexBehave = find(strcmp(tblnoID.Properties.VariableNames, 'matchedBehavioralData'), 1);

    behaveVals = tblnoID{strcmp(tblnoID.subj,sub), colIndexBehave};
    colIndexDistinctivenessData = find(strcmp(tblnoID.Properties.VariableNames, 'distinctiveness'), 1);
    distinctivenessVals = tblnoID{strcmp(tblnoID.subj,sub), colIndexDistinctivenessData};

    sc= scatter( distinctivenessVals, behaveVals, 60,  'filled', 'MarkerFaceColor', colors(sd,:), 'MarkerEdgeColor', colors(sd, :), 'MarkerFaceAlpha', 0.5);  
       
    hold on
    
     % random intercept value´, find for given subj
    indxSubValues = find(strcmp(names.Level, sub));
    RE_Int = re(indxSubValues(1));
    

    RE_Slope = re(indxSubValues(2));
    % plot individual lines
    y = polyval( [( lme.Coefficients.Estimate(2) + RE_Slope), ( lme.Coefficients.Estimate(1) + RE_Int)], [min(distinctivenessVals) max(distinctivenessVals)]);
    pl= plot([min(distinctivenessVals) max(distinctivenessVals)],y);
    pl.Color = colors(sd,:);
    pl.LineWidth = 2;


    clearvars sub RE_Int RE_slope
    clearvars behaveVals categorysVals sub
end





%% format plot
box off
set(gcf, 'Color', 'w')

xlim([0.2 1.3]); 
xlabel('distinctiveness (diff in r)'); 
set(gca, 'XTick', [ -0.2 0 0.2 0.4 0.6 0.8 1 1.2])
set(gca,'XTicklabel', {'-0.2', '0', '0.2', '0.4', '0.6', '0.8','1', '1.2'},'FontSize',18 )

if contains(test, 'wrmt3')
    ylabel('reading score (%)'); ylim([0 102])
elseif contains(test, 'CF')
    ylabel('Cambridge Face Test score (%)'); ylim([0 102])
end
set(gca, 'YTick', [ 0 20 40 60 80 100])
set(gca,'YTicklabel', [0 20 40 60 80 100 ],'FontSize',18 )


title(sprintf('%s %s - %s', hemi, test, category), 'Interpreter', 'none')
set(gcf, 'color', 'w')

%% save plot
figureName = sprintf('ScatterPlot_BehaviorByDistinctiveness_%s_%s_%s', category, hemi, test);
 print(fullfile(figuresDir, figureName), '-dpng', '-r200')

