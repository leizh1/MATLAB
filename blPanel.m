function varargout = blPanel(varargin)
% BLPANEL MATLAB code for blPanel.fig
%      BLPANEL, by itself, creates a new BLPANEL or raises the existing
%      singleton*.
%
%      H = BLPANEL returns the handle to a new BLPANEL or the handle to
%      the existing singleton*.
%
%      BLPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BLPANEL.M with the given input arguments.
%
%      BLPANEL('Property','Value',...) creates a new BLPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before blPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to blPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help blPanel

% Last Modified by GUIDE v2.5 28-Jan-2013 14:02:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @blPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @blPanel_OutputFcn, ...
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


% --- Executes just before blPanel is made visible.
function blPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to blPanel (see VARARGIN)

% Choose default command line output for blPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = blPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lb_bl.
function lb_bl_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.blPanelUpdate();


% --- Executes during object creation, after setting all properties.
function lb_bl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_bl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_bl_nAY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ed_bl_nAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_bl_nAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_bl_nFAY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ed_bl_nFAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_bl_nFAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_bl_nCY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ed_bl_nCY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_bl_nCY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_bl_yr0_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ed_bl_yr0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_bl_yr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pb_bl_revert.
function pb_bl_revert_Callback(hObject, eventdata, handles)


% --- Executes on button press in pb_bl_save.
function pb_bl_save_Callback(hObject, eventdata, handles)


% --- Executes on selection change in pm_bl_pattern.
function pm_bl_pattern_Callback(hObject, eventdata, handles)
app = ecmRuntimeController.instance();
app.blPanelUpdate();


% --- Executes during object creation, after setting all properties.
function pm_bl_pattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_bl_pattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in sub_pl_bl_pattern.
function sub_pl_bl_pattern_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in sub_pl_bl_pattern 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(eventdata.NewValue, 'String'), 'Plot'))
    %hide table
    set(handles.tb_bl_pattern, 'Visible', 'off');
    %unhide axes
    set(handles.ax_bl_pattern, 'Visible', 'on');
    %legend
    legend show;
else
    %unhide table
    set(handles.tb_bl_pattern, 'Visible', 'on');
    %hide axes
    set(handles.ax_bl_pattern, 'Visible', 'off');
    %hide legend
    legend off;
end


% --- Executes on button press in rb_bl_pattern_sum.
function rb_bl_pattern_sum_Callback(hObject, eventdata, handles)
% hObject    handle to rb_bl_pattern_sum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of rb_bl_pattern_sum
app = ecmRuntimeController.instance;
app.blPanelUpdate;
