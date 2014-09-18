% Calculates the fragment masses of the input peptide sequences
%
% Input:
% seq = cell array of strings containing peptide sequences
% iTRAQ_type = {4,8} assumes Lysines are iTRAQ-labeled
%
% Output:
% fragments = cell array of fragments and fragment masses of input peptides

function fragments = fragment_masses2(seq, charge_state, prec_only)
global iTRAQ_masses iTRAQ_names c_term n_term;

global K k I L l M m F T t W V R r H A N D C c E Q G P S s Y y;

global NH3 H2O H3PO4 HPO3 CO2 SOCH4;

% Scan through all sequence inputs
for i = 1:length(seq)
    % Store Peptide Sequence
    fragments{i}.seq = seq{i};
    
    fragments{i}.all = [];
    fragments{i}.all_names = {};
    
    [~,~,~,curr_seq] = regexp(seq{i}, '[A-Za-z]');
    
    loc_m = find_loc(seq{i}, 'm');
    loc_st = find_loc(seq{i}, '[st]');
    loc_y = find_loc(seq{i}, 'y');
    
    
    % Create b-ions
    
    % Carbamidomethyl cysteines present with reduction/alkylation
    if strcmp(curr_seq{1},'C')
       curr_seq{1} = 'c'; 
    end
    
    mass_fragments = [n_term + eval(curr_seq{1})];
        
    for j = 2:length(curr_seq)
        if strcmp(curr_seq{j},'C')
            curr_seq{j} = 'c';
        end
        if strcmp(curr_seq{j},'X')
            mass_fragments(end+1) = mass_fragments(end);
            disp('Unknown Amino Acid');
        else
            mass_fragments(end+1) = mass_fragments(end) + eval(curr_seq{j});
        end
    end
    mass_fragments(end) = mass_fragments(end) + c_term;        
            
    fragments{i}.b_ions = mass_fragments;
    
    % Store Parent mass
    parent = mass_fragments(end);
    
    % Store Precursor Charge State masses
    proton = exact_mass(1,0,0,0,0,0);
    precursor = [parent+proton, (parent+2*proton)/2, (parent+3*proton)/3, (parent+4*proton)/4, (parent+5*proton)/5];
    fragments{i}.precursors = precursor;
    
    % Return more than just parent ions
    if prec_only == 0
        
        precursor_names = {'MH^{+1}' 'MH^{+2}' 'MH^{+3}' 'MH^{+4}' 'MH^{+5}'};
        
        fragments{i}.all = [fragments{i}.all, precursor(1:min(5,charge_state))];
        fragments{i}.all_names = [fragments{i}.all_names, precursor_names(1:min(5,charge_state))];
        
        
        [out_mass, out_names] = b_losses(charge_state, mass_fragments, {'NH_3', 'H_2O', 'H_3PO_4', 'SOCH_4'}, [NH3; H2O; H3PO4; SOCH4], [ones(1,length(mass_fragments)); ones(1,length(mass_fragments)); loc_st'; loc_m']);
        fragments{i}.all = [fragments{i}.all, out_mass];
        fragments{i}.all_names = [fragments{i}.all_names, out_names];
        
        [out_mass, out_names] = b_losses(charge_state, mass_fragments, {'NH_3', 'H_2O', 'HPO_3', 'SOCH_4'}, [NH3; H2O; HPO3; SOCH4], [ones(1,length(mass_fragments)); ones(1,length(mass_fragments)); loc_y'; loc_m']);
        fragments{i}.all = [fragments{i}.all, out_mass];
        fragments{i}.all_names = [fragments{i}.all_names, out_names];
        
        [out_mass, out_names] = b_losses(charge_state, mass_fragments, {'NH_3', 'H_2O', 'HPO_3-H_2O', 'SOCH_4'}, [NH3; H2O; H3PO4; SOCH4], [ones(1,length(mass_fragments)); ones(1,length(mass_fragments)); loc_y'; loc_m']);
        fragments{i}.all = [fragments{i}.all, out_mass];
        fragments{i}.all_names = [fragments{i}.all_names, out_names];
        
        
        mass_fragments = [];
        mass_fragments(1) = [c_term + eval(curr_seq{end}) + exact_mass(2,0,0,0,0,0)];
        
        
        for j = 2:length(curr_seq)
            mass_fragments(j) = mass_fragments(j-1) + eval(curr_seq{length(curr_seq) - j + 1});
        end                
        
%         mass_fragments(end) = mass_fragments(end);

        % iTRAQ 8-plex terminal y adduct
        if length(iTRAQ_masses) == 8
            fragments{i}.all = [fragments{i}.all, mass_fragments(end) + exact_mass(2,2,2,2,0,0), (mass_fragments(end) + exact_mass(2,2,2,2,0,0) + exact_mass(1,0,0,0,0,0))/2];
            fragments{i}.all_names = [fragments{i}.all_names, {['y_{', num2str(length(curr_seq)), '} + 86']}, {['y_{', num2str(length(curr_seq)), '}^{+2}', ' + 43']}];
        end
        
        fragments{i}.y_ions = mass_fragments;
        
        loc_m = find_loc(seq{i}(end:-1:1),'m');
        loc_st = find_loc(seq{i}(end:-1:1),'[st]');
        loc_y = find_loc(seq{i}(end:-1:1),'y');
        
        [out_mass, out_names] = y_losses(charge_state, mass_fragments, {'NH_3', 'H_2O', 'H_3PO_4', 'SOCH_4'}, [NH3; H2O; H3PO4; SOCH4], [ones(1,length(mass_fragments)); ones(1,length(mass_fragments)); loc_st'; loc_m']);
        fragments{i}.all = [fragments{i}.all, out_mass];
        fragments{i}.all_names = [fragments{i}.all_names, out_names];
        
        [out_mass, out_names] = y_losses(charge_state, mass_fragments, {'NH_3', 'H_2O', 'HPO_3', 'SOCH_4'}, [NH3; H2O; HPO3; SOCH4], [ones(1,length(mass_fragments)); ones(1,length(mass_fragments)); loc_y'; loc_m']);
        fragments{i}.all = [fragments{i}.all, out_mass];
        fragments{i}.all_names = [fragments{i}.all_names, out_names];
        
        [out_mass, out_names] = y_losses(charge_state, mass_fragments, {'NH_3', 'H_2O', 'HPO_3-H_2O', 'SOCH_4'}, [NH3; H2O; H3PO4; SOCH4], [ones(1,length(mass_fragments)); ones(1,length(mass_fragments)); loc_y'; loc_m']);
        fragments{i}.all = [fragments{i}.all, out_mass];
        fragments{i}.all_names = [fragments{i}.all_names, out_names];
        
        
        % Other Peaks
        
        % Internal Fragments
        [if_names, if_masses] = internal_fragments(seq{i});
        fragments{i}.all = [fragments{i}.all, if_masses];
        fragments{i}.all_names = [fragments{i}.all_names, if_names];
        
        
        % Phosphotyrosine peak
        if ~isempty(regexp(seq,'y'))
            fragments{i}.all(end+1) = 216.04;
            fragments{i}.all_names = [fragments{i}.all_names, {'pY'}];
        end
        
        % Store iTRAQ masses
        fragments{i}.all = [fragments{i}.all, iTRAQ_masses];
        fragments{i}.all_names = [fragments{i}.all_names, iTRAQ_names];
        
        % Unique peak ID's
        [~,idx] = unique(fragments{i}.all);
        fragments{i}.all = fragments{i}.all(idx);
        fragments{i}.all_names = fragments{i}.all_names(idx);
        
    end
end
end

%% Find peptides that may have particular loss
function out = find_loc(curr_seq, x)
    
    out = zeros(length(curr_seq),1);
    temp = regexp(curr_seq, x);
    if ~isempty(temp)
        out(temp) = 1;
        for i = length(out):-1:1
            out(i) = sum(out(1:i));
        end
    end
end

%% Find all possible losses at each position of the peptide for b and a ions
function [out_mass, out_name] = b_losses(charge_state, mass_fragments, loss_name, loss, loc)
        % mass_fragments
        % loss_name = cell array containing names of losses
        % loss = n-by-1 vector with masses of single losses
        % loc = n-by-length matrix where each row is a vector produced by
        %       find_loc for the corresponding loss
        
        % CO loss for a-ion
        CO = exact_mass(0, 1, 0, 1, 0, 0);
        out_mass = [];
        out_name = {};                
        
        J = length(loss);
        
        % At each position consider all combinations of possible losses
        for i = 1:length(mass_fragments)   
            temp = [];
            for j = J:-1:1
                if j == J
                    temp(J,:) = 0:loc(J,i);
                else
                    [~,col] = size(temp);
                    temp = repmat(temp,1,loc(j,i)+1);
                    for k = 1:loc(j,i)
                        temp(j, k*col + 1: (k+1)*col) = k;
                    end
                end
            end
            temp = temp';
            out_mass = [out_mass, (mass_fragments(i) - temp * loss)', ((mass_fragments(i) - temp * loss + 1)/2)', (mass_fragments(i) -temp * loss - CO)', ((mass_fragments(i) - temp * loss - CO + 1)/2)'];
            
            for j = 1:length(temp)
                temp_name = [];
                for k = 1:length(loss_name)
                    if temp(j,k) > 0                        
                        if temp(j,k) == 1
                            temp_name = [temp_name, '-', loss_name{k}];
                        else
                            temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                        end
                    end
                end
                out_name{end+1} = ['b_{', num2str(i), '}', temp_name];
            end
            
            for j = 1:length(temp)
                temp_name = [];
                for k = 1:length(loss_name)
                    if temp(j,k) > 0
                        if temp(j,k) == 1
                            temp_name = [temp_name, '-', loss_name{k}];
                        else
                            temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                        end
                    end
                end
                out_name{end+1} = ['b_{', num2str(i), '}', temp_name, '^{+2}'];
            end
            
            for j = 1:length(temp)
                temp_name = [];
                for k = 1:length(loss_name)
                    if temp(j,k) > 0
                        if temp(j,k) == 1
                            temp_name = [temp_name, '-', loss_name{k}];
                        else
                            temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                        end
                    end
                end
                out_name{end+1} = ['a_{', num2str(i), '}', temp_name];
            end
            
            for j = 1:length(temp)
                temp_name = [];
                for k = 1:length(loss_name)
                    if temp(j,k) > 0
                        if temp(j,k) == 1
                            temp_name = [temp_name, '-', loss_name{k}];
                        else
                            temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                        end
                    end
                end
                out_name{end+1} = ['a_{', num2str(i), '}', temp_name, '^{+2}'];
            end
            
            if charge_state >= 3
                out_mass = [out_mass, ((mass_fragments(i) - temp * loss + 2)/3)', ((mass_fragments(i) - temp * loss - CO + 2)/3)'];
                for j = 1:length(temp)
                    temp_name = [];
                    for k = 1:length(loss_name)
                        if temp(j,k) > 0
                            if temp(j,k) == 1
                                temp_name = [temp_name, '-', loss_name{k}];
                            else
                                temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                            end
                        end
                    end
                    out_name{end+1} = ['b_{', num2str(i), '}', temp_name, '^{+3}'];
                end
                for j = 1:length(temp)
                    temp_name = [];
                    for k = 1:length(loss_name)
                        if temp(j,k) > 0
                            if temp(j,k) == 1
                                temp_name = [temp_name, '-', loss_name{k}];
                            else
                                temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                            end
                        end
                    end
                    out_name{end+1} = ['a_{', num2str(i), '}', temp_name, '^{+3}'];
                end
            end
            if charge_state >= 4
                out_mass = [out_mass, ((mass_fragments(i) - temp * loss + 3)/4)', ((mass_fragments(i) - temp * loss - CO + 3)/4)'];
                for j = 1:length(temp)
                    temp_name = [];
                    for k = 1:length(loss_name)
                        if temp(j,k) > 0
                            if temp(j,k) == 1
                                temp_name = [temp_name, '-', loss_name{k}];
                            else
                                temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                            end
                        end
                    end
                    out_name{end+1} = ['b_{', num2str(i), '}', temp_name, '^{+4}'];
                end
                for j = 1:length(temp)
                    temp_name = [];
                    for k = 1:length(loss_name)
                        if temp(j,k) > 0
                            if temp(j,k) == 1
                                temp_name = [temp_name, '-', loss_name{k}];
                            else
                                temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                            end
                        end
                    end
                    out_name{end+1} = ['a_{', num2str(i), '}', temp_name, '^{+4}'];
                end
            end
            
            
            
            % Precursor loss peaks with all possible losses
            if i == length(mass_fragments)
%                 for m = 1:5
                for m = 1:min([charge_state,5])
                    out_mass = [out_mass, ((mass_fragments(end) - temp * loss + m * exact_mass(1,0,0,0,0,0))/m)'];
                    for j = 1:length(temp)
                        temp_name = [];
                        for k = 1:length(loss_name)
                            if temp(j,k) > 0
                                if temp(j,k) == 1
                                    temp_name = [temp_name, '-', loss_name{k}];
                                else
                                    temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                                end
                            end
                        end
                        if m == 1
                            out_name{end+1} = ['MH', temp_name];
                        else
                            out_name{end+1} = ['MH', temp_name, '^{+', num2str(m), '}'];
                        end
                    end
                end
            end
        end        
end
    
%% Find all possible losses at each position of the peptide for y ions
function [out_mass, out_name] = y_losses(charge_state, mass_fragments, loss_name, loss, loc)
        % mass_fragments
        % loss_name = cell array containing names of losses
        % loss = n-by-1 vector with masses of single losses
        % loc = n-by-length matrix where each row is a vector produced by
        %       find_loc for the corresponding loss
        
        out_mass = [];
        out_name = {};                
        
        J = length(loss);
        
        % At each position consider all combinations of possible losses
        for i = 1:length(mass_fragments)   
            temp = [];
            for j = J:-1:1
                if j == J
                    temp(J,:) = 0:loc(J,i);
                else
                    [~,col] = size(temp);
                    temp = repmat(temp,1,loc(j,i)+1);
                    for k = 1:loc(j,i)
                        temp(j, k*col + 1: (k+1)*col) = k;
                    end
                end
            end
            temp = temp';
            out_mass = [out_mass, (mass_fragments(i) - temp * loss)', ((mass_fragments(i) - temp * loss + 1)/2)'];
            
            for j = 1:length(temp)
                temp_name = [];
                for k = 1:length(loss_name)
                    if temp(j,k) > 0                        
                        if temp(j,k) == 1
                            temp_name = [temp_name, '-', loss_name{k}];
                        else
                            temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                        end
                    end
                end
                out_name{end+1} = ['y_{', num2str(i), '}', temp_name];
            end
            
            for j = 1:length(temp)
                temp_name = [];
                for k = 1:length(loss_name)
                    if temp(j,k) > 0
                        if temp(j,k) == 1
                            temp_name = [temp_name, '-', loss_name{k}];
                        else
                            temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                        end
                    end
                end
                out_name{end+1} = ['y_{', num2str(i), '}', temp_name, '^{+2}'];
            end                        
            if charge_state >= 3
                out_mass = [out_mass, ((mass_fragments(i) - temp * loss + 2)/3)'];
                for j = 1:length(temp)
                    temp_name = [];
                    for k = 1:length(loss_name)
                        if temp(j,k) > 0
                            if temp(j,k) == 1
                                temp_name = [temp_name, '-', loss_name{k}];
                            else
                                temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                            end
                        end
                    end
                    out_name{end+1} = ['y_{', num2str(i), '}', temp_name, '^{+3}'];
                end
            end
            if charge_state >= 4
                out_mass = [out_mass, ((mass_fragments(i) - temp * loss + 3)/4)'];
                for j = 1:length(temp)
                    temp_name = [];
                    for k = 1:length(loss_name)
                        if temp(j,k) > 0
                            if temp(j,k) == 1
                                temp_name = [temp_name, '-', loss_name{k}];
                            else
                                temp_name = [temp_name, '-', num2str(temp(j,k)),loss_name{k}];
                            end
                        end
                    end
                    out_name{end+1} = ['y_{', num2str(i), '}', temp_name, '^{+4}'];
                end
            end
        end        
end