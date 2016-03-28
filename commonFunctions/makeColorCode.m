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