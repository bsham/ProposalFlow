% script for evaluation proposal flow (PCR and mIoU@k)
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function do_evaluation(db_name)

evalc(['set_conf_', db_name]);

colorCode = makeColorCode(100);
ShowMatch = false;

% bins for plots
tbinv_PCR = linspace(0,1,101);
tbinv_mIoU = linspace(1,100,100);

%loop through features
for ft = 1:numel(conf.feature)
    
    for ci = 1:numel(conf.class)
        
        fprintf('processing %s feature for %s...\n',conf.feature{ft},conf.class{ci});
        
        % load the annotation file
        load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',conf.class{ci})), 'KP');
        load(fullfile(conf.benchmarkDir,sprintf('AP_%s.mat',conf.class{ci})), 'AP');
        nImage = length(KP.image_name);
        
        % histogram for each class
        eva = struct([]);
        
        for fa = 1:numel(conf.algorithm)
            eva(fa).method = func2str(conf.algorithm{fa});
            eva(fa).histo_PCR = zeros(numel(tbinv_PCR),1);
            eva(fa).histo_mIoU = zeros(numel(tbinv_mIoU),1);
            eva(fa).color = colorCode(:,fa);
        end
        eva(fa+1).method = 'Upper bound';
        eva(fa+1).histo_PCR = zeros(numel(tbinv_PCR),1);
        eva(fa+1).color = colorCode(:,fa+1);
        
        val_count=zeros(numel(tbinv_mIoU),1); %validate number of matches for histogram confidence
        
        for fi = 1:nImage
            
            fprintf('%03d/%03d\n', fi,nImage);
            
            idx_for_active_opA = zeros(1,AP.num_op_all(fi),'int32');
            % indexing candidate proposals (GT) for evaluation (original index to
            % current index)
            idx_for_active_opA(AP.idx_for_active_op{fi}) = 1:numel(AP.idx_for_active_op{fi});
            
            % compare it to other images
            for fj = 1:nImage
                if fj==fi
                    continue;
                end
                
                % load ground truth results
                load(fullfile(conf.matchGTDir,KP.image_dir{fi},...
                    [ KP.image_name{fi}(1:end-4) '-' KP.image_name{fj}(1:end-4)...
                    '_' func2str(conf.proposal) '.mat' ]), 'IoU2GT');
                
                for fa = 1:numel(conf.algorithm) % for each algorithm
                    
                    % load matching results
                    load(fullfile(conf.matchDir,KP.image_dir{fi},conf.feature{ft},...
                        [ KP.image_name{fi}(1:end-4) '-' KP.image_name{fj}(1:end-4)...
                        '_' func2str(conf.proposal) '_' conf.feature{ft} '_' func2str(conf.algorithm{fa}) '.mat' ]), 'pmatch');
                    
                    % indexing all the condidate proposals in image A w.r.t
                    % candidate proposals (GT) in image B
                    idx_eva_opA = idx_for_active_opA(pmatch.match(1,:));
                    
                    %indices (image A) for valid matches w.r.t. pmatch.match(1,:)
                    idx_valid_op = find(idx_eva_opA > 0);
                    
                    % indices (image B) for valid matches
                    idx_eva_opB = pmatch.match(2,:);
                    
                    % candidate matches
                    idx_active_match = [ idx_eva_opA(idx_valid_op); idx_eva_opB(idx_valid_op) ];
                    
                    % consider valid matching
                    dIoU = Inf(numel(idx_valid_op),1);
                    
                    for l=1:size(idx_active_match,2)
                        if idx_active_match(2,l) > 0
                            dIoU(l) = IoU2GT(idx_active_match(1,l),idx_active_match(2,l));
                        end
                    end
                    
                    dscore = pmatch.match_confidence(idx_valid_op);
                    [~, idx_dscore_sort] = sort(dscore,'descend');
                    
                    % consider valid matches
                    dIoU_sort = [dIoU(idx_dscore_sort); ones(numel(tbinv_mIoU)-numel(idx_dscore_sort),1)];
                    
                    bin_PCR = vl_binsearch(tbinv_PCR, double(dIoU));
                    for p=1:numel(bin_PCR)
                        eva(fa).histo_PCR(bin_PCR(p)) = eva(fa).histo_PCR(bin_PCR(p)) + 1.0/numel(dIoU);
                    end
                    for p=1:numel(tbinv_mIoU)
                        eva(fa).histo_mIoU(tbinv_mIoU(p)) = eva(fa).histo_mIoU(tbinv_mIoU(p)) + (1-dIoU_sort(p));
                    end
                end
                
                % =========================================================================
                % visualization matching results for each algorithm and
                % upper-bound match.
                % =========================================================================
                
                if ShowMatch
                    load(fullfile(conf.proposalDir, KP.image_dir{fi},...
                        [ KP.image_name{fi}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'op');
                    op.coords = op.coords';
                    opA = op;
                    coords_opA = opA.coords; %coordinates for upper left and lower right points
                    
                    load(fullfile(conf.proposalDir, KP.image_dir{fj},...
                        [ KP.image_name{fj}(1:end-4) '_' func2str(conf.proposal) '.mat' ]), 'op');
                    op.coords = op.coords';
                    opB = op;
                    coords_opB = opB.coords; %coordinates for upper left and lower right points
                    
                    Ii=imread(fullfile(conf.datasetDir,KP.image_dir{fi},KP.image_name{fi}));
                    Ij=imread(fullfile(conf.datasetDir,KP.image_dir{fj},KP.image_name{fj}));
                    imout = appendimages(Ii,Ij);
                    
                    [scr_UB,idx_UB]=min(IoU2GT,[],2);
                    
                    for ki=1:10:numel(idx_valid_op)
                        clf; figure(1);imshow(rgb2gray(imout)); hold on;
                        fprintf('\npart: %d/%d\n', ki,length(idx_valid_op));
                        % candidate box in reference image
                        li = idx_valid_op(ki);
                        
                        for fa = 1:numel(conf.algorithm) % for each algorithm
                            load(fullfile(conf.matchDir,KP.image_dir{fi},...
                                [ KP.image_name{fi}(1:end-4) '-' KP.image_name{fj}(1:end-4)...
                                '_' func2str(conf.proposal) '_' conf.feature{ft} '_' func2str(conf.algorithm{fa}) '.mat' ]), 'pmatch');
                            % transform current indices to candidate indices
                            % indexing all the condidate boxes in reference image w.r.t candidate boxes (GT) in reference image
                            idx_eva_opA = idx_for_active_opA(pmatch.match(1,:));
                            %indices (reference image) for valid matches w.r.t. rmatch.match(1,:)
                            idx_valid_op = find(idx_eva_opA > 0);
                            % indices (target image) for valid matches
                            idx_eva_opB = pmatch.match(2,:);
                            
                            idx_active_match = [ idx_eva_opA(idx_valid_op); idx_eva_opB(idx_valid_op) ];
                            
                            drawboxline(coords_opA(:,pmatch.match(1,li)),'LineWidth',4,'color',[255/255,215/255,0]);
                            
                            drawboxline(coords_opB(:,idx_active_match(2,ki)),'LineWidth',4,'color',colorCode(:,fa),'offset',[size(Ii,2) 0 ]);
                            fprintf('1-overlap score score (matched) - %s: %f\n', func2str(conf.algorithm{fa}), IoU2GT(idx_active_match(1,ki),idx_active_match(2,ki)));
                            h=text(double(10+size(Ii,2)),20+(fa-1)*20,[func2str(conf.algorithm{fa}) ': ' num2str(IoU2GT(idx_active_match(1,ki),idx_active_match(2,ki)))]);
                            h.FontSize = 14;
                            h.BackgroundColor = colorCode(:,fa);
                        end
                        drawboxline(coords_opB(:,idx_UB(idx_active_match(1,ki))),'LineWidth',4,'color',[255/255,215/255,0],'offset',[size(Ii,2) 0 ]);
                        h=text(double(10+size(Ii,2)),20+fa*20,['upper bound: ' num2str(scr_UB(idx_active_match(1,ki)))]);
                        h.FontSize = 14;
                        h.BackgroundColor = [255/255,215/255,0];
                        
                        fprintf('1-overlap score (upperbound): %f\n', scr_UB(idx_active_match(1,ki)));
                        pause;
                        
                    end
                end
                
                if numel(idx_dscore_sort) > numel(tbinv_mIoU)
                    val_count_idx = ones(numel(tbinv_mIoU),1);
                else
                    val_count_idx = [ones(numel(idx_dscore_sort),1); zeros(numel(tbinv_mIoU)-numel(idx_dscore_sort),1)];
                end
                val_count=val_count+val_count_idx;
                
                % upper bound
                dIoU2GT = IoU2GT(idx_eva_opA(idx_valid_op),:);
                bin_upper_IoU = vl_binsearch(tbinv_PCR, double(min(dIoU2GT,[],2)));
                for p=1:size(dIoU2GT,1)
                    eva(end).histo_PCR(bin_upper_IoU(p)) = eva(end).histo_PCR(bin_upper_IoU(p)) + 1.0/numel(bin_upper_IoU);
                end
            end
        end
        
        for fa = 1:numel(eva)
            eva(fa).histo_PCR = eva(fa).histo_PCR ./ (nImage*(nImage-1));
        end
        for fa = 1:numel(eva)-1
            eva(fa).histo_mIoU = eva(fa).histo_mIoU ./ val_count;
        end
        
        fprintf('%d images processed.\n',nImage);
        
        
        fileID = fopen([conf.evaPFDir '/' conf.class{ci} '-' func2str(conf.proposal) '-' conf.feature{ft} '.txt'],'w');
        fprintf(fileID,'%s\n', conf.class{ci});
        fprintf(fileID,'\n%s\n', 'AuC of PCR plots');
        for fa=1:numel(eva)
            fprintf(fileID, '%.2f\n',trapz(tbinv_PCR(1:end-1), cumsum(eva(fa).histo_PCR(1:end-1))));
        end
        fprintf(fileID,'\n%s\n', 'AuC of mIoU@k plots');
        for fa=1:numel(eva)-1
            fprintf(fileID, '%.2f\n',trapz(tbinv_mIoU(1:end), cumsum(eva(fa).histo_mIoU(1:end))./tbinv_mIoU'));
        end
        
        fclose(fileID);
        
        save(fullfile(conf.evaPFDir, conf.class{ci},...
            [ conf.class{ci} '_' func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'eva');
        
        
        % =========================================================================
        % plot evaluation
        % =========================================================================
        hFig=figure;
        set_figure;
        subplot(1,2,1);
        %set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
        set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
        hold on;
        for fa=1:numel(eva)
            plot( tbinv_PCR(1:end-1), cumsum(eva(fa).histo_PCR(1:end-1)),...
                '-', 'LineWidth', 3, ...
                'Color', eva(fa).color, ...
                'MarkerSize', 7, ...
                'MarkerEdgeColor', eva(fa).color,...
                'MarkerFaceColor', eva(fa).color);
            method_name{fa} = eva(fa).method;
        end
        xlabel('IoU threshold');
        ylabel('PCR');
        axis([0, tbinv_PCR(end), 0, 1]);
        set(gcf, 'Color', 'w');
        legend(method_name,'Location','northwest');
        
        %xlim([-pi pi]);
        set(gca,'XTick',0:0.2:tbinv_PCR(end)); %<- Still need to manually specific tick marks
        set(gca,'YTick',0:0.2:1); %<- Still need to manually specific tick marks
        grid on
        title('PCR plots (IoU)');
        
        subplot(1,2,2);
        %set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
        set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
        hold on;
        for fa=1:numel(eva)-1
            plot( tbinv_mIoU(1:end), cumsum(eva(fa).histo_mIoU(1:end))./tbinv_mIoU',...
                '-', 'LineWidth', 3, ...
                'Color', eva(fa).color, ...
                'MarkerSize', 7, ...
                'MarkerEdgeColor', eva(fa).color,...
                'MarkerFaceColor', eva(fa).color);
            method_name{fa} = eva(fa).method;
        end
        xlabel('Number of top matches, k');
        ylabel('mIoU@k');
        axis([1, tbinv_mIoU(end), 0, 1]);
        set(gcf, 'Color', 'w');
        legend(method_name,'Location','northeast');
        %set(gca,'XTick',0:0.2:tbinv_PCR(end)); %<- Still need to manually specific tick marks
        set(gca,'YTick',0:0.2:1); %<- Still need to manually specific tick marks
        grid on
        title('mIoU@k plots');
        
        figure_name = [conf.evaPFDir '/' conf.class{ci} '-' func2str(conf.proposal) '-' conf.feature{ft} '.pdf'];
        print(hFig,figure_name, '-dpdf');
        close(hFig);
    end
end

