% script for making GT data based on the annotations and the proposals
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function makeGT_WILLOW()

global conf;
global tps_interp;

ShowGT = false;

for ci = 1:numel(conf.class)
    
    fprintf('processing %s...\n',conf.class{ci});
    
    % load the annotation file
    load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',conf.class{ci})), 'KP');
    nImage = length(KP.image_name);
    nAnno = size(KP.part_x,2);
    
    % load the indices of valid object proposals and corresponding object bounding box
    load(fullfile(conf.benchmarkDir,sprintf('AP_%s.mat',conf.class{ci})), 'AP');
    idx_for_active_op=AP.idx_for_active_op;             % indices for valid object proposals
    idx_for_bbox_of_active_op=AP.idx_for_bbox_of_active_op;     % indices for obj bounding box of valid object proposals
    
    
    for fi = 1:nImage
        imgA=imread(fullfile(conf.datasetDir,KP.image_dir{fi},KP.image_name{fi}));
        imgA_height=size(imgA,1);imgA_width=size(imgA,2);
        
        % load proposals
        load(fullfile(conf.proposalDir,KP.image_dir{fi},...
            [ KP.image_name{fi}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'op');
        op.coords = op.coords';
        opA = op;
        
        idx_for_active_opA = idx_for_active_op{fi};
        idx_for_bbox_of_active_opA = idx_for_bbox_of_active_op{fi};
          
        %coordinates for upper left and lower right points of active proposals 
        coords_for_active_opA = opA.coords(:,idx_for_active_opA); 
        
        annoA = KP.image2anno{fi};
        part_x_A = KP.part_x(:,annoA);
        part_y_A = KP.part_y(:,annoA);
        
        % indices for coords_for_active_opA (clock-wise)
        xy_idx = zeros(4, size(coords_for_active_opA,2));
        xy_idx(1,:) =  sub2ind([imgA_width,imgA_height],coords_for_active_opA(1,:),coords_for_active_opA(2,:));
        xy_idx(2,:) =  sub2ind([imgA_width,imgA_height],coords_for_active_opA(3,:),coords_for_active_opA(2,:));
        xy_idx(3,:) =  sub2ind([imgA_width,imgA_height],coords_for_active_opA(3,:),coords_for_active_opA(4,:));
        xy_idx(4,:) =  sub2ind([imgA_width,imgA_height],coords_for_active_opA(1,:),coords_for_active_opA(4,:));
        
        % compare it to other images
        for fj = 1:nImage
            if fj==fi
                continue;
            end
            imgB=imread(fullfile(conf.datasetDir,KP.image_dir{fj},KP.image_name{fj}));
            imgB_height=size(imgB,1);imgB_width=size(imgB,2);
            
            % load proposals
            load(fullfile(conf.proposalDir, KP.image_dir{fj},...
                [ KP.image_name{fj}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'op');
            op.coords = op.coords';
            opB = op;
            
            annoB = KP.image2anno{fj};
            part_x_B = KP.part_x(:,annoB);
            part_y_B = KP.part_y(:,annoB);
            
            % =========================================================================
            % TPS warping using keypoints in image A and B
            % =========================================================================
            [coords_warped_opA_y, coords_warped_opA_x, imgW, imgWr]  = ...
                tpswarp(imgA,[imgB_width imgB_height],[double(part_y_A) double(part_x_A)],[double(part_y_B) double(part_x_B)],tps_interp); % thin plate spline warping
        
            % revising warped coordinates out of the image frame
            coords_warped_opA_x = max(min(round(coords_warped_opA_x),imgB_width),1);
            coords_warped_opA_y = max(min(round(coords_warped_opA_y),imgB_height),1);
            
            % x,y coordinates for (warped) points from image A (clock-wise)
            coords_warped_opA = [coords_warped_opA_x(xy_idx(1,:)), coords_warped_opA_y(xy_idx(1,:)),...
                coords_warped_opA_x(xy_idx(2,:)), coords_warped_opA_y(xy_idx(2,:)),...
                coords_warped_opA_x(xy_idx(3,:)), coords_warped_opA_y(xy_idx(3,:)),...
                coords_warped_opA_x(xy_idx(4,:)), coords_warped_opA_y(xy_idx(4,:))]';
            
           
            % ground truth (tight rectangular boxes, computed by averaging coordinates)  
            coords_GT_opA_x = sort([coords_warped_opA_x(xy_idx(1,:)),coords_warped_opA_x(xy_idx(2,:)),...
                coords_warped_opA_x(xy_idx(3,:)),coords_warped_opA_x(xy_idx(4,:))]');
            coords_GT_opA_y = sort([coords_warped_opA_y(xy_idx(1,:)),coords_warped_opA_y(xy_idx(2,:)),...
                coords_warped_opA_y(xy_idx(3,:)),coords_warped_opA_y(xy_idx(4,:))]');
            coords_GT_opA = [(coords_GT_opA_x(1,:)+coords_GT_opA_x(2,:))./2;...
                (coords_GT_opA_y(1,:)+coords_GT_opA_y(2,:))./2;...
                (coords_GT_opA_x(3,:)+coords_GT_opA_x(4,:))./2;...
                (coords_GT_opA_y(3,:)+coords_GT_opA_y(4,:))./2];
            
            % revising coordinates of ground truth out of the image frame
            coords_GT_opA(1,:)=max(min(coords_GT_opA(1,:),imgB_width),1);
            coords_GT_opA(2,:)=max(min(coords_GT_opA(2,:),imgB_height),1);
            coords_GT_opA(3,:)=max(min(coords_GT_opA(3,:),imgB_width),1);
            coords_GT_opA(4,:)=max(min(coords_GT_opA(4,:),imgB_height),1);
            
            %convert bbox [xmin ymin xmax ymax] to [x y width hieght]
            coords_GT_opA_xywh = [coords_GT_opA(1,:);coords_GT_opA(2,:);...
                coords_GT_opA(3,:)-coords_GT_opA(1,:)+1;coords_GT_opA(4,:)-coords_GT_opA(2,:)+1];
            coords_opB_xyhw=[opB.coords(1,:);opB.coords(2,:);...
                opB.coords(3,:)-opB.coords(1,:)+1;opB.coords(4,:)-opB.coords(2,:)+1];
            
            
            % =========================================================================
            % compute IoU between GT of obj propoasl in image A and all obj proposals in image B
            % =========================================================================
            IoU2GT = 1-bboxOverlapRatio(coords_GT_opA_xywh', coords_opB_xyhw', 'Union');
            
            % =========================================================================
            % visualization ground truth for each object proposal in image A
            % =========================================================================
            if ShowGT
                colorCode = makeColorCode(100);
                
                % show warped image (from image A to B)
                warpout = appendimages(uint8(imgWr),uint8(imgW));
                clf(figure(1),'reset')
                figure(1);
                imshow(warpout);hold on;
                
                numOfPlot = 1;
                [score_IoU, idx_IoU] = sort(IoU2GT,2);
                
                imout = appendimages(imgA,imgB);
                
                for ki=1:10:length(idx_for_active_opA)
                    clf(figure(2),'reset');
                    figure(2);imshow(rgb2gray(imout)); hold on;
                    
                    % show keypoints in image A and B
                    for k = 1:length(annoA)
                        ai = annoA(k);
                        pids = find(KP.part_visible(:,ai));
                        for kp=1:length(pids)
                            pid = pids(kp);
                            plot(KP.part_x(pid, ai),KP.part_y(pid, ai),'o','MarkerEdgeColor','k',...
                                'MarkerFaceColor',colorCode(:,pid),'MarkerSize', 20);
                        end
                    end
                    for k = 1:length(annoB)
                        aj = annoB(k);
                        pids = find(KP.part_visible(:,aj));
                        for kp=1:length(pids)
                            pid = pids(kp);
                            plot(KP.part_x(pid, aj)+size(imgA,2),KP.part_y(pid, aj),'o','MarkerEdgeColor','k',...
                                'MarkerFaceColor',colorCode(:,pid),'MarkerSize', 20);
                        end
                    end
                    
                    fprintf('\npart: %d/%d\n', ki,length(idx_for_active_opA));
                    
                    % show each valid proposal in image A
                    drawboxline(opA.coords(:,idx_for_active_opA(ki)),'LineWidth',4,'color',[255/255,215/255,0]);
                    
                    % candidate proposals in image B (ranked w.r.t 1-IoU, control parameter = numOfPlot)
                    % for numOfPlot=1, upperbound match
                    for kj=1:numOfPlot
                        % box
                        drawboxline(opB.coords(:,idx_IoU(ki,kj)),'LineWidth',4,'color',colorCode(:,kj),'offset',[ size(imgA,2) 0 ]);
                        h=text(double(10+size(imgA,2)),20,['1-overlap score: ' num2str(score_IoU(ki,kj))]);
                        h.FontSize = 14;
                        h.BackgroundColor = colorCode(:,kj);
                        
                        fprintf('1-overlap score (%d): %f \n', kj, score_IoU(ki,kj));
                    end
                    
                    % show warped proposals from image A
                    drawpolygon(coords_warped_opA(:,ki),'LineWidth',4,'color',[255/255,215/255,0],'offset',[size(imgA,2) 0 ]);
                    h=text(double(10),double(size(imgB,1)-45),'warped obj box');
                    h.FontSize = 12;
                    h.BackgroundColor = [255/255,215/255,0];
                    
                    % show ground truths 
                    drawboxline(coords_GT_opA(:,ki),'LineWidth',4,'color',[0,1,0],'offset',[ size(imgA,2) 0 ]);
                    h=text(double(101),double(size(imgB,1)-45),'ground truth');
                    h.FontSize = 12;
                    h.BackgroundColor = [0,1,0];
                    
                    h=text(double(10),double(size(imgB,1)-25),'upper bound box for overlap score');
                    h.FontSize = 12;
                    h.BackgroundColor = colorCode(:,kj);
                   
                    pause;
                end
            end
            
            %save 1-IoU scores for all possible matches between GT and obj proposals in image B
            save(fullfile(conf.matchGTDir,KP.image_dir{fi},[ KP.image_name{fi}(1:end-4) ...
                '-' KP.image_name{fj}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'IoU2GT');
        end
        fprintf('%d/%d processed.\n',fi, nImage);
    end
    fprintf('%d images, %d annotations processed.\n',nImage, nAnno);
end

end
