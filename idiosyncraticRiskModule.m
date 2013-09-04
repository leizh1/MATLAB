classdef idiosyncraticRiskModule < Singleton
    methods(Static)
        function obj = instance()
            obj =  idiosyncraticRiskModule();
        end
        
        function obj = idiosyncraticRiskModule()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new idiosyncraticRiskModule class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
        function idioDist = getIdioDist(LOB)
            pd = LOB.paramDist;
            mean_ = mean(pd, 3);
            std_ = std(pd, 0, 3);
            kappa_ = (mean_ ./ std_).^2;
            theta_ = (std_.^2 )./mean_;
            %
            idioDist = gamrnd(kappa_, theta_, size(pd));
            

        end
    end
    

end
