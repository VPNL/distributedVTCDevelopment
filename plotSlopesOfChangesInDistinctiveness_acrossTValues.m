
% Plots the slopes of the LMM for category distinctiveness 
% for a given category across subsets of voxels defined by different
% t-values (Figures S3-S4)
clx
close all
%% Set up INPUTS

%  ROI
% Select the region of interest to plot the data for , either 'lateral' or
% 'medial'
 partition='lateral'; 




%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';


% List of datasets with data for different thresholds (t-value)
voxelSets = {'RSM_zscore_29children_vtc_selective_8categories_union_t1_noSubID',...
    'RSM_zscore_29children_vtc_selective_8categories_union_t2_noSubID',...
    'RSM_zscore_29children_vtc_selective_8categories_union_t3_noSubID',...
    'RSM_zscore_29children_vtc_selective_8categories_union_t4_noSubID',...
    'RSM_zscore_29children_vtc_selective_8categories_union_t5_noSubID'};


 %% Run for all categories

categories = {'Numbers', 'Words', 'Limbs', 'Bodies', 'AdultFaces', 'ChildFaces',...
 'Cars', 'StringInstruments', 'Houses', 'Corridors'};

hemis= {'lh', 'rh'};

for c=1:length(categories)
    
    category = categories{c};

    %% Loop through voxel Sets defined by different t-values
 

    allCoefficients = struct;

    for v=1:length(voxelSets)
        voxelSet = voxelSets{v};
        threshold = char(extractBetween(voxelSet, '_t', '_noSubID'));
        
        load([dataDir voxelSet])
        
        for h=1:length(hemis)
            hemi=hemis{h};
            roi= [hemi '_vtc_' partition];
            
             % reorganize Data: matrix of the format categories x categories x sessions
            [RSMdata3D, age, allSessions, subj, tSNR]  = prepareRSMData(RSMnoIDs, roi);

            % Compute distinctiveness for this category
            distinctiveness = computeCategoryDistinctiveness(RSMdata3D, categories, category);

            % Run a linear mixed model with predictors age and tSNR and
            % distinctiveness as dependent variable, subject is random effect
            % create table first
            tbl = table(distinctiveness, age, allSessions, subj, tSNR);
            lme = fitlme(tbl, 'distinctiveness ~ age + tSNR + (1| subj)');
            allCoefficients.(roi).(category).(['t' threshold]) = lme.Coefficients;
                 
           
            clearvars lme tbl
        end
        close all

    end

    %% Create a plot showing the slopes for each voxelset and hemisphere

    % errorbar(x,y, neg, pos)
    figure(1)
    for h=1:length(hemis)

        hemi = hemis{h};
        % Format data for errorbar plot
        x= 1:1:length(voxelSets);

        y = [allCoefficients.([hemi '_vtc_' partition]).(category).(['t1']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t2']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t3']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t4']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t5']){2,2}];

        neg = [allCoefficients.([hemi '_vtc_' partition]).(category).(['t1']){2,2} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t1']){2,7},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t2']){2,2} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t2']){2,7},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t3']){2,2} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t3']){2,7},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t4']){2,2} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t4']){2,7},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t5']){2,2} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t5']){2,7}];

        pos = [allCoefficients.([hemi '_vtc_' partition]).(category).(['t1']){2,8} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t1']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t2']){2,8} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t2']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t3']){2,8} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t3']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t4']){2,8} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t4']){2,2},...
            allCoefficients.([hemi '_vtc_' partition]).(category).(['t5']){2,8} - allCoefficients.([hemi '_vtc_' partition]).(category).(['t5']){2,2}];
        if h==1
            area([2.7 3.3], [0.1 0.1], 'FaceColor', 'y', 'EdgeColor', 'y')
            hold on
            area([2.7 3.3], [-0.1 -0.1], 'FaceColor', 'y', 'EdgeColor', 'y')
        end

        % CREATE ERRORBAR
        if strcmp(hemi, 'lh')
            e=errorbar(x -0.05,y, neg, pos, '-square', 'LineWidth', 3, 'Color', 'k', 'CapSize', 0, 'MarkerSize', 11, 'MarkerFaceColor',  'k');
        else
            e=errorbar(x +0.05,y, neg, pos, ':diamond', 'LineWidth', 3, 'Color', [0.6 0.6 0.6], 'CapSize', 0, 'MarkerSize', 11, 'MarkerFaceColor',   [0.6 0.6 0.6]);
        end
        xlim([0 6])
        ylim([-0.05 0.07])

        hold on

    end

    % format plot
    title(category)
    xlabel('t-threshold', 'FontSize', 14)
    ylabel('Change in distinctiveness', 'FontSize', 14)
    a = get(gca, 'XTickLabel');
    set(gca, 'XTickLabel', a, 'FontSize', 12)
    rl= refline([0 0]);
    rl.Color = [0.3 0.3 0.3];
    rl.LineWidth = 2;
    set(gcf, 'color', 'w')
    box off
    % l=legend(hemis);
    % l.Location = 'southeast';
    % l.Box = 'off';
    % l.FontSize = 14;

    figureName = sprintf('LMM_ChangeInDisticitveness_t-thresholds_%s_%s', category, partition);

    set(gcf, 'Position', [0 0 600 500]);
    print(fullfile(figuresDir, figureName), '-dpng', '-r200')
    
end % end category loop



