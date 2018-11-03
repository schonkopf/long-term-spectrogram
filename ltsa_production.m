function [Result, Parameters]=ltsa_production(PATHNAME, sen, channel, time_info, FFT_size, overlap, reading_interval, ltsa_resolution, Frequency_range, Recording_env) 

file=dir(fullfile(PATHNAME, '*.wav'));

Result_median=[]; Result_SPL_median=[]; Result_mean=[]; Result_SPL_mean=[];
h=waitbar(0,'Please wait for the analysis...');
for file_no=1:size(file,1)
    waitbar(file_no/size(file,1),h,['Processing ' num2str(file_no) ' / ' num2str(size(file,1)) '. please wait...']);
    infile = file(file_no).name;
    sound_info=audioinfo([PATHNAME '\' infile]);
    siz=sound_info.TotalSamples;
    sf =sound_info.SampleRate;
    
    % retrieve the time of recording
    if isempty(time_info.time_label)==1
       file(file_no).datenum=file(file_no).datenum-siz/sf/(24*3600);
    else
       SS = str2num(infile(time_info.second_label(1):time_info.second_label(2))); % second
       MM = str2num(infile(time_info.minute_label(1):time_info.minute_label(2))); % minute
       HH = str2num(infile(time_info.hour_label(1):time_info.hour_label(2))); % hour
       dd = str2num(infile(time_info.day_label(1):time_info.day_label(2))); % day
       mm = str2num(infile(time_info.month_label(1):time_info.month_label(2))); % month
       if length(time_info.year_label)==2
           yy = str2num([infile(time_info.year_label(1):time_info.year_label(2))]); % year
       else
           yy = str2num([num2str(time_info.year_label(3)) infile(time_info.year_label(1):time_info.year_label(2))]); % year
       end
       
       file(file_no).datenum=datenum([yy mm dd HH MM SS]);
    end
    
    for n=1:ceil(siz(1)/(sf*reading_interval))
        temp_median=[]; temp_mean=[]; temp_spl_median=[]; temp_spl_mean=[];
        matrix_duration=[floor((n-1)*sf*reading_interval)+1 ceil(n*sf*reading_interval)];
        if matrix_duration(2)>siz
            matrix_duration(2)=siz;
        end
        
        if diff(matrix_duration)>0.1*sf*ltsa_resolution
            data=audioread([PATHNAME '\' infile], matrix_duration);
            
            data=data(:,channel);
            if reading_interval>ltsa_resolution
                left=rem(length(data),round(ltsa_resolution*sf));
                data=reshape(data(1:end-left),round(ltsa_resolution*sf),[]);
            end

            % measuring the acoustic features based on the PAMGuide
            % Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology and Evolution
            for m=1:size(data,2)
                [A2,f] = sound_characterization(data(:,m),sf,sen,FFT_size,overlap,'Hamming',Recording_env,min(Frequency_range),max(Frequency_range),'PSD',0,0,1);
                SIGNAL=log10(median(10.^(A2(2:end,2:end)),1));
                SIGNAL_mean=log10(mean(10.^(A2(2:end,2:end)),1));
                [SPL]=sound_characterization(data(:,m),sf,sen,FFT_size,overlap,'Hamming',Recording_env,min(Frequency_range),max(Frequency_range),'Broadband',0,0,1);
                SPL_rms=log10(median(10.^(SPL(2:end,2))));
                SPL_rms_mean=log10(mean(10.^(SPL(2:end,2))));
                
                temp_median(m,:)=[file(file_no).datenum+(reading_interval*(n-1)+ltsa_resolution*(m-1))/(24*3600) SIGNAL];
                temp_mean(m,:)=[file(file_no).datenum+(reading_interval*(n-1)+ltsa_resolution*(m-1))/(24*3600) SIGNAL_mean];
                temp_spl_median(m,:)=[file(file_no).datenum+(reading_interval*(n-1)+ltsa_resolution*(m-1))/(24*3600) SPL_rms]; 
                temp_spl_mean(m,:)=[file(file_no).datenum+(reading_interval*(n-1)+ltsa_resolution*(m-1))/(24*3600) SPL_rms_mean];
            end
            Result_median=[Result_median; temp_median];
            Result_mean=[Result_mean; temp_mean];
            Result_SPL_median=[Result_SPL_median; temp_spl_median];
            Result_SPL_mean=[Result_SPL_mean; temp_spl_mean];
        end
    end
end

Result.SPL_median=Result_SPL_median; Result.SPL_mean=Result_SPL_mean; Result.LTS_median=Result_median; Result.LTS_mean=Result_mean; Result.f=f;
Parameters.FFT_size=FFT_size; Parameters.overlap=overlap; Parameters.sensitivity=sen; Parameters.sampling_freq=sf; Parameters.channel=channel;
close(h)