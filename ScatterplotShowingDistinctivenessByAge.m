% This script creates a scatter plot showing category
% distinctiveness by age

clear all
close all
%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';
fileName = 'RSM_zscore_allChildrenNew_vtc_noSubID';

% Load RSM data. Struct is organized by ROI (left and right lateral VTC),
% subject and session
load([dataDir fileName])

% Indicate the category (for instance, category = 'Words', can be  'Numbers', 'Words', 'Limbs', 'Bodies', 'AdultFaces', 'ChildFaces',...
% 'Cars', 'StringInstruments', 'Houses', 'Corridors')
category = 'ChildFaces';

% Indicate the roi (roi = 'lh_vtc_lateral' or roi = 'rh_vtc_lateral')
roi = 'rh_vtc_lateral';


%% Gather data and compute distinctiveness for each session and ROI, Run linear mixed models

% Order of categories in RSM. this order is important
categories= {'Numbers', 'Words', 'Limbs', 'Bodies', 'AdultFaces', 'ChildFaces',...
 'Cars', 'StringInstruments', 'Houses', 'Corridors'};


% reorganize Data: matrix of the format categories x categories x sessions
[RSMdata3D, age, allSessions, subj, tSNR]  = prepareRSMData(RSMnoIDs, roi);

% Compute distinctiveness for this category
distinctiveness = computeCategoryDistinctiveness(RSMdata3D, categories, category);

% Run a linear mixed model with  age as predictor &
% distinctiveness as dependent variable, subject is random effect
tbl = table(distinctiveness, age, allSessions, subj);

lme = fitlme(tbl, 'distinctiveness ~ age + (1| subj)');

%% Create figure


figure(1)  
set(gcf, 'Position', [0 0 600 500]);

% Create CI for slope matching those produced in R
tblnew = table();
tblnew.age=linspace(min(tbl.age),max(tbl.age))';
tblnew.subj = repmat({'a'},100,1);
[ypred, yCI, DF] = predict(lme, tblnew);
yfit_meanline = polyval([lme.Coefficients.Estimate(2) lme.Coefficients.Estimate(1)], [min(tbl.age),max(tbl.age)] );  
eb = errorbar3(tblnew.age', ypred', [yCI(:,1)'; yCI(:,2)'] , 1, [0.8 0.8 0.8]);
hold on



%  plot individual data on top
allsubj = unique(tbl.subj);
colors1 = brewermap(11, 'PiYG');  
colors2 = brewermap(11, 'PuOr'); 
colors3 = brewermap(9, 'RdYlBu'); 
% colors1 = cbrewer(qual', 'Set3', 12);    
% colors3 = cbrewer('qual', 'Set1', 9);   
% colors2 = cbrewer('qual', 'Dark2', 8);
colors = [colors1; colors3; colors2];

% Find values for each subject and plot in one color
for sd = 1:length(allsubj)
    sub = allsubj{sd};

    colIndexage = find(strcmp(tbl.Properties.VariableNames, 'age'), 1);

    ageVals = tbl{strcmp(tbl.subj,sub), colIndexage};
    colIndexDistinctivenessData = find(strcmp(tbl.Properties.VariableNames, 'distinctiveness'), 1);
    categoryVals = tbl{strcmp(tbl.subj,sub), colIndexDistinctivenessData};

    plot(ageVals, categoryVals,  'o', 'MarkerFaceColor', colors(sd,:), 'MarkerEdgeColor', colors(sd, :),...
        'MarkerSize', 9)
    hold on
    clearvars ageVals categorysVals sub
end

% finally plot overall regression line
line(tblnew.age, ypred, 'Color', [0.5 0.5 0.5])
r1 = refline(lme.Coefficients.Estimate(2), lme.Coefficients.Estimate(1));
r1.Color = [0.5 0.5 0.5];
r1.LineWidth = 4;

%ylim([-0.5 1.2])
ylim([-0.3 1.2])
ylabel({'distinctiveness (on-off diag)'})

% title
title(sprintf('%s %s', category, roi), 'Interpreter', 'none')
refline([0 0])

xlim([5 18])
xlabel({'age (years)'})
set(gca,'XTick', [5 9 13 17]) 
set(gca,'XTicklabel', [5 9 13 17],'FontSize',18 )


%% format plot
box off
set(gcf, 'Color', 'w')

%% save figure
figureName = sprintf('ScatterPlot_DistinctivenessByAge_%s_%s', category, roi);
 print(fullfile(figuresDir, figureName), '-dpng', '-r200')

