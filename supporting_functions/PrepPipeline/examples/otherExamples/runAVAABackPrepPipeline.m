%% Example: Running the pipeline outside of ESS using the ARL shooter data.
% This data is organized into subdirectories by subject under the main
% input directory. The data is in raw format, but has the channel
% locations. However, the assignment to reference and evaluation channels
% has to be be done manually.

%% Read in the file and set the necessary parameters
basename = 'TsLs_NBack';
inDir = 'E:\CTAData\AVAA_Validation_setfiles'; % Input data directory used for this demo
outDir = 'O:\ARL_Data\TsLs_NBack\AVAA_Robust_1Hz';
reportDir = 'O:\ARL_Data\TsLs_NBack\AVAA_Robust_1Hz_Report';
doReport = true;
publishOn = true;
%% Prepare if reporting
if doReport
    summaryReportName = [basename '_summary.html'];
    sessionFolder = '.';
    summaryReport = [reportDir filesep summaryReportName];
    if exist(summaryReport, 'file')
        delete(summaryReport);
    end
    summaryFile = fopen(summaryReport, 'a+', 'n', 'UTF-8');
end
%% Parameters that must be preset
params = struct();
%params.lineFrequencies = [60, 120, 180, 200, 212, 240];
params.detrendType = 'high pass';
params.detrendCutoff = 1;
params.referenceType = 'robust';
params.keepFiltered = false;
params.referenceChannels = 1:20;
params.lineNoiseChannels = 1:20;
params.referenceChannels = 1:20;
params.evaluationChannels = 1:20;
params.rereferencedChannels = 1:20;
params.detrendChannels = 1:20;
params.lineNoiseChannels = 1:20;
params.meanEstimateType = 'median';
params.interpolationOrder = 'post-reference';
params.keepFiltered = false;
params.ignoreBoundaryEvents = true;
basenameOut = [basename 'robust_1Hz_post_median_unfiltered'];

%% Get the directories
inList = dir(inDir);
dirNames = {inList(:).name};
dirTypes = [inList(:).isdir];
fileNames = dirNames(~dirTypes);

%% Run the pipeline
for k = 1:length(fileNames)
    [myPath, myName, myExt] = fileparts(fileNames{k});
    if ~strcmpi(myExt, '.set')
        continue;
    end
    thisName = [inDir filesep fileNames{k}];
    EEG = pop_loadset(thisName);
    params.name = myName;
    [EEG, computationTimes] = prepPipeline(EEG, params);
    fprintf('Computation times (seconds):\n   %s\n', ...
        getStructureString(computationTimes));
    fname = [outDir filesep fileNames{k}];
    save(fname, 'EEG', '-mat', '-v7.3');
    if doReport
        [fpath, name, fext] = fileparts(thisName);
        sessionReportName = [name '.pdf'];
        sessionReport = [reportDir filesep sessionReportName];
        consoleFID = 1;
        publishPrepReport(EEG, summaryReport, sessionReport, consoleFID, ...
                          publishOn);
    end
end

