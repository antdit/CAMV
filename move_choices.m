for i = 1:length(old.data)
    if isfield(old.data{i},'fragments')
        for j = 1:length(old.data{i}.fragments)
%             new.data{i}.fragments{j}.status = old.data{i}.fragments{j}.status;            
        end        
    end
end