function f = flipfeat(f)
% f = flipfeat(f)
% Horizontal-flip HOG features.
% Used for learning symmetric models.

% flip permutation

if size(f,3) == 31
    p = [10 9 8 7 6 5 4 3 2 1 18 17 16 15 14 13 12 11 19 27 26 25 24 23 ...
         22 21 20 30 31 28 29];
elseif size(f,3) == 32
    p = [10 9 8 7 6 5 4 3 2 1 18 17 16 15 14 13 12 11 19 27 26 25 24 23 ...
     22 21 20 30 31 28 29 32];
else
    error('dimension should be 31 or 32.');
end

f = f(:,end:-1:1,p);
