% script for extracting valid object proposals
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function do_ext_active_proposal(db_name)
% close all; clear;
% warning('off', 'all');
evalc(['set_conf_', db_name]);
bShowOP = false;

for ci = 1:numel(conf.class)
    
    % load the annotation file
    load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',conf.class{ci})), 'KP');
    nImage = length(KP.image_name);
    
    idx_for_active_op = cell(1,nImage);          % indices for valid object proposals
    idx_for_bbox_of_active_op = cell(1,nImage);  % indices for obj bounding box of valid object proposals
    num_op_all = zeros(1,nImage);                % number of object proposals
    
    for fi = 1:nImage
        anno_i = KP.image2anno{fi};
        
        % load proposals
        load(fullfile(conf.proposalDir,KP.image_dir{fi},...
            [ KP.image_name{fi}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'op');
        op.coords = op.coords';
        
        % find valid object proposals
        [ idx_op, idx_bb ] = crop_active_boxset(op.coords,...
            KP.bbox(:,anno_i), KP.part_x(:,anno_i), KP.part_y(:,anno_i), conf.threshold_intersection);
        idx_for_active_op{fi} = idx_op;
        idx_for_bbox_of_active_op{fi} = anno_i(idx_bb);
        num_op_all(fi) = size(op.coords,2);
        
        
        % =========================================================================
        % visualization for active boxset colocoded according to their NN
        % keypoints
        % =========================================================================
        if bShowOP
            colorCode = makeColorCode(100);
            
            img=imread(fullfile(conf.datasetDir,KP.image_dir{fi},KP.image_name{fi}));
            clf; imshow(img); hold on;
            center = 0.5 * (op.coords(1:2,idx_op)+op.coords(3:4,idx_op));
            for k=1:length(idx_op)
                part_x = KP.part_x(:,anno_i);
                part_y = KP.part_y(:,anno_i);
                npart = size(part_x,1);
                [ ~, idm ] = min(sum(([ part_x(:) part_y(:) ]'  - repmat(center(:,k),1,numel(part_x))).^2,1));
                drawboxline(op.coords(:,idx_op(k)),'color',colorCode(:,mod(idm-1,npart)+1));
            end
            pause;
        end
        % =========================================================================
        
    end
    
    % save indices for active object proposals and corresponding object bounding box
    AP.idx_for_active_op = idx_for_active_op;
    AP.idx_for_bbox_of_active_op = idx_for_bbox_of_active_op;
    AP.num_op_all = num_op_all;
    save(fullfile(conf.benchmarkDir,sprintf('AP_%s.mat',conf.class{ci})), 'AP');
    
    %fprintf('%d\n', sum(cellfun('length',RC.idx_for_active_op)));
    %fprintf('%d\n',sum(RC.num_op_all));
    
end
