%% FamRecEEGpic_BehavAnalysis

%% GENERAL SET-UP
csvdir      = fullfile(curexperiment.datafolder_inputbehav, 'BehavData');
csvdf       = dir(csvdir);
csvfiles    = {csvdf.name};

display(sprintf('\nBEHAVIORAL ANALYSES\n'))

% get the phases of the experiment (because they partly determine filename)
for i=1:length(curexperiment.datasets_names)-1 % skip rest
    phases{i}     = curexperiment.datasets_names{i}(5:end); % phase names
end
clear i

% get the participant numbers
p=1;
for i=1:length(phases):length(csvfiles)
    if length(csvfiles{i})>2
        ppns{p} = csvfiles{i}(1:3);
        p=p+1;
    end
end
clear i
clear p

% to loop or not to loop
loop = true; % loop

%% LOOP OVER PARTICIPANTS OR NOT
curl = '';
% start loop or determine current ppn
if loop
    display('Loop true')
    strt = 1:length(ppns);
else
    display('Loop false')
    strt = f;
end
for p=strt
    cur_ppn = ppns{p};
    fprintf(curl);
    curtxt = sprintf('\nPARTICIPANT %d of %d',p,length(ppns));
    fprintf(curtxt)
    curl = repmat('\b',1,length(curtxt));
    % select files of this participant
    ppnfiles = csvfiles(logical(~cellfun('isempty',strfind(csvfiles,cur_ppn))));    
    for cur_phase=1:length(phases)
        % select the files for this memory phase
        phafile = ppnfiles(logical(~cellfun('isempty',strfind(ppnfiles,phases{cur_phase}))));
        
        %% LOAD FILE
        inputdir = fullfile(csvdir,phafile);
        fid = fopen(inputdir{:},'rt');
        if fid~=-1
            T = textscan(fid, curexperiment.behav.file_format{cur_phase}, 'Delimiter', ',', 'HeaderLines', 21); % skip practice
        else
            error('Cannot open %s\n',inputdir);
        end
        fclose(fid);
        clear inputdir
        clear fid
        
        %% GET THE VARIABLES
        for i=1:length(T)
            evalc(sprintf('ppn.%s = T{i};',curexperiment.behav.vars{cur_phase,i}));
        end
        clear T
        clear i
        clear memfiles
        
        %% RECODE VARIABLES
        % gender
        if ppn.gender{1} == 'f'
            ppn.gender = 1;
        elseif ppn.gender{1} == 'm'
            ppn.gender = 2;
        end
        % ppn
        ppn.ppn = ppn.ppn(1);
        % age
        ppn.age = ppn.age(1);
        % encoding response
        if cur_phase==1
            ppn.enc_resp(strcmp(ppn.enc_resp,'left'))={1}; % pleasant
            ppn.enc_resp(strcmp(ppn.enc_resp,'right'))={2}; % unpleasant
            ppn.enc_resp(strcmp(ppn.enc_resp,''))={9}; % no response
            ppn.enc_resp=cell2mat(ppn.enc_resp);
        end
        % retrieval
        if cur_phase==2
            ppn.ret_resp = ppn.on_resp;
            ppn.ret_RT = ppn.on_RT;
        end
        %% ANALYSES   
        % Encoding/Retrieval No Responses
        if cur_phase==1
            evalc(sprintf('ppn.%s_noresp = sum(ppn.%s_RT(:)==0)',phases{cur_phase}(2:end),phases{cur_phase}(2:end)));
        elseif cur_phase==2
            evalc(sprintf('ppn.%s_noresp = numel(find(ppn.conf_rating==99))',phases{cur_phase}(2:end)));
        end

        % Encoding/Retrieval RTs
        evalc(sprintf('ppn.%s_meanRT = mean(nonzeros(ppn.%s_RT))',phases{cur_phase}(2:end),phases{cur_phase}(2:end)));
        
        if cur_phase==1
            % 1 = pleasant, 2 = unpleasant
            ppn.enc_resp_pos = sum(ppn.enc_resp==1);
            ppn.enc_resp_neg = sum(ppn.enc_resp==2);
        elseif cur_phase==2       
            % Retrieval counts (6 levels of confidence & 4 memory score groups)
            ppn.count_vso = sum(logical(ppn.conf_rating == 13 & ppn.on_acc == 11)); % very conf hit
            ppn.count_bso = sum(logical(ppn.conf_rating == 12 & ppn.on_acc == 11)); % bit conf hit
            ppn.count_nso = sum(logical(ppn.conf_rating == 11 & ppn.on_acc == 11)); % not conf hit
            ppn.count_nsn = sum(logical(ppn.conf_rating == 21 & ppn.on_acc == 22)); % not conf cr
            ppn.count_bsn = sum(logical(ppn.conf_rating == 22 & ppn.on_acc == 22)); % bit conf cr
            ppn.count_vsn = sum(logical(ppn.conf_rating == 23 & ppn.on_acc == 22)); % very conf cr
            ppn.count_vsm = sum(logical(ppn.conf_rating == 23 & ppn.on_acc == 12)); % very conf miss
            ppn.count_bsm = sum(logical(ppn.conf_rating == 22 & ppn.on_acc == 12)); % bit conf miss
            ppn.count_nsm = sum(logical(ppn.conf_rating == 21 & ppn.on_acc == 12)); % not conf miss
            ppn.count_vsf = sum(logical(ppn.conf_rating == 13 & ppn.on_acc == 21)); % very conf fa
            ppn.count_bsf = sum(logical(ppn.conf_rating == 12 & ppn.on_acc == 21)); % bit conf fa
            ppn.count_nsf = sum(logical(ppn.conf_rating == 11 & ppn.on_acc == 21)); % not conf fa
              
            % d'
            ppn.hit_rate = length(ppn.on_acc(logical(ppn.on_acc==11)))/length(ppn.on_acc(logical(ppn.on_acc==11 | ppn.on_acc==12)));
            ppn.fa_rate = length(ppn.on_acc(logical(ppn.on_acc==21)))/length(ppn.on_acc(logical(ppn.on_acc==22 | ppn.on_acc==21)));
            ppn.cr_rate = length(ppn.on_acc(logical(ppn.on_acc==22)))/length(ppn.on_acc(logical(ppn.on_acc==22 | ppn.on_acc==21)));
            
            zhr = norminv(ppn.hit_rate);
            zfar = norminv(ppn.fa_rate);
            ppn.d_prime = zhr-zfar;
            clear zfar
            clear zhr

            ppn.hit_rate_vs = ppn.count_vso/(ppn.count_vso+ppn.count_vsm);
            ppn.fa_rate_vs = ppn.count_vsf/(ppn.count_vsn+ppn.count_vsf);
            if ppn.fa_rate_vs==0
                % Adjust only the extreme values by replacing rates of 0 with 0.5/n and rates of 1 with (n-0.5)/n 
                % where n is the number of signal or noise trials (Macmillan & Kaplan, 1985)
                ppn.fa_rate_vs=0.5/ppn.count_vsn;
            end
            ppn.d_prime_vs = norminv(ppn.hit_rate_vs)-norminv(ppn.fa_rate_vs);
            
            ppn.hit_rate_bs = ppn.count_bso/(ppn.count_bso+ppn.count_bsm);
            ppn.fa_rate_bs = ppn.count_bsf/(ppn.count_bsn+ppn.count_bsf);
            ppn.d_prime_bs = norminv(ppn.hit_rate_bs)-norminv(ppn.fa_rate_bs);
            
            ppn.hit_rate_ns = ppn.count_nso/(ppn.count_nso+ppn.count_nsm);
            ppn.fa_rate_ns = ppn.count_nsf/(ppn.count_nsn+ppn.count_nsf);
            ppn.d_prime_ns = norminv(ppn.hit_rate_ns)-norminv(ppn.fa_rate_ns);
            
            ppn.hit_rate_LC = (ppn.count_bso+ppn.count_nso)/(ppn.count_nso+ppn.count_nsm+ppn.count_bso+ppn.count_bsm);
            ppn.fa_rate_LC = (ppn.count_bsf+ppn.count_nsf)/(ppn.count_nsn+ppn.count_nsf+ppn.count_bsn+ppn.count_bsf);
            ppn.d_prime_LC = norminv(ppn.hit_rate_LC)-norminv(ppn.fa_rate_LC);       
            
            % new encoding subsequent memory response
            hitrp = 0;
            missrp = 0;
            hitrn = 0;
            missrn = 0;
            ppn.encDm=zeros(curexperiment.Ntrials_enc,1);
            % loop over ret trials
            for i=1:length(ppn.ret_pic)
                % loop over enc trials
                for e=1:length(ppn.enc_pic)
                    % find match between enc and ret trials
                    if strcmp(ppn.ret_pic{i},ppn.enc_pic{e})
                        % adjust to no response
                        if ppn.conf_rating(i)==99 || ppn.enc_resp(e)==9
                            ppn.encDm(e)=99;
                        % make Dm responses pleasant
                        elseif ppn.on_acc(i) == 11 && ppn.conf_rating(i) == 13 && ppn.enc_resp(e)==1
                            ppn.encDm(e)=131; % subs hitHC pleasant
                            hitrp=hitrp+1;
                        elseif ppn.on_acc(i) == 11 && (ppn.conf_rating(i) == 12 || ppn.conf_rating(i) == 11) && ppn.enc_resp(e)==1
                            ppn.encDm(e)=121; % subs hitLC pleasant
                            hitrp=hitrp+1;
                        elseif ppn.on_acc(i) == 12 && ppn.enc_resp(e)==1
                            ppn.encDm(e)=111; % subs miss pleasant
                            missrp=missrp+1;
                        % make Dm responses unpleasant
                        elseif ppn.on_acc(i) == 11 && ppn.conf_rating(i) == 13 && ppn.enc_resp(e)==2
                            ppn.encDm(e)=132; % subs hitHC unpleasant
                            hitrn=hitrn+1;
                        elseif ppn.on_acc(i) == 11 && (ppn.conf_rating(i) == 12 || ppn.conf_rating(i) == 11) && ppn.enc_resp(e)==2
                            ppn.encDm(e)=122; % subs hitLC unpleasant
                            hitrn=hitrn+1;
                        elseif ppn.on_acc(i) == 12 && ppn.enc_resp(e)==2
                            ppn.encDm(e)=112; % subs miss unpleasant
                            missrn=missrn+1;
                        end
                    end
                end
            end
            
            % Encoding counts
            ppn.count_SubsHitHC_pos = sum(logical(ppn.encDm == 131));
            ppn.count_SubsHitLC_pos = sum(logical(ppn.encDm == 121));
            ppn.count_SubsMiss_pos = sum(logical(ppn.encDm == 111));
            ppn.count_SubsHitHC_neg = sum(logical(ppn.encDm == 132));
            ppn.count_SubsHitLC_neg = sum(logical(ppn.encDm == 122));
            ppn.count_SubsMiss_neg = sum(logical(ppn.encDm == 112));
            
            % pleasantness & memory performance
            ppn.hit_rate_pleasant = hitrp/(hitrp+missrp);
            ppn.hit_rate_unpleasant = hitrn/(hitrn+missrn);
            
            clear hitrp hitrn missrp missrn
        end
    end
    clear cur_phase
    clear phafile

    ppn=rmfield(ppn,{'enc_pic','enc_resp','enc_RT','fix_time','encDm',...
    'ret_pic','on_class','on_resp','on_RT','on_acc',...
    'ret_resp','ret_RT','conf_resp','conf_RT','conf_rating'});
    curtable=struct2table(ppn);
    if ~loop
        display(sprintf('\n%d',ppn.ppn))
        curtable
    end
    
    if loop
        if p==1
            table_behav = curtable;
        else
            table_behav = [table_behav;curtable];
        end
    else
        table_behav = curtable;
        subjectdata.behavdata=ppn
    end
    clear ppn
    clear cur_ppn
    clear ppnfiles
    clear curtable rocData
end
clear csv*
clear phases
clear p i
clear curl
clear ppns
if exist(outputfile,'file')
   load(outputfile)
end
if loop
    Data.BehavRes= table_behav;
else
    Data.BehavRes(f,:)= table_behav;
end
clear table_behav
clear targf luref nBins nConds fitStat model ParNames x0 LB UB subID groupID
clear condLabels modelID outpath roc_solver
save(outputfile,'Data')