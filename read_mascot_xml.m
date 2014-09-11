% Pulls informations from MASCOT search output xml file into a struct
%
% Input: 
%   filename:    String containing filename of MASCOT search results (.xml)
%
% Output:
%   mods: Struct with names of fixed modifications
%   it_mods: Struct with names of variable modifications
%   out: Struct with fields:    query
%                               protein
%                               pep_seq
%                               scan_number
%                               scan_data

% Version support: Mascot 2.1.03
%                         2.4.1

function [mods, it_mods, out] = read_mascot_xml(filename)

fid = fopen(filename);

mods = {};
it_mods = {};
out = {};
index = 1;

protein = '';

version = '';

while isempty(version)
    line = fgetl(fid);
    if ~isempty(strfind(line,'<MascotVer>'))        
        version = line;
        version = regexprep(version,'<MascotVer>','');
        version = regexprep(version,'</MascotVer>','');    
    end        
end

if strcmp(version, '2.1.03')
    % Get query number, protein, and sequence
    while ~feof(fid) && ~strcmp(line, '</hits>')
        line = fgetl(fid);
        
        if ~isempty(strfind(line,'<MODS>'))
            line = regexprep(line,'<MODS>','');
            line = regexprep(line,'</MODS>','');
            
            [str,rem] = strtok(line,',');
            if ~isempty(str)
                mods{1} = str;
            end
            while ~isempty(rem)
                [str,rem] = strtok(rem,',');
                mods{end+1} = str;
            end
        elseif ~isempty(strfind(line,'<IT_MODS>'))
            line = regexprep(line,'<IT_MODS>','');
            line = regexprep(line,'</IT_MODS>','');
            
            [str,rem] = strtok(line,',');
            if ~isempty(str)
                it_mods{1} = str;
            end
            while ~isempty(rem)
                [str,rem] = strtok(rem,',');
                it_mods{end+1} = str;
            end
            
        elseif ~isempty(strfind(line,'<protein accession'))
            line = regexprep(line,'<protein accession="','');
            gi = regexprep(line,'">','');
        elseif ~isempty(strfind(line,'<prot_desc>'))
            line = regexprep(line,'<prot_desc>','');
            protein = regexprep(line,'</prot_desc>','');
        elseif ~isempty(strfind(line,'<peptide query='))
            line = regexprep(line,'<peptide query="','');
            out{index}.gi = gi;
            out{index}.protein = protein;
            out{index}.query = str2num(regexprep(line,'">',''));
        elseif ~isempty(strfind(line,'<pep_exp_mz>'))
            line = regexprep(line,'<pep_exp_mz>','');
            out{index}.pep_exp_mz = str2num(regexprep(line,'</pep_exp_mz>',''));
        elseif ~isempty(strfind(line,'<pep_exp_z>'))
            line = regexprep(line,'<pep_exp_z>','');
            out{index}.pep_exp_z = str2num(regexprep(line,'</pep_exp_z>',''));
        elseif ~isempty(strfind(line,'<pep_score>'))
            line = regexprep(line,'<pep_score>','');
            out{index}.pep_score = str2num(regexprep(line,'</pep_score>',''));
        elseif ~isempty(strfind(line,'<pep_rank>'))
            line = regexprep(line,'<pep_rank>','');
            out{index}.pep_rank = str2num(regexprep(line,'</pep_rank>',''));
        elseif ~isempty(strfind(line,'<pep_seq>'))
            line = regexprep(line,'<pep_seq>','');
            out{index}.pep_seq = regexprep(line,'</pep_seq>','');
        elseif ~isempty(strfind(line,'<pep_var_mod>'))
            line = regexprep(line,'<pep_var_mod>','');
            line = regexprep(line,'</pep_var_mod>','');
            
            pep_var_mods = {};
            [str,rem] = strtok(line,';');
            if ~isempty(str)
                if ~isempty(regexp(str,'plex'))
                    pep_var_mods{1,1} = 1;
                    pep_var_mods{1,2} = str;
                else
                    [~,e,~,d] = regexp(str,'^[0-9]+');
                    if ~isempty(d)
                        pep_var_mods{1,1} = str2num(d{1});
                        pep_var_mods{1,2} = str(e(1)+2:end);
                    else
                        pep_var_mods{1,1} = 1;
                        pep_var_mods{1,2} = str;
                    end
                end
            else
                pep_var_mods = {};
            end
            while ~isempty(rem)
                [str,rem] = strtok(rem,';');
                str = str(2:end);
                [a,~] = size(pep_var_mods);
                if ~isempty(regexp(str,'plex'))
                    pep_var_mods{a+1,1} = 1;
                    pep_var_mods{a+1,2} = str;
                else
                    [~,e,~,d] = regexp(str,'^[0-9]+');
                    if ~isempty(d)
                        pep_var_mods{a+1,1} = str2num(d{1});
                        pep_var_mods{a+1,2} = str(e(1)+2:end);
                    else
                        pep_var_mods{a+1,1} = 1;
                        pep_var_mods{a+1,2} = str;
                    end
                end
            end
            out{index}.pep_var_mods = pep_var_mods;
            index = index+1;
        elseif ~isempty(strfind(line,'<pep_var_mod/>'))
            out{index}.pep_var_mods = {};
            index = index+1;
        end
    end
    
    scan_map = {};
    index = 1;
    
    while ~feof(fid)
        line = fgetl(fid);
        if ~isempty(strfind(line,'<query number='))
            [~,~,~,query_number] = regexp(line,'[0-9]*');
            scan_map{index}.query = str2num(query_number{1});
        elseif ~isempty(strfind(line,'<StringTitle>'))
            line = regexprep(line,'<StringTitle>','');
            line = regexprep(line,'</StringTitle>','');
            
            found = false;
            [str,rem] = strtok(line,':');
            while ~found && ~isempty(rem)
                if ~isempty(strfind(str,'MStype'))
                    [~,~,~,d] = regexp(str,'[0-9]*');
                    scan_map{index} = num2str(d{1});
                    found = true;
                end
                [str,rem] = strtok(rem,':');
            end
            index = index + 1;
        end
    end
    
    for i = 1:length(out)
        query_number = out{i}.query;
        out{i}.scan_number = str2num(scan_map{query_number});
        %     out{i}.scan_data = scan_map{query_number}.input;
    end
    
elseif strcmp(version, '2.4.1')
    query_used = [];
    index = 1;
    while ~feof(fid) && ~strcmp(line, '</hits>')
        line = fgetl(fid);
        
        if strcmp(line, '<fixed_mods>')
            % Collect list of fixed modifications used in search
            while ~strcmp(line, '</fixed_mods>')
                if ~isempty(strfind(line, '<name>'))
                    line = regexprep(line, '<name>', '');
                    line = regexprep(line, '</name>', '');
                    mods{end+1} = line;
                end
                line = fgetl(fid);
            end                
        elseif strcmp(line, '<variable_mods>')
            % Collect list of variable modifications used in search
            while ~strcmp(line, '</variable_mods>')
                if ~isempty(strfind(line, '<name>'))
                    line = regexprep(line, '<name>', '');
                    line = regexprep(line, '</name>', '');
                    it_mods{end+1} = line;
                end
                line = fgetl(fid);
            end        
       elseif ~isempty(strfind(line,'<protein accession'))
            line = regexprep(line,'<protein accession="','');
            gi = regexprep(line,'" member.+','');
        elseif ~isempty(strfind(line,'<prot_desc>'))
            line = regexprep(line,'<prot_desc>','');
            protein = regexprep(line,' OS=.+','');
        elseif ~isempty(strfind(line,'<peptide query='))
%             line = regexprep(line,'<peptide query="','');
            out{index}.gi = gi;
            out{index}.protein = protein;
            
            
            line1 = regexprep(line, '<peptide query="', '');
            line1 = regexprep(line1, '" rank=.*', '');                       
            out{index}.query = str2num(line1);
            
            query_used(index) = str2num(line1);
            
            line2 = regexprep(line, '.*rank="','');
            line2 = regexprep(line2, '" isbold.*', '');           
            out{index}.pep_rank = str2num(line2);
            
            
        elseif ~isempty(strfind(line,'<pep_exp_mz>'))
            line = regexprep(line,'<pep_exp_mz>','');
            out{index}.pep_exp_mz = str2num(regexprep(line,'</pep_exp_mz>',''));
        elseif ~isempty(strfind(line,'<pep_exp_z>'))
            line = regexprep(line,'<pep_exp_z>','');
            out{index}.pep_exp_z = str2num(regexprep(line,'</pep_exp_z>',''));
        elseif ~isempty(strfind(line,'<pep_score>'))
            line = regexprep(line,'<pep_score>','');
            out{index}.pep_score = str2num(regexprep(line,'</pep_score>',''));
%         elseif ~isempty(strfind(line,'<pep_rank>'))
%             line = regexprep(line,'<pep_rank>','');
%             out{index}.pep_rank = str2num(regexprep(line,'</pep_rank>',''));
        elseif ~isempty(strfind(line,'<pep_seq>'))
            line = regexprep(line,'<pep_seq>','');
            out{index}.pep_seq = regexprep(line,'</pep_seq>','');
        elseif ~isempty(strfind(line,'<pep_var_mod>'))
            line = regexprep(line,'<pep_var_mod>','');
            line = regexprep(line,'</pep_var_mod>','');
            
            pep_var_mods = {};
            [str,rem] = strtok(line,';');
            if ~isempty(str)
                if ~isempty(regexp(str,'plex'))
                    pep_var_mods{1,1} = 1;
                    pep_var_mods{1,2} = str;
                else
                    [~,e,~,d] = regexp(str,'^[0-9]+');
                    if ~isempty(d)
                        pep_var_mods{1,1} = str2num(d{1});
                        pep_var_mods{1,2} = str(e(1)+2:end);
                    else
                        pep_var_mods{1,1} = 1;
                        pep_var_mods{1,2} = str;
                    end
                end
            else
                pep_var_mods = {};
            end
            while ~isempty(rem)
                [str,rem] = strtok(rem,';');
                str = str(2:end);
                [a,~] = size(pep_var_mods);
                if ~isempty(regexp(str,'plex'))
                    pep_var_mods{a+1,1} = 1;
                    pep_var_mods{a+1,2} = str;
                else
                    [~,e,~,d] = regexp(str,'^[0-9]+');
                    if ~isempty(d)
                        pep_var_mods{a+1,1} = str2num(d{1});
                        pep_var_mods{a+1,2} = str(e(1)+2:end);
                    else
                        pep_var_mods{a+1,1} = 1;
                        pep_var_mods{a+1,2} = str;
                    end
                end
            end
            out{index}.pep_var_mods = pep_var_mods;
            index = index+1;
        elseif ~isempty(strfind(line,'<pep_var_mod/>'))
            out{index}.pep_var_mods = {};
            index = index+1;
        end
    end
    
    qs_map = [];
    prev_query = 0;
    while ~feof(fid)
        line = fgetl(fid);
        if regexp(line,'<q_peptide query="[0-9]+" rank="1"')
            [~,~,~,query_number] = regexp(line,'[0-9]*');                        
            curr_query = str2num(query_number{1});
        
            while isempty(strfind(line, '</q_peptide>'))
                line = fgetl(fid);
                
                if ~isempty(strfind(line,'<pep_scan_title>'))
%                     line = regexprep(line,'.*Spectrum','');
%                     line = regexprep(line,' scans.*','');
                    
                    line = regexprep(line,'.*scans:','');
                    line = regexprep(line,',</pep_scan_title>','');

                    curr_scan = str2num(line);                   
                    
                    if curr_query ~= prev_query
                        qs_map(end+1, :) = [curr_query str2num(line)];
                        prev_query = curr_query;
                    end
%                     out_idx = find(query_used == curr_query);
%                     if ~isempty(out_idx)
%                         for i = 1:length(out_idx)
%                             out{out_idx(i)}.scan_number = str2num(line);
%                             found = 1;
%                         end
%                     end
                end
            end                       
        end
    end
    for i = 1:length(out)        
        out{i}.scan_number = qs_map(qs_map(:,1) == out{i}.query, 2);
    end
else
    warndlg('Unsupported Version of Mascot.');
    error('read_mascot_xml:Mascot', 'Unsupported Version of Mascot.');
end
fclose(fid);
