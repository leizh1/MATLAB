classdef GC %global constants & variables
    properties(Constant = true)
        %% compression mode
        NormalMode = 0
        CompressedMode = 1
        
        %% glossory
        AY = 'AY'
        FAY = 'FAY'
        CY = 'CY'
        
        
        %% memory control
        MEM_LOW = 0.8
        MEM_CRITICAL = 0.9
        
        %% load methods
        LOAD_DB = 0
        LOAD_MAT = 1
        LOAD_EXCEL = 2
        LOAD_HDF5 = 3
        
        %% driver simulation
        DRIVER_SIMULATION_GENERATE = 0
        DRIVER_SIMULATION_LOAD = 1
        
        %% Parallel
        PARALLEL_NONE = 0
        PARALLEL_PROCESSING = 1
        
        
    end

end
