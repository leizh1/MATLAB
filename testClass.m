classdef testClass < Singleton
    properties
        var=1;
    end
    
    methods(Static)
        function obj = instance()
            obj=testClass();
        end
        
        function obj = testClass()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
end

