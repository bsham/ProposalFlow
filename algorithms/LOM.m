function [ confidenceMap ] = LOM( viewA, viewB, opt)
% Naive + local offset regularization by Bumsub Ham, Inria - WILLOW
bVerbose = false;
bDeleteByAspect = opt.bDeleteByAspect;
bFeature = opt.feature;
thresAspect = 2.0;

tic;
% aspect ratio
aTrain = viewA.frame(3,:)./viewA.frame(6,:);
aTest = viewB.frame(3,:)./viewB.frame(6,:);

% learned BG HOG statistics
if strcmp(bFeature,'HOG')
    load('./feature/who2/bg11.mat');
    nY = 8; nX = 8;
    [bg.R, bg.mu_bg] = whiten(bg,nX,nY);
    % compute full sim matrix
    % compute S^-1*(mu_pos-mu_bg) efficiently
    A = viewA.desc-repmat(bg.mu_bg,1,size(viewA.desc,2));
    A = bg.R\(bg.R'\A);
    B = viewB.desc;
    
    bias = -A'*bg.mu_bg;
    wVoteFull = [ A; bias' ]'* [ B; ones(1,size(B,2)) ];
    wVoteFull = max(wVoteFull,0);
    fprintf('wdot\n');
elseif strcmp(bFeature,'SPM')
    % chi2 kernel embedding (inner product)
    wVoteFull = vl_alldist2(sparse(double(viewA.desc)),sparse(double(viewB.desc)), 'KCHI2');
    fprintf('chi2\n');
else
    A = viewA.desc;
    B = viewB.desc;
    wVoteFull = A'*B;
    wVoteFull = max(wVoteFull,0);
    fprintf('dot\n');
end

tableValid = true(size(viewA.frame,2),size(viewB.frame,2));

if bVerbose
    fprintf('vote weight: max %f - min %f\n', max(wVoteFull(:)), min(wVoteFull(:)));
end

nFeatTrain = size(viewA.desc,2);

if bDeleteByAspect
    for j=1:nFeatTrain
        bValid = (aTest/aTrain(j) < thresAspect) & (aTest/aTrain(j) > 1/thresAspect);
        tableValid(j, ~bValid) = false;
    end
end

idxValid = find(tableValid>0);
confidenceMap = zeros(size(viewA.frame,2),size(viewB.frame,2),'single');
confidenceMap(idxValid) = wVoteFull(idxValid);

% offset-reg
IoU_threshold = 0;

offset_x = zeros(size(viewA.frame,2),size(viewB.frame,2));
offset_y = zeros(size(viewA.frame,2),size(viewB.frame,2));
offset_s = zeros(size(viewA.frame,2),size(viewB.frame,2));
for i=1:nFeatTrain
    offset_x(i,:)=repmat(viewA.frame(1,i),1,size(viewB.desc,2)) - viewB.frame(1,:);
    offset_y(i,:)=repmat(viewA.frame(2,i),1,size(viewB.desc,2)) - viewB.frame(2,:);
    offset_s(i,:)=repmat(viewA.frame(3,i).*viewA.frame(6,i),1,size(viewB.desc,2))./ (viewB.frame(3,:).*viewB.frame(6,:));
end

%frame2box
boxA=frame2box(viewA.frame);
boxA_xywh = [boxA(1,:);boxA(2,:);boxA(3,:)-boxA(1,:)+1;boxA(4,:)-boxA(2,:)+1];
boxA_IoU=bboxOverlapRatio(boxA_xywh', boxA_xywh', 'Union');

boxA_IoU_idx=zeros(size(boxA,2),size(boxA,2));
boxA_IoU_idx(boxA_IoU>IoU_threshold)=1;

for i=1:nFeatTrain
    idx_local_neighborhood = find(boxA_IoU_idx(i,:)==1)';
    local_wVoteFull=confidenceMap(idx_local_neighborhood,:);
  
    [matching_conf, matching_idx]=max(local_wVoteFull,[],2);
    
    [global_matching_conf, ~]=max(confidenceMap,[],2);
   
    indices = sub2ind(size(offset_x), idx_local_neighborhood, matching_idx);
    local_offset_x_for_matching_point=offset_x(indices);
    local_offset_y_for_matching_point=offset_y(indices);
    local_offset_s_for_matching_point=offset_s(indices);

    local_offset = [local_offset_x_for_matching_point,...
        local_offset_y_for_matching_point,...
        local_offset_s_for_matching_point];
    
    % #geometric median
    initial_median_offset = ones(1,3);
    for j=1:20
        distance = abs(bsxfun(@minus, local_offset, initial_median_offset))+eps;
        norminator = sum((local_offset./distance),1);
        denorminator = sum((1./distance),1);
        median_offset = norminator./denorminator;
        initial_median_offset=median_offset;
    end
    if 0
        clustMembsCell=cell(1);
        clustMembsCell{1}=1:size(local_offset,2);
        numClust = length(clustMembsCell);
        figure(10),clf,hold on
        cVec = 'bgrcmykbgrcmykbgrcmykbgrcmyk';%, cVec = [cVec cVec];
        for k = 1:min(numClust,length(cVec))
            myMembers = clustMembsCell{k};
            myClustCen = median_offset(k,:);
            scatter3(local_offset(1,myMembers),local_offset(2,myMembers),local_offset(3,myMembers),[cVec(k) '.'])
            scatter3(myClustCen(1),myClustCen(2),myClustCen(3),'o','MarkerEdgeColor','k','MarkerFaceColor',cVec(k+1))
            %plot(local_offset(1,myMembers),local_offset(2,myMembers),[cVec(k) '.'])
            %    plot(myClustCen(1),myClustCen(2),'o','MarkerEdgeColor','k','MarkerFaceColor',cVec(k+1), 'MarkerSize',10)
        end
        title(['no shifting, numClust:' int2str(numClust)]);
        pause;
        clf;
    end
    
    Affinity_xy = sqrt((offset_x(i,:)-median_offset(1)).^2 + (offset_y(i,:)-median_offset(2)).^2);
    Affinity_s = offset_s(i,:)-median_offset(3);
    Affinity = exp(-0.05.*Affinity_xy-0.3.*abs(Affinity_s));
    
    confidenceMap(i,:)=confidenceMap(i,:).*Affinity.*(sum(matching_conf)/sum(global_matching_conf));
end
end

