function do_readKP_WILLOW()
% demo function to visualize the dataset images and their annotations
% by Minsu Cho, Inria - WILLOW / ENS 

close all;

set_path;
set_conf_WILLOW;


class = 'car(S)';
% load the annotation file
load(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',class)), 'KP'); 
nImage = length(KP.image_name);
nAnno = size(KP.part_x,2);
fprintf('%d images, %d annotations loaded\n',nImage, nAnno);    

colorCode = makeColorCode(100);

for fi = 1:nImage
    I=imread(fullfile(conf.datasetDir,class,KP.image_name{fi}));
    anno = KP.image2anno{fi};
    clf;
    imagesc(I); axis image;
    hold on;
    
    for j = 1:length(anno)
        
        ai = anno(j);
        plot(KP.bbox([1 3 3 1 1],ai), KP.bbox([2 2 4 4 2],ai),'m:','linewidth',2);
        pids = find(KP.part_visible(:,ai));
        for ki=1:length(pids)
            pid = pids(ki);
            plot(KP.part_x(pid, ai),KP.part_y(pid, ai),'o','MarkerEdgeColor','k',...
                'MarkerFaceColor',colorCode(:,pid),'MarkerSize', 10);
        end
        %axis image off;
        %title(sprintf('image: %d/%d: "%s" (red=difficult, T=truncated, O=occluded)',...
        %    fi,length(ims),fname),'interpreter','none');

        fprintf('press any key to continue with next image\n');
        %fprintf('%s %s: %2d/%2d keypoints \n',classes{ci}, fname, nkp, npart); 
        pause;
    end
end





end

function [ priorColorCode ] = makeColorCode( nCol )

priorColorCode(1,:) = [ 1 0 0 ]; 
priorColorCode(2,:) = [ 0 1 0 ]; 
priorColorCode(3,:) = [ 0 0 1 ]; 
priorColorCode(4,:) = [ 0 1 1 ]; 
priorColorCode(5,:) = [ 1 0 1 ]; 
priorColorCode(6,:) = [ 1 1 0 ]; 
priorColorCode(7,:) = [ 1 0.5 0 ]; 
priorColorCode(8,:) = [ 1 0 0.5 ]; 
priorColorCode(9,:) = [ 1 0.5 0.5 ]; 
priorColorCode(10,:) = [ 0.5 1 0 ]; 
priorColorCode(11,:) = [ 0 1 0.5 ]; 
priorColorCode(12,:) = [ 0.5 1 0.5 ]; 

nMore = nCol - size(priorColorCode,1);
if nMore > 0 
    priorColorCode(size(priorColorCode,1)+1:nCol,:) = rand(nMore, 3);
end

priorColorCode = priorColorCode';

end

