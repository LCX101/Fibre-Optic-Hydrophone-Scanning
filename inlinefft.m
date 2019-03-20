function [hydrophonePeak, sigGenPeak, freqPeak] = inlinefft(arData,Fs,L,TF)
%INLINEFFT takes scan data inline and outputs peaks at selected frequencies
%   INPUTS arData - data from scope
%           Fs -  sample frequency
%           L - number of samples
%           TF - target frequency for peak measurement

% seperate signals
hydrophoneData = arData(:,1) ;
sigGenData = arData(:,2) ;

% fft calcs
n = 2^nextpow2(L) ;                                 % number of freq points
T = 1/Fs ;                                          % period
t = (0:L-1)*T ;                                     % time vector
f = Fs*(0:(L/2))/L;                                 % frequency vector
hydrophoneDataFreqDom = fft(hydrophoneData) ;       % fft calc
hydrophoneDataFreqDom2 = abs(hydrophoneDataFreqDom/L) ;        % correct amplitude scaling
hydrophoneDataFreqDom1 = 2*hydrophoneDataFreqDom2(1:L/2+1) ;   % ignore mirrored part

sigGenDataFreqDom = fft(sigGenData) ;               % fft calc
sigGenDataFreqDom2 = abs(sigGenDataFreqDom/L) ;                 % correct amplitude scaling
sigGenDataFreqDom1 = 2*sigGenDataFreqDom2(1:L/2+1) ;            % ignore mirrored part

%plot frequency spectrum 
% figure(500)
% plot(f,hydrophoneDataFreqDom1)
% hold on
% plot(f,sigGenDataFreqDom1)

[offset, loc] = min(abs(f-TF));

hydrophonePeak = hydrophoneDataFreqDom1(loc);
sigGenPeak = sigGenDataFreqDom1(loc);
freqPeak = f(loc) ;

end

