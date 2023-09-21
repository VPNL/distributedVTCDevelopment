% This script creates the tables of the stats indicating the change in
% distinctiveness by age in category-selective disk ROIs.
close all
clear all

%% Set up paths, files and variables
dataDir = './data/';

fileName = 'RSM_zscore_29children_DISK_ROIs_noSubID';

%% indicate the region of interest you want to plot the data for, select one
% of
% 'lh_mOTS_word_SessionAvgDisk'
% 'lh_mFus_faceadultfacechild_SessionAvgDisk'
% 'lh_pOTS_word_SessionAvgDisk'
% 'lh_OTS_limb_SessionAvgDisk'
% 'lh_pFus_faceadultfacechild_SessionAvgDisk'
% 'lh_CoS_placehouse_SessionAvgDisk'

% or for right hemisphere ROIs
% 'rh_mFus_faceadultfacechild_SessionAvgDisk'
% 'rh_pOTS_word_SessionAvgDisk'
% 'rh_OTS_limb_SessionAvgDisk'
% 'rh_pFus_faceadultfacechild_SessionAvgDisk'
% 'rh_CoS_placehouse_SessionAvgDisk'

roi ='rh_pFus_faceadultfacechild_SessionAvgDisk'

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

t = table(categories', int_parameter, int_lowerCI, int_upperCI, int_df, int_t, int_p,...
    age_parameter, age_lowerCI, age_upperCI, age_df, age_t, age_p,...
    tSNR_parameter, tSNR_lowerCI, tSNR_upperCI, tSNR_df, tSNR_t, tSNR_p)


