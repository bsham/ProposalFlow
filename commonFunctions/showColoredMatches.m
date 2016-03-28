function showColoredMatches(frame1, frame2, match, weight, varargin)
% show matches with different colors based on their weights

strcolormap = 'jet';
mode = 'frame';

for k=1:2:length(varargin)
  opt=lower(varargin{k}) ;
  arg=varargin{k+1} ;
  switch opt
    case 'offset'
      offset = arg;
      if numel(offset) == 1
          offset(2) = 0;
      end
      frame2(1,:) = frame2(1,:) + offset(1);
      frame2(2,:) = frame2(2,:) + offset(2);      
    case 'colormap'
        strcolormap = arg;
    case 'mode'
        mode = arg;
    otherwise
      error(sprintf('Unknown option ''%s''', opt)) ;
  end
end

cmap = colormap(strcolormap);
colormap('gray');

maxW = max(weight);
minW = min(weight);
if maxW > minW
    step_w = length(cmap) / (maxW-minW);
else
    step_w = length(cmap);
end

[ tmp, idxC ] = sort(weight);
for m=1:numel(weight)
    idxMatch = idxC(m);
    colorId = min( ceil( ( weight(idxMatch)-minW ) * step_w ) + 1, length(cmap));
    colorCode = cmap( colorId, :);
    
    if strcmp(mode,'frame')
        %vl_plotframe(frame1(:,match(1,idxMatch)),'color','w','LineWidth',3);
        vl_plotframe(frame1(:,match(1,idxMatch)),'color',colorCode,'LineWidth',2);
        %vl_plotframe(frame2(:,match(2,idxMatch)),'color','w','LineWidth',3);
        vl_plotframe(frame2(:,match(2,idxMatch)),'color',colorCode,'LineWidth',2);
    elseif strcmp(mode,'box')
        xmin= frame1(1,match(1,idxMatch)) - frame1(3,match(1,idxMatch));
        ymin= frame1(2,match(1,idxMatch)) - frame1(6,match(1,idxMatch));
        xmax= frame1(1,match(1,idxMatch)) + frame1(3,match(1,idxMatch));
        ymax= frame1(2,match(1,idxMatch)) + frame1(6,match(1,idxMatch));
        plot([xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'Color',colorCode,'LineWidth',2,'LineStyle','-');
        xmin= frame2(1,match(2,idxMatch)) - frame2(3,match(2,idxMatch));
        ymin= frame2(2,match(2,idxMatch)) - frame2(6,match(2,idxMatch));
        xmax= frame2(1,match(2,idxMatch)) + frame2(3,match(2,idxMatch));
        ymax= frame2(2,match(2,idxMatch)) + frame2(6,match(2,idxMatch));
        plot([xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'Color',colorCode,'LineWidth',2,'LineStyle','-');
    end
    
    coord_x = [ frame1(1,match(1,idxMatch)) frame2(1,match(2,idxMatch)) ];
    coord_y = [ frame1(2,match(1,idxMatch)) frame2(2,match(2,idxMatch)) ];
    %plot( coord_x(:), coord_y(:), '-','LineWidth',3,'MarkerSize',10,'color', 'w');
    plot( coord_x(:), coord_y(:), '-','LineWidth',2,'MarkerSize',10,'color', colorCode);
    
end

end