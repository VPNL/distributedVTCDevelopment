% SwarmplotShowingPredictionError
% Note: This script has to be run in Matlab version 2020b or newer
% Note: Xjitter is random
% It plots the difference in prediction error for behavior based on
% distinctiveness over the union of the selective vs the non-selective voxels.

%% Set up paths, files and variables
dataDir = './data/';
figuresDir = './figures/';

% indicate if you want to plot the difference in prediction error for Words
% or Faces (category='Words' or 'AdultFaces')
category='Words';

%%  Prepare data

if strcmp(category, 'Words')
    fileName = 'PredictionError_lh_vtc_lateral_Words_wrmt3_pseudo';
elseif strcmp(category, 'AdultFaces')
    fileName = 'PredictionError_rh_vtc_lateral_AdultFaces_CFMT_Adults';
end
roi = char(extractBetween(fileName, 'Error_', ['_' category] ));
test = char(extractAfter(fileName, [category '_']));

load([dataDir fileName])

% get difference between selective and nonselective  
diff = AllPE.selective.brain.data - AllPE.nonSelective.brain.data;

x= ones(length(diff),1);

%% create figure
figure(1)
set(gcf,'position',[0,0, 350, 500])
if strcmp(category, 'Words')
    plotColor = [125/255 43/255 84/255 ];
elseif contains(category, 'Faces')
    plotColor = [102/255 0 51/255 ];
end
s=  swarmchart(x, diff, 100, plotColor, 'filled','MarkerFaceAlpha', '0.4');
s.SizeData = 100;
s.XJitterWidth =0.4;
s.XJitter = 'randn';


% figure formatting
ylim([-15 15])
xlim([0 2])
rl = refline([0 0]);
rl.Color = [0.5 0.5 0.5];

box off
set(gcf,'color','w');

% title
titleStr = sprintf('%s %s',  roi, category);
title(titleStr, 'Interpreter', 'none')
ylabel('Difference in error')
xlabel('selective -nonselective')
xticks = '';
xticklabels = '';

set(gca,'fontname','arial') 
set(gca, 'FontSize', 15)

figureStr=sprintf('SwarmPlot_%s_%s_%s', roi, category, test);
print(fullfile(figuresDir, figureStr), '-dpng', '-r200')

