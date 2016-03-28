% demo code for computing dense flow field
% using ProposalFlow (LOM+SS)

clc;
clear all;

% show object proposal matching
bShowMatch = true;

% show dense flow field
bShowFlow = true;

set_path;
set_conf;

num_op=500; %number of object proposals

fprintf(' + Parsing images\n\n');
imgA = imread(fullfile(conf.datasetDir,'Cars_008a.png'));
imgB = imread(fullfile(conf.datasetDir,'Cars_014b.png'));

% ===============================================================
% extracting object proposals using SelectiveSearch
% ===============================================================
fprintf(' + Extrating object proposals ');
tic;
[proposalA, ~] = SS(imgA, num_op);% (x,y) coordinates ([col,row]) for left-top and right-bottom points
[proposalB, ~] = SS(imgB, num_op);% (x,y) coordinates ([col,row]) for left-top and right-bottom points
opA.coords=proposalA;
opB.coords=proposalB;
clear proposalA; clear proposalB;
fprintf('took %.2f secs.\n\n',toc);

% ===============================================================
% extrating feature descriptors
% ===============================================================
fprintf(' + Extrating featrues ');
tic;
featA =  extract_segfeat_hog(imgA,opA);
featB =  extract_segfeat_hog(imgB,opB);
fprintf('took %.2f secs.\n\n',toc);

viewA = load_view(imgA,opA,featA);
viewB = load_view(imgB,opB,featB);
clear featA; clear featB;
clear opA; clear opB;

% ===============================================================
% matching object proposals
% ===============================================================
fprintf(' + Matching object proposals\n');
fprintf('   - # of features: A %d => # B %d\n', size(viewA.desc,2), size(viewB.desc,2) );

% options for matching
opt.bDeleteByAspect = true;
opt.bDensityAware = false;
opt.bSimVote = true;
opt.bVoteExp = true;
opt.feature = 'HOG';

% matching algorithm
% NAM: naive appearance matching
% PHM: probabilistic Hough matching
% LOM: local offset matching
tic;
confidence = feval( @LOM, viewA, viewB, opt );
fprintf('   - %s took %.2f secs.\n\n', func2str(@LOM), toc);
t1=toc;

% ===============================================================
% show object proposal matching
% ===============================================================

if bShowMatch
    [confidenceA, max_id ] = max(confidence,[],2);
    match = [ 1:numel(max_id); max_id'];
    hFig_match = figure(1); clf;
    imgInput = appendimages( viewA.img, viewB.img, 'h' );
    imshow(rgb2gray(imgInput)); hold on;
    showColoredMatches(viewA.frame, viewB.frame, match,...
        confidenceA, 'offset', [ size(viewA.img,2) 0 ], 'mode', 'box');
end

% ===============================================================
% computing dense flow field
% ===============================================================
fprintf(' + Computing dense correspondnece ');
tic;
bPost=true; % applying post processing using SDFilering
match = flow_field_generation(viewA, viewB, confidence, sdf, bPost);
fprintf('took %.2f secs.\n\n',toc);
t2=toc;

fprintf('==================================\n');
fprintf('Total flow took %.2f secs\n',t1+t2);
fprintf('==================================\n');

save(fullfile(conf.resultDir,'flow.mat'), 'match');


if bShowFlow
    clf(figure(2),'reset');
    imgInput = appendimages( viewA.img, viewB.img, 'h' );
    figure(2);imshow(imgInput);hold on;
    figure(3);imshow(flowToColor(cat(3,match.vx,match.vy)));%Flow =cat(3,match.vx,match.vy);cquiver(Flow(1:10:end,1:10:end,:));
    WarpedImg=warpImage(im2double(viewB.img),match.vx,match.vy);
    figure(4);imshow(WarpedImg);
end
