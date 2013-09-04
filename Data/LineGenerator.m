load('..\Data\driversInfo.mat','driversInfo');%driversInfo
load('lineInfo');
LOBNames = lineInfo(:,1);
nLOB = length(LOBNames);
save_structure = false;
struct_array = false;


driverAYList=[];
driverCYList=[];
driverNameList = driversInfo(:,1);
driverTypeList = driversInfo(:,2);
for i=1:length(driverNameList)
    if(strcmp(driverTypeList{i}, 'AY'))
        driverAYList = [driverAYList driverNameList(i)];
    elseif(strcmp(driverTypeList{i}, 'CY'))
        driverCYList = [driverCYList driverNameList(i)];
    end
end

for iLOB = 2:nLOB
    %create nAY nFAY nCY
    %{
    nAY = 6+abs(round(norminv(rand,0,2)));  %6+sigma2
    nFAY = 3+abs(round(norminv(rand,0,0.5))); %3+sigma0.5
    duration = nAY+1+abs(round(norminv(rand,0,2))); %nAY+1+sigma2
    nCY = duration + nFAY-1;
    %}
    
    nAY = lineInfo{iLOB, 5};
    nFAY = lineInfo{iLOB, 6};
    nCY = lineInfo{iLOB, 7};
    yr0 = lineInfo{iLOB, 4};
    
    %construct betaAY
    nAYDrivers = length(driverAYList);
    nDrivers = ceil(rand*nAYDrivers);
    ix = randsample(nAYDrivers, nDrivers);
    betaAY = cell(nAY+nFAY+1, nDrivers+1);
    betaAY(1,2:end)=driverAYList(ix);
    core = repmat(rand(1, nDrivers)-0.5, [nAY+nFAY, 1]);
    %infuse the rand number
    betaAY(2:end, 2:end) = num2cell(core+rand(size(core))/10);
    betaAY(2:end,1) = num2cell([yr0-nAY+1:yr0+nFAY]);
    
    %construct betaCY
    nCYDrivers = length(driverCYList);
    nDrivers = ceil(rand*nCYDrivers);
    ix = randsample(nCYDrivers,nDrivers);
    betaCY = cell(nCY+1, nDrivers+1);
    betaCY(1,2:end)=driverCYList(ix);
    core = repmat(rand(1, nDrivers)-0.5, [nCY, 1]);
    %infuse the rand number
    betaCY(2:end, 2:end) = num2cell(core+rand(size(core))/10);
    betaCY(2:end,1) = num2cell([yr0:yr0+nCY-1]);
    
    %save
    lineInfo{iLOB, 2} = betaAY;
    lineInfo{iLOB, 3} = betaCY;
    
    %developPattern
    %{
    developmentPattern = zeros(nAY+nFAY, nCY);
    
    shapeScale = 5+abs((norminv(rand,0,5)));
    shape = shapeScale*lognpdf(1/duration:1/duration:1);
    for i=1:nAY
        shape = abs(shape + norminv(rand(1,duration),0,shapeScale/duration));
        shape = shape./sum(shape);
        developmentPattern(i,1:duration-nAY+i-1) = shape(1,2+nAY-i:duration);
    end
    
    for i=1:nFAY;
        shape = abs(shape + norminv(rand(1,duration),0,shapeScale/duration));
        shape = shape./sum(shape);
        developmentPattern(nAY+i, i:i+duration-1) = shape(1,:);
    end
    %volume
    %volume = zeros(nAY+nFAY, 1);
    volume = abs(norminv(rand(nAY+nFAY,1)))*100000+5000;
    
    %save info
    if(save_structure)
        %lineInfo = struct;
        if(struct_array) %struct array
            lineInfo(iLOB).name = LOBNames{iLOB};
            lineInfo(iLOB).betaAY = betaAY;
            lineInfo(iLOB).betaCY = betaCY;
            lineInfo(iLOB).nAY = nAY;
            lineInfo(iLOB).nFAY = nFAY;
            lineInfo(iLOB).nCY = nCY;
            lineInfo(iLOB).duration = duration;
            lineInfo(iLOB).developmentPattern = developmentPattern;
            lineInfo(iLOB).volume = volume;
        else %1*1 struct
            lineInfo.(['LOB' num2str(iLOB)]).name = LOBNames{iLOB};
            lineInfo.(['LOB' num2str(iLOB)]).betaAY = betaAY;
            lineInfo.(['LOB' num2str(iLOB)]).betaCY = betaCY;
            lineInfo.(['LOB' num2str(iLOB)]).nAY = nAY;
            lineInfo.(['LOB' num2str(iLOB)]).nFAY = nFAY;
            lineInfo.(['LOB' num2str(iLOB)]).nCY = nCY;
            lineInfo.(['LOB' num2str(iLOB)]).duration = duration;
            lineInfo.(['LOB' num2str(iLOB)]).developmentPattern = developmentPattern;
            lineInfo.(['LOB' num2str(iLOB)]).volume = volume;
        end
    else
        %lineInfo = cell(nLOB,9);
        lineInfo{iLOB,1} = LOBNames{iLOB};
        lineInfo{iLOB,2} = betaAY;
        lineInfo{iLOB,3} = betaCY;
        lineInfo{iLOB,4} = nAY;
        lineInfo{iLOB,5} = nFAY;
        lineInfo{iLOB,6} = nCY;
        lineInfo{iLOB,7} = duration;
        lineInfo{iLOB,8} = developmentPattern;
        lineInfo{iLOB,9} = volume;
    end
    %}
    
    
end
save('lineInfo', 'lineInfo', 'lineInfoTitle');
clear LOBNames betaAY betaCY LOBNames developmentPattern driverAYList driverCYList driverNameList driverTypeList driversInfo duration i iLOB ix nAY nAYDrivers nCY nCYDrivers nFAY nLOB save_structure shape shapeScale volume;
