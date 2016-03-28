function [ feat ] = extract_segfeat_spm(img, seg)
%% extract spatial pyramid features from segments

load('./feature/dsift_dict/dsift_dict.mat');

% initialize structs
dsift = struct;
% extract dsift
[f,d] = dsift_wrapper(img);
% normalize and quantize
d = double(d);
d = d ./ (repmat(sum(d,1), size(d,1), 1) + eps); % L1 NORM
d = d ./ (repmat(sqrt(sum(d.^2,1)), size(d,1), 1) + eps); % L2 NORM
[~, quant_d] = min(pdist2(d', centers'), [], 2);

dsift.location = f;
dsift.words = quant_d';

% compute SPM features
hist_temp = zeros(size(seg.coords,1), 10000);
im_maxsize = max(dsift.location, [], 2);
% loop through boxes
for j = 1:size(hist_temp,1)
    
    box = seg.coords(j,:);
    box(1:4) = round(box(1:4));
    
    % generate image mask
    im_mask = zeros(im_maxsize(1), im_maxsize(2), 'uint8');
    
    if box(1)== 0
        box(1)=box(1)+1;
    end
    if box(2)== 0
        box(2)=box(2)+1;
    end
    
    im_mask_gridx = floor(linspace(box(1), box(3), 4));
    im_mask_gridy = floor(linspace(box(2), box(4), 4));
    im_mask_gridind = 1;
    for mx = 1:3
        for my = 1:3
            im_mask(im_mask_gridx(mx):im_mask_gridx(mx+1), im_mask_gridy(my):im_mask_gridy(my+1)) = im_mask_gridind;
            im_mask_gridind = im_mask_gridind + 1;
        end
    end
    % compute histogram representation
    box_sifthist = zeros(10, 1000);
    for k = 1:numel(dsift.words)
        loc_temp = dsift.location(:,k);
        if im_mask(loc_temp(1), loc_temp(2)) > 0
            box_sifthist(im_mask(loc_temp(1), loc_temp(2)), dsift.words(k)) = box_sifthist(im_mask(loc_temp(1), loc_temp(2)), dsift.words(k)) + 1;
            box_sifthist(10, dsift.words(k)) = box_sifthist(10, dsift.words(k)) + 1;
        end
    end
    hist_temp(j,:) = box_sifthist(:)';
    
end
% normalize histogram
hist_temp = hist_temp ./ repmat(sum(hist_temp,2) + eps, 1, size(hist_temp,2));

% add to feat
%feat.hist = sparse(hist_temp);
feat.hist = single(hist_temp);
feat.boxes = seg.coords;
feat.img = img;
end


%% WRAPPER TO RUN DENSE SIFT DESCRIPTOR CODE
function [f,d] = dsift_wrapper(img)

% read in image
I = single(rgb2gray(img));

% run feat
binSize = 8;
magnif = 3;
Is = vl_imsmooth(I, sqrt((binSize/magnif)^2 - .25));
[f,d] = vl_dsift(I, 'size', binSize, 'step', 4);

end