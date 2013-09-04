%This object serves as input and output function, memory management and disk IO management.

classdef ECMIO < handle
    events
        critical_memory
    end
    
    methods(Static)
        function obj = ECMIO()
            %add a listener to handle memory
            display('Clear memory listener added');
            addlistener(ECMIO, 'critical_memory', @obj.clearnMemory);
        end
        
         %% save simulation
        function saveFactors(LOB)
            GP = Params.instance;
            fprintf('Saving LOB %s:', LOB.name);
            factorAY = LOB.factorAY;
            factorCY = LOB.factorCY;
            filePath = [GP.saved 'simulation_' num2str(LOB.ID) '_' LOB.name '.mat'];
            tic
            save(filePath, 'factorAY', 'factorCY');
            toc
            
        end
        
        %% load factors
        function [factorAY, factorCY] = loadFactors(LOB)
            GP = Params.instance;
            load([GP.saved 'simulation_' num2str(LOB.ID) '_' LOB.name '.mat']);
        end
        
        %% compression function
        function compressed = compressMatrix(matrix, key)
            n = size(matrix,3);
            origByte = whos('matrix');
            origByte= origByte.bytes;
            
            compressed = zeros(length(key), n, 'single');
            fprintf('Compressing:');
            tic
            for i=1:n
                tempMatrix = matrix(:,:,i);
                compressed(:,i) = tempMatrix(key);
            end
            toc
            newByte = whos('compressed');
            newByte = newByte.bytes;
            fprintf('Compression rate = %d%% \n', int8(newByte/origByte*100));
        end
        
        function decompressed = decompression(matrix, key, sizeM)
            n = size(matrix,2);
            decompressed = zeros(sizeM(1), sizeM(2), n);
            temp = zeros(sizeM);
            for i = 1:n
                temp(key) = matrix(:,i);
                decompressed(:,:,i) = temp;
            end
        end
        
        %% memory check
        function RAMCheck()
            %memory check
            [user, sys] = memory;
            memUsage = user.MemUsedMATLAB/1e9;
            memSys = sys.SystemMemory.Available/1e9;
            fprintf('Memory usage: %2.2f GB (%2.2f%%) \n', memUsage, memUsage/memSys*100);
            if(memUsage>memSys*GC.MEM_CRITICAL)
                warning('Critical memory');
                notify(ECMIO, critical_memory);
            elseif(memUsage>memSys*GC.MEM_LOW)
                warning('System low memory');
                ECMIO.cleanCashflow();
            end
        end
        
        function reload = factorsNeedGenerate(LOB)
            GP = Params.instance;
            try
                [factorAY, factorCY] = ECMIO.loadFactors(LOB);
            catch err
                if(strcmp(err.identifier, 'MATLAB:load:couldNotReadFile'))
                    if(~isdir(GP.saved))
                        mkdir(GP.saved);
                        fprintf(['Dir ' GP.saved ' created \n']);
                    else
                        fprintf('Factors of %s have not been generated, starting simulation\n', LOB.name);
                    end
                    reload = true;
                    return;
                else
                    rethrow(err);
                end
            end
            
            if(size(factorAY,1) < GP.N)
                reload = true;
            else
                LOB.factorAY = factorAY(1:GP.N , :);
                LOB.factorCY = factorCY(1:GP.N , :);
                reload = false;
            end
            
        end
        
        function loadLineInfo(path)
            [~, ~, LOBNames] = xlsread(path,'info','A1:A4');
            %fields 
        end
        
        function cleanCashflow()
            app = ecmRuntimeController();
            LOBs = app.LOBs;
            BLs = app.BLs;
            %LOB
            for i=1:length(LOBs)
                LOBs(i).clean;
            end
            %BL
            for i=1:length(BLs)
                BLs(i).cashflow = [];
            end
            %display
            app.statusUpdate('cashflow has been cleaned');
        end
        
    end
end
