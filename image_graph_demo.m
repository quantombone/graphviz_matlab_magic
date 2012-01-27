function image_graph_demo(sequence)
% A demo which creates an image graph using graphviz
%
% Inputs: 
%   sequence: (either a cell array of images or a distance
%     matrix).  If the input is a cell array of images, then the
%     exemplarsvm library is required for some utility functions.
% Outputs:
%    The file will be written to /tmp/graph.pdf

if iscell(sequence)
  % Compute HOG features per image, resulting feature matrix is the
  % following size: [NDIM x NIMAGES]
  % Then compute distances squared between each element, producing a
  % [NIMAGES x NIMAGES] matrix
  tic
  d = distSqr_fast(ecat(emap(@(x)reshape(esvm_hog(imresize_max(toI(x),200),20),[], ...
                            1),sequence),2));
  toc
  fprintf(1,'Features took %.3f seconds to process\n');
elseif isnumeric(sequence)
  d = sequence;
end

% Create symmetric binary adjacency matrix by taking top 10% of
% shortest edges and enforcing symmetry
sd = sort(d(:));
thresh = sd(max(1,round(.1*length(sd))));
A = d<thresh;
A = A&A';

params = sexy_graph_params(A);
params.sfdp_coloring = 1;
%params = eigenvector_node_coloring(A, params);
sexy_graph(A,params);

%uncomment below, if on a mac, and you want the graph to
%automatically display
unix(['open ' params.pdf_file]);
