function [ viewInfo ] = load_view( img, seg, feat, varargin )
% load image and make view info

conf = [];
cand = [];
for k=1:2:length(varargin)
  opt=lower(varargin{k}) ;
  arg=varargin{k+1} ;
  switch opt
    case 'conf'
      conf = arg;
    case 'cand'
      cand = arg;  
    otherwise
      error(sprintf('Unknown option ''%s''', opt)) ;
  end
end

viewInfo.img = img;
boxes = seg.coords;

if size(viewInfo.img,3) == 3
    viewInfo.img_gray = rgb2gray(viewInfo.img);
elseif size(featInfo.img,3) == 1
    viewInfo.img_gray = viewInfo.img;
    viewInfo.img = repmat( viewInfo.img, [ 1 1 3 ]);
else
    err([ 'wrong image file!: ' filePathName ]);
end

if isempty(cand)
    bValid1 = boxes(:,1) > size(viewInfo.img,2)*0.01 & boxes(:,3) < size(viewInfo.img,2)*0.99 ...
        & boxes(:,2) > size(viewInfo.img,1)*0.01 & boxes(:,4) < size(viewInfo.img,1)*0.99;
    bValid2 = boxes(:,1) < size(viewInfo.img,2)*0.01 & boxes(:,3) > size(viewInfo.img,2)*0.99 ...
        & boxes(:,2) < size(viewInfo.img,1)*0.01 & boxes(:,4) > size(viewInfo.img,1)*0.99;
    idxValid = find(bValid1 | bValid2);
else
    idxValid = cand;
end

boxes = boxes(idxValid,:);

viewInfo.idx2ori = int32(idxValid); % current index to original index
%viewInfo.ori2idx = zeros(size(boxes,1),1,'int32');
%viewInfo.ori2idx(idxValid) = 1:numel(idxValid); % original index to current index
viewInfo.frame = box2frame(boxes');
viewInfo.type = ones(1,size(viewInfo.frame,2),'int32');
%viewInfo.desc = sparse(feat.hist(idxValid,:)');
viewInfo.desc = single(feat.hist(idxValid,:)');
%viewInfo.desc = full(feat.hist');
viewInfo.patch = cell(0);

if isfield(feat, 'mask')
    viewInfo.mask = feat.mask(idxValid)';
end
if isfield(feat, 'hist_mask')
    viewInfo.desc_mask = single(feat.hist_mask(idxValid,:)');
end
    
viewInfo.bbox = [ 1, 1, size(viewInfo.img,2), size(viewInfo.img,1) ]';