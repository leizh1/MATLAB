function varargout = MainDialog(varargin)
% MAINDIALOG MATLAB code for MainDialog.fig
%      MAINDIALOG, by itself, creates a new MAINDIALOG or raises the existing
%      singleton*.
%
%      H = MAINDIALOG returns the handle to a new MAINDIALOG or the handle to
%      the existing singleton*.
%
%      MAINDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINDIALOG.M with the given input arguments.
%
%      MAINDIALOG('Property','Value',...) creates a new MAINDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainDialog

% Last Modified by GUIDE v2.5 18-Dec-2012 16:46:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @MainDialog_OutputFcn, ...
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


% --- Executes just before MainDialog is made visible.
function MainDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainDialog (see VARARGIN)

% Choose default command line output for MainDialog
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainDialog wait for user response (see UIRESUME)
% uiwait(handles.main);

%abort if main window already exsits
if(strcmp(get(hObject, 'Visible'), 'on'))
    msgbox('Application is already open. Operation aboarted.','Warning','warn');
    return;
end

%clear
clear app;
dbstop if error;

%initiate runtime controller
app = ecmRuntimeController.instance();
%update handles in app
app.mainWindow = hObject;
app.handles = handles;


% --- Outputs from this function are returned to the command line.
function varargout = MainDialog_OutputFcn(hObject, eventdata, handles) 

% --------------------------------------------------------------------


% --- Executes on button press in ToggleBtn.
% hObject    handle to initToggleBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function taskToggleBtn_Callback(hObject, eventdata, handles)
app =  ecmRuntimeController();
if(get(hObject, 'Value') == 0)
    set(hObject, 'Value', 1);
elseif(isempty(app.BLs))
    msgbox('Please complete initiation before precede to other tasks. To start initiation, press "Start" in Initiation panel.','Need initiation','warn');
    set(hObject, 'Value', 0);
    set(handles.initToggleBtn, 'Value', 1);
else
    %get name
    name = get(hObject, 'String');
    [~, ix] = ismember(name, app.guiData.panels(:,1));
    
    %hide previous panel
    for i=2:length(app.guiData.panels)
        if(get(handles.(app.guiData.panels{i, 2}), 'Parent') == app.handles.(app.guiData.main_frame));
            i_current = i;
        end
    end
    %unhide target panel
    app.swapPanel(handles.(app.guiData.panels{ix, 2}), ... %new panel
        handles.(app.guiData.panels{i_current, 2}), ... %old panel
        app.handles.(app.guiData.main_frame), ... %target frame
        app.container);
    set(handles.(app.guiData.panels{ix, 2}), 'Position', [0,0,160,48])
    
    %update panel
    if(strcmp(name, 'Initiation'))
        app.initPanelUpdate();
        app.statusUpdate('Initiation panel.');
    elseif(strcmp(name, 'Line of Business'))
        app.lobPanelUpdate();
        app.statusUpdate('Line of Business panel.');
    elseif(strcmp(name, 'Economic Drivers'))
        app.driverPanelUpdate();
        app.statusUpdate('Economic Drivers panel.');
    elseif(strcmp(name, 'Budget Lines'))
        app.blPanelUpdate();
        app.statusUpdate('Budget Lines panel.');
    elseif(strcmp(name, 'Run Analysis'))
        app.runPanelUpdate();
        app.statusUpdate('Run Analytics panel.');
    end
end


% --------------------------------------------------------------------
function Action_Callback(hObject, eventdata, handles)
% hObject    handle to Action (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function About_Callback(hObject, eventdata, handles)
% hObject    handle to About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when selected object is changed in pl_tasks.
function pl_tasks_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pl_tasks 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


function pl_tasks_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pl_tasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
