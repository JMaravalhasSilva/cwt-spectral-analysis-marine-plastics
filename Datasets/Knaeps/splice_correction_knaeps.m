% author: José Maravalhas-Silva

data_knaeps = readtable("./Knaeps.csv", 'VariableNamingRule', 'preserve');

for idx = 2:width(data_knaeps)
    % Correct VIS
    diff_vis = data_knaeps(651,idx) - data_knaeps(652,idx);
    data_knaeps(1:651,idx) = data_knaeps(1:651,idx) - diff_vis;
    
    % Correct SWIR2
    diff_swir2 = data_knaeps(1451,idx) - data_knaeps(1452,idx);
    data_knaeps(1452:end,idx) = data_knaeps(1452:end,idx) + diff_swir2;
end

writetable(data_knaeps,"./Knaeps_corrected.csv");
