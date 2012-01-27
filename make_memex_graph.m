function [I] = make_memex_graph(A, params)
% Create a graph visualization of a matrix
% Input: 
%   A: a symmetric binary adjacency matrix
%   params: an optional set of parameters
% Output:
%   I: the graph image
%
% NOTE: A should be symmetric and have 1 component (not enforced)
%
% Tomasz Malisiewicz (tomasz@cmu.edu) 
%% if this is turned on, then we do two step coloring
DO_COLORS = 0;

if ~exist('params','var') || numel(params)==0
  params.is_silly = 1;
end

if ~isfield(params,'special_node')
  params.special_node = -1;
end

if ~isfield(params,'shapestring')
  for i = 1:size(A,1)
    params.shapestring{i} = 'shape=circle';
  end
end

bname = 'graph';
params.svg_file = [params.tmpdir bname '.pdf'];
params.gv_file = [params.tmpdir bname '.gv'];
params.png_file = [params.tmpdir bname '.jpg'];
params.pdf_file = [params.tmpdir bname '.pdf'];
params.plain_file = [params.tmpdir bname '.plain'];
params.nodes_file = [params.tmpdir bname '.nodes'];
%params.gv2_file = [params.tmpdir bname '.gv2'];



if ~isfield(params,'colors')
  %% generate white node colors
  params.colors = rgb2hsv(repmat([1 1 1],size(A,1),1));
end

if ~isfield(params, 'node_names');
  for i = 1:size(A,1)
    params.node_names{i} = '';%num2str(i);
  end
end

if ~isfield(params,'edge_names')
  % params.edge_names = sparse_cell(size(A,1),size(A,2));
  % [u,v] = find(A);
  % for i = 1:length(u)
  %   params.edge_names{u(i),v(i)} = '';%sprintf('label="W=%.3f"',double(A(u(i),v(i))));
  % end
end

if ~isfield(params,'edge_colors')
  
  % [u,v] = find(A);
  % params.edge_colors = sparse_cell(size(A,1),size(A,2));
  % for i = 1:length(u)
  %   params.edge_colors{u(i),v(i)} = rgb2hsv([0 0 0]);
  % end
    
  %params.edge_colors = colorsheet(dists,:);
  %params.edge_colors(:, 1) = 1;
end

if ~isfield(params,'icon_string')
  params.icon_string = @(i)'';
end
  
for i = 1:size(A,1)
  params.colstring{i} = sprintf('fillcolor="%.3f %.3f %.3f"',...
                               params.colors(i,1), ...
                               params.colors(i,2),...
                               params.colors(i,3)); 
  
  params.node_names{i} = sprintf('label="%s"',params.node_names{i});
end



%A = A>0;
%A = (A+A')>0;

%% get largest connected component
%curA = A;
%curA(find(speye(size(curA)))) = 1;
%[p,q,r,s] = dmperm(curA);

%dr = diff(r);
%[aa,bb] = max(dr);
%inds = p(r(bb) : (r(bb+1)-1));
%A = curA(inds,inds);
%fprintf(1,'Largest CC has %d nodes\n',length(inds));

%gv_file = '/nfs/hn22/tmalisie/ddip/memex.gv';
%plain_file = '/nfs/hn22/tmalisie/ddip/memex.plain';
%nodes_file = '/nfs/hn22/tmalisie/ddip/memex.nodes';

%gv2_file = '/nfs/hn22/tmalisie/ddip/memex.2.gv';
%ps_file = '/nfs/hn22/tmalisie/ddip/memex.ps';
%png_file = '/nfs/hn22/tmalisie/ddip/memex.png';
if 0
  params.tmpdir = '/tmp/';
end


if ~exist('special_node','var')
  special_node = -1;
end

%if ~exist('edge_names','var')
%  for i = 1:size(A,1)
%    edge_names{i} = sprintf('NODE %d',i);
%  end
%end

fprintf(1,'Dumping graph\n');
show_graph(A, [], params);

if DO_COLORS == 1
  fprintf(1,'creating plain file\n');
  unix(sprintf('dot -Ksfdp -Tplain %s > %s', ...
               gv_file, plain_file));
  fprintf(1,'creating colors\n');
  unix(sprintf('grep node %s | awk ''{print($2,$3,$4)}'' > %s',...
               plain_file, nodes_file));
  
  r = load(nodes_file,'-ascii');
  positions = r(:,2:3);
  ids = r(:,1);
  [aa,bb] = sort(ids);
  positions = positions(bb,:);

  
  fprintf(1,'Dumping graph with colors\n');
  show_graph(A, positions, params);
else
  %params.gv2_file = params.gv_file;
end

if nargout == 0
  fprintf(1,'creating pdf file %s\n', params.pdf_file);
  [basedir,tmp,tmp] = fileparts(params.pdf_file);
  unix(sprintf('cd %s && dot -Ksfdp -Tpdf %s > %s', ...
               basedir,params.gv_file, params.pdf_file));
  
  %unix(sprintf('ps2pdf %s %s',ps_file,pdf_file));
else
  fprintf(1,'creating png file and loading\n');
  [aaa,bbb,ccc] = fileparts(params.gv2_file);
  
  unix(sprintf('cd %s && dot -Ksfdp -Tpng %s > %s', ...
               aaa,gv2_file, params.png_file));
  I = imread(png_file);
end

function show_graph(A, positions, params)
gv_file = params.gv_file;
[u,v] = find(A>0);
goods = (v>=u);
u = u(goods);
v = v(goods);

fid = fopen(gv_file,'w');

fprintf(fid,'graph G {\n');
fprintf(fid,['node [shape=circle style="filled" width=1.0 height=.5' ...
             ' penwidth=10 labelloc="t" fontsize="30"' ...
              ' labelfontcolor="black"]\n']);
fprintf(fid,'graph [outputorder="edgesfirst" size="20,20"]\n');
%fprintf(fid,'graph [page="8.5,11"]\n');
fprintf(fid,'edge [fontsize="10.0" penwidth=10 weight=10]\n');
%fprintf(fid,'bgcolor="black"\n');
fprintf(fid,'overlap="scale"\n');
%fprintf(fid,'fixedsize=true\n');

for i = 1:size(A,1)
 
  %if i == params.special_node
  %  shapestring = 'penwidth=50';%'style=filled fillcolor="red"';
  %end
  
  fprintf(fid,'%d [%s %s %s %s];\n',i,...
          params.shapestring{i},...
          params.colstring{i},...
          params.node_names{i},...
          params.icon_string{i});

  %end
  %fprintf(fid,'%d;\n',i);
end

if numel(positions) > 0
  dists = zeros(length(u),1);
  for i = 1:length(u) 
    dists(i) = norm(positions(u(i),:)-positions(v(i),:));
  end
  
  NC = 20;
  colorsheet = jet(NC);
  %colorsheet = colorsheet(end:-1:1,:);
  
  dists = dists - min(dists);
  dists = dists / (max(dists)+eps);
  dists = round(dists*(NC-1)+1);
  

  
  %now dists are between 0 and 1
  edge_colors = colorsheet(dists,:);
end

% for i = 1:length(u)
%   params.edge_colors{u(i),v(i)} = rgb2hsv(params.edge_colors{u(i), ...
%                     v(i)});
% end

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

