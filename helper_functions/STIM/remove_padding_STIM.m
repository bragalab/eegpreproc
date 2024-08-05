function [epoched_data, window] = remove_padding_STIM(epoched_data, padding, window)
fprintf('Removing padding from Epochs.\n')
%% Remove Padding
epoched_data = epoched_data(:,1+padding:end-padding,:);
window = window(1+padding:end-padding);
end
