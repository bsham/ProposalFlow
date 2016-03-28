function box = box2rect( box )
% tranform boxes into frames
box(3:4,:) = box(3:4,:)-box(1:2,:);
% box(:, 3:4) = box(:, 3:4)-box(:, 1:2);
end