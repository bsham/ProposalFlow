function [candidates, score] = EB(im, num_candidates)

% Demo for Edge Boxes (please see readme.txt first).

%% load pre-trained edge detection model (see edgesDemo.m)
model=load('./object-proposal/edges-master/models/forest/modelBsds');model=model.model;


%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .85;     % step size of sliding window search
opts.beta  = .95;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

%% detect bbs (no visualization code for now)
tic, bbs=edgeBoxes(im,model,opts); toc
candidates = double(bbs(:,1:4));
candidates(:,3:4) = candidates(:,3:4) + candidates(:,1:2);
score = double(bbs(:,end));

[candidates, score] = remove_boundary_box(im, candidates, score);

if size(candidates, 1) > num_candidates
    candidates = candidates(1:num_candidates,:);
    score = score(1:num_candidates);
end
end

