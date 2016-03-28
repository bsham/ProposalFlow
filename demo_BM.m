% demo code for evaluating ProposalFlow 
% To set types of object proposals, features, and matching algorithm, 
% see the file: set_conf_RSF.m

% set path
set_path;

% parsing keypoint annotations
do_prepKP_RSF;

% extracting object proposals
do_ext_proposal('RSF');

% extracting valid object proposals (object proposals near object bounding
% boxes)
do_ext_active_proposal('RSF');

% automatically estimating ground-truth matches for valid object proposals
do_makeGT('RSF');

% extracting feature descriptors for all object proposals
do_ext_feature('RSF');

% computing proposal flow (matching all object proposals between two images)
do_matching('RSF');

% evaluating the PCR and mIoU@k performance of proposal flow
do_evaluation('RSF');

% evaluating proposal flow (averaging performance per feature)
do_evaluation_avg('RSF');

% computing dense flow field using proposal flow
do_dense_flow('RSF');

% evaluating dense flow field (PCK)
do_dense_flow_evaluation('RSF');