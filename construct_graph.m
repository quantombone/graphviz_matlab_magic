function I=construct_graph(mat,video)
K = 100;
mat = mat(1:K,1:K);
video = video(1:K);

N = size(mat,1);

for i = 1:N
  other.node_names{i} = sprintf('%d',i);
end

other.icon_string = @(i)sprintf('image="%s"',baser(video{i}));

A = mat & mat';

%A = (mat + mat')/2;
A = A - diag(diag(A));



% newA = A*0;
% for i = 1:size(A,1)
%   [aa,bb] = sort(A(i,:),'descend');
%   newA(i,bb(1:5)) = A(i,bb(1:5));
% end
% A = newA & newA';


other.svg_file = '/tmp/okay.pdf';
other.gv_file = '/Users/tomasz/av/demos/frames2/g.gv';
other.png_file = '/tmp/okay.jpg';
other.pdf_file = '/tmp/okay.pdf';
other.plain_file = '/tmp/okay.plain';
other.nodes_file = '/tmp/okay.nodes';
other.gv2_file = '/tmp/okay.gv2';
I=make_memex_graph(A,other);





function res = baser(x)
[a,b,c] = fileparts(x);
res = [b c];

