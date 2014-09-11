function print_compare(data, scan, id, print_file_name)


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
plot_assignment(data, scan,id);
set(gca, 'TickDir', 'out', 'box', 'off');
ylim([0,1.25*max(data{scan}.scan_data(:,2))]);

x_start = 0.95 * data{scan}.fragments{id}.validated{1,1};
x_end = 1.05 * data{scan}.fragments{id}.validated{end,1};

xlim([x_start,x_end]);
xlabel('m/z', 'Fontsize', 20);
ylabel('Intensity', 'Fontsize', 20);

set(gcf,'PaperPositionMode','auto');
print(fig2, '-dtiff', '-r600', print_file_name);
close(fig2);
end

% Plot fragment label assignments onto active axes
function plot_assignment(data, scan,id)
CID_tol = 1e-3;
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