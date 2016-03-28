function [ invframe, detA ] = inv_frame( frame1 )
% return inverse frames and determinants

invframe = zeros(size(frame1));
detA = frame1(3,:).*frame1(6,:)-frame1(5,:).*frame1(4,:);
invframe(1,:) = frame1(5,:).*frame1(2,:) - frame1(1,:).*frame1(6,:);
invframe(2,:) = frame1(1,:).*frame1(4,:) - frame1(3,:).*frame1(2,:);
invframe(3,:) = frame1(6,:);   invframe(4,:) = -frame1(4,:);
invframe(5,:) = -frame1(5,:);  invframe(6,:) = frame1(3,:);
invframe = invframe ./ repmat(detA,6,1);

end
