function [epoched_data, bad_epochs] = reject_epochs_STIM(epoched_data, channel_IDs, window, OUTPATH, interaction)
%% add paths
addpath('/projects/b1134/tools/eegpreproc/helper_functions')

%% exclude trials that overlap with bad segments
fprintf('Excluding any epochs that overlap with bad segments.\n')
nan_epochs = zeros(size(epoched_data,1), size(epoched_data,3)); %channel x trial
for i = 1:size(epoched_data,1) %for each channel 
	for j = 1:size(epoched_data,3) %for each trial
        if sum(isnan(epoched_data(i,:,j))) > 0  
            nan_epochs(i,j) = 1;
        end
	end
end


%% Epoch Rejection
fprintf('Detecting Bad Epochs.\n')
if exist(sprintf('%s/Bad_Epochs.txt', OUTPATH), 'file')
    if interaction == 1
        response = input('A file has been found with existing Bad Trials for this run, would you like to use these (y or n)?', 's');
    else
        response = 'y'; %automatically use old file
    end
    if strcmp(response,'y')
        fprintf('Loading Old Bad Epochs.\n')
        bad_epochs = importdata(sprintf('%s/Bad_Epochs.txt', OUTPATH));
        bad_epochs = bad_epochs | nan_epochs;
        writematrix(bad_epochs, sprintf('%s/Bad_Epochs.txt', OUTPATH))
    else   
        threshold = 500; %uV
        bad_epochs = Bad_Epoch_Detector_STIM(epoched_data, channel_IDs, window, threshold);
        bad_epochs = bad_epochs | nan_epochs;
        writematrix(bad_epochs, sprintf('%s/Bad_Epochs.txt', OUTPATH))
        fprintf('New Bad Epochs have been loaded and written to a txt file.\n')
    end
else
    threshold = 500; %uV
    bad_epochs = Bad_Epoch_Detector_STIM(epoched_data, channel_IDs, window, threshold);
    bad_epochs = bad_epochs | nan_epochs;
    writematrix(bad_epochs, sprintf('%s/Bad_Epochs.txt', OUTPATH))
    fprintf('New Bad Epochs have been loaded and written to a txt file.\n')
end

fprintf('Excluding %i Epochs.\n', sum(sum(bad_epochs)))
for i = 1:size(epoched_data,1) %for each channel
    epoched_data(i,:, logical(bad_epochs(i,:))) = NaN;
end    


end
