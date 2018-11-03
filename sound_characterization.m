% Performs DFT-based analysis (PSD,TOLf (fast 1/3-octave method),Broadband)
% for PAMGuide.m

% This code accompanies the manuscript: 

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright ?2014 The Authors.

% Author: Nathan D. Merchant. Last modified 22 Sep 2014

% xbit: wavread data
% Fs: sampling rate
% S = Sensitivity + Gain + 20*log10(1/vADC); vADC = sqrt(2); 
% N = Fs; 
% r = window overlap;
% winname: enter 'None', 'Hann', 'Hamming', 'Blackman'
% envi: enter 'Air', or 'Wat'
% lcut = Fs/N; 
% hcut = Fs/2;  
% atype: enter 'PSD', 'PowerSpec', 'Broadband', 'TOL'
% tstamp = datenum(y,m,d,H,M,S+MS); 
% disppar = 1;
% calib = 1;

% Example: 
% [data, Fs, bit]=wavread('ex.wav');
% Sen=-165; calib=1; window_length=512 (N); overlap=0.5; time_num=0;
% [A] = sound_wave(data,Fs,Sen,time_num,calib,1);
% [A,f]=sound_characterization(data,Fs,Sen,window_length,overlap,'Hamming','Wat',1,48000,'Broadband',time_num,1,calib);
% log_axis=1; plottype='Both'; File=[];
% PG_Viewer(A,plottype,File,log_axis);

function [A,f] = sound_characterization(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstamp,disppar, calib)

if disppar == 1
switch atype                  
    case 'PSD'                      %if PSD selected
        fprintf('Computing PSD...')
    case 'PowerSpec'                %if power spectrum selected
        fprintf('Computing power spectrum...')
    case 'Broadband'                %if broadband level selected
        fprintf('Computing broadband level...')
    case 'TOL'                     %if TOL selected
        fprintf('Computing 1/3-octave levels...')
end
end
tic

switch envi
    case 'Air'
    pref = 20;
    case 'Wat'
    pref = 1;
end


%% COMPUTING POWER SPECTRUM ---------------------------------------

%% Divide signal into data segments (corresponds to EQUATION 5)

xl = length(xbit);

if N > xl                           %check segment is shorter than file
    disp('Error: The chosen segment length is longer than the file.')
    A = 0;
    return
end
xbit = single(xbit);                %reduce precision to single for speed
xgrid = buffer(xbit,N,ceil(N*r),'nodelay').';    
                                    %grid whose rows are each (overlapped) 
                                    %   segment for analysis
clear xbit
if xgrid(length(xgrid(:,1)),N) == 0 %remove final segment if not full
    xgrid = xgrid(1:length(xgrid(:,1))-1,:);
end

M = length(xgrid(:,1));             %total number of data segments


%% Apply window function (corresponds to EQUATION 6)

switch winname                      %define window
    case 'None'                     %i.e. rectangular (Dirichlet) window
        w = ones(1,N);
        alpha = 1;                  %scaling factor
    case 'Hann'                     %Hann window         
        w = (0.5 - 0.5*cos(2*pi*(1:N)/N));
        alpha = 0.5;                %scaling factor
    case 'Hamming'                  %Hamming window
        w = (0.54 - 0.46*cos(2*pi*(1:N)/N));
        alpha = 0.54;               %scaling factor
    case 'Blackman'                 %Blackman window
        w = (0.42 - 0.5*cos(2*pi*(1:N)/N) + 0.08*cos(4*pi*(1:N)/N));
        alpha = 0.42;               %scaling factor
end

xgrid = xgrid.*repmat(w/alpha,M,1);
                                    %multiply segments by window function

%% Compute DFT (EQUATION 7)

X = abs(fft(xgrid.')).';            %calculate DFT of each data segment
clear xgrid
% [ if a frequency-dependent correction is being applied to the signal,  
%   e.g. frequency-dependent hydrophone sensitivity, it should be applied 
%   here to each frequency bin of the DFT ]


%% Compute power spectrum (EQUATION 8)

P = (X./N).^2;                      %power spectrum = square of amplitude                                  
clear X

%% Compute single-sided power spectrum (EQUATION 9)

Pss = 2*P(:,2:floor(N/2)+1);        %remove DC (0 Hz) component and 
                                    % frequencies above Nyquist frequency
                                    % Fs/2 (index of Fs/2 = N/2+1), divide
                                    % by noise power bandwidth
clear P
%% Compute frequencies of DFT bins

f = floor(Fs/2)*linspace(1/(N/2),1,N/2);
                                    %calculate frequencies of DFT bins
flow = find(single(f) >= lcut,1,'first');   %low-frequency cut-off                                    
fhigh = find(single(f) <= hcut,1,'last');   %high-frequency cut-off
f = f(flow:fhigh);                  %frequency bins in user-defined range
nf = length(f);                     %number of frequency bins

%% Compute noise power bandwidth and delta(f)

B = (1/N).*(sum((w/alpha).^2));     %noise power bandwidth (EQUATION 12)
delf = Fs/N;                        %frequency bin width

%% Convert to dB

switch atype                  
    case 'PSD'                      %if PSD selected (EQUATION 11)
        a = 10*log10((1/(delf*B))*Pss(:,flow:fhigh)./(pref^2))-S;  
    case 'PowerSpec'                %if power spectrum selected
        a = 10*log10(Pss(:,flow:fhigh)./(pref^2))-S;  %EQUATION 10
    case 'Broadband'                %if broadband level selected
        %a = 10*log10((1/B)*sum(Pss(:,flow:fhigh),2)./(pref^2))-S;
        a = 10*log10(sum(Pss(:,flow:fhigh),2)./(pref^2))-S;
                                    %EQUATION 17

%% 1/3 octave analysis (if selected)
    case 'TOL'
% Generate 1/3-octave frequencies
    if lcut < 25
        lcut = 25;
    end
    lobandf = floor(log10(lcut));   %lowest power of 10 frequency for 1/3 
                                    % octave band computation
    hibandf = ceil(log10(hcut));    %highest ""
    nband = 10*(hibandf-lobandf)+1; %number of 1/3-octave bands
    fc = zeros(1,nband);            %initialise 1/3-octave frequency vector
    fc(1) = 10^lobandf;             %lowest frequency = lowest power of 10

% Calculate centre frequencies (corresponds to EQUATION 13)        
    
    for i = 2:nband                 %calculate 1/3 octave centre 
        fc(i) = fc(i-1)*10^0.1;     % frequencies to (at least) precision 
    end                             % of ANSI standard
    
    fc = fc(find(fc >= lcut,1,'first'):find(fc <= hcut,1,'last'));
                                    %crop frequency vector to frequency
                                    %   range of data

    nfc = length(fc);               %number of 1/3 octave bands
    
% Calculate boundary frequencies of each band (EQUATIONS 14-15)    
    fb = fc*10^-0.05;               %lower bounds of 1/3 octave bands
    fb(nfc+1) = fc(nfc)*10^0.05;    %upper bound of highest band (upper
                                    %   bounds of previous bands are lower
                                    %   bounds of next band up in freq.)
    if max(fb) > hcut               %if highest 1/3 octave band extends 
        nfc = nfc-1;                %   above highest frequency in DFT, 
        fc = fc(1:nfc);             %   remove highest band
    end
    

% Calculate 1/3-octave band levels (corresponds to EQUATION 16)
    P13 = zeros(M,nfc);             %initialise TOL array
        
    for i = 1:nfc                   %loop through centre frequencies
        fli = find(f >= fb(i),1,'first');   %index of lower bound of band
        fui = find(f < fb(i+1),1,'last');   %index of upper bound of band
        for q = 1:M                 %loop through DFTs of data segments
            fcl = sum(Pss(q,fli:fui));%integrate over mth band frequencies
            P13(q,i) = fcl ;         %store TOL of each data segment
        end
    end
    if ~isempty(P13(1,10*log10(P13(1,:)/(pref^2)) <= -10^6))
        lowcut = find(10*log10(P13(1,:)/(pref^2)) <= -10^6,1,'last') + 1;
                                    %index lowest band before empty bands
                                    % at low frequencies
        P13 = P13(:,lowcut:nfc);        %remove empty low-frequency bands
        fb = fb(lowcut:nfc+1);      
        fc = fc(lowcut:nfc);
        nfc = length(fc);              %redefine nfc
    end
	a = 10*log10((1/B)*P13/(pref^2))-S; %TOLs
    clear P13
end
clear Pss


% Compute time vector

tint = (1-r)*N/Fs;                  %time interval in secs between segments
ttot = M*tint-tint;                 %total duration of file in seconds
t = 0:tint:ttot;                    %time vector in seconds   
if ~isempty(tstamp)                 %time stamp data if selected
    t = tstamp + datenum(0,0,0,0,0,t);
end

%% Construct output array
a = double(a);
switch atype
    case {'PSD','PowerSpec'}
        A = zeros(M+1,nf+1);
        A(2:M+1,2:nf+1) = a;
        A(1,2:nf+1) = f; A(2:M+1,1) = t;
    case 'Broadband'
        A = [t.',a];
        A = [zeros(1,2);A];
    case 'TOL'
        A = zeros(M+1,nfc+1); A(2:M+1,2:nfc+1) = a;
        A(1,2:nfc+1) = fc; A(2:M+1,1) = t;
        f = fc;
end

aid = 0;
switch atype
    case 'PSD',aid = aid + 1;
    case 'PowerSpec',aid = aid + 2;
    case 'TOL',aid = aid + 3;
    case 'Broadband',aid = aid + 4;
    case 'Waveform',aid = aid + 5;
    case 'TOLf',aid = aid + 3;
end
if calib == 1,aid = aid + 10;else aid = aid + 20;end
if strcmp(envi,'Air'), aid = aid + 100;else aid = aid + 200;end
if ~isempty(tstamp), aid = aid + 1000;else aid = aid + 2000;end
A(1,1) = aid;

tock = toc;
if disppar == 1,fprintf([' done in ' num2str(tock) ' s.\n']),end