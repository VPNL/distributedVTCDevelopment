% plotMDSforAgeGroups
% This script plots the MDS embeddings for a given ROI and voxel subset
% (union of selective, non-selective voxels) for 5-9-year olds and 13-17
% year-olds

clear all
close all

%% Set up
dataDir = './data/';
figuresDir = './figures/';
% Enter the name of the respective dataset 
% (1) selective: RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID
% (2) nonSelective: RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID
% (3) all voxels: RSM_zscore_allChildrenNew_vtc_noSubID
fileName = 'RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID';
dataType = char(extractAfter(fileName, 'vtc_'));

if length(dataType)>7
    dataType = extractBefore(dataType, '_');
end
% Enter the name of the ROI you want to plot: roi= 'lh_vtc_lateral' or 'rh_vtc_lateral'
roi= 'lh_vtc_lateral';

%% Load template and data 
% For easier visual comparison across hemispheres and voxel types, all MDS embeddings will be aligned to the MDS embedding of 
% 13-17yo in left lateral VTC

templateFilename = 'RSMzscore_allChildrenNew_vtc_13-17yo_lh_vtc_lateral_emb';

load([dataDir templateFilename ])
embAlign = meanRSM_emb_old;
clearvars meanRSM_emb_old

load([dataDir fileName])

%% Select data for age groups

% reorganize Data: matrix of the format categories x categories x sessions
[RSMdata3D, age, allSessions, subj, tSNR]  = prepareRSMData(RSMnoIDs, roi);

% sort by age
[sortedAge, indxAge]=sort(age, 'ascend');
RSMSortedByAge=RSMdata3D(:,:,indxAge);
subjSortedByAge=subj(indxAge);
allSessionsSortedByAge=allSessions(indxAge);
% select age groups
youngAges=sortedAge<10;
RSMyoungAges=RSMSortedByAge(:,:,youngAges);
subjYoung = subjSortedByAge(youngAges);
allSessionsYoung= allSessionsSortedByAge(youngAges);

olderAges=sortedAge>=13;
RSMolderAges=RSMSortedByAge(:,:,olderAges);
subjOld = subjSortedByAge(olderAges);
allSessionsOld= allSessionsSortedByAge(olderAges);

%% Find all sessions of the same subject and average those, so one datapoint of each subj remains
subjYoungUnique=unique(subjYoung, 'stable');
for y=1:length(subjYoungUnique)
    youngSubjScores = [];

    youngSubSessionIdx=find(strcmp(extractBefore(allSessionsYoung, '_'), subjYoungUnique{y}));
    youngSubjScores = RSMyoungAges(:,:,youngSubSessionIdx);
    RSMYoung(:,:,y) = mean(youngSubjScores,3);
end

    subjOldUnique=unique(subjOld, 'stable');
for o=1:length(subjOldUnique)
    oldSubjScores = [];

    oldSubSessionIdx=find(contains(allSessionsOld, subjOldUnique{o}));
    oldSubjScores = RSMolderAges(:,:,oldSubSessionIdx);
    RSMOld(:,:,o) = mean(oldSubjScores,3);
end

%% MDS embedding
% YOUNG Kids
% create mean of all RSMs across all sessions in the group
meanRSMyoung=mean(RSMYoung,3);

% convert matrix to dissimilarity matrix. pdist returens pairwise distances as vecctor and squareform puts back to matrix format
meanRSM_dist_young = squareform(pdist(meanRSMyoung));

% do classical multidimensional scaling (dimensionality is set to 2 here)
meanRSM_emb_young = cmdscale(meanRSM_dist_young,2);

% TEENS
% create mean of all RSMs across all sessions in the group
meanRSMold=mean(RSMOld,3);

% convert matrix to dissimilarity matrix. pdist returens pairwise distances as vecctor and squareform puts back to matrix format
meanRSM_dist_old = squareform(pdist(meanRSMold));

% do classical multidimensional scaling (dimensionality is set to 2 here)
meanRSM_emb_old = cmdscale(meanRSM_dist_old,2);

%% Align to template (for easier visibility)
% Align all embeddinsg to that of the older kids all voxels in lh lateral VTC
% D = procrustes(X, Y) determines a linear transformation  of the points in the matrix Y to best conform them to the points in the matrix X. 
[residual_stressold, meanRSM_emb_old_aligned] = procrustes(embAlign, meanRSM_emb_old, 'Scaling', 0); 

% Align the embedding of young kids to that embeddinsg to that of the older kids 
[residual_stress, meanRSM_emb_young_aligned] = procrustes(meanRSM_emb_old_aligned, meanRSM_emb_young, 'Scaling', 0); 


%% PLOT MDS embeddings
figure(1);
set(gcf, 'Position', [0 0 800 800]);

% set up colors for categories
myColors = [56 61 150;... %numbers
    133 193 233;... % word
    244 208 63;... % limb
    230 126 34 ;... %  %bodies
    203 67 53;... % adult faces
    100 30 22;... % kid faces
    126 47 142;... %car
    191 0 191;... %guitar
    104 159 56;... %house
    0 77 64]; %corridor

labels = {'number', 'word', 'limb', 'body', 'adultface',...
    'childface', 'car', 'instrument', 'house', 'corridor'}; 

for c=1:length(labels)
    

    %%  Plot circles
    ax=gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    ylim([-1.22 1.22]); xlim([-1.22 1.22])

    sy=scatter(meanRSM_emb_young_aligned(c, 1), meanRSM_emb_young_aligned(c, 2), 300, myColors(c,:)./255, 'filled');

    hold on
    so=scatter(meanRSM_emb_old_aligned(c, 1), meanRSM_emb_old_aligned(c, 2), 600, myColors(c,:)./255, 'filled');
    so.MarkerFaceAlpha=0.6;
    x=[meanRSM_emb_young_aligned(c, 1) meanRSM_emb_old_aligned(c, 1)];
    y=[meanRSM_emb_young_aligned(c, 2) meanRSM_emb_old_aligned(c, 2)];
    pl=line(x,y);
    pl.Color = myColors(c,:)./255;
    pl.LineWidth=2;

    % euclidian distance
    d(c)=pdist([meanRSM_emb_young_aligned(c, 1), meanRSM_emb_young_aligned(c, 2); meanRSM_emb_old_aligned(c, 1), meanRSM_emb_old_aligned(c, 2)], 'euclidean');

    set(gcf, 'color', 'w')
    hold on
    ax=gca;
    ax.YDir='normal';

    % Plot arrows, complicated in matlab
     arrowYoung = [meanRSM_emb_young_aligned(c, 1) meanRSM_emb_young_aligned(c, 2)]; % x, y group 1
     arrowOld   = [meanRSM_emb_old_aligned(c, 1) meanRSM_emb_old_aligned(c, 2)]; % x,y group 2
     dp=arrowOld-arrowYoung;           

    % try quiver function
    q=quiver(arrowYoung(1), arrowYoung(2), dp(1), dp(2), 0, 'LineWidth', 4);
    arrowColor=myColors(c,:)./255;

    % make arrrows a bit darker than other colors
    minVal=min(arrowColor);
    if minVal<0.5
        arrowColor = arrowColor - minVal;
    else
        arrowColor = arrowColor - 0.5;
    end
    q.Color = arrowColor;
    q.MaxHeadSize=4;
       
    
end
% Formmat plot

set(gca, 'xtick', [-1 1])
set(gca, 'ytick', [-1 1])
ax.FontSize = 16;

ylim([-1.22 1.22]); xlim([-1.22 1.22])

box off
myTitle = sprintf('%s 5-9y (n=%d) & 13-17y (n=%d)', roi, length(RSMYoung), length(RSMOld)); 
title(myTitle, 'Interpreter','none', 'FontSize', 16);

set(gcf, 'Position', [0 0 800 800]);

 %% save plot
figureName = sprintf('MDS_YoungKids_Teens_%s_%s', dataType, roi);
print(fullfile(figuresDir, figureName), '-dpng', '-r200')





    