function [ft_data, window, padding] = epoch_data_STIM(channel_IDs, newsamplefreq, good_channels, OUTPATH, Events)
%% add paths
addpath('/projects/b1134/tools/fieldtrip-20220202/') %add fieldtrip toolbox
ft_defaults

%% convert to fieldtrip format
cfg = [];
cfg.label = channel_IDs(:,1);
cfg.fsample = newsamplefreq;
cfg.trial{1} = good_channels;
cfg.time{1} = (1:size( cfg.trial{1}, 2))/cfg.fsample;
ft_data = ft_datatype_raw(cfg);

%% epoch data with padding
if contains(OUTPATH, 'NWB')
    epoch_begin = -500; %samples aka ms
    epoch_end = 499; %the clincal stim trials are shorter, stimulate at 1 Hz
    padding = 5;
    window = epoch_begin-padding:epoch_end+padding;
else
    epoch_begin = -500; %samples aka ms
    epoch_end = 1499; 
    padding = 0;
    window = epoch_begin-padding:epoch_end+padding;
end
if contains(OUTPATH, 'sham') %for sham stim datsets
    Events = (1-epoch_begin:length(window)+10:length(good_channels)-epoch_end)'; %make up events
elseif isempty(Events) && ~exist(sprintf('%s/Events.txt', OUTPATH), 'file') %for stim datasets with no events  
    fprintf('This stimulation dataset has no events. Finding them now.\n')
    Events = Stim_Event_Finder(OUTPATH);
elseif isempty(Events)
    Events = importdata(sprintf('%s/Events.txt', OUTPATH));
end

fprintf('Epoching Data.\n')
cfg = [];            %start               %end                          %trigger offset
cfg.trl = [round(Events)+epoch_begin-padding, round(Events)+epoch_end+padding, ones(length(Events),1)*(epoch_begin-padding)];%Nx3 matrix with the trial definition
ft_data = ft_redefinetrial(cfg, ft_data);

end