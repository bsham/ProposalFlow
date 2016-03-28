function drawpolygon(polygon, varargin)
% draw boxes
% input: 8 by nBox
% parallellogram(1:2,:) upper-left point
% parallellogram(3:4,:) upper-right point
% parallellogram(5:6,:) lower-right point
% parallellogram(7:8,:) lower-left point

linew = 1;
lines = '-';
col = 'r';
offset = [ 0 0];

for k=1:2:length(varargin)
  opt=lower(varargin{k}) ;
  arg=varargin{k+1} ;
  switch opt
    case 'offset'
      offset = arg;
      if numel(offset) == 1
          offset(2) = 0;
      end
      polygon([1 3 5 7],:) = polygon([1 3 5 7],:) + offset(1);
      polygon([2 4 6 8],:) = polygon([2 4 6 8],:) + offset(2);
    case 'linewidth'
        linew = arg;
    case 'linestyle'
        lines = arg;
    case 'color'
        col = arg;    
    otherwise
      error(sprintf('Unknown option ''%s''', opt)) ;
  end
end

x = [polygon(1,:); polygon(3,:); polygon(5,:); polygon(7,:); polygon(1,:); nan(1,size(polygon,2))];
y = [polygon(2,:); polygon(4,:); polygon(6,:); polygon(8,:); polygon(2,:); nan(1,size(polygon,2))];

if 1
    plot(x,y,'Color','k','LineWidth',linew+1,'LineStyle',lines);
    plot(x,y,'Color',col,'LineWidth',linew,'LineStyle',lines);
else
    for i=1:size(boxes,2)
        col=rand(3,1);
        plot(x(:,i),y(:,i),'Color','k','LineWidth',linew+1,'LineStyle',lines);
        plot(x(:,i),y(:,i),'Color',col,'LineWidth',linew,'LineStyle',lines);
    end
end
