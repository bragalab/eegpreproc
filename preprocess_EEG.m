% Convert raw data into preprocessed data. To be used for all
% datatypes (STIM, VIVID, FIX, etc.). 
%
% Created by Chris Cyr, Ruize Yang and Yesh Vempati. Last updated April 2023.
% This script will do the following for the raw data at the given destination (INPATH)
% 0. Load downsampled data
% 1. Remove Bad Data that was marked during EEGQC
% 2. Automatically mark additional channels (loud, white matter, near stim site, etc.)
% 3. Find Events, if necessary
% 4. Epoch
% 5. Notch Filter, if necessary
% 6. Detect bad trials, if necessary
% 7. Re-reference
% 8. Time Frequency decomposition
% 9. Normalize Data
% 10.Save to file at new destination (processed folder)
%
% This script is currently only built out for STIM, VIVID, and FIX data

function preprocess_EEG(INPATH, varargin)
%% add paths
addpath('/projects/b1134/tools/fieldtrip-20220202/') %add fieldtrip toolbox
addpath('/projects/b1134/tools/electrode_visualization') %add inter-electrode distance toolbox
addpath('/projects/b1134/tools/eeganalysis')
addpath('/projects/b1134/tools/eegqc')
addpath(genpath('/projects/b1134/tools/eegpreproc'))
addpath('/projects/b1134/tools/Zelanotools/')
ft_defaults

%% interpret input arguments
if ~isempty(varargin)
    if strcmp(varargin{1}, 'nointeraction')
        interaction = 0;
    end
else
    interaction = 1;
end

%% downsample raw data
if contains(INPATH, 'STIM')
    [SubjectID,SessionID,TaskID,StimSite,CurrentID, OUTPATH,...
        raw_channels,channel_IDs,Events,Stim1,Stim2,newsamplefreq] = load_downsampled_data_STIM(INPATH);
elseif contains(INPATH, 'VIVID')
    [SubjectID,SessionID,TaskID,OUTPATH,...
        raw_channels,channel_IDs,Events,newsamplefreq] = load_downsampled_data_VIVID(INPATH);  
elseif contains(INPATH, 'FIX')
    [SubjectID,SessionID,TaskID,OUTPATH,...
        raw_channels,channel_IDs,Events,newsamplefreq] = load_downsampled_data_FIX(INPATH);    
else
	fprintf('This datatype is currently not supported for preprocessing.\n')   
    return
end

%% Remove/Mark Bad Data
if contains(INPATH, 'STIM')
    [bad_channels, bad_segments, power_spectrum_deviant_channels, ...
        out_channels, path_channels, exclusion_channels, white_channels, ...
        loud_channels, channel_IDs, QCd_channels] = ...
        remove_data_STIM(OUTPATH, channel_IDs, raw_channels, newsamplefreq, SubjectID, interaction);
elseif contains(INPATH, 'VIVID')
    [bad_channels, bad_segments, power_spectrum_deviant_channels, ...
        out_channels, path_channels, white_channels, ...
        loud_channels, channel_IDs, QCd_channels] = ...
        remove_data_VIVID(OUTPATH, channel_IDs, raw_channels, newsamplefreq, SubjectID, interaction);          
elseif contains(INPATH, 'FIX')
    [bad_channels, bad_segments, power_spectrum_deviant_channels, ...
        out_channels, path_channels, white_channels, ...
        loud_channels, channel_IDs, QCd_channels] = ...
        remove_data_FIX(OUTPATH, channel_IDs, raw_channels, newsamplefreq, SubjectID, interaction);        
end
clear raw_channels

%% Epoch Data
if contains(INPATH, 'STIM')
    [epoched_ft_data, window, padding] = epoch_data_STIM(channel_IDs, newsamplefreq, QCd_channels, OUTPATH, Events);
elseif contains(INPATH, 'VIVID')
    [epoched_ft_data, window, BehavType, CondType, VisGrade, padding, Events] = epoch_data_VIVID(SubjectID, SessionID, TaskID, channel_IDs, newsamplefreq, QCd_channels, Events);
elseif contains(INPATH, 'FIX')
    [epoched_ft_data, window, padding, Events] = epoch_data_FIX(channel_IDs, newsamplefreq, QCd_channels, Events);
end
clear QCd_channels

%% Notch Filter Data
if contains(INPATH, 'STIM')
    fprintf('No Notch filtering is applied for stimulation data.\n')
    notchfiltered_ft_data = epoched_ft_data;
elseif contains(INPATH, 'VIVID')
    notchfiltered_ft_data = filter_data_VIVID(epoched_ft_data);
elseif contains(INPATH, 'FIX')
    notchfiltered_ft_data = filter_data_FIX(epoched_ft_data);
end
clear epoched_ft_data

%% convert back to Braga Lab Format
notchfiltered_data = zeros(height(notchfiltered_ft_data.trial{1}),...
    width(notchfiltered_ft_data.trial{1}), width(notchfiltered_ft_data.trial));
for i = 1:width(notchfiltered_ft_data.trial)
    notchfiltered_data(:,:,i) = notchfiltered_ft_data.trial{i};
    notchfiltered_ft_data.trial{i} = [];
end
empty_ft_data = notchfiltered_ft_data;
clear notchfiltered_ft_data


%% Exclude Trials/Epochs
if contains(INPATH, 'STIM')
    [trialx_data, bad_epochs] = reject_epochs_STIM(notchfiltered_data, channel_IDs, window, OUTPATH, interaction);
elseif contains(INPATH, 'VIVID')
    [trialx_data, bad_epochs] = reject_epochs_VIVID(notchfiltered_data, OUTPATH);
elseif contains(INPATH, 'FIX')
    fprintf('No Epoch Rejection is applied for fixation data.\n')
    trialx_data = notchfiltered_data;
end
clear notchfiltered_data

%% Store raw LFP signals for downstream processing (leftover code from Yesh Project)
%if contains(INPATH, 'STIM')
%    fprintf('No temporary files are stored for stimulation data.\n')
%elseif contains(OUTPATH, 'VIVID')
%    store_LFPs_VIVID(SubjectID, SessionID, TaskID, channel_IDs, ...
%    good_channels, bad_channels, loud_channels, path_channels, ...
%    out_channels, bad_segments, white_channels, power_spectrum_deviant_channels,...
%        epoched_data, padding, newsamplefreq)
%elseif contains(OUTPATH, 'FIX')
%    store_LFPs_FIX(SubjectID, SessionID, TaskID, channel_IDs, ...
%    good_channels, bad_channels, loud_channels, path_channels, ...
%    out_channels, bad_segments, white_channels, power_spectrum_deviant_channels,...
%        epoched_data, newsamplefreq)   
%end

%% rereference
if contains(INPATH, 'STIM')
    [rereferenced_data, channel_IDs] = rereference_data_STIM(channel_IDs, trialx_data, SubjectID);
elseif contains(INPATH, 'VIVID')
    rereferenced_data = rereference_data_VIVID(channel_IDs, trialx_data, empty_ft_data,...
        out_channels, bad_channels, path_channels, power_spectrum_deviant_channels);
elseif contains(INPATH, 'FIX')
    rereferenced_data = rereference_data_FIX(channel_IDs, trialx_data, empty_ft_data,...
        out_channels, bad_channels, path_channels, power_spectrum_deviant_channels,...
        loud_channels);
end
clear trialx_data

%% Time-Frequency Decomposition
if contains(OUTPATH, 'STIM')
    %timefreq_data = timefreq_decomp_STIM(rereferenced_data, empty_ft_data, channel_IDs, OUTPATH, padding, newsamplefreq);
    timefreq_data = rereferenced_data;
elseif contains(OUTPATH, 'VIVID')
    timefreq_data = timefreq_decomp_VIVID(rereferenced_data, empty_ft_data, channel_IDs);
elseif contains(OUTPATH, 'FIX')
    timefreq_data = timefreq_decomp_FIX(rereferenced_data, empty_ft_data, channel_IDs, padding, newsamplefreq);
end
clear rereferenced_data

%% Remove Padding
if contains(OUTPATH, 'STIM')
    [unpadded_data, window] = remove_padding_STIM(timefreq_data, padding, window);
elseif contains(OUTPATH, 'VIVID') 
    [unpadded_data, window] = remove_padding_VIVID(timefreq_data, padding, window);
elseif contains(OUTPATH, 'FIX')
    [unpadded_data, window] = remove_padding_FIX(timefreq_data, padding, window);
end
clear timefreq_data

%% Data Normalization   
fprintf('Normalizing Data.\n')
if contains(OUTPATH, 'STIM')
    Z_data = normalize_data_STIM(unpadded_data, empty_ft_data, window);
elseif contains(OUTPATH, 'VIVID')
    Z_timefreq_data = normalize_data_VIVID(unpadded_data,window);
elseif contains(OUTPATH, 'FIX')
%    project = input('Is this data part of the VIVID project or the HFBvsBOLD Project? (1 or 2)');
%    if project == 1
%        TFR_normalized_data = normalize_data_FIX(timefreq_data);
%    elseif project == 2
        Z_timefreq_data = normalize_data_FIX_CC(unpadded_data);
%    end
end   
clear unpadded_data

%% save preprocessed data
if contains(OUTPATH, 'STIM')
    save_preprocessed_data_STIM(SubjectID, OUTPATH, SessionID, TaskID, StimSite,...
    channel_IDs, bad_channels, path_channels, exclusion_channels, out_channels,...
    bad_segments, white_channels, power_spectrum_deviant_channels, loud_channels, ...
    bad_epochs, Stim1, Stim2, Z_data, CurrentID)
elseif contains(OUTPATH, 'VIVID')
    save_preprocessed_data_VIVID(SubjectID, INPATH, OUTPATH, SessionID, TaskID,...
        channel_IDs, bad_channels, loud_channels, path_channels, out_channels, ...
        bad_segments, white_channels, power_spectrum_deviant_channels,...
                Z_timefreq_data,BehavType, CondType, VisGrade)        
elseif contains(OUTPATH, 'FIX')
    save_preprocessed_data_FIX(SubjectID, OUTPATH, SessionID, TaskID,...
        channel_IDs, bad_channels, path_channels, out_channels,...
         white_channels, power_spectrum_deviant_channels, loud_channels, ...
        Z_timefreq_data)
    HFB_preproc_results(OUTPATH)
end

end
