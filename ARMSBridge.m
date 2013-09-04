classdef ARMSBridge < Singleton
    properties
        armsModels %array of all ARMS models
        modelFileNameMap
        armsModelLocation = '\\livpwfs11\shares\Chartis-ERM\ChartisERM\2012Q4 ARMS Models\'
        modelList = {} %model name list
        modelFileName = 'armsModels.mat'
    end
    
    methods(Static)
        function obj = instance()
            obj = ARMSBridge();
        end
        
        function obj = ARMSBridge()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new ARMSBridge class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
    methods
        function models = get.armsModels(obj)
           if(~isempty(obj.armsModels))
               models = obj.armsModels;
               return;
           end
               obj.armsModels = ARMSModel.empty(length(obj.modelList), 0);
               models = obj.armsModels;
        end
        
        function modelList = getModelList(obj)
            GP = Params();
            try
                %try load locally first
                load(['C:\' obj.modelFileName], 'modelList');
            catch err
                display(err.message);
                %read remotely from ARMS folder
                fileSys = dir(GP.armsModelLocation);
                fileSys(cell2mat({fileSys.bytes})==0)=[]; %remove folders
                nameList = {fileSys.name};
                idx = strfind(nameList, '__CF5000.mat');
                obj.modelList = {};
                for i=1:length(nameList)
                    if(idx{i}>0)
                        obj.modelList = [obj.modelList; nameList{i}(1:idx{i}-1)];
                    end
                end
                modelList = obj.modelList;
                
            end
            
        end
        
        function INS = fetchArmsData(obj, fileName, path)
            if(nargin == 2)
                path = obj.armsModelLocation;
            end
            paramSim = [];
            display(['Loading data from model:', fileName, '\n']);
            load([path fileName], 'INS');
            %create fitted parameter
            INS.param_model = [];
            sim = load([path fileName, '__CF5000.mat'], 'Boot*');
            simNames = fieldnames(sim);
            for i=1:length(simNames)
                
                %simulation
                paramSim = [paramSim, sim.(simNames{i}).PD.param];
                %extract some info from boot
                if(isempty(INS.param_model))
                    INS.size = sim.(simNames{i}).size; %size
                    INS.key = sim.(simNames{i}).Loc_RSVS; %key
                    INS.baseForecast = sim.(simNames{i}).PD.model; %fitted triangle (base forecast)
                else
                    if(INS.param_model ~= sim.(simNames{i}).PD.model)
                        error('Model fitted parameter mismatch.');
                    end
                end
            end
            %stich together
            INS.name = fileName;
            INS.paramSim = paramSim;
        end
        
        function saveModels(obj)
            GP = Params.instance();
            %get list
            modelList = obj.modelList;
            nModel = length(modelList);
            %obj.armsModels = cell(nModel,3);
            %save list
            save([GP.pathIn, GP.armsModel], 'modelList');
            for i=1:nModel
                display(i);
                modelName = obj.modelList{i};
                model = obj.fetchArmsData(modelName, obj.armsModelLocation);

                %obj.armsModels.(modelName)=model;
                %save
                save([GP.pathIn, obj.modelFileName], model, '-append');
                clear modelName;
            end
            
        end
        
        function path = get.armsModelLocation(obj)
            GP = Params;
            path = GP.armsModelLocation;
        end
        
        function list = get.modelList(obj)
            if(~isempty(obj.modelList))
                list = obj.modelList;
                return
            end
            %read the list
            list = obj.getModelList();
        end
       
        
        %%
        function model = getModelByName(obj, modelRefName)
            if(isnan(modelRefName))
                obj.getDummyModel();
            end
            % index for model name
            try
                [~, i] = ismember(modelRefName, obj.modelFileNameMap(:,1));
            catch  err
                if(strcmp(err.message, 'Index exceeds matrix dimensions.'))
                    %
                else
                    throw(err);
                end
                
            end
            
            if(i==0)
                obj.getDummyModel();
            end
                
            %index for model file
            [~, idx] = ismember(obj.modelFileNameMap{i,3}, obj.modelList);
            try
                model = obj.armsModels(idx);
            catch err
                if(strcmp(err.message, 'Index exceeds matrix dimensions.'))
                    %read file first
                    GP = Params();
                    modelData = obj.fetchArmsData(obj.modelList{idx});
                    %create model
                    model = ARMSModel.createModel(modelData);
                    %add model to array
                    obj.armsModels(idx) = model;
                else
                    throw(err)
                end
                
            end
            
            if(isempty(model.name))
                %read file first
                    GP = Params();
                    modelData = obj.fetchArmsData(obj.modelList{idx});
                    %create model
                    model = ARMSModel.createModel(modelData);
                    %add model to array
                    obj.armsModels(idx) = model;
            end
        end
        
        %% Triangle to pattern (Old) ===============NEED UPDATE ==================
        function [developmentPattern, historicalPattern, volume, nAY, nFAY, nCY, triangle] = transformPattern(obj, triangle, yr0, type, AYColumn, CYColumn)
            %clearn
            triangle(isnan(triangle))=0;
            %===============NEED UPDATE ==================
            switch type
                case 'A'
                    fprintf('Type A triangle: yearly AY and Yearly CY\n');
                    AYType='Y';
                    CYType='Y';
                case 'B'
                    fprintf('Type B triangle: yearly AY and Yearly (with month number - 3) CY\n');
                    AYType='Y';
                    CYType='Y';
                case 'C'
                    fprintf('Type C triangle: Quarterly AY and Quarterly CY\n');
                    AYType='Q';
                    CYType='Q';
                case 'D'
                    fprintf('Type D triangle: yearly AY and Yearly CY\n');
                    AYType='Y';
                    CYType='Y';
                case 'E'
                    fprintf('Type E triangle: yearly AY and yearly CY\n');
                    AYType='Y';
                    CYType='Y';
                otherwise
                    error('Incorrect parameter in triangle: unrecognized type\n');
            end
            
            %CONVERT Q TO Y
            %test AY, see if the AY type described is consistant with AY type in data
            [~,nAY] = ismember(yr0, AYColumn);
            if(nAY == 0) %AYColumn is not in year format, it is in quater format
                nAY=floor(length(AYColumn)/4)-1;
                %warning if this info is inconsistant with type
                if(strcmp(AYType,'Y'))
                    warning('This triangle has quaterly AY! Set to nAY = %d\n', nAY);
                    AYType = 'Q';
                end
                
                nFAY = 1;%===============>>>assume nFAY = 1<<<==================
            else
                %nFAY is yearly
                if(strcmp(AYType,'Q'))
                    warning('This triangle has yearly AY! Set to nAY = %d\n', nAY);
                    AYType = 'Y';
                end
                nFAY = length(AYColumn)-nAY;
            end
            
            %test nCY, see if the CY type described is consistant with CY type in data
            CY_interval = CYColumn(2:end)-CYColumn(1:end-1);
            if(max(CY_interval)~=min(CY_interval))
                error('Error in CY column: inconsistant CY increasement!\n');
            end
            if(max(CY_interval)==3) %quaterly CY
                nCY=floor(length(CYColumn)/4);
                if(strcmp(CYType,'Y'))
                    warning('This triangle has quaterly CY! Set to nCY = %d\n', nCY);
                    CYType = 'Q';
                end
            elseif(max(CY_interval)==12) %yearly CY
                nCY = length(CYColumn);
                if(strcmp(CYType,'Q'))
                    warning('This triangle has yearly CY! Set to nCY = %d\n', nCY);
                    CYType = 'Y';
                end
            else
                error('Error in CY column\n');
            end
            
            %assignn multiplier
            if(strcmp(AYType, 'Q'))
                AYMultiplier = 4;
            else
                AYMultiplier = 1;
            end
            if(strcmp(CYType, 'Q'))
                CYMultiplier = 4;
            else
                CYMultiplier = 1;
            end
            
            %check if starting at 12 or 3
            if(CYColumn(1)>12/CYMultiplier)
                colNeedToInsert = floor(CYColumn(1)*CYMultiplier/12-0.01);
                triangle = [zeros(size(triangle,1),colNeedToInsert), triangle];
                nCY = floor(size(triangle,2)/CYMultiplier);
                warning('yearly CY start with %d. Set nCY to %d\n', CYColumn(1), nCY);
            elseif(CYColumn(1)<12/CYMultiplier)
                %ignore for now===========>>>NEED UPDATE<<< ============
                %treat it as correct
                warning('yearly CY start with %d \n', CYColumn(1));
            end
                
            %combine Quater to year
            if(AYMultiplier+CYMultiplier>2)
                newTriangle = zeros(nAY+nFAY, nCY);
                for iAY = 1:nAY+nFAY
                    for iCY = 1:nCY
                        AY_Start = (iAY-1)*AYMultiplier+1;
                        AY_End = iAY*AYMultiplier;
                        CY_Start = (iCY-1)*CYMultiplier+1;
                        CY_End = iCY*CYMultiplier;
                        newTriangle(iAY,iCY) = sum(sum(triangle(AY_Start:AY_End,CY_Start:CY_End)));
                    end
                end
                triangle = newTriangle;
            end
            %END OF CONVERT Q TO Y
            
            %convert triangle to pattern
            [developmentTriangle, historicalTriangle, volume, nAY, nFAY, nCY] = obj.getTriangle(triangle, nAY, nFAY, nCY);
            %percentage
            historicalPattern = historicalTriangle ./ repmat(sum(triangle, 2), 1, nCY);
            developmentPattern = developmentTriangle ./ repmat(volume, 1, nCY);
        end
        
        function [dPatternN, hPatternN, volume, nAY, nFAY, nCY] = getTriangle(obj, triangle, nAY, nFAY, nCY)
            
            N = size(triangle, 3);
            %historical pattern
            hPatternN = zeros(nAY+nFAY, nCY, N);
            for i = 1:nAY
                dataLength = min(nAY-i+1, nCY);
                hPatternN(i, 1:dataLength, :) = triangle(i, 1:dataLength, :);
            end
            
            
            %development Pattern
            %trim triangle if nCY<nAY
            if(nAY>nCY)
                triangle = triangle((nAY-nCY+1):end, :, :);
                nAY = nCY;
            end
            %volume
            volume = sum(triangle,2);
            %tranform AY
            dPatternN = zeros(nAY+nFAY, nCY, N);
            
            for ix = 1:nAY
                dPatternN(ix, :, :) = [triangle(ix, nAY-ix+1:end, :), zeros(1, nAY-ix, N)];
            end
            %transform FAY
            for jx = 1:nFAY
                dPatternN(nAY+jx, :, :) = [zeros(1, jx, N), triangle(nAY+jx, 1:end-(jx), :)];
            end
            
        end

        %% AS vs ARMS Model.xlsx
        function map = get.modelFileNameMap(obj)
            if(~isempty(obj.modelFileNameMap))
                map = obj.modelFileNameMap;
                return;
            end
            GP = Params();
            [~,~,map] = xlsread(GP.modelFileNameMapping);
            obj.modelFileNameMap = map;
        end
        
    end 
end
