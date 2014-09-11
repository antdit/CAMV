function gui_test()
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

CID_tol = 1e-3;
HCD_tol = 1e-5;

accept_list = {};
maybe_list = {};
reject_list = {};

% Tree
h = figure('pos',[150,100,1200,600]);
set(gcf,'name','Spectrum Validation','numbertitle','off', 'MenuBar', 'none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   seq = 'ABCDEFG';
%         
%   b_used = [1 0 1 0 0 1 0];
%   y_used = [1 1 1 0 0 0 0];    
%   
%   x_start = 0;
%   y_start = 475;
%   
%   num_font_size = 5;
%   
%   space_x = 10;
% %   space_y = 20;
%   
% %   text(x_start, y_start + space_y, num2str(b_ions(1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
% %   text(x_start, y_start, seq(1), 'Units', 'pixels', 'HorizontalAlignment', 'Center')
%   
%   prev = x_start;
%   
%   for i = 2:length(seq)
%       if b_used(i-1) == 1 && y_used(end-i+1) == 1
%           text(prev + space_x, y_start, '\color{red}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
%       elseif b_used(i-1) == 1 && y_used(end-i+1) == 0
%           text(prev + space_x, y_start, '\color{red}^{\rceil}\color{black}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
%       elseif b_used(i-1) == 0 && y_used(end-i+1) == 1
%           text(prev + space_x, y_start, '^{\rceil}\color{red}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
%       else
%           text(prev + space_x, y_start, '^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
%       end
%       
% %       if i < length(seq)
% %           text(prev + 2*space_x, y_start + space_y, num2str(b_ions(i)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
% %       end
%       text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center');
% %       text(prev + 2*space_x, y_start - space_y, num2str(y_ions(end-i+1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
%       prev = prev + 2*space_x;
%   end
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


handle_file = uicontrol('Style', 'pushbutton', 'String', 'Get File','Position', [250 20 50 20],'Callback', @upload);
handle_file_continue = uicontrol('Style', 'pushbutton', 'String', 'Load Session','Position', [300 20 75 20],'Callback', @load_session);
handle_file_save = uicontrol('Style', 'pushbutton', 'String', 'Save Session','Position', [375 20 75 20],'Callback', @save_session,'Enable', 'off');

ax0 = axes('Position', [0,0,1,1], 'Visible', 'off');
h1 = text(500,20, '', 'Units', 'pixels', 'Interpreter', 'none');

% MS2 data
ax1 = axes('Position', [.2,.125,.6,.7], 'TickDir', 'out', 'box', 'off');

% MS2 Peak Assignments
ax1_assign = axes('Position', [.2,.125,.6,.7], 'Visible', 'off');
linkaxes([ax1,ax1_assign],'xy');

% Precursor Window
ax2 = axes('Position', [.84,.5,.14,.25], 'TickDir', 'out', 'box', 'off');
text(.5,1.1,'Precursor', 'HorizontalAlignment', 'center');

% iTRAQ Window
ax3 = axes('Position', [.84,.125,.14,.25], 'TickDir', 'out', 'box', 'off');
text(.5,1.1,'iTRAQ', 'HorizontalAlignment', 'center');

% Handle buttonclick events
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
            end
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
            iTRAQ_to_Excel();
        else
            warndlg('No peptide identifications have been selected.','Empty List');
        end
    end

% Print plots for scans in "maybe" list
    function print_maybe(hObject, event)
        if length(maybe_list) > 0
            if exist(['output\', filename,'\maybe']) == 0
                % Make output directory
                mkdir(['output\', filename,'\maybe']);
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
            iTRAQ_to_Excel();
        else
            warndlg('No peptide identifications have been selected.','Empty List');
        end
    end

% Upload file 
    function upload(~,~)
        cd('input');
        [filename, path] = uigetfile({'*.raw','RAW Files'});
        cd('..');
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
        end
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
            
            [mtree,jtree] = build_tree(filename, data);
            set(handle1,'Enable', 'off');
            set(handle2,'Enable', 'off');
            set(handle3,'Enable', 'off');
            set(handle_print_accept,'Enable', 'on');
            set(handle_print_maybe,'Enable', 'on');
            set(handle_file_save,'Enable', 'on');
            print_now('');
        end
    end

% Save Session
    function save_session(~,~)
        print_now('Saving...');
        save(['input\', filename,'.mat'],'data', 'iTRAQType', 'iTRAQ_masses');
        print_now('');
    end

% Display Message Below Plot
    function print_now(string)
        axes(ax0);        
        delete(h1);        
        h1 = text(500,20, string, 'Units', 'pixels', 'Interpreter', 'none');
        drawnow;
    end

% Handle mouse click events in uitree
    function mousePressedCallback(hTree, eventData)
        nodes = mtree.getSelectedNodes;
        node = nodes(1);               
        
        scan_curr = regexp(node.getValue,'\.','split');               
        scan_prev = regexp(prev_node,'\.','split');
        
        % New Node selected
        if ~strcmp(node.getValue,prev_node)
           if ~isempty(regexp(node.getValue,'root')) || ~isempty(regexp(node.getValue,'protein'))
               % Root node selected
               set(handle1, 'Enable', 'off');
               set(handle2, 'Enable', 'off');               
               set(handle3, 'Enable', 'off');
%                print_now('root')
               
               % Clear all Plots
               cla(ax1);
               cla(ax1_assign);
               cla(ax2);
               cla(ax3);
                             
               set(ax1, 'TickDir', 'out', 'box', 'off');                             
               set(ax2, 'TickDir', 'out', 'box', 'off');               
               set(ax3, 'TickDir', 'out', 'box', 'off');
               
           elseif ~isempty(regexp(node.getValue,'\.'))
               % Particular Peptide Assignment Selected
               set(handle1, 'Enable', 'on');
               set(handle2, 'Enable', 'on');
               set(handle3, 'Enable', 'on');
               
               % Replot new scan and assignment
               cla(ax1);
               cla(ax1_assign);
               cla(ax2);
               cla(ax3);
               
               axes(ax1);
               set(gca, 'TickDir', 'out', 'box', 'off');
               stem(data{str2num(scan_curr{1})}.scan_data(:,1),data{str2num(scan_curr{1})}.scan_data(:,2),'Marker', 'none');
               
               axes(ax1_assign)
               display_ladder(str2num(scan_curr{1}),str2num(scan_curr{2}));
               plot_assignment(str2num(scan_curr{1}),str2num(scan_curr{2}));
               
               axes(ax2);
               plot_prec(str2num(scan_curr{1}));
               set(gca, 'TickDir', 'out', 'box', 'off');
               text(.5,1.1,'Precursor', 'HorizontalAlignment', 'center');
               
               axes(ax3);
               plot_iTRAQ(str2num(scan_curr{1}));
               set(gca, 'TickDir', 'out', 'box', 'off');
               text(.5,1.1,'iTRAQ', 'HorizontalAlignment', 'center');
               
               set(ax1, 'TickDir', 'out', 'box', 'off');
               set(ax2, 'TickDir', 'out', 'box', 'off');               
               set(ax3, 'TickDir', 'out', 'box', 'off');

%-------------------------------------------------------------------------%
           else
               % Scan Selected
               set(handle1, 'Enable', 'off');
               set(handle2, 'Enable', 'off');               
               set(handle3, 'Enable', 'off');                                            
               
               cla(ax1_assign);
               cla(ax1);
               cla(ax2);
               cla(ax3);
               
               axes(ax1);
               set(gca, 'TickDir', 'out', 'box', 'off');
               stem(data{str2num(scan_curr{1})}.scan_data(:,1),data{str2num(scan_curr{1})}.scan_data(:,2), 'Marker', 'none');
               ylim([0,1.25*max(data{str2num(scan_curr{1})}.scan_data(:,2))]);
               
               axes(ax2);
               plot_prec(str2num(scan_curr{1}));
               set(gca, 'TickDir', 'out', 'box', 'off');
               
               axes(ax3);
               plot_iTRAQ(str2num(scan_curr{1}));
               set(gca, 'TickDir', 'out', 'box', 'off');                              
               
               set(ax1, 'TickDir', 'out', 'box', 'off');
               set(ax2, 'TickDir', 'out', 'box', 'off');               
               set(ax3, 'TickDir', 'out', 'box', 'off');

           end
           
           prev_node = node.getValue; 
                      
        end
    end
    
% Read MASCOT output XML file
    function data = validate_spectra(to_process)      
        if exist(['output\', filename],'dir') == 0
            mkdir(['output\', filename]);
        end
        print_now(['Reading File: ', filename]);
        
        [mods, it_mods, data] = read_mascot_xml(['input\', filename, '.xml']);
        
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
                iTRAQ_masses = [113.11, 114.11, 115.11, 116.11, 117.11, 118.11, 119.11, 121.12];
            elseif strcmp(it_mods{i},'iTRAQ4plex (K)') || strcmp(it_mods{i},'iTRAQ4plex (N-term)')
                iTRAQType = {'Variable', 4};
                iTRAQ_masses = [114.11, 115.11, 116.11, 117.11];
            end        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Remove scans without iTRAQ
        if strcmp(iTRAQType{1},'Variable')
            for i = length(data):-1:1
                [a,~] = size(data{i}.pep_var_mods);
                has_iTRAQ = 0;
                for j = 1:a
                    b = regexp(data{i}.pep_var_mods{j,2},'iTRAQ');
                    if length(b) > 0
                        has_iTRAQ = 1;
                    end
                end
                if ~has_iTRAQ
                    data(i) = [];
                end
            end
        end
        
        
        disp(['Size of Data: ', num2str(length(data))]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % Initialize AA masses based on iTRAQ type
        init_fragments(iTRAQType{2});
        
        % Get scan data from RAW file
        scans_used = [];
        for i = 1:length(data)
            scans_used = [scans_used, data{i}.scan_number];
        end
        
        batch = 100;
        
        scans_used = unique(scans_used);
        
        iTRAQ_scans_used = [];
        prec_scans_used = [];
        
        ID_batch = batch:batch:length(scans_used);
        if length(ID_batch) > 0
            if ID_batch(end) ~= length(scans_used)
                ID_batch(end+1) = length(scans_used);
            end
%-------------------------------------------------------------------------%            
            % Get MS2 Data
            j_prev = 0;
            for idx = 1:length(ID_batch)
                i = ID_batch(idx);
                print_now(['Reading MS2 Data: ', num2str(i), ' of ', num2str(length(scans_used))]);
                % Create scan number filters for msconvert
                scans = [];
                scans = ['--filter "scanNumber'];
                j = j_prev+1;
                
                while j < i+1
                    scans = [scans, ' ', num2str(scans_used(j))];
                    j = j + 1;
                end
                j = j - 1;
                scans = [scans, '"'];
                
                mzXML_command = ['msconvert input\', filename, '.raw -o input\ --mzXML ', scans];
                system(mzXML_command);
                
                % Convert mzXML file into MATLAB struct                
                temp_out = mzxmlread2(['input\', filename,'.mzXML']);
                if i == batch
                    mzXML_out = temp_out;
                else
                    %         mzXML_out.scan(j_prev+1:j) = temp_out.scan(1:end);
                    for k = 1:length(temp_out.scan)
                        mzXML_out.scan(end+1).peaks = temp_out.scan(k).peaks;
                        mzXML_out.scan(end).activationMethod = temp_out.scan(k).activationMethod;
                        mzXML_out.scan(end).precursorMz = temp_out.scan(k).precursorMz;
                    end
                end
                j_prev = j;
            end
            
            print_now('Storing MS2 Data');
            
            % Transfer MS2 information to data struct
            for i = 1:length(data)
                idx = find(scans_used == data{i}.scan_number);
                if ~isempty(idx)
                    data{i}.activation_method = mzXML_out.scan(idx).activationMethod;
                    data{i}.prec_scan = mzXML_out.scan(idx).precursorMz.precursorScanNum;
                    prec_scans_used(end+1) = mzXML_out.scan(idx).precursorMz.precursorScanNum;
                    
                    if strcmp(data{i}.activation_method,'CID')
                        data{i}.scan_data = [mzXML_out.scan(idx).peaks.mz(1:2:end),mzXML_out.scan(idx).peaks.mz(2:2:end)];
                        data{i}.iTRAQ_scan = data{i}.scan_number - 1;
                        iTRAQ_scans_used(end+1) = data{i}.scan_number - 1;
                    else
                        % Resolve HCD data
                        temp1 = mzXML_out.scan(idx).peaks.mz(1:2:end);
                        temp2 = mzXML_out.scan(idx).peaks.mz(2:2:end);
                        if ~issorted(temp1)
                            [temp1,idx] = unique(temp1);
                            temp2 = temp2(idx);
                        end
                        data{i}.scan_data = mspeaks(temp1, temp2);
                        data{i}.iTRAQ_scan = data{i}.scan_number;
                        iTRAQ_scans_used(end+1) = data{i}.scan_number;
                    end
                end
            end                        
            
%-------------------------------------------------------------------------%
            % Get iTRAQ data
            iTRAQ_scans_used = unique(iTRAQ_scans_used);
            ID_batch = [];
            ID_batch = batch:batch:length(iTRAQ_scans_used);
            if ID_batch(end) ~= length(iTRAQ_scans_used)
                ID_batch(end+1) = length(iTRAQ_scans_used);
            end
            
            j_prev = 0;
            for idx = 1:length(ID_batch)
                i = ID_batch(idx);
                print_now(['Reading iTRAQ Data: ', num2str(i), ' of ', num2str(length(iTRAQ_scans_used))]);
                % Create scan number filters for msconvert
                scans = [];
                scans = ['--filter "scanNumber'];
                j = j_prev+1;
                
                while j < i+1
                    scans = [scans, ' ', num2str(iTRAQ_scans_used(j))];
                    j = j + 1;
                end
                j = j - 1;
                scans = [scans, '"'];
                
                iTRAQ_filter = '';
                
                if iTRAQType{2} == 4
                    iTRAQ_filter = '--filter "mzWindow [113,118]"';
                elseif iTRAQType{2} == 8
                    iTRAQ_filter = '--filter "mzWindow [112,122]"';
                end
                
                mzXML_command = ['msconvert input\', filename, '.raw -o input\ --mzXML ', scans, ' ', iTRAQ_filter];
                system(mzXML_command);
                
                % Convert mzXML file into MATLAB struct
                temp_out = mzxmlread2(['input\', filename,'.mzXML']);
                if i == batch
                    mzXML_out = temp_out;
                else                   
                    for k = 1:length(temp_out.scan)
                        mzXML_out.scan(end+1).peaks = temp_out.scan(k).peaks;
                    end
                end
                j_prev = j;
            end                       
            
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
            
%-------------------------------------------------------------------------%
            % Get Precursor Scan information
            prec_scans_used = unique(prec_scans_used);
            
            ID_batch = [];
            ID_batch = batch:batch:length(prec_scans_used);
            if ID_batch(end) ~= length(prec_scans_used)
                ID_batch(end+1) = length(prec_scans_used);
            end
            
            j_prev = 0;
            for idx = 1:length(ID_batch)
                i = ID_batch(idx);
                print_now(['Reading Precursor Data: ', num2str(i), ' of ', num2str(length(prec_scans_used))]);
                % Create scan number filters for msconvert
                scans = [];
                scans = ['--filter "scanNumber'];
                j = j_prev+1;
                
                while j < i+1
                    scans = [scans, ' ', num2str(prec_scans_used(j))];
                    j = j + 1;
                end
                j = j - 1;
                scans = [scans, '"'];
                
                mzXML_command = ['msconvert input\', filename, '.raw -o input\ --mzXML ', scans];
                system(mzXML_command);
                
                % Convert mzXML file into MATLAB struct
                temp_out = mzxmlread2(['input\', filename,'.mzXML']);
                if i == batch
                    mzXML_out = temp_out;
                else
                    %         mzXML_out.scan(j_prev+1:j) = temp_out.scan(1:end);
                    for k = 1:length(temp_out.scan)
                        mzXML_out.scan(end+1).peaks = temp_out.scan(k).peaks;
                        %                         mzXML_out.scan(end).activationMethod = temp_out.scan(k).activationMethod;
                    end
                end
                j_prev = j;
            end
            
            print_now('Storing Precursor Data');
            
            for i = 1:length(data)
                idx = find(prec_scans_used == data{i}.prec_scan);
                if ~isempty(idx)
                    % Resolve HCD data
                    temp1 = mzXML_out.scan(idx).peaks.mz(1:2:end);
                    temp2 = mzXML_out.scan(idx).peaks.mz(2:2:end);
                    
                    % Collect MS1 scan data within 5 m/z units of precursor
                    idx2 = find(abs(temp1 - data{i}.pep_exp_mz) < 2);
                    
                    temp1 = temp1(idx2);
                    temp2 = temp2(idx2);
                    
                    if ~issorted(temp1)
                        [temp1,idx] = unique(temp1);
                        temp2 = temp2(idx);
                    end
                    data{i}.prec_scan_data = mspeaks(temp1, temp2);
                end
            end
        end
        
%-------------------------------------------------------------------------%
        
        % Check for Cysteine carbamidomethylation present in MASCOT search
        for i = 1:length(mods)
            if strcmp(mods{i}, 'Carbamidomethyl (C)')
                C_carb = true;
            end
        end                
        
        % Check each assignment to each scan
        for i = 1:length(data)
            
            print_now(['Validating: ', num2str(i), ' of ', num2str(length(data))]);
            
            if C_carb && ~isempty(strfind(data{i}.pep_seq,'C'))
                data{i}.pep_seq = regexprep(data{i}.pep_seq,'C', 'c');
            end
            
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
            
            if pY + pSTY + oM < 5 && isempty(regexp(pep_seq,'X')) && length(pep_seq) < 50
                poss_seq = gen_possible_seq2(pep_seq, pY, pSTY, oM, acK);
                
                if min(size(poss_seq)) > 0 && max(size(poss_seq)) < 25
                    fragments = fragment_masses2(poss_seq, data{i}.pep_exp_z, 0);
                else
                    fragments = {};
                end
                
                
                if min(size(fragments)) > 0
                    % Include all peaks > 10%
                    temp = data{i}.scan_data(:,2)/max(data{i}.scan_data(:,2));
                    temp = find(temp > 0.1);
                    
                    % Find peaks that are local maximums in empty regions
                    for k = 1:length(data{i}.scan_data(:,2))
                        idx = find(abs(data{i}.scan_data(:,1) - data{i}.scan_data(k,1)) < 25);
                        if data{i}.scan_data(k,2) == max(data{i}.scan_data(idx,2)) && data{i}.scan_data(k,2)/max(data{i}.scan_data(:,2)) > 0.025
                            temp = [temp; k];
                        end
                    end
                    temp = unique(temp);
                    for j = 1:max(size(fragments))
                        
%                         validated = compare_spectra(fragments{j}, data{i}.scan_data(temp,:), CID_tol);
%                         fragments{j}.validated = validated;
                        fragments{j}.validated = compare_spectra(fragments{j}, data{i}.scan_data(temp,:), CID_tol);
                        fragments{j}.status = 0;
                    end     
                end
                data{i}.fragments = fragments;
            else
                data{i}.fragments = {};
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

% Plot fragment label assignments onto ax1_assign
    function plot_assignment(scan,id)   
        
%         data{scan}.scan_data(:,2)
        
%         axes(ax1_assign);
        hold on;
        plot_isotope = [];
        plot_good = [];
        plot_med = [];
        plot_miss = [];
        
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
                else
                    if data{scan}.fragments{id}.validated{num_id_peaks,5} < CID_tol
                        plot_good(end+1,:) = [x y];
                    else
                        plot_med(end+1,:) = [x y];
                    end
                    text(x,y,name,'FontSize', 8, 'Rotation', 90);
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
        if ~isempty(plot_miss)            
            plot(plot_miss(:,1), plot_miss(:,2), 'or');
        end                
        
        ylim([0, 1.25*max_y]);
        hold off;
    end

% Plot iTRAQ region data onto ax3
    function plot_iTRAQ(scan)  
%         axes(ax3);
        title('iTRAQ');
        hold on;
        mz = data{scan}.iTRAQ_scan_data(:,1);
        int = data{scan}.iTRAQ_scan_data(:,2);
        stem(mz,int, 'Marker', 'none');
                
        if iTRAQType{2} == 8            
            xlim([112,122]);            
        elseif iTRAQType{2} == 4            
            xlim([113,118]);            
        end
                        
        ylim([0,1.1*max(int)]);
        
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

% Plot iTRAQ region data onto ax2
    function plot_prec(scan)
%         axes(ax2);        
        xlim([-Inf,Inf]);
        
        title('Precursor');
        hold on;
        mz = data{scan}.prec_scan_data(:,1);
        int = data{scan}.prec_scan_data(:,2);  
        
        ylim([0,1.1*max(int)]);
        
        stem(mz,int, 'Marker', 'none');
        
        prec = data{scan}.pep_exp_mz;
        
        [diff,idx] = min(abs(mz-prec));
        plot(mz(idx), int(idx), '*g');
        
        if data{scan}.pep_exp_z == 2
            step = 0.5;
        elseif data{scan}.pep_exp_z == 3
            step = 0.333;
        elseif data{scan}.pep_exp_z == 4
            step = 0.25;
        elseif data{scan}.pep_exp_z == 5
            step = 0.2;
        end
        
        ion_series = prec-5*step:step:prec+5*step;
                
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
        ax3_pdf = axes('Position', [.75,.125,.14,.25], 'TickDir', 'out', 'box', 'off');
        title('iTRAQ');
      
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
        
        axes(ax3_pdf);
        plot_iTRAQ(scan);
        set(gca, 'TickDir', 'out', 'box', 'off');
%         text(.5,1.1,'iTRAQ', 'HorizontalAlignment', 'center');
        
        orient landscape;
        paperUnits = get(fig, 'PaperUnits');
        set(fig, 'PaperUnits','inches');
        paperSize = get(fig,'PaperSize');
        paperPosition = [-1 -.5 paperSize + [2 .5]];
        set(fig, 'PaperPosition', paperPosition);
        set(fig, 'PaperUnits',paperUnits);
        
        print(fig,'-dpdf', '-r900', ['output\', filename, '\', fig_name]);
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
            mz = data{scan}.iTRAQ_scan_data(:,1); 
            int = data{scan}.iTRAQ_scan_data(:,2);                                    
            
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
            %%%
% % %             
% % %             
% % %             for j = 1:length(iTRAQ_masses)                
% % %                 [val,idx] = min(abs(data{scan}.iTRAQ_scan_data(:,1) - iTRAQ_masses(j)));
% % %                 if val < 0.01
% % %                     line = [line, num2str(data{scan}.iTRAQ_scan_data(idx,2)), '\t'];
% % %                 else
% % %                     line = [line, num2str(0), '\t'];
% % %                 end
% % %             end
            line = [line, '\n'];
            fprintf(XLS_out, line);
        end
        fclose(XLS_out);
    end
end
