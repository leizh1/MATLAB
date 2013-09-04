function varargout = runPanel(varargin)
% RUNPANEL MATLAB code for runPanel.fig
%      RUNPANEL, by itself, creates a new RUNPANEL or raises the existing
%      singleton*.
%
%      H = RUNPANEL returns the handle to a new RUNPANEL or the handle to
%      the existing singleton*.
%
%      RUNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNPANEL.M with the given input arguments.
%
%      RUNPANEL('Property','Value',...) creates a new RUNPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runPanel

% Last Modified by GUIDE v2.5 07-Jan-2013 16:21:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @runPanel_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before runPanel is made visible.
function runPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runPanel (see VARARGIN)

% Choose default command line output for runPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = runPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pb_run_plot.
function pb_run_plot_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.runPanelPlot();

% --- Executes on button press in pb_run_run.
function pb_run_run_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.runPanelRun();

% --- Executes during object creation, after setting all properties.
function slider_run_sim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_run_sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in pm_run_sim.
function pm_run_sim_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
selectedType = get(handles.pm_run_sim, 'Value');
app.runPanelUpdate();

% --- Executes during object creation, after setting all properties.
function pm_run_sim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_run_sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function lb_run_results_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_run_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_run_sim_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_run_sim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_run_sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_run_criteria.
function lb_run_criteria_Callback(hObject, eventdata, handles)
%reset selection
set(handles.lb_run_input,'Value', 1);
set(handles.lb_run_output,'Value', 1);
set(handles.lb_run_list,'Value', 1);
app = ecmRuntimeController.instance();
app.runPanelCriteriaUpdate;
app.runPanelInputUpdate;
app.runPanelOutputUpdate;


% --- Executes during object creation, after setting all properties.
function lb_run_criteria_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_run_criteria (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_run_input.
function lb_run_input_Callback(hObject, eventdata, handles)
set(handles.lb_run_output,'Value', 1);
set(handles.lb_run_list,'Value', 1);
app = ecmRuntimeController.instance();
app.runPanelInputUpdate();
app.runPanelOutputUpdate();


% --- Executes during object creation, after setting all properties.
function lb_run_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_run_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_run_output.
function lb_run_output_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.runPanelOutputUpdate();

% --- Executes during object creation, after setting all properties.
function lb_run_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_run_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in lb_run_list.
function lb_run_list_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.runPanelListUpdate();

% --- Executes during object creation, after setting all properties.
function lb_run_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_run_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slider_run_sim_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.sliderPaging(hObject, handles.ed_run_sim, 'runPanelUpdate');

% --- Executes on button press in cb_run_plot.
function cb_run_plot_Callback(hObject, eventdata, handles)
% hObject    handle to cb_run_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of cb_run_plot
app = ecmRuntimeController.instance;
if(get(hObject,'Value')==1)
    app.runPanelPlot;
end
