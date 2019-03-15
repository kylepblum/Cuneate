%% Get spindle output for relevant muscles

muscles = {'brachioradialis','brachialis','tricep_lat','tricep_lon',...
    'tricep_sho','pectoralis_sup','pectoralis_inf','lat_dorsi_sup',...
    'flex_carpi_ulnaris','flex_carpi_radialis','flex_digit_superficialis'};

EMG = {'EMG_Brad','EMG_Brach','EMG_TriLat','EMG_TriMid','EMG_TriMed',...
'EMG_PecSup','EMG_PecInf','EMG_Lat','EMG_FCU','EMG_FCR','EMG_FDS'};

spindleParams.trialInd = 1:numel(trial_data);
spindleParams.bufferSize = 1/trial_data(1).bin_size; %1 second buffer
spindleParams.time_step = 0.005;
spindleParams.startIdx = {'idx_startTime',0}; %reference index and relative idx
spindleParams.endIdx = {'idx_endTime',0};
spindleParams.dataStore = 'lean';

for idxMuscle = 1:numel(muscles)

    spindleParams.emgName = EMG{idxMuscle};
    spindleParams.musName = muscles{idxMuscle};
    
    spindleOut(idxMuscle,:) = getAffPotFromMusState(trial_data,spindleParams);    
end

%% Get smooth firing rates



%% Run GLMs for cuneate neurons based on relevant muscle spindles

