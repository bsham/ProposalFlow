% script for matching object proposals
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function matching_WILLOW()

global conf;

bShowMatch = false;  % show k best matches for each pairwise matching

%loop through features
for ft = 1:numel(conf.feature)
    
    for ci = 1:numel(conf.class)
        
        fprintf('processing %s...',conf.class{ci});
        % load the annotation file
        load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',conf.class{ci})), 'KP');
        load(fullfile(conf.benchmarkDir,sprintf('AP_%s.mat',conf.class{ci})), 'AP');
        
        nImage = length(KP.image_name);
        
        % box matching from image A to image B
        for i=1:nImage
            
            img = imread(fullfile(conf.datasetDir,KP.image_dir{i},KP.image_name{i}));
            
            % load object proposals and features for image A
            load(fullfile(conf.proposalDir,KP.image_dir{i},[ KP.image_name{i}(1:end-4)...
                '_' func2str(conf.proposal) '.mat' ]), 'op');
            load(fullfile(conf.featureDir,KP.image_dir{i},conf.feature{ft},[ KP.image_name{i}(1:end-4)...
                '_' func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'feat');
            viewA = load_view(img,op,feat,'conf', conf);
            
            if bShowMatch
                % indicies for active object proposals transform current indices to candidate indices
                idx_for_active_opA = zeros(AP.num_op_all(i),1,'int32');
                idx_for_active_opA(AP.idx_for_active_op{i}) = 1:numel(AP.idx_for_active_op{i}); % original index to current index
                idx_for_active_opA = idx_for_active_opA(viewA.idx2ori)';
            end
            
            
            for j=1:nImage
                
                if i == j,   continue;   end % skip when it's same
                
                img = imread(fullfile(conf.datasetDir,KP.image_dir{j},KP.image_name{j}));
                
                % load object proposals and features for image B
                load(fullfile(conf.proposalDir,KP.image_dir{j},[ KP.image_name{j}(1:end-4)...
                    '_' func2str(conf.proposal) '.mat' ]), 'op');
                load(fullfile(conf.featureDir,KP.image_dir{j},conf.feature{ft},[ KP.image_name{j}(1:end-4)...
                    '_' func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'feat');
                viewB = load_view(img, op, feat, 'conf', conf);
                
                fprintf('\n======= %s-(%03d/%03d <= %03d/%03d) =======\n',conf.class{ci}, i,nImage,j,nImage);
                fprintf('+ features: %s\n', conf.feature{ft} );
                fprintf('+ object proposal: %s\n', func2str(conf.proposal) );
                fprintf('+ number of proposals: A %d => B %d\n', size(viewA.desc,2), size(viewB.desc,2) );
                
                % run matching algorithms
                for fa = 1:numel(conf.algorithm)
                    tic;
                    fprintf(' - %s matching... ', func2str(conf.algorithm{fa}));
                    
                    % options for matching
                    opt.bDeleteByAspect = true;
                    opt.bDensityAware = false;
                    opt.bSimVote = true;
                    opt.bVoteExp = true;
                    opt.feature = conf.feature{ft};
                    %profile on;
                    confidenceMap = feval( conf.algorithm{fa}, viewA, viewB, opt );
                    
                    fprintf('   took %.2f secs\n',toc);
                    
                    % matching confidence
                    [ confidenceA, max_id ] = max(confidenceMap,[],2);
                    
                    pmatch.confidence = confidenceMap;
                    pmatch.match = [ viewA.idx2ori viewB.idx2ori(max_id) ]';
                    pmatch.match_confidence = confidenceA;
                    
                    if isempty(dir(fullfile(conf.matchDir,conf.class{ci},conf.feature{ft})))
                        mkdir(fullfile(conf.matchDir,conf.class{ci},conf.feature{ft}));
                    end
                    
                    save(fullfile(conf.matchDir, KP.image_dir{i},conf.feature{ft},...
                        [ KP.image_name{i}(1:end-4) '-' KP.image_name{j}(1:end-4)...
                        '_' func2str(conf.proposal) '_' conf.feature{ft} '_' func2str(conf.algorithm{fa}) '.mat' ]), 'pmatch');
                    
                    % =========================================================================
                    % visualization top k-matches and their valid matches
                    % according to the IoU threshold.
                    % paramter:
                    % num_of_top_k_matches
                    % IoU_threshold
                    % =========================================================================
                    
                    if bShowMatch
                        strVisMode = 'box';
                        
                        load(fullfile(conf.matchGTDir,KP.image_dir{i},...
                            [ KP.image_name{i}(1:end-4) '-' KP.image_name{j}(1:end-4)...
                            '_' func2str(conf.proposal) '.mat' ]), 'IoU2GT'); % for visualization
                        
                        idx_for_opB = pmatch.match(2,:);
                        idx_valid = find((idx_for_active_opA > 0) & (idx_for_opB > 0));
                        
                        %                 %% top k-matches
                        %                 [~,idx_sort_conf]=sort(confidenceA,'descend');
                        %                 num_of_top_k_matches = numel(rmatch.match(1,:));
                        %                 temp_idx=zeros(1,num_of_top_k_matches);
                        %
                        %                 for kk=1:num_of_top_k_matches
                        %                     if isempty(find(idx_valid(:)==idx_sort_conf(kk))) == 0
                        %                     temp_idx(kk)=idx_valid(find(idx_valid(:)==idx_sort_conf(kk)));
                        %                     end
                        %                 end
                        %                 idx_valid = temp_idx(temp_idx > 0);
                        
                        
                        % computing top k-matches
                        num_of_top_k_matches = numel(pmatch.match(1,:));
                        [~,idx_sort_conf]=sort(confidenceA,'descend');
                        idx_sort_conf=idx_sort_conf(1:num_of_top_k_matches);
                        
                        [Lia,Locb] = ismember(idx_valid,idx_sort_conf);
                        idx=sort(Locb,'ascend');
                        idx=idx(idx>0);
                        
                        idx_temp=zeros(1,num_of_top_k_matches);
                        if isempty(Lia) == 0
                            idx_temp(idx)=idx_sort_conf(idx);
                        end
                        idx_valid = idx_temp(idx_temp > 0);
                        
                        
                        IoU_threshold = 0.3;
                        match_cand = [ idx_for_active_opA; idx_for_opB ];
                        id_true = false(numel(viewA.idx2ori),1);
                        for l=1:numel(idx_valid)
                            li = idx_valid(l);
                            id_true(li) = IoU2GT(match_cand(1,li),match_cand(2,li)) <= IoU_threshold;
                        end
                        
                        match = [ 1:numel(max_id); max_id'];
                        
                        hFig_match = figure(1); clf;
                        imgInput = appendimages( viewA.img, viewB.img, 'h' );
                        imshow(rgb2gray(imgInput)); hold on; iptsetpref('ImshowBorder','tight');
                        
                        fprintf(' - Visualizing results... \n');
                        showColoredMatches(viewA.frame, viewB.frame, match(:,idx_sort_conf(1:num_of_top_k_matches)),...
                            confidenceA(idx_sort_conf(1:num_of_top_k_matches)), 'offset', [ size(viewA.img,2) 0 ], 'mode', strVisMode);
                        pause;
                        clf;
                        
                        fprintf('   correct match / active proposal (threshold %.2f): %03d/%03d\n\n',IoU_threshold, nnz(id_true), AP.num_op_active(i));
                        
                        imshow(rgb2gray(imgInput)); hold on;
                        showColoredMatches(viewA.frame, viewB.frame, match(:,id_true),...
                            confidenceA(id_true), 'offset', [ size(viewA.img,2) 0 ], 'mode', strVisMode);
                        pause(0.1);
                        pause;
                        
                    end
                end
            end
        end
    end
end

