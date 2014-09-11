function out = gen_possible_seq(seq, pY, pS, pT, oM)

nY = all_comb(length(pY));
nS = all_comb(length(pS));
nT = all_comb(length(pT));
nM = all_comb(length(oM));

out = {};

if ~isempty(nY) && ~isempty(nS) && ~isempty(nT) && ~isempty(nM)
    for i = 1:length(nY)
        for j = 1:length(nS)
            for k = 1:length(nT)
                for l = 1:length(nM)
                    temp_seq = seq;                    
                    temp_seq(pY(find(nY(i,:)))) = 'y';
                    temp_seq(pS(find(nS(j,:)))) = 's';
                    temp_seq(pT(find(nT(k,:)))) = 't';
                    temp_seq(oM(find(nM(l,:)))) = 'm';
                    out{end+1} = temp_seq;
                end
            end
        end
    end
elseif ~isempty(nY) && ~isempty(nS) && ~isempty(nT) && isempty(nM)
    for i = 1:length(nY)
        for j = 1:length(nS)
            for k = 1:length(nT)
                temp_seq = seq;
                temp_seq(pY(find(nY(i,:)))) = 'y';
                temp_seq(pS(find(nS(j,:)))) = 's';
                temp_seq(pT(find(nT(k,:)))) = 't';
                out{end+1} = temp_seq;
            end
        end
    end
elseif ~isempty(nY) && ~isempty(nS) && isempty(nT) && ~isempty(nM)
    for i = 1:length(nY)
        for j = 1:length(nS)            
            for l = 1:length(nM)
                temp_seq = seq;
                temp_seq(pY(find(nY(i,:)))) = 'y';
                temp_seq(pS(find(nS(j,:)))) = 's';
                
                temp_seq(oM(find(nM(l,:)))) = 'm';
                out{end+1} = temp_seq;
            end            
        end
    end
elseif ~isempty(nY) && isempty(nS) && ~isempty(nT) && ~isempty(nM)
    for i = 1:length(nY)        
        for k = 1:length(nT)
            for l = 1:length(nM)
                temp_seq = seq;
                temp_seq(pY(find(nY(i,:)))) = 'y';
                temp_seq(pT(find(nT(k,:)))) = 't';
                temp_seq(oM(find(nM(l,:)))) = 'm';
                out{end+1} = temp_seq;
            end
        end        
    end
elseif ~isempty(nY) && ~isempty(nS) && ~isempty(nT) && ~isempty(nM)
    for j = 1:length(nS)
        for k = 1:length(nT)
            for l = 1:length(nM)
                temp_seq = seq;
                temp_seq(pS(find(nS(j,:)))) = 's';
                temp_seq(pT(find(nT(k,:)))) = 't';
                temp_seq(oM(find(nM(l,:)))) = 'm';
                out{end+1} = temp_seq;
            end
        end
    end
elseif ~isempty(nY) && ~isempty(nS) && isempty(nT) && isempty(nM)
    for i = 1:length(nY)
        for j = 1:length(nS)
            temp_seq = seq;
            temp_seq(pY(find(nY(i,:)))) = 'y';
            temp_seq(pS(find(nS(j,:)))) = 's';
            out{end+1} = temp_seq;
        end
    end
elseif ~isempty(nY) && isempty(nS) && ~isempty(nT) && isempty(nM)
    for i = 1:length(nY)
        for k = 1:length(nT)
            temp_seq = seq;
            temp_seq(pY(find(nY(i,:)))) = 'y';
            temp_seq(pT(find(nT(k,:)))) = 't';
            out{end+1} = temp_seq;
        end
    end
elseif isempty(nY) && ~isempty(nS) && ~isempty(nT) && isempty(nM)    
    for j = 1:length(nS)
        for k = 1:length(nT)
            temp_seq = seq;
            temp_seq(pS(find(nS(j,:)))) = 's';
            temp_seq(pT(find(nT(k,:)))) = 't';
            out{end+1} = temp_seq;
        end
    end
elseif ~isempty(nY) && isempty(nS) && isempty(nT) && ~isempty(nM)
    for i = 1:length(nY)
        for l = 1:length(nM)
            temp_seq = seq;
            temp_seq(pY(find(nY(i,:)))) = 'y';
            temp_seq(oM(find(nM(l,:)))) = 'm';
            out{end+1} = temp_seq;
        end
    end
elseif isempty(nY) && ~isempty(nS) && isempty(nT) && ~isempty(nM)
        for j = 1:length(nS)
            for l = 1:length(nM)
                temp_seq = seq;
                temp_seq(pS(find(nS(j,:)))) = 's';
                temp_seq(oM(find(nM(l,:)))) = 'm';
                out{end+1} = temp_seq;
            end
        end
elseif isempty(nY) && isempty(nS) && ~isempty(nT) && ~isempty(nM)   
    for k = 1:length(nT)
        for l = 1:length(nM)
            temp_seq = seq;
            temp_seq(pT(find(nT(k,:)))) = 't';
            temp_seq(oM(find(nM(l,:)))) = 'm';
            out{end+1} = temp_seq;
        end
    end
elseif ~isempty(nY) && isempty(nS) && isempty(nT) && isempty(nM)
    for i = 1:length(nY)
        temp_seq = seq;
        temp_seq(pY(find(nY(i,:)))) = 'y';
        out{end+1} = temp_seq;
    end
elseif isempty(nY) && ~isempty(nS) && isempty(nT) && isempty(nM)
    for j = 1:length(nS)
        temp_seq = seq;
        temp_seq(pS(find(nS(j,:)))) = 's';
        out{end+1} = temp_seq;
    end
elseif isempty(nY) && isempty(nS) && ~isempty(nT) && isempty(nM)
    for k = 1:length(nT)
        temp_seq = seq;
        temp_seq(pT(find(nT(k,:)))) = 't';
        out{end+1} = temp_seq;
    end
elseif isempty(nY) && isempty(nS) && isempty(nT) && ~isempty(nM)
    for l = 1:length(nM)
        temp_seq = seq;
        temp_seq(oM(find(nM(l,:)))) = 'm';
        out{end+1} = temp_seq;
    end
else
    out{end+1} = seq;    
end