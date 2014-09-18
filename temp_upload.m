% Upload file 
    function upload(~,~)
    
    h2 = figure('pos',[400,400,500,200], 'WindowStyle', 'modal'); 
    set(gcf,'name','File Selection','numbertitle','off', 'MenuBar', 'none');
    set(gca,'Visible', 'off', 'Position', [0 0 1 1]);
    
    text(10, 150, 'RAW File:', 'Units', 'pixels');       
    handle_RAW = uicontrol('Style','edit','Position',[100 138 300 20],'Enable','on', 'HorizontalAlignment', 'left');
    uicontrol('Style', 'pushbutton', 'Position', [410 138, 20, 20], 'String', '...', 'Callback', @select_RAW);
    
    text(10, 125, 'Mascot XML:', 'Units', 'pixels');                        
    handle_XML = uicontrol('Style','edit','Position',[100 113 300 20],'Enable','on', 'HorizontalAlignment', 'left');
    uicontrol('Style', 'pushbutton', 'Position', [410 113, 20, 20], 'String', '...', 'Callback', @select_XML);        
    
    uicontrol('Style', 'pushbutton', 'Position', [300 53, 100, 20], 'String', 'Process', 'Callback', @process);
    
        function select_RAW(~,~)
            [RAW_filename, RAW_path] = uigetfile({'*.raw','RAW Files'});
            set(handle_RAW, 'String', [RAW_path, RAW_filename]);
        end
    
        function select_XML(~,~)
             [XML_filename, XML_path] = uigetfile({'*.xml','XML Files'});
             set(handle_XML, 'String', [XML_path, XML_filename]);
        end
    
        function process(~,~)
            
            if isempty(RAW_filename)
                msgbox('No RAW file selected','Warning');
            elseif isempty(XML_filename)
                msgbox('No XML file selected','Warning');
            else
                set(handle_file,'Enable', 'off');
                set(handle_file_continue,'Enable', 'off');
                
                filename = regexprep(filename,'.RAW','');
                filename = regexprep(filename,'.raw','');
                filename = regexprep(filename,'.xml','');
                
                CID_tol = str2double(get(handle_CID_tol, 'String'))/1e6;
                HCD_tol = str2double(get(handle_HCD_tol, 'String'))/1e6;
                
                validate_spectra();
                
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
                
                delete(handle_CID_tol);
                delete(handle_HCD_tol);
            end
            toc;
        end
    end
