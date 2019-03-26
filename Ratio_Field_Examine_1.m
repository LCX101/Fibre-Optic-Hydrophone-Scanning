%Examining the ratio field
r=ratio;
threshold = 0.6 ;   %Fraction of maximum value
[r_max]=max(max(r_vec));
r_thresh=r_max*threshold;
r_filtered=nan(size(r));
r_filtered(r>r_thresh)=r(r>r_thresh);

%Calcularing the mean without the filtering
r_mean=mean(mean(r));
r_mean_filt=nanmean(nanmean(r_filtered));


figure
subplot(1,2,1)
imagesc(r)
set(gca,'ydir','normal')
title(strcat('Mean =',num2str(r_mean,3)));
subplot(1,2,2)
imagesc(r_filtered)
set(gca,'ydir','normal')
title(strcat('Mean =',num2str(r_mean_filt,3)));