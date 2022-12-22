

function [RSMdata3D, age, allSessions, subj, tSNR]  = prepareRSMData(RSMnoIDs, roi)
% Prepare the RSM data so they can more easily be worked with
% INPUTS:
% (1) RSMnoIDs: the structure containing the RSM data for all ROIs,
% subjects, and sessions
% (2)roi: name of the roi you want to get the prepare the data for, such as
% roi = 'rh_vtc_lateral'

% OUTPUTS;
% (1) RSMdata3D: 3d-matrix containing RSM data. 
% Format: nr of categories x nr of categories x nr of sessions
% (2) age: vector containing age of sessions in fraction of a year,
% matchiing order to RSM data
% (3) allSessions: cell with names of all included sessions (corresponding
% to each RSM in the 3dmatrix)
% (4) subj: cell with included subjects (corresponding to each RSM in the 3d
% matrix)
% (5) tSNR: vector containing tSNR for each sessions,
% matchiing order to RSM data

age = [];
allSessions = {};
subj = {};
RSMdata={};
tSNR = [];

subjects = fieldnames(RSMnoIDs.(roi));

for s = 1:length(subjects)
    % sessions are nested in subjects
    sessionNames = fieldnames(RSMnoIDs.(roi).(subjects{s}));
    
    for i =1:length(sessionNames)
        RSMdata{end+1} = RSMnoIDs.(roi).(subjects{s}).(sessionNames{i}).csym;
        allSessions{end+1,1}=sessionNames{i};
        subj{end+1,1}=subjects{s};
        age(end+1,1) = RSMnoIDs.(roi).(subjects{s}).(sessionNames{i}).age;
        tSNR(end+1,1) = RSMnoIDs.(roi).(subjects{s}).(sessionNames{i}).tSNR;
    end
    
    
    clearvars sessionNames
end

% convert to 3 D matrix
RSMdata3D=cat(3, RSMdata{:});


end