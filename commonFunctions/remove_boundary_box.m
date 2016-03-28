function [candidates, scores] = remove_boundary_box(img, candidates, scores)

bValid1 = candidates(:,1) > size(img,2)*0.01 & candidates(:,3) < size(img,2)*0.99 ...
    & candidates(:,2) > size(img,1)*0.01 & candidates(:,4) < size(img,1)*0.99;
bValid2 = candidates(:,1) < size(img,2)*0.01 & candidates(:,3) > size(img,2)*0.99 ...
    & candidates(:,2) < size(img,1)*0.01 & candidates(:,4) > size(img,1)*0.99;
idxValid = find(bValid1 | bValid2);

candidates = candidates(idxValid,:);
scores = scores(idxValid,:);
end