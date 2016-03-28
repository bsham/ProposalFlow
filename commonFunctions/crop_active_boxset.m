function [ idx_sel idx_bbox ] = crop_active_boxset( boxfull, bbox, part_x, part_y, threshold_intersection)
% crop a subset of active boxes based on bounding boxes 

centerfull = 0.5*(boxfull(1:2,:) + boxfull(3:4,:));
rectA = box2rect(boxfull); % x, y, w, h
areaA = rectA(3,:).*rectA(4,:); % w * h
rect_s = box2rect(bbox);
%area_s = rect_s(3,:).*rect_s(4,:);
area_int = rectint(rect_s',rectA');
id_sel = false(1,size(boxfull,2));
idx_bbox = zeros(1,size(boxfull,2),'uint16');

% find boxes whose centers lie within the bounding box
for p=1:size(bbox,2)
    IOA = area_int(p,:) ./ areaA; % area intersection ratio (included vs. box)
%    id_center_included = ( centerfull(1,:) >= bbox(1,p) )...
%        & ( centerfull(1,:) <= bbox(3,p) )...
%        & ( centerfull(2,:) >= bbox(2,p) )...
%        & ( centerfull(2,:) <= bbox(4,p) );
    id_valid = IOA > threshold_intersection;
    id_sel(id_valid) = true;
    idx_bbox(id_valid) = p;
end
tmp_sel = find(id_sel);

idx_sel = [];
%idx_nn = [];
% suppress boxes covering no keypoint
for i=1:length(tmp_sel)
    id_valid = ( part_x(:) >= boxfull(1,tmp_sel(i)) )...
        & ( part_x(:) <= boxfull(3,tmp_sel(i)) )...
        & ( part_y(:) >= boxfull(2,tmp_sel(i)) )...
        & ( part_y(:) <= boxfull(4,tmp_sel(i)) );
    if any(id_valid)            
        %center = 0.5 * (boxfull(1:2,tmp_sel(i))+boxfull(3:4,tmp_sel(i)));
        %[ tmp, idm ] = min(sum((points_cover - repmat(center,1,size(points_cover,2))).^2,1));
        idx_sel = [ idx_sel tmp_sel(i) ];
        %idx_nn = [ idx_nn idm ];
    end
end

idx_sel = uint16(idx_sel); 
idx_bbox = idx_bbox(idx_sel);