if isfield(params,'ct_edge_coloring')
  fprintf(1,'got here\n');
  V = params.V;
  %V = ct_embedding(A, params.Kevec);
  [u,v] = find(A);
  dists = sum((V(1:params.Kevec,u) - V(1:params.Kevec,v)).^2,1);




  if 0
    figure(2)
    CT = getCTmatrix(A);
    CT = CT.*A;
    CT2 = distSqr_fast(V,V);
    CT2 = CT2.*A;
    imagesc(CT-CT2), colorbar
    title('difference in CTs')
    figure(1)
  end

  NC = 200;
  colorsheet = jet(NC);
  colorsheet = colorsheet(end:-1:1,:);
  
  if abs(range(dists)) < .000001
    dists = dists*0+mean(dists);
  end
    
  dists = dists - min(dists);
  dists = dists / (max(dists)+eps);
  dists = round(dists*(NC-1)+1);

  cur_colors = colorsheet(dists,:);
  
  %params.edge_colors = sparse_cell(size(A,1),size(A,2));
  %for i = 1:length(u)
  %  params.edge_colors{u(i),v(i)} = cur_colors(i,:);
  %end
end
