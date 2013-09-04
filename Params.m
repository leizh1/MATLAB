classdef Params < Singleton
    properties %(SetAccess = immutable)
        N = 10000
        pathIn = '.\Data\'
        pathOut = '..\Reports\'
        saved = '..\Saved\'
        guiData = '.\Data\guidata.mat'
        
        %files
        ECM_info = '.\Data\ECM_info.xlsx';
        triangle = '.\Data\Triangles.xlsx'
        yr0 = 2010
        compressionMode = GC.NormalMode
        
        %line
        lineLoadMode = GC.LOAD_MAT %LOB loading source
        lineInfo = '.\Data\lineInfo.mat'
        
        %driver
        driverLoadMode = GC.LOAD_MAT %Economic driver loading source
        driversSource = '.\Data\driversInfo.mat' %default driver info location
        driverSimulationSource = GC.DRIVER_SIMULATION_GENERATE
        
        %BL
        blLoadMode = GC.LOAD_MAT
        blInfo
        
        
        %Discount rate
        discountMode = 1 % if cashflow should be discounted
        stochasticRate = 0
        currList = {'AUD', 'CAD', 'CHF', 'DKK', 'EUR', 'GBP', 'HKD', 'JPY', 'MYR', 'SGD', 'TWD', 'USD'}
        yieldPath = '.\Data\yields.mat' %default yield location
        ratePath = '\\Livpwfs11\shares\Chartis-ERM\David_Romoff\OUTBOX\AssetSim\DataByCurrency\'
        currencyTab = 'Curves' %default cur table tab
        yieldLoadMode
        
        
        %ARMS model
        armsModelLocation = '\\livpwfs11\shares\Chartis-ERM\ChartisERM\2012Q4 ARMS Models\' %location of ARMS model file
        modelFileNameMapping = '.\Data\AS vs ARMS Model.xlsx'
        armsModel = 'armsModels.mat' %file name for arms model list
        trending = 0.05 %trending factor
        steadyStage = 1
        
        %Parameter Risk
        parameterRiskMode = 1;
        
        %idiosyncratic risk
        idiosyncraticRiskMode = 1;
        
        %systematic risk
        systematicRiskMode = 1;
        
        %GUI
        figure; %figure
        axes; %axes
    end
    
    %% static method
    methods(Static)
        function obj = instance()
            obj = Params();
        end
        
        function obj = Params()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new Params class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
end
