%Produce the disturbance matrix
classdef SystemRiskGenerator
    
    methods(Static)
        % Concrete implementation.  See Singleton superclass.
        function obj = instance()
            obj = SystemRiskGenerator();
        end
        
        function obj = SystemRiskGenerator()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new SystemRiskGenerator class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end

        %%
        %{
        function setFactorTable(obj, Drivers)
            if(obj.factorTable==0)
                %pool factors into an hash: name, obj
                obj.factorTable = cell2struct({Drivers(:).simulation}, {Drivers(:).name}, 1);
            end
        end
        %}
        %% Development pattern for BL
    
        function devPattern = combineDevelopmentPattern(BL)
            app = ecmRuntimeController.instance();
            LOBArray = app.LOBs;
            devPattern = zeros(BL.nAY+BL.nFAY, BL.nCY);
            
            for i = 1:size(BL.mapping)
                %location of each LOB related
                [~, loc] = ismember(BL.mapping(i,1), {LOBArray.name});
                %get LOB
                LOB = LOBArray(loc);
                %cashflow Matrix is calculated when needed
                tempDevPattern = LOB.developmentPattern;
                %AY
                if LOB.nAY<BL.nAY
                    tempDevPattern = [zeros(BL.nAY-LOB.nAY, LOB.nCY); tempDevPattern];
                end
                %FAY
                if LOB.nFAY<BL.nFAY
                    tempDevPattern = [tempDevPattern; zeros(BL.nFAY-LOB.nFAY,LOB.nCY)];
                end
                %CY
                if LOB.nCY < BL.nCY
                    tempDevPattern = [tempDevPattern, zeros(BL.nAY+BL.nFAY, BL.nCY-LOB.nCY)];
                end
                %combine
                devPattern = devPattern + tempDevPattern.*BL.mapping{i,2};
            end
        end
        
        function volume = combineVolume(BL)
            app = ecmRuntimeController.instance();
            LOBArray = app.LOBs;
            volume = zeros(BL.nAY+BL.nFAY, 1);
            
            for i = 1:size(BL.mapping)
                %get LOB
                [~, loc] = ismember(BL.mapping(i,1), {LOBArray.name});
                LOB = LOBArray(loc);
                %cashflow Matrix is calculated when needed
                tempVolume = LOB.volume;
                %AY
                if LOB.nAY<BL.nAY
                    tempVolume = [zeros(BL.nAY-LOB.nAY,1); tempVolume];
                end
                %FAY
                if LOB.nFAY<BL.nFAY
                    tempVolume = [tempVolume; zeros(BL.nFAY-LOB.nFAY,1)];
                end

                %combine
                volume = volume + tempVolume.*BL.mapping{i,2};
            end
        end
        
        %% factors
        function factorAY = synthesizeAY(line, Drivers) 
            %factor AY = beta1*factor1*beta2*factor2...            
            GP = Params.instance();
            factorAY = ones(GP.N, line.nAY+line.nFAY, 'single');
            driverNameList = {Drivers(:).name};
            for i=1:size(line.betaAY, 1)
                %get foctor simulation
                factorName = line.betaAY{i,1};
                [~, ix] = ismember(factorName, driverNameList);
                if(ix == 0)
                    error('Error: AY factor in line: %s is empty', line.name);
                end
                %trim factor to the same length of Line
                trimedFactorSim = SystemRiskGenerator.trimFactor(Drivers(ix), line);
                %calculation
                if(size(factorAY,2)>1 && size(factorAY,2)~= size(trimedFactorSim,2)) %check error
                    fprintf('line:[%d, %d]  betaAY: %d  factor:[%d, %d] \n',size(factorAY), line.betaAY{i,2}, size(trimedFactorSim));
                    error('dimention do not match');
                end
                beta = line.betaAY{i,2};
                factorAY = factorAY .* exp( beta .* trimedFactorSim);
                
            end
        end

        function factorCY = synthesizeCY(line, Drivers)
            GP = Params.instance; 
            %CY = beta1*factor1*beta2*factor2...
            factorCY = ones(GP.N, line.nCY, 'single');
            driverNameList = {Drivers(:).name};
            for i=1:size(line.betaCY, 1)
                [~, ix] = ismember(line.betaCY{i,1}, driverNameList);
                trimedFactor = SystemRiskGenerator.trimFactor(Drivers(ix), line);
                beta = abs(line.betaCY{i,2});
                factorCY = factorCY .* ((1+beta) .* trimedFactor);
            end
        end

        %%
        function trimedFactor = trimFactor(factor, line)
            GP = Params.instance;
            %find the starting and ending point of the data by line
            simulation=factor.simulation;
            switch factor.type
                %<------AY------>
                case 'AY'
                    if(factor.nAY >= line.nAY)
                        YrBeg = 1 + factor.nAY - line.nAY;
                    else
                        %AY
                        simulation = factor.extendDriver(line, simulation, 'AY');
                        YrBeg = 1;
                    end
                    
                    if(factor.nFAY >= line.nFAY)
                        %use line's nAY
                        YrEnd = max([line.nAY, factor.nAY])+line.nFAY;
                    else
                        %FAY
                        simulation = factor.extendDriver(line, simulation, 'FAY');
                        YrEnd = max([line.nAY, factor.nAY])+line.nFAY;
                    end
                %<------CY------>    
                case 'CY'
                    if(factor.nCY >= line.nCY)
                        YrBeg = 1;
                        YrEnd = line.nCY;
                    else
                        simulation = factor.extendDriver(line, simulation, 'CY');
                        YrBeg = 1;
                        YrEnd = line.nCY;
                    end
                otherwise
                    error('factor type undefined');
            end

            %truncate the simulation
            trimedFactor = simulation(1:GP.N,YrBeg:YrEnd);

        end
        %% cashflow
        function cashflowMatrix = getCashflowMatrix(LOB)
            %determine if it is BL
            if(isa(LOB, 'BudgetLine'))
                cashflowMatrix = 0; %BL shouldn't call this function
                return
            end
            
           disturbanceMatrix = LOB.disturbanceMatrix;
           [a b c] = size(disturbanceMatrix);
           cashflowMatrix = repmat(LOB.developmentPattern, [1,1,c]) .* ...
                                  disturbanceMatrix .* ...
                                  repmat(LOB.volume, [1, b, c]);
           
        end
        %% disturbance matrix
        function disturbanceMatrix = getDisturbanceMatrix(LOB)
            if(isa(LOB, 'BudgetLine'))
                disturbanceMatrix = 0; %for LOB only
                return
            end
            
            GP = Params();
            dimAY = size(LOB.factorAY,2);
            dimCY = size(LOB.factorCY,2);
            dMatrix = ones(dimAY, dimCY, GP.N, 'single');
            
            %=============skip if systematic risk mode is set to 0=========
            if(GP.systematicRiskMode == 0)
                disturbanceMatrix = dMatrix + rand(size(dMatrix))/1000;
                disturbanceMatrix = disturbanceMatrix .* repmat(LOB.developmentPattern~=0, [1,1,GP.N]);
                return;
            end
            %=============skip if systematic risk mode is set to 0=========
            
            
            %calculation
            %fprintf('Calculating line %s:', obj.name);
            %tic
            if (GP.compressionMode == GC.CompressedMode)
                 compressedMatrix = zeros(length(LOB.key), GP.N, 'single');
                 for j=1:GP.N
                    tempMatrix = LOB.developmentPattern .* ((LOB.factorAY(j,:))' * (LOB.factorCY(j,:)));
                    compressedMatrix(:,j) = tempMatrix(LOB.key);
                 end
                 disturbanceMatrix = compressedMatrix;
            else % normal mode
                for k=1:GP.N
                    dMatrix(:,:,k)  = ((LOB.factorAY(k,:))' * (LOB.factorCY(k,:)));
                end
                disturbanceMatrix = dMatrix;
            end
            %toc
        end
        
        %% Combine cashflow from LOB to given BL
        function forcastedCF = combineCashflow(BL)
            lineFactory = LineFactory();
            LOBArray = lineFactory.LOBArray;
            GP = Params.instance();
            fprintf('Calculating BL cashflow: %s: \n', BL.name);
            forcastedCF = zeros(BL.nAY+BL.nFAY, BL.nCY, GP.N);
            tic
            for i = 1:size(BL.mapping,1)
                %location of each LOB related
                [~, loc] = ismember(BL.mapping(i,1), {LOBArray.name});
                %get LOB
                LOB = LOBArray(loc);
                %cashflow Matrix is calculated when needed
                tempCashflow = LOB.cashflowMatrix;
                %AY
                if LOB.nAY<BL.nAY
                    tempCashflow = [zeros(BL.nAY-LOB.nAY, LOB.nCY, GP.N); tempCashflow];
                end
                %FAY
                if LOB.nFAY<BL.nFAY
                    tempCashflow = [tempCashflow; zeros(BL.nFAY-LOB.nFAY,LOB.nCY, GP.N)];
                end
                %CY
                if LOB.nCY < BL.nCY
                    tempCashflow = [tempCashflow, zeros(BL.nAY+BL.nFAY, BL.nCY-LOB.nCY, GP.N)];
                end
                %combine
                forcastedCF = forcastedCF + tempCashflow.*BL.mapping{i,2};
            end
            toc
            fprintf('===========================\n');
        end
        

    end
    
    
end
        
