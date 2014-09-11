% Returns a matrix, where each row is a permutation of sites to modify
% 
% Input:
%   n:  Number of residues
%
% Output:
%   out: matrix with each row containing a unique set to be modified

function out = all_comb(n)

out = [];

if n>3
    n = 3;
end

for i = 1:n
    temp = [];
    temp = [zeros(1,n-i), ones(1,i)];
    out = [out; unique(perms(temp),'rows')];
end