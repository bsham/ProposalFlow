function [ feat ] = extract_segfeat_cnn(img, seg, type, mask)
%% extract hog features from segments
if nargin < 4
    mask = [];
end

if strcmp(type,'Conv1')
    num_of_layers = 5;%2;
elseif strcmp(type,'Conv2')
    num_of_layers = 9;%6;
elseif strcmp(type,'Conv3')
    num_of_layers = 11;%10;
elseif strcmp(type,'Conv4')
    num_of_layers = 13;%12;
else
    num_of_layers = 15;%14;
end

net = load('./feature/cnn-model/imagenet-caffe-ref.mat') ;
net.layers = net.layers(1:15);

% initialize structs
feat = struct;
% nDim = 4096;
% cnn_temp = zeros(size(seg.coords,1), nDim);
% imsize_cnn = net.normalization.imageSize(1:2);
imsize_cnn = [67,67]; %(3 x 3 output size network)
resized_average_image = imresize(net.normalization.averageImage,imsize_cnn);

heights = double(seg.coords(:,3) - seg.coords(:,1) + 1);
widths = double(seg.coords(:,4) - seg.coords(:,2) + 1);
box_rects = [ seg.coords(:,1:2) heights widths ];

ims_ = zeros([imsize_cnn(1), imsize_cnn(2), 3, size(seg.coords,1)]);
% loop through boxes
for j = 1:size(seg.coords,1)
    % preprocessing
    % 1) Resize
    % 2) single
    % 3) average image
    img_patch_o = imresize(imcrop(img, box_rects(j,:)), imsize_cnn);
    im = single(img_patch_o);
    im_ = im - resized_average_image;
    ims_(:,:,:,j) = im_;
end
ims_ = single(ims_);
res = vl_simplenn(net, ims_);
% conv5: res(15).x 
% conv4: res(12).x 
% conv3: res(10).x

% cnn_3 = reshape(res(10).x, numel(res(10).x)/size(seg.coords,1), size(seg.coords,1))';
% cnn_4 = reshape(res(12).x, numel(res(12).x)/size(seg.coords,1), size(seg.coords,1))';
% cnn_5 = reshape(res(15).x, numel(res(15).x)/size(seg.coords,1), size(seg.coords,1))';
% cnn_temp = [cnn_3, cnn_4, cnn_5];
cnn_temp = reshape(res(num_of_layers).x, numel(res(num_of_layers).x)/size(seg.coords,1), size(seg.coords,1))';

% l2 normalization
% for i=1:size(seg.coords,1)
%     cnn_temp(i,:)=cnn_temp(i,:)./norm(cnn_temp(i,:),2);
% end
    
% add to feat
feat.hist = single(cnn_temp);
%feat.hist = single(cnn_temp);
%feat.hist = sparse(double(cnn_temp));
% if ~isempty(mask)
%     feat.hist_mask = single(hist_mask);
%     feat.mask = mask;
% end
feat.boxes = seg.coords;
feat.img = img; 

end