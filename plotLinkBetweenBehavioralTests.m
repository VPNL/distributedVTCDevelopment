% tests Links Between Reading Tests and between face tests

% test if performance on one Reading test predicts
% performance on another reading test

% And tests if performance on one face recognition test (CFMT adults) is
% linked to performance on a version of the CFMT with child faces.
clear all
close all

%% Set up variables and directories
% select either 'reading' or 'face' for the test domain
testdomain='face';

% load data
dataDir = './data/';
figuresDir = './figures/';
if strcmp(testdomain, 'face')
    load([dataDir 'tableFaceTests.mat'])
elseif strcmp(testdomain, 'reading')
    load([dataDir 'tableReadingTests.mat'])
end

%% run LMM

%allSlopes = runLMMOnData(allSlopes, tbl, [test1 '_' test2], 'behavioral', 'allDataTest1', 'allDataTest2', modelSelection);

if strcmp(testdomain, 'face')
    lme = fitlme(tbl_noSubjID, 'child_faces ~ adult_faces + (1| subj)')
elseif strcmp(testdomain, 'reading')
    lme = fitlme(tbl_noSubjID, 'real_words ~ pseudo_words + (1| subj)')
end



%% Create figure
figure(1)  
set(gcf, 'Position', [0 0 600 500]);

% Create CI for slope (matching those produced in R)
tblnew = table();
if strcmp(testdomain, 'face')
    tblnew.adult_faces=linspace(min(tbl_noSubjID.adult_faces),max(tbl_noSubjID.adult_faces))';
elseif strcmp(testdomain, 'reading')
    tblnew.pseudo_words=linspace(min(tbl_noSubjID.pseudo_words),max(tbl_noSubjID.pseudo_words))';
end

tblnew.subj = repmat({'a'},100,1);
[ypred, yCI, DF] = predict(lme, tblnew);

if strcmp(testdomain, 'face')
    yfit_meanline = polyval([lme.Coefficients{2,2} lme.Coefficients{1,2}], [min(tbl_noSubjID.adult_faces),max(tbl_noSubjID.adult_faces)])
    eb = errorbar3(tblnew.adult_faces', ypred', [yCI(:,1)'; yCI(:,2)'] , 1, [0.8 0.8 0.8]);
elseif strcmp(testdomain, 'reading')
    yfit_meanline = polyval([lme.Coefficients{2,2} lme.Coefficients{1,2}], [min(tbl_noSubjID.pseudo_words),max(tbl_noSubjID.pseudo_words)])
    eb = errorbar3(tblnew.pseudo_words', ypred', [yCI(:,1)'; yCI(:,2)'] , 1, [0.8 0.8 0.8]);
end

hold on

% plot individual data on top
allsubj = unique(tbl_noSubjID.subj);
colors1 = cbrewer('qual', 'Set3', 12);        
colors4 = cbrewer('qual', 'Set2', 8);   
colors2 = cbrewer('qual', 'Dark2', 8);
colors3=cbrewer('qual', 'Paired', 1);
colors = [colors1; colors3; colors2; colors4];
            
% Find values for each subject and plot in one color
for sd = 1:length(allsubj)
    sub = allsubj{sd};
    
    if strcmp(testdomain, 'face')
       	colIndexallData2 = find(strcmp(tbl_noSubjID.Properties.VariableNames, 'adult_faces'), 1);
        colIndexallData1 = find(strcmp(tbl_noSubjID.Properties.VariableNames, 'child_faces'), 1);
    elseif strcmp(testdomain, 'reading')
        colIndexallData2 = find(strcmp(tbl_noSubjID.Properties.VariableNames, 'pseudo_words'), 1);
        colIndexallData1 = find(strcmp(tbl_noSubjID.Properties.VariableNames, 'real_words'), 1);
    end
    allDataTest2Vals = tbl_noSubjID{strcmp(tbl_noSubjID.subj,sub), colIndexallData2};
    allDataTest1Vals = tbl_noSubjID{strcmp(tbl_noSubjID.subj,sub), colIndexallData1};
    plot(allDataTest2Vals, allDataTest1Vals,  'o', 'MarkerFaceColor', colors(sd,:), 'MarkerEdgeColor', colors(sd, :))
    
    hold on
    clearvars allDataTest1Vals allDataTest2Vals sub
end


% finally plot overall regression line
if strcmp(testdomain, 'face')
    line(tblnew.adult_faces, ypred, 'Color', [0.5 0.5 0.5])
elseif strcmp(testdomain, 'reading')
    line(tblnew.pseudo_words, ypred, 'Color', [0.5 0.5 0.5])
end

r1 = refline(lme.Coefficients{2,2}, lme.Coefficients{1,2});
r1.Color = [0.5 0.5 0.5];
r1.LineWidth = 4;

%% Format plot
xlabel(lme.CoefficientNames{1,2}, 'Interpreter', 'none', 'FontSize', 14)
ylabel(lme.Formula.FELinearFormula.ResponseName, 'Interpreter', 'none', 'FontSize', 14)
if strcmp(testdomain, 'face')
   ylim([0 100]) 
   xlim([0 100]) 
   rl=refline([0 33]);
   rl.Color=[0.8 0.8 0.8];
   rl.LineWidth=2;
   rl.LineStyle=':';
   pl=plot([33 33], [0 100], ':', 'Color', [0.8 0.8 0.8]);
   pl.LineWidth = 2;
   
end


box off
set(gcf, 'color', 'w')
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 18)

%% save plot
figureName = sprintf('LinkBetweenBehavioralTests_%s', testdomain);
print(fullfile(figuresDir, figureName), '-dpng', '-r200')

