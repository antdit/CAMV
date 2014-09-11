% seq: peptide sequence
% pY: Number of tyrosine phosphorylations found by MASCOT
% pSTY: Number of STY phosphorylations found by MASCOT
% oM: Number of M oxidations found by MASCOT

function out = gen_possible_seq2(seq, pY, pSTY, oM, acK)
out = {};

% Check that all non-terminal Lysines are acetylated in the presence of
% acK
if acK > 0    
    posK = regexp(seq,'K');
    if (length(posK) == acK && strcmp(seq(end),'R'))
        seq(posK) = 'k';
    elseif (length(posK)-1 == acK && strcmp(seq(end),'K'))
        seq(posK) = 'k';
        seq(end) = 'K';
    else
        return
    end
end

% Check for pY, pSTY, and oM
if pY > 0 && pSTY == 0 && oM > 0
    m = regexp(seq,'M');
    tempM = all_combs(m,oM);
    y = regexp(seq,'Y');
    tempY = all_combs(y,pY);
    
    for i = 1:length(tempM)
       temp_seq1 = seq;
       temp_seq1(tempM{i}) = 'm';
       for j = 1:length(tempY)
          temp_seq2 = temp_seq1;
          temp_seq2(tempY{j}) = 'y';
          out{end+1} = temp_seq2;
       end
    end
    
elseif pSTY>0 && oM > 0
    m = regexp(seq,'M');
    tempM = all_combs(m,oM);
    sty = regexp(seq,'[STY]');
    tempSTY = all_combs(sty, pSTY + pY);
    for i = 1:length(tempM)
        temp_seq1 = seq;
        temp_seq1(tempM{i}) = 'm';
        for j = 1:length(tempSTY)
            temp_seq2 = temp_seq1;
            for k=1:length(tempSTY{j})
                if temp_seq2(tempSTY{j}(k))=='Y'
                    temp_seq2(tempSTY{j}(k)) = 'y';
                elseif temp_seq2(tempSTY{j}(k))=='T'
                    temp_seq2(tempSTY{j}(k)) = 't';
                elseif temp_seq2(tempSTY{j}(k))=='S'
                    temp_seq2(tempSTY{j}(k)) = 's';
                end
            end
            out{end+1} = temp_seq2;
        end     
    end
   
elseif pSTY > 0 && oM == 0
    sty = regexp(seq,'[STY]');
    tempSTY = all_combs(sty, pSTY + pY);
    for i = 1:length(tempSTY)
        temp_seq = seq;
        for j=1:length(tempSTY{i})
            if temp_seq(tempSTY{i}(j))=='Y'
                temp_seq(tempSTY{i}(j)) = 'y';
            elseif temp_seq(tempSTY{i}(j))=='T'
                temp_seq(tempSTY{i}(j)) = 't';
            elseif temp_seq(tempSTY{i}(j))=='S'
                temp_seq(tempSTY{i}(j)) = 's';
            end
        end
        out{end+1} = temp_seq;
    end
elseif pY > 0 && pSTY == 0 && oM == 0 
    y = regexp(seq,'Y');
    tempY = all_combs(y,pY);
    for i = 1:length(tempY)
        temp_seq = seq;
        temp_seq(tempY{i}) = 'y';
        out{end+1} = temp_seq;
    end
elseif pY == 0 && pSTY == 0 && oM > 0
    m = regexp(seq,'M');
    tempM = all_combs(m,oM);    
    for i = 1:length(tempM)
        temp_seq = seq;
        temp_seq(tempM{i}) = 'm';
        out{end+1} = temp_seq;
    end    
else
    out{1} = seq;
end

end

function out = all_combs(sites, num_mods)
    temp = rec_pos(length(sites), num_mods);
    out = {};
    for i = 1:length(temp)
        temp1 = [];
        for j = 1:length(temp{i})
            if temp{i}(j) == 1;
                temp1(end+1) = sites(j);
            end
        end
        out{end+1} = temp1; 
    end
end

function out = rec_pos(len, rem)
    if len == 0;
        % Base case: not positions left
        out = {};
    elseif rem > len        
        % Base case: too many remaining modification
        out = {};
    elseif rem == 0
        % Base case: no remaining modifications
        out{1} = zeros(1,len);
    elseif rem == len
        % Base case: all remaining are modified
        out{1} = ones(1,len);
    else
        % Recursive call
        out0 = rec_pos(len-1,rem);
        out1 = rec_pos(len-1,rem-1);
        
        out = {};
        for i = 1:length(out0);
            out{end+1} = [0,out0{i}];
        end
        for i = 1:length(out1);
            out{end+1} = [1,out1{i}];
        end
    end
end