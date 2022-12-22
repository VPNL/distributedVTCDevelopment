% plotMDSDistanceFirstLastSession_VoxelSubsets

%  Plot individual euclidian distance from each childs first to
%  last sessions MDS embedding across all categories
% for the selective vs non-selective voxels 


%% set up directories
dataDir = './data/';
figuresDir = './figures/';

% Enter the name of the ROI (i.e., roi='lh_vtc_lateral'; 'rh_vtc_lateral'
roi =  'lh_vtc_lateral';

% enter file name without the .mat 
fileNames={'RSM_zscore_29Children128Sessions_vtc_selective_8categories_union_noSubID', 'RSM_zscore_29Children128Sessions_vtc_nonSelective_8categories_union_noSubID'};

for f=1:length(fileNames)
    
    fName = fileNames{f};
    % extract datatype from file name (selectvie voxels/nonselective
    % voxels)
    dataType=char(extractAfter(fName, 'hildren'));
    dataType=char(extractBetween(dataType, 'vtc_', '_8'));
    
    eucDist =[];
    load([dataDir fName])
    % reorganize Data: matrix of the format categories x categories x sessions
    [RSMdata3D, age, allSessions, subj, tSNR]  = prepareRSMData(RSMnoIDs, roi);

    %% Find first and last session of the same subject, get procrustes distance
    
    subjUnique=unique(subj, 'stable');
    
    for s=1:length(subjUnique)
   

        SubSessionIdx=find(strcmp(extractBefore(allSessions, '_'), subjUnique{s}));
        % sessions should be ordered by ascending age for each subj but lets double check
        SubAges=age(SubSessionIdx);
        [minAge, minAgeidx] = min(SubAges);
        [maxAge, maxAgeidx] = max(SubAges);
        
        SubjFirstRSM = RSMdata3D(:,:,SubSessionIdx(minAgeidx));
        SubjLastRSM = RSMdata3D(:,:,SubSessionIdx(maxAgeidx));
        
        %% MDS embedding
        %% first session
        % convert matrix to dissimilarity matrix. pdist returens pairwise distances as vecctor and squareform puts back to matrix format
        firstRSM_dist = squareform(pdist(SubjFirstRSM));
        
        % do classical multidimensional scaling (dimensionality is set to 2 here)
        firstRSM_emb = cmdscale(firstRSM_dist,2);

        %% last 
        % convert matrix to dissimilarity matrix. pdist returens pairwise distances as vecctor and squareform puts back to matrix format
        lastRSM_dist = squareform(pdist(SubjLastRSM));

        % do classical multidimensional scaling (dimensionality is set to 2 here)
        lastRSM_emb = cmdscale(lastRSM_dist,2);

        % Align the embedding of young to old
        [residual_stress(s), youngEmbeddingAligned2Old] = procrustes( lastRSM_emb,firstRSM_emb, 'Scaling', 0); 

        
        d= [];
        for c=1:length(lastRSM_emb)
            d(c)=pdist([youngEmbeddingAligned2Old(c, 1), youngEmbeddingAligned2Old(c, 2); lastRSM_emb(c, 1), lastRSM_emb(c, 2)], 'euclidean');
            
        end
            eucDist(s)=mean(d) ;
        hold off
    end

euclDist.(dataType)=eucDist;

clearvars eucDist
clearvars RSMnoIDs
end

%% Plot with individual lines for each subject
figure(1) 
set(gcf, 'Position', [0 0 400 600]);

%  plot individualsubj lines, one color each
colors1 = cbrewer('qual', 'Set3', 12);        
colors3 = cbrewer('qual', 'Set1', 9);   
colors2 = cbrewer('qual', 'Dark2', 8);
colors = [colors1; colors3; colors2];


for s=1:length(euclDist.selective)
    pl=plot([1 2], [euclDist.selective(s) euclDist.nonSelective(s)]);
    
    if euclDist.selective(s) > euclDist.nonSelective(s)
        pl.Color = [0.6 0.6 0.6];
    else
        pl.Color = 'r';
    end
    pl.LineWidth=3;
    hold on
    
end

% formatting
title(roi, 'interpreter', 'none')
ylabel('euclidian distance (first to last session)')
ylim([0 1])
xlim([0.6 2.3])
xticks([1,2])
yticks([0, 0.2 0.4 0.6 0.8 1])
xticklabels( {'selective', 'non-Selective'})
box off
set(gcf,'color', 'white')
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 15)

figureName= sprintf('MDS_EmbEuclDist_Individuals_VoxelSubsets_%s', roi)
print(fullfile(figuresDir, figureName), '-dpng', '-r200')

%% Run paired t-test

[h, p, ci, stats ]= ttest(euclDist.selective, euclDist.nonSelective)