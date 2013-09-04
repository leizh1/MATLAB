classdef ARMSModel < handle
    properties
        model %model data file that contains everything
        name
        baseForecast
        size = [0. 0]
        key
        historicalTriangle
        triangle
        paramSim
        volumeRef
        nAY
        nCY
        nFAY = 0
    end
    
    methods(Static)
        function obj = createModel(modelData)
            obj = ARMSModel();
            obj.model = modelData;
            obj.name = modelData.name;
            obj.baseForecast = ECMIO.decompression(modelData.baseForecast, modelData.key, modelData.size);
            obj.size = modelData.size;
            obj.key = modelData.key;
            obj.historicalTriangle = modelData.data_PD(1:obj.size(1), 1:obj.size(2));
            obj.paramSim = modelData.paramSim;
        end
    end
    
    methods
        function volume = get.volumeRef(obj)
            parameterRiskModule = ParameterRiskModule();
            volume = parameterRiskModule.getVolumeReference(obj);
        end
        
        function nAY = get.nAY(obj)
            nAY = obj.size(1);
        end
        
        
        function nCY = get.nCY(obj)
            nCY = obj.size(2);
        end
        
        function t = get.triangle(obj)
            t = obj.historicalTriangle + obj.baseForecast;
        end
    end
    
    
end
