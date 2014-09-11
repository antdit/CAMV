scan_data = [0.9 0.09;
             1 1;
             1.05 .5
             1.5 2];
prec = 1;

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