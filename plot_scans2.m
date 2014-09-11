function plot_scans2(data, fragments, filename, tol)

    for j = 1:length(fragments)
        p = figure;
        hold on;
        stem(data.scan_data(:,1),data.scan_data(:,2), 'Marker', 'none');
        [num_id_peaks_max, ~] = size(fragments{j}.validated);
        max_y = 0;
        
        plot_isotope = [];
        plot_good = [];
        plot_med = [];
        plot_miss = [];
        
        for num_id_peaks = 1:num_id_peaks_max
            x = fragments{j}.validated{num_id_peaks,1};            
            y = fragments{j}.validated{num_id_peaks,4};
            max_y = max(y,max_y);
            name = fragments{j}.validated{num_id_peaks,2};
            
            if ~isempty(name)
                if strcmp(name, 'isotope')
                    plot_isotope(end+1,:) = [x y];
%                     plot(x,y,'*y');
                else
                    if fragments{j}.validated{num_id_peaks,5} < tol
                        plot_good(end+1,:) = [x y];
%                         color = '*g';
                    else
                        plot_med(end+1,:) = [x y];
%                         color = '*m';
                    end
%                     plot(x,y,color);
                    text(x,y,name,'FontSize', 8, 'Rotation', 90);
                end
            else
                plot_miss(end+1, :) = [x y];
%                 plot(x,y,'or');
            end            
        end
        
        if ~isempty(plot_good)
            plot(plot_good(:,1), plot_good(:,2), '*g');
        end
        if ~isempty(plot_med)
            plot(plot_med(:,1), plot_med(:,2), '*m');
        end
        if ~isempty(plot_isotope)
            plot(plot_isotope(:,1), plot_isotope(:,2), '*y');
        end
        if ~isempty(plot_miss)            
            plot(plot_miss(:,1), plot_miss(:,2), 'or');
        end
        
        if fragments{j}.validated{1,1} < 250
            xlim(gca, [100,max(fragments{j}.validated{end,1}, 250)]);
        else
            if fragments{j}.validated{end,1} > 250
                xlim(gca, [250,max(fragments{j}.validated{end,1},450)]);
            end
        end
        
        ylim(gca, [0, 1.25*max_y]);
        hold off;
        
        picture_title = [num2str(data.scan_number), ' - ', fragments{j}.seq];
        
        h = figure;             
        objects = allchild(p);
        copyobj(get(p,'children'),h);                
        
        title(picture_title);
        
        picture_title = regexprep(picture_title, 'p', '(p)');
        picture_title = regexprep(picture_title, 's', '(s)');
        picture_title = regexprep(picture_title, 't', '(t)');
        picture_title = regexprep(picture_title, 'm', '(m)');
        picture_title = regexprep(picture_title, 'y', '(y)');
        
        protein_name = regexprep(data.protein, '/', '-');
        protein_name = regexprep(protein_name, ':', '-');
        protein_name = regexprep(protein_name, '\.', '');
                
%         picture_name = ['output/', filename, '/', picture_title];
        picture_name = ['output/all/', protein_name, ' - ', picture_title];
        
        saveas(gca, picture_name,'fig');
        hold off;
        delete(h);
%         close(h);        
        
        pa = gca;
        a = get(pa,'Position');
        a(4) = a(4) - 0.15;
        set(gca, 'Position', a);
         
        picture_title = [num2str(data.scan_number), ' - ', fragments{j}.seq];
        
        picture_title = regexprep(picture_title, 'p', '(p)');
        picture_title = regexprep(picture_title, 's', '(s)');
        picture_title = regexprep(picture_title, 't', '(t)');
        picture_title = regexprep(picture_title, 'm', '(m)');
        picture_title = regexprep(picture_title, 'y', '(y)');
                
%         picture_name = ['output/', filename, '/', picture_title];
        picture_name = ['output/all/', protein_name, ' - ', picture_title];
        
        ylim(gca, [0, 1.25*max_y]);
        
        charge_state = find(abs(fragments{j}.precursors - data.pep_exp_mz) < 1);
        %         protein_name = data.protein;
        
        
        [b_used, y_used] = get_used(fragments{j}.validated, length(fragments{j}.seq));
        
        print_pdf(p, fragments{j}.seq, fragments{j}.b_ions, fragments{j}.y_ions, b_used, y_used, picture_name, charge_state, protein_name, filename, data.scan_number);
        
        hold off;
        delete(p);
%         close(p);
        
        cell2csv([picture_name,'.csv'], fragments{j}.validated);
    end
end



function [b_used, y_used] = get_used(validated, num_res)

b_used = zeros(num_res - 1,1);
y_used = zeros(num_res - 1,1);

rows = size(validated);

for i = 1:rows
    curr_id = validated{i,2};
    if ~isempty(curr_id)    
        if strcmp(curr_id(1), 'y')
            [~,~,~,val] = regexp(curr_id,'[0-9]+');
            y_used(str2num(val{1})) = 1;
        elseif strcmp(curr_id(1), 'a') || strcmp(curr_id(1), 'b')
            [~,~,~,val] = regexp(curr_id,'[0-9]+');
            b_used(str2num(val{1})) = 1;
        end
    end
end
end