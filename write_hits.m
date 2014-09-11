fid = fopen('pY_sites.xls','w');

title_line = 'Precursor Scan Number\t Scan Number\t iTRAQ Scan Number\t Peptide Sequence\t Variable Modifications\t mz\t Charge State\t MASCOT Score\t Rank\n';
fprintf(fid, title_line);


for i = 1:length(data)
    data_line = [num2str(data{i}.prec_scan), '\t', num2str(data{i}.scan_number), '\t', num2str(data{i}.iTRAQ_scan), '\t', data{i}.pep_seq, '\t'];
    [r,c] = size(data{i}.pep_var_mods);
    
    % Print first n-1 mods
    for j = 1:r-1
        if data{i}.pep_var_mods{j,1} == 1
            data_line = [data_line, data{i}.pep_var_mods{j,2}, '; '];
        else
            data_line = [data_line, num2str(data{i}.pep_var_mods{j,1}), ' '];
            data_line = [data_line, data{i}.pep_var_mods{j,2}, '; '];
        end
    end
    % Print last mod
    if r > 0
        if data{i}.pep_var_mods{r,1} == 1
            data_line = [data_line, data{i}.pep_var_mods{r,2}];
        else
            data_line = [data_line, num2str(data{i}.pep_var_mods{r,1}), ' '];
            data_line = [data_line, data{i}.pep_var_mods{r,2}];
        end
    end
    data_line = [data_line, '\t', num2str(data{i}.pep_exp_mz), '\t', num2str(data{i}.pep_exp_z), '\t', num2str(data{i}.pep_score), '\t', num2str(data{i}.pep_rank), '\n'];
    fprintf(fid, data_line);   
end
fclose(fid);