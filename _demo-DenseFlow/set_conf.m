% script for setting configuration parameters 
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France 

% parameter for SD-filtering (SDF)
sdf.nei= 0;                 % 0: 4-neighbor 1: 8-neighbor
sdf.lambda = 20;            % smoothness parameter
sdf.sigma_g = 30;           % bandwidth for static guidance
sdf.sigma_u = 15;           % bandwidth for dynamic guidance
sdf.itr=2;                  % number of iterations
sdf.issparse=true;          % is the inpu

% HOG decorrelation
file_lda_bg_hog = './feature/who2/bg11.mat';

conf.resultDir = './res/';
conf.datasetDir = './imgs/';


if isempty(dir(conf.resultDir))
    mkdir(conf.resultDir);
end