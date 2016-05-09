% demo code for evaluating ProposalFlow 
% To set types of object proposals, features, and matching algorithm, 
% see the file: set_conf_PF.m

addpath('./PF-dataset-WILLOW-code');

% set path
set_path;

% set config
set_conf_WILLOW;

% parsing keypoint annotations
prepKP_WILLOW;

% extracting object proposals
ext_proposal_WILLOW;

% extracting valid object proposals (object proposals near object bounding
% boxes)
ext_active_proposal_WILLOW;

% automatically estimating ground-truth matches for valid object proposals
makeGT_WILLOW;

% extracting feature descriptors for all object proposals
ext_feature_WILLOW;

% computing proposal flow (matching all object proposals between two images)
matching_WILLOW;

% evaluating the PCR and mIoU@k performance of proposal flow
eva_WILLOW;

% evaluating proposal flow (averaging performance per feature)
eva_avg_WILLOW;

% computing dense flow field using proposal flow
dense_flow_WILLOW;

% evaluating dense flow field (PCK)
dense_flow_eva_WILLOW;