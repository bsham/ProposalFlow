function [candidates, score] = RP(im, num_proposals, seed)


if nargin < 3
    % seed to milliseconds
    seed = str2double(datestr(now,'HHMMSSFFF'));
end

configParams = LoadConfigFile('./rp-master/config/rp_4segs.mat');

configParams.approxFinalNBoxes = num_proposals*50;
configParams.q = 1;
configParams.rSeedForRun = seed;
proposals = RP(im, configParams);
score = [];
score = -1*ones(size(proposals,1),1,'single');
[candidates, score] = remove_boundary_box(im, proposals, score);

if size(candidates, 1) > num_proposals
    
    idx = randi(size(candidates, 1),[1, num_proposals]);
    candidates = candidates(idx,:);
    score = score(idx);
end

end
