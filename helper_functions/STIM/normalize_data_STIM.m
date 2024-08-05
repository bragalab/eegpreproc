function Z_data = normalize_data_STIM(epoched_data, timefreq_data, window)
%% add paths
addpath('/projects/b1134/tools/Zelanotools/')
addpath('/projects/b1134/tools/fieldtrip-20220202/') %add fieldtrip toolbox
ft_defaults

%% Data Normalization   
fprintf('Normalizing Data.\n')
baselinewindow = -500:-50;
%broadband data
Z_data = NaN(size(epoched_data,1), size(epoched_data,2), size(epoched_data,3));
%trial specific Z score
for i = 1:size(epoched_data,1) %for each channel
    for j = 1:size(epoched_data,3) %for each trial
        %calculate trial specific parameters
        baseline = epoched_data(i, baselinewindow - window(1) + 1, j);
        baseline_mean = mean(baseline);
        baseline_SD = std(baseline);
        %normalize each trial
        Z_data(i,:,j) = (epoched_data(i,:,j)-baseline_mean)/baseline_SD;
    end
end
%time frequency data normalization and stats
%cfg = [];
%cfg.time = timefreq_data.time;
%cfg.freq = timefreq_data.freq;
%cfg.baseline = [-0.5, -0.1];
%cfg.toi = [0, 1.5];
%cfg.nboots = 1000;
%cfg.inital_pval = 0.001;
%cfg.cluster_stats = 'sumstats';

%realZ = zeros(size(timefreq_data.powspctrm,2), length(timefreq_data.freq), ...
%    length(timefreq_data.time));%Z-scored data channel x freq x time
%real_diff = zeros(size(timefreq_data.powspctrm,2), length(timefreq_data.freq), ...
%    length(timefreq_data.time));
%clustinfo = struct('Connectivity', cell(size(timefreq_data.powspctrm,2),1),...
%    'ImageSize', cell(size(timefreq_data.powspctrm,2),1),...
%    'NumObjects', cell(size(timefreq_data.powspctrm,2),1),...
%    'PixelIdxList', cell(size(timefreq_data.powspctrm,2),1));
%corrp = cell(size(timefreq_data.powspctrm,2),1);
%for i = 1:size(timefreq_data.powspctrm,2) %for each channel
%    fprintf('Normalizing channel %s. \n', timefreq_data.label{i})
%    %exclude nan trials
%    nan_trials = isnan(timefreq_data.powspctrm(:,i,50,1));
%    if sum(nan_trials) < size(timefreq_data.powspctrm,1)
%    	input_data = squeeze(timefreq_data.powspctrm(~nan_trials,i,:,:));
%    	%run permutation
%    	evalc('[realZ(i,:,:), real_diff(i,:,:), ~, clustinfo(i), corrp{i}, ~] = G_Permut_WithinPowChange( input_data, cfg);');
%    end
%end
%Z_timefreq_data.realZ = realZ;
%Z_timefreq_data.real_diff = real_diff;
%Z_timefreq_data.clustinfo = clustinfo;
%Z_timefreq_data.corrp = corrp;
%Z_timefreq_data.freq = timefreq_data.freq;
%Z_timefreq_data.time = timefreq_data.time;

%% add in other stuff
%Z_timefreq_data.itpc = timefreq_data.itpc;
%Z_timefreq_data.fractal_baseline = timefreq_data.fractal_baseline;
%Z_timefreq_data.original_baseline = timefreq_data.original_baseline;
%Z_timefreq_data.oscillatory_baseline = timefreq_data.oscillatory_baseline;
%Z_timefreq_data.fractal_activation = timefreq_data.fractal_activation;
%Z_timefreq_data.original_activation = timefreq_data.original_activation;
%Z_timefreq_data.oscillatory_activation = timefreq_data.oscillatory_activation;
%Z_timefreq_data.ap_baseline = timefreq_data.ap_baseline;
%Z_timefreq_data.ap_params_baseline = timefreq_data.ap_params_baseline;
%Z_timefreq_data.ap_activation = timefreq_data.ap_activation;
%Z_timefreq_data.ap_params_activation = timefreq_data.ap_params_activation;

end
