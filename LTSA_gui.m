% This program can help to automatic detect tonal sounds. Users can change
% the default settings of each parameter in this m file. Please make sure
% the special_filter_load.m is existed in the same folder.
% Please contact Tzu-Hao (Harry) Lin for any question: schonkopf@gmail.com
clear; clc;
try
    [File,PATHNAME] = uigetfile('*.wav');
catch
end

PATHNAME_o=cd;
outfile = ['Input file name']; % name of output file
if exist('parameters.mat')==0
    sen = 0;         % microphone/hydrophone sensitivity
    FFT_size=1024; % window size (samples)
    reading_interval=300; % time interval of data reading (second)
    ltsa_resolution=10; % time resolution of long-term spectrogram (second)
    Frequency_range=[100 90000]; % frequency range of long-term spectrogram (Hz)
    Recording_env='Wat';
    Recording_device='Soundtrap';
else
    load([PATHNAME_o '\parameters.mat']);
end

if strcmp(Recording_env,'Wat')==1
    env_control=1;
elseif strcmp(Recording_env,'Air')==1
    env_control=2;
end

if PATHNAME~=0
    if strcmp(Recording_device,'SM4')==1
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

% initiate the GUI
h1=figure('Position',[150 150 800 450],'Menubar','none');
hlabel=uicontrol('Style','text','String','Recording channel:','FontSize',11,'Position',[25 380 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Recording environment:','FontSize',11,'Position',[25 340 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Recording sensitivity:','FontSize',11,'Position',[25 300 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Reading interval (sec):','FontSize',11,'Position',[25 260 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Time resolution (sec):','FontSize',11,'Position',[25 220 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','FFT size (samples):','FontSize',11,'Position',[25 180 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Upper frequency limit (Hz):','FontSize',11,'Position',[25 140 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Lower frequency limit (Hz):','FontSize',11,'Position',[25 100 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Output file name:','FontSize',11,'Position',[25 60 200 30],'HorizontalAlignment','left');

h_edit1=uicontrol('Style','popupmenu','String', '1|2','FontSize',10,'Position',[225 385 100 30]);
h_edit2=uicontrol('Style','popupmenu','String', 'Wat|Air','Value',env_control,'FontSize',10,'Position',[225 345 100 30]);
h_edit3=uicontrol('Style','edit','String', sen,'FontSize',12,'Position',[225 305 100 30]);
h_edit4=uicontrol('Style','edit','String', reading_interval,'FontSize',12,'Position',[225 265 100 30]);
h_edit5=uicontrol('Style','edit','String', ltsa_resolution,'FontSize',12,'Position',[225 225 100 30]);
h_edit6=uicontrol('Style','edit','String', FFT_size,'FontSize',12,'Position',[225 185 100 30]);
h_edit7=uicontrol('Style','edit','String', max(Frequency_range),'FontSize',12,'Position',[225 145 100 30]);
h_edit8=uicontrol('Style','edit','String', min(Frequency_range),'FontSize',12,'Position',[225 105 100 30]);
h_edit9=uicontrol('Style','edit','String', outfile,'FontSize',12,'Position',[225 65 200 30]);

hbutton1=uicontrol('Style','pushbutton','Position',[480 50 140 40],'String','Run analysis','FontSize',12,'Callback','button_action=1; gui_action;');
hbutton2=uicontrol('Style','pushbutton','Position',[640 50 140 40],'String','View LTS','FontSize',12,'Callback','button_action=2; gui_action;');

hlabel=uicontrol('Style','text','String',File,'FontSize',15,'FontWeight','bold','FontName','FixedWidth','Position',[350 395 400 30],'HorizontalAlignment','left'); 
reference=[]; for n=1:length(File); temp=num2str(100+n); temp(1)=[]; if n<9; temp=[temp(end) '    ']; elseif n==9; temp=[temp(end) '   ']; else; temp=[temp(end-1:end) '  ']; end; reference=[reference temp]; end
hlabel=uicontrol('Style','text','String',['  ' reference],'FontSize',5,'Position',[350 365 400 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Year','FontSize',11,'Position',[400 340 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Month','FontSize',11,'Position',[400 300 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Day','FontSize',11,'Position',[400 260 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Hour','FontSize',11,'Position',[400 220 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Minute','FontSize',11,'Position',[400 180 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Second','FontSize',11,'Position',[400 140 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Extra labels before input year','FontSize',11,'Position',[400 100 200 30],'HorizontalAlignment','left'); 

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