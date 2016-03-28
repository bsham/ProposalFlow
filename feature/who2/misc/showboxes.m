function showboxes(im, boxes, partcolor)
% showboxes(im, boxes)
% Draw boxes on top of image.


if nargin < 3,
  partcolor(1)    = {'r'};
  partcolor(2:20) = {'b'};
end

%imagesc(im); axis image; axis off;
imshow(im); hold on;
if ~isempty(boxes)
  numparts = floor(size(boxes, 2)/4);
  for i = 1:numparts
    ids = 1:min(3,size(boxes,1));
    x1 = boxes(ids,1+(i-1)*4);
    y1 = boxes(ids,2+(i-1)*4);
    x2 = boxes(ids,3+(i-1)*4);
    y2 = boxes(ids,4+(i-1)*4);
    line([x1 x1 x2 x2 x1]',[y1 y2 y2 y1 y1]','color',partcolor{i},'linewidth',5);
  end
end
drawnow;
hold off;
