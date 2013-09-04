% Provides a set of analytical functions.

classdef AnalyticModule < Singleton
    properties
        tags
    end
    
    methods(Static)
        % Concrete implementation.  See Singleton superclass.
        function obj = instance()
            obj = AnalyticModule();
        end
        
        function obj = AnalyticModule()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating AnalyticModule instance');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
        %% main function for analytics calculation
        function analytics = getStatisticsByTag(BLArray, tags)
            lineFactory = LineFactory.instance();
            filteredBLArray = AnalyticModule.filterByTag(BLArray, tags);
            
            for i = 1:size(tags, 1)
                %create a BL object for grouping purpose
                %BLGroup = BudgetLine(tags{i,2});
                %collapse cashflow to CY
                fprintf('Grouping cashflow for tag: %s \n', tags{i,2});
                cashflow = AnalyticModule.groupCashflow(filteredBLArray);
                aggregatedCashflow = sum(cashflow,1);
                ReportModule.displayAggregatedCashflowBySurf(aggregatedCashflow);
                %pause
            end
        end

        function statsMat = getStatisticsByBL(BL, query)
            cashflowCY = sum(BL.cashflow,1);
            [rows, cols, nsims] = size(cashflowCY);
            cashflowCY = reshape(cashflowCY, cols, nsims);
            %stats
            maxCY = max(cashflowCY, 1);
            minCY = min(cashflowCY, 1);
            meanCY = mean(cashflowCY, 1);
        end
        
        function [statMat, rowName] = formatStatisticResult(result)
            statMat = [result(1).max; result(1).min; result(1).mean; result(1).std];
            rowName = {'Max' 'Min' 'Mean' 'Std'};
            %VaR
            for i=1:length(result)
                statMat = [statMat; result(i).VaR];
                rowName = [rowName, ['VaR ', num2str(result(i).precentile), '%']];
            end
            %CVaR
            for i=1:length(result)
                statMat = [statMat; result(i).CVaR];
                rowName = [rowName, ['CVaR ', num2str(result(i).precentile), '%']];
            end    
        end
        
        %% Filter the Array by tag criteria
        function filteredBLArray = filterByTag(BLArray, tags)
            IDList = [];
            filteredBLArray = BudgetLine.empty();
            for i = 1:size(tags,1)
                for j=1:length(BLArray)
                    category = tags{i,1};
                    value = tags{i,2};
                    if(strcmp(BLArray(j).tag.(category) , value))
                        IDList = [IDList, j];
                    end
                end
            end
            IDList = unique(IDList);
            for k = 1:length(IDList)
                filteredBLArray(k) = BLArray(IDList(k));
            end
        end
        
        %% get statistics by cashflow
        function analytics = getStatistics(cashflow, dimension, precentile)
            if(nargin == 2)
                precentile = 99;
            end
            %
            maxCY = max(cashflow, [], dimension);
            minCY = min(cashflow, [], dimension);
            meanCY = mean(cashflow, dimension);
            stdCY = std(cashflow,1,dimension);
            %VaR
            for i=1:length(precentile)
                analytics(i).max = maxCY;
                analytics(i).min = minCY;
                analytics(i).mean = meanCY;
                analytics(i).std = stdCY;
                analytics(i).precentile = precentile{i};
                analytics(i).VaR = prctile(cashflow, 100-precentile{i}, dimension);
                analytics(i).CVaR = AnalyticModule.CVaR(cashflow, analytics(i).VaR, dimension);
            end
        end
        
        function cvar = CVaR(cashflow, var, dim)
            if(dim==1)
                repeatVAR = repmat(var, [size(cashflow,1), 1]);
            elseif(dim==3)
                repeatVAR = repmat(var, [1,1,size(cashflow,3)]);
            end
            
            condition=cashflow>repeatVAR;
            cvar = sum(cashflow.*condition, dim)./sum(condition, dim);
            cvar(isnan(cvar))=0;
        end
        
        %% Group cashflow
        function [groupedCashflow, nAY, nFAY, nCY] = groupCashflow(BLGroup)
            GP = Params.instance();
            if(length(BLGroup==1))
                groupedCashflow = BLGroup.cashflow;
                nAY = BLGroup.nAY;
                nFAY = BLGroup.nFAY;
                nCY = BLGroup.nCY;
                return;
            end
            
            tic
            
            nAY = max([BLGroup.nAY]);
            nFAY = max([BLGroup.nFAY]);
            nCY =max([BLGroup.nCY]);
            groupedCashflow = zeros(nAY+nFAY,nCY,GP.N, 'single');
            
            %parallel processing
            if(matlabpool('size')==0)
                %matlabpool open;
            end
            
            for i = 1:length(BLGroup)
                BL = BLGroup(i);
                BLCashflow = BL.cashflow;
                %AY
                if(BL.nAY < nAY)
                    BLCashflow = [zeros(nAY-BL.nAY, BL.nCY, GP.N); BLCashflow];
                elseif(BL.nAY > nAY)
                    error('Error in combining Cash flow of the selected BL: incorrect nAY');
                end
                
                %FAY
                if(BL.nFAY < nFAY)
                    BLCashflow = [BLCashflow; zeros(nFAY-BL.nFAY, BL.nCY, GP.N)];
                elseif(BL.nFAY > nFAY)
                    error('Error in combining Cash flow of the selected BL: incorrect nFAY');
                end
                
                %CY
                if(BL.nCY < nCY)
                    BLCashflow = [BLCashflow, zeros(nAY+nFAY, nCY-BL.nCY, GP.N)];
                elseif(BL.nCY > nCY)
                    error('Error in combining Cash flow of the selected BL: incorrect nCY');
                end
                
                %group
                groupedCashflow = groupedCashflow + BLCashflow;
                
                %memory
                ECMIO.RAMCheck;
            end
            
            toc
            
            fprintf('===========================\n');
        end
        
        
        %% Risk attribution
        function calculateRiskAttribution(BLGroup)
            groupPattern = groupPayoutPattern(BLGroup);
            factors = groupFactor(BLGroup);
            
        end
        
        function [payoutPattern, nAY, nFAY, nCY] = groupPayoutPattern(BLGroup)
            GP = Params.instance();
            if(length(BLGroup==1))
                payoutPattern = BLGroup.pattern;
                nAY = BLGroup.nAY;
                nFAY = BLGroup.nFAY;
                nCY = BLGroup.nCY;
                return;
            end
            
            tic
            
            nAY = max([BLGroup.nAY]);
            nFAY = max([BLGroup.nFAY]);
            nCY =max([BLGroup.nCY]);
            payoutPattern = zeros(nAY+nFAY,nCY);
            
            for i = 1:length(BLGroup)
                BL = BLGroup(i);
                pattern = BL.pattern;
                %AY
                if(BL.nAY < nAY)
                    pattern = [zeros(nAY-BL.nAY, BL.nCY); pattern];
                elseif(BL.nAY > nAY)
                    error('Error in combining pattern of the selected BL: incorrect nAY');
                end
                
                %FAY
                if(BL.nFAY < nFAY)
                    pattern = [pattern; zeros(nFAY-BL.nFAY, BL.nCY)];
                elseif(BL.nFAY > nFAY)
                    error('Error in combining pattern of the selected BL: incorrect nFAY');
                end
                
                %CY
                if(BL.nCY < nCY)
                    pattern = [pattern, zeros(nAY+nFAY, nCY-BL.nCY)];
                elseif(BL.nCY > nCY)
                    error('Error in combining pattern of the selected BL: incorrect nCY');
                end
                
                %group
                payoutPattern = payoutPattern + pattern;
            end
            
            toc
            
            fprintf('===========================\n');
        end
    end
    
    methods
        %% tags
        function tags = updateTags(obj)
            tags = struct();
            app = ecmRuntimeController();
            tags.Region = unique(app.lineFactory.BLInfo(:,2));
            tags.ProfitCenter = unique(app.lineFactory.BLInfo(:,3));
            tags.P_C = unique(app.lineFactory.BLInfo(:,4));
            obj.tags = tags;
        end

    end
end
