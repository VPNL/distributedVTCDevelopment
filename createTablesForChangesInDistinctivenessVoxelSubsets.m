% This script creates tables of the linear mixed models indicating the change in
% distinctiveness per year in different subsets of voxels
close all
clear all

%% Set up paths, files and variables
dataDir = './data/';

% to create the tables for the union of the selective voxels use
% (1)fileName =
% 'RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID'
% to create the table for the non-selective voxels
% (2) fileName =
% 'RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID'
fileName = 'RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID';
dataType = extractAfter(fileName, 'vtc_');
% Choose one of these ROIS: 'lh_vtc_lateral', 'rh_vtc_lateral',
% 'lh_vtc_medial', 'rh_vtc_medial'
roi = 'lh_vtc_lateral';
%%

% Load RSM data. Struct is organized by ROI & partition (left and right lateral & medial VTC),
% subject and session
load([dataDir fileName])

% Order of categories in RSM. this order is important
categories= {'Numbers', 'Words', 'Limbs', 'Bodies', 'AdultFaces', 'ChildFaces',...
 'Cars', 'StringInstruments', 'Houses', 'Corridors'};

%% Gather data and compute distinctiveness for each session and ROI, Run linear mixed models

int_parameter = [];
int_lowerCI = [];
int_upperCI = [];
int_df = [];
int_p = [];

age_parameter = [];
age_lowerCI = [];
age_upperCI = [];
age_df = [];
age_p = [];

tSNR_parameter = [];
tSNR_lowerCI = [];
tSNR_upperCI = [];
tSNR_df = [];
tSNR_p = [];



for c= 1:length(categories)
    category = categories{c};
   

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
    % intercept
    int_parameter(c,1) = allCoefficients.(category).(roi).coeffs{1,2};
    int_lowerCI(c,1) = allCoefficients.(category).(roi).coeffs{1,7};
    int_upperCI(c,1) = allCoefficients.(category).(roi).coeffs{1,8};
    int_df(c,1) = allCoefficients.(category).(roi).coeffs{1,5};
    int_t(c,1) = allCoefficients.(category).(roi).coeffs{1,4};
    int_p(c,1) = allCoefficients.(category).(roi).coeffs{1,6};

    %% add coefficitnets for age
    age_parameter(c,1) = allCoefficients.(category).(roi).coeffs{2,2};
    age_lowerCI(c,1) = allCoefficients.(category).(roi).coeffs{2,7};
    age_upperCI(c,1) = allCoefficients.(category).(roi).coeffs{2,8};
    age_df(c,1) = allCoefficients.(category).(roi).coeffs{2,5};
    age_t(c,1) = allCoefficients.(category).(roi).coeffs{2,4};
    age_p(c,1) = allCoefficients.(category).(roi).coeffs{2,6};

    %% Tsnr
    tSNR_parameter(c,1) = allCoefficients.(category).(roi).coeffs{3,2};
    tSNR_lowerCI(c,1) = allCoefficients.(category).(roi).coeffs{3,7};
    tSNR_upperCI(c,1) = allCoefficients.(category).(roi).coeffs{3,8};
    tSNR_df(c,1) = allCoefficients.(category).(roi).coeffs{3,5};
    tSNR_t(c,1) = allCoefficients.(category).(roi).coeffs{3,4};
    tSNR_p(c,1) = allCoefficients.(category).(roi).coeffs{3,6};
   

    clearvars RSMdata3D age allSessions subj tSNR distinctiveness lme


end
% display table
t = table(categories', int_parameter, int_lowerCI, int_upperCI, int_df, int_t, int_p,...
    age_parameter, age_lowerCI, age_upperCI, age_df, age_t, age_p,...
    tSNR_parameter, tSNR_lowerCI, tSNR_upperCI, tSNR_df, tSNR_t, tSNR_p)

% % to save the table as excel file:
% filename =  sprintf('table_LMM_%s_%s.xlsx', dataType, roi);
% filePath =   ['./excelFiles/' filename];
% writetable(t,filePath,'Sheet',1)

