
channel=1;                      % recording channel
sen=0;                          % microphone/hydrophone sensitivity
FFT_size=1024;                  % window size (samples)
reading_interval=300;           % time interval of data reading (second)
ltsa_resolution=10;             % time resolution of long-term spectrogram (second)
Frequency_range=[100 20000];    % frequency range of long-term spectrogram (Hz)
Recording_env='Air';            % Recording environment
Recording_device='SM';          % Recording device ('SM' or 'Soundtrap')