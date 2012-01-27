function params = eigenvector_node_coloring(A, params, K)
% Perform node coloring based on normalized laplacian embedding
% using the K-th eigenvector
%
% Tomasz Malisiewicz (tomasz@csail.mit.edu)

if ~exist('K','var')
  K = 2;
end

A = A - diag(diag(A));
degs = sum(A,1);
L = normalized_laplacian(A);

[V,D] = eig(full(L));
D = D.*(D>0);
[aa,bb] = sort(diag(D));
V = V(:,bb);
D = D(bb,bb);
%eres = diag(D);
%eres = eres(K);
volG = sum(degs);
dists = sqrt(volG)*diag(degs.^-.5)*V(:,K);

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

function L = normalized_laplacian(A)
A = A - diag(diag(A));
degs = sum(A,1);
Tih = spdiag(degs.^-.5);
L = speye(size(A)) - Tih*A*Tih;

%% enforce machine precision un-symmetry
%% helps eigs make sure we don't get negative eigenvalues
L = (L + L')/2;

function W = spdiag(D)
% from Timothee Cour

D=D(:);
n=length(D);
W = spdiags(D,0,n,n);
