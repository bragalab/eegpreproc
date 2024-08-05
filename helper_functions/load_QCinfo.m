function [bad_channels, bad_segments, power_spectrum_deviant_channels, out_channels, path_channels] = load_QCinfo(OUTPATH, interaction)

%run info
if contains(OUTPATH, 'STIM')
    fileinfo = split(OUTPATH, '/');
    ProjectID = fileinfo{end-5};
    SubjectID = fileinfo{end-4};
    SessionID = fileinfo{end-3};
    SUBPATH = sprintf('/projects/b1134/processed/eegproc/%s/%s/%s', ...
        ProjectID, SubjectID, SessionID);
else
    fileinfo = split(OUTPATH, '/');
    SubjectID = fileinfo{end-2};
    SessionID = fileinfo{end-1};
    SUBPATH = sprintf('/projects/b1134/processed/eegproc/BNI/%s/%s', SubjectID, SessionID);
end
fprintf('\n Looking for QC information for this run...\n\n')

%bad channels
if exist(sprintf('%s/Bad_Channels.txt', OUTPATH), 'file')
    if interaction == 1
        response = input('A file has been found with existing Bad Channels for this run, would you like to use these (y or n)?', 's');
    else
        response = 'y';%automatically use old file
    end
    if strcmp(response,'y')
        bad_channels = importdata(sprintf('%s/Bad_Channels.txt', OUTPATH));
        if isempty(bad_channels)
            bad_channels = cell(0,0);
        end   
        fprintf('Old Bad Channels have been loaded.\n')
    else
        response = input('Please enter new Bad Channels for this run, separated by commas (A1, A2, A3, A4)', 's');
        response = strrep(response, ' ',''); %remove spaces
        bad_channels = split(response,',');
        if sum(ismissing(bad_channels))
            bad_channels = cell(0,0);
        end  
        writecell(bad_channels, sprintf('%s/Bad_Channels.txt', OUTPATH))
        fprintf('New Bad Channels have been loaded and written to a txt file.\n')
    end    
else
    response = input('Please enter new Bad Channels for this run, separated by commas (A1, A2, A3, A4)', 's');
    response = strrep(response, ' ',''); %remove spaces
    bad_channels = split(response,',');
    if sum(ismissing(bad_channels))
        bad_channels = cell(0,0);
    end         
    writecell(bad_channels, sprintf('%s/Bad_Channels.txt', OUTPATH))
    fprintf('New Bad Channels have been loaded and written to a txt file.\n')
end  

%bad segments
if exist(sprintf('%s/Bad_Segments.txt', OUTPATH), 'file')
    if interaction == 1
        response = input('A file has been found with existing Bad Segments for this run, would you like to use these (y or n)?', 's');
    else
        response = 'y';%automatically use old file
    end   
    if strcmp(response,'y')
        bad_segments = importdata(sprintf('%s/Bad_Segments.txt', OUTPATH));
        if isempty(bad_segments)
            bad_segments = cell(0,0);
        end              
        fprintf('Old Bad Segments have been loaded.\n')
    else
        response = input('Please enter new Bad Segments (in seconds) for this run, separated by commas (0-15, 25-30, 110-120)', 's');
        response = strrep(response, ' ',''); %remove spaces
        bad_segments = split(response,',');
        if sum(ismissing(bad_segments)) 
            bad_segments = cell(0,0);
        end 
        writecell(bad_segments, sprintf('%s/Bad_Segments.txt', OUTPATH))
        fprintf('New Bad Segments have been loaded and written to a txt file.\n')
    end    
else
    response = input('Please enter new Bad Segments (in seconds) for this run, separated by commas (0-15, 25-30, 110-120)', 's');
    response = strrep(response, ' ',''); %remove spaces
    bad_segments = split(response,',');
    if sum(ismissing(bad_segments))
        bad_segments = cell(0,0);
    end         
    writecell(bad_segments, sprintf('%s/Bad_Segments.txt', OUTPATH))
    fprintf('New Bad Segments have been loaded and written to a txt file.\n')
end  

%power spectrum deviant channels
if exist(sprintf('%s/Power_Spectrum_Deviant_Channels.txt', OUTPATH), 'file')
    if interaction == 1
        response = input('A file has been found with existing Power Spectrum Deviant Channels for this run, would you like to use these (y or n)?', 's');
    else
        response = 'y'; %automatically use old file
    end
    if strcmp(response,'y')
        power_spectrum_deviant_channels = importdata(sprintf('%s/Power_Spectrum_Deviant_Channels.txt', OUTPATH));
        if isempty(power_spectrum_deviant_channels)
            power_spectrum_deviant_channels = cell(0,0);
        end    
        fprintf('Old Power Spectrum Deviant Channels have been loaded.\n')
    else
        response = input('Please enter new Power Spectrum Deviant Channels (in seconds) for this run, separated by commas (A1, A2, A3, A4)', 's');
        response = strrep(response, ' ',''); %remove spaces
        power_spectrum_deviant_channels = split(response,',');
        if sum(ismissing(power_spectrum_deviant_channels))
            power_spectrum_deviant_channels = cell(0,0);
        end    
        writecell(power_spectrum_deviant_channels, ...
            sprintf('%s/Power_Spectrum_Deviant_Channels.txt', OUTPATH))
        fprintf('New Power Spectrum Deviant Channels have been loaded and written to a txt file.\n')
    end    
else
    response = input('Please enter new Power Spectrum Deviant Channels for this run, separated by commas (A1, A2, A3, A4)', 's');
    response = strrep(response, ' ',''); %remove spaces
    power_spectrum_deviant_channels = split(response,',');
    if sum(ismissing(power_spectrum_deviant_channels))
        power_spectrum_deviant_channels = cell(0,0);
    end           
    writecell(power_spectrum_deviant_channels, ...
            sprintf('%s/Power_Spectrum_Deviant_Channels.txt', OUTPATH))
    fprintf('New Power Spectrum Deviant Channels have been loaded and written to a txt file.\n')
end  

%Out of Brain channels
if exist(sprintf('%s/Out_of_Brain_Channels.txt', SUBPATH), 'file')
    if interaction == 1
        response = input('A file has been found with existing Out of Brain Channels for this run, would you like to use these (y or n)?', 's');
    else
        response = 'y';%automatically use old file
    end
    if strcmp(response,'y')
        out_channels = importdata(sprintf('%s/Out_of_Brain_Channels.txt', SUBPATH));
        if isempty(out_channels)
            out_channels = cell(0,0);
        end                   
        fprintf('Old Out of Brain channels have been loaded.\n')
    else
        response = input('Please enter new Out of Brain channels for this run, separated by commas (A1, A2, A3, A4)', 's');
        response = strrep(response, ' ',''); %remove spaces
        out_channels = split(response,',');
        if sum(ismissing(out_channels))
            out_channels = cell(0,0);
        end              
        writecell(out_channels, ...
            sprintf('%s/Out_of_Brain_Channels.txt', SUBPATH))
        fprintf('New Out of Brain channels have been loaded and written to a txt file.\n')
    end    
else
    response = input('Please enter new Out of Brain channels for this run, separated by commas (A1, A2, A3, A4)', 's');
    response = strrep(response, ' ',''); %remove spaces
    out_channels = split(response,',');
    if sum(ismissing(out_channels))
        out_channels = cell(0,0);
    end        
    writecell(out_channels, ...
        sprintf('%s/Out_of_Brain_Channels.txt', SUBPATH))
    fprintf('New Out of Brain channels have been loaded and written to a txt file.\n')
end 

%Pathologic channels
if exist(sprintf('%s/Pathologic_Channels.txt', SUBPATH), 'file') 
    if interaction == 1
        response = input('A file has been found with existing Pathologic Channels for this run, would you like to use these (y or n)?', 's');
    else
        response = 'y'; %automatically use old file
    end
    if strcmp(response,'y')
        path_channels = importdata(sprintf('%s/Pathologic_Channels.txt', SUBPATH));
        if isempty(path_channels)
            path_channels = cell(0,0);
        end
        fprintf('Old Pathologic Channels have been loaded.\n')
    else
        response = input('Please enter new Pathologic Channels for this run, separated by commas (A1, A2, A3, A4)', 's');
        response = strrep(response, ' ',''); %remove spaces
        path_channels = split(response,',');
        if sum(ismissing(path_channels))
            path_channels = cell(0,0);
        end
        writecell(path_channels, ...
            sprintf('%s/Pathologic_Channels.txt', SUBPATH))
        fprintf('New Pathologic Channels have been loaded and written to a txt file.\n')
    end    
else
    response = input('Please enter new Pathologic Channels for this run, separated by commas (A1, A2, A3, A4)', 's');
    response = strrep(response, ' ',''); %remove spaces
    path_channels = split(response,',');
    if sum(ismissing(path_channels))
        path_channels = cell(0,0);
    end
    writecell(path_channels, ...
        sprintf('%s/Pathologic_Channels.txt', SUBPATH))
    fprintf('New Pathologic Channels have been loaded and written to a txt file.\n')
end
end    
