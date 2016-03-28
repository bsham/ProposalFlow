% script for extracting object proposals
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function do_ext_proposal(db_name, modk, modv)
% close all; clear;
% warning('off', 'all');
evalc(['set_conf_', db_name]);
bShowOP = false;

for ci = 1:numel(conf.class)
    
    % load the annotation file
    load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',conf.class{ci})), 'KP');
    nImage = length(KP.image_name);
    
    % loop through images
    for i = 1:nImage
        if exist('modk') && exist('modv') && mod(i, modv) ~= modk
            continue;
        end
        image_name = fullfile(conf.datasetDir,KP.image_dir{i},KP.image_name{i});
        img = imread(image_name);
        
        % extract object proposals
        fprintf('Extracting proposals - %s (%d/%d): %s ', conf.class{ci}, i, nImage, KP.image_name{i});
        [proposal, scores] = feval( conf.proposal, img, conf.num_op);
        op.coords=proposal; % (x,y) coordinates ([col,row]) for left-top and right-bottom points
        op.scores=scores;   % objectness score
        fprintf('%d %s generated.\n',size(op.coords,1),func2str(conf.proposal));
        
        % save extracted object proposals
        save(fullfile(conf.proposalDir,KP.image_dir{i},[ KP.image_name{i}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'op');
        
        % =========================================================================
        % show extracted object proposasls
        % =========================================================================
        if bShowOP
            img=imread(fullfile(conf.datasetDir,KP.image_dir{i},KP.image_name{i}));
            clf; imshow(rgb2gray(img)); hold on;
            op.coords=op.coords';
            colorCode = makeColorCode(length(op.coords));
            for k=1:length(op.coords)
                drawboxline(op.coords(:,k),'LineWidth',4,'color',colorCode(:,k));
            end
            pause;
        end
        
    end
end
