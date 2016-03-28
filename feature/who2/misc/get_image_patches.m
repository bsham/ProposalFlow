function [imgs, dims]=get_image_patches(pos)
load(bg_file_name);
model=initmodel('',pos, bg);
dims=model.maxsize*8;
for k=1:numel(pos)
	im=imread(pos(k).im);
    bx=ceil([pos(k).x1 pos(k).y1 pos(k).x2 pos(k).y2]);
    bx(1)=max(bx(1),1);
    bx(2)=max(bx(2),1);
    bx(3)=min(size(im,2),bx(3));
    bx(4)=min(size(im,1),bx(4));
    imtmp=im(bx(2):bx(4),bx(1):bx(3), :);
	if(isfield(pos, 'flipped'))
    if(pos(k).flipped)
        imtmp=imtmp(:,end:-1:1,:);
    end
	end
	imgs{k}=imresize(imtmp, dims);
end
