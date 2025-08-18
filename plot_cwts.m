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

% Figure saving options. Ensure fig dir exists.
SAVE_FIGS = false; 
SAVE_FIG_DIR = "~/Figures";

% Force the spectrum and scalogram plots to have the same width.
% This aligns the x axis ticks of the two plots
FORCE_EQUAL_SPEC_AND_CWT_WIDTH = true;

% Make one figure with multiple spectra plotted on it
% Indexes correspond to the order in which data is loaded
MAKE_MULTIPLE_SPECTRA_PLOT = true;
multiple_spectra_idx = [1 2 3];
plot_colors = ["black" "blue" "red"];

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
for i=1:n_spectra
    [wtf, f, coi] = cwt(spectra(:,i), 'VoicesPerOctave', 48);
    cwt_results{i} = wtf;
end

%% Plot data

if PLOT_VIS
    x_lim_min = 350;
else
    x_lim_min = 700;
end

cwt_plot_width = 0;

if MAKE_MULTIPLE_SPECTRA_PLOT
    for i=1:n_spectra
        fig_handle = figure(i);
        fig_handle.Name = spectra_labels{i};
        fig_handle.NumberTitle = 'off';
        fig_handle.Position = [50 50 1000 1000];
        
        ax1 = subplot(2,1,1);
        make_spectrum_plot(spectra(:,i), wavelengths, x_lim_min);

        ax2 = subplot(2,1,2);
        make_cwt_subplot(cwt_results{i}, f, coi, x_lim_min, ...
                         wavelengths);

        if FORCE_EQUAL_SPEC_AND_CWT_WIDTH
            drawnow;
            if cwt_plot_width == 0
                cwt_plot_width = ax2.Position(3);
            end
            ax1.Position(3) = cwt_plot_width; 
        end

        if SAVE_FIGS
            name = fullfile(SAVE_FIG_DIR, i + " " + spectra_labels{i} + ...
                                          "_combined.png");
            exportgraphics(fig_handle, name, 'BackgroundColor', 'none');
        end
    end
else
    for i=1:n_spectra
        fig_spectrum_handle = figure(2*i-1);
        fig_spectrum_handle.Name = spectra_labels{i} + " Spectrum";
        fig_spectrum_handle.NumberTitle = 'off';
        fig_spectrum_handle.Position = [50 50 1000 500];
        
        ax_spectrum = make_spectrum_plot(spectra(:,i), wavelengths, x_lim_min);
        if FORCE_EQUAL_SPEC_AND_CWT_WIDTH
            drawnow;
        end
        
        fig_scalogram_handle = figure(i*2);
        fig_scalogram_handle.Name = spectra_labels{i} + " Scalogram";
        fig_scalogram_handle.NumberTitle = 'off';
        fig_scalogram_handle.Position = [50 50 1000 500];

        ax_cwt = make_cwt_subplot(cwt_results{i}, f, coi, x_lim_min, ...
                                  wavelengths);
        if FORCE_EQUAL_SPEC_AND_CWT_WIDTH
            drawnow;
            if cwt_plot_width == 0
                cwt_plot_width = ax_cwt.Position(3);
            end
            ax_spectrum.Position(3) = cwt_plot_width;
        end

        if SAVE_FIGS
            name = fullfile(SAVE_FIG_DIR, i + " " + spectra_labels{i} + ...
                                          "_spectrum.png");
            exportgraphics(fig_spectrum_handle, name, 'BackgroundColor', ...
                                                      'none');
            name = fullfile(SAVE_FIG_DIR, i + " " + spectra_labels{i} + ...
                                          "_scalogram.png");
            exportgraphics(fig_scalogram_handle, name, 'BackgroundColor', ...
                                                       'none');
        end
    end
end

if MAKE_MULTIPLE_SPECTRA_PLOT
    fig_handle = figure();
    fig_spectrum_handle.Name = "Combined Spectra";
    fig_spectrum_handle.NumberTitle = 'off';
    fig_handle.Position = [50 50 1000 500];
    
    hold on;
    for i=1:1:length(multiple_spectra_idx)
        spect_handle = plot(wavelengths, spectra(:,multiple_spectra_idx(i)), ...
                            'Color', plot_colors(i));
    end
    grid on;
    ylabel("Reflectance (%)");
    ylim([0 1]);
    yticks([0:0.1:2]);
    xlabel("Wavelength (nm)");
    xlim([x_lim_min 2500]);
    xticks([x_lim_min:100:2500]);
    legend(strrep(spectra_labels(multiple_spectra_idx), '_', '\_'), "Location","northeast");
    
    drawnow;
    spect_handle.Parent.Position(3) = cwt_plot_width;
    
    if SAVE_FIGS
        name = fullfile(SAVE_FIG_DIR, "combined.png");
        exportgraphics(fig_handle, name, 'BackgroundColor', 'white');
    end

end

function ax = make_spectrum_plot(spectrum, wavelengths, x_lim_min)
    
    plot_handler = plot(wavelengths, spectrum);
    grid on;
    ylabel("Reflectance (%)");
    ylim([0 ceil(max(spectrum)*10)/10]);
    yticks([0:0.1:2]);
    xlabel("Wavelength (nm)");
    xlim([x_lim_min 2500]);
    xticks([x_lim_min:100:2500]);

    ax = plot_handler.Parent;
end

function ax = make_cwt_subplot(wtf, f, coi, x_lim_min, wavelengths)
    
    xlabel("Wavelength (nm)");
    xlim([x_lim_min 2500]);
    xticks([x_lim_min:100:2500]);
    
    % Spatial frequency only up to 0.1nm -1 as there are no components 
    % above that due to the upscaling of the spectral data to 1nm
    ylabel("Spatial Frequency (nm^-1)");
    ylim([0.0015 0.1]);
    yticks([0.005 0.01 0.05 0.1]); 
    
    surf_handle = surface(wavelengths,f,abs(wtf));
    shading flat;
    
    % Get variable ax for return and make ticks visible
    ax = surf_handle.Parent;
    set(ax,'TickDir','out');
    ax.YAxis.LineWidth = 2;

    set(ax,"yscale","log");
    
    hold on;
    
    % Plot COI above data (i.e. with higher Z so that it is visible)
    coi_handle = plot(wavelengths,coi,"w--",LineWidth=2);
    set(coi_handle,'ZData',max(max(abs(wtf)))*ones(length(wavelengths),1));

    if x_lim_min == 350 % I know this is a code smell. Please ignore :)
        max_abs_in_plot = max(max(abs(wtf))); 
    else
        idx = find(wavelengths > 700);
        wtf_ir_only = wtf(:, idx);
        max_abs_in_plot = max(max(abs(wtf_ir_only)));  
    end
    
    % Make colorbar round to nearest "even" number for a nicer look
    colorbar_max = min((ceil(max_abs_in_plot*100/2)*2)/100, 0.1);
    colorbar('Ticks',[0 colorbar_max/2 colorbar_max]);
    caxis([0 colorbar_max]);
end