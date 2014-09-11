% Compare an actual spectra to predicted fragmentation pattern
%
% Inputs:
%   predicted:  Element of struct produced by fragment_masses.m
%   actual:     Measured spectra
%   tol:        Error tolerance between predicted and actual
%
% Outputs:
%   out:        {:,1} - observed m/z
%               {:,2} - assigned ion name
%               {:,3} - predicted ion m/z
%               {:,4} - observed intensity
%               {:,5} - percent error (m/z)
%               {:,6} - cell array of other ion possibilities
%                       {:,1} - ion name
%                       {:,2} - score
%                       {:,3} - m/z

function out = compare_spectra(predicted, actual, tol)

[~,idx] = sort(actual(:,1));
actual = actual(idx,:);

AA{1} = [60.0444; %S
    70.0651; %R/P
    72.0808; %V
    74.0600; %T
    84.0444; %Q
    84.0808; %K
    86.0964; %I/L
    87.0553; %N
    87.0917; %R
    88.0393; %D
    100.0869; %R
    101.0709; %Q
    101.1073; %K
    102.0550; %E
    104.0528; %M
    110.0713; %H
    112.0869; %R
    120.0808; %F
    126.0550; %P
    126.0913; %K
    129.0659; %Q
    129.1022; %K
    136.0757; %Y
    138.0662; %H
    159.0917]; %W

AA{2} = {'S', 'R/P', 'V', 'T', 'Q', 'K', 'I/L', 'N', 'R', 'D', 'R', 'Q', 'K', 'E', 'M', 'H', 'R', 'F', 'P', 'K', 'Q', 'K', 'Y', 'H', 'W'};

out = {};
out{1,2} = '';

[r,~] = size(actual);

for i = 1:r
    out{i,1} = actual(i,1);
    isotope = 0;        
    % Check for isotope peak of +1 or +2 peak    
    if i > 1 && min(abs(actual(i,1) - actual(i-1,1) - [1, 0.5]))/actual(i,1) < tol
        if ~isempty(out{i-1,2})
            if actual(i,2) < actual(i-1,2)
                out{i,2} = 'isotope';
                out{i,3} = 'C13';
                out{i,4} = actual(i,2);                   
                
                out{i,6} = {'isotope',10,actual(i,2)};
                
                isotope = 1;
            end
        end                
    end
    
    if isotope == 0
        % Check for known sequence peak
        clear idx;
        clear all_matches;
        idx = find(abs((predicted.all - actual(i))./predicted.all) < 1.5*tol);                  
        
        
        
        if ~isempty(idx)
            best_score = 1;
            if length(idx) > 1
                score = [];
                all_matches = {};
                closest_ion = [1, 10];
                for j = 1:length(idx)
                    temp = predicted.all_names{idx(j)};
                    
                    if abs(predicted.all(idx(j)) - actual(i)) < closest_ion(2)
                        closest_ion = [j, abs(predicted.all(idx(j)) - actual(i))];
                    end
                    
                    score(j) = 0;
                    num_losses = [];
                    if strcmp(temp(1),'M')
                        % Bonus for being a parent ion           
                        score(j) = score(j) + 12;                             
                    elseif strcmp(temp(1),'y') || strcmp(temp(1),'b')
                        % Bonus for being a b or y series ion           
                        score(j) = score(j) + 10;
                    end
                    % Penalty for additional losses
                    num_losses = length(regexp(temp,'-'));
                    score(j) = score(j) - num_losses;                                                            
                    all_matches{end+1,1} = temp;
                    all_matches{end,2} = score(j);
                    all_matches{end,3} = predicted.all(idx(j));
                end
                
                % Bonus for closest predicted mass: increase score by 1
                all_matches{closest_ion(1),2} = all_matches{closest_ion(1),2} + 0.5;
                
                
                [r,c] = size(all_matches);               
                for j = 1:r
                    if all_matches{j,2} > all_matches{best_score,2}                        
                        best_score = j;
%                         id = all_matches{1,1};
%                         score = all_matches{1,2};
%                         mass = all_matches{1,3};
%                         all_matches{1,1} = all_matches{j,1};
%                         all_matches{1,2} = all_matches{j,2};
%                         all_matches{1,3} = all_matches{j,3};
%                         
%                         all_matches{j,1} = id;
%                         all_matches{j,2} = score;
%                         all_matches{j,3} = mass;
                    end
                end
                out{i,6} = all_matches;            
            else
                all_matches{1,1} = predicted.all_names{idx};
                all_matches{1,2} = 10;
                all_matches{1,3} = predicted.all(idx);
                out{i,6} = all_matches;
            end
            out{i,2} = all_matches{best_score,1};
            out{i,3} = all_matches{best_score,3};
            out{i,4} = actual(i,2);            
            out{i,5} = abs((all_matches{best_score,3} - actual(i,1))./all_matches{best_score,3});
        else            
            idx = find(abs((AA{1} - actual(i))./AA{1}) < tol);
            if ~isempty(idx)
                if length(idx) > 1
                    [~,idx] = min(abs((AA{1} - actual(i))./AA{1}));
                end
                out{i,2} = AA{2}{idx};
                out{i,3} = AA{1}(idx);
                out{i,4} = actual(i,2);
                out{i,5} = abs((predicted.all(idx) - actual(i,1))./predicted.all(idx));
                out{i,6} = {predicted.all_names{idx},10,predicted.all(idx)};
            else
                out{i,4} = actual(i,2);
                out{i,6} = {};
            end            
        end
    end
end
end

