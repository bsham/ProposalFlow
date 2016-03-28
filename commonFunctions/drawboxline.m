function drawboxline(boxes, varargin)
% draw boxes
% input: 4 by nBox

linew = 4;
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
      boxes([1 3],:) = boxes([1 3],:) + offset(1);
      boxes([2 4],:) = boxes([2 4],:) + offset(2);
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

x = [boxes(1,:); boxes(3,:); boxes(3,:); boxes(1,:); boxes(1,:); nan(1,size(boxes,2))];
y = [boxes(2,:); boxes(2,:); boxes(4,:); boxes(4,:); boxes(2,:); nan(1,size(boxes,2))];

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
