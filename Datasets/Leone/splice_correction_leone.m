% author: José Maravalhas-Silva

data_leone = readtable("./Leone.csv", 'VariableNamingRule', 'preserve');

for idx = 2:width(data_leone)

    % Correct VIS
    diff_vis = data_leone(651,idx) - data_leone(652,idx);
    data_leone(1:651,idx) = data_leone(1:651,idx) - diff_vis;
    
    % Check if SWIR2 needs correction at 1800nm or at 1830nm
    diff_1800 = table2array(data_leone(1451,idx) - data_leone(1452,idx));
    diff_1830 = table2array(data_leone(1451+30,idx) - data_leone(1452+30,idx));
    max_diff = max(abs(diff_1800),abs(diff_1830));

    if max_diff < 0.01
        disp("Idx " + string(idx) + " skipped")
        continue;
    end

    % Correct SWIR2
    if abs(diff_1800) > abs(diff_1830)
        disp("Idx " + string(idx) + " fix at 1800");
        data_leone(1452:end,idx) = data_leone(1452:end,idx) + diff_1800;
    else
        disp("Idx " + string(idx) + " fix at 1830");
        data_leone(1452+30:end,idx) = data_leone(1452+30:end,idx) + diff_1830;
    end

end

writetable(data_leone,"./Leone_corrected.csv");
