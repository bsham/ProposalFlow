function [ feat ] = extract_segfeat_hog(img, seg, mask)
%% extract hog features from segments
if nargin < 3
    mask = [];
end
% initialize structs
feat = struct;

% compute HOG features
szCell = 8;
nX=8; nY=8;
nDim = nX*nY*31;
hist_temp = zeros(size(seg.coords,1), nDim);
hist_mask = zeros(size(seg.coords,1), nX*nY);
%im_patch_pad = ones(szCell*(nY+2),szCell*(nX+2),3);
%load('./feature/who2/bg11.mat');

pixels = double([nY nX] * szCell);
cropsize = ([nY nX]+2) * szCell;
% minsize

widths = double(seg.coords(:,3) - seg.coords(:,1) + 1);
heights = double(seg.coords(:,4) - seg.coords(:,2) + 1);
box_rects = [ seg.coords(:,1:2) widths heights ];


hog_prev = [];
% loop through boxes
for j = 1:size(hist_temp,1)    
    %img_patch = imresize(imcrop(img, box_rect), [szCell*nY szCell*nX]);
    %img_patch_pad(szCell+1:end-szCell,szCell+1:end-szCell,:) = img_patch;
    %img_patch = imresize(imcrop(img, box_rects(j,:)), [szCell*(nY+2) szCell*(nX+2)]);

    % padding
    padx = szCell * widths(j) / pixels(2);
    pady = szCell * heights(j) / pixels(1);
    x1 = round(double(seg.coords(j,1))-padx);
    x2 = round(double(seg.coords(j,3))+padx);
    y1 = round(double(seg.coords(j,2))-pady);
    y2 = round(double(seg.coords(j,4))+pady);
    %  pos(i).y1
    window = subarray(img, y1, y2, x1, x2, 1);
    img_patch = imresize(window, cropsize, 'bilinear');
    
    hog = features(double(img_patch), szCell);
    hog = hog(:,:,1:end-1);
    hist_temp(j,:) = hog(:)';
    
    if ~isempty(mask)
        mask_tmp = imresize(double(mask{j}),[8 8],'bilinear');% > 0;
        hist_mask(j,:) = mask_tmp(:)';
    end
    
    if 0
        img_patch_o = imresize(imcrop(img, box_rects(j,:)), [szCell*nY szCell*nX]);
        hog_vlfeat = vl_hog(single(img_patch_o), szCell);
        imhog = vl_hog('render', hog_vlfeat);

        hog_cc = single(hog);
        imhog2 = vl_hog('render', hog_cc);

        mu_pos = hog_cc;
        %[hog_lda, bias]   = train_hog_lda_filter(bg, mu_pos);
        [ny,nx,nf] = size(mu_pos);
        [R,neg] = whiten(bg,nX,nY);
        w = R\(R'\(mu_pos(:)-neg));
        bias = - w'*neg;
        hog_lda = reshape(w,[ny nx nf]);
        
        hog_lda_p = hog_lda;
        hog_lda_p(hog_lda_p<0) = 0;
        imhog_lda = vl_hog('render', single(hog_lda_p));

        if isempty(hog_prev)
            hog_prev = hog_cc;
        end

        s_ori = hog_cc(:)'*hog_cc(:);
        s_ori_prev = hog_cc(:)'*hog_prev(:);
        s_lda = hog_lda(:)'*hog_cc(:) + bias;
        s_lda_prev = hog_lda(:)'*hog_prev(:) + bias;

        fprintf('w/  whitened: %f %f\n', s_lda, s_lda_prev);
        fprintf('w/o whitened: %f %f\n', s_ori, s_ori_prev);

        clf ; 
        subplot(3,2,1); imagesc(img);  axis square; hold on;
        [ xmin ] = seg.coords(j,1); [ ymin ] = seg.coords(j,2);
        [ xmax ] = seg.coords(j,3); [ ymax ] = seg.coords(j,4);
        plot([xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'Color','r','LineWidth',1,'LineStyle','-');

        subplot(3,2,2); imagesc(img_patch_o); axis square;
        subplot(3,2,3); imagesc(imhog) ; colormap gray ; axis square;
        subplot(3,2,4); imagesc(imhog2) ; colormap gray ; axis square;
        %subplot(3,2,5); imagesc(imhog_whitened) ; colormap gray ; axis square;
        subplot(3,2,6); imagesc(imhog_lda) ; colormap gray ; axis square;
        pause;

        hog_prev = hog_cc;
    end
end
    
    
% add to feat
%feat.hist = sparse(hist_temp);
feat.hist = single(hist_temp);
if ~isempty(mask)
    feat.hist_mask = single(hist_mask);
    feat.mask = mask;
end
feat.boxes = seg.coords;
feat.img = img; 
        

function B = subarray(A, i1, i2, j1, j2, pad)

% B = subarray(A, i1, i2, j1, j2, pad)
% Extract subarray from array
% pad with boundary values if pad = 1
% pad with zeros if pad = 0

dim = size(A);
%i1
%i2
is = i1:i2;
js = j1:j2;

if pad,
  is = max(is,1);
  js = max(js,1);
  is = min(is,dim(1));
  js = min(js,dim(2));
  B  = A(is,js,:);
else
  % todo
end