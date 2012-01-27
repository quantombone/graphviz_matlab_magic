function params = sexy_graph_params(A)
% Returns the default parameters for graph drawing
N = size(A,1);
for i = 1:N
  params.node_names{i} = sprintf('%d',i);
  params.icon_string{i} = '';
  params.shapestring{i} = 'shape=circle';
end
params.colors = rgb2hsv(repmat([1 1 1],size(A,1),1));

% If enabled, perform two passes of graphviz, where the first pass
% is used to obtain the node positions
params.sfdp_coloring = 0;

params.file_prefix = 'graph';
params.tmpdir = '/tmp/';

