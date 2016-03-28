% im = appendimages(image1, image2, direction)
%
% Return a new image that appends the two images side-by-side or up and
% down

function im = appendimages(image1, image2, direction)

if nargin < 3
    direction = 'h';
end

nChan = size(image1,3);

% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.
if( direction == 'v' )

    cols1 = size(image1,2);
    cols2 = size(image2,2);

    if (cols1 < cols2)
         image1(1,cols2) = 0;
    else
         image2(1,cols1) = 0;
    end

    % Now append both images side-by-side.
    im = [image1; image2];   
else
    rows1 = size(image1,1);
    rows2 = size(image2,1);

    if rows1 < rows2
         image1 = [image1; 255*ones(rows2-rows1, size(image1, 2), nChan)];
    elseif rows1 > rows2
         image2 = [image2; 255*ones(rows1-rows2, size(image2, 2), nChan)];
    end

    % Now append both images side-by-side.
    im = [image1 image2];   
end

    
