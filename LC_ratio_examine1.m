function [r_mean,r_mean_filt]=LC_ratio_examine1(targetFreq,hydrophonePeaks,sigGenPeaks,addendum)
%Measuring the ratio, r, between the two
r=hydrophonePeaks./sigGenPeaks;

threshold = 0.5 ;   %Fraction of maximum value
[r_max]=max(max(r));
r_thresh=r_max*threshold;
r_filtered=nan(size(r));
r_filtered(r>r_thresh)=r(r>r_thresh);

%Calcularing the mean without the filtering
r_mean=mean(mean(r));
r_mean_filt=nanmean(nanmean(r_filtered));



%Saving the data
file_name=strcat('FOH_',num2str(targetFreq/1e3,4),'kHz',addendum,'.mat');
save(file_name,'hydrophonePeaks','sigGenPeaks','r','r_filtered','r_mean','r_mean_filt'); %ADD R_FILTERED
end
