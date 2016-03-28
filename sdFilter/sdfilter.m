function [u] = sdfilter(g,u0,f,mask,nei,lambda,sigma_g,sigma_u,itr,issparse)

[~, ~, Zg]=size(g);
[X, Y, Zu]=size(u0); N = X*Y;
[~, edges] = lattice(X,Y,nei);

fVals = reshape(f,N,Zu);
if (issparse)
    A = zeros(N,1);
    A(mask > 0) = 1;
    C=sparse(1:N,1:N,A);
    F = C*double(fVals);
else
    C = sparse(1:N,1:N,ones(N,1));
    F = double(fVals);
end

if Zg > 1, g = colorspace('Lab<-', g);end;
gVals = reshape(g,N,Zg);
weights_g = makeweights(edges,gVals,sigma_g);
gW = adjacency(edges,weights_g,N);


fprintf(1,'lambda: %d, # of steps: %d\n',lambda, itr);
for i=1:itr
    fprintf(1,'%d/%d\n',i, itr); pause(.1)
    
    %if Zu > 1,u0 = colorspace('Lab<-', u0);end;
    uVals = reshape(u0,N,Zu);
    weights_u = makeweights(edges,uVals,sigma_u);
    uW = adjacency(edges,weights_u,N);
    
    W=gW.*uW;
    D  = sparse(1:N,1:N,sum(W));
    L = D-W;
    
    R = (C+lambda*L);
    U = (R \ F);
    
    u = reshape(U,X,Y,Zu);
    u0 = u;
    
    if Zu > 1,u0 = colorspace('Lab<-', u0);end;
end
fprintf('\n');


