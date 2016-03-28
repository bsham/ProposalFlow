function do_prepKP_RSF( )
% transform raw keypoint annotations into my data
% by Minsu Cho, Inria - WILLOW / ENS

set_conf_RSF;

classes = conf.class;

for ci = 1:length(classes)
    
    ims = dir(fullfile(conf.annoKPDir, classes{ci}, '*.png'));
    
    fprintf('processing %s...',classes{ci});
    
    image_dir = cell(1,1); image_name = cell(1,1); image2anno = cell(1,1); anno2image = [];
    part_list = cell(1,1); part_hist = zeros(1,1); npart = 0;
    %sub_list = cell(1,1); sub_hist = zeros(1,1); nsub = 0;
    
    load(fullfile(conf.annoKPDir, classes{ci}, [ims(1).name(1:end-4) '.mat']), 'pts_coord');
    npart = size(pts_coord,2);
    for fp = 1:npart
        part_list{fp} = [ 'part_' char(64+fp) ];
    end
    for fi = 1:length(ims)
        image_dir{fi} = classes{ci};
        image_name{fi} = ims(fi).name;
        image2anno{fi} = fi;
        anno2image(fi) = fi;
    end
    
    part_visible = true(length(part_list), length(ims));
    bbox = zeros(4, length(ims),'single');
    part_x = zeros(length(part_list), length(ims),'single');
    part_y = zeros(length(part_list), length(ims),'single');
    part_z = zeros(length(part_list), length(ims),'single');
    
    for fi = 1:length(ims)
        load(fullfile(conf.annoKPDir, classes{ci}, [ims(fi).name(1:end-4) '.mat']), 'pts_coord');
        bbox(:,fi) = [ min(pts_coord(1,:)) min(pts_coord(2,:))...
            max(pts_coord(1,:)) max(pts_coord(2,:)) ]';
        
        if size(pts_coord,2) == npart
            part_x(:, fi) = pts_coord(1,:)';
            part_y(:, fi) = pts_coord(2,:)';
            part_z(:, fi) = zeros(size(pts_coord,2),1);
        else
            nt = size(pts_coord,2);
            part_x(1:nt, fi) = pts_coord(1,:)';
            part_y(1:nt, fi) = pts_coord(2,:)';
            part_z(1:nt, fi) = zeros(size(pts_coord,2),1);
            fprintf('%s file error!\n',ims(fi).name);
        end
        
    end
    
    KP.image_dir = image_dir;
    KP.image_name = image_name;
    KP.image2anno = image2anno;
    KP.anno2image = anno2image;
    KP.part_list = part_list;
    %KP.sub_list = sub_list;
    %KP.sub_index = sub_index;
    KP.part_visible = part_visible;
    KP.bbox = bbox;
    KP.part_x = part_x;
    KP.part_y = part_y;
    KP.part_z = part_z;
    save(fullfile(conf.benchmarkDir,sprintf('KP_%s.mat',classes{ci})), 'KP');
    fprintf('%d annotations processed\n',fi);
end



