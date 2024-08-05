% Creates bipolar referencing scheme using information from
% monopolar_channel_IDs variable. You can optionally include epoched data
% as a fourth argument and it will return rereferenced data as well as the
% referencing scheme. Currently is set up to only work with stim
% directories
%
function [bipolar_data, bipolar_channel_IDs] = bipolar_reref(monopolar_channel_IDs, SubjectID, varargin)
%%
%convert some strings to numbers for math purposes
monopolar_channel_IDs(:,3:4) = num2cell(str2double(monopolar_channel_IDs(:,3:4)));

% If its a grid patient
if sum(cell2mat(monopolar_channel_IDs(:,4))) > height(monopolar_channel_IDs)
    bipolar_Lnames = split(readcell(sprintf('/projects/b1134/processed/fs/%s/%s/elec_recon/%s_bipolarelectrodeNames.txt',...
        SubjectID, SubjectID, SubjectID)), '-');
    %remove duplicates from this file that are used only as stim sites
    duplicate_indices = false(height(bipolar_Lnames),1);
    for i = 1:height(bipolar_Lnames)
        index = find(matches(bipolar_Lnames(:,1), bipolar_Lnames(i,1)));
        if length(index) > 1
            duplicate_indices(index(2:end)) = true;
        end
        index = find(matches(bipolar_Lnames(:,2), bipolar_Lnames(i,2)));
        if length(index) > 1
            duplicate_indices(index(2:end)) = true;
        end
    end
    bipolar_Lnames(duplicate_indices,:) = [];
end
%%
% create bipolar montage
if length(varargin) == 1
    monopolar_data = varargin{1};
    bipolar_data = zeros(size(monopolar_data)); %channel x time x trial
else
    monopolar_data = zeros(height(monopolar_channel_IDs),1,1); %fake data
    bipolar_data = zeros(size(monopolar_data));
end
%%
bipolar_channel_IDs = cell(length(monopolar_channel_IDs),4);    
i = 1;
while i <= height(monopolar_channel_IDs)
    if monopolar_channel_IDs{i,4} == 1 %depth electrode
       for j = i:i+monopolar_channel_IDs{i,3}-2
            bipolar_data(j,:,:) = monopolar_data(j,:,:) - monopolar_data(j+1,:,:);
            bipolar_channel_IDs{j,1} = sprintf('%s-%s', monopolar_channel_IDs{j,1},...
                monopolar_channel_IDs{j+1,1});
            bipolar_channel_IDs{j,2} = monopolar_channel_IDs{j,2};
            bipolar_channel_IDs{j,3} = num2str(monopolar_channel_IDs{j,3} - 1);
            bipolar_channel_IDs{j,4} = num2str(monopolar_channel_IDs{j,4});
       end
       i = j + 2;
    else %grid electrode
        index = matches(bipolar_Lnames(:,1), monopolar_channel_IDs{i,1});
        if sum(index) > 0 %if this monopolar contact is the first contact in a bipolar pair
            %find the names and indices of both contacts
            contact1 = matches(monopolar_channel_IDs(:,1), bipolar_Lnames{index,1});
            contact2 = matches(monopolar_channel_IDs(:,1), bipolar_Lnames{index,2});
            %do the reref
            bipolar_data(i,:,:) = monopolar_data(contact1,:,:) - monopolar_data(contact2,:,:);
            bipolar_channel_IDs{i,1} = sprintf('%s-%s', monopolar_channel_IDs{contact1,1},...
                monopolar_channel_IDs{contact2,1});
            %update contact info
            bipolar_channel_IDs{i,2} = monopolar_channel_IDs{contact1,2};
            if abs(str2double(bipolar_Lnames{index,1}(isstrprop(bipolar_Lnames{index,1}, 'digit'))) - ...
                    str2double(bipolar_Lnames{index,2}(isstrprop(bipolar_Lnames{index,2}, 'digit')))) %for grids referenced along rids
                bipolar_channel_IDs{i,3} = num2str(monopolar_channel_IDs{i,3} - 1);
                bipolar_channel_IDs{i,4} = num2str(monopolar_channel_IDs{i,4});      
            else
                bipolar_channel_IDs{i,3} = num2str(monopolar_channel_IDs{i,3}); %for grids rereferenced along columns
                bipolar_channel_IDs{i,4} = num2str(monopolar_channel_IDs{i,4} - 1);   
            end
        end
        i = i + 1;
    end
end
   %%
%remove empty rows
empty_indices = cellfun(@isempty, bipolar_channel_IDs(:,1));
bipolar_channel_IDs(empty_indices, :) = [];
bipolar_data(empty_indices,:,:) = [];
end