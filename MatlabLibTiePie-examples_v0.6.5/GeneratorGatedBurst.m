% GeneratorGatedBurst.m - for LibTiePie 0.6+
%
% This example generates a 10 kHz square waveform, 5 Vpp when the external trigger input is active.
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

% Try to open a generator with arbitrary support:
clear gen;
for k = 0 : LibTiePie.DeviceList.Count - 1
    item = LibTiePie.DeviceList.getItemByIndex(k);
    if item.canOpen(DEVICETYPE.GENERATOR)
        gen = item.openGenerator();
        if ismember(GM.GATED_PERIODS, gen.ModesNative) && ~isempty(gen.TriggerInputs)
            break;
        else
            clear gen;
        end
    end
end
clear item

if exist('gen', 'var')
    % Set signal type:
    gen.SignalType = ST.SQUARE;

    % Set frequency:
    gen.Frequency = 10e3; % 10 kHz

    % Set amplitude:
    gen.Amplitude = 5; % 5 V

    % Set offset:
    gen.Offset = 0; % 0 V

    % Set mode:
    gen.Mode = GM.GATED_PERIODS;

    % Locate trigger input:
    triggerInput = gen.getTriggerInputById(TIID.EXT1); % EXT 1

    if triggerInput == false
        clear triggerInput;
        clear gen;
        error('Unknown trigger input!');
    end

    % Enable trigger input:
    triggerInput.Enabled = true;

    % Release reference to trigger input:
    clear triggerInput;

    % Enable output:
    gen.OutputOn = true;

    % Print generator info:
    display(gen);

    % Start signal burst:
    gen.start();

    % Wait for keystroke:
    display('Press any key to stop signal generation...');
    waitforbuttonpress;

    % Stop generator:
    gen.stop();

    % Disable output:
    gen.OutputOn = false;

    % Close generator:
    clear gen;
else
    error('No generator available with gated burst support!');
end
