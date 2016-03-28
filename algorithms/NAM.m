% Naive Appearance Matching  
function [ confidenceMap ] = NAM( viewA, viewB, opt)
bVerbose = false;
bDensityAware = opt.bDensityAware;
bDeleteByAspect = opt.bDeleteByAspect;
bFeature = opt.feature;
thresAspect = 2.0;

if bDensityAware
    po = 4;    method = 'circles';
    radius = [];    N = [];    n = [];    ms = 5;
    figure; axis ij;
    out = scatplot(viewA.frame(1,:),viewA.frame(2,:),method,radius,N,n,po,ms);
    fdensity = out.dd';
else
    fdensity = ones(size(viewA.frame,2),1)';
end

tic;
% aspect ratio
aTrain = viewA.frame(3,:)./viewA.frame(6,:);
aTest = viewB.frame(3,:)./viewB.frame(6,:);


% learned BG HOG statistics
if strcmp(bFeature,'HOG')
    load('./feature/who2/bg11.mat');
    nY = 8; nX = 8;
    [bg.R, bg.mu_bg] = whiten(bg,nX,nY);
    % compute full sim matrix
    % compute S^-1*(mu_pos-mu_bg) efficiently
    A = viewA.desc-repmat(bg.mu_bg,1,size(viewA.desc,2));
    A = bg.R\(bg.R'\A);
    B = viewB.desc;
    
    bias = -A'*bg.mu_bg;
    wVoteFull = [ A; bias' ]'* [ B; ones(1,size(B,2)) ];
    wVoteFull = max(wVoteFull,0);
    fprintf('wdot\n');
elseif strcmp(bFeature,'SPM')
    % chi2 kernel embedding (inner product)
    wVoteFull = vl_alldist2(sparse(double(viewA.desc)),sparse(double(viewB.desc)), 'KCHI2');
    fprintf('chi2\n');
else
    A = viewA.desc;
    B = viewB.desc;
    wVoteFull = A'*B;
    wVoteFull = max(wVoteFull,0);
    fprintf('dot\n');
end


tableValid = true(size(viewA.frame,2),size(viewB.frame,2));

if bVerbose
    fprintf('vote weight: max %f - min %f\n', max(wVoteFull(:)), min(wVoteFull(:)));
end

nFeatTrain = size(viewA.desc,2);

if bDeleteByAspect
    for j=1:nFeatTrain
        bValid = (aTest/aTrain(j) < thresAspect) & (aTest/aTrain(j) > 1/thresAspect);
        tableValid(j, ~bValid) = false;
    end
end

% make the confidence map (# of frames A by # of frames B)
confidenceMap = zeros(size(viewA.frame,2),size(viewB.frame,2),'single');
idxValid = find(tableValid>0);
confidenceMap(idxValid) = wVoteFull(idxValid);
end

