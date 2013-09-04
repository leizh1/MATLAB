dbstop if error;
GP = Params;
lineFactory = LineFactory();
app = ecmRuntimeController();
GP.lineInfo = '.\Data\lineInfoTest.mat';
GP.steadyStage = 1;
%customize map info
[~, ~, mapInfo] = xlsread(GP.ECM_info,'Weights_new');
mapInfo(1,:) = [];
mapInfo(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),mapInfo)) = {''};
%create lob
LOBs = lineFactory.createLOBs(lineFactory.lineInfo, mapInfo);
app.Drivers = EconomicDrivers.loadDrivers();
LOBs(1).modelRef;
%plot
GP.figure = figure;
for i=1:size(lineFactory.lineInfo, 1)
    LOB = LOBs(i);
    %change corr when flag =1
    if(i==1 || i==3)
        LOB.setCorr(0.5);
    end
    display(['Correlation for LOB:' mat2str(LOB.ID) ' is ' mat2str(LOB.corr)]);
    fhandle = figure; %new figure
    ahandle = gca;
    
    %param risk
    pm = LOB.paramDist;
    aggregatedDist = sum(pm,1)./sum(pm>0); %exclude 0
    ReportModule.displayAggregatedCashflowBySurf(aggregatedDist, ahandle);
    set(fhandle, 'Name', mat2str(LOB.ID));
    
    %idio risk
%     idioDist = LOB.idioDist;
%     aggregatedDist = sum(idioDist,1)./sum(idioDist>0); %exclude 0
%     ReportModule.displayAggregatedCashflowBySurf(aggregatedDist, ahandle);
%     set(fhandle, 'Name', mat2str(LOB.ID));
    %pause
end
