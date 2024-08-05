function [bad_channels, bad_segments, power_spectrum_deviant_channels, ...
    out_channels, path_channels, exclusion_channels, white_channels, ...
    loud_channels, channel_IDs, good_channels] = ...
    remove_data_STIM(OUTPATH, channel_IDs, good_channels, newsamplefreq, SubjectID, interaction)
 %% add paths
addpath('/projects/b1134/tools/electrode_modeling') %add inter-electrode distance toolbox
addpath('/projects/b1134/tools/eegpreproc/helper_functions')

%% load info from QC excel for specific dataset
[bad_channels, bad_segments, power_spectrum_deviant_channels, out_channels, path_channels] = load_QCinfo(OUTPATH, interaction);

%% Remove/Mark bad data
%exclude bad channels, determined via the QC pdf
fprintf('Excluding Bad Channels.\n')
if ~isempty(bad_channels)    
    bad_channel_indices = matches(channel_IDs(:,1), bad_channels);
    good_channels(bad_channel_indices, :) = nan;
end

%exclude pathologic channels, determined by the clinical team
fprintf('Excluding Pathologic Channels.\n')
if ~isempty(path_channels)
    path_channel_indices = matches(channel_IDs(:,1), path_channels);
    good_channels(path_channel_indices, :) = nan;
end

%exclude channels outside of brain, determined via Electrode Visualization pdf
fprintf('Excluding Out of Brain Channels.\n')
if ~isempty(out_channels)
    out_channel_indices = matches(channel_IDs(:,1), out_channels);
    good_channels(out_channel_indices, :) = nan;
end

%exclude bad time segments, determined via the QC pdf
fprintf('Excluding Bad Segments.\n')
if ~isempty(bad_segments)
    for i = 1:length(bad_segments) %for each bad time segment
        times = split(bad_segments(i), '-');
        start_time = str2double(times{1})*newsamplefreq + 1; %convert to samples
        end_time = str2double(times{2})*newsamplefreq;
        good_channels(:, start_time:end_time) = nan;
    end
end

%mark channels near stim site but do not exclude
fprintf('Marking channels near the stimulation site, but not excluding them.\n')
stim_distance(OUTPATH);
load(sprintf('%s/monopolar_distances.mat', OUTPATH), 'distances')
exclusion_zone = 20; %mm
exclusion_indices = false(height(channel_IDs),1);
for i = 1:height(exclusion_indices) 
    exclusion_indices(i) = distances{strcmp(channel_IDs{i,1}, distances(:,1)), 2} < exclusion_zone;
end
exclusion_channels = channel_IDs(exclusion_indices,1);

%mark white matter contacts but do not exclude
fprintf('Marking channels in white matter, but not excluding them.\n')
if exist(sprintf('/projects/b1134/analysis/elec2roi/%s/elecs_surf_3mm_41k', SubjectID), 'dir')
    gray_channel_path = sprintf('/projects/b1134/analysis/elec2roi/%s/elecs_surf_3mm_41k', SubjectID);
else
    fprintf('%s Does not have 3mm spheres projected to 41k gray matter surface.\n Cannot determine channels in white matter.\n', SubjectID)
    return
end
gray_files = dir(gray_channel_path);
gray_channels = cell(length(gray_files),1);
for i = 1:length(gray_files)
    grayfile = split(gray_files(i).name, '_');
    graychannel = grayfile{1};
    if matches(graychannel, channel_IDs(:,1))
        gray_channels{i} = graychannel;
    end    
end
gray_channels(cellfun(@isempty, gray_channels)) = [];
gray_channels = unique(gray_channels);
[white_channels, ~] = setdiff(channel_IDs(:,1), gray_channels);   

%mark loud channels but do not exclude
fprintf('Marking channels with high variance, but not excluding them.\n')
channel_var = var(good_channels,0,2, 'omitnan');
loud_channels = channel_IDs(channel_var > 5*median(channel_var, 'omitnan'),1);  

end