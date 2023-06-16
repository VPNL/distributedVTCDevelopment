% Show bar plots indicating the prediction error for different models
% predicting behavior (face recognition, reading) from category
% distictiveness


%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';

% Indicate the category (category= 'Words' or 'AdultFaces')
category = 'Words';
% Indicate the ROI (roi = 'lh_vtc_lateral' or 'rh_vtc_lateral')
roi = 'lh_vtc_lateral';
% Indicate the test (test = 'wrmt3_pseudo' or 'CFMT_Adults')
test = 'wrmt3_pseudo';

%% load data

behaveDataFileName = ['tableBrainBehave_' category '_' roi '_selective_8categories_union_' test];
load([dataDir behaveDataFileName])
tblnoID.distinctiveness = []; % remove distinctiveness values from table, these are the ones for selective voxels, but we need both those for nonselective and selective  voxels
% we will collect those from RSMs

% we want to test if distinctiveness over the selective or nonSelective
% voxels is a better predictor
voxelSubsets = {'selective', 'nonSelective'};

% we also want to test if a model with distinctiveness alone is sufficient
% or if a model with distinctiveness+age predicts behavior better
modelNames = {  'brain', 'brainAge'};

% Order of categories in RSM. this order is important
categories= {'Numbers', 'Words', 'Limbs', 'Bodies', 'AdultFaces', 'ChildFaces',...
 'Cars', 'StringInstruments', 'Houses', 'Corridors'};

for v=1:length(voxelSubsets)
    % load distinctiveness data for nonselective or seleccive voxels
   load([dataDir 'RSM_zscore_29Children128Sessions_vtc_' voxelSubsets{v} '_8categories_union_noSubID'])
   
   % reorganize Data: matrix of the format categories x categories x sessions
    [RSMdata3D, age, allSessions, subj, tSNR]  = prepareRSMData(RSMnoIDs, roi);

    % Compute distinctiveness for this category
    distinctiveness = computeCategoryDistinctiveness(RSMdata3D, categories, category);
    
    % match distinctiveness to behavioral data (not all fMRI sessions have
    % behavioral data)
    for t=1:height(tblnoID)
        sessionIdx = find(strcmp(tblnoID.matchedfMRIsessions{t}, allSessions));
        tblnoID.dist(t) = distinctiveness(sessionIdx); 
    end
    
     %% Loop though different models
     for m=1:length(modelNames)
         modelName = modelNames{m};
         if strcmp(modelName, 'brain')
            indVariables = {'dist'};
         elseif strcmp(modelName, 'brainAge')
             indVariables = {'dist', 'matchedAgeBehavior'};
         end
         
         %% Leave out sessions of one subject and then compute LMM, repeat for all

        if length(indVariables)==1
 
            [allPredictionErrors,  subjIDs]=calculatePredictionError1predictor(tblnoID, indVariables{1}, 'matchedBehavioralData')
        else
            [allPredictionErrors, subjIDs] =calculatePredictionError2predictors(tblnoID, indVariables, 'matchedBehavioralData');
        end

        AllPE.(voxelSubsets{v}).(modelName).data =   allPredictionErrors;
        clearvars allPredictionErrors allPredictionErrors1Predictor
     end
   
    
end

% Box plot with these conditions
% (1) selective-10, (2) non-selective-10 (3) all-selective + age,

f2 = figure('Position', [0 0 300 500]);

% Set up colors, different for words and faces
if contains(category, 'Words')
    plotColors=[153/255 0 76/255 ;...
        0.5 0.5 0.5;...
        1/255 1/255 1/255];
else
    plotColors=[ 204/255 0/255 102/255 ;...
        0.8 0.8 0.8;...
        91/255 85/255 88/255 ];
end


%% create box plot
boxPlotData = [AllPE.('selective').('brain').data,... % Model with only distinctiveness
    AllPE.('nonSelective').('brain').data, ... % Model with only distinctiveness
    AllPE.('selective').('brainAge').data ]  % -------model distinctiveness and AGE 

groupNames ={'selective', 'non-selective', 'selective+age'};
bp=boxplot(boxPlotData, groupNames, 'Widths', 0.8, 'Symbol', '+', 'Color',[0.4 0.4 0.4] );
gcf = formatBoxPlotLines(gcf, bp);

% Color boxplot
b = findobj(gca,'Tag','Box');
patch(get(b(3),'XData'),get(b(3),'YData'), plotColors(1,:), 'FaceAlpha',.75 ); 
patch(get(b(2),'XData'),get(b(2),'YData'), plotColors(2,:), 'FaceAlpha',.75 ); 
patch(get(b(1),'XData'),get(b(1),'YData'), plotColors(3,:), 'FaceAlpha',.75 );

ylabel('Median absolute prediction error', 'FontSize', 12)
xticklabels(groupNames)
xtickangle(30)

set(f2, 'color', 'white')
box off
ylim([0 35])


titlestr=sprintf('%s %s %s', roi, category, test);
title(titlestr, 'Interpreter', 'none')
figureStr=sprintf('BoxPlot_ModelComp_%s_%s_%s', roi, category, test);


print(fullfile(figuresDir, figureStr), '-dpng', '-r200')







