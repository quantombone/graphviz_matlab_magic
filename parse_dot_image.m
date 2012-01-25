function parse_dot_image(parse,train,trainc)
%Makes a graphviz graph plot for the Bayesian Network object
%cols = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1; .5 1 0];
colstring = {'red','green','blue','brown','yellow','orange','orchid'};
%for i = 1:size(cols,1)
%  col_string{i} = sprintf('%f:%f:%f\n
%end
  
fid = fopen('/nfs/hn22/tmalisie/www/pb_parses/one.dot','w');

fprintf(fid,'graph G {\n');

N = size(parse.keepmasks,3);
fprintf(fid,'subgraph cluster_segments {\nstyle=filled;\n');
for i = 1:N
  fprintf(fid,'%d [shape=box,color="%s"];\n',i,colstring{i});
end

for i = 1:N
  for j = (i+1):N
    fprintf(fid,'%d -- %d [style="dashed",color="red"];\n',i,j);
  end
end

fprintf(fid,'}\n')

if 1
  for i = 1:N
    fprintf(fid,'subgraph cluster_hits%d {\nstyle=filled;\n', i);
    %hits = find(parse.distmat(i,:)<0);
    [aa,hits{i}] = psort(parse.distmat(i,:)',20);
    %hits{i} = hits{i}(aa<1);
    for j = 1:length(hits{i})
      fprintf(fid,'%d.%d [color="black"];\n',i,hits{i}(j));
    end
    fprintf(fid,'}\n');
    
    fprintf(fid,['%d -- cluster_hits%d [weight=20, style="solid",' ...
                 'color="black"];\n'],i,i);
  end
end

NEX = size(train.C,1);

conn = sparse(trainc.contextobjects(:,1),trainc.contextobjects(:,2),1,NEX,NEX);
for i = 1:N
  for j = (i+1):N
    connbase = conn(hits{i},hits{j});
    [uu,vv] = find(connbase);
    for a = 1:length(uu)
      fprintf(fid,'%d.%d -- %d.%d [style="dashed",color="red"];\n',i,hits{i}(uu(a)),j,hits{j}(vv(a)));
    end
  end
end

%fprintf(fid,'%d -- %d [weight=8, style="dashed", color="%s"];\n',id1,id2,col);

fprintf(fid,'fontsize=20;\n');
fprintf(fid,'}\n');

function mat = sim_edge(fid,A,e_anchor,anchor_id,col,AMODE)
if ~exist('AMODE','var')
  AMODE = 0;
end

mat = zeros(size(e_anchor));

anchor_mat = A(e_anchor(:),e_anchor(:));

[uu,vv] = find(anchor_mat);
goods = (vv>uu);
uu = uu(goods);
vv = vv(goods);
for i = 1:length(uu)
  curu = uu(i);
  curv = vv(i);
  [a,b] = ind2sub(size(e_anchor),[curu curv]);
  id1 = anchor_id(a(1),b(1));
  id2 = anchor_id(a(2),b(2));

  if (AMODE == 1) & (b(1)~=b(2))
    continue
  end

  mat(a(1),b(1))=1;
  mat(a(2),b(2))=1;
end

function show_nodes(fid,e_anchor,e_loose,anchor_id, ...
                              loose_id,boolmat,train,A)


if 0
tic
[p,q,r,s] = dmperm(A(e_loose(:),e_loose(:)));
toc

cc_sizes = diff(r);

%inds = p(r(bb):(r(bb+1)-1));
for i = 1:length(cc_sizes)
  
  %avoid single ones
  %if cc_sizes(i) <= 1
  %  continue
  %end
  
  inds = p(r(i):(r(i+1)-1));
  for j = 1:length(inds)
    [myi,myj] = ind2sub(size(loose_id),p(j));
    exind = e_loose(myi,myj);

    imgl = train.info.imageid(exind);
    objl = train.info.objectid(exind);
    [namel] = labelme_geticon_name(train.D,imgl,objl);
    namel = strrep(namel,'/nfs/hn22/tmalisie/iccv09/labelme400//',...
                '../../');
    loose_name = train.info.classnames{train.info.classes(exind)};
    
    fprintf(fid,['%d [label="L(%d,%d)", tooltip="%s" URL="%s", color="red",' ...
                 'fontsize=10];\n'],loose_id(myi,myj),myi,myj,loose_name,namel);
  end
  
  
end

return;
end


for i = 1:size(e_anchor,1)
  for j = 1:size(e_anchor,2)
    if (boolmat(i,j)==0)
      continue;
    end

    imgl = train.info.imageid(e_loose(i,j));
    objl = train.info.objectid(e_loose(i,j));
    [namel] = labelme_geticon_name(train.D,imgl,objl);
    namel = strrep(namel,'/nfs/hn22/tmalisie/iccv09/labelme400//',...
                '../../');
    
    anchor_name = train.info.classnames{train.info.classes(e_anchor(i,j))};
    loose_name = train.info.classnames{train.info.classes(e_loose(i,j))};
    
    %fprintf(fid,'%d [label="A(%d,%d)", tooltip="%s", color="blue", fontsize=10];\n',anchor_id(i,j),i,j,anchor_name);
    fprintf(fid,['%d [label="L(%d,%d)", tooltip="%s" URL="%s", color="red",' ...
                 'fontsize=10];\n'],loose_id(i,j),i,j,loose_name,namel);
  end
end

%nbrs = setdiff(find(sum(A(uex,:))),uex);
%subA = A(uex,nbrs);
%s = sum(subA,1);
%nbrs = nbrs(find(s>1));

%keyboard
return;

for i = 1:size(e_anchor,1)
  for j = 1:size(e_anchor,2)
    if (boolmat(i,j)==0)
      continue;
    end
    fprintf(fid,'%d -- %d [weight=20, style="bold"];\n',anchor_id(i,j), ...
            loose_id(i,j));
  end
end

fclose(fid);