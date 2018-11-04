
if button_action==0
    try
    [File,PATHNAME] = uigetfile('*.wav');
    catch
    end
    
    if PATHNAME~=0
        if strcmp(Recording_device,'SM')==1
            temp=strfind(File,'_20'); temp=temp(1);
            label_pos=[1 4; 5 6; 7 8; 10 11; 12 13; 14 15]+temp;
            extra_label=[];
        elseif strcmp(Recording_device,'Soundtrap')==1
            temp=strfind(File,'.'); temp=temp(1);
            label_pos=[1 2; 3 4; 5 6; 7 8; 9 10; 11 12]+temp;
            extra_label=[20];
        else
            label_pos=zeros(6,2);
            extra_label=[];
        end
    else 
        label_pos=zeros(6,2);
        extra_label=[];
    end
    
    hlabel=uicontrol('Style','text','String',File,'FontSize',15,'FontWeight','bold','FontName','FixedWidth','Position',[350 400 400 30],'HorizontalAlignment','left'); 
    reference=[]; for n=1:length(File); temp=num2str(100+n); reference=[reference temp(end)]; end
    hlabel=uicontrol('Style','text','String',[reference],'FontSize',15,'FontName','FixedWidth','Position',[350 370 400 30],'HorizontalAlignment','left'); 
    
    h_y1=uicontrol('Style','edit','String', label_pos(1,1),'FontSize',11,'Position',[500 350 50 20]);
    h_y2=uicontrol('Style','edit','String', label_pos(1,2),'FontSize',11,'Position',[570 350 50 20]);
    h_m1=uicontrol('Style','edit','String', label_pos(2,1),'FontSize',11,'Position',[500 310 50 20]);
    h_m2=uicontrol('Style','edit','String', label_pos(2,2),'FontSize',11,'Position',[570 310 50 20]);
    h_d1=uicontrol('Style','edit','String', label_pos(3,1),'FontSize',11,'Position',[500 270 50 20]);
    h_d2=uicontrol('Style','edit','String', label_pos(3,2),'FontSize',11,'Position',[570 270 50 20]);
    h_H1=uicontrol('Style','edit','String', label_pos(4,1),'FontSize',11,'Position',[500 230 50 20]);
    h_H2=uicontrol('Style','edit','String', label_pos(4,2),'FontSize',11,'Position',[570 230 50 20]);
    h_M1=uicontrol('Style','edit','String', label_pos(5,1),'FontSize',11,'Position',[500 190 50 20]);
    h_M2=uicontrol('Style','edit','String', label_pos(5,2),'FontSize',11,'Position',[570 190 50 20]);
    h_S1=uicontrol('Style','edit','String', label_pos(6,1),'FontSize',11,'Position',[500 150 50 20]);
    h_S2=uicontrol('Style','edit','String', label_pos(6,2),'FontSize',11,'Position',[570 150 50 20]);
    h_y_extra=uicontrol('Style','edit','String', extra_label,'FontSize',11,'Position',[650 110 50 20]);

elseif button_action==0.5
    try
        [parameter_file,parameter_path] = uigetfile('*.mat');
    catch
    end
    cd(parameter_path); load(parameter_file); cd(PATHNAME_o);
    if strcmp(Recording_env,'Wat')==1
        env_control=1;
    elseif strcmp(Recording_env,'Air')==1
        env_control=2;
    end
    h_edit1=uicontrol('Style','popupmenu','String', '1|2','Value',channel,'FontSize',10,'Position',[225 385 100 30]);
    h_edit2=uicontrol('Style','popupmenu','String', 'Wat|Air','Value',env_control,'FontSize',10,'Position',[225 345 100 30]);
    h_edit3=uicontrol('Style','edit','String', sen,'FontSize',12,'Position',[225 305 100 30]);
    h_edit4=uicontrol('Style','edit','String', reading_interval,'FontSize',12,'Position',[225 265 100 30]);
    h_edit5=uicontrol('Style','edit','String', ltsa_resolution,'FontSize',12,'Position',[225 225 100 30]);
    h_edit6=uicontrol('Style','edit','String', FFT_size,'FontSize',12,'Position',[225 185 100 30]);
    h_edit7=uicontrol('Style','edit','String', max(Frequency_range),'FontSize',12,'Position',[225 145 100 30]);
    h_edit8=uicontrol('Style','edit','String', min(Frequency_range),'FontSize',12,'Position',[225 105 100 30]);
    h_edit9=uicontrol('Style','edit','String', outfile,'FontSize',12,'Position',[225 65 200 30]);
    
elseif button_action==1
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