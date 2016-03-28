function [candidates, score] = MCG(im, num_candidates)
install;

tic;
% Test the 'accurate' version, which tackes around 30 seconds in mean
[candidates_mcg, ~] = im2mcg(im,'accurate');
% flip x and y coordinates
candidates = candidates_mcg.bboxes(:,[2 1 4 3]);
score = candidates_mcg.scores;
toc;

[candidates, score] = remove_boundary_box(im, candidates, score);

if size(candidates, 1) > num_candidates
    candidates = candidates(1:num_candidates,:);
    score = score(1:num_candidates);
end

end
