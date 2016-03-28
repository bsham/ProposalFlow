function fwh=whiten_feats(f, R, neg, bg)
sz=size(f);
if(~exist('R','var'))
	
	if(~exist('bg', 'var'))
		load(bg_file_name);
	end
	[R, neg]=whiten(bg, sz(2), sz(1));
end

%remove trunc feats
f1=f(:,:,1:end-1);

%convert into column vector
f1=f1(:);

%center and multiply by R^{-T}
fwh=R'\(f1-neg);

%reshape
fwh=reshape(fwh, [sz(1) sz(2) sz(3)-1]);
	
	
