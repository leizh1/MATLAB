function lineFactory = initiation(GP)
%% Import external data
%economic drivers
load([GP.pathIn GP.driversInfo], 'driversInfo');  %need to be changed to excel format
%line
load([GP.pathIn GP.lineInfoMat], 'lineInfo');
%excel format
%{
ECMIO.loadLineInfo([GP.pathIn GP.lineInfo]);

LOBNames(1)=[];
lineInfo = cell(length(LOBNames),9); %empty lineInfo
for i=1:length(LOBNames)
    [~, ~, LOBInfo] = xlsread([GP.pathIn GP.lineInfo],i+1,'A2:G2');
    [~, ~, betaAY] = xlsread([GP.pathIn GP.lineInfo],i+1,['betaAY' num2str(i)]);
    [~, ~, betaCY] = xlsread([GP.pathIn GP.lineInfo],i+1,['betaCY', num2str(i)]);
    [~, ~, pattern] = xlsread([GP.pathIn GP.lineInfo],i+1,['pattern', num2str(i)]);
    lineInfo(i,:) = [LOBInfo{2}, {betaAY}, {betaCY}, LOBInfo{1,3:6}, {pattern}, LOBInfo{7}];
end
%}
%BL
[~, ~, BLInfo] = xlsread([GP.pathIn GP.ECM_info],'BL');
BLInfo(1,:) = [];
BLInfo(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),BLInfo)) = {''};
%mapping
[~, ~, mapInfo] = xlsread([GP.pathIn GP.ECM_info],'Weights');
mapInfo(1,:) = [];
mapInfo(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),mapInfo)) = {''};

%% create drivers
Drivers = EconomicDrivers.createDrivers(driversInfo);

%% LOBs construction
nLOB = size(lineInfo,1);
lineFactory = LineFactory.instance();
LOBs = lineFactory.createLOBs(lineInfo, mapInfo);

%% BL construction
BLs = lineFactory.createBudgetLine(BLInfo);
lineFactory.applyMapping(BLs);

end
