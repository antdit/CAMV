num_peaks = 50;

        seq = 'WHITELABORATORy'
%         protein = data{scan}.protein;
%         charge_state = data{scan}.pep_exp_z;
%         scan_number = data{scan}.scan_number;
%         
        data{1}.mass = 216.04;
        data{1}.intensity = 38;
        data{1}.name = 'pY';
        
        data{2}.mass = 262.05;
        data{2}.intensity = 20;
        data{2}.name = 'y_{1}';
        
        data{3}.mass = 418.15;
        data{3}.intensity = 52;
        data{3}.name = 'y_{2}';
        
        data{4}.mass = 437.23;
        data{4}.intensity = 24;
        data{4}.name = 'b_{3}';
        
        data{5}.mass = 667.32;
        data{5}.intensity = 33;
        data{5}.name = 'b_{5}';
        
        data{6}.mass = 774.34;
        data{6}.intensity = 40;
        data{6}.name = 'y_{4}';
        
        data{7}.mass = 845.39;
        data{7}.intensity = 18;
        data{7}.name = 'y_{5}';
        
        data{8}.mass = 965.48;
        data{8}.intensity = 100;
        data{8}.name = 'b_{8}';
        
        data{9}.mass = 1001.49;
        data{9}.intensity = 88;
        data{9}.name = 'y_{6}';
        
        data{10}.mass = 1256.65;
        data{10}.intensity = 68;
        data{10}.name = 'y_{7}';
        
        data{11}.mass = 1370.69;
        data{11}.intensity = 25;
        data{11}.name = 'y_{8}';
        
        data{12}.mass = 1376.74;
        data{12}.intensity = 64;
        data{12}.name = 'b_{10}';
        
        data{13}.mass = 1441.73;
        data{13}.intensity = 75;
        data{13}.name = 'y_{9}';
        
        data{14}.mass = 1548.83;
        data{14}.intensity = 43;
        data{14}.name = 'b_{12}';
        
        data{15}.mass = 1683.86;
        data{15}.intensity = 15;
        data{15}.name = 'y_{11}';
        
        data{16}.mass = 1784.91;
        data{16}.intensity = 23;
        data{16}.name = 'y_{12}';
        
        data{17}.mass = 1897.99;
        data{17}.intensity = 28;
        data{17}.name = 'y_{13}';
        
        for i = 18:num_peaks
            data{i}.name = '';
            data{i}.intensity = 10 * rand;
            data{i}.mass = 1800 * rand + 200;
        end
        
        b_used = zeros(length(seq),1);
        y_used = zeros(length(seq),1);
        
        R = size(data,2);
        for i = 1:R            
            if regexp(data{i}.name,'b')
                [~,~,~,d] = regexp(data{i}.name,'[0-9]*');
                b_used(str2num(d{1})) = 1;
            elseif regexp(data{i}.name,'y')
                [~,~,~,d] = regexp(data{i}.name,'[0-9]*');
                y_used(str2num(d{1})) = 1;
            end            
        end
        
        % Print with black background
        fig2 = figure('pos', [100 100 800 400]);
        set(gcf, 'InvertHardCopy', 'off');
        set(gca,'Visible','off');
        
        x_start = 40;
        y_start = 310;
        
        num_font_size = 25;
                
        space_x = 20;        
                
        text(x_start, y_start, seq(1), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'Color', [1 1 1], 'FontSize', num_font_size);
        
        prev = x_start;
        
        for i = 2:length(seq)
            if b_used(i-1) == 1 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '\color{red}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            elseif b_used(i-1) == 1 && y_used(end-i+1) == 0
                text(prev + space_x, y_start, '\color{red}^{\rceil}\color{gray}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            elseif b_used(i-1) == 0 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '\color{gray}^{\rceil}\color{red}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            else
                text(prev + space_x, y_start, '\color{gray}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            end
            if i > 5
                text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'Color', [0 1 0] ,'FontSize', num_font_size);
            else
               text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'Color', [1 1 1], 'FontSize', num_font_size);         
            end
            prev = prev + 2*space_x;
        end
        
        scan_data = [];
        for i = 1:num_peaks
            scan_data(i,1) = data{i}.mass;
            scan_data(i,2) = data{i}.intensity;
        end
        
        ax1_pdf = axes('Position', [.12,.15,.8,.55], 'TickDir', 'out', 'box', 'off');
                               
        axes(ax1_pdf);
        stem(scan_data(:,1),scan_data(:,2),'Marker', 'none', 'Linewidth', 2);
        
        %%%%
         hold on;
                                         
        x_start = 195; %0.95 * min(scan_data(:,1));
        x_end = 1.05 * max(scan_data(:,1));
        
        x_range = [x_start,x_end];
        
        for i = 1:17
            x = data{i}.mass;
            y = data{i}.intensity;
            text(x,y,['  ', data{i}.name],'FontSize', 8, 'Rotation', 90, 'Color', [1 1 1]);
            plot(data{i}.mass, data{i}.intensity, '*g');
        end
        hold off;
        %%%%
        
        
        set(gca, 'TickDir', 'out', 'box', 'off');
        ylim([0,100]);
               
        xlim([x_start,x_end]);
        xlabel('m/z', 'Fontsize', 14, 'Color', [1 1 1]);
        ylabel('Intensity (%)', 'Fontsize', 14, 'Color', [1 1 1]);             
        
        hold on;
        plot([0,2500],[0 0],'Color', [1 1 1]);
        hold off;
        set(gca,'ycolor', [1 1 1]);
        set(gca,'xcolor', [1 1 1]);
        set(fig2, 'Color', [0 0 0]);
        set(gca, 'Color', 'none');
        set(gcf,'PaperPositionMode','auto');
        
        print(fig2, '-dtiff', '-r600', 'white_laboratory_b');
        close(fig2);
        
        
        % Print with white background
        fig2 = figure('pos', [100 100 800 400]);       
        set(gca,'Visible','off');
        
        x_start = 40;
        y_start = 310;
        
        num_font_size = 25;
                
        space_x = 20;        
                
        text(x_start, y_start, seq(1), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
        
        prev = x_start;
        
        for i = 2:length(seq)
            if b_used(i-1) == 1 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '\color{red}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            elseif b_used(i-1) == 1 && y_used(end-i+1) == 0
                text(prev + space_x, y_start, '\color{red}^{\rceil}\color{gray}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            elseif b_used(i-1) == 0 && y_used(end-i+1) == 1
                text(prev + space_x, y_start, '\color{gray}^{\rceil}\color{red}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            else
                text(prev + space_x, y_start, '\color{gray}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
            end
            if i > 5
                text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'Color', [0 .75 0] ,'FontSize', num_font_size);
            else
               text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);         
            end
            prev = prev + 2*space_x;
        end
        
        scan_data = [];
        for i = 1:num_peaks
            scan_data(i,1) = data{i}.mass;
            scan_data(i,2) = data{i}.intensity;
        end
        
        ax1_pdf = axes('Position', [.12,.15,.8,.55], 'TickDir', 'out', 'box', 'off');
                               
        axes(ax1_pdf);
        stem(scan_data(:,1),scan_data(:,2),'Marker', 'none', 'Linewidth', 2);
        
        %%%%
         hold on;
                                         
        x_start = 195; %0.95 * min(scan_data(:,1));
        x_end = 1.05 * max(scan_data(:,1));
        
        x_range = [x_start,x_end];
        
        for i = 1:17
            x = data{i}.mass;
            y = data{i}.intensity;
            text(x,y,['  ', data{i}.name],'FontSize', 8, 'Rotation', 90);
            plot(data{i}.mass, data{i}.intensity, '*g');
        end
        hold off;
        %%%%
        
        
        set(gca, 'TickDir', 'out', 'box', 'off');
        ylim([0,100]);
               
        xlim([x_start,x_end]);
        xlabel('m/z', 'Fontsize', 14);
        ylabel('Intensity (%)', 'Fontsize', 14);             
                
        set(gcf,'PaperPositionMode','auto');
        
        print(fig2, '-dtiff', '-r600', 'white_laboratory_w');
        close(fig2);