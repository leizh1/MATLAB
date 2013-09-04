function varargout = initPanel(varargin)
% INITPANEL MATLAB code for initPanel.fig
%      INITPANEL, by itself, creates a new INITPANEL or raises the existing
%      singleton*.
%
%      H = INITPANEL returns the handle to a new INITPANEL or the handle to
%      the existing singleton*.
%
%      INITPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INITPANEL.M with the given input arguments.
%
%      INITPANEL('Property','Value',...) creates a new INITPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before initPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to initPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help initPanel

% Last Modified by GUIDE v2.5 23-Aug-2013 15:30:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @initPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @initPanel_OutputFcn, ...
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


% --- Executes just before initPanel is made visible.
function initPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to initPanel (see VARARGIN)

% Choose default command line output for initPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes initPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = initPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ed_iteration_Callback(hObject, eventdata, handles)
% hObject    handle to ed_iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_iteration as text
%        str2double(get(hObject,'String')) returns contents of ed_iteration as a double


% --- Executes during object creation, after setting all properties.
function ed_iteration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start_Btn.
% ==============================Initiation process=========================
%====================================================================
function start_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to start_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GP = Params.instance();
%main app controller
app = ecmRuntimeController.instance();

%Interation
GP.N = str2num(get(handles.ed_iteration, 'String'));
%compression mode
if(get(handles.cb_compression, 'Value') == 0)
    GP.compressionMode = GC.NormalMode;
else
    GP.compressionMode = GC.compressionMode;
end
%LOB

if(get(handles.rb_lob_mat, 'Value'))
    GP.lineInfo = get(handles.eb_lob_path, 'String');
    GP.lineLoadMode = GC.LOAD_MAT;
elseif(get(handles.rb_lob_excel, 'Value'))
    GP.lineInfo = get(handles.eb_lob_path, 'String');
    GP.lineLoadMode = GC.LOAD_EXCEL;
else
    warning('No option selected for LOB loading!');
end

%Drivers
if(get(handles.rb_ed_db, 'Value'))
    error('Selection for Economic Drivers failed: no such option');
elseif(get(handles.rb_ed_mat, 'Value'))
    GP.driverLoadMode = GC.LOAD_MAT;
    GP.driversSource = get(handles.eb_ed_path, 'String');
elseif(get(handles.rb_bl_HDF5, 'Value'))
    GP.driverLoadMode = GC.LOAD_HDF5;
    GP.driversSource = get(handles.eb_ed_path, 'String');
else
    warning('No option selected for LOB loading!');
end

%BL
if(get(handles.rb_bl_db, 'Value'))
    error('Selection for BL failed: no such option');
elseif(get(handles.rb_bl_mat, 'Value'))
    GP.blLoadMode = GC.LOAD_MAT;
    GP.ECM_info = get(handles.eb_bl_path, 'String');
elseif(get(handles.rb_bl_excel, 'Value'))
    GP.ECM_info = get(handles.eb_bl_path, 'String');
    GP.blLoadMode = GC.LOAD_EXCEL;
else
    warning('No option selected for LOB loading!');
end

%rates
if(get(handles.rb_bl_mat, 'Value'))
    GP.yieldLoadMode = GC.LOAD_MAT;
    GP.yieldPath = get(handles.eb_yields_path, 'String');
elseif(get(handles.rb_bl_excel, 'Value'))
    GP.yieldPath = get(handles.eb_yields_path, 'String');
    GP.yieldLoadMode = GC.LOAD_EXCEL;
else
    warning('No option selected for yields loading!');
end

%parameter risk
GP.armsModelLocation = get(handles.eb_parameter, 'String');

%send to app
app.initiation(GP);

%update panel
%set(handles.lb_lob, 'String', {app.LOBs.name});



function eb_lob_path_Callback(hObject, eventdata, handles)
% hObject    handle to eb_lob_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_lob_path as text
%        str2double(get(hObject,'String')) returns contents of eb_lob_path as a double


% --- Executes during object creation, after setting all properties.
function eb_lob_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_lob_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_lob_browse.
function btn_lob_browse_Callback(hObject, eventdata, handles)
% hObject    handle to btn_lob_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName,FilterIndex] = uigetfile;
if(~isnumeric(FileName))
    newPath = strrep([PathName, FileName], pwd, '.');
    set(handles.eb_lob_path, 'String', newPath);
end

% --- Executes on button press in btn_ed_browse.
function btn_ed_browse_Callback(hObject, eventdata, handles)
[FileName,PathName,FilterIndex] = uigetfile;
if(~isnumeric(FileName))
    newPath = strrep([PathName, FileName], pwd, '.');
    set(handles.ed_ed_path, 'String', newPath);
end

% --- Executes on button press in btn_bl_browse.
function btn_bl_browse_Callback(hObject, eventdata, handles)
[FileName,PathName,FilterIndex] = uigetfile;
if(~isnumeric(FileName))
    newPath = strrep([PathName, FileName], pwd, '.');
    set(handles.eb_bl_path, 'String', newPath);
end


function eb_bl_path_Callback(hObject, eventdata, handles)
% hObject    handle to eb_bl_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_bl_path as text
%        str2double(get(hObject,'String')) returns contents of eb_bl_path as a double


% --- Executes during object creation, after setting all properties.
function eb_bl_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_bl_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_compression.
function cb_compression_Callback(hObject, eventdata, handles)
GP = Params.instance();
if(get(hObject,'Value'))
    GP.compressionMode = GC.CompressedMode;
else
    GP.compressionMode = GC.NormalMode;
end



function eb_ed_path_Callback(hObject, eventdata, handles)
% hObject    handle to eb_ed_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_ed_path as text
%        str2double(get(hObject,'String')) returns contents of eb_ed_path as a double


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


% --- Executes when selected object is changed in sub_pl_drivers.
function sub_pl_drivers_SelectionChangeFcn(hObject, eventdata, handles)
selection = get(eventdata.NewValue, 'String');
switch selection
    case 'External souce'
        set(handles.eb_ed_path, 'Enable', 'on');
        set(handles.btn_ed_browse, 'Enable', 'on');
        set(handles.eb_ed_path, 'String', '.\Data\driversInfoHDF5.mat');
    case '.mat file'
        set(handles.eb_ed_path, 'Enable', 'on');
        set(handles.btn_ed_browse, 'Enable', 'on');
        set(handles.eb_ed_path, 'String', '.\Data\driversInfo.mat');
    case 'Database'
        set(handles.eb_ed_path, 'Enable', 'off');
        set(handles.btn_ed_browse, 'Enable', 'off');
end

% --- Executes when selected object is changed in sub_pl_yields.
function sub_pl_yields_SelectionChangeFcn(hObject, eventdata, handles)
selection = get(eventdata.NewValue, 'String');
GP = Params.instance();
switch selection
    case 'Static rate'
        set(handles.eb_yields_path, 'Enable', 'on');
        set(handles.btn_yields_browse, 'Enable', 'on');
        set(handles.eb_yields_path, 'String', '.\Data\yields.mat');
        GP.stochasticRate = 0;
        ECMIO.cleanCashflow(); %reset cashflow
    case 'Stochastic rate'
        set(handles.eb_yields_path, 'Enable', 'off');
        set(handles.btn_yields_browse, 'Enable', 'off');
        GP.stochasticRate = 1;
        ECMIO.cleanCashflow(); %reset cashflow
end

% --- Executes during object creation, after setting all properties.
function eb_yields_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_yields_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_discount.
function cb_discount_Callback(hObject, eventdata, handles)
GP = Params.instance();
val = get(hObject,'Value');

if(val==0)
    set(handles.eb_yields_path, 'Enable', 'off');
    set(handles.btn_yields_browse, 'Enable', 'off');
    set(handles.rb_static, 'Enable', 'off');
    set(handles.rb_stochastic, 'Enable', 'off');
else
    set(handles.eb_yields_path, 'Enable', 'on');
    set(handles.btn_yields_browse, 'Enable', 'on');
    set(handles.rb_static, 'Enable', 'on');
    set(handles.rb_stochastic, 'Enable', 'on');
end



function eb_credit_Callback(hObject, eventdata, handles)
% hObject    handle to eb_credit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_credit as text
%        str2double(get(hObject,'String')) returns contents of eb_credit as a double


% --- Executes during object creation, after setting all properties.
function eb_credit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_credit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_credit.
function cb_credit_Callback(hObject, eventdata, handles)
% hObject    handle to cb_credit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_credit


% --- Executes on button press in cb_cat.
function cb_cat_Callback(hObject, eventdata, handles)
% hObject    handle to cb_cat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_cat



function eb_cat_Callback(hObject, eventdata, handles)
% hObject    handle to eb_cat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_cat as text
%        str2double(get(hObject,'String')) returns contents of eb_cat as a double


% --- Executes during object creation, after setting all properties.
function eb_cat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_cat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_systematic.
function cb_systematic_Callback(hObject, eventdata, handles)
GP = Params.instance();
val = get(hObject,'Value');
if(GP.systematicRiskMode ~= val)
    GP.systematicRiskMode = get(hObject,'Value');
    ECMIO.cleanCashflow(); %reset cashflow
end


% --- Executes on button press in cb_idiosyncratic.
function cb_idiosyncratic_Callback(hObject, eventdata, handles)
GP = Params.instance();
val = get(hObject,'Value');
if(GP.idiosyncraticRiskMode ~= val)
    GP.idiosyncraticRiskMode = get(hObject,'Value');
    ECMIO.cleanCashflow(); %reset cashflow
end


function eb_idiosyncratic_Callback(hObject, eventdata, handles)
% hObject    handle to eb_idiosyncratic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_idiosyncratic as text
%        str2double(get(hObject,'String')) returns contents of eb_idiosyncratic as a double


% --- Executes during object creation, after setting all properties.
function eb_idiosyncratic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_idiosyncratic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eb_parameter_Callback(hObject, eventdata, handles)
% hObject    handle to eb_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_parameter as text
%        str2double(get(hObject,'String')) returns contents of eb_parameter as a double


% --- Executes during object creation, after setting all properties.
function eb_parameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_parameter.
function cb_parameter_Callback(hObject, eventdata, handles)
GP = Params.instance();
val = get(hObject,'Value');
if(GP.parameterRiskMode ~= val)
    GP.parameterRiskMode = get(hObject,'Value');
    ECMIO.cleanCashflow(); %reset cashflow
end


% --- Executes on button press in cb_market.
function cb_market_Callback(hObject, eventdata, handles)
% hObject    handle to cb_market (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_market



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_steadyState.
function cb_steadyState_Callback(hObject, eventdata, handles)
GP = Params.instance();
val = get(hObject,'Value');
if(GP.steadyStage ~= val)
    GP.steadyStage = get(hObject,'Value');
    lf = LineFactory(); %reset cashflow
    lf.createLOBs();
end
