% This script plots the slopes of linear mixed models indicating the change in
% distinctiveness per year


%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';
fileName = 'RSM_zscore_allChildrenNew_vtc_noSubID';

% indicate if you want to plot data for medial or lateral VTC: 
% partition = 'lateral' or partition = 'medial'

partition = 'medial';

%%

% Load RSM data. Struct is organized by ROI & partition (left and right lateral & medial VTC),
% subject and session
load([dataDir fileName])

% Order of categories in RSM. this order is important
categories= {'Numbers', 'Words', 'Limbs', 'Bodies', 'AdultFaces', 'ChildFaces',...
 'Cars', 'StringInstruments', 'Houses', 'Corridors'};

%% Gather data and compute distinctiveness for each session and ROI, Run linear mixed models
rois = {['lh_vtc_' partition], ['rh_vtc_' partition]};
slopeData = [];
lowerCI = [];
upperCI = [];

for c= 1:length(categories)
    category = categories{c};
    for r=1:length(rois)
        roi = rois{r};

        % reorganize Data: matrix of the format categories x categories x sessions
        [RSMdata3D, age, allSessions, subj, tSNR]  = prepareRSMData(RSMnoIDs, roi);
        
        % Compute distinctiveness for this category
        distinctiveness = computeCategoryDistinctiveness(RSMdata3D, categories, category);
        
        % Run a linear mixed model with predictors age and tSNR and
        % distinctiveness as dependent variable, subject is random effect
        % create table first
        tbl = table(distinctiveness, age, allSessions, subj, tSNR);
        
        lme = fitlme(tbl, 'distinctiveness ~ age + tSNR + (1| subj)');
        allCoefficients.(category).(roi).coeffs = lme.Coefficients;
        
        % extract slope and CI of age predictor frmo LMM
        if strcmp(allCoefficients.(category).(roi).coeffs{2,1}, 'age')
            slopeData(c,r) = allCoefficients.(category).(roi).coeffs{2,2};
            lowerCI(c,r) = allCoefficients.(category).(roi).coeffs{2,7};
            upperCI(c,r) = allCoefficients.(category).(roi).coeffs{2,8};
        else
            fprintf('Check order of predictors in LMM')
        end
            
        clearvars RSMdata3D age allSessions subj tSNR distinctiveness lme
    end

end

%% Create barplot showing slopes for age of LMM

figure(1)
set(gcf, 'Position', [0 0 1200 500]);
bp=bar(slopeData, 'FaceColor','flat', 'EdgeColor', 'none');
% color bars for each category and hemisphere
bp(1).CData(1,:) = [121/255 134/255 203/255]; % num
bp(1).CData(2,:) = [133/255 193/255 233/255 ]; % word
bp(1).CData(3,:) = [255/255 235/255 59/255]; % limb
bp(1).CData(4,:) = [ 240/255 178/255 122/255 ]; % [255/255 102/255 0/255]; %bodies
bp(1).CData(5,:) = [236/255 112/255 99/255]; % adult faces
bp(1).CData(6,:) = [146/255 43/255 33/255]; % kid faces
bp(1).CData(7,:) = [153/255 0/255 255/255];
bp(1).CData(8,:) = [255/255 152/255 255/255];
bp(1).CData(9,:) = [156/255 204/255 101/255];
bp(1).CData(10,:) = [0/255 105/255 92/255];

bp(2).CData(1,:) = [121/255 134/255 203/255]; % num
bp(2).CData(2,:) = [133/255 193/255 233/255 ]; % word
bp(2).CData(3,:) = [255/255 235/255 59/255]; % limb
bp(2).CData(4,:) = [ 240/255 178/255 122/255 ]; % [255/255 102/255 0/255]; %bodies
bp(2).CData(5,:) = [236/255 112/255 99/255]; % adult faces
bp(2).CData(6,:) = [146/255 43/255 33/255]; % kid faces
bp(2).CData(7,:) = [153/255 0/255 255/255];
bp(2).CData(8,:) = [255/255 152/255 255/255];
bp(2).CData(9,:) = [156/255 204/255 101/255];
bp(2).CData(10,:) = [0/255 105/255 92/255];
hold on

%% add errorbars for grouped bar ploot
ngroups = length(categories);
nbars = length(rois);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
r = refline([0 0]);
r.Color = [0.2 0.2 0.2];

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    for pos = 1:length(x)
 
        pl1 = plot([x(pos) x(pos)], [lowerCI(pos,i) upperCI(pos,i)], '-' );

        % color errorbars 
        pl1.Color = [0.5 0.5 0.5];     
        pl1.LineWidth = 3;
   
    end

end

%% format plot
box off
set(gcf, 'Color', 'w')
ylabel('Change in distinctiveness (per year)', 'FontSize', 12)
xticklabels(categories)
xtickangle(45)
titlestr = [partition ' VTC'];
title(titlestr)

%% save figure
figureName = ['BarPlot_ChangeInDistinctivenessPerYear_' partition];
 print(fullfile(figuresDir, figureName), '-dpng', '-r200')

