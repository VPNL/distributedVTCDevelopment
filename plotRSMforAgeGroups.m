%% Create mean RSM plots across all sessions of 5-9 year olds and 13-17 yo

clear all; close all


%% Set up
dataDir = './data/';
figuresDir = './figures/';

% Enter the name of the respective dataset. One of:
% (1) selective: RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID
% (2) nonSelective: RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID
% (3) all voxels: RSM_zscore_allChildrenNew_vtc_noSubID
fileName = 'RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID';
dataType = char(extractBetween(fileName, 'zscore_', 'noSubID'));
% Enter the ROI ('lh_vtc_lateral', 'rh_vtc_lateral', 'lh_vtc_medial', or
% 'rh_vtc_medial')
roi ='lh_vtc_lateral';

new_labels = {'N', 'W', 'L', 'B', 'A', 'K', 'C', 'G', 'H', 'P'};


%% Load data 


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



%% plot RSMs
figure(1);

set(gcf, 'Position', [0 0 1320 650]);
subplot(1,2,1)
imagesc(nanmean(RSMYoung,3), [-.7 .7]); 
axis('image');
cmap=mrvColorMaps('coolhot'); 
colormap(cmap);
colorbar; 

% set title
if contains(roi, 'vtc')
    myTitle = sprintf('%s 5-9y (n=%d subjects)', roi, length(RSMYoung)); 
else
    % check if there are nan in the data (if ROI not available)
    checkNan = any(isnan(RSMYoung));
    checkNan = sum(checkNan,2);
    checkNan = reshape(checkNan, length(RSMYoung),1);
    RSMYoungN = length(checkNan(checkNan<10));
    myTitle = sprintf('%s 5-9y (n=%d subjects)', roi, RSMYoungN); 
end

title(myTitle, 'Interpreter','none', 'FontSize', 10);
set(gca,'Xtick', [1:1:10], 'XtickLabel',new_labels, 'FontSize', 12)
set(gca,'Ytick', [1:1:10], 'YtickLabel',new_labels, 'FontSize', 12)

subplot(1,2,2)%% plot teens
imagesc(nanmean(RSMOld,3), [-.7 .7]); 
axis('image');
cmap=mrvColorMaps('coolhot'); 
colormap(cmap);
colorbar; 

% set title
if contains(roi, 'vtc')
  myTitle = sprintf('%s 13-17y (n=%d subjects)', roi, length(RSMOld)); 
else
    checkNanO= any(isnan(RSMOld));
    checkNanO = sum(checkNanO,2);
    chechNanO=reshape(checkNanO, length(RSMOld),1);
    RSMYOldn = length(checkNanO(checkNanO<10));
    myTitle = sprintf('%s 13-17y (n=%d subjects)', roi, RSMYOldn); 
end
title(myTitle, 'Interpreter','none', 'FontSize', 10);
set(gca,'Xtick', [1:1:10], 'XtickLabel',new_labels, 'FontSize', 12)
set(gca,'Ytick', [1:1:10], 'YtickLabel','', 'FontSize', 12)

set(gcf, 'color', 'w')
 % save plot
figureName = sprintf('RSM_youngKidsVsOldKids_%s_%s_colorb',  roi, dataType);
print(fullfile(figuresDir, figureName), '-dpng', '-r200')
    

