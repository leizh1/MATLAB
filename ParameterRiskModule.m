classdef ParameterRiskModule < Singleton
    properties
        paramDataset %stores the data related to param risk, including credibility factor and correlation parameter
        %fittedPattern
    end
    
    methods(Static)
        function obj = instance()
            obj = ParameterRiskModule();
        end
        
        function obj = ParameterRiskModule()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new ParameterRiskModule class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
    methods
        %% get param disterbance matrix by LOB
        function sim = getParamSim(obj, LOB)
            %get parameter distribution from ARMS model
            tic
            model = LOB.modelRef;
            paramSim = model.paramSim;
            baseForecast = model.baseForecast;
            %decode
            paramSim = ECMIO.decompression(paramSim, model.key, model.size);
            simN = size(paramSim, 3);
            %standarize by deviding base forecast
            PD = paramSim./repmat(baseForecast, [1,1,simN]);   %<==================?????????? why not mean =1
            PD(isnan(PD))=0;
            %normalize
            PN = PD./repmat(mean(PD, 3), [1,1,simN]);
            PN(isnan(PN))=0;
            
            %scale
            scaleFactor = (LOB.modelRef.volumeRef ./ LOB.volumeRef).^0.5;
            PL = 1 + (PN-1).* scaleFactor;
            PL(PN==0) = 0;  %force the original 0 goes back
            toc
            tic
            % copula: calculate copular of PN and PL by IC method, using sum of each
            % sumulation's pattern as a vector, and LOB.corr as correlation
            % between these two series.
            sumVectorScaled = sum(sum(PL, 1), 2);
            sumVectorScaled = reshape(sumVectorScaled, [simN, 1, 1]);
            sumVectorNormal = sum(sum(PN, 1), 2);
            sumVectorNormal = reshape(sumVectorNormal, [simN, 1, 1]);
            
            sample = [sumVectorNormal, sumVectorScaled];
            r = LOB.corr;
            if(r>1); r=0.9;warning('LOB.corr is large than one, change to 0,9 now');end;
            
            R = [1, r; r, 1];
            
            
            simN = length(sumVectorScaled);
            score = norminv((1:simN) ./ (simN+1), 0, 1);
            [sample, index] = Util.IC(sample, R, score, LOB.ID);  
            
            %======figure for debug==========
            %{
            GP = Params();
            figure(GP.figure);
            subplot(2, 2, LOB.ID);
            scatter(sample(:,1), sample(:,2));
            title(['ID= ' mat2str(LOB.ID) ' corr = ' mat2str(LOB.corr) ' flag = ' mat2str(LOB.ARMSFlag)]);
            %}
            %======copula==========
            PL_reordered = PL(:,:,index(:,2));
            % combine: mix reordered PL with PN, by using credibilityFactor
            % as the percentage
            PLC = LOB.credibilityFactor .* PL_reordered + (1-LOB.credibilityFactor) .* PN;
            toc
            %transform the original shape of lower right triangle to be lower left triangle
            armsBridge = ARMSBridge();
            [sim, ~] = armsBridge.getTriangle(PLC, model.nAY, model.nFAY, model.nCY);
            
            %compatibility shift for nAY and nCY mismatch  %==================>needs update
        end
        
        function volume = getVolumeReference(obj, model)
            triangle = model.triangle;
            nAY = model.nAY;
            nCY = model.nCY;
            x = size(triangle,1);
            y = size(triangle,2);
            %logical location represents last 5 diagonals
            logicalMatrix = repmat(1: y, x, 1) + repmat((1:x)', 1, y);
            logicalMatrix = (logicalMatrix<=(nAY+1)) - (logicalMatrix<=(nAY-4)); 
            volume = sum(sum(triangle(logical(logicalMatrix))));
            
%             for j = 1:nCY
%                 s = (nAY-3-j);
%                 e = (nAY-j+1);
%                 volume = volume + sum(historicalTriangle( s:e , j));
%             end
        end
        
        %% get data table
        function table = get.paramDataset(obj)
            if(~isempty(obj.paramDataset))
                table = obj.paramDataset;
                return;
            end
            %create new
            display('Create new paramDataset');
            GP =Params();
            [num, txt, raw] = xlsread(GP.ECM_info, 'Param Data');
            lobNames = raw(2:end, 4);
            [~, PPIdx] = ismember('PayoutPattern', txt(1,:));
            SSPP = num(2:end,PPIdx+1:end);
            for i=1:size(SSPP,1)
                PP = SSPP(i,SSPP(i,:)>0);
                raw{i+1,PPIdx} = PP;
            end
            obj.paramDataset = cell2dataset(raw(:,1:PPIdx), 'ObsNames', lobNames);
            table = obj.paramDataset;
        end
        
        %% payout pattern
        function sspp = getPayoutPattern(obj, LOB)
            name = LOB.name;
            sspp = obj.paramDataset{name, 'PayoutPattern'};
            %LOB.payoutPattern = sspp;
        end
        
    end
    
    

end
