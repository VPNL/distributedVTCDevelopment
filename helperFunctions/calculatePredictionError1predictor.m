
function [allPredictionErrors1Predictor,  subjIDs]=calculatePredictionError1predictor(tbl, indVariable, depVariable)
% calculate the prediction error for each subject between the LMM
% prediction and the actual value for a LMM with 1 predictor
% INPUTS: 
% (1): tbl of all subjects data containing a column named subj, with the
% subj IDs
% (2): the names of the independent Variable as named in the tbl, such as
% indVariable = 'matchedfMRIsessionsAges'
% (3) the name of the dependent Variable as in the table, such as
% depVariable = 'dist';

% OUTPUT: prediction errors for all subjects (for each subj, we take the
% median error across that subject's sessions)

includedSubj=unique(tbl.subj);
allPredictionErrors1Predictor=nan(length(includedSubj),1);

for i=1:length(includedSubj)
    % leave out all sessions of on subj each time
    leftOutSubj=includedSubj{i};
    tblRemainingSubjs =tbl;
    leftOutSubjIdx=find(strcmp(tblRemainingSubjs.subj, leftOutSubj));
    
    % save data of that subj in separate tbl
    tblLeftOut =tblRemainingSubjs(leftOutSubjIdx, :);
    
    % remove all sessions of that subj to run LMM on remaining data
    tblRemainingSubjs(leftOutSubjIdx, :)=[];
    
    lme_allMinus1 = fitlme(tblRemainingSubjs, 'matchedBehavioralData ~ dist + (dist| subj)');
    
    % Using these model parameters, get predicted values for all sessions of that subject
    pErrorLOS =nan(height(tblLeftOut),1);
    
    for l=1:height(tblLeftOut)
        % predictedBehavValueLeftOut= intercept + (slopePred1 * leftOutPred1Value) 
        predictedBehavValueLeftOut= lme_allMinus1.Coefficients{1,2} + ...
            (lme_allMinus1.Coefficients{2,2} * tblLeftOut.(indVariable)(l));
        
        pErrorLOS(l) = abs(tblLeftOut.(depVariable)(l) - predictedBehavValueLeftOut);
        clearvars predictedBehavValueLeftOut
    end
    
    % Get median of prediction errors of that subj
    allPredictionErrors1Predictor(i)=median(pErrorLOS);
    subjIDs{i} = leftOutSubj;

clearvars tblLeftOut tblRemainingSubjs  pErrorLOS lme_allMinus1
end

end