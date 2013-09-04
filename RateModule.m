classdef RateModule < Singleton
    properties
        curves %currency curves
        cube %simulation of rates (not catched)
        currencyMap %line to currency/country map
        tenors
        currList
        nRate %simulation number of rates
    end
    
    methods(Static)
        %% Concrete implementation.  See Singleton superclass.
        function obj = instance()
            obj = RateModule();
        end
        
        function obj = RateModule()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new RateModule class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
    methods
         %% currency table
        function currMap = get.currencyMap(obj)
            if(~isempty(obj.currencyMap))
                currMap = obj.currencyMap;
                return;
            end
            
            GP = Params();
            [~, ~, currMap] = xlsread(GP.ECM_info, GP.currencyTab);
            currMap(1,:)=[];
            obj.currencyMap = currMap;
        end
        
        %% yields, legacy method to load static currency curves
        function curves = loadCurve(obj)
            if(~isempty(obj.curves))
                curves = obj.curves;
                return;
            end            
            
            GP = Params();
            
            if(GP.stochasticRate)
                %stochastic rate
                cube = obj.cube; %prepare the cube and other parameter
                curvesCell = [GP.currList; num2cell(cube, 3)];
                curves = cell2dataset(curvesCell, 'ObsNames', obj.tenors);
            else
                %static rate
                path = GP.yieldPath; %static rate info
                load(path, 'treas_yields');
                countryList = {'EU', 'AP', 'CE', 'LA', 'FE','US'};
                tenorList = {'3M', '6M', '1Y', '2Y', '3Y', '4Y', '5Y', '6Y', '7Y', '8Y', '9Y',...
                    '10Y', '11Y', '12Y', '13Y', '14Y', '15Y', '16Y', '17Y', '18Y', '19Y', '20Y',...
                    '21Y', '22Y', '23Y', '24Y', '25Y', '26Y', '27Y', '28Y', '29Y', '30Y'};
                curvesCell = [countryList; num2cell(zeros(length(tenorList),length(countryList)))];
                curves = cell2dataset(curvesCell, 'ObsNames', tenorList);
                %read the input
                for i=1:size(treas_yields,2)
                    tag = treas_yields{1,i};
                    info = regexp(tag, '\.', 'split');
                    countryCode = info(1);
                    tenor = info(2);
                    curves{tenor, countryCode} = 1 + treas_yields{2,i};
                end
            end
            %save to obj
            obj.curves = curves;
        end
        
        %% cube if the container of stochastic rates
        function cube = get.cube(obj)
            %cube is the container of stochastic paths of rate curves
            %dimentions: r:tenor c:currency z:sim#
            %cube is not catched
            
            display('Loading stochastic rates');
            
            GP = Params();
            obj.currList = GP.currList; %currency list
            
            %reading pattern
            pattern = 'Govt';
            endpattern = ', 3)';
            tenor = [];
            
            path = GP.ratePath;
            fileList = dir(path);
            fileNames = {fileList.name};
            
            for i=1:length(obj.currList)
                curr = obj.currList{i};
                fname = [obj.currList{i} '_data.mat'];
                exsit = ismember(fname, fileNames);
                if(~exsit)
                    continue;
                end
                %read the file
                labels = [curr '_RatingsLabels'];%column label file name
                rates = [curr '_rateLevels'];%rate file name
                load([path fname], labels, rates);
                %check labels
                labels = eval(labels); %convert to label file
                rates = eval(rates); %convert to rate file
                govtIndex = regexp(labels, pattern);  %pattern beginning location
                endIndex = regexp(labels, endpattern); %pattern ending location
                for j=1:length(govtIndex)
                    if(isempty(govtIndex{j}))
                        govtIndex{j}=0; %add 0 if pattern not found
                    else
                        tenor(j) = str2num(labels{j}(govtIndex{j}+length(pattern)+2:endIndex{j}-1)); %get tenor from label as number
                    end
                end
                govtIndex = cell2mat(govtIndex); %convert to matrix
                %save
                tenorList(:,i) = tenor(govtIndex>0); %tenors is organized by tenor by curr
                rateCube(:,:,i) = rates(:, govtIndex>0); %save each curr by third dimention
            end
            
            %tenor check
            if(max(tenorList, [], 2) ~= min(tenorList, [], 2))
                error('Tenor is not equivalent accross currencies');
            end
            %tenor transform
            tenors = cell(length(tenorList(:,1)),1);
            
            for i = 1:length(tenors)
                yr = tenorList(i,1);
                if(yr<1)
                    tenor = [num2str(int8(yr*12)) 'M'];
                else
                    tenor = [num2str(yr), 'Y'];
                end
                tenors{i} = tenor;
            end
            %transform r:simulation# c:tenor z:currency to r:tenor c:currency z:sim#
            for i=1:size(rateCube,3)
                for j = 1:size(rateCube, 2)
                    cube(j,i,:) = rateCube(:,j,i);
                end
            end
            display('Finished loading currency simulation');
            %obj.cube = cube;
            obj.tenors = tenors;
            obj.nRate = size(cube,3);
        end
        
        
    end
end
