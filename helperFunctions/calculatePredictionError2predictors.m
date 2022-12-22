function [allPredictionErrors, subjIDs] =calculatePredictionError2predictors(tbl, indVariables, depVariable)
% calculate the prediction error for each subject between the LMM
% prediction and the actual value for a LMM with two predictors
% INPUTS: 
% (1): tbl of all subjects data containing a column named subj, with the
% subj IDs
% (2): the names of the independent Variables/predictors as named in the tbl, such as
% indVariables = {'matchedfMRIsessionsAges', 'categoryData'};
% (3) the name of the dependent Variable as in the table, such as
% depVariable = 'matchedBehavioralData';

% OUTPUT: prediction errors for all subjects (for each subj, we take the
% mean error across that subjects sessions)

includedSubj=unique(tbl.subj);
allPredictionErrors=nan(length(includedSubj),1);

for i=1:length(includedSubj)
    % leave out all sessions of on subj each time
    leftOutSubj=includedSubj{i};
    tblRemainingSubjs =tbl;
    leftOutSubjIdx=find(strcmp(tblRemainingSubjs.subj, leftOutSubj));
    
    % save data of that subj in separate tbl
    tblLeftOut =tblRemainingSubjs(leftOutSubjIdx, :);
    
    % remove all sessions of that subj to run LMM on remaining data
    tblRemainingSubjs(leftOutSubjIdx, :)=[];
    
     % run lmm with multiple predictors on data leaving out one subj data 
     modelStr = sprintf('%s ~ %s + %s + (%s| subj)', depVariable, indVariables{1}, indVariables{2}, indVariables{1})
     lme_allMinus1 = fitlme(tblRemainingSubjs, modelStr) ;
    
    % Using these model parameters, get predicted values for all sessions of that subject
    pErrorLOS =nan(height(tblLeftOut),1);
   
    % we can get the same result using the predict function
    predictedBehavValuesLeftOut = predict(lme_allMinus1, tblLeftOut);
    
    for l=1:height(tblLeftOut)
        % predictedBehavValueLeftOut= intercept + (slopePred1 * leftOutPred1Value) + (slopePred2 * leftOutPred2Value)
%         predictedBehavValueLeftOut= lme_allMinus1.Coefficients{1,2} + ...
%             (allSlopes_mult.('leaveOneOut').(indVariables{1}).slope * tblLeftOut.(indVariables{1})(l)) +...
%             (allSlopes_mult.('leaveOneOut').(indVariables{2}).slope * tblLeftOut.(indVariables{2})(l));      
%         pErrorLOS(l) = abs(tblLeftOut.(depVariable)(l) - predictedBehavValueLeftOut);
%         
        % same result using the predict function
        pErrorLOS(l) = abs(tblLeftOut.(depVariable)(l) - predictedBehavValuesLeftOut(l));
        
        
        clearvars predictedBehavValueLeftOut
    end
    
    % Get or median of prediction errors of that subj
    allPredictionErrors(i)=median(pErrorLOS);
    subjIDs{i} = leftOutSubj;

clearvars tblLeftOut tblRemainingSubjs allSlopes_mult pErrorLOS
end

end