%% 20140725 


%% 1145 - Attempting to Fix Affine Transformations of Schumacher Data
% Today's parameters
timeStamp = '201407251145';

paramStruct = struct(...
    'General', struct(...
        'ConvertToStructure', false,...
        'LargeData', false,...
        'OutputPath', 'C:/Users/jgrooms/Desktop/Data Sets/Raw Data/Schumacher Data',...
        'Scans', {{[1]}},...
        'ScanState', 'RS',...
        'Subjects', 1,...
        'UseSliceTimingCorrection', false),...
    'Initialization', struct(...
        'AnatomicalFolderStr', 't1_MPRAGE_',...
        'DataPath', 'C:/Users/jgrooms/Desktop/Data Sets/Raw Data/Schumacher Data',...
        'FunctionalFolderStr', 'fMRI_\d_\d\d',...
        'IMGFolderStr', 'IMG',...
        'MNIBrain', 'C:/Users/jgrooms/Dropbox/Globals/MNI/template/T1.nii',...
        'MNIFolder', 'C:/Users/jgrooms/Dropbox/Globals/MNI',...
        'ROIFolder', 'C:/Users/jgrooms/Dropbox/Globals/MNI/roi',...
        'SegmentsFolder', 'C:/Users/jgrooms/Dropbox/Globals/MNI/segments',...
        'SubjectFolderStr', 'DMC_003'),...
    'Segmentation', struct(...
        'BiasReg', 0.0001,...
        'BiasFWHM', 60,...
        'Cleanup', false,...
        'MaskImage', {{''}},...
        'NumGauss', [2 2 2 4],...
        'OutputCorrected', true,...
        'OutputCSF', [0 0 1],...
        'OutputGM', [0 0 1],...
        'OutputWM', [0 0 1],...
        'RegType', 'mni',...
        'SampleDistance', 3,...
        'WarpReg', true,...
        'WarpCutoff', 25),...
    'Registration', struct(...
        'CostFunction', 'nmi',...
        'FWHMSmoothing', [7 7],...
        'Interpolation', 1,...
        'Masking', 0,...
        'OutputPrefix', 'r',...
        'Separation', [4 2],...
        'Tolerances', [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001 0.001],...
        'Wrapping', [0 0 0]),...
    'Normalization', struct(...
        'AmtRegularization', 1,...
        'BoundingBox', [-78 -112 -50; 78 76 85],...
        'DCTCutoff', 25,...
        'Interpolation', 1,...
        'Masking', false,...
        'NormPrefix', 'w',...
        'NumIterations', 16,...
        'Preservation', 0,...
        'RegPrefix', 'r',...
        'Regularization', 'mni',...
        'SourceSmoothing', 8,...
        'TemplateSmoothing', 0,...
        'TemplateWeightImage', {''},...
        'VoxelSize', [2 2 2],...
        'Wrapping', [0 0 0]),...
    'Conditioning', struct(...
        'BlurMasks', true,...
        'CSFCutoff', 0.2,...
        'DetrendOrder', 2,...
        'FilterData', true,...
        'FilterLength', 45,...
        'GMCutoff', 0.1,...
        'MeanCutoff', 0.2,...
        'NumPCToRegress', NaN,...
        'NumTRToRemove', 0,...
        'Passband', [0.01 0.08],...
        'PCAVarCutoff', 0.0001,...
        'RegressCSF', false,...
        'RegressGlobal', false,...
        'SpatialBlurSigma', 2,...
        'SpatialBlurSize', 3,...
        'UsePCA', false,...
        'UseZeroPhaseFilter', true,...
        'WMCutoff', 0.15));

boldObj(paramStruct);



%% 1314 - Image Slices of Functional Data at Various Preprocessing Stages
% Today's parameters
timeStamp = '201407251314';

% load([get(Paths, 'Desktop') '/prepMotion.mat']);
load([get(Paths, 'Desktop') '/prepDCM2IMG.mat']);


funFiles = boldData.Preprocessing.Files.IMG.Functional;

% funIMG = load_nii(funFiles{1}(1:end-2));
funIMG = load_nii(funFiles{1});

for a = 1:22
    figure;
    imagesc(funIMG.img(:, :, a));
end



%% 1736 - Re-Running EEG Interelectrode Correlations at Classical EEG Passbands
% Today's parameters
timeStamp = '201407251736';
analysisStamp = '%s Band EEG Interelectrode Correlations';
dataSaveName = 'C:/Users/jgrooms/Desktop/Today Data/20140725/201407251736 - %s%s';
imSaveName = 'C:/Users/jgrooms/Desktop/Today Data/20140725/201407251736-%d - %s%s';

bandStrs = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};
passbands = {[1, 4], [4, 8], [8, 13], [13, 30], [30, 100]};

eegPath = [get(Paths, 'EEG') '/Unfiltered'];
eegFiles = search(eegPath, 'eegObject', 'Ext', '.mat');

corrData = nan(68, 68, 17);

% Create & image correlations by scan
pbar = progress('EEG Interelectrode Correlations', 'Scans Completed');
for a = 2:length(bandStrs)
    
    currentAnalysis = sprintf(analysisStamp, bandStrs{a});
    
    reset(pbar, 2);
    for b = 1:length(eegFiles)
        load(eegFiles{b})
        Filter(eegData, 'Passband', passbands{a});
        ephysData = ToArray(eegData);
        corrData(:, :, b) = corrcoef(ephysData');

        figure;
        imagesc(corrData(:, :, b), [-1 1]);
        cbar = colorbar;
        set(gca, 'XTick', 0:10:64, 'YTick', 0:10:64);
        set(cbar, 'YTick', -1:0.5:1);
        set(gca, 'FontSize', 20);
        set(get(cbar, 'YLabel'), 'String', 'r', 'FontSize', 25);
        xlabel('Electrode Index', 'FontSize', 25);
        ylabel('Electrode Index', 'FontSize', 25);
        imSaveStrPNG = sprintf(imSaveName, b, currentAnalysis, '.png');
        imSaveStrFIG = sprintf(imSaveName, b, currentAnalysis, '.fig');
        saveas(gcf, imSaveStrPNG, 'png');
        saveas(gcf, imSaveStrFIG, 'fig');
        close;

        update(pbar, 2, b/length(eegFiles));
    end

    % Average data together & save everything
    meanCorrData = nanmean(corrData, 3);
    dataSaveStr = sprintf(dataSaveName, currentAnalysis, '.mat');
    save(dataSaveStr, 'corrData', 'corrData', 'meanCorrData', '-v7.3');

    % Image the average interelectrode correlations
    figure;
    imagesc(meanCorrData, [-1 1]);
    cbar = colorbar;
    set(gca, 'XTick', 0:10:64, 'YTick', 0:10:64);
    set(cbar, 'YTick', -1:0.5:1);
    set(gca, 'FontSize', 20);
    set(get(cbar, 'YLabel'), 'String', 'r', 'FontSize', 25);
    xlabel('Electrode Index', 'FontSize', 25);
    ylabel('Electrode Index', 'FontSize', 25);
    imSaveStrPNG = sprintf(dataSaveName, analysisStamp, '.png');
    imSaveStrFIG = sprintf(dataSaveName, analysisStamp, '.fig');
    saveas(gcf, imSaveStrPNG, 'png');
    saveas(gcf, imSaveStrFIG, 'fig');
    close all;
    
    update(pbar, 1, a/length(bandStrs));
end
close(pbar);