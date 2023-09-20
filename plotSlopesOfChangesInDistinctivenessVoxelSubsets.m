% This script plots the slopes of linear mixed models indicating the change in
% distinctiveness per year in different subsets of voxels including
% 1) the union of the selective voxels
% 2) the non-selective voxels

%%
clear all; close all;
% indicate if you want to plot data for medial or lateral VTC: 
% partition = 'lateral' or partition = 'medial'
partition = 'lateral';


%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';
% To reproduce the plot in Figure 2 use:
fileNames = {'RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID', ...
    'RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID'};

% Alternatively, to reproduce the plot of the control analysis in Supplementary Fig 2 use: 

%  fileNames = {'RSM_zscore_29children_vtc_selective_8categories_union_t3_var_matched_noSubID', ...
%      'RSM_zscore_29children_vtc_nonSelective_8categories_union_t3_var_matched_noSubID'};

% Order of categories in RSM. 
categories= {'Numbers', 'Words', 'Limbs', 'Bodies', 'AdultFaces', 'ChildFaces',...
 'Cars', 'StringInstruments', 'Houses', 'Corridors'};

%% Gather data and compute distinctiveness for each session and ROI, Run linear mixed models
rois = {['lh_vtc_' partition], ['rh_vtc_' partition]};
slopeData = [];
lowerCI = [];
upperCI = [];

for c= 1:length(categories)
    category = categories{c};
    
    for f=1:length(fileNames)
        fileName = char(fileNames{f});
        voxelSubset = char(extractBetween(fileName, 'vtc_' , '_8categories'));
        % Load RSM data. Struct is organized by ROI (left and right lateral VTC),
        % subject and session
        load([dataDir fileName])
      
        
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
            allCoefficients.(category).(voxelSubset).(roi).coeffs = lme.Coefficients;

            % Also extract the relative number of voxels for each voxel subset
            subjUnique = fieldnames(RSMnoIDs.(roi));
            proportion = [];
            for s=1:length(subjUnique)
                sessions = fieldnames(RSMnoIDs.(roi).(subjUnique{s}));
                for e=1:length(sessions)
                    % get nr of included voxels  (union of selective across al categories, non-selective)
                    % relative to overall size of ROI. 
                   proportion(end+1,1)= RSMnoIDs.(roi).(subjUnique{s}).(sessions{e}).included/...
                        RSMnoIDs.(roi).(subjUnique{s}).(sessions{e}).overallNr;
                    
                end
                clearvars sessions
            end
        
            voxelsIncl.(roi).(voxelSubset) = proportion;
            

            clearvars RSMdata3D age allSessions subj tSNR distinctiveness lme tbl proportion
        end
               
        clearvars fileName
    end

end

%% Create barplot showing slopes for age of LMM

figure(1)
allSlopes = [];
allCILower = [];
allCIUpper = [];
% reformat data for grouped bar plot 
for g=1:length(categories)
allSlopesCategory = [allCoefficients.(categories{g}).('selective').(['lh_vtc_' partition]).coeffs{2,2} allCoefficients.(categories{g}).('selective').(['rh_vtc_' partition]).coeffs{2,2} ...
    allCoefficients.(categories{g}).('nonSelective').(['lh_vtc_' partition]).coeffs{2,2} allCoefficients.(categories{g}).('nonSelective').(['rh_vtc_' partition]).coeffs{2,2}];

allSlopes = [allSlopes; allSlopesCategory];

allCILowerCategory = [allCoefficients.(categories{g}).('selective').(['lh_vtc_' partition]).coeffs{2,7} allCoefficients.(categories{g}).('selective').(['rh_vtc_' partition ]).coeffs{2,7} ...
    allCoefficients.(categories{g}).('nonSelective').(['lh_vtc_' partition]).coeffs{2,7} allCoefficients.(categories{g}).('nonSelective').(['rh_vtc_' partition]).coeffs{2,7}];

allCILower = [allCILower; allCILowerCategory];

allCIUpperCategory = [allCoefficients.(categories{g}).('selective').(['lh_vtc_' partition]).coeffs{2,8} allCoefficients.(categories{g}).('selective').(['rh_vtc_' partition]).coeffs{2,8} ...
    allCoefficients.(categories{g}).('nonSelective').(['lh_vtc_' partition]).coeffs{2,8} allCoefficients.(categories{g}).('nonSelective').(['rh_vtc_' partition]).coeffs{2,8}];

allCIUpper = [allCIUpper; allCIUpperCategory];

end


set(gcf, 'Position', [0 0 1200 500]);
bp=bar(allSlopes, 'FaceColor','flat', 'EdgeColor', 'none', 'BarWidth', 1);
hold on
%% add errorbars for grouped bar ploot
ngroups = length(categories);
nbars = 4;

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
r = refline([0 0]);
r.Color = [0.2 0.2 0.2];

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    for pos = 1:length(x)
 
        pl1 = plot([x(pos) x(pos)], [allCILower(pos,i) allCIUpper(pos,i)], '-' );

        % color errorbars 
        pl1.Color = [0.3 0.3 0.3];     
        pl1.LineWidth = 2;
   
    end
end

%% format figure
box off
% color bars
bp(1).CData = [153/255 0 76/255]; 
bp(2).CData = [204/255 0/255 102/255]; 
bp(3).CData = [0.5 0.5 0.5];
bp(4).CData = [0.8 0.8 0.8]; 

set(gcf, 'Color', 'w')

ylabel('Change in distinctiveness per year')
ylim([-0.05 0.06])
xlabel('categories', 'FontSize', 10)
xticklabels(categories); xtickangle(90)

titlestr = [partition ' VTC'];
title(titlestr)

legendStr={};

for n=1:length(fileNames)
    for r=1:length(rois)
        roi=rois{r};
        voxelSet = char(extractBetween(fileNames{n}, 'vtc_' , '_8categories'));
        
        
        legendStr{r+n*(n-1)} = sprintf('%s %s (%.0f%%, ± %.0f)', roi(1:2), voxelSet ,...
            (mean( voxelsIncl.(roi).(voxelSet))*100),...
        (std( voxelsIncl.(roi).(voxelSet))*100) );
    end
end

% format legend
lg=legend(legendStr);
lg.Box= 'off';
lg.Location = 'southeast';
lg.FontSize=10;


%% save figure
figureName = ['BarPlot_ChangeInDistinctivenessPerYear_voxelSubsets_' partition];
 print(fullfile(figuresDir, figureName), '-dpng', '-r200')

