% filenames = {'20130311_E20_T5_DTA.xml', '20130311_E20_T5_DTA2.1.xml', '20130311_E20_T5_PW.xml', '20130311_E20_T5_PW2.1.xml'};
filenames = {'20130320_E20_T5_maestro_PW2.1.xml', '20130320_E20_T5_maestro_DTA.xml'};


for j = 1:length(filenames)
    filename = filenames{j};
    filename = regexprep(filename,'.RAW','');
    filename = regexprep(filename,'.raw','');
    filename = regexprep(filename,'.xml','');
    
    [mods, it_mods, data] = read_mascot_xml(['input\', filename, '.xml']);
    
    f = fopen(['output\',filename,'.xls'],'w');
    
    fprintf(f, 'Protein\t m/z\t Charge State\t Score\t Scan Number\t Sequence\t  Mods\n');
    
    for i = 1:length(data)
        fprintf(f, [data{i}.protein, '\t']);
        fprintf(f, [num2str(data{i}.pep_exp_mz), '\t']);
        fprintf(f, [num2str(data{i}.pep_exp_z), '\t']);
        fprintf(f, [num2str(data{i}.pep_score), '\t']);
        fprintf(f, [num2str(data{i}.scan_number), '\t']);
        fprintf(f, [data{i}.pep_seq, '\t']);
        
        if ~isempty(data{i}.pep_var_mods)
            [r,c] = size(data{i}.pep_var_mods);
            row = 1;
            while row < r
                fprintf(f, [num2str(data{i}.pep_var_mods{row,1}), ' ', data{i}.pep_var_mods{row,2}, '\t']);
                row = row + 1;
            end
            fprintf(f, [num2str(data{i}.pep_var_mods{r,1}), ' ', data{i}.pep_var_mods{r,2}, '\n']);
        else
            fprintf(f,'\n');
        end
    end
    fclose(f);
end