% script for setting path
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

% vlfeat
run('/Users/ham/_research/cv-lib/vlfeat-0.9.20/toolbox/vl_setup');

% matconvnet
run('/Users/ham/_research/cv-lib/matconvnet-1.0-beta18/matlab/vl_setupnn');

% common functions
addpath('./commonFunctions');

% matching algorithm
addpath('./algorithms');

% feature
addpath(genpath('./feature'));


% object proposals
addpath('./object-proposal');
% edge-box
addpath('./object-proposal/edges-master');
% selective search
addpath('./object-proposal/SelectiveSearchCodeIJCV');
addpath('./object-proposal/SelectiveSearchCodeIJCV/Dependencies');
% mcg;
addpath('./object-proposal/mcg-2.0/pre-trained');
% baselines
addpath('./object-proposal/baselines');

% tps warping
addpath('./tpsWarp/');

% dense correspondence
addpath('./denseCorrespondence');

% SD filter
addpath('./sdFilter');





