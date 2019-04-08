%% Get spindle output for relevant muscles
muscles = {'brachioradialis','brachialis','tricep_lat','tricep_lon',...
    'tricep_sho','pectoralis_sup','pectoralis_inf','lat_dorsi_sup',...
    'flex_carpi_ulnaris','flex_carpi_radialis','flex_digit_superficialis',...
    'deltoid_ant','deltoid_med','deltoid_pos','teres_major','infraspinatus'...
    'ext_carp_rad_brevis','ext_carpi_ulnaris','ext_digitorum','bicep_sh',...
    'bicep_lh'};

EMG = {'EMG_Brad','EMG_Brach','EMG_TriLat','EMG_TriMid','EMG_TriMed',...
'EMG_PecSup','EMG_PecInf','EMG_Lat','EMG_FCU','EMG_FCR','EMG_FDS',...
'EMG_DeltAnt','EMG_DeltMid','EMG_DeltPos','EMG_TerMaj',...
'EMG_InfSpin','EMG_ECRb','EMG_ECU','EMG_EDC','EMG_BiMed','EMG_BiLat'};

spindleParams.trialInd = 1:numel(trial_data);
spindleParams.bufferSize = 1/trial_data(1).bin_size; %1 second buffer
spindleParams.time_step = 0.005;
spindleParams.startIdx = {'idx_startTime',0}; %reference index and relative idx
spindleParams.endIdx = {'idx_endTime',0};
spindleParams.dataStore = 'lean';
trial_data(1).spindleOut = [];

for idxMuscle = 1:numel(muscles)

    spindleParams.emgName = EMG{idxMuscle};
    spindleParams.musName = muscles{idxMuscle};
    
    spindleOut_constG(:,idxMuscle) = getAffPotFromMusState(trial_data,spindleParams);    
end


%% Smooth spindle outputs

% smoothParams.kernel_SD = 0.1; %seconds
% smoothParams.signals = 'r';
% % smoothParams.calc_rate = true;
% 
% for idxMuscle = 1:size(spindleOut_GS,2)
%     for idxTrial = 1:size(spindleOut_GS,1)
% 
%         spindleOut_GS(idxTrial,idxMuscle) = ...
%              smoothSignals(spindleOut_GS(idxTrial,idxMuscle),smoothParams);
%         
%     end
% end



%% Run GLMs for cuneate neuron meanFR based on relevant muscle spindle

glmParams.idx_msInputs = [];
glmParams.idx_emgInputs = [1:22];
glmParams.idxCell = 4;
glmParams.trialType = 'all';

[Bact,FRact,Xact] = fitCuneateGLMs(trial_data,spindleOut_constG,glmParams);

% glmParams.trialType = 'bump';
% [Bpas,FRpas,Xpas] = fitCuneateGLMs(trial_data,spindleOut_constG,glmParams);
% 
% actXpas = glmval(Bact,Xpas,'log');
% 
% pasXact = glmval(Bpas,Xact,'log');


%% Do cuneate GLM cross-validation
xvalParams.idx_msInputs = [1:21];
xvalParams.idx_emgInputs = [1:22];
xvalParams.idx_lenInputs = [1:39];
xvalParams.idx_velInputs = [1:39];
xvalParams.idxCell = 4;

trialsPerm = randperm(numel(trial_data));

xvalParams.idx_trials = trialsPerm;





%% Run nnmf analysis on firing rates
nnmfParams.idxCell = 1;
nnmfParams.trialType = 'act';

nnmfCuneate(trial_data,nnmfParams);



