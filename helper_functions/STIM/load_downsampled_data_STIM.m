function [SubjectID, SessionID, TaskID, StimSite, CurrentID, OUTPATH,...
    good_channels, channel_IDs, Events, Stim1, Stim2, newsamplefreq] = load_downsampled_data_STIM(INPATH)
%% add paths
addpath('/projects/b1134/tools/eegqc')

%% load downsampled data
fileinfo = split(INPATH, '/');
ProjectID = fileinfo{end-6};
SubjectID = fileinfo{end-5};
SessionID = fileinfo{end-4};
TaskID = fileinfo{end-3};
StimSite = fileinfo{end-2};
CurrentID = fileinfo{end-1};
OUTPATH = sprintf('/projects/b1134/processed/eegproc/%s/%s/%s/%s/%s/%s',...
    ProjectID, SubjectID, SessionID, TaskID, StimSite, CurrentID);

if ~exist(sprintf('%s/downsampled_data_uV.mat', OUTPATH), 'file')
    fprintf('Downsampling Raw Data files from %s.\n', INPATH)
    if ~exist(OUTPATH, 'dir')
        mkdir(OUTPATH)
    end          
    load_dataCSC(INPATH,OUTPATH)
    load(sprintf('%s/downsampled_data_uV.mat', OUTPATH)) 
else
    fprintf('Loading pre-existing file %s/downsampled_data_uV.mat\n', OUTPATH)
    load(sprintf('%s/downsampled_data_uV.mat', OUTPATH)) 
end

if sum(isletter(SubjectID)) < length(SubjectID) %for Stanford Patients
    Events = Stims';
end

end