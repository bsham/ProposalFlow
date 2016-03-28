% script for evaluating dense flow field
% written by Bumsub Ham, Inria - WILLOW / ENS, Paris, France

function do_dense_flow_evaluation(db_name)
set_path;
evalc(['set_conf_', db_name]);

colorCode = makeColorCode(100);

% bins for plots
tbinv = linspace(0,1,101);

%loop through features
for ft = 1:numel(conf.feature)
    
    avg_PCK = struct([]);
    for fa = 1:numel(conf.algorithm)
        avg_PCK(fa).method = func2str(conf.algorithm{fa});
        avg_PCK(fa).histo = zeros(numel(tbinv),1);
        avg_PCK(fa).color = colorCode(:,fa);
    end
    
    for ci = 1:length(conf.class)
        
        fprintf('processing %s...\n',conf.class{ci});
        
        % load the annotation file
        load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',conf.class{ci})), 'KP');
        nImage = length(KP.image_name);
        nAnno = size(KP.part_x,2);
        
        % histogram for each class
        PCK = struct([]);
        for fa = 1:numel(conf.algorithm)
            PCK(fa).method = func2str(conf.algorithm{fa});
            PCK(fa).histo = zeros(numel(tbinv),1);
            PCK(fa).color = colorCode(:,fa);
        end
        
        for fi = 1:nImage
            fprintf('%03d/%03d\n', fi,nImage);
            
            % compare it to other images
            for fj = 1:nImage
                if fj==fi
                    continue;
                end
                
                for fa = 1:numel(conf.algorithm) % for each algorithm
                    % load matching results
                    load(fullfile(conf.flowDir,KP.image_dir{fi},conf.feature{ft},...
                        [ KP.image_name{fi}(1:end-4) '-' KP.image_name{fj}(1:end-4)...
                        '_' func2str(conf.proposal) '_' conf.feature{ft} '_' func2str(conf.algorithm{fa}) '.mat' ]), 'dmatch');
                    
                    PCK2GT = zeros(min(numel(KP.part_x(:,fi)),numel(KP.part_x(:,fj))),1);
                    
                    vx=dmatch.vx;
                    vy=dmatch.vy;
                    
                    for k=1:numel(PCK2GT)
                        px=round(KP.part_x(k, fi));
                        py=round(KP.part_y(k, fi));
                        
                        PCK2GT(k) = (KP.part_x(k, fi)+vx(py,px)-KP.part_x(k, fj))^2+(KP.part_y(k, fi)+vy(py,px)-KP.part_y(k, fj))^2;
                    end
                    PCK2GT=sqrt(PCK2GT);
                    PCK2GT=PCK2GT./max(KP.bbox(3:4,fj) - KP.bbox(1:2,fj));
                    
                    bin_PCK = vl_binsearch(tbinv, double(PCK2GT));
                    for p=1:numel(bin_PCK)
                        PCK(fa).histo(bin_PCK(p)) = PCK(fa).histo(bin_PCK(p)) + 1.0/numel(PCK2GT);
                    end
                end
            end
        end
        
        for fa = 1:numel(PCK)
            PCK(fa).histo = PCK(fa).histo ./ (nImage*(nImage-1));
        end
        
        fprintf('%d images, %d annotations processed.\n',nImage, nAnno);
        
        fileID = fopen(fullfile(conf.evaDFDir,[ conf.class{ci} '-' func2str(conf.proposal) '-' conf.feature{ft} '.txt']),'w');
        fprintf(fileID,'%s\n', conf.class{ci});
        
        fprintf(fileID,'\n%s\n', 'PCK (alpha=0.05)');
        for fa=1:numel(PCK)
            fprintf(fileID, '%.2f\n',max(cumsum(PCK(fa).histo(1:5))) );
        end
        fprintf(fileID,'\n%s\n', 'PCK (alpha=0.1)');
        for fa=1:numel(PCK)
            fprintf(fileID, '%.2f\n',max(cumsum(PCK(fa).histo(1:10))) );
        end
        fprintf(fileID,'\n%s\n', 'PCK (alpha=0.2)');
        for fa=1:numel(PCK)
            fprintf(fileID, '%.2f\n',max(cumsum(PCK(fa).histo(1:20))) );
        end
        fclose(fileID);
        
        save(fullfile(conf.evaDFDir, conf.class{ci},...
            [ conf.class{ci} '_' func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'PCK');
        
        
        %average
        for fa = 1:numel(conf.algorithm)
            avg_PCK(fa).histo = avg_PCK(fa).histo+PCK(fa).histo;
        end
    end
    
    for fa = 1:numel(conf.algorithm)
        avg_PCK(fa).histo = avg_PCK(fa).histo ./ length(conf.class);
    end
    
    fileID = fopen(fullfile(conf.evaDFavgDir,[ func2str(conf.proposal) '-' conf.feature{ft} '.txt']),'w');
    fprintf(fileID,'%s: %s\n', func2str(conf.proposal), conf.feature{ft});
    fprintf(fileID,'\n%s\n', 'PCK (alpha=0.05)');
    for fa=1:numel(avg_PCK)
        fprintf(fileID, '%.2f\n',max(cumsum(avg_PCK(fa).histo(1:5))) );
    end
    fprintf(fileID,'\n%s\n', 'PCK (alpha=0.1)');
    for fa=1:numel(avg_PCK)
        fprintf(fileID, '%.2f\n',max(cumsum(avg_PCK(fa).histo(1:10))) );
    end
    fprintf(fileID,'\n%s\n', 'PCK (alpha=0.2)');
    for fa=1:numel(avg_PCK)
        fprintf(fileID, '%.2f\n',max(cumsum(avg_PCK(fa).histo(1:20))) );
    end
    fclose(fileID);
    
    save(fullfile(conf.evaDFavgDir, [ func2str(conf.proposal) '_' conf.feature{ft} '.mat' ]), 'avg_PCK');
end

