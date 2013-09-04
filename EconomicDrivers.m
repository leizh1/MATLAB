% Class of Economic Driver. It contains all the parameters of a driver, and
% its methods includes load, create driver, and set, extend simulations.

classdef EconomicDrivers <handle
    %%
    properties(SetAccess = protected)
        name
        type %AY/CY
        simulation=[]
        rules %extending rules
        attributes
        nAY
        nFAY
        nCY
        yr0
    end
    %% static
    
    methods(Static)
        function driverArray=loadDrivers()
            GP = Params.instance();
            switch GP.driverLoadMode
                case GC.LOAD_MAT
                    load(GP.driversSource, 'driversInfo');
                    driversInfo(1,:)=[];
                    %create driver
                    driverArray = EconomicDrivers.createDrivers(driversInfo);
                case GC.LOAD_HDF5
                    info = h5info(GP.driversSource);
                    drivers = {info.Groups.Name};
                    driverArray = EconomicDrivers.createDrivers(drivers);
            end
        end
        
        function driverArray = createDrivers(driversInfo)
            driverArray = EconomicDrivers.empty(size(driversInfo,1),0);
            GP = Params.instance();
            if(size(driversInfo,1)==1)
                for i=1:length(driversInfo)
                    try
                        name=char(h5read(GP.driversSource, [driversInfo{i}, '/name']));
                        type = char(h5read(GP.driversSource, [driversInfo{i}, '/type']));
                        rules.extentionAY = char(h5read(GP.driversSource, [driversInfo{i}, '/rules/extentionAY']));
                        rules.extentionCY = char(h5read(GP.driversSource, [driversInfo{i}, '/rules/extentionCY']));
                        rules.extentionFAY = char(h5read(GP.driversSource, [driversInfo{i}, '/rules/extentionFAY']));
                        parameters.type = char(h5read(GP.driversSource, [driversInfo{i}, '/parameters/type']));
                        parameters.sigma = h5read(GP.driversSource, [driversInfo{i}, '/parameters/sigma']);
                        parameters.mu = h5read(GP.driversSource, [driversInfo{i}, '/parameters/mu']);
                        %parameters.alpha = h5read(GP.driversSource, [driversInfo{i}, '/parameters/alpha']);
                        %parameters.beta = h5read(GP.driversSource, [driversInfo{i}, '/parameters/beta']);
                        nAY = h5read(GP.driversSource, [driversInfo{i}, '/nAY']);
                        nFAY = h5read(GP.driversSource, [driversInfo{i}, '/nFAY']);
                        nCY = h5read(GP.driversSource, [driversInfo{i}, '/nCY']);
                        yr0 = h5read(GP.driversSource, [driversInfo{i}, '/baseYear']);
                    catch err
                        if(strcmp(err.identifier, 'MATLAB:imagesci:h5read:datasetDoesNotExist'))
                            warning(err.message);
                        else
                            rethrow(err);
                        end
                    end
                    %simulation = h5read(GP.driversPathHDF5, [driversInfo{i}, '/simulation']);
                    %create driver
                    driverArray(i) = EconomicDrivers(name);
                    driverArray(i).setParams(type , parameters, rules, yr0, nAY, nFAY, nCY);
                end
            else
                for i=1:size(driversInfo,1)
                    name=driversInfo{i, 1};
                    type = driversInfo{i,2};
                    rules = driversInfo{i,3};
                    attributes = driversInfo{i,4};
                    nAY = driversInfo{i,5};
                    nFAY = driversInfo{i,6};
                    nCY = driversInfo{i,7};
                    yr0 = driversInfo{i,8};
                    driverArray(i) = EconomicDrivers(name);
                    driverArray(i).setParams(type , attributes, rules, yr0, nAY, nFAY, nCY);
                end
            end
        end
    end
    
    %%
    methods
        function obj = EconomicDrivers(name)
            obj.name = name;            
        end
        %%
        function setParams(obj, type, ...
                attributes, rules, yr0, ...
                nAY, nFAY, nCY)
            obj.type = type;
            obj.attributes = attributes;
            obj.rules = rules;
            obj.yr0 = yr0;
            obj.nAY = nAY;
            obj.nFAY = nFAY;
            obj.nCY = nCY;
        end
        
        %% create simulation if not provided
        function simulation = get.simulation(obj)
            if(~isempty(obj.simulation))
                simulation = obj.simulation;
                return;
            end
            %get global params
            GP=Params.instance;
            if(GP.driverSimulationSource == GC.DRIVER_SIMULATION_GENERATE)
                %generate simulation
                if(obj.type ==GC.AY)
                    simulation = ones(GP.N, obj.nAY+obj.nFAY);
                    simulation(:, 1:obj.nAY) = repmat(norminv(rand(GP.N,1), obj.attributes.mu, obj.attributes.sigma), 1, obj.nAY);
                    for ifay = 1:obj.nFAY
                        simulation(:, obj.nAY+ifay) = norminv(rand(GP.N, 1), obj.attributes.mu, obj.attributes.sigma*ifay^0.5);
                    end
                elseif(obj.type == GC.CY)
                    simulation = ones(GP.N, obj.nCY);
                    for icy = 1:obj.nCY
                        simulation(:, icy) = norminv(rand(GP.N, 1), obj.attributes.mu, obj.attributes.sigma*icy^0.5);
                    end
                end
            elseif(GP.driverSimulationSource == GC.DRIVER_SIMULATION_LOAD)
                %load simulation
                load([GP.dataPath 'driversInfo.mat'], 'driversSimulation');
                [~, ix] = ismember(obj.name, driversSimulation(:,1));
                simulation = driversSimulation{ix,2};
                %truncate the size
                simulation = simulation(GP.N,:);
            else
                error('Driver simulation type error: define either Generate or Load in GC');
            end
            obj.simulation = simulation;
        end
        
        %% extend factor by rule
        function simulation = extendDriver(driver, line, simulation_, type)
            
            GP=Params.instance;
            simulation=simulation_;
            switch type
                case 'AY'
                    switch driver.rules.extentionAY
                        case 'copy'
                            simulation = [repmat(simulation(:,1),[1,line.nAY - driver.nAY]), simulation];
                        case 'simulation' % usually we don't simulate AY
                            simulation = [norminv(rand(GP.N, line.nAY - driver.nAY), driver.attributes.mu, driver.attributes.sigma), simulation];
                    end
                    driver.nAY = line.nAY;
                    extent = line.nAY - driver.nAY;
                case 'FAY'
                    switch driver.rules.extentionFAY
                        case 'copy'
                            simulation = [simulation, repmat(simulation(:,end),[1,line.nFAY - driver.nFAY])];
                        case 'simulation'
                            simulation = [simulation, ones(GP.N, line.nFAY-driver.nFAY)];
                            for ifay = driver.nFAY:line.nFAY
                                simulation(:, ifay) =  norminv(rand(GP.N, 1), driver.attributes.mu, driver.attributes.sigma*ifay^0.5);
                            end
                    end
                    driver.nFAY = line.nFAY;
                    extent = line.nFAY - driver.nFAY;
                case 'CY'
                    switch driver.rules.extentionCY
                        case 'copy'
                            simulation = [simulation, repmat(simulation(:,end),[1,line.nCY - driver.nCY])];
                        case 'simulation'
                            simulation = [simulation, ones(GP.N, line.nCY-driver.nCY)];
                            for icy = driver.nCY:line.nCY
                                simulation(:, icy) =  norminv(rand(GP.N, 1), driver.attributes.mu, driver.attributes.sigma*icy^0.5);
                            end
                    end
                    driver.nCY = line.nCY;
                    extent = line.nCY - driver.nCY;
            end
            driver.simulation = simulation;
            fprintf('Extended driver %s with %d %s. \n', driver.name, extent, type);
        end
        

        %%
        function set.type(obj, type)
            if(strcmp(type,'AY')||strcmp(type,'CY'))
                obj.type = type;
            else
                error('Driver type incorrect');
            end
        end
        
    end
    
end
