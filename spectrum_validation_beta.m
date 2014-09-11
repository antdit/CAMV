function spectrum_validation_beta()
import javax.swing.*
import javax.swing.tree.*;

data = {};
mtree = 0;
jtree = 0;
prev_node = '';
filename = '';

% iTRAQ_type = 8;
iTRAQType = {};
iTRAQ_masses = [];

SILAC = false;
SILAC_R6 = false;
SILAC_R10 = false;
SILAC_K6 = false;
SILAC_K8 = false;

CID_tol = 1e-3;
HCD_tol = 1e-5;

accept_list = {};
maybe_list = {};
reject_list = {};

cont_thresh = 100;
cont_window = 1;

% Tree
h = figure('pos',[150,100,1200,600]);
set(gcf,'name','Spectrum Validation','numbertitle','off', 'MenuBar', 'none');


% Buttons
handle1 = uicontrol('Style', 'pushbutton', 'String', 'Accept',...
    'Enable', 'off',...
    'BackgroundColor', 'g',...
    'Position', [800 20 50 20],...
    'Callback', @accept);

handle2 = uicontrol('Style', 'pushbutton', 'String', 'Maybe',...
    'Enable', 'off',...
    'BackgroundColor', [1 0.5 0.2],...
    'Position', [850 20 50 20],...
    'Callback', @maybe);

handle3 = uicontrol('Style', 'pushbutton', 'String', 'Reject',...
    'Enable', 'off',...
    'BackgroundColor', 'r',...
    'Position', [900 20 50 20],...
    'Callback', @reject);

handle_print_accept = uicontrol('Style', 'pushbutton', 'String', 'Print Accept List',...
    'Enable', 'off',...   
    'Position', [980 20 100 20],...
    'Callback', @print_accepted);

handle_print_maybe = uicontrol('Style', 'pushbutton', 'String', 'Print Maybe List',...
    'Enable', 'off',...   
    'Position', [1080 20 100 20],...
    'Callback', @print_maybe);

% handle_print_curr_ms2 = uicontrol('Style', 'pushbutton', 'String', 'Print Current MS2',...  
%     'Position', [1080 0 100 20],...
%     'Callback', @print_ms2);

handle_process_anyway = uicontrol('Style', 'pushbutton', 'String', 'Process Anyway',...                       
            'Enable', 'off',...
            'Visible', 'off',...
            'Position', [250 525 100 20],...
            'Callback', @process_anyway);

handle_search = uicontrol('Style', 'pushbutton', 'String', 'Search',...                       
            'Enable', 'off',...           
            'Visible', 'off',...
            'Position', [2 2 100 20],...
            'Callback', @search);
        
handle_transfer = uicontrol('Style', 'pushbutton', 'String', 'Transfer Choices',...
            'Enable', 'off',...           
            'Visible', 'off',...
            'Position', [102 2 100 20],...
            'Callback', @transfer);
        
handle_file = uicontrol('Style', 'pushbutton', 'String', 'Get File','Position', [250 20 50 20],'Callback', @upload);
handle_file_continue = uicontrol('Style', 'pushbutton', 'String', 'Load Session','Position', [300 20 75 20],'Callback', @load_session);
handle_file_save = uicontrol('Style', 'pushbutton', 'String', 'Save Session','Position', [375 20 75 20],'Callback', @save_session,'Enable', 'off');

handle_batch_process = uicontrol('Style', 'pushbutton', 'String', 'Batch Process', 'Position', [10, 100, 100, 20], 'Callback', @batch_process);    

ax0 = axes('Position', [0,0,1,1], 'Visible', 'off');
h1 = text(500,20, '', 'Units', 'pixels', 'Interpreter', 'none');
h_code = text(250,550, '', 'Units', 'pixels', 'Interpreter', 'none','FontWeight','bold','Color','r');

% MS2 data
ax1 = axes('Position', [.2,.125,.6,.7], 'TickDir', 'out', 'box', 'off');

% MS2 Peak Assignments
ax1_assign = axes('Position', [.2,.125,.6,.7], 'Visible', 'off');
linkaxes([ax1,ax1_assign],'xy');

% Write Information onto plot
ax1_info = axes('Position', [.2,.125,.6,.7], 'Visible', 'off');

% Precursor Window
ax2 = axes('Position', [.84,.5,.14,.25], 'TickDir', 'out', 'box', 'off');
text(.5,1.1,'Precursor', 'HorizontalAlignment', 'center');

% Now initialized after iTRAQ presence is confirmed
% % iTRAQ Window
ax3 = axes('Position', [.84,.125,.14,.25], 'TickDir', 'out', 'box', 'off','Visible','off');
% text(.5,1.1,'iTRAQ', 'HorizontalAlignment', 'center');

% Precursor Contamination
handle_prec_cont = uicontrol('Style','checkbox','String','Exclude Precursor Contamination?',...
    'Position',[10,500,200,20],...
    'Callback',@prec_cont_checked);

handle_threshold = uicontrol('Style','edit',...
    'Position',[30,480,50,20],...
    'Enable','off');

handle_window = uicontrol('Style','edit',...
    'Position',[30,460,50,20],...
    'Enable','off');

    function prec_cont_checked(hObject,event)
        if get(handle_prec_cont,'Value')
           set(handle_threshold,'Enable','on'); 
           set(handle_window,'Enable','on'); 
        else
           set(handle_threshold,'Enable','off');
           set(handle_window,'Enable','off');
        end
    end

% Scan Number List
handle_scan_number_list = uicontrol('Style','checkbox','String','Use scan list (XLS)?',...
    'Position',[10,400,200,20]);   

axes(ax0);
text(80,490, '%', 'Units', 'pixels', 'Interpreter', 'none');
text(80,470, '+/- m/z', 'Units', 'pixels', 'Interpreter', 'none');

% Handle buttonclick events on tree
    function accept(hObject, event)
        nodes = mtree.getSelectedNodes;   
        node = nodes(1);
        node.setIcon(im2java(imread('green.jpg')));
        jtree.treeDidChange();
        
        % Add to list to be printed
        id = regexp(node.getValue,'\.','split');        
        scan = id{1};
        choice = id{2};
        
        data{str2num(scan)}.fragments{str2num(choice)}.status = 1;
        
        found = 0;
        for i = 1:length(accept_list)
            if strcmp(accept_list{i}.scan,scan) && strcmp(accept_list{i}.choice,choice)
                found = 1;
            end
        end
        if ~found
            accept_list{end+1}.scan = scan;
            accept_list{end}.choice = choice;
                        
            for i = 1:length(reject_list)
                if strcmp(reject_list{i}.scan,scan) && strcmp(reject_list{i}.choice,choice)
                    found = 1;
                    reject_list(i) = '';
                end
            end
            
            if ~found
                for i = 1:length(maybe_list)
                    if strcmp(maybe_list{i}.scan,scan) && strcmp(maybe_list{i}.choice,choice)
                        found = 1;
                        maybe_list(i) = '';
                    end
                end
            end
        end                                
    end

    function reject(hObject, event)
        nodes = mtree.getSelectedNodes;   
        node = nodes(1);
        node.setIcon(im2java(imread('red.jpg')));
        jtree.treeDidChange();
                
        id = regexp(node.getValue,'\.','split');        
        scan = id{1};
        choice = id{2};
        
        data{str2num(scan)}.fragments{str2num(choice)}.status = 3;
        
        found = 0;
        for i = 1:length(reject_list)
            if strcmp(reject_list{i}.scan,scan) && strcmp(reject_list{i}.choice,choice)
                found = 1;
            end
        end
        if ~found
            reject_list{end+1}.scan = scan;
            reject_list{end}.choice = choice;
                        
            for i = 1:length(accept_list)
                if strcmp(accept_list{i}.scan,scan) && strcmp(accept_list{i}.choice,choice)
                    found = 1;
                    accept_list(i) = '';
                end
            end
            
            if ~found
                for i = 1:length(maybe_list)
                    if strcmp(maybe_list{i}.scan,scan) && strcmp(maybe_list{i}.choice,choice)
                        found = 1;
                        maybe_list(i) = '';
                    end
                end
            end
        end         
    end

    function maybe(hObject, event)
        nodes = mtree.getSelectedNodes;   
        node = nodes(1);
        node.setIcon(im2java(imread('orange.jpg')));
        jtree.treeDidChange();
        
        % Add to list to be printed
        id = regexp(node.getValue,'\.','split');  
        scan = id{1};
        choice = id{2};
        
        data{str2num(scan)}.fragments{str2num(choice)}.status = 2;
        
        found = 0;
        for i = 1:length(maybe_list)
            if strcmp(maybe_list{i}.scan,scan) && strcmp(maybe_list{i}.choice,choice)
                found = 1;
            end
        end
        if ~found
            maybe_list{end+1}.scan = scan;
            maybe_list{end}.choice = choice;
                        
            for i = 1:length(reject_list)
                if strcmp(reject_list{i}.scan,scan) && strcmp(reject_list{i}.choice,choice)
                    found = 1;
                    reject_list(i) = '';
                end
            end
            
            if ~found
                for i = 1:length(accept_list)
                    if strcmp(accept_list{i}.scan,scan) && strcmp(accept_list{i}.choice,choice)
                        found = 1;
                        accept_list(i) = '';
                    end
                end
            end
        end                                
    end

% Print plots for scans in "accept" list and write XLS with iTRAQ data
    function print_accepted(hObject, event)
        if length(accept_list) > 0
            if exist(['output\', filename,'\accept']) == 0
                % Make output directory
                mkdir(['output\', filename,'\accept']);
            else
                % Remove files that are no longer accepted
                dir_contents = dir(['output\', filename,'\accept']);
                for i = 3:length(dir_contents)
                    found = 0;
                    for j = 1:length(accept_list)
                        scan = str2num(accept_list{j}.scan);
                        id = str2num(accept_list{j}.choice);
                        
                        seq = data{scan}.fragments{id}.seq;
                        seq = regexprep(seq, 's', '(s)');
                        seq = regexprep(seq, 't', '(t)');
                        seq = regexprep(seq, 'y', '(y)');
                        seq = regexprep(seq, 'm', '(m)');
                        seq = regexprep(seq, 'k', '(k)');
                        
                        fig_name = [data{scan}.protein, ' - ', num2str(data{scan}.scan_number), ' - ', seq];
                        
                        fig_name = regexprep(fig_name, '/', '-');
                        fig_name = regexprep(fig_name, ':', '-');
                        fig_name = regexprep(fig_name, '\.', '');                                                
                        
                        if strcmp(dir_contents(i).name,[fig_name,'.pdf'])
                            found = 1;
                        end                        
                    end
                    if ~found
                        delete(['output\', filename,'\accept\',dir_contents(i).name]);
                    end
                end
            end
            % Print new figures
            for i = 1:length(accept_list)                
                scan = str2num(accept_list{i}.scan);
                id = str2num(accept_list{i}.choice);
                
                seq = data{scan}.fragments{id}.seq;
                seq = regexprep(seq, 's', '(s)');
                seq = regexprep(seq, 't', '(t)');
                seq = regexprep(seq, 'y', '(y)');
                seq = regexprep(seq, 'm', '(m)');
                seq = regexprep(seq, 'k', '(k)');
                
                fig_name = [data{scan}.protein, ' - ', num2str(data{scan}.scan_number), ' - ', seq];
                
                fig_name = regexprep(fig_name, '/', '-');
                fig_name = regexprep(fig_name, ':', '-');
                fig_name = regexprep(fig_name, '\.', '');
                
                if ~exist(['output\',filename,'\accept\',fig_name,'.pdf'],'file')
                    print_pdf(scan, id, ['accept\',fig_name]);
                end
                
            end
            if ~strcmp(iTRAQType{1},'None')
                iTRAQ_to_Excel();
            elseif SILAC
                SILAC_to_Excel();
            end                
        else
            warndlg('No peptide identifications have been selected.','Empty List');
            delete(['output\', filename,'\accept\*.pdf']);
            delete(['output\', filename,'\*.xls'])
        end
    end

% Print plots for scans in "maybe" list
    function print_maybe(hObject, event)
        if length(maybe_list) > 0
            if exist(['output\', filename,'\maybe']) == 0
                % Make output directory
                mkdir(['output\', filename,'\maybe']);
            else
                % Remove files that are no longer accepted
                dir_contents = dir(['output\', filename,'\maybe']);
                for i = 3:length(dir_contents)
                    found = 0;
                    for j = 1:length(maybe_list)
                        scan = str2num(maybe_list{j}.scan);
                        id = str2num(maybe_list{j}.choice);
                        
                        seq = data{scan}.fragments{id}.seq;
                        seq = regexprep(seq, 's', '(s)');
                        seq = regexprep(seq, 't', '(t)');
                        seq = regexprep(seq, 'y', '(y)');
                        seq = regexprep(seq, 'm', '(m)');
                        seq = regexprep(seq, 'k', '(k)');
                        
                        fig_name = [data{scan}.protein, ' - ', num2str(data{scan}.scan_number), ' - ', seq];
                        
                        fig_name = regexprep(fig_name, '/', '-');
                        fig_name = regexprep(fig_name, ':', '-');
                        fig_name = regexprep(fig_name, '\.', '');                                              
                        
                        if strcmp(dir_contents(i).name,[fig_name,'.pdf'])
                            found = 1;
                        end                        
                    end
                    if ~found
                        delete(['output\', filename,'\maybe\',dir_contents(i).name]);
                    end
                end
            end
            for i = 1:length(maybe_list)
                scan = str2num(maybe_list{i}.scan);
                id = str2num(maybe_list{i}.choice);
                
                seq = data{scan}.fragments{id}.seq;
                seq = regexprep(seq, 's', '(s)');
                seq = regexprep(seq, 't', '(t)');
                seq = regexprep(seq, 'y', '(y)');
                seq = regexprep(seq, 'm', '(m)');
                seq = regexprep(seq, 'k', '(k)');
                
                fig_name = [data{scan}.protein, ' - ', num2str(data{scan}.scan_number), ' - ', seq];
                
                fig_name = regexprep(fig_name, '/', '-');
                fig_name = regexprep(fig_name, ':', '-');
                fig_name = regexprep(fig_name, '\.', '');
                
                if ~exist(['output\',filename,'\maybe\',fig_name,'.pdf'],'file')
                    print_pdf(scan, id, ['maybe\',fig_name]);
                end
            end            
        else
            warndlg('No peptide identifications have been selected.','Empty List');
            delete(['output\', filename,'\maybe\*.pdf']);
        end
    end

% Used to make publication quality tiff's of single MS2 scans
    function print_ms2(hObject, event)
        nodes = mtree.getSelectedNodes;
        node = nodes(1);               
        
        scan_curr = regexp(node.getValue,'\.','split');
        scan = str2num(scan_curr{1});
        id = str2num(scan_curr{2});
        
        seq = data{scan}.fragments{id}.seq;
        protein = data{scan}.protein;
        charge_state = data{scan}.pep_exp_z;
        scan_number = data{scan}.scan_number;
        
%         b_ions = data{scan}.fragments{id}.b_ions;
%         y_ions = data{scan}.fragments{id}.y_ions;
        
        b_used = zeros(length(seq),1);
        y_used = zeros(length(seq),1);
        
        [R,~] = size(data{scan}.fragments{id}.validated);
        for r = 1:R
            if ~isempty(data{scan}.fragments{id}.validated{r,2})
                if strcmp(data{scan}.fragments{id}.validated{r,2}(1),'a') || strcmp(data{scan}.fragments{id}.validated{r,2}(1),'b')
                    [~,~,~,d] = regexp(data{scan}.fragments{id}.validated{r,2},'[0-9]*');
                    b_used(str2num(d{1})) = 1;
                elseif strcmp(data{scan}.fragments{id}.validated{r,2}(1),'y')
                    [~,~,~,d] = regexp(data{scan}.fragments{id}.validated{r,2},'[0-9]*');
                    y_used(str2num(d{1})) = 1;
                end
            end
        end
        
        fig2 = figure('pos', [100 100 800 400]);
        set(gca,'Visible','off');
%         % Print PDF friendly scan information and ladder
%         text(-40, 665, protein, 'Units', 'pixels', 'FontSize', 10);
%         text(-40, 650, ['Charge State: +', num2str(charge_state)], 'Units', 'pixels', 'FontSize', 10);
%         text(-40, 635, ['Scan Number: ', num2str(scan_number)], 'Units', 'pixels', 'FontSize', 10);
%         text(-40, 620, ['File Name: ', filename, '.raw'], 'Units', 'pixels', 'FontSize', 10, 'Interpreter', 'none');
        
        x_start = -40;
        y_start = 325;
        
        num_font_size = 5;
        
%         space_x = 20;
        space_x = 10;
%         space_y = 20;
        
%         text(x_start, y_start + space_y, num2str(b_ions(1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
        text(x_start, y_start, seq(1), 'Units', 'pixels', 'HorizontalAlignment', 'Center')
        
        prev = x_start;
        
        for i = 2:length(seq)
            if b_used(i-1) == 1 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '\color{red}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            elseif b_used(i-1) == 1 && y_used(end-i+1) == 0
                text(prev + space_x, y_start, '\color{red}^{\rceil}\color{black}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            elseif b_used(i-1) == 0 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '^{\rceil}\color{red}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            else
                text(prev + space_x, y_start, '^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            end
            
%             if i < length(seq)
%                 text(prev + 2*space_x, y_start + space_y, num2str(b_ions(i)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
%             end
            text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center');
%             text(prev + 2*space_x, y_start - space_y, num2str(y_ions(end-i+1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            prev = prev + 2*space_x;
        end
        
        
        ax1_pdf = axes('Position', [.12,.15,.8,.65], 'TickDir', 'out', 'box', 'off');       
      
        axes(ax1_pdf);        
        stem(data{scan}.scan_data(:,1),data{scan}.scan_data(:,2),'Marker', 'none');                
        plot_assignment(scan,id);
        set(gca, 'TickDir', 'out', 'box', 'off');        
        ylim([0,1.25*max(data{scan}.scan_data(:,2))]);
        
        x_start = 0.95 * data{scan}.fragments{id}.validated{1,1};
        x_end = 1.05 * data{scan}.fragments{id}.validated{end,1};
        
        xlim([x_start,x_end]);                
        xlabel('m/z', 'Fontsize', 20);
        ylabel('Intensity', 'Fontsize', 20);
        
        set(gcf,'PaperPositionMode','auto');
        print(fig2, '-dtiff', '-r600', 'curr_ms2');
        close(fig2);
    end

% Process multiple files
    function batch_process(~,~)
        cd('input');
        [names, path] = uigetfile({'*.raw','RAW Files'}, 'MultiSelect', 'on');
        cd('..');
        if strcmp(class(names),'char')
            filename = names;
            filename = regexprep(filename,'.RAW','');
            filename = regexprep(filename,'.raw','');
            filename = regexprep(filename,'.xml','');            
            
            data = validate_spectra();
        
            print_now(['Saving...', filename]);
            save(['input\', filename,'.mat'],'data', 'iTRAQType', 'iTRAQ_masses','SILAC_R6','SILAC_R10','SILAC_K6','SILAC_K8','cont_thresh','cont_window');
            print_now('');
            
            data = {};
            
            iTRAQType = {};
            iTRAQ_masses = [];

            SILAC = false;
            SILAC_R6 = false;
            SILAC_R10 = false;
            SILAC_K6 = false;
            SILAC_K8 = false;                        
        else
            for i = 1:length(names)
                filename = names{i};
                filename = regexprep(filename,'.RAW','');
                filename = regexprep(filename,'.raw','');
                filename = regexprep(filename,'.xml','');
                
                data = validate_spectra();
                
                print_now(['Saving...', filename]);
                save(['input\', filename,'.mat'],'data', 'iTRAQType', 'iTRAQ_masses','SILAC_R6','SILAC_R10','SILAC_K6','SILAC_K8','cont_thresh','cont_window');
                print_now('');
                
                data = {};
            
                iTRAQType = {};
                iTRAQ_masses = [];

                SILAC = false;
                SILAC_R6 = false;
                SILAC_R10 = false;
                SILAC_K6 = false;
                SILAC_K8 = false;
            end
        end        
    end

% Upload file 
    function upload(~,~)
        cd('input');
        [filename, path] = uigetfile({'*.raw','RAW Files'});
        cd('..');
        tic;
        if filename
            set(handle_file,'Enable', 'off'); 
            set(handle_file_continue,'Enable', 'off'); 
            
            filename = regexprep(filename,'.RAW','');
            filename = regexprep(filename,'.raw','');
            filename = regexprep(filename,'.xml','');            
            
%             data = validate_spectra(filename);                                   
            data = validate_spectra();
            
            [mtree,jtree] = build_tree(filename, data);
            set(handle1,'Enable', 'off');
            set(handle2,'Enable', 'off');
            set(handle3,'Enable', 'off');
            set(handle_print_accept,'Enable', 'on');
            set(handle_print_maybe,'Enable', 'on');
            set(handle_file_save,'Enable', 'on');
            set(handle_search, 'Visible', 'on', 'Enable', 'on');
            set(handle_transfer, 'Visible', 'on', 'Enable', 'on');
            delete(handle_prec_cont);
            delete(handle_threshold);
            delete(handle_scan_number_list);
            delete(handle_batch_process);
        end
        toc;
    end

% Load Session
    function load_session(~,~)
        cd('input');
        [filename, path] = uigetfile({'*.mat','MAT Files'});
        cd('..');
        if filename
            print_now('Loading...');
            set(handle_file,'Enable', 'off'); 
            set(handle_file_continue,'Enable', 'off'); 
            
            filename = regexprep(filename,'.mat','');
            
%             data = validate_spectra(filename);                                   
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
            
            % Initialize AA masses based on iTRAQ type
            init_fragments(iTRAQType{2});
        
            [mtree,jtree] = build_tree(filename, data);
            set(handle1,'Enable', 'off');
            set(handle2,'Enable', 'off');
            set(handle3,'Enable', 'off');
            set(handle_print_accept,'Enable', 'on');
            set(handle_print_maybe,'Enable', 'on');
            set(handle_file_save,'Enable', 'on');
            set(handle_search, 'Visible', 'on', 'Enable', 'on');
            set(handle_transfer, 'Visible', 'on', 'Enable', 'on');
            print_now('');
            delete(handle_prec_cont);
            delete(handle_threshold);
            delete(handle_scan_number_list);
            delete(handle_batch_process);
            
            if ~strcmp(iTRAQType{1},'None')
               set(ax3,'Visible', 'on'); 
            end
        end
    end

% Save Session
    function save_session(~,~)
        SILAC = false;
        print_now('Saving...');
        save(['input\', filename,'.mat'],'data', 'iTRAQType', 'iTRAQ_masses','SILAC_R6','SILAC_R10','SILAC_K6','SILAC_K8','cont_thresh','cont_window');
        print_now('');
    end

% Search by scan number or protein name
    function search(~,~)
        h2 = figure('pos',[400,400,500,200], 'WindowStyle', 'modal');        
        set(gcf,'name','Search','numbertitle','off', 'MenuBar', 'none');
        set(gca,'Position', [0,0,1,1], 'Visible', 'off');
               
        text(10, 150, 'Protein Name:', 'Units', 'pixels');                        
        handle_search_protein = uicontrol('Style','edit','Position',[100 138 200 20],'Enable','on', 'HorizontalAlignment', 'left');
        
        text(10, 125, 'Scan Number:', 'Units', 'pixels');                        
        handle_search_scan_number = uicontrol('Style','edit','Position',[100 113 200 20],'Enable','on', 'HorizontalAlignment', 'left');
                        
        uicontrol('Style', 'pushbutton', 'String', 'Search','Position', [25 10 50 20],'Callback', @SearchCallback);
        
        function SearchCallback(~,~)
            prot_name = get(handle_search_protein,'String');
            scan_num = str2num(get(handle_search_scan_number,'String'));
            if ~isempty(prot_name)
                names = {};
                prev_name = '';
                for i = 1:length(data)                    
                    if ~isempty(regexp(data{i}.protein,prot_name)) && ~strcmp(data{i}.protein,prev_name)                        
                        names{end+1} = data{i}.protein;
                        prev_name = data{i}.protein;
                    end                    
                end
                
                if length(names) == 0
                    msgbox('No Matching Proteins','Warning');
                elseif length(names) == 1                                                            
                    choose_protein(names{1});                    
                else
                    % More than one match
                    close(h2);
                    h2 = figure('pos',[400,400,500,200], 'WindowStyle', 'modal');
                    set(gcf,'name','Search','numbertitle','off', 'MenuBar', 'none');
                    set(gca,'Position', [0,0,1,1], 'Visible', 'off');        
                    text(100, 150, 'Protein Name:', 'Units', 'pixels');   
                    
                    handle_select_protein = uicontrol('Style','listbox','Position',[100 38 200 100], 'String', names);
                    uicontrol('Style', 'pushbutton', 'String', 'Select','Position', [100 10 50 20],'Callback', @SelectNameCallback);                                        
                end
                
            elseif ~isempty(scan_num)
                node = get(mtree.root,'FirstChild');
                found = 0;
                while ~found && ~isempty(node)
                    if get(node,'UserData') == scan_num
                        found = 1;
                    else
                        node = get(node, 'NextNode');                    
                    end
                end
                mtree.setSelectedNode(node);
                prev_node = '';
                close(h2);
            end
            
            function SelectNameCallback(~,~)
                all_names = get(handle_select_protein,'String');
                curr_name = all_names{get(handle_select_protein,'Value')};
                choose_protein(curr_name)
            end
            
            function choose_protein(curr_name)
                node = get(mtree.root,'FirstChild');
                while ~strcmp(get(node,'Name'), curr_name)
                    node = get(node,'NextSibling');
                end
                
                mtree.setSelectedNode(node);
                prev_node = '';
                close(h2);
                
                set(handle1, 'Enable', 'off');
                set(handle2, 'Enable', 'off');
                set(handle3, 'Enable', 'off');
                
                % Clear all Plots
                cla(ax1);
                cla(ax1_assign);
                cla(ax1_info);
                cla(ax2);
                if iTRAQType{2} > 0
                    cla(ax3);
                end
                set(ax1, 'TickDir', 'out', 'box', 'off');
                set(ax2, 'TickDir', 'out', 'box', 'off');
                if iTRAQType{2} > 0
                    set(ax3, 'TickDir', 'out', 'box', 'off');
                end
            end
        end
    end

% Transfer choices from another .mat file for same run
    function transfer(~,~)
        global R K k;
        cd('input');
        [trans_filename, path] = uigetfile({'*.mat','MAT Files'});
        cd('..');
        if trans_filename
            print_now('Loading...');
            set(handle_file,'Enable', 'off'); 
            set(handle_file_continue,'Enable', 'off');                         
            
            trans_filename = regexprep(trans_filename,'.mat','');
            new_data = data;                               
            temp = load(['input\',trans_filename,'.mat']);            
            if (temp.iTRAQType{2} == iTRAQType{2}) && (SILAC_R6 == temp.SILAC_R6) && (SILAC_R10 == temp.SILAC_R10) && (SILAC_K6 == temp.SILAC_K6) && (SILAC_K8 == temp.SILAC_K8)
                if length(new_data) == length(temp.data)
                    print_now('Tranferring...');
                    for i = 1:length(temp.data)
                        if ~isfield(temp.data{i},'code') && isfield(new_data{i},'code')
                            % Scan has been accepted anyway
                                                        
                            %%% PROCESS ANYWAY %%%
                            % Modify masses of SILAC labeled amino acids for current
                            % peptide                            
                            
                            if new_data{i}.r6 > 0
                                R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
                            elseif new_data{i}.r10 > 0
                                R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(10,0,0,0,0,0);
                            else
                                R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0);
                            end
                            
                            if new_data{i}.k6 > 0
                                K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
                                % Acetyl Lysine
                                k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0) + exact_mass(8,0,0,0,0,0);
                            elseif new_data{i}.k8 > 0
                                K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
                                % Acetyl Lysine
                                k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0) + exact_mass(8,0,0,0,0,0);
                            else
                                % iTRAQ
                                if iTRAQType{2} == 4
                                    iTRAQ = 144.1021 + exact_mass(1,0,0,0,0,0);
                                    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
                                elseif iTRAQType{2} == 8
                                    iTRAQ = 304.2054 + exact_mass(1,0,0,0,0,0);
                                    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
                                else
                                    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0);
                                end
                                % Acetyl Lysine, not iTRAQ labeled
                                k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0);
                            end
                            
                            poss_seq = gen_possible_seq2(new_data{i}.pep_seq, new_data{i}.pY, new_data{i}.pSTY, new_data{i}.oM, new_data{i}.acK);
                            
                            if min(size(poss_seq)) > 0
                                fragments = fragment_masses2(poss_seq, new_data{i}.pep_exp_z, 0);
                                
                                % Include all peaks > 10%
                                temp_peaks = new_data{i}.scan_data(:,2)/max(new_data{i}.scan_data(:,2));
                                temp_peaks = find(temp_peaks > 0.1);
                                
                                % Find peaks that are local maximums in empty regions
                                for k_idx = 1:length(new_data{i}.scan_data(:,2))
                                    idx = find(abs(new_data{i}.scan_data(:,1) - new_data{i}.scan_data(k_idx,1)) < 25);
                                    if new_data{i}.scan_data(k_idx,2) == max(new_data{i}.scan_data(idx,2)) && new_data{i}.scan_data(k_idx,2)/max(new_data{i}.scan_data(:,2)) > 0.025
                                        temp_peaks = [temp_peaks; k_idx];
                                    end
                                end
                                temp_peaks = unique(temp_peaks);
                                
                                for j = 1:max(size(fragments))
                                    fragments{j}.validated = compare_spectra(fragments{j}, new_data{i}.scan_data(temp_peaks,:), CID_tol);
                                    fragments{j}.status = 0;
                                end
                                new_data{i}.fragments = fragments;
                                new_data{i} = rmfield(new_data{i},'code');
                            end
                            %%%%%%%%%%%%%%%%%%%%%%
                        end
                        if isfield(temp.data{i},'fragments')
                            for j = 1:length(temp.data{i}.fragments)
                                % Copy choices made for individuals IDs
                                if new_data{i}.fragments{j}.status == 0 
                                    new_data{i}.fragments{j}.status = temp.data{i}.fragments{j}.status;
                                end
                            end
                        end                        
                    end
                    clear data;
                    data = new_data;
                    mtree = 0;
                    jtree = 0;
                    [mtree,jtree] = build_tree(filename, data);
                else
                    msgbox('Files do not match', 'modal')
                end
            else
                msgbox('Files do not match', 'modal')            
            end            
        end    
        clear temp;       
        print_now('');
    end

% Display Message Below Plot
    function print_now(string)
        axes(ax0);        
        delete(h1);        
        h1 = text(500,20, string, 'Units', 'pixels', 'Interpreter', 'none');
        drawnow;
    end

% Display Code Text Above Plot
    function print_code_now(string)
        axes(ax0);
        delete(h_code);
        h_code = text(250,575, string, 'Units', 'pixels', 'Interpreter', 'none','FontWeight','bold','Color','r');
        drawnow;
    end

% Handle mouse click events in uitree
    function mousePressedCallback(~, ~)
        nodes = mtree.getSelectedNodes;
        node = nodes(1);               
        
        scan_curr = regexp(node.getValue,'\.','split');               
        scan_prev = regexp(prev_node,'\.','split');
        
        % New Node selected
        if ~strcmp(node.getValue,prev_node)
            print_code_now('');
            set(handle_process_anyway,'Visible', 'off', 'Enable', 'off');
           if ~isempty(regexp(node.getValue,'root')) || ~isempty(regexp(node.getValue,'protein'))
               % Root or Protein node selected
               set(handle1, 'Enable', 'off');
               set(handle2, 'Enable', 'off');               
               set(handle3, 'Enable', 'off');
               
               % Clear all Plots
               cla(ax1);
               cla(ax1_assign);
               cla(ax1_info);
               cla(ax2);
               if iTRAQType{2} > 0
                   cla(ax3);
               end
               set(ax1, 'TickDir', 'out', 'box', 'off');
               set(ax2, 'TickDir', 'out', 'box', 'off');
               if iTRAQType{2} > 0
                   set(ax3, 'TickDir', 'out', 'box', 'off');
               end
           elseif ~isempty(regexp(node.getValue,'\.'))
               % Particular Peptide Assignment Selected
               set(handle1, 'Enable', 'on');
               set(handle2, 'Enable', 'on');
               set(handle3, 'Enable', 'on');
               
               % Replot new scan and assignment
               cla(ax1);
               cla(ax1_assign);
               cla(ax1_info);
               cla(ax2);
               if iTRAQType{2} > 0
                   cla(ax3);
               end
               
               axes(ax1);
               set(gca, 'TickDir', 'out', 'box', 'off');               
               stem(data{str2num(scan_curr{1})}.scan_data(:,1),data{str2num(scan_curr{1})}.scan_data(:,2),'Marker', 'none');                                                                                                      
               
               axes(ax1_assign)
               display_ladder(str2num(scan_curr{1}),str2num(scan_curr{2}));
               plot_assignment(str2num(scan_curr{1}),str2num(scan_curr{2}));                                             
               
               axes(ax1_info)
               text(0.01, 0.95, ['Scan Number: ', num2str(data{str2num(scan_curr{1})}.scan_number)]);
               
               axes(ax2);
               plot_prec(str2num(scan_curr{1}));
               set(gca, 'TickDir', 'out', 'box', 'off');
               text(.5,1.1,'Precursor', 'HorizontalAlignment', 'center');
               
               if iTRAQType{2} > 0
                   axes(ax3);
                   plot_iTRAQ(str2num(scan_curr{1}));
                   set(gca, 'TickDir', 'out', 'box', 'off');
                   text(.5,1.1,'iTRAQ', 'HorizontalAlignment', 'center');
               end
               
               set(ax1, 'TickDir', 'out', 'box', 'off');
               set(ax2, 'TickDir', 'out', 'box', 'off');               
               if iTRAQType{2} > 0
                   set(ax3, 'TickDir', 'out', 'box', 'off');
               end
%-------------------------------------------------------------------------%
           else
               % Scan Selected
               set(handle1, 'Enable', 'off');
               set(handle2, 'Enable', 'off');               
               set(handle3, 'Enable', 'off');                                            
               
               cla(ax1);
               cla(ax1_assign);
               cla(ax1_info);               
               cla(ax2);
               if iTRAQType{2} > 0
                   cla(ax3);
               end
               
               axes(ax1);
               set(gca, 'TickDir', 'out', 'box', 'off');
               stem(data{str2num(scan_curr{1})}.scan_data(:,1),data{str2num(scan_curr{1})}.scan_data(:,2), 'Marker', 'none');
               ylim([0,1.25*max(data{str2num(scan_curr{1})}.scan_data(:,2))]);
               
               axes(ax1_info)
               text(0.01, 0.95, ['Scan Number: ', num2str(data{str2num(scan_curr{1})}.scan_number)]);
               
               axes(ax2);
               plot_prec(str2num(scan_curr{1}));
               set(gca, 'TickDir', 'out', 'box', 'off');
               
               if iTRAQType{2} > 0
                   axes(ax3);
                   plot_iTRAQ(str2num(scan_curr{1}));
                   set(gca, 'TickDir', 'out', 'box', 'off');
               end
               
               set(ax1, 'TickDir', 'out', 'box', 'off');
               set(ax2, 'TickDir', 'out', 'box', 'off');               
               if iTRAQType{2} > 0
                   set(ax3, 'TickDir', 'out', 'box', 'off');
               end
               
               if isfield(data{str2num(scan_curr{1})},'code') && ~strcmp(data{str2num(scan_curr{1})},'No Possible Sequence')
                                      
                   axes(ax1_assign);
                   print_code_now(data{str2num(scan_curr{1})}.code);
                   %%%%%%%%%%%%
                   set(handle_process_anyway,'Enable','on','Visible','on');                   
                   %%%%%%%%%%%%
               end
           end
           
           prev_node = node.getValue; 
                      
        end
    end

% Handle mouse click on peak label
    function labelCallback(a,~)
        nodes = mtree.getSelectedNodes;
        node = nodes(1);               
        
        scan_curr = regexp(node.getValue,'\.','split');                               
        scan = str2num(scan_curr{1});
        id = str2num(scan_curr{2});
                
        [r,~] = size(data{scan}.fragments{id}.validated);
        curr_name = get(a,'String');
        curr_pos = get(a,'Position');
        curr_ion = 0;
        for i = 1:r
            if strcmp(curr_name,data{scan}.fragments{id}.validated(i,2)) && curr_pos(1) == data{scan}.fragments{id}.validated{i,1}
                curr_ion = i;                
            end
        end
                                
        h2 = figure('pos',[300,300,500,500], 'WindowStyle', 'modal');        
        set(gcf,'name','Rename Peak','numbertitle','off', 'MenuBar', 'none');
        set(gca,'Position', [0,0,1,1], 'Visible', 'off');
        text(.1,.98,['Observed Mass: ', num2str(data{scan}.fragments{id}.validated{curr_ion,1})]);
        text(.1,.94,['Current Label: ', get(a,'String')]);
       
        uicontrol('Style', 'pushbutton', 'String', 'OK','Position', [25 10 50 20],'Callback', @OKCallback);
        uicontrol('Style', 'pushbutton', 'String', 'Cancel','Position', [75 10 50 20],'Callback', @CancelCallback);
        
        rbh = uibuttongroup('Position',[0,0,0.5,0.9],'SelectionChangeFcn', @radioCallback);
        
        [r,~] = size(data{scan}.fragments{id}.validated{curr_ion,6});
        text(280,450,'Mass:','Units','pixels');
        
        if r > 0
            for i = 1:r
                % Show Radio Button with Name                
                temp_h = uicontrol('Style','Radio','String', data{scan}.fragments{id}.validated{curr_ion,6}{i,1},'Parent', rbh, 'Position', [20 400 - (i-1)*50 150 20]);                
                % Show Mass                
                text(280, 410 - (i-1)*50, num2str(data{scan}.fragments{id}.validated{curr_ion,6}{i,3}),'Units','pixels');                
            end
            uicontrol('Style','Radio','String', 'Other:','Parent', rbh, 'Position', [20 400 - r*50 200 20]);            
            handle_other = uicontrol('Style','edit','Position',[50,400-r*50-20,150,20],'Enable','off');
        else
            uicontrol('Style','Radio','String', 'Other:','Parent', rbh, 'Position', [20 400 - r*50 200 20]);            
            handle_other = uicontrol('Style','edit','Position',[50,400-r*50-20,150,20],'Enable','on');
        end
        
        function radioCallback(a,~)
             if strcmp(get(get(a,'SelectedObject'),'String'),'Other:')            
                 set(handle_other,'Enable','on');
             else
                 set(handle_other,'Enable','off');
             end
        end
        
        function OKCallback(~,~)
            if strcmp(get(get(rbh,'SelectedObject'),'String'),'Other:')                
                if ~isempty(get(handle_other,'String'))                    
                    data{scan}.fragments{id}.validated{curr_ion,2} = get(handle_other,'String');
                    data{scan}.fragments{id}.validated{curr_ion,3} = 'unknown';
                    data{scan}.fragments{id}.validated{curr_ion,5} = 'unknown';
                else
                    if isempty(data{scan}.fragments{id}.validated{curr_ion,6})                        
                        data{scan}.fragments{id}.validated{curr_ion,2} = [];
                        data{scan}.fragments{id}.validated{curr_ion,3} = [];
                        data{scan}.fragments{id}.validated{curr_ion,5} = [];
                    end
                end
            else
                name = get(get(rbh,'SelectedObject'),'String');
                data{scan}.fragments{id}.validated{curr_ion,2} = name;
                
                [r,~] = size(data{scan}.fragments{id}.validated{curr_ion,6});
                chosen_id = 0;
                for i = 1:r
                    if strcmp(data{scan}.fragments{id}.validated{curr_ion,6}{i,1},name)
                        chosen_id = i;
                    end
                end                                
                data{scan}.fragments{id}.validated{curr_ion,3} = data{scan}.fragments{id}.validated{curr_ion,6}{chosen_id,3};
                data{scan}.fragments{id}.validated{curr_ion,5} = abs(data{scan}.fragments{id}.validated{curr_ion,6}{chosen_id,3}-data{scan}.fragments{id}.validated{curr_ion,1})/data{scan}.fragments{id}.validated{curr_ion,6}{chosen_id,3};
            end          
            cla(ax1_assign);
            axes(ax1_assign);
            display_ladder(scan,id);
            plot_assignment(scan,id);            
            close(h2);
        end
        function CancelCallback(~,~)
            close(h2);
        end
    end

% Read MASCOT output XML file
    function data = validate_spectra()   
        % Check if precursor contamination exclusion has been activated
        if get(handle_prec_cont,'Value')
            % Get new contamination threshold, default = 100%
            if ~isempty(get(handle_threshold,'String'))
                cont_thresh = str2num(get(handle_threshold,'String'));
            end
            % Get new contamination window, default = 1 m/z
            if ~isempty(get(handle_window,'String'))
                cont_window = str2num(get(handle_window,'String'));
            end
        end
        
        if exist(['output\', filename],'dir') == 0
            mkdir(['output\', filename]);
        end
        print_now(['Reading File: ', filename]);
        
        
        if exist(['input\', filename, '.xml'])
            [mods, it_mods, data] = read_mascot_xml(['input\', filename, '.xml']);
        else
            [mods, it_mods, data] = read_mascot_xml(['input\', filename, '.txt']);
        end
        
        disp(['Size of Data: ', num2str(length(data))]);
        
        % Get information about fixed and variable modifications
        C_carb = false;
        iTRAQType = {'None', 0};
        
        M_Ox = false;
        Y_p = false;
        ST_p = false;
        K_ac = false;
        
        % Include constant modifications
        for i = 1:length(mods)
            if strcmp(mods{i}, 'Carbamidomethyl (C)')
                C_carb = true;
            elseif ~isempty(strfind(mods{i}, 'iTRAQ'))
                if strcmp(mods{i},'iTRAQ8plex (K)') || strcmp(mods{i},'iTRAQ8plex (N-term)')
                    iTRAQType = {'Fixed', 8};
                    iTRAQ_masses = [113.107, 114.11, 115.108, 116.11, 117.11, 118.11, 119.11, 121.12];
                elseif strcmp(mods{i},'iTRAQ4plex (K)') || strcmp(mods{i},'iTRAQ4plex (N-term)')
                    iTRAQType = {'Fixed', 4};
                    iTRAQ_masses = [114.11, 115.108, 116.11, 117.11];
                end
            end
        end
        
        % Include variable modifications
        for i = 1:length(it_mods)
            if strcmp(it_mods{i}, 'Oxidation (M)')
                M_Ox = true;
            elseif strcmp(it_mods{i}, 'Phospho (Y)')
                Y_p = true;
            elseif strcmp(it_mods{i}, 'Phospho (ST)') || strcmp(it_mods{i}, 'Phospho (STY)')
                Y_p = true;
                ST_p = true;
            elseif strcmp(it_mods{i}, 'Acetyl (K)')
                acK = true;
            elseif strcmp(it_mods{i},'iTRAQ8plex (K)') || strcmp(it_mods{i},'iTRAQ8plex (N-term)')
                iTRAQType = {'Variable', 8};
                iTRAQ_masses = [113.107, 114.11, 115.108, 116.11, 117.11, 118.11, 119.11, 121.12];
            elseif strcmp(it_mods{i},'iTRAQ4plex (K)') || strcmp(it_mods{i},'iTRAQ4plex (N-term)')
                iTRAQType = {'Variable', 4};
                iTRAQ_masses = [114.11, 115.108, 116.11, 117.11];
            elseif strcmp(it_mods{i},'Arginine-13C6 (R-13C6) (R)')
                SILAC = 1;
                SILAC_R6 = 1;
            elseif strcmp(it_mods{i},'Arginine-13C615N4 (R-full) (R)')
                SILAC = 1;
                SILAC_R10 = 1;
            elseif strcmp(it_mods{i},'Lysine-13C6 (K-13C6) (K)')
                SILAC = 1;
                SILAC_K6 = 1;
            elseif strcmp(it_mods{i},'Lysine-13C615N2 (K-full) (K)')
                SILAC = 1;
                SILAC_K8 = 1;
            end
        end
        
% %         %------------------------------------%
% %         % Remove scans without iTRAQ
% %         if strcmp(iTRAQType{1},'Variable')
% %             for i = length(data):-1:1
% %                 if isfield(data{i},'pep_var_mods');
% %                     [a,~] = size(data{i}.pep_var_mods);
% %                     has_iTRAQ = 0;
% %                     for j = 1:a
% %                         b = regexp(data{i}.pep_var_mods{j,2},'iTRAQ');
% %                         if length(b) > 0
% %                             has_iTRAQ = 1;
% %                         end
% %                     end
% %                     if ~has_iTRAQ
% %                         if ~isfield(data{i},'code')
% %                             data{i}.code = 'no iTRAQ';
% %                         else
% %                             data{i}.code = [data{i}.code, ' + no iTRAQ'];
% %                         end
% %                         disp('No iTRAQ');
% %                     end
% %                 else
% %                     if ~isfield(data{i},'code')
% %                         data{i}.code = 'no iTRAQ';
% %                     else
% %                         data{i}.code = [data{i}.code, ' + no iTRAQ'];
% %                     end
% %                     disp('No iTRAQ');
% %                 end
% %             end
% %         end
% %         %------------------------------------%
        
        disp(['Size of Data: ', num2str(length(data))]);
        %------------------------------------%
        %------------------------------------%
        % Remove peptides with too many possible combinations of
        % modifications
        for i = length(data):-1:1
            [a,~] = size(data{i}.pep_var_mods);
            pY = 0;
            pSTY = 0;
            oM = 0;
            acK = 0;
            
            for j = 1:a
                if strcmp(data{i}.pep_var_mods{j,2},'Phospho (STY)')
                    pSTY = pSTY + data{i}.pep_var_mods{j,1};
                elseif strcmp(data{i}.pep_var_mods{j,2},'Phospho (ST)')
                    pSTY = pSTY + data{i}.pep_var_mods{j,1};
                elseif strcmp(data{i}.pep_var_mods{j,2},'Phospho (Y)')
                    pY = pY + data{i}.pep_var_mods{j,1};
                elseif strcmp(data{i}.pep_var_mods{j,2},'Oxidation (M)')
                    oM = oM + data{i}.pep_var_mods{j,1};
                elseif strcmp(data{i}.pep_var_mods{j,2},'Acetyl (K)')
                    acK = acK + data{i}.pep_var_mods{j,1};
                end
            end
            
            pep_seq = data{i}.pep_seq;
            num_comb = 1;
            
            if pY > 0
                num_comb = num_comb*nchoosek(length(regexp(pep_seq,'Y')),pY);
            end
            if pSTY > 0
                num_comb = num_comb*nchoosek(length(regexp(pep_seq,'[STY]')),pSTY);
            end
            if oM > 0
                num_comb = num_comb*nchoosek(length(regexp(pep_seq,'M')),oM);
            end
            data{i}.num_comb = num_comb;

            % Remove if too many combinations
            if num_comb > 10
                if ~isfield(data{i},'code')
                    data{i}.code = ['Too Many Combinations: ', num2str(num_comb)];
                else
                    data{i}.code = [data{i}.code, ' + Too Many Combinations: ', num2str(num_comb)];
                end
                disp('Too Many Combinations');
            end
        end
        
        disp(['Size of Data: ', num2str(length(data))]);
        %------------------------------------%
        % Initialize AA masses based on iTRAQ type
        init_fragments(iTRAQType{2});
        
        % Get scan data from RAW file
        scans_used = [];        
        if get(handle_scan_number_list,'Value')            
            if exist(['input\',filename,'.xlsx'],'file')
                % Read only fron scan input list
                temp = unique(xlsread(['input\',filename,'.xlsx']));
                
                for i = 1:length(temp)
                    j = 1;
                    found = 0;
                    while j <= length(data) && ~found
                        if temp(i) == data{j}.scan_number
                            data{j}.used = 1;
                            found = 1;
                        end
                        j = j + 1;
                    end 
                end
                for i = length(data):-1:1
                    if ~isfield(data{i},'used')
                        data(i) = [];
                    end
                end
            else
                print_now('No Scan List File Found');
            end
        end
        
        for i = 1:length(data)
            scans_used = [scans_used, data{i}.scan_number];
        end
        
        scans_used = unique(scans_used);
                        
        %%
        
        % Get MS2 Data
        
        print_now('Getting MS2 Data');
        fid = fopen('config.txt','w');
        scans = [];
        fwrite(fid,'filter="scanNumber');
        
        scan_num = [];
        for i = 1: length(scans_used)
            scans = [scans, ' ', num2str(scans_used(i))];
            scan_num(end+1) = scans_used(i);
        end
        scans = [scans, '"'];
        fwrite(fid,scans);
        fclose(fid);
        
        system(['ProteoWizard\"ProteoWizard 3.0.4323"\msconvert input\', filename, '.raw -o input\ --mzXML -c config.txt']);
        mzXML_out = mzxmlread2(['input\', filename,'.mzXML']);
        delete('config.txt');
        iTRAQ_scans_used = [];
        prec_scans_used = [];
        
        print_now('Storing MS2 Data');
        
        % Transfer MS2 information to data struct
        for i = length(data):-1:1
            idx = find(scans_used == data{i}.scan_number);
            if ~isempty(idx)                               
                data{i}.activation_method = mzXML_out.scan(idx).precursorMz.activationMethod;
                data{i}.prec_scan = mzXML_out.scan(idx).precursorMz.precursorScanNum;
                
                % If a precursor scan is available
                if ~isempty(mzXML_out.scan(idx).precursorMz.precursorScanNum)
                    prec_scans_used(end+1) = mzXML_out.scan(idx).precursorMz.precursorScanNum;
                    if strcmp(data{i}.activation_method,'CID')
                        data{i}.scan_data = [mzXML_out.scan(idx).peaks.mz(1:2:end),mzXML_out.scan(idx).peaks.mz(2:2:end)];
                        if ~strcmp(iTRAQType{1},'None')
                            data{i}.iTRAQ_scan = data{i}.scan_number - 1;
                            iTRAQ_scans_used(end+1) = data{i}.scan_number - 1;
                        end
                    else
                        % Resolve HCD data
                        temp1 = mzXML_out.scan(idx).peaks.mz(1:2:end);
                        temp2 = mzXML_out.scan(idx).peaks.mz(2:2:end);
                        if ~issorted(temp1)
                            [temp1,idx] = unique(temp1);
                            temp2 = temp2(idx);
                        end
                        data{i}.scan_data = mspeaks(temp1, temp2);
                        if ~strcmp(iTRAQType{1},'None')
                            data{i}.iTRAQ_scan = data{i}.scan_number;
                            iTRAQ_scans_used(end+1) = data{i}.scan_number;
                        end
                    end
                else
                    if ~isfield(data{i},'code')
                        data{i}.code = 'No Precursor Scan Number';
                    else
                        data{i}.code = [data{i}.code,' + No Precursor Scan Number'];
                    end
                    disp('No Precursor Scan Number');
                end
            else
                if ~isfield(data{i},'code')
                    data{i}.code = 'No Matching Query';
                else
                    data{i}.code = [data{i}.code, ' + No Matching Query'];
                end
                disp('No Matching Query');
            end
        end
        
        %-------------------------------------------------------------------------%
        % Get iTRAQ data
        if ~strcmp(iTRAQType{1},'None')
            % iTRAQ Window
            ax3 = axes('Position', [.84,.125,.14,.25], 'TickDir', 'out', 'box', 'off');
            text(.5,1.1,'iTRAQ', 'HorizontalAlignment', 'center');
            
            
            print_now('Getting iTRAQ Data');
            iTRAQ_scans_used = unique(iTRAQ_scans_used);
            
            fid = fopen('config.txt','w');
            scans = [];
            
            if iTRAQType{2} == 4
                fprintf(fid,'filter="mzWindow [113,118]"\n');
            elseif iTRAQType{2} == 8
                fprintf(fid,'filter="mzWindow [112,122]"\n');
            end
            
            fwrite(fid,'filter="scanNumber');
            
            for i = 1: length(iTRAQ_scans_used)
                scans = [scans, ' ', num2str(iTRAQ_scans_used(i))];
            end
            scans = [scans, '"'];
            fwrite(fid,scans);
            fclose(fid);
            
            system(['ProteoWizard\"ProteoWizard 3.0.4323"\msconvert input\', filename, '.raw -o input\ --mzXML -c config.txt']);
            
            mzXML_out = mzxmlread2(['input\', filename,'.mzXML']);
            delete('config.txt');
            
            print_now('Storing iTRAQ Data');
            
            for i = 1:length(data)
                idx = find(iTRAQ_scans_used == data{i}.iTRAQ_scan);
                if ~isempty(idx)
                    % Resolve HCD data
                    if length(mzXML_out.scan(idx).peaks.mz) > 0
                        temp1 = mzXML_out.scan(idx).peaks.mz(1:2:end);
                        temp2 = mzXML_out.scan(idx).peaks.mz(2:2:end);
                        if ~issorted(temp1)
                            [temp1,idx] = unique(temp1);
                            temp2 = temp2(idx);
                        end
                        data{i}.iTRAQ_scan_data = mspeaks(temp1, temp2);
                    else
                        data{i}.iTRAQ_scan_data = [];
                    end
                end
            end
        end
        %-------------------------------------------------------------------------%
        % Determine SILAC precursor masses
        
        for i = 1:length(data)
            num_k = length(regexp(data{i}.pep_seq,'[Kk]'));
            num_r = length(regexp(data{i}.pep_seq,'[Rr]'));
            temp_prec = [];
            pSTY = 0;
            pY = 0;
            oM = 0;
            acK = 0;
            r6 = 0;
            r10 = 0;
            k6 = 0;
            k8 = 0;
            
            [a,~] = size(data{i}.pep_var_mods);
            for j = 1:a
                curr_var_mod = data{i}.pep_var_mods{j,2};
                if strcmp(curr_var_mod,'Phospho (STY)')
                    pSTY = pSTY + data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Phospho (ST)')
                    pSTY = pSTY + data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Phospho (Y)')
                    pY = pY + data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Oxidation (M)')
                    oM = oM + data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Acetyl (K)')
                    acK = acK + data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Arginine-13C6 (R-13C6) (R)')
                    r6 = data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Arginine-13C615N4 (R-full) (R)')
                    r10 = data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Lysine-13C6 (K-13C6) (K)')
                    k6 = data{i}.pep_var_mods{j,1};
                elseif strcmp(curr_var_mod,'Lysine-13C615N2 (K-full) (K)')
                    k8 = data{i}.pep_var_mods{j,1};
                end
            end
            data{i}.r6 = r6;
            data{i}.r10 = r10;
            data{i}.k6 = k6;
            data{i}.k8 = k8;
            data{i}.pSTY = pSTY;
            data{i}.pY = pY;
            data{i}.oM = oM;
            data{i}.acK = acK;
            
            if (r6 > 0 && r10 > 0) || (r6 > 0 && k8 > 0) || (k6 > 0 && k8 > 0) || (k6 > 0 && r10 > 0)
                % Mix of Medium and Heavy SILAC assigned in same
                % assignemnt
                if ~isfield(data{i},'code')
                    data{i}.code = 'Mixed SILAC';
                else
                    data{i}.code = [data{i}.code, ' + Mixed SILAC'];
                end
            elseif ((r6 > 0 || k6 > 0) && (r6 < num_r || k6 < num_k)) || ((r10 > 0 || k8 > 0) && (r10 < num_r || k8 < num_k))
                % Mix of SILAC and non-SILAC in same assignment
                if ~isfield(data{i},'code')
                    data{i}.code = 'Mixed SILAC';
                else
                    data{i}.code = [data{i}.code, ' + Mixed SILAC'];
                end
            end
            temp_prec(1) = data{i}.pep_exp_mz - (r6*exact_mass(6,0,0,0,0,0) + ...
                r10*exact_mass(10,0,0,0,0,0) + ...
                k6*exact_mass(6,0,0,0,0,0) + ...
                k8*exact_mass(8,0,0,0,0,0)) / data{i}.pep_exp_z;
            temp_prec(2) = temp_prec(1) + (num_r*exact_mass(6,0,0,0,0,0) + num_k*exact_mass(6,0,0,0,0,0))/data{i}.pep_exp_z;
            temp_prec(3) = temp_prec(1) + (num_r*exact_mass(10,0,0,0,0,0) + num_k*exact_mass(8,0,0,0,0,0))/data{i}.pep_exp_z;
            data{i}.SILAC_prec = temp_prec;            
        end        
                        
        % Get Precursor Scan information
        print_now('Getting Precursor Data');
        prec_scans_used = unique(prec_scans_used);
        
        fid = fopen('config.txt','w');
        scans = [];
        
        fwrite(fid,'filter="scanNumber');
        
        for i = 1: length(prec_scans_used)
            scans = [scans, ' ', num2str(prec_scans_used(i))];
        end
        scans = [scans, '"'];
        fwrite(fid,scans);
        fclose(fid);
        
        system(['ProteoWizard\"ProteoWizard 3.0.4323"\msconvert input\', filename, '.raw -o input\ --mzXML -c config.txt']);
        
        mzXML_out = mzxmlread2(['input\', filename,'.mzXML']);
        delete('config.txt');
        
        print_now('Storing Precursor Data');
        
        for i = length(data):-1:1
            idx = find(prec_scans_used == data{i}.prec_scan);
            if ~isempty(idx)
                % Resolve HCD data
                temp1 = mzXML_out.scan(idx).peaks.mz(1:2:end);
                temp2 = mzXML_out.scan(idx).peaks.mz(2:2:end);
                
                if SILAC
                    % Collect MS1 scan data to accomodate SILAC precursors
                    idx2 = intersect(find(temp1 > data{i}.SILAC_prec(1) - 2),find(temp1 < data{i}.SILAC_prec(3) + 2));
                else
                    % Collect MS1 scan data within 2 m/z units of precursor
                    idx2 = find(abs(temp1 - data{i}.pep_exp_mz) < 2);
                end
                
                temp1 = temp1(idx2);
                temp2 = temp2(idx2);
                
                if ~issorted(temp1)
                    [temp1,idx3] = unique(temp1);
                    temp2 = temp2(idx3);
                end
                if max(size(temp1)) > 2
                    data{i}.prec_scan_data = mspeaks(temp1, temp2);
                else
                    if ~isfield(data{i},'code')
                        data{i}.code = 'Poor MS1 data';
                    else
                        data{i}.code = [data{i}.code, ' + Poor MS1 data'];
                    end
                    disp('Poor MS1 data');
                end
            end
        end
        
        %-------------------------------------------------------------------------%
        
        % Remove precursor contaminated scans from validation list
        size(data);
        r1 = 0;
        r2 = 0;
        if get(handle_prec_cont,'Value')
            for scan = length(data):-1:1
                
                scan_data = data{scan}.prec_scan_data;
                prec = data{scan}.pep_exp_mz;
                scan_data = scan_data(abs(scan_data(:,1) - prec) < cont_window,:);
                
                
                step = 0;
                if isfield(data{scan},'pep_exp_z')
                    step = 1/data{scan}.pep_exp_z;
                end
                
                if step > 0
                    ion_series = prec-5*step:step:prec+5*step;
                    
                    max_int = 0;
                    tol_range = 0.01;
                    for i = 1:length(ion_series)
                        in_range_idx = find(abs(scan_data(:,1) - ion_series(i)) < tol_range);
                        if ~isempty(in_range_idx)
                            max_int = max(max_int,max(scan_data(in_range_idx,2)));
                            scan_data(in_range_idx,2) = 0;
                        end
                    end
                    
                    if (max(scan_data(:,2))/max_int)*100 > cont_thresh
                        if ~isfield(data{scan},'code')
                            data{scan}.code = 'Contaminated Precursor';
                        else
                            data{scan}.code = [data{scan}.code, ' + Contaminated Precursor'];
                        end
                        disp('Contaminated Precursor');
                    end
                else
                    if ~isfield(data{scan},'code')
                        data{scan}.code = 'No Precursor Charge State';
                    else
                        data{scan}.code = [data{scan}.code, ' + No Precursor Charge State'];
                    end
                    disp('No Precursor Charge State');
                end
            end
        end
        disp(['Size of Data: ', num2str(length(data))]);
        
        % Check for Cysteine carbamidomethylation present in MASCOT search
        for i = 1:length(mods)
            if strcmp(mods{i}, 'Carbamidomethyl (C)')
                C_carb = true;
            end
        end
        
        % Check each assignment to each scan
        for i = length(data):-1:1
            disp([num2str(length(data)-i+1), ' of ', num2str(length(data))]);
            print_now(['Validating: ', num2str(length(data)-i+1), ' of ', num2str(length(data))]);
            
            if C_carb && ~isempty(strfind(data{i}.pep_seq,'C'))
                data{i}.pep_seq = regexprep(data{i}.pep_seq,'C', 'c');
            end
            
            % Modify masses of SILAC labeled amino acids for current
            % peptide
            global R K k;
            
            if data{i}.r6 > 0
                R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
            elseif data{i}.r10 > 0
                R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(10,0,0,0,0,0);
            else
                R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0);
            end
            
            if data{i}.k6 > 0
                K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
                % Acetyl Lysine
                k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0) + exact_mass(8,0,0,0,0,0);
            elseif data{i}.k8 > 0
                K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
                % Acetyl Lysine
                k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0) + exact_mass(8,0,0,0,0,0);
            else
                %-----------------------------%
                var_8plex = 0;
                var_4plex = 0;
                
                curr_var_mods = data{i}.pep_var_mods;
                [row, col] = size(curr_var_mods);
                for idx = 1:row
                    if ~isempty(regexp(curr_var_mods{idx,2},'iTRAQ4plex (K)'))
                        var_4plex = 1;
                    elseif ~isempty(regexp(curr_var_mods{idx,2},'iTRAQ8plex (K)'))
                        var_8plex = 1;
                    end
                end
                %-----------------------------%
                % Lysine iTRAQ labeled
                if iTRAQType{2} == 4 || var_4plex
                    iTRAQ = 144.1021 + exact_mass(1,0,0,0,0,0);                                      
                    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
                elseif iTRAQType{2} == 8 || var_8plex
                    iTRAQ = 304.2054 + exact_mass(1,0,0,0,0,0);                    
                    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
                else                                        
                    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0);
                end
                % Acetyl Lysine, not iTRAQ labeled
                k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0);
            end
            
            pep_seq = data{i}.pep_seq;
            
            if ~isempty(regexp(pep_seq,'X'))
                if ~isfield(data{i},'code')
                    data{i}.code = 'Unknown Amino Acid';
                else
                    data{i}.code = [data{i}.code, ' + Unknown Amino Acid'];
                end
            end
            if length(pep_seq) > 50
                if ~isfield(data{i},'code')
                    data{i}.code = 'Sequence Too Long';
                else
                    data{i}.code = [data{i}.code, ' + Sequence Too Long'];
                end
            end
            if data{i}.pep_score < 25
                if ~isfield(data{i},'code')
                    data{i}.code = 'MASCOT Score < 25';
                else
                    data{i}.code = [data{i}.code, ' + MASCOT Score < 25'];
                end
            end
            
            if ~isfield(data{i},'code')
                poss_seq = gen_possible_seq2(pep_seq, data{i}.pY, data{i}.pSTY, data{i}.oM, data{i}.acK);
                
                if min(size(poss_seq)) > 0 %% && max(size(poss_seq)) < 9
                    fragments = fragment_masses2(poss_seq, data{i}.pep_exp_z, 0);
                    
                    
                    % Include all peaks > 10%
                    temp = data{i}.scan_data(:,2)/max(data{i}.scan_data(:,2));
                    temp = find(temp > 0.1);
                    
                    % Find peaks that are local maximums in empty regions
                    for k_idx = 1:length(data{i}.scan_data(:,2))
                        idx = find(abs(data{i}.scan_data(:,1) - data{i}.scan_data(k_idx,1)) < 25);
                        if data{i}.scan_data(k_idx,2) == max(data{i}.scan_data(idx,2)) && data{i}.scan_data(k_idx,2)/max(data{i}.scan_data(:,2)) > 0.025
                            temp = [temp; k_idx];
                        end
                    end
                    temp = unique(temp);
                    
                    % Keep if reasonable number of peaks
                    if length(temp) < 50
                        for j = 1:max(size(fragments))
                            fragments{j}.validated = compare_spectra(fragments{j}, data{i}.scan_data(temp,:), CID_tol);
                            fragments{j}.status = 0;
                        end
                        data{i}.fragments = fragments;
                    else
                        if ~isfield(data{i},'code')
                            data{i}.code = 'Too Many Peaks';
                        else
                            data{i}.code = [data{i}.code, ' + Too Many Peaks'];
                        end
                        disp('Too Many Peaks');
                    end
                else
                    if ~isfield(data{i}, 'code')
                        data{i}.code = 'No Possible Sequence';
                    else
                        data{i}.code = [data{i}.code, ' + No Possible Sequence'];
                    end
                    disp('No Possible Sequence');
                end
            end
        end
    end

% Retrieve Sequences and Assignments for previously excluded ID
    function process_anyway(~,~)        
        print_code_now('Processing...');
        
        nodes = mtree.getSelectedNodes;
        node = nodes(1);
        
        scan_curr = regexp(node.getValue,'\.','split');
        scan = str2num(scan_curr{1});               
          
        % Modify masses of SILAC labeled amino acids for current
        % peptide
        global R K k;
        
        if data{scan}.r6 > 0
            R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
        elseif data{scan}.r10 > 0
            R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(10,0,0,0,0,0);
        else
            R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0);
        end
        
        if data{scan}.k6 > 0
            K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
            % Acetyl Lysine
            k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0) + exact_mass(8,0,0,0,0,0);
        elseif data{scan}.k8 > 0
            K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + exact_mass(6,0,0,0,0,0);
            % Acetyl Lysine
            k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0) + exact_mass(8,0,0,0,0,0);
        else
            %-----------------------------%
            var_8plex = 0;
            var_4plex = 0;
            
            curr_var_mods = data{scan}.pep_var_mods;
            [row, col] = size(curr_var_mods);
            for idx = 1:row
                if ~isempty(regexp(curr_var_mods{idx,2},'iTRAQ4plex (K)'))
                    var_4plex = 1;
                elseif ~isempty(regexp(curr_var_mods{idx,2},'iTRAQ8plex (K)'))
                    var_8plex = 1;
                end
            end
            %-----------------------------%
            % Lysine iTRAQ labeled
            if iTRAQType{2} == 4 || var_4plex
                iTRAQ = 144.1021 + exact_mass(1,0,0,0,0,0);
                K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
            elseif iTRAQType{2} == 8 || var_8plex
                iTRAQ = 304.2054 + exact_mass(1,0,0,0,0,0);
                K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
            else
                K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0);
            end
            % Acetyl Lysine, not iTRAQ labeled
            k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0);
        end
        
        poss_seq = gen_possible_seq2(data{scan}.pep_seq, data{scan}.pY, data{scan}.pSTY, data{scan}.oM, data{scan}.acK);
        
        if min(size(poss_seq)) > 0
            fragments = fragment_masses2(poss_seq, data{scan}.pep_exp_z, 0);
            
            % Include all peaks > 10%
            temp = data{scan}.scan_data(:,2)/max(data{scan}.scan_data(:,2));
            temp = find(temp > 0.1);
            
            % Find peaks that are local maximums in empty regions
            for k_idx = 1:length(data{scan}.scan_data(:,2))
                idx = find(abs(data{scan}.scan_data(:,1) - data{scan}.scan_data(k_idx,1)) < 25);
                if data{scan}.scan_data(k_idx,2) == max(data{scan}.scan_data(idx,2)) && data{scan}.scan_data(k_idx,2)/max(data{scan}.scan_data(:,2)) > 0.025
                    temp = [temp; k_idx];
                end
            end
            temp = unique(temp);
            
            for j = 1:max(size(fragments))
                fragments{j}.validated = compare_spectra(fragments{j}, data{scan}.scan_data(temp,:), CID_tol);
                fragments{j}.status = 0;
            end
            data{scan}.fragments = fragments;
            data{scan} = rmfield(data{scan},'code');
            
            name = data{scan}.pep_seq;
            [R,~] = size(data{scan}.pep_var_mods);
            
            for r = 1:R
                if data{scan}.pep_var_mods{r,1} == 1
                    name = [name, ' + ', data{scan}.pep_var_mods{r,2}];
                else
                    name = [name, ' + ', num2str(data{scan}.pep_var_mods{r,1}), ' ', data{scan}.pep_var_mods{r,2}];
                end
            end
                        
            node.setName(name);
            set(node,'LeafNode',false);
            mtree.reloadNode(node);            
            
            set(handle_process_anyway,'Visible','off','Enable','off');
            print_code_now('');
            
            for j = 1:length(data{scan}.fragments)                
                node.add(uitreenode('v0', [num2str(scan),'.',num2str(j)], data{scan}.fragments{j}.seq,  'gray.jpg', true));
            end            
        end        
    end

% Build uitree in gui
    function [mtree, jtree] = build_tree(filename, data)
        print_now('');
        % Root node
        filename = regexprep(filename,'input\','');
        root = uitreenode('v0', 'root', filename, [], false);
        
        prev_prot = '';
        
        num_prot = 1;
        
        prot = uitreenode('v0', 0, 'temp', [], false);
        
        for i = 1:length(data)
            if i == 1
                % First scan
                prot = uitreenode('v0', 'protein', data{i}.protein, 'white.jpg', false);
                prev_prot = data{i}.protein;
                num_prot = num_prot + 1;
            elseif ~strcmp(data{i}.protein,prev_prot)
                root.add(prot);
                % First scan of new protein
                prot = uitreenode('v0', 'protein', data{i}.protein, 'white.jpg', false);
                prev_prot = data{i}.protein;
                num_prot = num_prot + 1;
            end
            
            name = data{i}.pep_seq;
            [R,~] = size(data{i}.pep_var_mods);
            
            for r = 1:R
                if data{i}.pep_var_mods{r,1} == 1
                    name = [name, ' + ', data{i}.pep_var_mods{r,2}];
                else
                    name = [name, ' + ', num2str(data{i}.pep_var_mods{r,1}), ' ', data{i}.pep_var_mods{r,2}];
                end
            end
                        
            temp = uitreenode('v0', num2str(i), name, 'white.jpg', false);
            temp.UserData = data{i}.scan_number;
            if ~isfield(data{i},'code')
                for j = 1:length(data{i}.fragments)
                    seq = data{i}.fragments{j}.seq;
                    switch data{i}.fragments{j}.status
                        case 0
                            temp.add(uitreenode('v0', [num2str(i),'.',num2str(j)], seq,  'gray.jpg', true));
                        case 1
                            temp.add(uitreenode('v0', [num2str(i),'.',num2str(j)], seq,  'green.jpg', true));
                            accept_list{end+1}.scan = num2str(i);
                            accept_list{end}.choice = num2str(j);
                        case 2
                            temp.add(uitreenode('v0', [num2str(i),'.',num2str(j)], seq,  'orange.jpg', true));
                            maybe_list{end+1}.scan = num2str(i);
                            maybe_list{end}.choice = num2str(j);
                        case 3
                            temp.add(uitreenode('v0', [num2str(i),'.',num2str(j)], seq,  'red.jpg', true));
                            reject_list{end+1}.scan = num2str(i);
                            reject_list{end}.choice = num2str(j);
                    end
                end
            else
                set(temp,'LeafNode',true);
                temp.setName(['<html><font color="red">', name,'<html>']);
            end
            
            prot.add(temp);
            
            % Add last protein
            if i == length(data)
               root.add(prot) 
            end               
        end
        
%         treeModel = DefaultTreeModel(root);
%         mtree = uitree('v0'); %, 'Root', root);
%         mtree.setModel(treeModel);
%         drawnow;
        mtree = uitree('v0', 'Root', root);      
        mtree.setSelectedNode( root );     
        
        mtree.position = [0 25 200 575];
        
        % Use JTree properties from Java
        jtree = handle(mtree.getTree,'CallbackProperties');
        % MousePressedCallback is not supported by the uitree, but by jtree
        set(jtree, 'MousePressedCallback', @mousePressedCallback);
    end    

% Displays ladder on gui
    function display_ladder(scan,id)
%         axes(ax1_assign);
        
        [R,C] = size(data{scan}.fragments{id}.validated);
                        
        seq = data{scan}.fragments{id}.seq;
%         b_ions = data{scan}.fragments{id}.b_ions;
%         y_ions = data{scan}.fragments{id}.y_ions;
        
        b_used = zeros(length(seq),1);
        y_used = zeros(length(seq),1);
        
        for r = 1:R
            if ~isempty(data{scan}.fragments{id}.validated{r,2})
                if strcmp(data{scan}.fragments{id}.validated{r,2}(1),'a') || strcmp(data{scan}.fragments{id}.validated{r,2}(1),'b')
                    [~,~,~,d] = regexp(data{scan}.fragments{id}.validated{r,2},'[0-9]*');
                    b_used(str2num(d{1})) = 1;
                elseif strcmp(data{scan}.fragments{id}.validated{r,2}(1),'y')
                    [~,~,~,d] = regexp(data{scan}.fragments{id}.validated{r,2},'[0-9]*');
                    y_used(str2num(d{1})) = 1;
                end
            end
        end
        
        
        x_start = 0;
        y_start = 475;
        
        num_font_size = 5;
        
%         space_x = 20;
        space_x = 10;
%         space_y = 20;
        
%         text(x_start, y_start + space_y, num2str(b_ions(1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
        text(x_start, y_start, seq(1), 'Units', 'pixels', 'HorizontalAlignment', 'Center')
        
        prev = x_start;
        
        for i = 2:length(seq)
            if b_used(i-1) == 1 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '\color{red}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            elseif b_used(i-1) == 1 && y_used(end-i+1) == 0
                text(prev + space_x, y_start, '\color{red}^{\rceil}\color{black}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            elseif b_used(i-1) == 0 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '^{\rceil}\color{red}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            else
                text(prev + space_x, y_start, '^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            end
            
%             if i < length(seq)
%                 text(prev + 2*space_x, y_start + space_y, num2str(b_ions(i)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
%             end
            text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center');
%             text(prev + 2*space_x, y_start - space_y, num2str(y_ions(end-i+1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            prev = prev + 2*space_x;
        end
    end

% Plot fragment label assignments onto active axes
    function plot_assignment(scan,id)   
        
%         data{scan}.scan_data(:,2)
        
%         axes(ax1_assign);
        hold on;
        plot_isotope = [];
        plot_good = [];
        plot_med = [];
        plot_miss = [];
        plot_uk = [];
        
        max_y = 0;
        
        [num_id_peaks_max, ~] = size(data{scan}.fragments{id}.validated);
        
        for num_id_peaks = 1:num_id_peaks_max
            x = data{scan}.fragments{id}.validated{num_id_peaks,1};            
            y = data{scan}.fragments{id}.validated{num_id_peaks,4};
            max_y = max(y,max_y);
            name = data{scan}.fragments{id}.validated{num_id_peaks,2};
            
            if ~isempty(name)
                if strcmp(name, 'isotope')
                    plot_isotope(end+1,:) = [x y];
                elseif strcmp(data{scan}.fragments{id}.validated{num_id_peaks,3},'unknown')
                    plot_uk(end+1,:) = [x,y];
                    text(x,y,name,'FontSize', 8, 'Rotation', 90, 'ButtonDownFcn', @labelCallback);
                else
                    if data{scan}.fragments{id}.validated{num_id_peaks,5} < CID_tol
                        plot_good(end+1,:) = [x y];
                    else
                        plot_med(end+1,:) = [x y];
                    end
%                     text(x,y,name,'FontSize', 8, 'Rotation', 90);
                    text(x,y,name,'FontSize', 8, 'Rotation', 90, 'ButtonDownFcn', @labelCallback);
                end
            else
                plot_miss(end+1, :) = [x y];
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
        if ~isempty(plot_uk)
            plot(plot_uk(:,1), plot_uk(:,2), '*k');
        end
        if ~isempty(plot_miss)            
            [r,~] = size(plot_miss);
            for i = 1:r
                plot(plot_miss(i,1), plot_miss(i,2), 'or', 'ButtonDownFcn', @rename_miss);
            end
        end                
        
        
        ylim([0, 1.25*max_y]);
        hold off;
    end

% Rename an unlabeled peak
    function rename_miss(a,~)
        nodes = mtree.getSelectedNodes;
        node = nodes(1);
        
        scan_curr = regexp(node.getValue,'\.','split');
        scan = str2num(scan_curr{1});
        id = str2num(scan_curr{2});
        
        
        [r,~] = size(data{scan}.fragments{id}.validated);
        mass = get(a,'XData');
        curr_ion = 0;
        for i = 1:r
            if mass == data{scan}.fragments{id}.validated{i,1}
                curr_ion = i;
            end
        end
        
        h2 = figure('pos',[300,300,500,500], 'WindowStyle', 'modal');
        set(gcf,'name','Rename Peak','numbertitle','off', 'MenuBar', 'none');
        set(gca,'Position', [0,0,1,1], 'Visible', 'off');
        text(.1,.98,['Observed Mass: ', num2str(data{scan}.fragments{id}.validated{curr_ion,1})]);
        text(.1,.94,'Current Label: None');
        
        text(50,400,'New Name:','Units','pixels');
        handle_rename = uicontrol('Style','edit','Position',[50,400-50,150,20],'Enable','on');
        
        
        
        uicontrol('Style', 'pushbutton', 'String', 'OK','Position', [25 10 50 20],'Callback', @OKRenameCallback);
        uicontrol('Style', 'pushbutton', 'String', 'Cancel','Position', [75 10 50 20],'Callback', @CancelRenameCallback);
        
        function OKRenameCallback(~,~)
            if ~isempty(get(handle_rename,'String'))
                data{scan}.fragments{id}.validated{curr_ion,2} = get(handle_rename,'String');
                data{scan}.fragments{id}.validated{curr_ion,3} = 'unknown';
                data{scan}.fragments{id}.validated{curr_ion,5} = 'unknown';
            end
            cla(ax1_assign);
            axes(ax1_assign);
            display_ladder(scan,id);
            plot_assignment(scan,id);            
            close(h2);
        end
        
        function CancelRenameCallback(~,~)
            close(h2);
        end                
    end

% Plot iTRAQ region data onto active axes
    function plot_iTRAQ(scan)  
%         axes(ax3);
        title('iTRAQ');
        hold on;
        if ~isempty(data{scan}.iTRAQ_scan_data)
            mz = data{scan}.iTRAQ_scan_data(:,1);
            int = data{scan}.iTRAQ_scan_data(:,2);
            ylim([0,max(1,1.1*max(int))]);
        else
            mz = [];
            int = [];
        end
        stem(mz,int, 'Marker', 'none');
                
        if iTRAQType{2} == 8            
            xlim([112,122]);            
        elseif iTRAQType{2} == 4            
            xlim([113,118]);            
        end                                
        
        for i = 1:length(iTRAQ_masses)
           idx2 = [];
           val_int = [];
            idx = find(abs(mz-iTRAQ_masses(i)) < 0.01);            
            [val_int,idx2] = max(int(idx));
                                    
            if ~isempty(idx2)
                plot(iTRAQ_masses(i), val_int, '*g');
            end
        end     
        hold off;
    end

% Plot precursor region data onto active axes
    function plot_prec(scan)       
        
        title('Precursor');
        hold on;
        mz = data{scan}.prec_scan_data(:,1);
        int = data{scan}.prec_scan_data(:,2);
        
        prec = data{scan}.pep_exp_mz;
        
        ylim([0,1.1*max(int)]);
        if ~SILAC
            xlim([prec-2,prec+2]);
        else
            xlim([data{scan}.SILAC_prec(1) - 2,data{scan}.SILAC_prec(3) + 2]);
        end
        
        if SILAC
            for i = 1:length(data{scan}.SILAC_prec)                
                area([data{scan}.SILAC_prec(i)-cont_window,data{scan}.SILAC_prec(i)+cont_window],[1.1*max(int),1.1*max(int)],'FaceColor', [.95,.95,.95],'LineStyle','none');
            end
        end
        area([prec-cont_window,prec+cont_window],[1.1*max(int),1.1*max(int)],'FaceColor', [.75,.75,.75],'LineStyle','none');
        
        step = 1/data{scan}.pep_exp_z;
                                
        ion_series = [];
        if ~SILAC                        
            ion_series = prec-5*step:step:prec+5*step;
        else        
            for i = 1:length(data{scan}.SILAC_prec)
                 ion_series = [ion_series, data{scan}.SILAC_prec(i)-5*step:step:data{scan}.SILAC_prec(i)+5*step];
            end
        end
        
        stem(mz,int, 'Marker', 'none');
        for i = 1:length(ion_series)
            [diff,idx] = min(abs(ion_series(i)-mz));
            if diff < 0.05 && int(idx)/max(int) > 0.1
                plot(mz(idx), int(idx), '*g');
            end
        end
        hold off;
    end

% Print PDF containing MS2 with assignment, peptide ladder, iTRAQ,
% precursor, and run information
    function print_pdf(scan,id,fig_name)
        seq = data{scan}.fragments{id}.seq;
        protein = data{scan}.protein;
        charge_state = data{scan}.pep_exp_z;
        scan_number = data{scan}.scan_number;
        
%         b_ions = data{scan}.fragments{id}.b_ions;
%         y_ions = data{scan}.fragments{id}.y_ions;
        
        b_used = zeros(length(seq),1);
        y_used = zeros(length(seq),1);
        
        [R,~] = size(data{scan}.fragments{id}.validated);
        for r = 1:R
            if ~isempty(data{scan}.fragments{id}.validated{r,2})
                if strcmp(data{scan}.fragments{id}.validated{r,2}(1),'a') || strcmp(data{scan}.fragments{id}.validated{r,2}(1),'b')
                    [~,~,~,d] = regexp(data{scan}.fragments{id}.validated{r,2},'[0-9]*');
                    b_used(str2num(d{1})) = 1;
                elseif strcmp(data{scan}.fragments{id}.validated{r,2}(1),'y')
                    [~,~,~,d] = regexp(data{scan}.fragments{id}.validated{r,2},'[0-9]*');
                    y_used(str2num(d{1})) = 1;
                end
            end
        end
        
        fig = figure;
        set(gca,'Visible','off');
        % Print PDF friendly scan information and ladder
        text(-40, 665, protein, 'Units', 'pixels', 'FontSize', 10);
        text(-40, 650, ['Charge State: +', num2str(charge_state)], 'Units', 'pixels', 'FontSize', 10);
        text(-40, 635, ['Scan Number: ', num2str(scan_number)], 'Units', 'pixels', 'FontSize', 10);
        text(-40, 620, ['File Name: ', filename, '.raw'], 'Units', 'pixels', 'FontSize', 10, 'Interpreter', 'none');
        
        x_start = -40;
        y_start = 700;
        
        num_font_size = 5;
        
%         space_x = 20;
        space_x = 10;
%         space_y = 20;
        
%         text(x_start, y_start + space_y, num2str(b_ions(1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
        text(x_start, y_start, seq(1), 'Units', 'pixels', 'HorizontalAlignment', 'Center')
        
        prev = x_start;
        
        for i = 2:length(seq)
            if b_used(i-1) == 1 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '\color{red}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            elseif b_used(i-1) == 1 && y_used(end-i+1) == 0
                text(prev + space_x, y_start, '\color{red}^{\rceil}\color{black}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            elseif b_used(i-1) == 0 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '^{\rceil}\color{red}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            else
                text(prev + space_x, y_start, '^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
            end
            
%             if i < length(seq)
%                 text(prev + 2*space_x, y_start + space_y, num2str(b_ions(i)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
%             end
            text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center');
%             text(prev + 2*space_x, y_start - space_y, num2str(y_ions(end-i+1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            prev = prev + 2*space_x;
        end
        
        
        ax1_pdf = axes('Position', [.12,.125,.6,.65], 'TickDir', 'out', 'box', 'off');
        ax2_pdf = axes('Position', [.75,.5,.14,.25], 'TickDir', 'out', 'box', 'off');
        title('Precursor');
        
      
        axes(ax1_pdf);        
        stem(data{scan}.scan_data(:,1),data{scan}.scan_data(:,2),'Marker', 'none');                
        plot_assignment(scan,id);
        set(gca, 'TickDir', 'out', 'box', 'off');        
        ylim([0,1.25*max(data{scan}.scan_data(:,2))]);
        
        x_start = 0.95 * data{scan}.fragments{id}.validated{1,1};
        x_end = 1.05 * data{scan}.fragments{id}.validated{end,1};
        
        xlim([x_start,x_end]);
        
        axes(ax2_pdf);
        plot_prec(scan);
        set(gca, 'TickDir', 'out', 'box', 'off');
%         text(.5,1.1,'Precursor', 'HorizontalAlignment', 'center');
        if ~strcmp(iTRAQType{1},'None')
            ax3_pdf = axes('Position', [.75,.125,.14,.25], 'TickDir', 'out', 'box', 'off');
            title('iTRAQ');
            
            axes(ax3_pdf);
            plot_iTRAQ(scan);
            set(gca, 'TickDir', 'out', 'box', 'off');
%         text(.5,1.1,'iTRAQ', 'HorizontalAlignment', 'center');
        end
        
        orient landscape;
        paperUnits = get(fig, 'PaperUnits');
        set(fig, 'PaperUnits','inches');
        paperSize = get(fig,'PaperSize');
        paperPosition = [-1 -.5 paperSize + [2 .5]];
        set(fig, 'PaperPosition', paperPosition);
        set(fig, 'PaperUnits',paperUnits);
        
        filename_temp = fig_name;
        filename_temp = regexprep(filename_temp,'<','');
        filename_temp = regexprep(filename_temp,'>','');
        filename_temp = regexprep(filename_temp,':','');
        filename_temp = regexprep(filename_temp,'"','');
        filename_temp = regexprep(filename_temp,'/','');
%         filename_temp = regexprep(filename_temp,'\','');
        filename_temp = regexprep(filename_temp,'\|','');
        filename_temp = regexprep(filename_temp,'?','');
        filename_temp = regexprep(filename_temp,'*','');
        
        print(fig,'-dpdf', '-r900', ['output\', filename, '\', filename_temp]);
        close(fig);
    end

% Write XLS file with iTRAQ data for scans in "accept" list
    function iTRAQ_to_Excel()
        XLS_out = fopen(['output\', filename, '\', filename, '.xls'],'w');        
        title_line = ['Scan\t', 'Protein\t', 'Accession\t', 'Sequence\t', 'iTRAQ Centroided\n'];
        fprintf(XLS_out, title_line);
        
        for i = 1:length(accept_list)
            scan = str2num(accept_list{i}.scan);
            id = str2num(accept_list{i}.choice);
            
            line = [num2str(data{scan}.scan_number), '\t', data{scan}.protein, '\t', data{scan}.gi, '\t', data{scan}.fragments{id}.seq, '\t'];
            
            %%%            
            if ~isempty(data{scan}.iTRAQ_scan_data)
                mz = data{scan}.iTRAQ_scan_data(:,1);
                int = data{scan}.iTRAQ_scan_data(:,2);
            else
                mz = [];
               int = [];
            end
            
            for j = 1:length(iTRAQ_masses)
                idx2 = [];
                val_int = [];
                idx = find(abs(mz-iTRAQ_masses(j)) < 0.01);
                [val_int,idx2] = max(int(idx));
                
                if ~isempty(idx2)
                    line = [line, num2str(val_int), '\t'];
                else
                    line = [line, num2str(0), '\t'];
                end
            end
            line = [line, '\n'];
            fprintf(XLS_out, line);
        end
        fclose(XLS_out);
    end

% Write XLS file with SILAC data for scans in "accept" list
    function SILAC_to_Excel()
        XLS_out = fopen(['output\', filename, '\', filename, '.xls'],'w');        
        title_line = ['Scan\t', 'Protein\t', 'Accession\t', 'Sequence\t', 'SILAC Centroided\n'];
        fprintf(XLS_out, title_line);
        
        for i = 1:length(accept_list)
            scan = str2num(accept_list{i}.scan);
            id = str2num(accept_list{i}.choice);
            
            line = [num2str(data{scan}.scan_number), '\t', data{scan}.protein, '\t', data{scan}.gi, '\t', data{scan}.fragments{id}.seq, '\t'];
            
            %%%            
            mz = data{scan}.prec_scan_data(:,1); 
            int = data{scan}.prec_scan_data(:,2);                                    
            prec = data{scan}.SILAC_prec;
            
            for j = 1:length(prec)
                idx2 = [];
                val_int = [];
                idx = find(abs(mz-prec(j)) < 0.05);
                [val_int,idx2] = max(int(idx));
                
                if ~isempty(idx2)
                    line = [line, num2str(val_int), '\t'];
                else
                    line = [line, num2str(0), '\t'];
                end
            end
            line = [line, '\n'];
            fprintf(XLS_out, line);
        end
        fclose(XLS_out);
    end
end
