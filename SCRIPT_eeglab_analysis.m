clear all
dbstop if error % optional instruction to stop at a breakpoint if there is an error - useful for debugging
restoredefaultpath

%% 1. ADD TOOLBOXES TO MATLAB PATH
eeglab_path = 'C:\EEGLABtraining2018\eeglab14_1_1b'; % path to eeglab toolbox
fieldtrip_path = 'C:\EEGLABtraining2018\fieldtrip-20180212'; % path to fieldtrip toolbox
batchfun_path = 'C:\EEGLABtraining2018\EEGLABworkshops2018';
support_path = 'C:\EEGLABtraining2018\EEGLABworkshops2018\supporting_functions';

addpath(fieldtrip_path); ft_defaults; % NEW - changed order to to conflict with eeglab BIOSIG toolbox
addpath(genpath(eeglab_path)); 
rmpath(genpath(fullfile(eeglab_path,'plugins\Biosig3.3.0'))); 
addpath(genpath(batchfun_path));
addpath(genpath(support_path));
%% 2. FOLDER AND FILENAME DEFINITIONS

% FILE NAMING
% Name the input files as <study name>_<participant ID>_<sessions name_<block name>_<condition name>
% For example: EEGstudy_P1_S1_B1_C1.set
% Any of the elements can be left out. But all must be separated by underscores.

clear S
S.rawpath = 'C:\EEGLABtraining2018\Data\Raw'; % unprocessed data in original format
S.setpath = 'C:\EEGLABtraining2018\Data\Preprocessed'; % folder to save processed .set data
S.freqpath = 'C:\EEGLABtraining2018\Data\Frequency'; % folder to save processed .set data
S.erppath = 'C:\EEGLABtraining2018\Data\ERP'; % folder to save processed .set data
S.fnameparts = {'study','subject','block','cond'}; % parts of the input filename separated by underscores, e.g.: {'study','subject','session','block','cond'};
S.subjects = {'P1'}; % either a single subject, or leave blank to process all subjects in folder
S.sessions = {};
S.blocks = {'ECA'}; % blocks to load (each a separate file) - empty means all of them, or not defined
S.conds = {'_1.','_1O.','_10.','_10O.'}; % conditions to load (each a separate file) - empty means all of them, or not defined
S.datfile = 'C:\EEGLABtraining2018\EEGLABworkshops2018\Participant_data.xlsx'; % .xlsx file to group participants; contains columns named 'Subject', 'Group', and any covariates of interest
save(fullfile(S.setpath,'S'),'S'); % saves 'S' - will be overwritten each time the script is run, so is just a temporary variable

%% 3. DATA IMPORT
% This identifies files for conversion to EEGLAB format for a
% specific study and sets some parameters for the conversion. It calls the generic function
% "import_eeglab" to do the actual conversion.

% SETTINGS
load(fullfile(S.setpath,'S'))
S.loadext = 'vhdr'; % file extension of input data: supports 'vhdr' (Brainvision), 'cnt' (Neuroscan), 'mff' (EGI - requires mffimport2.0 toolbox)
S.saveprefix = ''; % prefix to add to output file, if needed
S.savesuffix = ''; % suffix to add to output file, if needed
S.chan.excl = [32]; % exclude channels, or leave empty as []
S.chan.addloc = fullfile(eeglab_path,'plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp'); % add channel locations from this path; or leave as ''
% RUN
S=eeglab_import(S);
save(fullfile(S.setpath,'S'),'S'); % saves 'S' - will be overwritten each time the script is run, so is just a temporary variable

%% 2. PREPROCESSING
% SET PREPROCESSING OPTIONS
load(fullfile(S.setpath,'S'))
S.loadext = 'set';
S.subjects = {'P1'}; % either a single subject, or leave blank to process all subjects in folder
S.sessions = {};
S.blocks = {'ECA'}; % blocks to load (each a separate file) - empty means all of them, or not defined
S.conds = {'_1.','_1O.','_10.','_10O.'}; % conditions to load (each a separate file) - empty means all of them, or not defined
S.cont.timewin = {[],[],[],[]}; % timewindow (s) of data to analyse; one per S.conds. Blank = analyse all.
S.downsample = 125;
S.chan.addloc = 'C:\Data\Matlab\eeglab13_6_5b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp'; % add channel locations from this path; or leave as ''
S.chan.interp = [];
S.chan.reref = 1;
S.filter.incl = [0 0];%[0.1 100]; % FILTER - INCLUSIVE
S.filter.notch = {};%{[45 55],[95 105]};
S.epoch.markers = {'S  1' 'S  2' 'S  3' 'S  4' 'S  5' 'S  6' 'S  7' 'S  8' 'S  9'};
S.epoch.addmarker = 1; % set to 1 to add markers if the above are not present: will use the first marker value
S.epoch.timewin = [-0.2 0.3]; % peri-marker time window
S.epoch.detrend = 0;
S.epoch.rmbase = 0;
S.epoch.separate = {[]}; % index of markers to separate into files
S.epoch.separate_suffix = {}; % suffixes to new file names: one per cell of S.epoch.separate
S.FTrej = {[0 5]}; % high freq to identify noise, low freq to identify eye movement
S.ICA = 0;
S.combinefiles = 1;
% RUN
S=eeglab_preprocess(S)
save(fullfile(S.setpath,'S'),'S'); % saves 'S' - will be overwritten each time the script is run, so is just a temporary variable

%% 3. PREPROCESSING AFTER ICA
% Only run this part if you have already manually selected ICA components for removal
% path to ICA processed data
load(fullfile(S.setpath,'S'))
S.loadext = 'combined.set';
S.ICAremove = 1; % remove ICA components (0 if already removed from data, 1 if selected but not removed)
S.detrend = 0;
S.rmbase = 1;
S.basewin = [-0.2 0]; % baseline window
S.FTrej = {[]};
S.reref = 1;
S.separatefiles = 1;
S.separate = {}; % index of markers to separate into files
S.separate_suffix = {}; % suffixes to new files names: one per cell of S.epoch.separate
% RUN
S=eeglab_preprocess_afterICA(S)
save(fullfile(S.setpath,'S'),'S'); % saves 'S' - will be overwritten each time the script is run, so is just a temporary variable
