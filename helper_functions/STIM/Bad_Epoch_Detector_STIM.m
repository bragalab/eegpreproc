function bad_epochs = Bad_Epoch_Detector_STIM(epoch_data, channel_IDs, window, threshold)
    global accept_reject
    global go_back
    global skip
%automatically detect artifactual epochs
    bad_epochs = zeros(size(epoch_data,1), size(epoch_data,3)); %channel x trial
    artifactwindow = [window(1):-10 10:window(end)];%ignore stim artifact area when detecting bad epochs
    for i = 1:size(epoch_data,1) %for each channel 
        for j = 1:size(epoch_data,3) %for each trial
            if max(abs(epoch_data(i, artifactwindow - window(1) + 1, j))) > threshold %mark trials with large values
                bad_epochs(i,j) = 1;
            end          
        end
    end
    %manually go through each epoch that was detected, accept/reject
    for i = 1:height(bad_epochs) %for each channel
        badtrials = find(bad_epochs(i,:));
        if ~isempty(badtrials)
            j = 1;
            skip = [];
            while j <= length(badtrials) %check each bad epoch
                fig = figure;
                fig.Units = 'inches';
                fig.Position = [4.5 1 8 5];
                fig.AutoResizeChildren = 'off';
                ax1 = subplot(1,2,1, 'parent', fig);
                hold(ax1, 'on')
                yline(ax1, threshold, 'r')
                yline(ax1, -threshold, 'r')
                xlabel(ax1, 'Time (ms)')
                ylabel(ax1, 'Amplitude (\muV')              
                ax2 = subplot(1,2,2,'parent', fig);
                xlabel(ax2, 'Time (ms)')
                ylabel(ax2, 'Amplitude (\muV')
                sgtitle(fig, ' ')
                if sum(~bad_epochs(i,:)) > 0 %only plot this if theres some good trials
                    plot(ax2, window, squeeze(epoch_data(i, :, ~bad_epochs(i,:))))
                end    
                title(ax2, sprintf('Good Trials, Channel %s', channel_IDs{i,1}))
                ylim(ax2, [-1000 1000])
                plot(ax1, window, epoch_data(i, :, badtrials(j)))
                title(ax1, sprintf('Bad Trial: Channel %s, Trial %i', channel_IDs{i,1}, badtrials(j)))
                ylim(ax1, [-1000 1000]) 
                xlim(ax1, [window(1) window(end)])
                accept_reject = [];
                go_back = [];
                back = uicontrol('parent', fig, 'style', 'pushbutton', ...
                    'Position', [240 590 100 22], 'string',...               % press back to go to previous bad trial
                    'BACK', 'callback', @Go_Back);
                reject = uicontrol('parent', fig, 'style', 'pushbutton', ...% press reject to confirm this as a bad trial
                    'Position', [475 590 100 22], 'string',...
                    'REJECT', 'callback', {@Push_Button, 1});                
                accept = uicontrol('parent', fig, 'style', 'pushbutton', ...% press accept to no longer consider this a bad trial
                    'Position', [700 590 100 22], 'string',...
                    'ACCEPT', 'callback', {@Push_Button, 0});
                skip_channel = uicontrol('parent', fig, 'style', 'pushbutton', ...% press skip to mark all trials for this channel as good and move on
                    'Position', [475 15 100 22], 'string',...
                    'SKIP', 'callback', {@Skip});
                waitfor(fig)
                 %check Accept and Reject Buttons
                if ~isempty(accept_reject)
                    bad_epochs(i, badtrials(j)) = accept_reject; %update matrix of bad trials
                end
                %check Back button
                if isempty(go_back) % go to next or previous trial, depending on button pressed
                    j = j + 1;
                else
                    j = j - 1;
                end
                if j == 0 % cannot go back further than first trial
                    j = 1;
                end
                %check Skip button
                if ~isempty(skip)
                    bad_epochs(i, :) = 0; %update matrix of bad trials
                    j = length(badtrials)+1;
                end
            end
        end
    end
    function Push_Button(~, ~, decision)
        accept_reject = decision;
        closereq()
    end 
    function Go_Back(~, ~)
        go_back = 1;
        closereq()
    end       
    function Skip(~, ~)
        skip = 1;
        closereq()
    end   
end           
                