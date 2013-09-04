classdef AYFactor < EconomicDrivers
    properties
        nAY
        nFAY
        currentYearPointer 
        baseYear %1990
        yr0
    end
    
    properties(Dependent = true)
        nAYLength
        
    end
    
    methods
        function obj = AYFactor(name, simulation, nAY, nFAY, beta, X)
            obj.name = name;
            obj.type = 'AY';
            obj.nAY = nAY;
            obj.nFAY = nFAY;
            obj.simulation = simulation;
            obj.beta = beta;
            obj.X = X;
            %check compliance
            if(~checkFactorComplience(obj))
                warning('AYFactor %s is not compliant to model standard', obj.name);
                extendFactor(obj)
            end
        end
        
        function nAYValue = get.nAYLength(obj)
           nAYValue = obj.nPAY + obj.nFAY; 
        end
        
        function currentYear = get.currentYearPointer(obj)
            currentYear = obj.nPAY+1;
        end
    end
        
end
