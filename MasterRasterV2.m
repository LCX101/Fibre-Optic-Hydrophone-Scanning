%% CONNECT TO STAGE (may have to change serial port name)

 %   if ~isempty(instrfind)
 %    fclose(instrfind);
 %     delete(instrfind);
%end

% Specify serial port
portName = 'COM5';

deviceAddress = 0; % 0 = both, 1 = X-axis, 2 = Y-axis
axisNumber = 0; 

% Set up serial object
s = serial(portName);
set(s, 'BaudRate',115200, 'DataBits',8, 'FlowControl','none',...
    'Parity','none', 'StopBits',1, 'Terminator','CR/LF'); % Don't mess with these values

fopen(s);

%% CONNECT TO HANDYSCOPE

% Open LibTiePie and display library info if not yet opened:
import LibTiePie.Const.*
import LibTiePie.Enum.*

if ~exist('LibTiePie', 'var')
  % Open LibTiePie:
  LibTiePie = LibTiePie.Library
end

% Search for devices:
LibTiePie.DeviceList.update();

% Try to open an oscilloscope with block measurement support:
clear scp;
for k = 0 : LibTiePie.DeviceList.Count - 1
    item = LibTiePie.DeviceList.getItemByIndex(k);
    if item.canOpen(DEVICETYPE.OSCILLOSCOPE)
        scp = item.openOscilloscope();
        if ismember(MM.BLOCK, scp.MeasureModes)
            break;
        else
            clear scp;
        end
    end
end
clear item

%% SET OSCILLOSCOPE SETTINGS

if exist('scp', 'var')
    % Set measure mode:
    scp.MeasureMode = MM.BLOCK;

    % Set sample frequency:
    scp.SampleFrequency = 20e6; 

    % Set record length:
    scp.RecordLength = 100000; % number of samples

    % Set pre sample ratio:
    scp.PreSampleRatio = 0; 

    % For all channels:
    for ch = scp.Channels
        % Enable channel to measure it:
        ch.Enabled = true;
        
        % Set coupling:
        ch.Coupling = CK.DCV; % DC Volt

        % Release reference:
        clear ch;
    end
    
    % Set range on each channel
    scp.Channels(1).Range = 0.2 ;
    scp.Channels(2).Range = 8 ;    
    
    % Print oscilloscope info:
    display(scp);
end

%% MANUALLY SET HOME WITH STAGE

%% SET CURRENT POSITION AS HOME

[home_pos] = AF_setHome(s) ;

%% DEFINE RASTER POINTS/AREA

raster_x_size = 5 ; % mm
raster_y_size = 5 ; % mm
step_size = 1 * 20000 ; % mm * scale

raster_x = (home_pos(1) - 0.5*(raster_x_size*20000)) : step_size : (home_pos(1) + 0.5*(raster_x_size*20000)) ;
raster_y = (home_pos(2) - 0.5*(raster_y_size*20000)) : step_size : (home_pos(2) + 0.5*(raster_y_size*20000)) ;

%% RASTER SCAN AND MEASURE WITH HYDROPHONE

targetFreq = 2e6;
pause('on')
hydrophonePeaks = zeros(length(raster_x),length(raster_y)) ;
sigGenPeaks = zeros(length(raster_x),length(raster_y)) ;
freqPeaks = zeros(length(raster_x),length(raster_y)) ;

for ii = 1 : numel(raster_x)
    for jj = 1: numel(raster_y)
        
        if mod(ii,2)==0 % iseven -> this makes the scan snake
            raster_yROW = flip(raster_y);
        else
            raster_yROW = raster_y;
        end
      
        AF_moveToPos(s, raster_x(ii), raster_yROW(jj))
        
        pause(0.05) % can tweak these to spped up or slow down scan
        
        [scp, arData, darRangeMin, darRangeMax] = AF_takeMeasOscilloscope( scp ) ;
        
        [hydrophonePeaks(ii,jj), sigGenPeaks(ii,jj), freqPeaks(ii,jj)] = inlinefft(arData,scp.SampleFrequency,scp.RecordLength, targetFreq);
        %hydrophonePeaks(ii,jj), sigGenPeaks(ii,jj), freqPeaks(ii,jj), phsDiff(ii,jj)] = inlinefftphase(arData,scp.SampleFrequency,scp.RecordLength);

        pause(0.05)
        
    end
end

hydrophonePeaks(2:2:end,:) = fliplr(hydrophonePeaks((2:2:end),:));
sigGenPeaks(2:2:end,:) = fliplr(sigGenPeaks((2:2:end),:));
freqPeaks(2:2:end,:) = fliplr(freqPeaks((2:2:end),:));

save('FOH_2019_demo.mat','hydrophonePeaks','sigGenPeaks','freqPeaks') 
%% QUICK PLOT OF SCAN

figure(513)
pcolor(hydrophonePeaks)
shading flat
daspect([1 1 1])

figure(502)
pcolor(sigGenPeaks)
shading flat
daspect([1 1 1])

figure(503)
pcolor(freqPeaks)
shading flat
daspect([1 1 1])

 