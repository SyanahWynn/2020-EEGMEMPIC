%% FamRecEEGpic ALTER MARKERS
% Checks whether enc_start, enc_stop, ret_start and ret_Stop markers are in
% the data. When this is not the case it adds them to it. Also it makes
% another column which contains the original markers.

% add a column for the original EEG markers
tmp=cell(size(data_markers.event)); [data_markers.event(:).original_marker] =deal(tmp{:});
clear tmp
i=1;
while i < length(data_markers.event)+1
   % exclude all non-marker rows
   if isequal(cellstr(data_markers.event(i).type),cellstr(curexperiment.eventtype)) == 0
      % delete non-marker row
       data_markers.event(i) = [];
   else
       % add a column with the original markers
        data_markers.event(i).original_marker = data_markers.event(i).value - curexperiment.marker_offset;
       % go to the next row
        i = i +1;         
   end
end
clear i

% count all markers
curexperiment.original_markers.cur_count(1)=0;
for i=2:length(data_markers.event) %skip the first row    
    % count the values
    curexperiment.original_markers.cur_count(logical(data_markers.event(i).original_marker == cell2mat(curexperiment.original_markers.original_marker))) = ...
        curexperiment.original_markers.cur_count(logical(data_markers.event(i).original_marker == cell2mat(curexperiment.original_markers.original_marker))) +1;
end
clear i

count_error = {};
c=1;
% check if all markers are there
for i=1:size(curexperiment.original_markers,1)
    % check if there is a predefined count value
    if ~isempty(curexperiment.original_markers.count_without_practice{i})
        % check whether the predefined count value matches the actual countin this participant
        if ~logical(curexperiment.original_markers.count_without_practice{i} == curexperiment.original_markers.cur_count(i))
            fprintf(2,[sprintf('ERROR count %s', curexperiment.original_markers.Properties.RowNames{i}) char(10)]);
            count_error{c} = curexperiment.original_markers.Properties.RowNames{i};
            c = c+1;
        end
    end
end
clear c

% If not all markers are there, correct for this if necessary & possible
if ~isempty(count_error)
    if any(strcmp(count_error,'Start Encoding'))
        StimEncMarker = cell2mat(table2array(curexperiment.original_markers('Stimulus Onset','original_marker')));
        StartEncMarker = cell2mat(table2array(curexperiment.original_markers('Start Encoding','original_marker')));
        for i=1:length(data_markers.event) 
            % determine the first stimulus onset
            if data_markers.event(i).original_marker == StimOnsetMarkerEnc.original_marker
                % add an arteficial start encoding marker before the first stimulus
                data_markers.event(i-1).original_marker = StartEncMarker;
                break
            end
        end
        clear StimEncMarker
        clear StartEncMarker
        clear i
        display(sprintf('\nERROR Start Encoding Solved\n'))
    end
    if any(strcmp(count_error,'Start Retrieval'))
        StimRetMarker = [cell2mat(table2array(curexperiment.original_markers('Stimulus Onset Old','original_marker')))...
            cell2mat(table2array(curexperiment.original_markers('Stimulus Onset New','original_marker')))];
        StartRetMarker = cell2mat(table2array(curexperiment.original_markers('Start Retrieval','original_marker')));
        for i=1:length(data_markers.event) 
            % determine the first stimulus onset
            if ismember(data_markers.event(i).original_marker, StimRetMarker)
                % add an arteficial start encoding marker before the first stimulus
                data_markers.event(i-1).original_marker = StartRetMarker;
                break
            end
        end
        clear StimRetMarker
        clear StartRetMarker
        clear i
        display(sprintf('\nERROR Start Ret Solved\n'))
    end
    if any(strcmp(count_error,'Start Practice Trial'))
        if cell2mat(table2array(curexperiment.original_markers('Start Practice Trial','count_without_practice')))...
                < table2array(curexperiment.original_markers('Start Practice Trial','cur_count'))
            StartPracMarker = cell2mat(table2array(curexperiment.original_markers('Start Practice Trial','original_marker')));
            for i=1:length(data_markers.event) 
                % determine the first practice marker
                if ismember(data_markers.event(i).original_marker, StartPracMarker)
                    % remove marker
                    data_markers.event(i).original_marker = 0;
                    break
                end
            end
            clear StartPracMarker
            display(sprintf('\nERROR Start Practice Trial Solved\n')) % Started Encoding Practice twice
        end
    end
    if any(strcmp(count_error,'End Encoding'))
        if cell2mat(table2array(curexperiment.original_markers('End Encoding','count_without_practice')))...
                < table2array(curexperiment.original_markers('End Encoding','cur_count'))
            EndEncMarker = cell2mat(table2array(curexperiment.original_markers('End Encoding','original_marker')));
            for i=1:length(data_markers.event) 
                % determine the first end encoding marker
                if ismember(data_markers.event(i).original_marker, EndEncMarker)
                    % remove marker
                    data_markers.event(i).original_marker = 0;
                    break
                end
            end
            clear EndEncMarker
            display(sprintf('\nERROR End Encoding Solved\n')) % Started Encoding and aborted in practice
        end        
    end
    if any(strcmp(count_error,'Eyes Closed AftRet')) && any(strcmp(count_error,'Eyes Open AftRet'))
        % change PostRetRestEEG trigger
        PostRetRestClosedMarker = cell2mat(table2array(curexperiment.original_markers('Eyes Closed AftRet','original_marker')));
        PostRetRestOpenMarker = cell2mat(table2array(curexperiment.original_markers('Eyes Open AftRet','original_marker')));
        for i=length(data_markers.event):-1:1
            if data_markers.event(i).original_marker==PostRetRestClosedMarker && data_markers.event(i-1).original_marker==PostRetRestClosedMarker
                data_markers.event(i-1).original_marker=PostRetRestOpenMarker;
                break
            end
        end
        clear PostRetRestClosedMarker
        clear PostRetRestOpenMarker
        display(sprintf('ERROR Eye AftRet Solved'))
    end
    if any(strcmp(count_error,'Eyes Closed AftEnc')) && any(strcmp(count_error,'Eyes Open AftEnc'))
        % change PostEncRestEEG trigger
        PostEncRestClosedMarker = cell2mat(table2array(curexperiment.original_markers('Eyes Closed AftEnc','original_marker')));
        PostEncRestOpenMarker = cell2mat(table2array(curexperiment.original_markers('Eyes Open AftEnc','original_marker')));
        for i=length(data_markers.event):-1:1
            if data_markers.event(i).original_marker==PostEncRestClosedMarker && data_markers.event(i-1).original_marker==PostEncRestClosedMarker
                data_markers.event(i-1).original_marker=PostEncRestOpenMarker;
                break
            end
        end
        clear PostEncRestClosedMarker
        clear PostEncRestOpenMarker
        display(sprintf('ERROR Eyes AftEnc Solved'))
    end
    clear i
elseif isempty(count_error)
    display(sprintf('All markers present'))
end
clear count_error    

%% BEHAVIORAL DATA
eval([curexperiment.name '_Analyses_Behav'])

%% ENCODING 

% Get the indexes of the events that correspond to encoding stimulus onsets
ind_event_enc = find(ismember(extractfield(data_markers.event,'original_marker'), cell2mat(table2array(curexperiment.original_markers('Stimulus Onset','original_marker')))));
if length(ind_event_enc) ~= cell2mat(table2array(curexperiment.original_markers('Stimulus Onset','count_without_practice')))
    error('Error Matching Encoding Trials and Events')
end  

% Loop through the encoding trials and find the corresponding retrieval trial
% to implement markers for subsequent memory performance.
ret_ind = zeros(length(subjectdata.behavdata.enc_pic),1);
for i=1:length(subjectdata.behavdata.enc_pic)
    % exclude no response trials in encoding
    if subjectdata.behavdata.enc_resp(i) ~= 9
        % find the index of the current ret pic that matches the enc pic
        ret_ind(i) = find(strcmp(subjectdata.behavdata.enc_pic{i}, subjectdata.behavdata.ret_pic));
        if length(ret_ind(i))>1 || ~strcmp(subjectdata.behavdata.ret_pic{ret_ind(i)},subjectdata.behavdata.enc_pic{i})
            error('Error Matching Encoding and Retrieval Trials')
        end
        % exclude no response trials in retrieval
        if subjectdata.behavdata.conf_rating(ret_ind(i)) == 99
            ret_ind(i)=0;
        end           
    end
end    
clear i

% loop through the encoding events to make the subsequent memory marker
for i=1:length(ind_event_enc)
    if ret_ind(i) ~= 0
%         for c=1:size(curexperiment.adjust_markers,1)
%             any(ismember(curexperiment.adjust_markers.original_conf{c},subjectdata.behavdata.conf_rating(ret_ind(i))))
        data_markers.event(ind_event_enc(i)).original_marker = curexperiment.adjust_markers.adjust_marker{logical(ismember(cell2mat(curexperiment.adjust_markers.original_conf(1:6)),subjectdata.behavdata.conf_rating(ret_ind(i))))};
        
    end
end
clear i

% count the encoding trial types
for i=1:size(curexperiment.adjust_markers,1)-6
    evalc(sprintf('BehavCount.Encoding.%s = sum((vertcat(data_markers.event(ind_event_enc).original_marker) == curexperiment.adjust_markers.adjust_marker{i}));',curexperiment.adjust_markers.Properties.RowNames{i}));
end

% show results in output
display(sprintf('\nTRIAL COUNT\n'))
display(BehavCount.Encoding)

clear ind_event_enc  
clear ret_ind

%% RETRIEVAL

% Get the indexes of the events that correspond to retrieval stimulus onsets
ind_event_ret = sort([find(ismember(extractfield(data_markers.event,'original_marker'), cell2mat(table2array(curexperiment.original_markers('Stimulus Onset Old','original_marker'))))) ...
    find(ismember(extractfield(data_markers.event,'original_marker'), cell2mat(table2array(curexperiment.original_markers('Stimulus Onset New','original_marker')))))]);
if length(ind_event_ret) ~= cell2mat(table2array(curexperiment.original_markers('Stimulus Onset Old','count_without_practice'))) + ...
        cell2mat(table2array(curexperiment.original_markers('Stimulus Onset New','count_without_practice')))
    error('Error Matching Retrieval Trials and Events')
end  

% loop through the retrieval events to make the memory marker
for i=1:length(ind_event_ret)
    % skip the no response trials
    if subjectdata.behavdata.conf_rating(i) ~= 99
        for c=6:size(curexperiment.adjust_markers,1)
            % check the trial type
            if any(ismember(curexperiment.adjust_markers.original_conf{c},subjectdata.behavdata.conf_rating(i))) &&...
                any(ismember(curexperiment.adjust_markers.original_acc{c},subjectdata.behavdata.on_acc(i)))
                data_markers.event(ind_event_ret(i)).original_marker = curexperiment.adjust_markers.adjust_marker{c};
            end
        end              
    end
end
clear i
clear c

% count the encoding trial types
for i=7:size(curexperiment.adjust_markers,1)
      evalc(sprintf('BehavCount.Retrieval.%s = sum((vertcat(data_markers.event(ind_event_ret).original_marker) == curexperiment.adjust_markers.adjust_marker{i}));',curexperiment.adjust_markers.Properties.RowNames{i}));
end

% show results in output
display(BehavCount.Retrieval)

clear ind_event_ret

%% WRAPPING UP
% replace the marker values with the original markers

A = num2cell(vertcat(data_markers.event.original_marker));
[data_markers.event.value] = A{:};
clear A

% remove the 'original_marker field'
data_markers.event = rmfield(data_markers.event,'original_marker');

% create an event file
event = data_markers.event;

% create a list of new marker values
new_markers = unique(extractfield(data_markers.event,'value'));
enc_stim_new = new_markers(ismember(new_markers, vertcat(curexperiment.adjust_markers.adjust_marker{1:6})));
ret_stim_new = new_markers(ismember(new_markers, vertcat(curexperiment.adjust_markers.adjust_marker{7:12})));
rest_stim_new = new_markers(ismember(new_markers, vertcat(curexperiment.original_markers.original_marker{3:8})));

% save the data with altered markers
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_RawData_AlterMarkers.mat'],'data_markers'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_AlterMarkers_Events.mat'],'event'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_EncAlterMarkers.mat'],'enc_stim_new'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_RetAlterMarkers.mat'],'ret_stim_new'); 
save([subjectdata.subjectdir filesep subjectdata.subjectnr '_Raw_RestAlterMarkers.mat'],'rest_stim_new');

clear new_markers
clear enc_stim_new
clear ret_stim_new
clear rest_stim_new
clear event

% save info on the preprocessing trials
if exist(outputfile,'file')
   load(outputfile)
end

Data.EEGEncRetCountpre.Encoding(f,:) = BehavCount.Encoding;
Data.EEGEncRetCountpre.Retrieval(f,:) = BehavCount.Retrieval;

save(outputfile,'Data')

clear BehavCount
curexperiment.original_markers.cur_count = [];
