

if button_action==1
    outfile=get(h_edit9,'String');
    
    % Analysis setting
    sen=str2num(get(h_edit3,'String')); 
    channel=get(h_edit1,'Value'); 
    FFT_size=str2num(get(h_edit6,'String')); 
    overlap=0;
    reading_interval=str2num(get(h_edit4,'String')); 
    ltsa_resolution=str2num(get(h_edit5,'String')); 
    Frequency_range=[str2num(get(h_edit8,'String')) str2num(get(h_edit7,'String'))]; 
    if get(h_edit2,'Value')==1
        Recording_env='Wat';
    elseif get(h_edit2,'Value')==2
        Recording_env='Air';
    end

    % Time label
    time_info.time_label=1;
    time_info.year_label=[str2num(get(h_y1,'String')) str2num(get(h_y2,'String')) str2num(get(h_y_extra,'String'))];
    time_info.month_label=[str2num(get(h_m1,'String')) str2num(get(h_m2,'String'))];   
    time_info.day_label=[str2num(get(h_d1,'String')) str2num(get(h_d2,'String'))];
    time_info.hour_label=[str2num(get(h_H1,'String')) str2num(get(h_H2,'String'))];
    time_info.minute_label=[str2num(get(h_M1,'String')) str2num(get(h_M2,'String'))];
    time_info.second_label=[str2num(get(h_S1,'String')) str2num(get(h_S2,'String'))];
        
    [Result, Parameters]=ltsa_production(PATHNAME, sen, channel, time_info, FFT_size, overlap, reading_interval, ltsa_resolution, Frequency_range, Recording_env);
    save([outfile '.mat'], 'Result','Parameters');
    
    figure(2);
    subplot(3,1,1); imagesc(Result.LTS_median(:,1),Result.f/1000,Result.LTS_median(:,2:end)'); axis xy; 
    datetick('x','keepticks'); ylabel('Frequency (kHz)'); title('Median-based LTS');
    subplot(3,1,2); imagesc(Result.LTS_median(:,1),Result.f/1000,Result.LTS_mean(:,2:end)'); axis xy; 
    datetick('x','keepticks'); ylabel('Frequency (kHz)'); title('Mean-based LTS');
    subplot(3,1,3); imagesc(Result.LTS_median(:,1),Result.f/1000,Result.LTS_mean(:,2:end)'-Result.LTS_median(:,2:end)'); axis xy; 
    datetick('x','keepticks'); ylabel('Frequency (kHz)'); title('Difference-based LTS'); colormap('jet')
    
elseif button_action==2
    [LTS_file,LTS_PATH] = uigetfile('*.mat');
    cd(LTS_PATH); load(LTS_file); cd(PATHNAME_o);
    
    figure(2);
    subplot(3,1,1); imagesc(Result.LTS_median(:,1),Result.f/1000,Result.LTS_median(:,2:end)'); axis xy; 
    datetick('x','keepticks'); ylabel('Frequency (kHz)'); title('Median-based LTS');
    subplot(3,1,2); imagesc(Result.LTS_median(:,1),Result.f/1000,Result.LTS_mean(:,2:end)'); axis xy; 
    datetick('x','keepticks'); ylabel('Frequency (kHz)'); title('Mean-based LTS');
    subplot(3,1,3); imagesc(Result.LTS_median(:,1),Result.f/1000,Result.LTS_mean(:,2:end)'-Result.LTS_median(:,2:end)'); axis xy; 
    datetick('x','keepticks'); ylabel('Frequency (kHz)'); title('Difference-based LTS'); colormap('jet')
end