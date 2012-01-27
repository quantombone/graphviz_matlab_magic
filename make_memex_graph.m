function I = make_memex_graph(A, params)
% Create a graph visualization of a matrix using graphviz via sfdp mode
% Input: 
%   A: a symmetric binary adjacency matrix
%   params: an optional set of parameters
% Output:
%   I: the graph image
%
% NOTE: A should be symmetric and have 1 component (not enforced)
%
% Tomasz Malisiewicz (tomasz@csail.mit.edu)

% turn diagonal off
A = A - diag(diag(A));

if ~exist('params','var')
  params = sexy_graph_params(A);
end
  
for i = 1:size(A,1)
  params.colstring{i} = sprintf('fillcolor="%.3f %.3f %.3f"',...
                               params.colors(i,1), ...
                               params.colors(i,2),...
                               params.colors(i,3)); 
  
  params.node_names{i} = sprintf('label="%s"',params.node_names{i});
end

write_dot_file(A, [], params);

if params.sfdp_coloring == 1
  positions = load_positions_from_sfdp(params.gv_file);
  fprintf(1,'Re-dumping graph with colors\n');
  write_dot_file(A, positions, params);
end

if nargout == 0
  fprintf(1,'creating pdf file %s\n', params.pdf_file);
  [basedir,tmp,tmp] = fileparts(params.pdf_file);
  [~,~]=unix(sprintf('cd %s && dot -Ksfdp -Tpdf %s > %s', ...
               basedir,params.gv_file, params.pdf_file));
else
  fprintf(1,'creating png file and loading\n');
  [aaa,bbb,ccc] = fileparts(params.gv_file);
  
  [~,~]=unix(sprintf('cd %s && dot -Ksfdp -Tpng %s > %s', ...
               aaa, params.gv_file, params.png_file));
  I = imread(params.png_file);
  delete(params.png_file);
end

delete(params.gv_file);

function write_dot_file(A, positions, params)
% Writes the dot file which graphviz will use as input

gv_file = params.gv_file;
[u,v] = find(A>0);
goods = (v>=u);
u = u(goods);
v = v(goods);

fid = fopen(gv_file,'w');
fprintf(fid,'// Dotfile written by make_memex_graph.m\n');
fprintf(fid,['// Matlab wrapper by Tomasz Malisiewicz (tomasz@' ...
             'csail.mit.edu)\n']);
fprintf(fid,['// Code available: https://github.com/quantombone/' ...
             'graphviz_matlab_magic\n']);
fprintf(fid,'graph G {\n');
fprintf(fid,['node [shape=circle style="filled" width=1.0 height=.5' ...
             ' penwidth=10 labelloc="t" fontsize="30"' ...
              ' labelfontcolor="black"]\n']);
fprintf(fid,'graph [outputorder="edgesfirst" size="20,20"]\n');
fprintf(fid,'edge [fontsize="10.0" penwidth=10 weight=10]\n');
fprintf(fid,'overlap="scale"\n');

for i = 1:size(A,1)  
  fprintf(fid,'%d [%s %s %s %s];\n',i,...
          params.shapestring{i},...
          params.colstring{i},...
          params.node_names{i},...
          params.icon_string{i});
end

if numel(positions) > 0
  dists = zeros(length(u),1);
  for i = 1:length(u) 
    dists(i) = norm(positions(u(i),:)-positions(v(i),:));
  end
  
  NC = 20;
  colorsheet = jet(NC);
  
  dists = dists - min(dists);
  dists = dists / (max(dists)+eps);
  dists = round(dists*(NC-1)+1);
  
  %now dists are between 0 and 1
  edge_colors = colorsheet(dists,:);
end

for i = 1:length(u)
  if u(i)>v(i)
    continue
  end
  
  en = '';
  if isfield(params,'edge_names')
    en = params.edge_names{u(i),v(i)};
  end

  if exist('edge_colors','var')
    ec = edge_colors(i,:);
  else
    ec = [1 1 1];
  end

  if isfield(params,'edge_colors')
    ec = params.edge_colors{u(i),v(i)};
  end
  fprintf(fid,'%d -- %d [weight=%.5f color="%.3f %.3f %.3f" %s];\n',...
          u(i), v(i), A(u(i),v(i)),...
          ec(1),ec(2),ec(3),...
          en);

end

fprintf(fid,'}\n');
fclose(fid);



function positions = load_positions_from_sfdp(gv_file)

plain_file = [gv_file '.plain'];
nodes_file = [gv_file '.nodes'];

[~,~]=unix(sprintf('dot -Ksfdp -Tplain %s > %s', ...
               gv_file, plain_file));
fprintf(1,'creating colors\n');
[~,~]=unix(sprintf('grep node %s | awk ''{print($2,$3,$4)}'' > %s',...
                   plain_file, nodes_file));

r = load(nodes_file,'-ascii');
positions = r(:,2:3);
ids = r(:,1);
[aa,bb] = sort(ids);
positions = positions(bb,:);
