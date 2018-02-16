clear all
dbstop if error % optional instruction to stop at a breakpoint if there is an error - useful for debugging

%% 1. ADD TOOLBOXES TO MATLAB PATH
eeglab_path = 'C:\EEGLABtraining2018\eeglab14_1_1b'; % path to eeglab toolbox
fieldtrip_path = 'C:\EEGLABtraining2018\fieldtrip-20180212'; % path to fieldtrip toolbox
batchfun_path = 'C:\EEGLABtraining2018\EEGLABworkshops2018';

addpath(genpath(eeglab_path));
addpath(fieldtrip_path); ft_defaults;
addpath(genpath(batchfun_path));
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
S.fnameparts = {'study','subject','block','event'}; % parts of the input filename separated by underscores, e.g.: {'study','subject','session','block','cond'};
S.subjects = {'P1'}; % either a single subject, or leave blank to process all subjects in folder
S.sessions = {};
S.blocks = {'ECA'}; % blocks to load (each a separate file) - empty means all of them, or not defined
S.conds = {'_1.','_1O.','_10.','_10O.'}; % conditions to load (each a separate file) - empty means all of them, or not defined
S.datfile = 'C:\EEGLABtraining2018\Data\Participant_data.xlsx'; % .xlsx file to group participants; contains columns named 'Subject', 'Group', and any covariates of interest
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
S.chan.addloc = fullfile(eeglab,'plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp'); % add channel locations from this path; or leave as ''
% RUN
S=eeglab_import(S);
save(fullfile(S.setpath,'S'),'S'); % saves 'S' - will be overwritten each time the script is run, so is just a temporary variable
