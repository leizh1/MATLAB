%A general class that holds informatino for a BL or a LOB

classdef Line < handle
    properties (SetAccess = protected, GetAccess = public)
        name
        ID = 0
        parents %mapped BLs
        nAY = 0 %length of AY
        nFAY = 0 %length of FAY including 0 year
        nCY = 0 %max CY
        compressionMode
        yr0
        
        %structural driver
        betaAY %factor exposures, memoryless
        betaCY %factor exposures, memoryless
        xAY %factor base
        xCY %factor base
        payoutPattern % steady state payout pattern
        developmentPattern %memoryless
        developmentPatternNum %numerical development pattern, memoryless
        triangle %the whole triangle containing both devPattern and histTriangle, in percentage term
        
%         payoutPattern %stedy stage PP in percentage term
%         expectedLoss %FAY1 dollar loss
        baseForecast %fiitted triangle by GLM, in percentage term
        trending %scale down factor in SS
        volume %real cash base
        expLoss %expected loss for next year
        duration %development pattern length on by AY
        
        %output
        disturbanceMatrix %memoryless
        cashflowMatrix %memorized
        
        %parameter risk
        credibilityFactor %credibility factor
        corr %correlation with ARMS reference model
        paramDist %parameter distribution
        paramSim %parameter risk simulation from ARMS
        modelRef %handle of the model referenced
        modelRefName
        volumeRef
        ARMSFlag
        historicalTriangle
        
        %discount factor
        currency
        country
        discountTable
        discountMode %local discount mode for LOB
        
        %idiosyncratic risk
        idioDist %idio risk distribution
        k
        p
    end

    properties 
        key %compression pattern
        factorAY %aggregated factor exposure, memoryless
        factorCY %aggregated factor exposure, memoryless
        analytics %statistic numbers for analysis
    end
    
    
    %%
    methods
        %% constructor
        function obj = Line(name )
            if(nargin>0)
                obj.name = name;
            end
            %search for name_ID
        end
        
        %% set pamaters
        function setParam(obj, ID, betaAY, betaCY, nAY, nFAY, nCY, duration, yr0, ... %basic information
                volume, developmentPattern, historicalTriangle, triangle, ... %triangle and pattern
                parents, ARMSFlag, expLoss, credibilityFactor,... %parameter risk
                p, k) %idiosyncratic risk
            %set parameters for each line
            %[~, obj.line_ID] = ismember(obj.name, lineInfo(:,1));
            %[~, ix] = ismember(obj.name, lineInfo(:,1));
            obj.ID = ID;
            obj.betaAY = betaAY;
            obj.betaCY = betaCY;
            obj.nAY = nAY;
            obj.nFAY = nFAY;
            obj.nCY = nCY;
            obj.yr0 = yr0;
            obj.duration = duration;
            obj.volume=volume;
            obj.developmentPattern = developmentPattern;
            obj.parents = parents;
            obj.historicalTriangle = historicalTriangle;
            obj.ARMSFlag = ARMSFlag;
            obj.expLoss = expLoss;
            obj.credibilityFactor = credibilityFactor;
            obj.triangle = triangle;
            obj.p = p;
            obj.k = k;
        end
        
        function updateParams(obj, lobObj)
%             obj.ID = lobObj.ID;
%             obj.betaAY = lobObj.betaAY;
%             obj.betaCY = lobObj.betaCY;
%             obj.nAY = lobObj.nAY;
%             obj.nFAY = lobObj.nFAY;
%             obj.nCY = lobObj.nCY;
%             obj.yr0 = lobObj.yr0;
%             obj.duration = lobObj.duration;
%             obj.volume = lobObj.volume;
%             obj.developmentPattern = lobObj.developmentPattern;
%             obj.parents = lobObj.parents;
%             obj.historicalTriangle = lobObj.historicalTriangle;
%             obj.ARMSFlag = lobObj.ARMSFlag;
%             obj.expLoss = lobObj.expLoss;
%             obj.credibilityFactor = lobObj.credibilityFactor;
%             obj.triangle = lobObj.triangle;
%             obj.p = lobObj.p;
%             obj.k = lobObj.k;
            fieldList = fieldnames(lobObj);
            for i=1:length(fieldList)
                field = fieldList{i};
                obj.(field) = lobObj.(field);
            end
        end
     
        %% developPattern
        function set.developmentPattern(obj, pmtPattern)
            %check integrety of pmtPattern
            %TODO: get nAY, nFAY, nCY, key
            %sum(pmtPattern(i,:))=1
            
            %Can take both cell and mat format as input
            if(iscell(pmtPattern))
                pmtPattern = cell2mat(pmtPattern);
            end
            obj.developmentPattern = pmtPattern;
            obj.key = int16(find(pmtPattern));
        end
        
        function numericalPattern = get.developmentPatternNum(obj)
%             if(isempty(obj.developmentPatternNum))
            numericalPattern = obj.developmentPattern.* repmat(obj.volume, 1, obj.nCY);
            obj.developmentPatternNum = numericalPattern;
%             else
%                 numericalPattern = obj.developmentPatternNum;
%             end
        end
        
        function devPattern = get.developmentPattern(obj)
            if(isa(obj, 'BudgetLine'))
                if(size(obj.developmentPattern)==[obj.nAY+obj.nFAY, obj.nCY]) %if exsits
                    devPattern = obj.developmentPattern;
                else
                    devPattern = SystemRiskGenerator.combineDevelopmentPattern(obj); %combine
                    obj.developmentPattern = devPattern;
                end
                return;
            end
            
            % the caller is LOB
            GP = Params();
            devPattern = obj.developmentPattern;
        end

   
        %% clean memory
        function clean(obj)
            obj.factorAY = [];
            obj.factorCY = [];
            obj.cashflowMatrix = [];
            obj.disturbanceMatrix = [];
        end

         %% set developmentLength
        function set.duration(obj, duration)
            if(length(duration)==obj.nAY+obj.nFAY)
                obj.duration = duration;
            elseif(length(duration)==1)
                %simple expend th
                obj.duration = ones(obj.nAY+obj.nFAY,1)*duration;
            elseif(isempty(duration)) 
                %duration is 0 when steady stage
                obj.duration = length(obj.payoutPattern);
            else
                error('Incorrect developmentLength: length does not equal to nAY+nFAY or 1');
            end
        end
        
         %% volume
        function set.volume(obj, volume)
            if(length(volume)==obj.nAY+obj.nFAY)
                obj.volume = volume;
            elseif(length(volume)==1)
                %expend the volume in SS
                obj.volume = ones(obj.nAY+obj.nFAY,1)*volume;
            else
                error('Incorrect volume: length does not equal to nAY+nFAY or 1');
            end
        end
        
        %% get dependent Cashflow Matrix
        function cashflow = get.cashflowMatrix(LOB)
            GP = Params();
            if(size(LOB.cashflowMatrix,3) == GP.N)
                cashflow = LOB.cashflowMatrix;
                return;
            end
            
            fprintf('Loading: %s\n', LOB.name);
            cashflow = SystemRiskGenerator.getCashflowMatrix(LOB);
            
            %==============apply discount rate===================
            if(GP.discountMode)
                cashflow = cashflow .* LOB.discountTable;
                display('Discount applied');
            end
            %==============apply param risk===================
            if(GP.parameterRiskMode)
                cashflow = cashflow .* LOB.paramDist;
                display('Parameter risk applied');
            end
            
            
            LOB.cashflowMatrix = cashflow; %memorized
        end
        
         %% get dependent disturbanceMatrix Matrix
        function disturbanceMatrix = get.disturbanceMatrix(LOB)
            %global mode
            LOB.compressionMode = GC.NormalMode;
            %calculation is handled by SystemRiskGenerator
            disturbanceMatrix = SystemRiskGenerator.getDisturbanceMatrix(LOB);
        end
        
            %% get factor AY and CY
            function factorAY = get.factorAY(LOB)
                if(~isempty(LOB.factorAY))
                    factorAY = LOB.factorAY;
                end
                GP = Params.instance;
                app = ecmRuntimeController.instance();
                if (size(LOB.factorAY,1) == GP.N) %determin if factorAY is exactly what needed
                    factorAY = LOB.factorAY;
                elseif(ECMIO.factorsNeedGenerate(LOB)) %determine if factor needs to be reload
                    factorAY = SystemRiskGenerator.synthesizeAY(LOB, app.Drivers);
                    LOB.factorAY = factorAY;
                end
                
                %factor should be loaded by factorsNeedGenerate method
                %check if loaded correctly
                
                if(size(factorAY,1) < GP.N)
                    error('Error loading factor AY for LOB: %s', LOB.name');
                end
                
            end
            
            function factorCY = get.factorCY(LOB)
                if(~isempty(LOB.factorCY))
                    factorCY = LOB.factorCY;
                end
                GP = Params.instance;
                app = ecmRuntimeController.instance();
                if (size(LOB.factorCY,1) == GP.N)
                    factorCY = LOB.factorCY;
                elseif(ECMIO.factorsNeedGenerate(LOB))
                    factorCY = SystemRiskGenerator.synthesizeCY(LOB, app.Drivers);
                    LOB.factorCY = factorCY;
                end
                %check if loaded correctly
                if(size(factorCY,1) < GP.N)
                    error('Error loading factor CY for LOB: %s', LOB.name');
                end
            end
            
            %% yr0
            function yr0 = get.yr0(obj)
               if(isempty(obj.yr0))
                   %time = clock;
                   %yr0 = time(1);
                   GP = Params.instance();
                   yr0=GP.yr0;
               else
                   yr0=obj.yr0;
               end
            end
            
            
            %% volume for BL
            function volume = get.volume(obj)
                if(isa(obj, 'BudgetLine'))
                    if(size(obj.volume,1)==obj.nAY+obj.nFAY)
                        volume = obj.volume;
                    else
                        volume = SystemRiskGenerator.combineVolume(obj);
                        obj.volume = volume;
                    end
                else
                    volume = obj.volume;
                end
            end
            
            %% SSPP
            function SSPP = get.payoutPattern(obj)
                prm = ParameterRiskModule();
                SSPP = prm.paramDataset{obj.name, 'PayoutPattern'};
            end
            
            %% discountFactor
            %get discountTable that will be used for calculation
            %not catched, to save memory
            function dt = get.discountTable(obj)
%                 if(~isempty(obj.discountTable))
%                     dt = obj.discountTable;
%                     return;
%                 end
                
                GP = Params();
                dt = ones(obj.nAY+obj.nFAY, obj.nCY, GP.N);

                 %rate to discount factor
                 for i = 1:obj.nCY
                     discounts = (1./(1+obj.getRate(i))).^i;
                     if(GP.N < size(discounts,2))
                         dt(1,i,:) = discounts(1:GP.N);
                     else
                         multiplier = ceil(GP.N/size(discounts,2));
                         discounts = repmat(discounts, multiplier);
                         dt(1,i,:) = discounts(1:GP.N);
                     end
                 end
                 %expend discounts
                 dt(2:end,:,:) = repmat(dt(1,:,:), [size(dt,1)-1, 1, 1]);
                 if(~GP.discountMode)
                     dt = repmat(dt,[1,1,GP.N]);
                 end
            end
            
            %% get rates
            function df = getRate(obj, tenor)
                app = ecmRuntimeController();
                GP = Params();
                
                %change tenor to char
                if(~ischar(tenor))
                    if(~isinteger(tenor))
                        tenor = int8(tenor);
                    end
                    tenor = [num2str(tenor), 'Y'];
                end
                
                %load from app.curves
                try
                    df = app.rateModule.curves{tenor, obj.currency};
                catch err
                    if(strcmp(err.identifier, 'stats:dataset:getobsindices:UnrecognizedObsName'))
                        %fit/extend the curve
                        warning(err.message);
                        %obj.createObs(tenor);
                        %obj.fitCurve(tenor);
                        df = 0;
                    else
                        rethrow(err);
                    end
                    
                end
                
                %fit the curve
                if(df==0)
                    obj.fitCurve(tenor);
                    df = app.rateModule.curves{tenor, obj.currency};
                end
            end
            
            function fitCurve(obj, tenor)
                app = ecmRuntimeController();
                yr = str2num(tenor(1:end-1));
                
                %create the obs
%                 obs = get(app.rateModule.curves, 'ObsNames');
%                 if(~ismember(tenor, obs))
%                     obj.createObs(tenor);
%                 end
                
                %find the value before
                np = obj.findNextValue('Precede', yr);
                
                %find n value after
                nf = obj.findNextValue('Forward', yr);
                if(nf==0)
                    %no future value, interplate by last two
                    df_2 = obj.getRate(yr-2);
                    df_1 = obj.getRate(yr-1);
                    df = 2*df_1-df_2;
                    
                elseif(nf>0 && np>0)
                    %find the intecepted value
                    df_p = obj.getDiscountFactor(yr-np);
                    df_f = obj.getDiscountFactor(yr+nf);
                    df = df_p + (df_f-df_p)/(np+nf)*np;
                else
                    error('error fitting curve: unexpected situation');
                end
                
                %apply calculated value
                if(~isscalar(df)) %check dimention
                    tmp(1,1,:) = df;
                    df = tmp; tmp=[];
                end
                ds = cell2dataset(['var'; num2cell(df, 3)]);
                app.rateModule.curves(tenor, obj.currency) = ds;
                display(['Currency curve ' obj.currency ' has been interpreted for tenor ' tenor]);
            end
            
            function cu = get.currency(obj)
                GP = Params();
                %legacy mode read by country
                if(~GP.stochasticRate)
                    cu = obj.country;
                    return;
                end
                %catched
                if(~isempty(obj.currency))
                    cu = obj.currency;
                    return;
                end
                
                app = ecmRuntimeController();
                [~, loc] = ismember(obj.name, app.rateModule.currencyMap);
                if(loc)
                    cu = app.rateModule.currencyMap{loc, 5};
                    obj.currency = cu;
                else
                    error(['No currency for LOB: ' obj.name]);
                end
            end
            
            function cn = get.country(obj)
                if(~isempty(obj.country))
                    cn = obj.country;
                    return;
                end
                
                app = ecmRuntimeController();
                [~, loc] = ismember(obj.name, app.rateModule.currencyMap);
                if(loc)
                    cn = app.rateModule.currencyMap{loc, 3};
                    obj.country = cn;
                else
                    error(['No country info found for LOB:' obj.name]);
                end
            end
            
            
            function n = findNextValue(obj, direction, yr, val)
                %find the next value that is not empty
                if(nargin==3)
                    val=0;
                end
                app = ecmRuntimeController();
                maxN = max([app.LOBs.nCY]); %max n can go
                %curve = app.rateModule.curves.(obj.currency);
                
                for n= 1 : maxN
                    if(strcmp(direction, 'Precede'))
                            tenor = [num2str(yr-n) 'Y'];
                        elseif(strcmp(direction, 'Forward'))
                            tenor = [num2str(yr+n) 'Y'];
                    end
                    
                    try %search for val
                        df = app.rateModule.curves{tenor, obj.currency};
                    catch err
                        %if backwards, create obs if needed, assuming the first obs exsits
                        if(strcmp(err.identifier, 'stats:dataset:getobsindices:UnrecognizedObsName'))
                            %warning(err.message);
                            
                            if((yr+n) > maxN)
                                %if the obs is exceeding the nCY limit,
                                %return zero indicating no future
                                %referencing value
                                n=0;
                                return; %this is the point that the search ends
                            else
                                %create the obs
                                %obj.createObs(tenor);
                                df = 0;
                            end
                        else
                            rethrow(err);
                        end
                    end
                    %if value is not 0, return n
                    if(df ~= val) %works for array too
                        return
                    end
                end

            end
            
%             function createObs(obj, tenor, val)
%                 if(nargin == 2)
%                     val = 0; %not using now
%                 end
%                 app = ecmRuntimeController();
%                 varNames = get(app.rateModule.curves, 'VarNames');
%                 curveNew = cell2dataset(...
%                     [varNames; num2cell(zeros(1, length(varNames), app.rateModule.nRate),3)],...
%                     'ObsNames', tenor);
%                 app.rateModule.curves = [app.rateModule.curves; curveNew];
%                 display(['Created new observation: ' tenor ' for curve: ' obj.currency])
%             end
                
            %this function is obsolete
%             function setDiscountMode(obj, mode)
%                 if(ischar(mode))
%                     switch mode
%                         case 'on'
%                             mode = 1;
%                         case 'On'
%                             mode = 1;
%                         case 'off'
%                             mode = 0;
%                         case 'Off'
%                             mode = 0;
%                     end
%                 end
%                 obj.discountMode = mode;
%             end

            %% Parameter risk
            function PD = get.paramDist(obj)
                GP = Params();
                if(isempty(obj.paramSim))
                    parameterRiskModule = ParameterRiskModule();
                    sim = parameterRiskModule.getParamSim(obj);
                    obj.paramSim = sim;
                else
                    %param simulation is stored in memory
                    sim = obj.paramSim;
                end
                
                PD = zeros(size(sim,1), size(sim,2), GP.N);
                %expend to sim size
                if(size(sim, 3) >= GP.N)
                    PD = sim(:,:,1:GP.N);
                else
                    n = ceil(GP.N./ size(sim, 3));
                    sim = repmat(sim, [1,1,n]);
                    PD = sim(:,:,1:GP.N);
                end
                
                %fit AY CY
                if(size(PD,1)<(obj.nAY+obj.nFAY))
                    PD=[PD; zeros((obj.nAY+obj.nFAY)-size(PD,1), size(PD,2), GP.N)];
                end
                if(size(PD,2)<obj.nCY)
                    PD=[PD, zeros(size(PD,1), obj.nCY-size(PD,2),  GP.N)];
                end
                PD = PD(1:(obj.nAY+obj.nFAY), 1:obj.nCY, :);
            end
            
            %% modelRef
            function modelRef = get.modelRef(obj)
                if(~isempty(obj.modelRef))
                    modelRef = obj.modelRef;
                    return;
                end
                armsBridge = ARMSBridge();
                modelRef = armsBridge.getModelByName(obj.modelRefName);
                %obj.modelRef = modelRef;
            end
            
            %model ref name
            function modelRefName = get.modelRefName(obj)
                parameterRiskModule = ParameterRiskModule();
                modelRefName = parameterRiskModule.paramDataset{obj.name, 'ARMS_Reference'};
            end
            
            %volume ref
            function volume = get.volumeRef(obj)
                parameterRiskModule = ParameterRiskModule();
                volume = parameterRiskModule.getVolumeReference(obj);
            end
            
            %% data structure
            %credibility factor
            function cf = get.credibilityFactor(obj)
                if(~isempty(obj.credibilityFactor))
                    cf = obj.credibilityFactor;
                    return;
                end
                parameterRiskModule = ParameterRiskModule();
                cf = parameterRiskModule.paramDataset{obj.name, 'CredibilityStandard'};
                obj.credibilityFactor = cf;
            end
            
            function flag = get.ARMSFlag(obj)
                if(~isempty(obj.ARMSFlag))
                    flag = obj.ARMSFlag;
                    return;
                end
                parameterRiskModule = ParameterRiskModule();
                flag = parameterRiskModule.paramDataset{obj.name, 'ARMSFlag'};
                obj.ARMSFlag = flag;
            end
            
            function c = get.corr(obj)
                if(~isempty(obj.corr))
                    c = obj.corr;
                    return
                end
                
                if(obj.ARMSFlag)
                    vol = obj.volumeRef;
                    vol2 = obj.modelRef.volumeRef;
                    obj.corr = (vol/vol2)^0.5;
                else
                    obj.corr = 0;
                end
                
                c = obj.corr;
            end
            
            function setCorr(obj, c)
                obj.corr = c;
            end
            
            function t = get.trending(obj)
                GP = Params();
                t = GP.trending;
            end
            
            %% idiosyncratic
            function id = get.idioDist(obj)
                if(~isempty(obj.idioDist))
                    id = obj.idioDist;
                    return
                end
                irm = idiosyncraticRiskModule();
                id = irm.getIdioDist(obj);
                obj.idioDist = id;
            end
    end
    
end
