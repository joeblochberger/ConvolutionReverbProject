% DSP_demo.m
% Tested on the following builds:  MATLAB R2020b
%
% (c) 2021 Joseph Blochberger (jblochb2@jhu.edu).  All rights reserved.
% Feel free to share and use this script with associated files based on the
% following creative commons license: Attribution-NonCommercial-ShareAlike
% 4.0 International (CC BY-NC-SA 4.0).  For more information, see
% creativecommons.org/licenses/by-na-sa/4.0/
%
% Usage:
% This script demonstrates the use of spectrogram analysis for audio
% signals as well as an appplication of convolution utilizing a simulated
% two-channel impulse response.  The curious mind should study the output
% of the script and note which harmonics are present in the signal.
%
% Input:
%      guitar_raw.wav - user selects appropriate .wav file representing a 
%      recorded audio signal.  The default demo is of an Epiphone
%      Hummingbird acoustic guitar having its high E string plucked using a
%      heavy gauge guitar pick and playing 2 string harmonics. The signal
%      is sampled at 48 kHz on a H1n Handy Recorder in mono but exported at
%      44.1 kHz.
%
%      hallsim_reverb_IR.wav - simulated reverb generated using a recorded 
%      clap sample and FL Studio 20 Producer Edition.  The clap is sampled
%      at 48 kHz on a H1n Handy Recorder in stereo but exported at 44.1 kHz
%
%      cathsim_reverb_IR.wav - simulated reverb generated using a recorded
%      clap sample and FL Studio 20 Producer Edition. The clap is sampled
%      at 48 kHz on a H1n Handy Recorder in stereobut exported at 44.1 kHz
%

%% clear the workspace, close all windows, clear the command window
close all; clear; clc;
Warn = warndlg('Warning! Set output volume to 50% before running!','VOLUME WARNING');
uiwait(Warn);

%% Load the guitar sample and the simulated impulse responses
[x,Fs] = audioread('guitar_raw.wav'); % Mono Signal
[hd] = audioread('rawclap_IR.wav'); % Dry IR Stereo
[h1] = audioread('hallsim_reverb_IR.wav'); % Wet IR Stereo
[h2] = audioread('cathsim_reverb_IR.wav'); % Wet IR Stereo

% Normalize all signals to see better
x_norm = x/max(abs(x));
hd_norm = [hd(:,1)/max(abs(hd(:,1))) hd(:,2)/max(abs(hd(:,2)))]; 
h1_norm = [h1(:,1)/max(abs(h1(:,1))) h1(:,2)/max(abs(h1(:,2)))];
h2_norm = [h2(:,1)/max(abs(h2(:,1))) h2(:,2)/max(abs(h2(:,2)))];

%% For the spectrogram analysis portion of the script, the following can be
% tweaked for study: nfft, win, ovrlp
% nfft = 2^2; % length of fft
% nfft = 2^9; % length of fft
% nfft = 2^10; % length of fft
nfft = 2^11; % length of fft

% window
% win = rectwin(nfft); % applied window
% win = triang(nfft); % applied window
win = hann(nfft); % applied window
% win = hamming(nfft); % applied window
% win = flattopwin(nfft); % applied window
% win = blackman(nfft); % applied window

% overlap
% ovrlp = nfft*0
% ovrlp = nfft*0.25; % samples to overlap
ovrlp = nfft*0.50; % samples to overlap
% ovrlp = nfft*0.75; % samples to overlap
% ovrlp = nfft*0.0625; % samples to overlap

%% Visualize the time series signal and impulse responses
fig1 = figure('units','normalized','outerposition',[0 0 1 1]); clf;
fsz = 10;
subplot(4,1,1)
plot(x_norm,'k')
title('Input signal: guitar_raw.wav','interpreter','none')
xlabel('Time Sample [n]')
set(gca,'fontsize',fsz,'fontweight','bold');
legend('Mono')
sound(x_norm,Fs); pause(14)

subplot(4,1,2)
% Visualize both channels of the impulse response
plot(hd_norm(:,1),'color',[0.75 0 0]); hold on;
plot(hd_norm(:,2),'color',[0 0.75 0]);
legend('Left Channel','Right Channel')
title('Impulse Response: rawclap_IR.wav','interpreter','none')
xlabel('Time Sample [n]')
set(gca,'fontsize',fsz,'fontweight','bold');
sound(hd_norm,Fs); pause(4)

subplot(4,1,3)
% Visualize both channels of the impulse response
plot(h1_norm(:,1),'color',[0.75 0 0]); hold on;
plot(h1_norm(:,2),'color',[0 0.75 0]);
legend('Left Channel','Right Channel')
title('Impulse Response: hallsim_reverb_IR.wav','interpreter','none')
xlabel('Time Sample [n]')
set(gca,'fontsize',fsz,'fontweight','bold');
sound(h1_norm,Fs); pause(4)

subplot(4,1,4)
% Visualize both channels of the impulse response
plot(h2_norm(:,1),'color',[0.75 0 0]); hold on;
plot(h2_norm(:,2),'color',[0 0.75 0]);
legend('Left Channel','Right Channel')
title('Impulse Response: cathsim_reverb_IR.wav','interpreter','none')
xlabel('Time Sample [n]')
set(gca,'fontsize',fsz,'fontweight','bold');
sound(h2_norm,Fs); pause(4)

%% Visualize the spectrogram of the dry signal without reverb and the
% result of applied convolution; use the sound function to listen to the
% results.
fig2 = figure('units','normalized','outerposition',[0 0 1 1]); clf;

% Waveform
N = length(x);
time= [0:N-1].'*(1/Fs);
subplot(7,1,1)
plot(time,x_norm,'k');
axis([0 N*(1/Fs) -1 1])
grid on
title('guitar_raw.wav','interpreter','none')
set(gca,'fontsize',fsz,'fontweight','bold');

% spectrogram
[y,freq,time,pres] = spectrogram(x_norm,win,ovrlp,nfft,Fs); % spectrogram
subplot(7,1,[2 3 4 5 6 7])
imagesc(time,freq,10*log10(pres))
axis xy; axis tight;
xlabel('Time [sec]');
ylabel('Frequency [Hz]')
title('Spectrogram of guitar_raw.wav','interpreter','none')
colormap gray(256)
set(gca,'fontsize',fsz,'fontweight','bold');
ylim([0 3000])
caxis([-100 0])
sound(x_norm,Fs); pause(14)

%% Perform convolution of the signal with the simulated IR reverbs

% % Snippet example of convolution with left channel of IR if one wanted to
% test out and write convolution by hand versus random numbers in textbooks
% figure
% subplot(3,1,1)
% stem(x(1:4))
% subplot(3,1,2)
% stem(h1(1:4,1))
% subplot(3,1,3)
% y = conv(x(1:4),h1(1:4,1));
% stem(y)

msgbox('Convolution being performed... please be patient')

% Perform convolution of the signal and large hall simulated reverb
y1Left = conv(x,h1(:,1));
y1Right = conv(x,h1(:,2));
hallsim_result = [y1Left y1Right];

% Perform convolution of the signal and cathedral simulated reverb
y2Left = conv(x,h2(:,1));
y2Right = conv(x,h2(:,2));
cathsim_result = [y2Left y2Right];

%% Visualize the spectrogram of the dry signal without reverb and the
% result of applied convolution; use the sound function to listen to the
% results.

fig3 = figure('units','normalized','outerposition',[0 0 1 1]); clf;

% Waveform
subplot(7,1,[1 2])
N = length(x);
time = [0:N-1].'*(1/Fs);
plot(time,x_norm,'k');
axis([0 N*(1/Fs) -1 1])
grid on
title('guitar_raw.wav','interpreter','none')
set(gca,'fontsize',fsz,'fontweight','bold');

% spectrogram
[y,freq,time,pres] = spectrogram(x_norm,win,ovrlp,nfft,Fs);
subplot(7,1,[3 4 5 6 7])
imagesc(time,freq,10*log10(pres))
axis xy; axis tight;
xlabel('Time [sec]');
ylabel('Frequency [Hz]')
title('Spectrogram of guitar_raw.wav','interpreter','none')
colormap gray(256)
set(gca,'fontsize',fsz,'fontweight','bold');
ylim([0 3000])
caxis([-100 0])
hold on;
plot(time,[ones(1,length(time))].*(329.628*1),'-','color',[0.75 0 0]);
plot(time,[ones(1,length(time))].*(329.628*2),'-','color',[0 0.75 0]);
plot(time,[ones(1,length(time))].*(329.628*3),'-','color',[0 0 0.75]);
legend('Analytical Fundamental','Analytical 1st Harmonic','Analytical 2nd Harmonic')
sound(x_norm,Fs); pause(14)

fig4 = figure('units','normalized','outerposition',[0 0 1 1]); clf;

% Waveform
[y,freq,time,pres] = spectrogram(hallsim_result(:,1),win,ovrlp,nfft,Fs);
numidx1 = find(min(abs(freq-329.628*1))==abs(freq-329.628*1));
numidx2 = find(min(abs(freq-329.628*2))==abs(freq-329.628*2));
numidx3 = find(min(abs(freq-329.628*3))==abs(freq-329.628*3));
subplot(7,1,[1 2])
N = length(h2_norm);
plot(time,10*log10(pres(numidx1,:)),'color',[0.75 0 0]); hold on;
plot(time,10*log10(pres(numidx2,:)),'color',[0 0.75 0]);
plot(time,10*log10(pres(numidx3,:)),'color',[0 0 0.75]);
legend('Analytical Fundamental','Analytical 1st Harmonic','Analytical 2nd Harmonic')
axis tight;
grid on
title('Convolution Reverb: Large Hall','interpreter','none')
set(gca,'fontsize',fsz,'fontweight','bold');
ylabel('dB, re: Unity')

% spectrogram
[y,freq,time,pres] = spectrogram(hallsim_result(:,1),win,ovrlp,nfft,Fs);
subplot(7,1,[3 4 5 6 7])
imagesc(time,freq,10*log10(pres))
axis xy; axis tight;
xlabel('Time [sec]');
ylabel('Frequency [Hz]')
title('Spectrogram of convolution reverb - large hall (left channel)','interpreter','none')
colormap gray(256)
set(gca,'fontsize',fsz,'fontweight','bold');
ylim([0 3000])
caxis([-100 0])
hold on;
plot(time,[ones(1,length(time))].*(329.628*1),'-','color',[0.75 0 0]);
plot(time,[ones(1,length(time))].*(329.628*2),'-','color',[0 0.75 0]);
plot(time,[ones(1,length(time))].*(329.628*3),'-','color',[0 0 0.75]);
legend('Analytical Fundamental','Analytical 1st Harmonic','Analytical 2nd Harmonic')
sound(hallsim_result,Fs); pause(14)

fig5 = figure('units','normalized','outerposition',[0 0 1 1]); clf;

% spectrogram
[y,freq,time,pres] = spectrogram(cathsim_result(:,1),win,ovrlp,nfft,Fs);
numidx1 = find(min(abs(freq-329.628*1))==abs(freq-329.628*1));
numidx2 = find(min(abs(freq-329.628*2))==abs(freq-329.628*2));
numidx3 = find(min(abs(freq-329.628*3))==abs(freq-329.628*3));
subplot(7,1,[1 2])
N = length(h2_norm);
plot(time,10*log10(pres(numidx1,:)),'color',[0.75 0 0]); hold on;
plot(time,10*log10(pres(numidx2,:)),'color',[0 0.75 0]);
plot(time,10*log10(pres(numidx3,:)),'color',[0 0 0.75]);
legend('Analytical Fundamental','Analytical 1st Harmonic','Analytical 2nd Harmonic')
axis tight;
grid on
title('Convolution Reverb: Cathedral','interpreter','none')
set(gca,'fontsize',fsz,'fontweight','bold');
ylabel('dB, re: Unity')

subplot(7,1,[3 4 5 6 7])
imagesc(time,freq,10*log10(pres))
axis xy; axis tight;
xlabel('Time [sec]');
ylabel('Frequency [Hz]')
title('Spectrogram of convolution reverb - cathedral (left channel)','interpreter','none')
colormap gray(256)
set(gca,'fontsize',fsz,'fontweight','bold');
ylim([0 3000])
caxis([-100 0])
hold on;
plot(time,[ones(1,length(time))].*(329.628*1),'-','color',[0.75 0 0]);
plot(time,[ones(1,length(time))].*(329.628*2),'-','color',[0 0.75 0]);
plot(time,[ones(1,length(time))].*(329.628*3),'-','color',[0 0 0.75]);
legend('Analytical Fundamental','Analytical 1st Harmonic','Analytical 2nd Harmonic')
sound(cathsim_result,Fs); pause(14)

%% Main lobes and sidelobe comparison

fig5 = figure('units','normalized','outerposition',[0 0 1 1]); clf;

subplot(3,3,1)
[y,freq,time,pres] = spectrogram(x_norm,win,ovrlp,nfft,Fs);
tidx = find(min(abs(time-2))==abs(time-2));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('No convolution, time = 2 sec')

subplot(3,3,2)
[y,freq,time,pres] = spectrogram(hallsim_result(:,1),win,ovrlp,nfft,Fs);
tidx = find(min(abs(time-2))==abs(time-2));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('Convolution w/ Large Hall, time = 2 sec')

subplot(3,3,3)
[y,freq,time,pres] = spectrogram(cathsim_result(:,1),win,ovrlp,nfft,Fs);
tidx = find(min(abs(time-2))==abs(time-2));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('Convolution w/ Cathedral, time = 2 sec')

subplot(3,3,4)
[y,freq,time,pres] = spectrogram(x_norm,win,ovrlp,nfft,Fs);
tidx = 258;
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('No convolution, time = 6 sec')

subplot(3,3,5)
[y,freq,time,pres] = spectrogram(hallsim_result(:,1),win,ovrlp,nfft,Fs);
tidx = find(min(abs(time-6))==abs(time-6));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('Convolution w/ Large Hall, time = 6 sec')

subplot(3,3,6)
[y,freq,time,pres] = spectrogram(cathsim_result(:,1),win,ovrlp,nfft,Fs);
tidx = find(min(abs(time-6))==abs(time-6));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('Convolution w/ Cathedral, time = 6 sec')

[y,freq,time,pres] = spectrogram(x_norm,win,ovrlp,nfft,Fs);
subplot(3,3,7)
tidx = find(min(abs(time-10))==abs(time-10));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('No convolution, time = 10 sec')

subplot(3,3,8)
[y,freq,time,pres] = spectrogram(hallsim_result(:,1),win,ovrlp,nfft,Fs);
tidx = find(min(abs(time-10))==abs(time-10));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('Convolution w/ Large Hall, time = 10 sec')

subplot(3,3,9)
[y,freq,time,pres] = spectrogram(cathsim_result(:,1),win,ovrlp,nfft,Fs);
tidx = find(min(abs(time-10))==abs(time-10));
plot(freq,10*log10(pres(:,tidx)),'-k'); hold on;
plot([ones(1,length(freq))].*(329.628*1),linspace(-100,0,length(freq)),'-','color',[0.75 0 0]); 
plot([ones(1,length(freq))].*(329.628*2),linspace(-100,0,length(freq)),'-','color',[0 0.75 0]);
plot([ones(1,length(freq))].*(329.628*3),linspace(-100,0,length(freq)),'-','color',[0 0 0.75]);
xlim([0 1500])
xlabel('freq, Hz')
ylim([-100 0])
ylabel('dB')
grid on
set(gca,'fontsize',fsz,'fontweight','bold');
title('Convolution w/ Cathedral, time = 10 sec')