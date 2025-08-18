% Jose Maravalhas Silva, 2025
% MATLAB version R2025a

%% Force figures to use light theme
s = settings;
s.matlab.appearance.figure.GraphicsTheme.TemporaryValue = "light";

%% Load data

close all;
clearvars -except data_knaeps data_leone
if (exist("data_knaeps", "var") == 0) || (exist("data_leone", "var") == 0)
    data_knaeps = readtable("./Datasets/Knaeps/Knaeps_corrected.csv", ...
                            "VariableNamingRule", "preserve");
    data_leone  = readtable("./Datasets/Leone/Leone_corrected.csv", ...
                            "VariableNamingRule", "preserve");
end

%% Configs

% Set to false to plot only IR data (>700nm)
PLOT_VIS = false;
BLACKOUT_REDUNDANT_RESULTS = false;

% Figure saving options. Ensure fig dir exists.
%SAVE_FIGS = true; 
%SAVE_FIG_DIR = "~/Figures";

% Hint: see "data_knaeps" variable at runtime to get indexes
knaeps_data_to_analyze = [9];  % Blue PP rope

% Indexes here are equal to the IDs in the original metadata, hence the +2
leone_data_to_analyze = [1   ... % PP Carat
                         347 ... % PP ToC
                         21  ... % PE Carat
                         66  ... % PE BlueFoam
                         106 ... % PE MilkBottle
                         6   ... % PS Carat
                         26  ... % PS VITO
                         332 ... % PS Shop
]+2;

%% Data preprocessing

dataset_prefixes = {"(K)","(L)"};

% Aggregate all data for easier handling
relevant_data = {data_knaeps(:,[knaeps_data_to_analyze]), ...
                 data_leone(:, [leone_data_to_analyze]) };
wavelengths = table2array(data_leone(:,1));

% Add dataset-specific prefixes to spectra names
for i = 1:length(relevant_data)
    newNames = append(dataset_prefixes{i}, " ", ...
                      relevant_data{i}.Properties.VariableNames);

    relevant_data{i} = renamevars(relevant_data{i}, ...
                                  1:width(relevant_data{i}), ...
                                  newNames);
end

spectra = []; 
spectra_labels = [];

% Arrange data in a matrix for ease of use 
for i = 1:length(relevant_data)
    spectra = [spectra, table2array(relevant_data{i})];
    spectra_labels = [spectra_labels, ... 
                      relevant_data{i}.Properties.VariableNames];
end

[n_wavelengths, n_spectra] = size(spectra);

%% Compute CWT
cwt_results = cell(n_spectra, 1);

relevant_f_idx = [];
relevant_wavelength_idx = find(wavelengths>700);

for i=1:n_spectra
    [wtf, f, coi] = cwt(spectra(:,i), 'VoicesPerOctave', 48);
    
    % Select frequencies between 0.01 and 0.1 nm^-1
    if isempty(relevant_f_idx)
        relevant_f_idx = find((0.01<f) & (f<0.1));
    end

    cwt_magnitudes{i} = abs(wtf(relevant_f_idx, relevant_wavelength_idx));
end

%% Compute CWT Gradient Matching

cwtgm_matrix = zeros(n_spectra);

relevant_wavelengths = wavelengths(relevant_wavelength_idx);
relevant_f = f(relevant_f_idx);

for idx1 = 1:n_spectra
    for idx2 = idx1:n_spectra

        spectrum_1 = spectra(:,idx1);
        spectrum_2 = spectra(:,idx2);
        
        nan_index_in_spectrum_1 = find(isnan(spectrum_1));
        nan_index_in_spectrum_2 = find(isnan(spectrum_2));
        
        nan_indexes = unique([nan_index_in_spectrum_1; nan_index_in_spectrum_2]);
        
        if ~isempty(nan_indexes)
            spectrum_1(nan_indexes,:) = [];
            spectrum_2(nan_indexes,:) = [];
        end

        cwtgm_matrix(idx1, idx2) = cwt_gradient_matching(cwt_magnitudes{idx1}, ...
                                                         cwt_magnitudes{idx2}, ...
                                                         relevant_wavelengths, ...
                                                         relevant_f);
        
        if BLACKOUT_REDUNDANT_RESULTS
            cwtgm_matrix(idx2, idx1) = nan;
        else
            cwtgm_matrix(idx2, idx1) = cwtgm_matrix(idx1, idx2);
        end
      
    end
end

figure('Name','CWTGM Score','NumberTitle','off');
h = heatmap(spectra_labels,spectra_labels, cwtgm_matrix, 'Interpreter', 'none', 'ColorLimits',[0 1]);
h.CellLabelFormat = "%.2f";
title("CWTGM Score");


function score = cwt_gradient_matching(C1, C2, wavelengths, f)
    
    % Compute horizontal gradients
    [gx1, ~] = gradient(C1, wavelengths, f);
    [gx2, ~] = gradient(C2, wavelengths, f);
    
    gradient_dot_product = gx1 .* gx2;
    simNumerator = sum(gradient_dot_product(:));

    % Compute magnitudes and norms
    gradMag1 = sqrt(gx1.^2);
    gradMag2 = sqrt(gx2.^2);
    
    norm1 = sqrt(sum((gradMag1(:).^2)));
    norm2 = sqrt(sum((gradMag2(:).^2)));

    % Compute final similarity score
    score = simNumerator / (norm1 * norm2 + eps);%+eps ensures no division by zero
end
