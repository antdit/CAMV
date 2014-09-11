
function print_pdf(fig, seq, b_ions, y_ions, b_used, y_used, fig_name, charge_state, protein, filename, scan_number)
% fig : figure handle containing spectra and labels
% seq : string containing peptide sequence
% b_used : vector with b ions that appear in spectra (1) or don't (0)
% y_used : vector with y ions that appear in spectra (1) or don't (0)

% fig = figure;

xlabel('m/z');
ylabel('Intensity');

text(-40, 665, protein, 'Units', 'pixels', 'FontSize', 10);
text(-40, 650, ['Charge State: +', num2str(charge_state)], 'Units', 'pixels', 'FontSize', 10);
text(-40, 635, ['Scan Number: ', num2str(scan_number)], 'Units', 'pixels', 'FontSize', 10);
text(-40, 620, ['File Name: ', filename, '.raw'], 'Units', 'pixels', 'FontSize', 10, 'Interpreter', 'none');

x_start = -40;
y_start = 700;

num_font_size = 5;

space_x = 20;
space_y = 20;

text(x_start, y_start + space_y, num2str(b_ions(1)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
text(x_start, y_start, seq(1), 'Units', 'pixels', 'HorizontalAlignment', 'Center')

prev = x_start;

for i = 2:length(seq)
    if b_used(i-1) == 1 && y_used(end-i+2) == 1        
        text(prev + space_x, y_start, '\color{red}^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
    elseif b_used(i-1) == 1 && y_used(end-i+2) == 0        
       text(prev + space_x, y_start, '\color{red}^{\rceil}\color{black}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
    elseif b_used(i-1) == 0 && y_used(end-i+2) == 1       
        text(prev + space_x, y_start, '^{\rceil}\color{red}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
    else
        text(prev + space_x, y_start, '^{\rceil}_{ \lfloor}', 'Units', 'pixels', 'FontSize', 18, 'HorizontalAlignment', 'Center');
    end
    
    if i < length(seq)
        text(prev + 2*space_x, y_start + space_y, num2str(b_ions(i)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
    end
    text(prev + 2*space_x, y_start, seq(i), 'Units', 'pixels', 'HorizontalAlignment', 'Center');
    text(prev + 2*space_x, y_start - space_y, num2str(y_ions(end-i+2)), 'Units', 'pixels', 'HorizontalAlignment', 'Center', 'FontSize', num_font_size);
    prev = prev + 2*space_x;
end

orient landscape


paperUnits = get(fig, 'PaperUnits');
set(gcf, 'PaperUnits','inches');
paperSize = get(fig,'PaperSize');
paperPosition = [-1 -.5 paperSize + [2 .5]];
set(gcf, 'PaperPosition', paperPosition);
set(gcf, 'PaperUnits',paperUnits);

print('-dpdf', '-r900', fig_name)