function show_pos_list(pos)
figure;



for k=1:numel(pos)
	fprintf('%d:%s\n', k, pos(k).im);
	im=imread(pos(k).im);
	if(isfield(pos, 'flipped'))
	if(pos(k).flipped)
		pos(k).flipped
		sz=size(im);
		w=pos(k).x2-pos(k).x1;
		pos(k).x1=sz(2)-pos(k).x2;
		%pos(k).y1=sz(1)/2-pos(k).y1;
		pos(k).x2=pos(k).x1+w;
		%pos(k).y2=sz(1)/2-pos(k).y2;
		im=im(:,end:-1:1,:);	
	end
	end
	showboxes(im,[pos(k).x1 pos(k).y1 pos(k).x2 pos(k).y2]);
	pause;
end
