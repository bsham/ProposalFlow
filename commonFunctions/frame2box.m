function box = frame2box( frame )
% tranform boxes into frames

[D,K] = size(frame) ;
box = zeros(4,K) ;

box(1,:) = frame(1,:) - frame(3,:);
box(2,:)= frame(2,:) - frame(6,:);
box(3,:)= frame(1,:) + frame(3,:);
box(4,:)= frame(2,:) + frame(6,:);

end