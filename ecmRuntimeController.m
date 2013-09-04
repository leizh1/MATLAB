% This object is the main runtime controller that connects model and view. 
% It controls model calculation, coordinates the data flow, and responds to GUI events.


classdef ecmRuntimeController < Singleton
    events
        
    end
    
    properties
        %objects link
        handles %GUI handles of all GUIs
        Drivers %Economic Driver holder
        LOBs %LOB holder
        BLs %BL holder
        lineFactory %lineFactory object
        analyticModule %analytical module object
        
        guiData %essential data to start GUI
        tags %Colection of all tags
        resultBLs %filtered BL
        selectedBL %Selected BL
        cashflow %Current cashflow result
        gcf %Current graphic figure handle
        container %Hidden panel container
        mainWindow %The main window
        rateModule %rate module instance
        
        %cGraph
    end
    
    methods(Static)
        function obj = instance()
            obj = ecmRuntimeController();
        end
        
        function obj = ecmRuntimeController()
            persistent uniqueInstance
            if(isempty(uniqueInstance))
                display('Creating a new ecmRuntimeController class');
                %obj created automatically
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
       
        function handles = getHandles(gui)
            guidata(gui,guihandles(gui)); %Store or retrieve GUI data
            handles = guihandles(gui); %Create structure of handles
        end
    end
    
    methods
        function startGUI(obj)
        %The function= starts to load the main panel and other sub panels
            %load pre-defined guidata
            GP = Params();
            load(GP.guiData);
            obj.guiData = guiData;
            %init value
            %default; %load default value
            Params;
            %start GUI
            MainDialog;
            %loading
            obj.statusUpdate('Loading Graphical User Interface...(1%%)');
            %container
            obj.container = figure;
            set(obj.container, 'Visible', 'off');
            %loading Panels
            nPanel = length(get(obj.handles.pl_tasks, 'Children'));
            base_ix = 2;
            end_ix = base_ix + nPanel - 1;
            %load first panel
            handles = obj.loadSubPanel(obj.guiData.panels(2,3), ...
                obj.guiData.panels(2,2), obj.mainWindow, obj.container);
            %display first panel
            obj.swapPanel(obj.handles.(obj.guiData.panels{2,2}), [], obj.handles.(obj.guiData.main_frame), obj.container);
            
            %load rest
            handles = obj.loadSubPanel(obj.guiData.panels(base_ix+1:end_ix,3), ...
                obj.guiData.panels(base_ix+1:end_ix,2), obj.mainWindow, obj.container);
            
            %finished loading
            obj.statusUpdate('Interface loaded.');
        end
        
        function newHandles = addGuidata(obj, handles)
            fields = fieldnames(handles);
            for i=1:length(fields)
                field = fields{i};
                data = handles.(field);
                obj.handles.(field) = data;
            end
            newHandles = obj.handles;
        end
        
        %% load  panels
        function handles = loadSubPanel(obj, file, child_panel, gui, target_frame)
            % Loads sub panels
            % Parameters:
            %  file, string of fig file name of the fig being loaded
            %  child_panel, panel being loaded to main figure
            %  tartget_frame, string of target frame tag
            %  gui, handles of main window
            % Output:
            %  handles
            
            if(length(file)~=length(child_panel))
                error('Error in loading parameter: fig files number is not the same as child panel number');
            end
            
            %hide main frame
            hl_main = guidata(gui);
            
            for i=1:length(file)
                %status
                obj.statusUpdate(['Loading Graphical User Interface: ' child_panel{i} ' (' num2str(int8(i/length(file)*100)) '%%) \n']);
                
                %load panel invisibly
                %pl_init = initPanel('Visible', 'off');
                pl_sub = openfig(file{i}, 'new', 'invisible');
                
                %get handles
                handles_sub = obj.getHandles(pl_sub);
                hl_main = guidata(gui); %not using getHandles prevent guidata being overwritten
                
                %move sub panel
                set(handles_sub.(child_panel{i}), 'Parent', target_frame);
                set(handles_sub.(child_panel{i}), 'Visible', 'off');

                %clean up
                delete(pl_sub);
                
                %update handle structure
                obj.addGuidata(handles_sub);
                
                
            end
            
            %return handles
            guidata(obj.mainWindow, obj.handles);
            handles = obj.handles;
            
            %display main frame
            %set(hl_main.(tartget_frame), 'Visible', 'on');
        end
        
        function swapPanel(obj, newPanel, oldPanel, targetFrame, container)
            if(oldPanel)
                set(oldPanel, 'Parent', container);
                set(oldPanel, 'Visible', 'off');
                %refresh
                %drawnow;
            end
            set(newPanel, 'Parent', targetFrame);
            set(newPanel, 'Position', [0,0,160,48]);
            set(newPanel, 'Visible', 'on');
            drawnow;
        end
           
        %% initiation
        function initiation(obj, GP)
        % Imports external data , initiates all the necessary objects
        % Input:
        %  GP: Global parameters
            armsBridge = ARMSBridge();
            parameterRiskModule = ParameterRiskModule();
        
            %economic drivers
            obj.statusUpdate('Loading Economic Drivers');
            obj.Drivers = EconomicDrivers.loadDrivers();
            
            %currency rates
            obj.statusUpdate('Updating currency rate');
            obj.rateModule.loadCurve();
            
            % LOBs construction
            obj.statusUpdate('Updating LOB');
            obj.lineFactory.createLOBs();
            
            % BL construction
            obj.statusUpdate('Updating BL');
            obj.lineFactory.createBudgetLine();
            obj.lineFactory.applyMapping();
            
            %tags
            obj.statusUpdate('Updating Tags');
            obj.analyticModule.updateTags();
            
            
            %%finishing
            obj.statusUpdate('Initialization complete!');
        end
        
        %% INITIATION PANEL UPDATE
        function initPanelUpdate(obj)
            return;
        end
        
        %% LOB PANEL UPDATE
        function lobPanelUpdate(obj)
            % updates the LOB panel everytime user changes the interface elements.
            
            %listbox
            set(obj.handles.lb_lob, 'String', {obj.LOBs.name});
            selected = get(obj.handles.lb_lob, 'Value');
            %data
            LOB = obj.LOBs(selected);
            %set properties
            set(obj.handles.sub_pl_lob_properties, 'Title', LOB.name);
            set(obj.handles.ed_lob_nAY, 'String', LOB.nAY);
            set(obj.handles.ed_lob_nFAY, 'String', LOB.nFAY);
            set(obj.handles.ed_lob_nCY, 'String', LOB.nCY);
            if(max(LOB.duration)==min(LOB.duration))
                set(obj.handles.ed_lob_duration, 'String', LOB.duration(1));
            else
                set(obj.handles.ed_lob_duration, 'String', 'Multiple values');
            end
            set(obj.handles.ed_lob_yr0, 'String', LOB.yr0);
            %set exposures
            set(obj.handles.tb_lob_factorAY, 'Data', LOB.betaAY);
            set(obj.handles.tb_lob_factorCY, 'Data', LOB.betaCY);
            % set parameter risk
            set(obj.handles.ed_lob_modelRef, 'String',LOB.modelRefName);
            set(obj.handles.ed_lob_armsFlag, 'String',LOB.ARMSFlag);
            set(obj.handles.ed_lob_credibility, 'String',LOB.credibilityFactor);
            set(obj.handles.ed_lob_loss, 'String', mean(LOB.expLoss));
            %set(obj.handles.ed_lob_majorLine, 'String', LOB.majorLine);
            %set(obj.handles.ed_lob_BL, 'String', mean(LOB.BL));
            
            %set pattern
            if(get(obj.handles.pu_lob_pattern_format, 'Value') == 1)
                %percentage
                pattern = LOB.developmentPattern;
                set(obj.handles.tb_lob_pattern, 'ColumnFormat', []);
                if(get(obj.handles.cb_lob_pattern_sum, 'Value') == 1)
                    %sum AY
                    pattern = sum(LOB.developmentPatternNum,1);
                    pattern = pattern./sum(pattern);
                end
                %table
                %set(obj.handles.tb_lob_pattern, 'Data', pattern);
                %graph
                cGraph = plot(obj.handles.ax_lob_pattern, LOB.yr0:LOB.yr0+LOB.nCY-1, pattern');
            else
                %numerical
                pattern = LOB.developmentPatternNum;
                if(get(obj.handles.cb_lob_pattern_sum, 'Value') == 1)
                    pattern = sum(pattern,1);
                end
                %format = cell(1,LOB.nCY);
                %format(:) = {'bank'};
                %set(obj.handles.tb_lob_pattern, 'ColumnFormat', format);
                %graph
                cGraph = plot(obj.handles.ax_lob_pattern, LOB.yr0:LOB.yr0+LOB.nCY-1, pattern');
            end
            
            %Graph format
            %fonts
            set(obj.handles.ax_lob_pattern, 'FontSize', 8);
            %sum
            if(get(obj.handles.cb_lob_pattern_sum, 'Value') == 1)
                %data preparation
                volume = sum(LOB.volume);
                %legend
                legend(obj.handles.ax_lob_pattern, 'Accident Year Sum');
                %row name
                set(obj.handles.tb_lob_pattern, 'RowName', 'AY');
            else
                %volume
                volume = LOB.volume;
                %legend
                legend(obj.handles.ax_lob_pattern, num2str([(LOB.yr0-LOB.nAY+1):(LOB.yr0+LOB.nFAY)]'))
                %row name
                set(obj.handles.tb_lob_pattern, 'RowName', (LOB.yr0-LOB.nAY+1):(LOB.yr0+LOB.nFAY));
            end
            %column row
            set(obj.handles.tb_lob_pattern, 'ColumnName', {'Volume', (LOB.yr0):(LOB.yr0+LOB.nCY-1)});
            %hide graph frame
            if(get(obj.handles.rb_lob_pattern_edit, 'Value')==1)
                set(obj.handles.ax_lob_pattern, 'Visible', 'off');
                legend off;
            end
            
            %set pattern into table
            set(obj.handles.tb_lob_pattern, 'Data', [volume, pattern]);
        end

        function lobPanelSave(obj)
        % Saves the LOB panel when user changes the number in LOB panel
        
            %listbox
            set(obj.handles.lb_lob, 'String', {obj.LOBs.name});
            selected = get(obj.handles.lb_lob, 'Value');
            %data
            LOB = obj.LOBs(selected);
            %save properties
            lobData.nAY = str2num(get(obj.handles.ed_lob_nAY, 'String'));
            lobData.nFAY = str2num(get(obj.handles.ed_lob_nFAY, 'String'));
            lobData.nCY = str2num(get(obj.handles.ed_lob_nCY, 'String'));
            lobData.yr0 = str2num(get(obj.handles.ed_lob_yr0, 'String'));
            lobData.betaAY = get(obj.handles.tb_lob_factorAY, 'Data');
            lobData.betaCY = get(obj.handles.tb_lob_factorCY, 'Data');
            %lobData.volume = get(obj.handles.tb_lob_volume, 'Data');
            %set pattern
            if(get(obj.handles.pu_lob_pattern_format, 'Value') == 1)
                %percentage
                pattern = get(obj.handles.tb_lob_pattern, 'Data');
                lobData.developmentPattern = pattern(:,2:end);
            else
                %numerical
                pattern = get(obj.handles.tb_lob_pattern, 'Data');
                lobData.developmentPatternNum = pattern(:,2:end);
            end
            
            %validate the LOB data
            
            %save to LOB
            LOB.updateParams(lobData);
        end
        
        %% driver PANEL UPDATE
        function driverPanelUpdate(obj)
        % Updates the Economic Driver panel elements.
        
            %listbox
            set(obj.handles.lb_ed, 'String', {obj.Drivers.name});
            selected = get(obj.handles.lb_ed, 'Value');
            %data
            driver = obj.Drivers(selected);
            driverData.name = driver.name;
            driverData.nAY = driver.nAY;
            driverData.nFAY = driver.nFAY;
            driverData.nCY = driver.nCY;
            driverData.type = driver.type;
            driverData.yr0 = driver.yr0;
            driverData.attributes = [fields(driver.attributes), struct2cell(driver.attributes)];
            driverData.rule = [fields(driver.rules), struct2cell(driver.rules)];
            %driverData.simulation = driver.simulation;
            %set properties
            set(obj.handles.sub_pl_ed_properties, 'Title', driverData.name);
            set(obj.handles.ed_ed_nAY, 'String', driverData.nAY);
            set(obj.handles.ed_ed_nFAY, 'String', driverData.nFAY);
            set(obj.handles.ed_ed_nCY, 'String', driverData.nCY);
            set(obj.handles.ed_ed_yr0, 'String', driverData.type);
            set(obj.handles.ed_ed_type, 'String', driverData.type);
            set(obj.handles.ed_ed_yr0, 'String', driverData.yr0);
            %set exposures
            set(obj.handles.tb_ed_attributes, 'Data', driverData.attributes);
            set(obj.handles.tb_ed_extension, 'Data', driverData.rule);
            %drop down menu
            selection = obj.guiSelection(obj.handles.pm_ed_sim);
            
            
            if(strcmp(selection, 'Statistic'))%===============================
                %disable nav bar
                set(obj.handles.t_ed_pages, 'Visible', 'off');
                set(obj.handles.ed_ed_sim, 'Visible', 'off');
                set(obj.handles.t_ed_sim, 'Visible', 'off');
                set(obj.handles.slider_ed_sim, 'Visible', 'off');
                %statistics
                query = {1 5 90 95 99};
                result = AnalyticModule.getStatistics(driver.simulation, 1, query);
                [statMat, rowName] = AnalyticModule.formatStatisticResult(result);
                set(obj.handles.tb_ed_sim, 'Data', statMat);
                %row name
                set(obj.handles.tb_ed_sim, 'RowName', rowName);
                
                
            elseif(strcmp(selection, 'Simulation'))%===============================
                %enable nav bar
                set(obj.handles.t_ed_pages, 'Visible', 'on');
                set(obj.handles.ed_ed_sim, 'Visible', 'on');
                set(obj.handles.t_ed_sim, 'Visible', 'on');
                set(obj.handles.slider_ed_sim, 'Visible', 'on');
                %simulation page
                pageLength = 1000;
                pages = ceil(size(driver.simulation, 1)/pageLength);
                driverData.sim = zeros(pageLength, size(driver.simulation, 2), pages);
                %init simulation
                if(max(driverData.sim(:,:,1))==0)
                    for i=1:pages
                        startRow = pageLength*(i-1)+1;
                        endRow = pageLength*i;
                        if(endRow>size(driver.simulation,1))
                            endRow = size(driver.simulation,1);
                        end
                        driverData.sim(:,:,i) = driver.simulation(startRow:endRow, :);
                    end
                end
                %pages
                set(obj.handles.t_ed_sim, 'String', ['/', num2str(pages)]);
                set(obj.handles.slider_ed_sim, 'UserData', pages); %user data for the slider
                currentPage = str2num(get(obj.handles.ed_ed_sim, 'String'));
                if( currentPage < 1)
                    currentPage = 1;
                elseif(currentPage>pages)
                    currentPage = pages;
                end
                startRow = pageLength*(currentPage-1)+1;
                endRow = pageLength*currentPage;
                set(obj.handles.tb_ed_sim, 'Data', driverData.sim(:,:,currentPage));
                set(obj.handles.tb_ed_sim, 'RowName', startRow:endRow);
                
                %page bar
                if(pages == 1)
                    set(obj.handles.slider_ed_sim, 'Enable', 'off');
                else
                    set(obj.handles.slider_ed_sim, 'Enable', 'on');
                    set(obj.handles.slider_ed_sim, 'SliderStep', [1/(pages-1), 0.1]);
                    set(obj.handles.slider_ed_sim, 'Value', (currentPage-1)/(pages-1));
                end
            end
            %column head
            if(strcmp(driver.type, 'AY'))
                set(obj.handles.tb_ed_sim, 'ColumnName', (driverData.yr0-driverData.nAY+1):(driverData.yr0+driverData.nFAY));
            elseif(strcmp(driver.type, 'CY'))
                set(obj.handles.tb_ed_sim, 'ColumnName', (driverData.yr0):(driverData.yr0+driverData.nCY-1));
            end
            
            %plot if figure exsits
            if(ishandle(obj.gcf))
                obj.driverPanelPlot;
            end
        end
        
        function driverPanelPlot(obj)
        % Plot driver dispersion by CY on figure
        
            %data
            selected = get(obj.handles.lb_ed, 'Value');
            driver = obj.Drivers(selected);
            %get figure
            %if a figure contains no axes, get(gcf,'CurrentAxes') returns the empty matrix. 
            %gca function actually creates an axes if one does not exist.
            if(obj.gcf)
                figure(obj.gcf);
                gca;
            else
                obj.gcf = figure;
                gca;
            end
            %set name
            set(obj.gcf, 'Name', driver.name);
            %draw graph
            ReportModule.displayAggregatedCashflowBySurf(driver.simulation, get(obj.gcf, 'CurrentAxes'), driver);
        end
        
        %% BL PANEL UPDATE
        function blPanelUpdate(obj)
        % Updates the BL panel elements
            %listbox
            set(obj.handles.lb_bl, 'String', {obj.BLs.name});
            selected = get(obj.handles.lb_bl, 'Value');
            %data
            BL = obj.BLs(selected);
            %set properties
            set(obj.handles.sub_pl_bl_properties, 'Title', BL.name);
            set(obj.handles.ed_bl_nAY, 'String', BL.nAY);
            set(obj.handles.ed_bl_nFAY, 'String', BL.nFAY);
            set(obj.handles.ed_bl_nCY, 'String', BL.nCY);
            set(obj.handles.ed_bl_yr0, 'String', BL.yr0);
            %set mapping
            set(obj.handles.tb_bl_mapping, 'Data', BL.mapping);
            set(obj.handles.tb_bl_mapping, 'ColumnFormat', {{obj.LOBs.name}});
            
            %data
            precentage = get(obj.handles.pm_bl_pattern, 'Value');
            sumAY = get(obj.handles.rb_bl_pattern_sum, 'Value');
            
            %pattern data prepare
            if(precentage == 1)
                %percentage
                set(obj.handles.tb_bl_pattern, 'ColumnFormat', []);
                pattern = BL.developmentPattern;
                if(sumAY == 1)
                    %sum AY
                    pattern = sum(BL.developmentPatternNum,1);
                    pattern = pattern./sum(pattern);
                end
            else
                %numerical
                pattern = BL.developmentPatternNum;
                %sum AY
                if(sumAY == 1)
                    pattern = sum(pattern,1);
                end
                %table
                set(obj.handles.tb_bl_pattern, 'Data', round(pattern));
            end
            
            %graph
            if(sumAY == 1)
                bar(obj.handles.ax_bl_pattern, BL.yr0:BL.yr0+BL.nCY-1,pattern');
                %volume
                volume = sum(BL.volume);
                %legend
                legend(obj.handles.ax_bl_pattern, 'Calender Year Sum');
                %row name
                set(obj.handles.tb_bl_pattern, 'RowName', 'AY');
            else
                cGraph = plot(obj.handles.ax_bl_pattern, BL.yr0:BL.yr0+BL.nCY-1, pattern');
                %volume
                volume = BL.volume;
                %legend
                legend(obj.handles.ax_bl_pattern, num2str([(BL.yr0-BL.nAY):(BL.yr0+BL.nFAY-1)]'));
                %row name
                set(obj.handles.tb_bl_pattern, 'RowName', (BL.yr0-BL.nAY):(BL.yr0+BL.nFAY-1));
            end
            
            %fonts
            set(obj.handles.ax_bl_pattern, 'FontSize', 8);
            
            
            %hide graph
            if(get(obj.handles.rb_bl_pattern_view, 'Value') == 1)
                set(obj.handles.ax_bl_pattern, 'Visible', 'off');
                legend off;
            end
            
            
            %table
            set(obj.handles.tb_bl_pattern, 'Data', [volume, pattern]);
            set(obj.handles.tb_bl_pattern, 'ColumnName', {'Volume', (BL.yr0):(BL.yr0+BL.nCY-1)});
        end
        
        %% RUN  PANEL 
        function runPanelUpdate(obj)
        % Updates the Run panel elements.
        
            %obj.runPanelCriteriaUpdate;
            %obj.runPanelInputUpdate;
            %obj.runPanelOutputUpdate;
            selectedType = obj.guiSelection(obj.handles.pm_run_sim);
            if(strcmp(selectedType, 'Risk attribution'))
                %table
                set(obj.handles.tb_run_analytics, 'Visible', 'off');
                %slider
                set(obj.handles.slider_run_sim, 'Visible', 'off');
                set(obj.handles.t_run_simN, 'Visible', 'off');
                set(obj.handles.ed_run_sim, 'Visible', 'off');
                set(obj.handles.t_run_sim, 'Visible', 'off');
                %calculate risk attribution
                obj.updateRiskAttribution();
            else
                if(strcmp(selectedType, 'Cash flow'))
                    %table
                    set(obj.handles.tb_run_analytics, 'Visible', 'on');
                    %slider
                    set(obj.handles.tb_run_analytics, 'Visible', 'on');
                    set(obj.handles.slider_run_sim, 'Visible', 'on');
                    set(obj.handles.t_run_simN, 'Visible', 'on');
                    set(obj.handles.ed_run_sim, 'Visible', 'on');
                    currentSim = str2num(get(obj.handles.ed_run_sim, 'String'));
                    set(obj.handles.tb_run_analytics, 'Data', obj.cashflow(:,:,currentSim));
                elseif(strcmp(selectedType, 'Statistic'))
                    %table
                    set(obj.handles.tb_run_analytics, 'Visible', 'on');
                    %slider
                    set(obj.handles.tb_run_analytics, 'Visible', 'on');
                    set(obj.handles.slider_run_sim, 'Visible', 'off');
                    set(obj.handles.t_run_simN, 'Visible', 'off');
                    set(obj.handles.ed_run_sim, 'Visible', 'off');
                    set(obj.handles.t_run_sim, 'Visible', 'off');
                elseif(strcmp(selectedType, 'Ranked results'))
                    %table
                    set(obj.handles.tb_run_analytics, 'Visible', 'on');
                    %slider
                    set(obj.handles.tb_run_analytics, 'Visible', 'on');
                    set(obj.handles.slider_run_sim, 'Visible', 'off');
                    set(obj.handles.t_run_simN, 'Visible', 'off');
                    set(obj.handles.ed_run_sim, 'Visible', 'off');
                    set(obj.handles.t_run_sim, 'Visible', 'off');
                end
                %run the calculation
                if(obj.selectedBL)
                    obj.runPanelRun();
                end
            end
            
            
            %if there is no selection of BL, disable table
            if(get(obj.handles.tb_run_analytics, 'UserData') == 1)
                set(obj.handles.tb_run_analytics, 'Enable', 'on');
            else
                set(obj.handles.tb_run_analytics, 'Enable', 'off');
                set(obj.handles.slider_run_sim, 'Visible', 'off');
                set(obj.handles.t_run_simN, 'Visible', 'off');
                set(obj.handles.ed_run_sim, 'Visible', 'off');
                set(obj.handles.t_run_sim, 'Visible', 'off');
            end
            
            
        end
        
        function runPanelCriteriaUpdate(obj)
        % Updates Input criteria listbox in Run panel when user changes it's vaue
        
            %selection
            criteriaSelection = obj.guiSelection(obj.handles.lb_run_criteria);
            %type
            if(strcmp(criteriaSelection, 'Region'))
                set(obj.handles.lb_run_input, 'String', obj.tags.Region);
                
                %tooltip
                set(obj.handles.lb_run_input, 'TooltipString', 'Select resion(s)');
                %status
                obj.statusUpdate(['You have selected all Budget Lines in region ' obj.tags.Region{1} '. Click Run to see the calculations']);
            elseif(strcmp(criteriaSelection, 'Profit Center'))
                set(obj.handles.lb_run_input, 'String', obj.tags.ProfitCenter);
                %multi selection
                set(obj.handles.lb_run_input, 'Max', length(obj.tags.ProfitCenter));
                %tooltip
                set(obj.handles.lb_run_input, 'TooltipString', 'Select Profit Center(s)');
                %status
                obj.statusUpdate( ['You have selected all Budget Lines in Profit Center: ' obj.tags.ProfitCenter{1} '. Click Run to see the calculations']);
            elseif(strcmp(criteriaSelection, 'Type'))
                set(obj.handles.lb_run_input, 'String', obj.tags.P_C);
                
                %multi selection
                set(obj.handles.lb_run_input, 'Max', length(obj.tags.P_C));
                %tooltip
                set(obj.handles.lb_run_input, 'TooltipString', 'Select Type(s)');
                %status
                obj.statusUpdate(['You have selected all Budget Lines in Type: ' obj.tags.P_C{1} '. Click Run to see the calculations']);
            elseif(strcmp(criteriaSelection, 'Budget Line'))
                set(obj.handles.lb_run_input, 'String', 'All Budget Lines');
                %tooltip
                set(obj.handles.lb_run_output, 'TooltipString', 'Select Budget Line(s)');
                %status
                obj.statusUpdate(['You have selected Budget Line: ' obj.BLs(1).name '. Please choose BL(s) and run calculation.']); 
            end
            %max
            if(~strcmp(criteriaSelection, 'Budget Line'))
                %multi selection
                set(obj.handles.lb_run_input, 'Max', length(get(obj.handles.lb_run_input, 'String')));
            end
        end
        
        function runPanelInputUpdate(obj)
        % Updates second level Input listbox in Run panel when user changes it's vaue
            inputSelection = obj.guiSelection(obj.handles.lb_run_input);
            criteriaSelection = obj.guiSelection(obj.handles.lb_run_criteria);
            if(~strcmp(criteriaSelection, 'Budget Line'))
                set(obj.handles.lb_run_output, 'String', vertcat('All', inputSelection));
                set(obj.handles.lb_run_output, 'Max', length(obj.resultBLs));
                %set max
                set(obj.handles.lb_run_output, 'Max', length(inputSelection));
            else
                set(obj.handles.lb_run_output, 'String', 'All Budget Lines');

            end
        end
        
        function runPanelOutputUpdate(obj)
        % Updates output listbox in Run panel when user changes it's vaue
        
            %criteria
            criteriaSelection = obj.guiSelection(obj.handles.lb_run_criteria);
            %type
            [outputSelection, outputSelected] = obj.guiSelection(obj.handles.lb_run_output);
            if(outputSelected == 1)
                %select all
                outputContents = get(obj.handles.lb_run_output, 'String');
                outputSelected = (2:length(outputContents))';
                outputSelection = outputContents(outputSelected);
            end
            %filteredBLArray
            filteredBLArray = [];
            %tag
            tags = cell(length(outputSelection), 2);
            
            %criteria
            if(strcmp(criteriaSelection, 'Region'))
                tags(:,1) = {'Region'};
                tags(:,2) = outputSelection;
                filteredBLArray = AnalyticModule.filterByTag(obj.BLs, tags);
                set(obj.handles.lb_run_list, 'String', {filteredBLArray.name});
                %tip
                selection = obj.listSelection(outputSelection);
                obj.statusUpdate( ['You have selected all Budget Lines in Region ' selection '. Click Run to see the result']);
                
            elseif(strcmp(criteriaSelection, 'Profit Center'))
                tags(:,1) = {'ProfitCenter'};
                tags(:,2) = outputSelection;
                filteredBLArray = AnalyticModule.filterByTag(obj.BLs, tags);
                set(obj.handles.lb_run_list, 'String', {filteredBLArray.name});
                %tip
                selection = obj.listSelection(outputSelection);
                obj.statusUpdate( ['You have selected all Budget Lines in Profit Center ' selection '. Click Run to see the result']);
            elseif(strcmp(criteriaSelection, 'Type'))
                tags(:,1) = {'P_C'};
                tags(:,2) = outputSelection;
                filteredBLArray = AnalyticModule.filterByTag(obj.BLs, tags);
                set(obj.handles.lb_run_list, 'String', {filteredBLArray.name});
                %tip
                selection = obj.listSelection(outputSelection);
                obj.statusUpdate(['You have selected all Budget Lines in ' selection '. Click Run to see the result']);
            elseif(strcmp(criteriaSelection, 'Budget Line'))
                set(obj.handles.lb_run_list, 'String', {obj.BLs.name});
                %select all
                set(obj.handles.lb_run_list, 'Value', [1:length(obj.BLs)]);
                filteredBLArray = obj.BLs;
                %tip
                %obj.statusUpdate('You have selected all Budget Lines. It will take a long time to calculate the results.');
            end
            %save filter result
            obj.resultBLs = filteredBLArray;
            obj.selectedBL = filteredBLArray;
            %max
            set(obj.handles.lb_run_list, 'max', length(filteredBLArray));
            %select all
            if(~strcmp(criteriaSelection, 'Budget Line'))
                set(obj.handles.lb_run_list, 'Value', [1:length(filteredBLArray)]');
            end
        end
        
        function selection = listSelection(obj, typeSelection)
        % Group selection in the Run panel.
            selection=[];
            for i=1:length(typeSelection)
                if(i==1) %first
                    selection =typeSelection{i};
                elseif(i==length(typeSelection)) %last
                    selection =[selection ' and ' typeSelection{i}];
                else
                    selection =[selection ', ' typeSelection{i}];
                end
            end
        end
        
        function runPanelListUpdate(obj)
        % Updates the status bar when listbox changes.
            selected = get(obj.handles.lb_run_list, 'Value');
            obj.selectedBL = obj.resultBLs(selected);
            count = length(selected);
            if(count <= 5)
                selections = obj.listSelection({obj.selectedBL.name});
                obj.statusUpdate(['You have selected Budget Line ' selections '. Click Run to start the calculation']);
            else
                obj.statusUpdate(['You have selected ' num2str(count) ' Budget Lines. Click Run to start the calculation']);
            end
        end
        
        function [cashflow, nAY, nFAY, nCY] = runPanelCalculation(obj)
        % Calculate cashflow by criteria set by user
            obj.statusUpdate(['Calculating ' num2str(length(obj.selectedBL))  ' Budget Lines.']);
            %cashflow
            [cashflow, nAY, nFAY, nCY] = AnalyticModule.groupCashflow(obj.selectedBL);
            obj.cashflow = cashflow;
            %update the table info
            set(obj.handles.tb_run_analytics, 'UserData', 1);
        end
        
        function runPanelRun(obj)
        % Aggregate cashflow and display on the panel when user clicks 'Run'
        
            %cashflow
            [cashflow, nAY, nFAY, nCY]  = obj.runPanelCalculation;
            aggregatedCashflowCY = sum(cashflow,1);
            %yr0
            GP = Params.instance;
            yr0 = GP.yr0;
            %table
            currentSim = str2num(get(obj.handles.ed_run_sim, 'String'));
            if( currentSim < 1)
                currentSim = 1;
            elseif(currentSim>GP.N)
                currentSim = GP.N;
            end
            set(obj.handles.t_run_simN, 'String', ['/', num2str(GP.N)]);
            %sim bar
            set(obj.handles.slider_run_sim, 'UserData', GP.N);
            set(obj.handles.slider_run_sim, 'SliderStep', [1/(GP.N-1), 0.1]);
            set(obj.handles.slider_run_sim, 'Value', (currentSim-1)/(GP.N-1));
            %calculation
            obj.statusUpdate('Calculating...');
            %selection
            type = get(obj.handles.pm_run_sim, 'Value');
            contents = get(obj.handles.pm_run_sim, 'String');
            selectedType = contents{type};
            if(strcmp(selectedType, 'Cash flow'))
                %cash flow
                set(obj.handles.tb_run_analytics, 'Data', cashflow(:,:,currentSim));
                format = cell(1,size(cashflow,2));%%
                format(:) = {'bank'};
                set(obj.handles.tb_run_analytics, 'ColumnFormat', format);
                %column
                set(obj.handles.tb_run_analytics, 'RowName', (yr0-nAY):(yr0+nFAY-1));
                set(obj.handles.tb_run_analytics, 'ColumnName', (yr0):(yr0+nCY-1));
            elseif(strcmp(selectedType, 'Ranked Results'))
                %
            elseif(strcmp(selectedType, 'Statistic'))
                %Statistics
                query = {1 5 90 95 99};
                result = AnalyticModule.getStatistics(aggregatedCashflowCY, 3, query);
                [statMat, rowName] = AnalyticModule.formatStatisticResult(result);
                set(obj.handles.tb_run_analytics, 'Data', statMat);
                %column
                set(obj.handles.tb_run_analytics, 'ColumnName', (yr0):(yr0+nCY-1));
                %row name
                set(obj.handles.tb_run_analytics, 'RowName', rowName);
            end
            %panel update
            obj.runPanelUpdate;
            obj.statusUpdate('Calculation completed');
            
            %plot
            if(get(obj.handles.cb_run_plot, 'Value')==1)
                obj.runPanelPlot;
            end
        end
        
        function runPanelPlot(obj)
        % Plot the cashflow distribution by CY
        
            %cashflow
            [cashflow, nAY, nFAY, nCY]  = obj.runPanelCalculation;
            aggregatedCashflowCY = sum(cashflow,1);
            %new figure
            if(obj.gcf) %Current figure handle
                figure(obj.gcf);
                gca; %Current axes handle
            else
                obj.gcf = figure;
                gca;
            end
            %draw graph
            ReportModule.displayAggregatedCashflowBySurf(aggregatedCashflowCY, get(obj.gcf, 'CurrentAxes'));
            %set name
            set(obj.gcf, 'Name', 'Cash flow by Canlendar Year');
            
        end
        
        function updateRiskAttribution(obj)
            ax = obj.handles.ax_risk_attribution;
            
        end
        
        %% OTHER FUNCTIONS
        function update = sliderPaging(obj, hObject, targetEditBox, updateFunction)
            position = get(hObject, 'Value');
            pages = get(hObject, 'UserData');
            interval = 1/(pages-1);
            
            if(mod(position, interval) > interval/2)
                cPage = ceil(single(position/interval))+1;
                position = (cPage-1)*interval;
            else
                cPage = floor(single(position/interval))+1;
                position = (cPage-1)*interval;
            end
            %update
            if(cPage ~= str2num(get(targetEditBox, 'String')))
                set(hObject, 'Value', position);
                %update page textField
                set(targetEditBox, 'String', cPage);
                %update panel
                obj.(updateFunction);
            end
        end
        
        function [selection, selected] = guiSelection(obj, handle)
            selected = get(handle,'Value');
            contents = get(handle,'String');
            selection = contents(selected);
        end
        
        function statusUpdate(obj, status, level)
            if(~isempty(obj.handles))
                set(obj.handles.statusBar, 'String', status);
                drawnow update;
                %refresh status bar
                fprintf(strcat(status, '\n'));
            else
                fprintf(strcat(status, '\n'));
            end
        end
        
        %% getter for easier access
        function rm = get.rateModule(obj)
            rm = RateModule();
        end
        
        function lf = get.lineFactory(obj)
            lf = LineFactory();
        end
        
        function am = get.analyticModule(obj)
            am = AnalyticModule();
        end
        
        function lobs = get.LOBs(obj)
            lobs = obj.lineFactory.LOBArray;
        end
        
        function bls = get.BLs(obj)
            bls = obj.lineFactory.BLArray;
        end
        
        function tags = get.tags(obj)
            tags = obj.analyticModule.tags;
        end
    end
    
end
