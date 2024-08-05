function Events = Stim_Event_Finder(OUTPATH)
%% add paths
addpath('/projects/b1134/tools/fieldtrip-20220202/') %add fieldtrip toolbox
ft_defaults

%% load downsampled data
fprintf('Loading pre-existing file %s/downsampled_data_uV.mat\n', OUTPATH)
load(sprintf('%s/downsampled_data_uV', OUTPATH), 'good_channels', 'channel_IDs',...
    'newsamplefreq','Stim1index', 'Stim1', 'Stim2index', 'Stim2');
%% load Stim channels
channel_choice = input('Do you want to use the stim channels to detect stim artifacts? If not it will use nearby channels. (y or n):', 's');

if strcmp(channel_choice, 'n')
    %find stim shaft, and pick something neighboring the stim channels
    StimShaft = Stim1(1:find(isletter(Stim1), 1, 'last'));
    AllShafts = cell(length(channel_IDs),1);
    for i = 1:length(channel_IDs) %from the list of all electrode names
        if strcmp(channel_IDs{i, 1}(1),'s')
            AllShafts{i} = 'SURF'; %relabel all surface electrodes as SURF
        else
            AllShafts{i} = channel_IDs{i, 1}(1:find(isletter(channel_IDs{i, 1}), 1, 'last'));
        end                     %relabel all iEEG electrodes as shaft name only
    end
    StimShaft_indices = find(matches(AllShafts, StimShaft));
    if Stim1index == StimShaft_indices(1) || Stim2index == StimShaft_indices(1) %if stim channels are at  beginning of shaft
        Stim1index = StimShaft_indices(1) + 2;
        Stim1 = channel_IDs{ Stim1index, 1};
        Stim2index = StimShaft_indices(1) + 3;
        Stim2 = channel_IDs{ Stim2index, 1};
        
    elseif Stim1index == StimShaft_indices(end) || Stim2index == StimShaft_indices(end) %if stim channels are at  beginning of shaft
        Stim1index = StimShaft_indices(end) - 2;
        Stim1 = channel_IDs{ Stim1index, 1};
        Stim2index = StimShaft_indices(end) - 3;
        Stim2 = channel_IDs{ Stim2index, 1};
    else %if stim channels are somewhere in the middle of the shaft
        if Stim1index < Stim2index
            Stim1index = Stim1index - 1;
            Stim1 = channel_IDs{ Stim1index, 1};
            Stim2index = Stim2index + 1;
            Stim2 = channel_IDs{ Stim2index, 1};
        else
            Stim1index = Stim1index + 1;
            Stim1 = channel_IDs{ Stim1index, 1};
            Stim2index = Stim2index - 1;
            Stim2 = channel_IDs{ Stim2index, 1};            
        end 
    end
    
end
% highpass filter stim signals
cfg = [];
cfg.label = channel_IDs([Stim1index Stim2index],1);
cfg.fsample = newsamplefreq;
cfg.trial{1} = good_channels([Stim1index Stim2index], :);
cfg.time{1} = (1:size( cfg.trial{1}, 2))/cfg.fsample;
ft_data = ft_datatype_raw(cfg); %convert to fieldtrip

cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 200;
ft_data = ft_preprocessing(cfg, ft_data);
filtered_Stim = ft_data.trial{1,1};

%% find Stim events
final_decision = 'n';
while strcmp(final_decision, 'n')
    f = figure;
    subplot(2,1,1);
    hold on
    plot(good_channels(Stim1index,:) ,'b') %plot original Stim1 signal
    ylabel(channel_IDs(Stim1index,1))
    h = plot(filtered_Stim(1,:), 'r');%plot filtered Stim1 signal
    ax = ancestor(h, 'axes'); %remove scientific notation
    ax.YAxis.Exponent = 0;
    ytickformat('%.0f')
    limits = ylim;
    yticks(limits(1):(limits(2) - limits(1))/10:limits(2))
    legend('Unfiltered', 'Filtered')

    subplot(2,1,2);
    hold on
    plot(good_channels(Stim2index,:) ,'b')%plot original Stim2 signal
    ylabel(channel_IDs(Stim2index,1))
    h = plot(filtered_Stim(2,:), 'r');%plot filtered Stim2 signal
    sgtitle(sprintf('%i Hz high pass filter', cfg.hpfreq))
    ax = ancestor(h, 'axes'); %remove scientific notation
    ax.YAxis.Exponent = 0;
    ytickformat('%.0f')
    limits = ylim;
    yticks(limits(1):(limits(2) - limits(1))/10:limits(2))
    legend('Unfiltered', 'Filtered')

    % make some decisions
    filter_choice = input('Do you want to use filtered or unfiltered signals (f or u)? :', 's');
    clip_choice = input('Do you want to ignore the ends of the file (y or n)? :', 's');
    channel_choice = input('Do you want to use the top channel or the bottom channel (1 or 2)? :');
    peak_choice = input('Which peaks do you want to detect on that channel (min or max)? :', 's');
    threshold = input('What absolute threshold do you want to use (must be positive integer)? :');
    close(f)
    
    if strcmp(filter_choice, 'f')
        signal = filtered_Stim(channel_choice,:);
    elseif strcmp(filter_choice, 'u') && channel_choice == 1
        signal = good_channels(Stim1index, :);
    elseif strcmp(filter_choice, 'u') && channel_choice == 2
        signal = good_channels(Stim2index, :);        
    end
    
    if strcmp(clip_choice, 'y')
        bad_segments = split(input("Enter the time segments to ignore ('0-5', '45-50'):", 's'), ',');
        for i = 1:length(bad_segments) %for each bad time segment
            times = split(bad_segments(i), '-');
            start_time = str2double(times{1})*newsamplefreq + 1; %convert to samples
            end_time = str2double(times{2})*newsamplefreq;
            signal(start_time:end_time) = 0;
        end
    end
    
    % find stim events
    if strcmp(peak_choice, 'max')
        [~, raw_stims] = findpeaks(signal, 'MinPeakDistance', 985, 'MinPeakHeight', threshold);
    elseif strcmp(peak_choice, 'min')
        [~, raw_stims] = findpeaks(-signal, 'MinPeakDistance', 985, 'MinPeakHeight', threshold);
    end

    fprintf('%i Events found\n', length(raw_stims))    
    fprintf('Interval Mean: %1.4f\n', mean(diff((raw_stims)))) 
    fprintf('Interval Std: %1.4f\n', std(diff((raw_stims))))
    
    % display events
    f = figure;
    ax1 = subplot(2,1,1);
    plot(filtered_Stim(1,:), 'r')
    ylabel(channel_IDs(Stim1index,1))
    hold on
    plot(raw_stims, filtered_Stim(1,raw_stims), 'b+')
    ax2 = subplot(2,1,2);
    plot(filtered_Stim(2,:), 'r')
    ylabel(channel_IDs(Stim2index,1))
    hold on
    plot(raw_stims, filtered_Stim(2,raw_stims), 'b+')
    linkaxes([ax1 ax2])
    sgtitle('Searching for Stim events')

    final_decision = input('Did I do a good job (y or n)?', 's');
    close(f)
end
Events = raw_stims';

end