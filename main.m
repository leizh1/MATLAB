dbstop if error;

% globalParams = struct;
% globalParams.N = 1000;
% globalParams.pathIn = '.\Data\';
% globalParams.saved = '.\Saved\';
% globalParams.pathOut = '..\Reports\';
% globalParams.driversInfo = 'driversInfo.mat';
% globalParams.lineInfoMat = 'lineInfo.mat';
% globalParams.lineInfo = 'LineInfo.xlsx';
% globalParams.ECM_info = 'ECM_info.xlsx';
% 
% construct abstract params class
% GP = Params.instance(globalParams);

%====================
%run simulation
%RunAnalysis(GP);
%====================


%====================Start GUI====================
app = ecmRuntimeController.instance();
app.startGUI();
%===============================================
clear globalParams;
