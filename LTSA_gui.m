% This program can help to automatic detect tonal sounds. Users can change
% the default settings of each parameter in this m file. Please make sure
% the special_filter_load.m is existed in the same folder.
% Please contact Tzu-Hao (Harry) Lin for any question: schonkopf@gmail.com
clear; clc;
PATHNAME_o=cd;
outfile = ['Input file name']; % name of output file
parameters;

if strcmp(Recording_env,'Wat')==1
    env_control=1;
elseif strcmp(Recording_env,'Air')==1
    env_control=2;
end

% initiate the GUI
h1=figure('Position',[150 150 800 450],'Menubar','none');
% Menubar
m_env = uimenu(h1,'Label','Load recording parameters', 'Callback','button_action=0.5; gui_action;');
m_load = uimenu(h1,'Label','Recording folder', 'Callback','button_action=0; gui_action;');

hlabel=uicontrol('Style','text','String','Recording channel:','FontSize',11,'Position',[25 380 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Recording environment:','FontSize',11,'Position',[25 340 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Recording sensitivity:','FontSize',11,'Position',[25 300 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Reading interval (sec):','FontSize',11,'Position',[25 260 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Time resolution (sec):','FontSize',11,'Position',[25 220 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','FFT size (samples):','FontSize',11,'Position',[25 180 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Upper frequency limit (Hz):','FontSize',11,'Position',[25 140 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Lower frequency limit (Hz):','FontSize',11,'Position',[25 100 200 30],'HorizontalAlignment','left');
hlabel=uicontrol('Style','text','String','Output file name:','FontSize',11,'Position',[25 60 200 30],'HorizontalAlignment','left');

h_edit1=uicontrol('Style','popupmenu','String', '1|2','Value',channel,'FontSize',10,'Position',[225 385 100 30]);
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

hlabel=uicontrol('Style','text','String','Year','FontSize',11,'Position',[400 340 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Month','FontSize',11,'Position',[400 300 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Day','FontSize',11,'Position',[400 260 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Hour','FontSize',11,'Position',[400 220 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Minute','FontSize',11,'Position',[400 180 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Second','FontSize',11,'Position',[400 140 200 30],'HorizontalAlignment','left'); 
hlabel=uicontrol('Style','text','String','Extra labels before input year','FontSize',11,'Position',[400 100 200 30],'HorizontalAlignment','left'); 