% demo code for evaluating ProposalFlow 
% To set types of object proposals, features, and matching algorithm, 
% see the file: set_conf_PF.m

% set path
set_path;

% parsing keypoint annotations
do_prepKP_PF;

% extracting object proposals
do_ext_proposal('PF');

% extracting valid object proposals (object proposals near object bounding
% boxes)
do_ext_active_proposal('PF');

% automatically estimating ground-truth matches for valid object proposals
do_makeGT('PF');

% extracting feature descriptors for all object proposals
do_ext_feature('PF');

% computing proposal flow (matching all object proposals between two images)
do_matching('PF');

% evaluating the PCR and mIoU@k performance of proposal flow
do_evaluation('PF');

% evaluating proposal flow (averaging performance per feature)
do_evaluation_avg('PF');

% computing dense flow field using proposal flow
do_dense_flow('PF');

% evaluating dense flow field (PCK)
do_dense_flow_evaluation('PF');