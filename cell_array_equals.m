function out = cell_array_equals(a1, a2)
out = true;

[r1,~] = size(a1);
[r2,~] = size(a2);

if r1 == r2
    for i = 1:r1
        if ~(a1{i,1} == a2{i,1} && strcmp(a1{i,2},a2{i,2}))
           out = false; 
        end            
    end
else
   out = false; 
end
    
end