load('..\Data\driversInfo.mat','driversInfo', 'driversInfoTitle');
nDriver = size(driversInfo,1);
driversSimulation = cell(nDriver,4);
rules = struct;
parameters = struct;

for i=1:nDriver
    driversSimulation{i,1}=driversInfo{i, 1}; %name
    type = driversInfo{i,2};
    nAY = driversInfo{i,5};
    nFAY = driversInfo{i,6};
    nCY = driversInfo{i,7};
    %simulation generation
    if(type=='AY')
        %driversSimulation{i,2} = norminv(rand(1000000,nAY+nFAY), mu, sigma);
    elseif(type == 'CY')
        %driversSimulation{i,2} = norminv(rand(1000000,nCY), mu, sigma);
    end
    %make rules
    rules.extentionAY = 'copy';
    rules.extentionFAY = 'copy';
    rules.extentionCY = 'copy';
    driversInfo{i,3} = rules;
    %parameter
    parameters.mu = driversInfo{i,4}.mu;
    parameters.sigma = driversInfo{i,4}.sigma;
    parameters.type = 'normal'
    driversInfo{i,4} = parameters;
end

save('..\Data\driversInfo.mat','driversInfo', 'driversInfo', 'driversInfoTitle', 'driversSimulation');
clear nDriver names;
