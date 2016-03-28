function dmatch=flow_field_generation(viewA, viewB,confidence,filter,bPost)

boxA=frame2box(viewA.frame);
boxA_xywh = [boxA(1,:);boxA(2,:);boxA(3,:)-boxA(1,:)+1;boxA(4,:)-boxA(2,:)+1];
[viewA_H, viewA_W,~] = size(viewA.img);

[viewB_H, viewB_W,~] = size(viewB.img);


[ confidenceA, max_id ] = max(confidence,[],2);

[anchor_confA, anchor_idA]=sort(confidenceA,'descend');
anchor_idB=max_id(anchor_idA);

boxB=frame2box(viewB.frame);
boxB_xywh = [boxB(1,:);boxB(2,:);boxB(3,:)-boxB(1,:)+1;boxB(4,:)-boxB(2,:)+1];

%Dense warping field (x,y)
WarpCoordXY = NaN(viewA_H,viewA_W,2);
Conf_Dense = zeros(viewA_H,viewA_W);
idxValid = zeros(viewA_H,viewA_W);
% initial dense warping field
for k=1:numel(anchor_idA)
    idxA=anchor_idA(k);
    idxB=anchor_idB(k);
    anchor_conf = anchor_confA(k);
    
    candBoxA=boxA(:,idxA);
    candBoxB=boxB(:,idxB);
    
    candBoxA_xywh=boxA_xywh(:,idxA);
    candBoxB_xywh=boxB_xywh(:,idxB);
    
    idxValid_temp=idxValid(candBoxA(2):candBoxA(4),candBoxA(1):candBoxA(3));
    if numel(find(idxValid_temp==0)) == 0
        continue;
    else
        % warped coordinate (x,y) for four points in
        % rectangle
        CellGrid = NaN(candBoxA_xywh(4),candBoxA_xywh(3),2);
        CellGrid(1,1,1:2)=cat(3,candBoxB(1),candBoxB(2));
        CellGrid(1,end,1:2)=cat(3,candBoxB(3),candBoxB(2));
        CellGrid(end,1,1:2)=cat(3,candBoxB(1),candBoxB(4));
        CellGrid(end,end,1:2)=cat(3,candBoxB(3),candBoxB(4));
        
        CellGridX = CellGrid(:,:,1);
        CellGridY = CellGrid(:,:,2);
        if size(CellGrid,1)==1 || size(CellGrid,2)==1
            continue;
        else
            [y,x] = find(~isnan(CellGridX));
            indexes = sub2ind(size(CellGridX),y,x);
            interpolator = scatteredInterpolant(y,x,double(CellGridX(indexes)), 'linear');
            [X,Y] = meshgrid(1:size(CellGridX,2),1:size(CellGridX,1));
            interpolated_CellGridX = interpolator(Y,X);
            
            interpolator = scatteredInterpolant(y,x,double(CellGridY(indexes)), 'linear');
            interpolated_CellGridY = interpolator(Y,X);
        end
        clear CellGridX;clear CellGridY;
        
        for p=1:candBoxA_xywh(4)
            for q=1:candBoxA_xywh(3)
                if idxValid(candBoxA(2)+p-1,candBoxA(1)+q-1)==0
                    WarpCoordXY(candBoxA(2)+p-1,candBoxA(1)+q-1,1)=interpolated_CellGridX(p,q);
                    WarpCoordXY(candBoxA(2)+p-1,candBoxA(1)+q-1,2)=interpolated_CellGridY(p,q);
                    Conf_Dense(candBoxA(2)+p-1,candBoxA(1)+q-1)=anchor_conf;
                    idxValid(candBoxA(2)+p-1,candBoxA(1)+q-1) =1;
                else
                    continue;
                end
            end
        end
    end
end

WarpCoordXY = round(WarpCoordXY);
WarpCoordXY(:,:,1)=max(min(WarpCoordXY(:,:,1),viewB_W),1);
WarpCoordXY(:,:,2)=max(min(WarpCoordXY(:,:,2),viewB_H),1);

p=1:viewA_W;
q=1:viewA_H;
p=repmat(p,viewA_H,1);
q=repmat(q',1,viewA_W);
vx=WarpCoordXY(:,:,1)-p;
vy=WarpCoordXY(:,:,2)-q;

if bPost
    % filtering for outliers in initial dense warping field
    Buffer_for_WarpCoordXY = NaN(viewB_H,viewB_W,2);
    Buffer_for_Conf = NaN(viewB_H,viewB_W);
    
    for p=1:viewA_H
        for q=1:viewA_W
            WarpCoordX=vx(p,q)+q;
            WarpCoordY=vy(p,q)+p;
            
            if isnan(Buffer_for_Conf(WarpCoordY,WarpCoordX))
                Buffer_for_Conf(WarpCoordY,WarpCoordX) = Conf_Dense(p,q);
                
                Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,1)=q;
                Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,2)=p;
            else
                if  Buffer_for_Conf(WarpCoordY,WarpCoordX)<Conf_Dense(p,q)
                    Buffer_for_Conf(WarpCoordY,WarpCoordX) = Conf_Dense(p,q);
                    
                    vx(Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,2)...
                        ,Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,1))=nan;
                    vy(Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,2)...
                        ,Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,1))=nan;
                    
                    Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,1)=q;
                    Buffer_for_WarpCoordXY(WarpCoordY,WarpCoordX,2)=p;
                    
                    Conf_Dense(p,q)=0;
                else
                    vx(p,q)=nan;
                    vy(p,q)=nan;
                    Conf_Dense(p,q)=0;
                end
            end
        end
    end
    
    % dense field regularization
    Mask_for_Reg = isnan(vx) | isnan(vy);
    Mask_for_Reg=1-Mask_for_Reg;
    vx=vx.*Mask_for_Reg;
    vy=vy.*Mask_for_Reg;
    
    u0=ones(viewA_H,viewA_W);
    fprintf(' - SDFiltering for x offset\n');
    vx = sdfilter(im2double(viewA.img),u0,vx,Mask_for_Reg,...
        filter.nei,filter.lambda,filter.sigma_g,filter.sigma_u,filter.itr,filter.issparse);
    fprintf(' - SDFiltering for y offset\n');
    vy = sdfilter(im2double(viewA.img),u0,vy,Mask_for_Reg,...
        filter.nei,filter.lambda,filter.sigma_g,filter.sigma_u,filter.itr,filter.issparse);
end


dmatch.vx = vx;
dmatch.vy = vy;





