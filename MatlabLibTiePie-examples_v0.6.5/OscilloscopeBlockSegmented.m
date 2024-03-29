% OscilloscopeBlockSegmented.m - for LibTiePie 0.6+
%
% This example performs a block mode measurement of 5 segments and plots the data.
%
% Find more information on http://www.tiepie.com/LibTiePie .

if verLessThan('matlab', '8')
    error('Matlab 8.0 (R2012b) or higher is required.');
end

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
        if ismember(MM.BLOCK, scp.MeasureModes) & (scp.SegmentCountMax > 1)
            break;
        else
            clear scp;
        end
    end
end
clear item

if exist('scp', 'var')
    % Set measure mode:
    scp.MeasureMode = MM.BLOCK;

    % Set sample frequency:
    scp.SampleFrequency = 1e6; % 1 MHz

    % Set record length:
    scp.RecordLength = 1000; % 10000 Samples

    % Set pre sample ratio:
    scp.PreSampleRatio = 0; % 0 %

    % Set segment count:
    scp.SegmentCount = 5; % 5 segments

    % For all channels:
    for ch = scp.Channels
        % Disable channels:
        ch.Enabled = false;

        % Set range:
        ch.Range = 8; % 8 V

        % Set coupling:
        ch.Coupling = CK.DCV; % DC Volt

        % Release reference:
        clear ch;
    end

    % Enable channel 1:
    scp.Channels(1).Enabled = true;

    % Set trigger timeout:
    scp.TriggerTimeOut = 100e-3; % 100 ms

    % Disable all channel trigger sources:
    for ch = scp.Channels
        ch.Trigger.Enabled = false;
        clear ch;
    end

    % Setup channel trigger:
    chTr = scp.Channels(1).Trigger; % Ch 1

    % Enable trigger source:
    chTr.Enabled = true;

    % Kind:
    chTr.Kind = TK.RISINGEDGE; % Rising edge

    % Level:
    chTr.Levels(1) = 0.5; % 50 %

    % Hysteresis:
    chTr.Hystereses(1) = 0.05; % 5 %

    % Release reference:
    clear chTr;

    % Print oscilloscope info:
    display(scp);

    % Start measurement:
    scp.start();

    % Wait for measurement to complete:
    while ~scp.IsDataReady
        pause(10e-3) % 10 ms delay, to save CPU time.
    end

    % Get all data from the scope:
    wSeg = 1;
    arData = scp.getData();
    while scp.IsDataReady
        wSeg = wSeg + 1;
        arData(:,:,wSeg) = scp.getData();
    end

    % Get all channel data value ranges (which are compensated for probe gain/offset):
    clear darRangeMin;
    clear darRangeMax;
    for i = 1 : length(scp.Channels)
        [darRangeMin(i), darRangeMax(i)] = scp.Channels(i).getDataValueRange();
    end

    % Plot all Ch1 segments:
    figure(500);
    for wSeg = 1 : scp.SegmentCount
        plot((1:scp.RecordLength) / scp.SampleFrequency, arData(:,1,wSeg));
        if wSeg == 1
            hold on
        end
    end
    hold off
    axis([0 (scp.RecordLength / scp.SampleFrequency) min(darRangeMin) max(darRangeMax)]);
    xlabel('Time [s]');
    ylabel('Amplitude [V]');

    % Plot all Ch1 segments in a waterfall:
    figure(600);
    waterfall(transpose(squeeze(arData(:,1,:))))


    % Close oscilloscope:
    clear scp;
else
    error('No oscilloscope available with block measurement and segmented trigger support!');
end
