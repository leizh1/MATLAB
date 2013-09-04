function varargout = driversPanel(varargin)
% DRIVERSPANEL MATLAB code for driversPanel.fig
%      DRIVERSPANEL, by itself, creates a new DRIVERSPANEL or raises the existing
%      singleton*.
%
%      H = DRIVERSPANEL returns the handle to a new DRIVERSPANEL or the handle to
%      the existing singleton*.
%
%      DRIVERSPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRIVERSPANEL.M with the given input arguments.
%
%      DRIVERSPANEL('Property','Value',...) creates a new DRIVERSPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before driversPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to driversPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help driversPanel

% Last Modified by GUIDE v2.5 10-Jan-2013 13:40:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @driversPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @driversPanel_OutputFcn, ...
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


% --- Executes just before driversPanel is made visible.
function driversPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to driversPanel (see VARARGIN)

% Choose default command line output for driversPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes driversPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = driversPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function eb_ed_path_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function eb_ed_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_ed_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_ed.
function lb_ed_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.driverPanelUpdate();

% --- Executes during object creation, after setting all properties.
function lb_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_ed_nAY_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_ed_nAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ed_nAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_ed_nFAY_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_ed_nFAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ed_nFAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_ed_nCY_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_ed_nCY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ed_nCY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_ed_type_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_ed_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ed_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_ed_yr0_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_ed_yr0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ed_yr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_ed_revert.
function pb_ed_revert_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.driverPanelUpdate();

% --- Executes on button press in pb_ed_save.
function pb_ed_save_Callback(hObject, eventdata, handles)


% --- Executes on slider movement.
function slider_ed_sim_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
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
if(cPage ~= str2num(get(handles.ed_ed_sim, 'String')))
    set(hObject, 'Value', position);
    %update page textField
    set(handles.ed_ed_sim, 'String', cPage);
    %update panel
    app = ecmRuntimeController.instance();
    app.driverPanelUpdate();
end


% --- Executes during object creation, after setting all properties.
function slider_ed_sim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ed_sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function ed_ed_sim_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.driverPanelUpdate();

% --- Executes during object creation, after setting all properties.
function ed_ed_sim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ed_sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_ed_sim.
function pm_ed_sim_Callback(hObject, eventdata, handles)
% hObject    handle to pm_ed_sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_ed_sim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_ed_sim
app = ecmRuntimeController.instance;
app.driverPanelUpdate();

% --- Executes during object creation, after setting all properties.
function pm_ed_sim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_ed_sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pb_ed_plot.
function pb_ed_plot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ed_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
app = ecmRuntimeController.instance;
app.driverPanelPlot();
