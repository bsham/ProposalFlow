function boxes=test_dataset(test, model, name)
% boxes=test_dataset(test, model, name)
% test is struct array with fields:
%	im:full path to image
for i = 1:length(test),
  fprintf('%s: testing: %d/%d\n', name, i, length(test));
  im = imread(test(i).im);
  tic;
  boxes{i} = detect(im, model, model.thresh);
  toc; tic;
  boxes{i} = nms(boxes{i},.5);
  toc;
 % showboxes(im,boxes{i});
end

