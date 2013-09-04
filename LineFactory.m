% Produce LOB and BL objects

classdef LineFactory < Singleton
    properties
        lineInfo
        BLInfo
        mapInfo
        LOBArray %= Line.empty() %pointer to LOB array
        BLArray %=BudgetLine.empty() %pointer to BL array
        BLGroups %Group BL array 
        currencyMap %Currency mapping table for LOB
        triangleInfo %triangle info sheet
    end
    
    methods(Static)
        
        %% Concrete implementation.  See Singleton superclass.
        function obj = instance()
            obj = LineFactory();
        end
        
        function obj = LineFactory()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating the lineFactory object');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
    end
    
    methods
        %% getter for properties
        %map info
        function mapInfo = get.mapInfo(obj)
            if(~isempty(obj.mapInfo))
                mapInfo = obj.mapInfo;
                return;
            end
            app = ecmRuntimeController();
            GP = Params();
            %app.statusUpdate('Loading Mapping');
            [~, ~, mapInfo] = xlsread(GP.ECM_info,'Weights_new');
            mapInfo(1,:) = [];
            mapInfo(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),mapInfo)) = {''};
            obj.mapInfo = mapInfo;
        end
        
        %line
        function lineInfo = get.lineInfo(obj)
            if(~isempty(obj.lineInfo))
                lineInfo = obj.lineInfo;
                return;
            end
            app = ecmRuntimeController();
            GP = Params();
            app.statusUpdate('Loading LOB data');
            load(GP.lineInfo, 'lineInfo');
            lineInfo(1,:)=[];
            obj.lineInfo = lineInfo;
        end
        
        %BL
        function BLInfo = get.BLInfo(obj)
            if(~isempty(obj.BLInfo))
                BLInfo = obj.BLInfo;
                return;
            end
            app = ecmRuntimeController();
            GP = Params();
            app.statusUpdate('Loading BL');
            [~, ~, BLInfo] = xlsread(GP.ECM_info,'BL');
            BLInfo(1,:) = [];
            BLInfo(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),BLInfo)) = {''};
            obj.BLInfo = BLInfo;
        end
        
        %% Line of Business
        function LOBArray = createLOBs(obj, lineInfo, mapInfo)
            GP = Params.instance;
            if(nargin==2)
                mapInfo = obj.mapInfo;
            elseif(nargin==1)
                mapInfo = obj.mapInfo;
                lineInfo = obj.lineInfo;
            end
            app = ecmRuntimeController();
            LOBArray = Line.empty(size(lineInfo,1),0);
            %load triangle data?
            %loadTriangle =1;
            %flush triangle data into mat file?
            saveTriangle = 1;
            obj.lineInfo = lineInfo;
            obj.mapInfo = mapInfo;
            
            
            for ix = 1:size(lineInfo,1)
                %try to read data from Line Info first
                if(isa(lineInfo, 'struct')) %read from excel
                    % for legacy competability
                    name = lineInfo.(['LOB', num2str(ix)]).name;
                    app.statusUpdate(['Creating LOB: ', name]);
                    LOB=Line(name);
                    betaAY = lineInfo.(['LOB', num2str(ix)]).betaAY;
                    betaCY = lineInfo.(['LOB', num2str(ix)]).betaCY;
                    nAY = lineInfo.(['LOB', num2str(ix)]).nAY;
                    nFAY = lineInfo.(['LOB', num2str(ix)]).nFAY;
                    nCY = lineInfo.(['LOB', num2str(ix)]).nCY;
                    duration = lineInfo.(['LOB', num2str(ix)]).duration;
                    volume=lineInfo.(['LOB', num2str(ix)]).volume;
                    developmentPattern = lineInfo.(['LOB', num2str(ix)]).developmentPattern;
                    parents = obj.setParents(LOB, mapInfo);
                    ARMSFlag;
                    expLoss;
                    CredibilityFactor;
                    ARMSRef;
                    historicalPattern;
                elseif(isa(lineInfo, 'cell')) %read from mat
                    
                    name = lineInfo{ix, 1};
                    app.statusUpdate(['Creating LOB: ', name]);
                    LOB=Line(name);
                    betaAY = lineInfo{ix, 2};
                    betaCY = lineInfo{ix, 3};
                    yr0 = lineInfo{ix, 4};
                    nAY = lineInfo{ix, 5};
                    nFAY = lineInfo{ix, 6};
                    nCY = lineInfo{ix, 7};
                    duration = lineInfo{ix, 8};
                    developmentPattern = lineInfo{ix, 9};
                    historicalPattern = lineInfo{ix, 10};
                    volume=lineInfo{ix, 11};
                    parents = obj.setParents(LOB, mapInfo);
                    ARMSFlag = lineInfo{ix, 12};  %changed
                    expLoss = lineInfo{ix, 13}; %changed
                    CredibilityFactor = lineInfo{ix, 14}; %changed
                    ARMSRef = lineInfo{ix, 15}; %model name
                    triangle = lineInfo{ix, 16};
                    p = lineInfo{ix, 17};
                    k = lineInfo{ix, 18};
                end
                
                %if some info are NA, try to get it from other sources
                %triangle extraction 
                if(isempty(triangle))
                    if(GP.steadyStage)
                        %get from steady stage
                        SSPP = LOB.payoutPattern;
                        trend = LOB.trending;
                        %apply nAY nFAY nCY into SS
                        [developmentPattern, historicalPattern, volume, triangle, nAY, nFAY, nCY] =...
                            obj.getTriangleByPayoutPattern(SSPP, nAY, nFAY, nCY, expLoss, trend);
                    else
                        %get trangle from excel in NSS
                        [developmentPattern, historicalPattern, volume, nAY, nFAY, nCY, triangle] =...
                            obj.getTriangleFromExcel(LOB);
                    end
                    
                    %save back to lineInfo
                    lineInfo{ix, 5} = nAY;
                    lineInfo{ix, 6} = nFAY;
                    lineInfo{ix, 7} = nCY;
                    lineInfo{ix, 9} = developmentPattern;
                    lineInfo{ix, 10} = historicalPattern;
                    lineInfo{ix, 11} = volume;
                    lineInfo{ix, 16} = triangle;
                end
                
                %set
                LOB.setParam(ix, betaAY, betaCY, nAY, nFAY, nCY, duration, yr0, ...
                    volume, developmentPattern, historicalPattern, triangle, parents,... %info that are generated
                    ARMSFlag, expLoss, CredibilityFactor, p, k);
                LOBArray(ix) = LOB;
                
                
            end
            
            if(saveTriangle)
                load(GP.lineInfo, 'lineInfoTitle');
                lineInfo = [lineInfoTitle; lineInfo];
                save(GP.lineInfo, 'lineInfo', 'lineInfoTitle');
                fprintf('lineInfo.mat has been updated!\n');
            end
            
            obj.LOBArray = LOBArray; %save

        end
        
        

        %% payout pattern from Steady state
        function [developmentPattern, historicalPattern, volume, triangle, nAY, nFAY, nCY] = getTriangleByPayoutPattern(obj, SSPP, nAY, nFAY, nCY, expLoss,trend)
            prm = ParameterRiskModule();
            ab = ARMSBridge();
            GP = Params();
            app = ecmRuntimeController();
            if(length(SSPP)>nCY)
                warning('Payout pattern data error: CY length from SS is larger than that of LOB');
            else
                SSPP = [SSPP, zeros(1, nCY - length(SSPP))];
            end
            AYLength = nAY + nFAY;
            
            %volume
            volume = zeros(AYLength, 1);
            volume(nAY) = expLoss;
            for ay = (nAY-1):-1:1
                volume(ay) = volume(ay+1)/(1+ trend);
            end
            if(nFAY>0)
                for fay = (nAY+1) : (nAY+nFAY)
                    volume(fay) = volume(fay-1) * (1+ trend);
                end
            end
            
            %triangle
            triangle = repmat(SSPP, AYLength, 1) .* repmat(volume, 1, nCY);
            
            %pattern
            [developmentTriangle, historicalTriangle, volume, nAY, nFAY, nCY] = ab.getTriangle(triangle, nAY, nFAY, nCY);
            %percentage
            historicalPattern = historicalTriangle ./ repmat(sum(triangle, 2), 1, nCY);
            developmentPattern = developmentTriangle ./ repmat(volume, 1, nCY);
        end
    
        %%
        %extract from excel (old)
        function [developmentPattern, historicalPattern, volume, nAY, nFAY, nCY, triangle]  = getTriangleFromExcel(obj, LOB)
            GP = Params();
            
            %create triangleInfo
            triangleInfo = obj.triangleInfo;
            
            %sheet
            modelName = LOB.modelRefName;
            
            %====================for testing purpose only==================
            if(isnan(modelName));   modelName = 'Avi_WW';  end
            
            %determine if triangle has been loaded
            if(isempty(triangleInfo{modelName,'developmentPattern'})) %skip if already loaded
                %get excel specific info
                [~, ~, sheet] = xlsread(GP.triangle, 'Summary'); %LOB loading directory with triangle
                yr0 = sheet{2,6}; %define yr0
                AY0 = sheet{3,6}; %define AY0
                CY0 = sheet{4,6};%define CY0
                lobSheet = triangleInfo{modelName, 'sheet'};
                triangleType = lobSheet(1);
                %determin info consistency
                if(yr0 ~= GP.yr0); error('Data inconsistency: yr0 not equal from GP and excel'); end;
                %read excel
                [~,~,triangleRaw] = xlsread(GP.triangle, lobSheet);
                %get triangle
                AY = size(triangleRaw,1)-AY0+1;
                for iay=1:AY %get nAY
                    triangleNum = triangleRaw{AY0+iay-1,CY0};
                    if(isnan(triangleNum) || isempty(triangleNum))
                        AY=iay-1;
                        break;
                    end
                end
                CY = size(triangleRaw,2)-CY0+1;
                for icy=1:CY %get nCY
                    triangleNum = triangleRaw{AY0+AY-2, CY0+icy-1};
                    if(isnan(triangleNum) || isempty(triangleNum))
                        CY=icy-1;
                        break;
                    end
                end
                %AYear
                AYColumn = cell2mat(triangleRaw(AY0:AY+AY0-1, CY0-1));
                %CYColumn
                CYColumn = cell2mat(triangleRaw(AY0-1, CY0:CY0+CY-1));
                %triangle
                triangleRaw = cell2mat(triangleRaw(AY0:AY+AY0-1, CY0:CY+CY0-1));
                
                %transform triangle to pattern
                armsBridge = ARMSBridge();
                [developmentPattern, historicalPattern, volume, nAY, nFAY, nCY, triangle] = armsBridge.transformPattern(triangleRaw, GP.yr0, triangleType, AYColumn, CYColumn);
                %save to triangle info
                triangleInfo{modelName,'developmentPattern'} = developmentPattern;
                triangleInfo{modelName,'historicalTriangle'} = historicalPattern;
                triangleInfo{modelName,'volume'} = volume;
                triangleInfo{modelName,'nAY'} = nAY;
                triangleInfo{modelName,'nFAY'} = nFAY;
                triangleInfo{modelName,'nCY'} = nCY;
                triangleInfo{modelName,'triangle'} = triangle;
                obj.triangleInfo = triangleInfo;
            else
                %get the info from triangleInfo
                developmentPattern = obj.triangleInfo{modelName,'developmentPattern'};
                historicalPattern = obj.triangleInfo{modelName,'historicalTriangle'};
                volume = obj.triangleInfo{modelName,'volume'};
                nAY = obj.triangleInfo{modelName,'nAY'};
                nFAY = obj.triangleInfo{modelName,'nFAY'};
                nCY = obj.triangleInfo{modelName,'nCY'};
                triangle = obj.triangleInfo{modelName,'triangle'};
            end
            
        end
        
        %% TriangleInfo
        function t = get.triangleInfo(obj)
            if(~isempty(obj.triangleInfo))
                t = obj.triangleInfo;
                return;
            end
            %create new
            display('Create new triangleInfo');
            GP =Params();
            [~, ~, sheet] = xlsread(GP.triangle, 'Summary');
            sheet = sheet(:,1:2);
            sheet(1,1:9) = {'ARMSRef', 'sheet', 'developmentPattern', 'historicalTriangle', 'volume', 'nAY', 'nFAY', 'nCY', 'triangle'};
            obj.triangleInfo = cell2dataset(sheet(:,2:end), 'ObsNames', sheet(2:end,1));
            t = obj.triangleInfo;
        end
        
        %% Budget lines
        function BLArray = createBudgetLine(obj)
            blInfo = obj.BLInfo;
            BLArray = BudgetLine.empty(size(blInfo,1),0);
            for ix = 1:size(blInfo, 1)
                BLArray(ix) = BudgetLine(blInfo{ix,1});
                tag = struct;
                tag.Region = blInfo{ix,2};
                tag.ProfitCenter = blInfo{ix,3};
                tag.P_C = blInfo{ix,4};
                mapping = obj.setMapping(BLArray(ix));
                BLArray(ix).setParams(ix, mapping, tag);
            end
            obj.BLArray = BLArray; %save reference to BLs
        end
        
        
        %% create mapping for BL
        function mapping = setMapping(obj, BL)
            Lia = ismember(obj.mapInfo(:,2), BL.name); %get LOB given BL
            loc = find(Lia); %filter out non-related LOB
            mapping = cell(length(loc), 2);
            mapping(:,1) = obj.mapInfo(loc,1);%LOB name
            mapping(:,2) = obj.mapInfo(loc,3);%weight
            %check
            if size(mapping,1)==0
                error('Mapping error: no LOB assigned in mapping for BL: %s', BL.name);
            end
        end
        
        
        %% apply mapping: calculates max AY, FAY, CY
        function applyMapping(obj)
            GP = Params();
            app = ecmRuntimeController();
            BLArray = obj.BLArray;
            for i=1:length(BLArray)
                %fprintf('Mapping %d LOBs to BL: %s \n', size(BLArray(i).mapping,1), BLArray(i).name);
                load(GP.lineInfo, 'lineInfoTitle');
                [~, col] = ismember({'nAY', 'nFAY', 'nCY'}, lineInfoTitle);
                [~, loc] = ismember(BLArray(i).mapping(:,1), obj.lineInfo(:,1));
                if(loc==0)
                    %no lob mapped to bl
                    BLArray(i).setAYCY(0,0,0);
                    return;
                end
                AY = cell2mat(obj.lineInfo(loc,col(1)));
                FAY = cell2mat(obj.lineInfo(loc,col(2)));
                CY = cell2mat(obj.lineInfo(loc,col(3)));
                %BLArray(i).nAY = max(AY);
                %BLArray(i).nFAY = max(FAY);
                %BLArray(i).nCY = max(CY);
                BLArray(i).setAYCY(max(AY),max(FAY),max(CY));
            end
        end
        
        
        %% create parents for LOB
        function parents = setParents(obj, LOB, mapInfo)
            Lia = ismember(mapInfo(:,1),LOB.name);
            if(sum(Lia)==0)
                error('Line information incorrect: name for line:"%s" could not be found', LOB.name);
            end
            loc = find(Lia);
            %parents.(mapInfo{loc,2}) = mapInfo{loc,3}
            parents = cell(length(loc), 2);
            parents(:,1) = mapInfo(loc,2);
            parents(:,2) = mapInfo(loc,3);
            %check sum
            if(single(sum(cell2mat(parents(:,2))))~= 1.00)
                error('Mapping error: sum of LOB weights does not equal to 1');
            end
        end
        

        
    end
    
    methods

        
    end
    
end
