# distributedVTCDevelopment


Code and data accompanying the manuscript “Longitudinal development of category representations in ventral temporal cortex predicts word and face recognition”

The code was developed and tested in MATLAB version 2017b.  The code to generate the swarm plot needs to be run in MATLAB version 2020b or newer.

Here we provide the code necessary to generate the figures and tables. Some of the functions use the cbrewer color schemes, which can be found here (https://de.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab). Please make sure to download these and add them to your path before you begin.
Please also make sure to add the ‘helperFunctions’ folder to your path.


Charles (2021). cbrewer : colorbrewer schemes for Matlab (https://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab), MATLAB Central File Exchange.




You can find an overview on the scripts and datasets needed to reproduce each figure and table here:

 Figure 1
•	1C: ScatterplotShowingDistinctivenessByAge.m
•	1D & 1E: plotSlopesOfChangesInDistinctiveness.m
◦	data file for both: 'RSM_zscore_allChildrenNew_vtc_noSubID'

Figure 2
•	2A & 2B: plotSlopesOfChangesInDistinctivenessVoxelSubsets.m
◦	data files: 'RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID', &
◦	    'RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID'


Figure 3
•	3A,3B,3D & 3E: plotMDSforAgeGroups.m
•	3C & 3F: plotMDSDistanceFirstLastSession_VoxelSubsets.m
◦	data files: RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID
◦	 'RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID'

Figure 4
•	4A & 4C: ScatterplotShowingBehaviorByDistinctiveness.m
◦	data file A: 'tableBrainBehave_Words_lh_vtc_lateral_selective_8categories_union_wrmt3_pseudo_distinctiveness
◦	data file C:'tableBrainBehave_AdultFaces_rh_vtc_lateral_selective_8categories_union_CFMT_Adults_distinctiveness';
•	4B & 4D - left: plotPredictionErrorForDifferentModel.m
◦	data file B: 'tableBrainBehave_Words_lh_vtc_lateral_selective_8categories_union_wrmt3_pseudo_distinctiveness
◦	data file D:'tableBrainBehave_AdultFaces_rh_vtc_lateral_selective_8categories_union_CFMT_Adults_distinctiveness';
•	4B & 4D – right: SwarmplotShowingPredictionError.m (requires MATLAB version r2020b or newer)
◦	data file B: 'PredictionError_lh_vtc_lateral_Words_wrmt3_pseudo'
◦	data file D: 'PredictionError_rh_vtc_lateral_AdultFaces_CFMT_Adults'



Supplementary Figure 2
•	plotSlopesOfChangesInDistinctivenessVoxelSubsets.m
◦	data files: 'RSM_zscore_29children_vtc_selective_8categories_union_t3_var_matched_noSubID', & 'RSM_zscore_29children_vtc_nonSelective_8categories_union_t3_var_matched_noSubID'
◦	to create a table with all stats use the code: createTablesForChangesInDistinctivenessVoxelSubsets.m and the data files listed for this figure


Supplementary Figures 3 & 4
•	plotSlopesOfChangesInDistinctiveness_acrossTValues.m
•	data files: 'RSM_zscore_29children_vtc_selective_8categories_union_t1_noSubID', 'RSM_zscore_29children_vtc_selective_8categories_union_t2_noSubID', 'RSM_zscore_29children_vtc_selective_8categories_union_t3_noSubID', 'RSM_zscore_29children_vtc_selective_8categories_union_t4_noSubID', 'RSM_zscore_29children_vtc_selective_8categories_union_t5_noSubID'
•	to create a table with all stats use the code: createTablesForChangesInDistinctivenessVoxelSubsets_varyingTVal.m and the data files listed for this figure

Supplementary Figure 5
•	plotSlopesOfChangesInDistinctiveness_DiskROIs.m
•	data file: 'RSM_zscore_29children_DISK_ROIs_noSubID'
•	to create a table with the stats use the code: createTablesForChangesInDistinctiveness_DISKROIs and the data files listed for this figure

Supplementary Figure 6 & 7
•	A,C,D: plotRSMforAgeGroups.m
◦	data file A:RSM_zscore_allChildrenNew_vtc_noSubID
◦	data file C: RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID
◦	data file D: RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID
•	B: plotMDSforAgeGroups.m
◦	datafile: :RSM_zscore_allChildrenNew_vtc_noSubID

Supplementary Figure 8
•	plotMDSforAgeGroups.m
◦	data file: A & C: RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID
◦	data file: B & D: RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID

Supplementary Figure 9
•	plotLinkBetweenBehavioralTests.m
◦	data file A: 'tableReadingTests.mat']
◦	data file B: 'tableFaceTests.mat'

Supplementary Figure 10
•	A & C: ScatterplotShowingBehaviorByNumberOfVoxels.m
◦	data file A: 'tableBrainBehave_Words_lh_vtc_lateral_selective_8categories_union_wrmt3_pseudo_nrSelectiveVxls'
◦	data file C: 'tableBrainBehave_AdultFaces_rh_vtc_lateral_selective_8categories_union_CFMT_Adults_nrSelectiveVxls';
•	B & D: ScatterplotShowingBehaviorByROISize.m
◦	data file B: 'table_Words_ROIsPlusBehavior'
◦	data file D: 'table_AdultFaces_ROIsPlusBehavior'


Tables 1 & 2
•	createTablesForChangesInDistinctivenessAllVoxels
◦	data file: 'RSM_zscore_allChildrenNew_vtc_noSubID'

Tables 3-6
•	createTablesForChangesInDistinctivenessVoxelSubsets.m
◦	data files: 'RSM_zscore_29children_LatMed_vtc_selective_8categories_union_noSubID' & 'RSM_zscore_29children_LatMed_vtc_nonSelective_8categories_union_noSubID'     

