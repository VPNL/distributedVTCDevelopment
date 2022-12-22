
function distinctiveness = computeCategoryDistinctiveness(RSMdata3D, categories, category)
% computes the distinctiveness for a given category
% INPUTS
% (1): RSMdata3D: matrix containing the RSM data
% This matrix has the format nr of categories x nr of categories x nr of sessions
% (2) categories: list of the categories (cell)
% (3) category: the selected category, for intance category = 'Words'

% OUTPUTS:
% (1) distinctiveness: a vector with values of distinctiveness of the
% length of the number of sessions


categoryNumber = find(contains(categories, category));

% we leave out the other category from the same domain (i.e., words vs all except
% numbers)
currentDomain = ceil(categoryNumber/2);
sameDomainCategories = [currentDomain*2-1 currentDomain*2];
allNumbers = 1:length(categories);
offDiagNumbers = setdiff(allNumbers, sameDomainCategories);

%% get on-diagonal values
onDiagValues = RSMdata3D(categoryNumber, categoryNumber, :);
% reshape to column vector
onDiagValues = reshape(onDiagValues,size(RSMdata3D, 3),1);

%% Off diagonal values without other category from same domain
offDiagValues =mean(RSMdata3D(categoryNumber, offDiagNumbers, :));
offDiagValues = reshape(offDiagValues,size(RSMdata3D, 3),1);

%% distinctiveness
distinctiveness = onDiagValues - offDiagValues;

end