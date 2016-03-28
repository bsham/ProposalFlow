function frame = box2frame( box )
% tranform boxes into frames

[D,K] = size(box) ;
frame = zeros(6,K) ;

frame(1:2,:) = [(box(3, :) + box(1, :)) ./ 2; (box(4, :) + box(2, :)) ./ 2]; %[xc; yc]
frame(3,:) = box(3, :) - frame(1,:);
frame(6,:) = box(4, :) - frame(2,:);
end