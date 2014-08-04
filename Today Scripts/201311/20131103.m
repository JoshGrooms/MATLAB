%% 20131103


%% 1834 - Generate ICA Images of FB BOLD Data
load masterStructs
boldFiles = get(fileData([fileStruct.Paths.DataObjects '/BOLD'], 'Search', 'fbZ'), 'Path');

for a = 1:length(boldFiles)
    load(boldFiles{a})
    convertToIMG(boldData);
    clear boldData
end

icaOutputFolder = ['E:\Graduate Studies\Lab Work\Data Sets\ICA Results\20131103 - GIFT Analysis Files (20 ICs, RS, FB, No GR)'];
mkdir(icaOutputFolder);


%% 1943 - Label ICs
% componentIDs = {...
%     'Precuneus',...
%     'RLN',...
%     'PVN',...
%     'WM',...
%     'Salience',...
%     'CSF',...
%     'DAN',...
%     'LVN',...
%     'Executive',...
%     '
%     'Auditory',...
%     'BG',...
%     'SMN',...
%     'Cerebellum',...
%     '
%     'LLN',...
%     '

% Can't identify several of the ICA networks from FB BOLD data and am missing some critical networks for comparison with
% DC data sets. Running coherence between DC RSN-EEG data sets now instead.


%% 1959 - Examining RSN-EEG MS Coherence
load masterStructs
eegFiles = get(fileData([fileStruct.Paths.DataObjects '/EEG'], 'Search', 'dcZ'), 'Path');
boldFiles = get(fileData([fileStruct.Paths.DataObjects '/BOLD'], 'Search', 'dcZ'), 'Path');
parentData = {boldFiles, eegFiles};
channels = paramStruct.general.channels;

% Setup a coherence parameter structure
cohStruct = struct(...
    'Initialization', struct(...
        'Bandwidth', {{'dc', 'dc'}},...
        'GSR', [false false],...
        'Modalities', 'RSN-EEG',...
        'ParentData', {parentData},...
        'Relation', 'MS Coherence',...
        'Scans', {{[1 2] [1 2] [1 2] [1 2] [1 2] [1 2] [1 2] [1 2]}},...
        'ScanState', 'RS',...
        'Subjects', []),...
    'Coherence', struct(...
        'Channels', {channels},...
        'GenerateNull', false,...
        'Masking', struct(...
            'Method', 'Correlation',...
            'File', [],...
            'Image', [],...
            'Shift', 4,...
            'Threshold', 0.9),...
        'NFFT', [],...
        'SegmentOverlap', [],...
        'Window', []),...
    'Thresholding', struct(...
        'AlphaVal', 0.05,...
        'CDFMethod', 'arbitrary',...
        'FWERMethod', 'sgof',...
        'Parallel', 'gpu',...
        'Tails', 'upper'));
cohData = cohObj(cohStruct);
store(cohData);
meanCohData = mean(cohData);

% Running this analysis is going to require some more extensive coding. Going to have to resume this later.


%% 2028 - Examining EEG Volume Conduction
load masterStructs
eegFiles = get(fileData([fileStruct.Paths.DataObjects '/EEG'], 'Search', 'fbZ'), 'Path');

corrData = [];
progBar = progress('Subjects Completed', 'Scans Completed');
for a = 1:length(eegFiles)
    load(eegFiles{a});
    standardize(eegData);
    
    reset(progBar, 2);
    for b = 1:length(eegData)
        if ~isempty(eegData(b).Data)
            
            currentData = eegData(b).Data.EEG;
            for c = 1:size(currentData, 1);
                [currentCorr, lags] = xcorrArr(currentData, currentData(c, :), 'MaxLag', 300, 'ScaleOpt', 'coeff');

                szCorr = size(currentCorr);
                currentCorr = reshape(currentCorr, [szCorr(1), 1, szCorr(2)]);
                corrData = cat(2, corrData, currentCorr);
            end
        end
        update(progBar, 2, b/length(eegData));
    end
    update(progBar, 1, a/length(eegFiles));
end
close(progBar);

save([fileStruct.Paths.Desktop '/tempVolumeConduction.mat']);