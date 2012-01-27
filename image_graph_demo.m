function image_graph_demo(sequence)
% A demo which shows an image graph

% Compute HOG features per image, resulting feature matrix is the
% following size: [NDIM x NIMAGES]
x = ecat(emap(@(x)reshape(esvm_hog(imresize_max(toI(x),200),20),[], ...
                          1),sequence),2);

% Compute distances squared between each element, producing a
% [NIMAGES x NIMAGES] matrix
d = distSqr_fast(x);

% Create symmetric binary adjacency matrix by taking top 10% of
% shortest edges and enforcing symmetry
sd = sort(d(:));
thresh = sd(max(1,round(.1*length(sd))));
A = d<thresh;
A = A&A';

% Show the graph
%sexy_graph(A);

params = sexy_graph_params(A);
%params.sfdp_coloring = 1;
params = evec_coloring(A, params);
sexy_graph(A,params);

%if on a mac
%unix(['open ' params.pdf_file]);
