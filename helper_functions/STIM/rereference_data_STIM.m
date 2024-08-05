function [epoched_data, channel_IDs] = rereference_data_STIM(channel_IDs, epoched_data, SubjectID)
%% add paths
addpath('/projects/b1134/tools/eegpreproc')

%% bipolar rereference
fprintf('Bipolar Rereferencing.\n')
[epoched_data, channel_IDs] = bipolar_reref(channel_IDs, SubjectID, epoched_data);

end