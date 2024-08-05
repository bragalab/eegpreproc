function CCEP_flip(OUTPATH)
%% load data
    file = dir(sprintf('%s/*_ds_qcx_epoch_trialsx_bpref_z.mat', OUTPATH)); %find preprocessed file
    file.name(end-3:end) = []; %remove .mat
    load(sprintf('%s/%s.mat', OUTPATH, file.name))

%% average across epochs
Z_avg = mean(Z_data,3,'omitnan');

%% flip signals based on maximum evoked response
flip_indicator = false(size(Z_data,1),1);
Z_avg_flip = NaN(size(Z_avg));
Z_flip = NaN(size(Z_data));
Stim_time = 500;
response_window = (10:400) + Stim_time;

for i = 1:height(Z_avg)
   if max(Z_avg(i, response_window)) < abs(min(Z_avg(i, response_window)))
       Z_avg_flip(i,:) = -Z_avg(i,:); %flip averages
       Z_flip(i,:,:) = -Z_data(i,:,:); %flip trials
       flip_indicator(i) = true;
   else
       Z_avg_flip(i,:) = Z_avg(i,:);  
       Z_flip(i,:,:) = Z_data(i,:,:);
   end
end

Z_SE = std(Z_data, 0, 3, 'omitnan');
%% Save out files and delete temporary files
delete(sprintf('%s/%s.mat', OUTPATH, file.name))

OUTFILE = sprintf('%s/%s_flip.mat', OUTPATH, file.name);
save(OUTFILE , 'channel_IDs', 'bad_channels', ...
    'path_channels', 'exclusion_channels', 'out_channels', 'bad_segments',...
    'white_channels', 'power_spectrum_deviant_channels', 'bad_epochs',...
    'Stim1', 'Stim2', 'Z_flip', 'flip_indicator', 'loud_channels')

avg_OUTFILE = sprintf('%s/%s_flip_avg.mat', OUTPATH, file.name);
save(avg_OUTFILE , 'channel_IDs', 'bad_channels', ...
    'path_channels', 'exclusion_channels', 'out_channels', 'bad_segments',...
    'white_channels', 'power_spectrum_deviant_channels', 'bad_epochs',...
    'Stim1', 'Stim2', 'Z_avg_flip', 'Z_SE', 'flip_indicator', 'loud_channels')

