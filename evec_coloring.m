if isfield(params,'evec_coloring')
  
  if 0
  A = A - diag(diag(A));
  degs = sum(A,1);
  L = normalized_laplacian(A);

  [V,D] = eig(full(L));
  D = D.*(D>0);
  [aa,bb] = sort(diag(D));
  V = V(:,bb);
  D = D(bb,bb);
  eres = diag(D);
  eres = eres(params.Kevec);
  volG = sum(degs);
  distsmat = sqrt(volG)*diag(degs.^-.5)*V;  

  dists = sqrt(volG)*diag(degs.^-.5)*V(:,params.Kevec);  
 
  end
  %dists = params.V(params.Kevec,:);
  %[aa,bb] = ct_embedding(A, size(A,1));
  %dists2 = params.V(params.Kevec,:);
%keyboard

  
  NC = 200;
  colorsheet = jet(NC);
  colorsheet = colorsheet(end:-1:1,:);
  
  if abs(range(dists)) < .000001
    dists = dists*0+mean(dists);
  end
  
  
  dists = dists - min(dists);
  dists = dists / (max(dists)+eps);
  dists = round(dists*(NC-1)+1);
  
  %now dists are between 0 and 1
  params.colors = rgb2hsv(colorsheet(dists,:));
end
