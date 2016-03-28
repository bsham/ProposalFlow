% script for evaluation proposal flow (PCR and mIoU@k)
% average over features
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function do_evaluation_avg(db_name)

evalc(['set_conf_', db_name]);

colorCode = makeColorCode(100);

% bins for plots
tbinv_PCR = linspace(0,1,101);
tbinv_mIoU = linspace(1,100,100);

for ft = 1:numel(conf.feature)
    
    eva_avg = struct([]);
    for fa = 1:numel(conf.algorithm)
        eva_avg(fa).method = func2str(conf.algorithm{fa});
        eva_avg(fa).histo_PCR = zeros(numel(tbinv_PCR),1);
        eva_avg(fa).histo_mIoU = zeros(numel(tbinv_mIoU),1);
        eva_avg(fa).color = colorCode(:,fa);
    end
    eva_avg(fa+1).method = 'Upper bound';
    eva_avg(fa+1).histo_PCR = zeros(numel(tbinv_PCR),1);
    eva_avg(fa+1).color = colorCode(:,fa+1);
    
    val_count=zeros(numel(tbinv_mIoU),1); %validate number of matches for histogram confidence
    
    for ci = 1:length(conf.class)
        
        load(fullfile(conf.evaPFDir, conf.class{ci},...
            [ conf.class{ci} '_' func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'eva');
        
        fprintf('processing %s feature for %s...\n',conf.feature{ft},conf.class{ci});
        
        % histogram for each class
        num_Nan = numel(isnan(eva(1).histo_mIoU));
        for fa = 1:numel(conf.algorithm)
            eva(fa).histo_mIoU(isnan(eva(fa).histo_mIoU)) = 0;
            eva_avg(fa).histo_PCR = eva_avg(fa).histo_PCR + eva(fa).histo_PCR;
            eva_avg(fa).histo_mIoU = eva_avg(fa).histo_mIoU + eva(fa).histo_mIoU;
        end
        eva_avg(fa+1).histo_PCR = eva_avg(fa+1).histo_PCR + eva(fa+1).histo_PCR;
        
        if numel(tbinv_mIoU)-num_Nan == 0
            val_count_idx = ones(numel(tbinv_mIoU),1);
        else
            val_count_idx = [ones(numel(dscore_sort_idx),1); zeros(numel(tbinv_mIoU)-num_Nan,1)];
        end
        val_count=val_count+val_count_idx;
    end
    
    for fa = 1:numel(eva)
        eva_avg(fa).histo_PCR = eva_avg(fa).histo_PCR./ length(conf.class);
    end
    for fa = 1:numel(eva)-1
        eva_avg(fa).histo_mIoU = eva_avg(fa).histo_mIoU ./ val_count;
    end
    
    
    fileID = fopen([conf.evaPFavgDir '/' func2str(conf.proposal) '-' conf.feature{ft} '.txt'],'w');
    fprintf(fileID,'%s: %s\n', func2str(conf.proposal), conf.feature{ft});
    fprintf(fileID,'\n%s\n', 'AuC of PCR plots');
    for fa=1:numel(eva_avg)
        fprintf(fileID, '%.2f\n',trapz(tbinv_PCR(1:end-1), cumsum(eva_avg(fa).histo_PCR(1:end-1))));
    end
    fprintf(fileID,'\n%s\n', 'AuC of mIoU@k plots');
    for fa=1:numel(eva_avg)-1
        fprintf(fileID, '%.2f\n',trapz(tbinv_mIoU(1:end), cumsum(eva_avg(fa).histo_mIoU(1:end))./tbinv_mIoU'));
    end
    
    fclose(fileID);
    
    save(fullfile(conf.evaPFavgDir, [ func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'eva_avg');
    
    % =========================================================================
    % plot evaluation
    % =========================================================================
    hFig=figure;
    set_figure;
    subplot(1,2,1);
    %set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
    set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
    hold on;
    for fa=1:numel(eva_avg)
        plot( tbinv_PCR(1:end-1), cumsum(eva_avg(fa).histo_PCR(1:end-1)),...
            '-', 'LineWidth', 3, ...
            'Color', eva_avg(fa).color, ...
            'MarkerSize', 7, ...
            'MarkerEdgeColor', eva_avg(fa).color,...
            'MarkerFaceColor', eva_avg(fa).color);
        method_name{fa} = eva_avg(fa).method;
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
    title('PCR plots');
    
    subplot(1,2,2);
    %set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
    set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
    hold on;
    for fa=1:numel(eva_avg)-1
        plot( tbinv_mIoU(1:end), cumsum(eva_avg(fa).histo_mIoU(1:end))./tbinv_mIoU',...
            '-', 'LineWidth', 3, ...
            'Color', eva_avg(fa).color, ...
            'MarkerSize', 7, ...
            'MarkerEdgeColor', eva_avg(fa).color,...
            'MarkerFaceColor', eva_avg(fa).color);
        method_name{fa} = eva_avg(fa).method;
    end
    xlabel('Number of top matches, k');
    ylabel('mIoU@k');
    axis([1, tbinv_mIoU(end), 0, 1]);
    set(gcf, 'Color', 'w');
    legend(method_name,'Location','northeast');
    %set(gca,'XTick',0:0.2:tbinv(end)); %<- Still need to manually specific tick marks
    set(gca,'YTick',0:0.2:1); %<- Still need to manually specific tick marks
    grid on
    title('mIoU@k plots');
    
    
    figure_name = [conf.evaPFavgDir '/' func2str(conf.proposal) '-' conf.feature{ft} '.pdf'];
    print(hFig,figure_name, '-dpdf');
    close(hFig);
end
