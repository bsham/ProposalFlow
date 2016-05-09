% script for setting configuration parameters 
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France 

global conf;
global tps_interp;
global sdf;

% parameters for make ground truth (near boxes for an object bounding box)
conf.threshold_intersection = 0.75; % area intersection ratio

% parameter for TPS warping
tps_interp.method = 'invdist'; %'nearest'; %'none' % interpolation method
tps_interp.radius = 5; % radius or median filter dimension
tps_interp.power = 2; %power for inverse wwighting interpolation method

% parameter for SD-filtering (SDF)
sdf.nei= 0;                 % 0: 4-neighbor 1: 8-neighbor
sdf.lambda = 20;            % smoothness parameter
sdf.sigma_g = 30;           % bandwidth for static guidance
sdf.sigma_u = 15;           % bandwidth for dynamic guidance
sdf.itr=2;                  % number of iterations
sdf.issparse=true;          % is the input sparse or not

% HOG decorrelation (whitening)
conf.file_lda_bg_hog = './feature/who2/bg11.mat';

% number of object proposal
conf.num_op = 500;

%% path

% dataset
conf.datasetDir = './PF-dataset-WILLOW/';

% keypoint
conf.annoKPDir = conf.datasetDir;

% object classes
conf.class = dir(conf.annoKPDir);
conf.class = {conf.class(4:end).name};

% proposal type
% @SS: selective search
% @RP: randomized Prim's
% @EB: edge box
% @MCG: multiscale combinatorial grouping
% @SW: sliding window
% @US: uniform sampling
% @GS: Gaussian sampling
conf.proposal = @SS;

% feature type
% HOG, SPM, Conv1, Conv2, Conv3, Conv4, Conv5
conf.feature = {'HOG', 'SPM', 'Conv1', 'Conv2', 'Conv3', 'Conv4', 'Conv5'};

% matching algorithm
% NAM: naive appearance matching
% PHM: probabilistic Hough matching
% LOM: local offset matching
%conf.algorithm = {@NAM, @PHM, @LOM, @LPHM};
conf.algorithm = {@NAM, @PHM, @LOM};

% benchmark dir
conf.benchmarkDir = ['./_BM-PF-WILLOW/' func2str(conf.proposal) '-' num2str(conf.num_op) '/'];
%conf.benchmarkDir = ['./_BM-PF-WILLOW/' func2str(conf.proposal) '/'];

% object proposal
conf.proposalDir = [conf.benchmarkDir 'proposal'];

% ground-truth matches
conf.matchGTDir = [conf.benchmarkDir 'proposal-match-GT'];

% fearues
conf.featureDir = [conf.benchmarkDir 'proposal-feature'];

% matches (proposal flow)
conf.matchDir = [conf.benchmarkDir 'proposal-match'];

% dense flow
conf.flowDir = [conf.benchmarkDir 'dense-flow'];

% evaluation (ProposalFlow)
conf.evaPFDir = [conf.benchmarkDir '_eva-ProposalFlow'];
conf.evaPFavgDir = [conf.benchmarkDir '_Avg-eva-ProposalFlow'];

% evaluation (ProposalFlow)
conf.evaDFDir = [conf.benchmarkDir '_eva-DenseFlow'];
conf.evaDFavgDir = [conf.benchmarkDir '_Avg-eva-DenseFlow'];

% make Dir
if isempty(dir(conf.benchmarkDir))
    mkdir(conf.benchmarkDir);
end
if isempty(dir(conf.proposalDir))
    mkdir(conf.proposalDir);
end
if isempty(dir(conf.matchGTDir))
    mkdir(conf.matchGTDir);
end
if isempty(dir(conf.featureDir))
    mkdir(conf.featureDir);
end
if isempty(dir(conf.matchDir))
    mkdir(conf.matchDir);
end
if isempty(dir(conf.flowDir))
    mkdir(conf.flowDir);
end
if isempty(dir(conf.evaPFDir))
    mkdir(conf.evaPFDir);
end
if isempty(dir(conf.evaPFavgDir))
    mkdir(conf.evaPFavgDir);
end
if isempty(dir(conf.evaDFDir))
    mkdir(conf.evaDFDir);
end
if isempty(dir(conf.evaDFavgDir))
    mkdir(conf.evaDFavgDir);
end

for ci = 1:length(conf.class)
    if isempty(dir(fullfile(conf.proposalDir,conf.class{ci})))
        mkdir(fullfile(conf.proposalDir,conf.class{ci}));
    end
    if isempty(dir(fullfile(conf.matchGTDir,conf.class{ci})))
        mkdir(fullfile(conf.matchGTDir,conf.class{ci}));
    end
    if isempty(dir(fullfile(conf.featureDir,conf.class{ci})))
        mkdir(fullfile(conf.featureDir,conf.class{ci}));
    end
    if isempty(dir(fullfile(conf.matchDir,conf.class{ci})))
        mkdir(fullfile(conf.matchDir,conf.class{ci}));
    end
    if isempty(dir(fullfile(conf.matchDir,conf.class{ci})))
        mkdir(fullfile(conf.matchDir,conf.class{ci}));
    end
    if isempty(dir(fullfile(conf.flowDir,conf.class{ci})))
        mkdir(fullfile(conf.flowDir,conf.class{ci}));
    end
    if isempty(dir(fullfile(conf.evaPFDir,conf.class{ci})))
        mkdir(fullfile(conf.evaPFDir,conf.class{ci}));
    end
    if isempty(dir(fullfile(conf.evaDFDir,conf.class{ci})))
        mkdir(fullfile(conf.evaDFDir,conf.class{ci}));
    end
end
