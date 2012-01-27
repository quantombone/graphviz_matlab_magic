function construct_graph(M, video)
% Construct a graph visualization using Graphviz using the sfdp
% algorithm
% Input:
%    M the symmetric binary matrix used to visualize
%    [video] optional sequence of file names which are used as images
N = size(M,1);

for i = 1:N
  params.node_names{i} = sprintf('%d',i);
  params.icon_string{i} = sprintf('image="%s"',baser(video{i}));
end

M = M - diag(diag(M));

params.tmpdir = '/tmp/';

make_memex_graph(M, params);

function res = baser(x)
[~,b,c] = fileparts(x);
res = [b c];

