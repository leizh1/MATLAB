function varargout = lobPanel(varargin)
% LOBPANEL MATLAB code for lobPanel.fig
%      LOBPANEL, by itself, creates a new LOBPANEL or raises the existing
%      singleton*.
%
%      H = LOBPANEL returns the handle to a new LOBPANEL or the handle to
%      the existing singleton*.
%
%      LOBPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOBPANEL.M with the given input arguments.
%
%      LOBPANEL('Property','Value',...) creates a new LOBPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lobPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lobPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lobPanel

% Last Modified by GUIDE v2.5 21-Aug-2013 15:28:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lobPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @lobPanel_OutputFcn, ...
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

function lobPanel_OpeningFcn(hObject, eventdata, handles, varargin)
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
function varargout = lobPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on selection change in lb_lob.
function lb_lob_Callback(hObject, eventdata, handles)
% hObject    handle to lb_lob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_lob contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_lob
app =  ecmRuntimeController.instance();
app.lobPanelUpdate();



% --- Executes during object creation, after setting all properties.
function lb_lob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_lob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%get LOBs data
app = ecmRuntimeController.instance();
LOBs = app.LOBs;
if(isempty(LOBs))
    set(hObject, 'String', 'loading...');
else
    set(hObject, 'String', {LOBs.name});
end

function ed_lob_nAY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ed_lob_nAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_nAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_nFAY_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_lob_nFAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_nFAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_nCY_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_lob_nCY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_nCY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_lob_duration_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_lob_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_yr0_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_lob_yr0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_yr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function pu_lob_pattern_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pu_lob_pattern_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in sub_pl_pattern.
function sub_pl_pattern_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in sub_pl_pattern 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(eventdata.NewValue, 'Tag'), 'rb_lob_pattern_view'))
    
    %hide table
    set(handles.tb_lob_pattern, 'Visible', 'off');
    %unhide axes
    set(handles.ax_lob_pattern, 'Visible', 'on');
    %legend
    legend show;
else
    %unhide table
    set(handles.tb_lob_pattern, 'Visible', 'on');
    %hide axes
    set(handles.ax_lob_pattern, 'Visible', 'off');
    %legend
    legend off;
end


% --- Executes on selection change in pu_lob_pattern_format.
function pu_lob_pattern_format_Callback(hObject, eventdata, handles)
% hObject    handle to pu_lob_pattern_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
app = ecmRuntimeController.instance();
app.lobPanelUpdate();


% --- Executes on button press in pb_lob_save.
function pb_lob_save_Callback(hObject, eventdata, handles)
% hObject    handle to pb_lob_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
app = ecmRuntimeController.instance();
app.lobPanelSave();

% --- Executes on button press in pb_lob_revert.
function pb_lob_revert_Callback(hObject, eventdata, handles)
% hObject    handle to pb_lob_revert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
app = ecmRuntimeController.instance();
app.lobPanelUpdate();



function ed_lob_modelRef_Callback(hObject, eventdata, handles)
% hObject    handle to ed_lob_modelRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_lob_modelRef as text
%        str2double(get(hObject,'String')) returns contents of ed_lob_modelRef as a double


% --- Executes during object creation, after setting all properties.
function ed_lob_modelRef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_modelRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_armsFlag_Callback(hObject, eventdata, handles)
% hObject    handle to ed_lob_armsFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_lob_armsFlag as text
%        str2double(get(hObject,'String')) returns contents of ed_lob_armsFlag as a double


% --- Executes during object creation, after setting all properties.
function ed_lob_armsFlag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_armsFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_credibility_Callback(hObject, eventdata, handles)
% hObject    handle to ed_lob_credibility (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_lob_credibility as text
%        str2double(get(hObject,'String')) returns contents of ed_lob_credibility as a double


% --- Executes during object creation, after setting all properties.
function ed_lob_credibility_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_credibility (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_loss_Callback(hObject, eventdata, handles)
% hObject    handle to ed_lob_loss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_lob_loss as text
%        str2double(get(hObject,'String')) returns contents of ed_lob_loss as a double


% --- Executes during object creation, after setting all properties.
function ed_lob_loss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_loss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_majorLine_Callback(hObject, eventdata, handles)
% hObject    handle to ed_lob_majorLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_lob_majorLine as text
%        str2double(get(hObject,'String')) returns contents of ed_lob_majorLine as a double


% --- Executes during object creation, after setting all properties.
function ed_lob_majorLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_majorLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_lob_BL_Callback(hObject, eventdata, handles)
% hObject    handle to ed_lob_BL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_lob_BL as text
%        str2double(get(hObject,'String')) returns contents of ed_lob_BL as a double


% --- Executes during object creation, after setting all properties.
function ed_lob_BL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_lob_BL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_lob_pattern_sum.
function cb_lob_pattern_sum_Callback(hObject, eventdata, handles)
% hObject    handle to cb_lob_pattern_sum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of cb_lob_pattern_sum
app = ecmRuntimeController.instance;
app.lobPanelUpdate;
