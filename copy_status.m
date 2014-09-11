function new = copy_status(old_name,new_name)
iTRAQType = 0;
iTRAQ_masses =0;
SILAC_R6 = 0;
SILAC_R10 = 0;
SILAC_K6 = 0;
SILAC_K8 = 0;
cont_thresh = 0;
cont_window = 0;

new_data = load_session(new_name);
old_data = load_session(old_name);

if length(old_data) == length(new_data)
    for i = 1:length(old_data)
        if isfield(old_data{i},'fragments')
            if isfield(new_data{i},'fragments')
                % Copy status of old file to new file when both scans have
                % already been validated
                for j = 1:length(old_data{i}.fragments)
                    new_data{i}.fragments{j}.status = old_data{i}.fragments{j}.status;                    
                end
            end
        end
    end
    save_session(new_name);
else
    disp('Structs of different size')
end

    function data = load_session(filename)
        filename = regexprep(filename,'.mat','');
        
        temp = load(['input\',filename,'.mat']);
        data = temp.data;
        iTRAQType = temp.iTRAQType;
        iTRAQ_masses = temp.iTRAQ_masses;
        SILAC_R6 = temp.SILAC_R6;
        SILAC_R10 = temp.SILAC_R10;
        SILAC_K6 = temp.SILAC_K6;
        SILAC_K8 = temp.SILAC_K8;
        cont_thresh = temp.cont_thresh;
        cont_window = temp.cont_window;
    end

    function save_session(filename)
        data = new_data;
        save(['input\', filename,'.mat'],'data', 'iTRAQType', 'iTRAQ_masses','SILAC_R6','SILAC_R10','SILAC_K6','SILAC_K8','cont_thresh','cont_window');
    end
end