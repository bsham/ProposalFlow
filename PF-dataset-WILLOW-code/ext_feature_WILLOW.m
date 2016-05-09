% script for extracting features of object proposals
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function ext_feature_WILLOW(modk, modv)

global conf;

for ci = 1:length(conf.class)
    
    load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',conf.class{ci})), 'KP');
    nImage = length(KP.image_name);
    
    %loop through features
    for ft = 1:numel(conf.feature)
        % loop through images
        for i = 1:nImage
            if exist('modk') && exist('modv') && mod(i, modv) ~= modk
                continue;
            end
            
            fprintf('Extracting features - %s (%d/%d): %s ', conf.class{ci}, i, nImage, KP.image_name{i});
            img = imread(fullfile(conf.datasetDir,KP.image_dir{i},KP.image_name{i}));
            
            % load object proposal
            load(fullfile(conf.proposalDir,KP.image_dir{i},...
                [ KP.image_name{i}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'op');
            
            if strcmp(conf.feature{ft},'HOG')
                feat = extract_segfeat_hog(img,op); % HOG
            elseif strcmp(conf.feature{ft}(1:3),'Con')
                feat = extract_segfeat_cnn(img,op,conf.feature{ft}); % CNN
            elseif strcmp(conf.feature{ft},'SPM')
                feat = extract_segfeat_spm(img,op); % SPM
            else
                break;
            end
            fprintf('%d %s generated.\n',size(op.coords,1),conf.feature{ft});
            
            if isempty(dir(fullfile(conf.featureDir,conf.class{ci},conf.feature{ft})))
                    mkdir(fullfile(conf.featureDir,conf.class{ci},conf.feature{ft}));
            end
                
            % save feats for the given image
            save(fullfile(conf.featureDir,KP.image_dir{i},conf.feature{ft},[ KP.image_name{i}(1:end-4)...
                '_' func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'feat');
        end
    end
end


