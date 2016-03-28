function showHOG(ww)

wwp = foldHOG(ww);
wwn = foldHOG(-ww);
sc = max([wwp(:);wwn(:)]);
sc = 255/sc;

siz = 20;

im1 = HOGpicture(wwp,siz)*sc;
im2 = HOGpicture(wwn,siz)*sc;

%Combine into 1 image
buff = 10;
im1 = padarray(im1,[buff buff],200,'both');
im2 = padarray(im2,[buff buff],200,'both');
im = cat(2,im1,im2);
im = uint8(im);
imagesc(im); colormap gray;
axis equal;

function im = HOGpicture(w, bs)
% HOGpicture(w, bs)
% Make picture of positive HOG weights.

% construct a "glyph" for each orientaion
bim1 = zeros(bs, bs);
bim1(:,round(bs/2):round(bs/2)+1) = 1;
bim1 = bim1;
no   = 9;
bim = zeros([size(bim1) no]);
bim(:,:,1) = bim1;
for i = 2:no,
  bim(:,:,i) = imrotate(bim1, -(i-1)*(180/no), 'crop');
end

% make pictures of positive weights bs adding up weighted glyphs
s = size(w);    
w(w < 0) = 0;    
im = zeros(bs*s(1), bs*s(2));
for i = 1:s(1),
  iis = (i-1)*bs+1:i*bs;
  for j = 1:s(2),
    jjs = (j-1)*bs+1:j*bs;          
    for k = 1:no,
      im(iis,jjs) = im(iis,jjs) + bim(:,:,k) * w(i,j,k);
    end
  end
end

function f = foldHOG(w)
% f = foldHOG(w)
% Condense HOG features into one orientation histogram.
% Used for displaying a feature.

f=max(w(:,:,1:9),0)+max(w(:,:,10:18),0)+max(w(:,:,19:27),0);
