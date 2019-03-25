function [mean_ratio]=LC_Freq_sweep_1(MeasureFreq,hydrophonePeaks,sigGenPeaks,addendum)
%Measuring the ratio between the two
ratio=hydrophonePeaks./sigGenPeaks;
mean_ratio=mean(mean(ratio));

%Plotting the figure
figure(3)
imagesc(ratio)
set(gca,'ydir','normal')
colorbar;
title(strcat('Mean Ratio=',num2str(mean_ratio,3)))

%Saving the data
file_name=strcat('FOH_',num2str(MeasureFreq/1e3,4),'kHz',addendum,'.mat');
save(file_name,'hydrophonePeaks','sigGenPeaks','ratio','mean_ratio');
