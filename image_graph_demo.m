function oldway(sequence)

% Compute HOG features per image
x = ecat(emap(@(x)reshape(esvm_hog(imresize_max(toI(x),200),20),[], ...
                          1),sequence),2);

% Compute distances squared between each element
d = distSqr_fast(x);

% Create symmetric matrix by taking top 10% of shortest edges and
% enforcing symmetry
sd = sort(d(:));
thresh = sd(round(.1*length(sd)));
A = d<thresh;
A = A&A';

construct_graph(A,sequence);