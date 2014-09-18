function test_gui()

h2 = figure('pos',[300,300,750,500], 'WindowStyle', 'modal');
set(gcf,'name','Recognized Modifications','numbertitle','off', 'MenuBar', 'none');
set(gca,'Position', [0,0,1,1], 'Visible', 'off');

col_names = {'Display Name', 'MASCOT Name', 'Residue', 'Fixed/Variable', 'Quantitation', 'Label Name', ''};

pos_AA = 'ACDEFGHIKLMNPQRSTVWYN-termC-term';

% table_data{:,1} = Display Name                [text]
% table_data{:,2} = MASCOT Name                 [text]
% table_data{:,3} = is selected for changes     [false/true]
% table_data{:,4} = Chemical Formula            [4x6 Array]
% table_data{:,5} = Amino Acid/Terminus         [ACDEFGHIKLMNPQRSTVWYN-termC-term]
% table_data{:,6} = Fixed/Variable              [Fixed/Variable]
% table_data{:,7} = MS1/2 Level Quantitation    [MS1/MS2]
% table_data{:,8} = Quantation Type Name        [text]
table_data = {};

MS1_types = 0;
MS2_types = 0;

MS1_type_names = {};
MS2_type_names = {};
MS2_mass_tags = {};
            
t = uitable('Parent', h2, ...
    'ColumnName', col_names, ...
    'ColumnEditable', [false, false, false, false, false, false, true],...
    'ColumnWidth', {150 150 'auto' 'auto' 'auto' 'auto' 'auto'}, ...
    'ColumnFormat', {'char', 'char', 'char', 'char', 'char', 'char', 'logical'},...
    'Position', [1 50 748 400]);
if ~isempty(table_data)
    set(t,'Data', table_data(:,[1,2,5,6,7,8,3]));
else
    set(t,'Data', {});
end

uicontrol('Style', 'pushbutton', 'String', 'Add', 'Position', [100 10 75 25], 'Callback', @add);
uicontrol('Style', 'pushbutton', 'String', 'Edit', 'Position', [175 10 75 25], 'Callback', @edit);
uicontrol('Style', 'pushbutton', 'String', 'Remove', 'Position', [250 10 75 25], 'Callback', @remove);
uicontrol('Style', 'pushbutton', 'String', 'Set up Mods', 'Position', [350 10 75 25], 'Callback', @setup_mods);

uicontrol('Style', 'pushbutton', 'String', 'Save', 'Position', [450 10 75 25], 'Callback', @save_mods);
uicontrol('Style', 'pushbutton', 'String', 'Load', 'Position', [525 10 75 25], 'Callback', @load_mods);
uicontrol('Style', 'pushbutton', 'String', 'Done', 'Position', [650 10 75 25], 'Callback', @done);

    function save_mods(~,~)
        h4 = figure('pos',[400,400,500,100], 'WindowStyle', 'modal');
        set(gcf,'name','Save','numbertitle','off', 'MenuBar', 'none');
        set(gca,'Position', [0,0,1,1], 'Visible', 'off');
        
        text(10, 70, 'File Name:', 'Units', 'pixels');
        handle_save_filename = uicontrol('Style','edit','Position',[100 58 200 20],'Enable','on', 'HorizontalAlignment', 'left');
        
        uicontrol('Style', 'pushbutton', 'String', 'Save','Position', [25 10 50 20],'Callback', @save_data);
        
        function save_data(~,~)
            filename = get(handle_save_filename,'String');
            save(['profiles\', filename, '.mat'], 'table_data');
            close(h4);
        end        
    end

    function load_mods(~,~)
        cd('profiles');
        filename = uigetfile({'*.mat','MAT Files'});
        cd('..');
        if filename            
            temp = load(['profiles\',filename]);
            table_data = temp.table_data;        
            if ~isempty(table_data)
                set(t,'Data', table_data(:,[1,2,5,3]));
            else
                set(t,'Data', {});
            end
        end
    end

    function add(~,~)
        [r,~] = size(table_data);                
        change_mod(r+1);                
    end

    function edit(~,~)
        temp = get(t,'Data');
        [r,~] = size(temp);
        found = 0;
        used = 0;
        for i = 1:r
            if temp{i,4} == true
                found = found + 1;
                used = i;
            end
        end
        
        if found == 1
            change_mod(used);           
        elseif found == 0
            msgbox('Please select a single row to modify','Warning');
        else
            msgbox('Please select only one row to modify','Warning');
        end
        
    end

    function remove(~,~)
        [r,c] = size(table_data);
        for i = r:-1:1
            if table_data{i,3} == true
                table_data(i,:) = [];
            end
        end
        set(t,'Data', table_data);
    end
      
    function setup_mods(~,~)       
        figure('pos',[400,400,250,150], 'WindowStyle', 'modal');
        ax0 = axes('Position', [0,0,1,1], 'Visible', 'off');

        temp = 'New';
        for i = 1:MS1_types
            temp = [temp, '|', MS1_type_names{i}];
        end
        
        text(10, 100, 'MS1 Types','Units', 'pixels');
        text(10, 50, 'MS2 Types','Units', 'pixels');
        
        MS1_handle = uicontrol('Style', 'popup',...
           'String', temp,...
           'Position', [100 80 100 30],...
           'Callback', @name_MS1);
       
        function name_MS1(~,~)
            h5 = figure;
            if get(MS1_handle,'Value') == 1                
                set(gcf, 'pos',[500,500,300,100], 'WindowStyle', 'modal',...
                    'name', 'Name New MS1 Type', 'numbertitle', 'off');
                new_MS1_name_handle = uicontrol('Style', 'edit', 'pos', [25 40 150 30]);
                uicontrol('Style', 'pushbutton', 'pos', [200 40 75 30], 'String', 'Save', 'Callback', @save_new_MS1_name);                
            else                
                set(gcf, 'pos',[500,500,175,100], 'WindowStyle', 'modal', 'numbertitle', 'off');               
                uicontrol('Style', 'pushbutton', 'pos', [50 40 75 30], 'String', 'Remove', 'Callback', @remove_MS1_name);                
            end
            
            function save_new_MS1_name(~,~)
                temp_name = get(new_MS1_name_handle, 'String');
                found = 0;
                for i = 1:MS1_types
                    if strcmp(temp_name, MS1_type_names{i}) || strcmp(temp_name, 'New')
                        found = 1;
                    end                        
                end
                if ~found
                    MS1_types = MS1_types + 1;
                    MS1_type_names{end+1} = temp_name;
                    temp = 'New';
                    for i = 1:MS1_types
                        temp = [temp, '|', MS1_type_names{i}];
                    end
                    set(MS1_handle, 'String', temp,'Value', 1);
                end
                close(h5);
            end
            
            function remove_MS1_name(~,~)
                temp_name = MS1_type_names{get(MS1_handle, 'Value') - 1};
                i = 1;
                while i <= MS1_types
                    if strcmp(temp_name, MS1_type_names{i})
                        MS1_type_names(i) = [];
                        i = MS1_types;
                        MS1_types = MS1_types - 1;                        
                        temp = 'New';
                        for j = 1:MS1_types
                            temp = [temp, '|', MS1_type_names{j}];
                        end
                        set(MS1_handle, 'String', temp, 'Value', 1);
                    end
                    i = i + 1;
                end
                close(h5);
            end
        end
        
        temp = 'New';
        for i = 1:MS2_types
            temp = [temp, '|', MS2_type_names{i}];
        end
       
        MS2_handle = uicontrol('Style', 'popup',...
           'String', temp,...
           'Position', [100 30 100 30], ...
           'Callback', @name_MS2);               
       
       function name_MS2(~,~)
            h5 = figure;
            ax0 = axes('Position', [0,0,1,1], 'Visible', 'off');
            if get(MS2_handle,'Value') == 1                
                set(gcf, 'pos',[500,500,300,150], 'WindowStyle', 'modal',...
                    'name', 'Name New MS2 Type', 'numbertitle', 'off');
                
                text(25, 125, 'Name', 'Units', 'pixels');
                MS2_name_handle = uicontrol('Style', 'edit', 'pos', [25 85 150 30]);
                
                text(25, 70, 'Mass Tags (comma separated)', 'Units', 'pixels');
                MS2_fragment_masses = uicontrol('Style', 'edit', 'pos', [25 30 150 30]);
                
                uicontrol('Style', 'pushbutton', 'pos', [200 20 75 30], 'String', 'Save', 'Callback', @save_new_MS2_name);                
            else 
                set(gcf, 'pos',[500,500,325,150], 'WindowStyle', 'modal',...
                    'name', 'Name New MS2 Type', 'numbertitle', 'off');
                
                text(25, 125, 'Name', 'Units', 'pixels');
                MS2_name_handle = uicontrol('Style', 'edit', 'pos', [25 85 150 30], 'String', MS2_type_names{get(MS2_handle,'Value') - 1});
                
                text(25, 70, 'Mass Tags (comma separated)', 'Units', 'pixels');
                
                temp_string = num2str(MS2_mass_tags{get(MS2_handle,'Value') - 1}(1));
                for i = 2:length(MS2_mass_tags{get(MS2_handle,'Value') - 1})
                    temp_string = [temp_string,',', num2str(MS2_mass_tags{get(MS2_handle,'Value') - 1}(i))];
                end
                
                MS2_fragment_masses = uicontrol('Style', 'edit', 'pos', [25 30 150 30], 'String', temp_string);
                
                uicontrol('Style', 'pushbutton', 'pos', [225 10 75 30], 'String', 'Save', 'Callback', @save_new_MS2_name);                                    
                                          
                uicontrol('Style', 'pushbutton', 'pos', [225 45 75 30], 'String', 'Remove', 'Callback', @remove_MS2_name);                
            end
            
            function save_new_MS2_name(~,~)
                temp_name = get(MS2_name_handle, 'String');
                temp_mass_tags = regexp(get(MS2_fragment_masses, 'String'), ',', 'split');
                
                mass_tags = [];
                for i = 1:length(temp_mass_tags)
                    mass_tags(i) = str2num(char(temp_mass_tags(i)));
                end
                
                found = 0;
                for i = 1:MS2_types
                    if strcmp(temp_name, 'New')
                        found = 1;
                    elseif get(MS2_handle,'Value') > 1
                        found = 1;
                        MS2_type_names{get(MS2_handle,'Value') - 1} = temp_name;
                        MS2_mass_tags{get(MS2_handle,'Value') - 1} = mass_tags;
                        temp = 'New';
                        for i = 1:MS2_types
                            temp = [temp, '|', MS2_type_names{i}];
                        end
                        set(MS2_handle, 'String', temp,'Value', 1);
                    end
                end
                if ~found
                    MS2_types = MS2_types + 1;
                    MS2_type_names{end+1} = temp_name;
                    MS2_mass_tags{end+1} = mass_tags;
                    temp = 'New';
                    for i = 1:MS2_types
                        temp = [temp, '|', MS2_type_names{i}];
                    end                    
                    set(MS2_handle, 'String', temp,'Value', 1);
                end                
                close(h5);
            end
                       
            
            function remove_MS2_name(~,~)
                temp_name = MS2_type_names{get(MS2_handle, 'Value') - 1};
                i = 1;
                while i <= MS2_types
                    if strcmp(temp_name, MS2_type_names{i})
                        MS2_type_names(i) = [];
                        i = MS2_types;
                        MS2_types = MS2_types - 1;                        
                        temp = 'New';
                        for j = 1:MS2_types
                            temp = [temp, '|', MS2_type_names{j}];
                        end
                        set(MS2_handle, 'String', temp, 'Value', 1);
                    end
                    i = i + 1;
                end
                close(h5);
            end
       end
        
    end

    function change_mod(row)
    
        h3 = figure('pos',[350,350,750,350]);%, 'WindowStyle', 'modal');
        set(gcf,'name','Modification Editor','numbertitle','off', 'MenuBar', 'none');
        set(gca,'Position', [0,0,1,1], 'Visible', 'off');           
        
        % Create the button group for class selection
        h4 = uibuttongroup('visible','off','Position',[.7 .7 .3 .3], 'SelectionChangeFcn', @change_mod_type);
        % Create three radio buttons in the button group.
        u0 = uicontrol('Style','radiobutton','String','None',...
            'pos',[10 70 100 30],'parent',h4,'HandleVisibility','off');
        u1 = uicontrol('Style','radiobutton','String','MS1 Class',...
            'pos',[10 40 100 30],'parent',h4,'HandleVisibility','off');
        u2 = uicontrol('Style','radiobutton','String','MS2 Class',...
            'pos',[10 10 100 30],'parent',h4,'HandleVisibility','off');
        % Initialize some button group properties.        
        set(h4,'SelectedObject',u0);  % No selection
        set(h4,'Visible','on');                
        
        function change_mod_type(~,~)
            if get(u0,'Value') == 1
                set(MS1_handle, 'Enable', 'off');
                set(MS2_handle, 'Enable', 'off');
            elseif get(u1,'Value') == 1
                set(MS1_handle, 'Enable', 'on');
                set(MS2_handle, 'Enable', 'off');
            elseif get(u2,'Value') == 1
                set(MS1_handle, 'Enable', 'off');
                set(MS2_handle, 'Enable', 'on');
            end
        end
        
        if MS1_types > 0
            temp = MS1_type_names{1};
            for i = 2:MS1_types
                temp = [temp, '|', MS1_type_names{i}];
            end
        else
           temp = 'NONE'; 
        end
        MS1_handle = uicontrol('Style', 'popup',...
            'String', temp,...
            'Parent', h4, 'Position', [100 36 100 30]);                        
                
        if MS2_types > 0
            temp = MS2_type_names{1};
            for i = 2:MS2_types
                temp = [temp, '|', MS2_type_names{i}];
            end
        else
            temp = 'NONE';
        end
        
        MS2_handle = uicontrol('Style', 'popup',...
            'String', temp,...
            'Parent', h4, 'Position', [100 6 100 30]);
        
        
        t_size = size(table_data);
        if t_size(1) < row
            set(MS1_handle, 'Enable', 'off');
            set(MS2_handle, 'Enable', 'off');
        else
            if table_data{row,6}{1} == 0
                set(MS1_handle, 'Enable', 'off');
                set(MS2_handle, 'Enable', 'off');
                set(u0,'Value',1);
                set(u1,'Value',0);
                set(u2,'Value',0);
            elseif table_data{row,6}{1} == 1
                set(MS1_handle, 'Enable', 'on');                                
                set(MS2_handle, 'Enable', 'off');
                set(u0,'Value',0);
                set(u1,'Value',1);
                set(u2,'Value',0);
            elseif table_data{row,6}{1} == 2
                set(MS1_handle, 'Enable', 'off');
                set(MS2_handle, 'Enable', 'on');
                set(u0,'Value',0);
                set(u1,'Value',0);
                set(u2,'Value',1);
            end
            
        end
        
        uicontrol('Style', 'pushbutton',...
            'String', 'Done',...
            'Position', [50 10 100 25],...
            'Callback', @mod_done);
        
        text(10,312.5, 'Display Name', 'Units', 'pixels', 'VerticalAlignment', 'middle');
        text(10,282.5, 'MASCOT Name', 'Units', 'pixels', 'VerticalAlignment', 'middle');
        text(10,252.5, 'Residue', 'Units', 'pixels', 'VerticalAlignment', 'middle');
        text(10,222.5, 'Modification Type', 'Units', 'pixels', 'VerticalAlignment', 'middle');
        fixed_variable_handle = uicontrol('Style', 'popup',...
            'String', 'Fixed|Variable',...
            'Parent', h3, 'Position', [125 200 100 30]);                        
        
        
        text(10,192.5, 'Chemical Formula', 'Units', 'pixels', 'VerticalAlignment', 'middle');
        atom_names = {'H', 'C', 'N', 'O', 'S', 'P'};
        isotope_names = {'0', '+1', '+2', '+3'};
        [r,c] = size(table_data);
        
        if row <= r                                
            chemical_formula = table_data{row,4};
            handle_display_name = uicontrol('Style', 'edit',...
                'String', table_data{row,1},...
                'Position', [125 300 200 25]);
                        
            handle_MASCOT_name = uicontrol('Style', 'edit',...
                'String', table_data{row,2},...
                'Position', [125 270 200 25]);                                
            
            value = regexp(pos_AA, table_data{row,5});
            if length(value) > 1
               value = value(1); 
            end
            if value > 21
               value = 22; 
            end
            
            handle_AA = uicontrol('Style', 'edit',...
                'String', 'A|C|D|E|F|G|H|I|K|L|M|N|P|Q|R|S|T|V|W|Y|N-term|C-term',...
                'Position', [125 240 200 25],...
                'Value', value);
        else                        
            handle_display_name = uicontrol('Style', 'edit',...
                'String', '',...
                'Position', [125 300 200 25]);
                        
            handle_MASCOT_name = uicontrol('Style', 'edit',...
                'String', '',...
                'Position', [125 270 200 25]);
                        
            handle_AA = uicontrol('Style', 'popup',...
                'String', 'A|C|D|E|F|G|H|I|K|L|M|N|P|Q|R|S|T|V|W|Y|N-term|C-term',...
                'Position', [125 240 200 25]);
            
            chemical_formula{1,1} = 0;
            chemical_formula{2,1} = 0;
            chemical_formula{1,2} = 0;
            chemical_formula{2,2} = 0;
            chemical_formula{1,3} = 0;
            chemical_formula{2,3} = 0;
            chemical_formula{1,4} = 0;
            chemical_formula{2,4} = 0;
            chemical_formula{3,4} = 0;
            chemical_formula{1,5} = 0;
            chemical_formula{2,5} = 0;
            chemical_formula{3,5} = 0;
            chemical_formula{4,5} = 0;
            chemical_formula{1,6} = 0;
        end
        
        handle_composition = uitable('Parent', h3,...            
                                     'ColumnName', atom_names,...
                                     'RowName', isotope_names,...
                                     'ColumnWidth', {50 50 50 50 50 50 }, ...
                                     'ColumnEditable', [true true true true true true],...
                                     'ColumnFormat', {'numeric', 'numeric', 'numeric', 'numeric'},...
                                     'Position', [100 75 350 100], ...
                                     'Data', chemical_formula,...
                                     'CellEditCallback', @composition_edit);
        
%         function check_AA(a,~)
%             temp = get(a,'String');
%             if isempty(regexp(temp, '[ACDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwy]'))
%                 msgbox('Invalid Residue','Warning');
%             end                                    
%         end
                                 
        function composition_edit(~,b)
            if ~isempty(chemical_formula{b.Indices(1), b.Indices(2)})
                if b.NewData >= 0
                    chemical_formula{b.Indices(1), b.Indices(2)} = round(b.NewData);
                else
                    msgbox('Please choose a positive integer','Warning');
                end                
            else
                msgbox('Not a valid isotope','Warning');
            end
            set(handle_composition, 'Data', chemical_formula);
        end
        
        function mod_done(~,~)
            if ~isempty(get(handle_display_name, 'String')) && ~isempty(get(handle_AA, 'String'))                                                        
                
                table_data{row,1} = get(handle_display_name, 'String');
                table_data{row,2} = get(handle_MASCOT_name, 'String');
                table_data{row,3} = false;
                table_data{row,4} = chemical_formula;
                
                value = get(handle_AA, 'Value');
                if length(value) > 1
                    value = value(1);                    
                end
                if value < 21
                    table_data{row,5} = pos_AA(value);
                elseif value == 21;
                    table_data{row,5} = 'N-term';
                else
                    table_data{row,5} = 'C-term';
                end
                
                if get(fixed_variable_handle, 'Value') == 1
                    table_data{row,6} = 'Fixed';
                else
                    table_data{row,6} = 'Variable';
                end
                
                if get(u0,'Value') == 1
                    table_data{row,7} = '';
                    table_data{row,8} = '';
                elseif get(u1,'Value') == 1
                    if MS1_types > 0
                        table_data{row,7} = 'MS1';
                        table_data{row, 8} = MS1_type_names{get(MS1_handle,'Value')};
                    else
                        table_data{row,7} = '';
                        table_data{row,8} = '';
                    end
                elseif get(u2,'Value') == 1
                    if MS2_types > 0
                        table_data{row,7} = 'MS2';
                        table_data{row,8} = MS2_type_names{get(MS2_handle,'Value')};                        
                    else
                        table_data{row,7} = '';
                        table_data{row,8} = '';
                    end
                end                                
                set(t,'Data', table_data(:,[1,2,5,6,7,8,3]));
            end
            close(h3);
        end
    end

    function done(~,~)
        close(h2);
    end
end