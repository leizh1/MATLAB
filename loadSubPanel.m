%
%load initiation panel pl_init
%
function handles = loadSubPanel(file, child_panel, gui, tartget_frame)
%file, string of fig file name of the fig being loaded
%child_panel, panel being loaded to main figure
%tartget_frame, string of target frame tag
%gui, handles of main gui

if(length(file)~=length(child_panel))
    error('Error in loading parameter: fig files number is not the same as child panel number');
end

%hide main frame
hl_main = guidata(gui);
set(hl_main.(tartget_frame), 'Visible', 'off');

for i=1:length(file)
    %load panel invisibly
    %pl_init = initPanel('Visible', 'off');
    pl_sub = openfig(file{i}, 'new', 'invisible');
    
    %get handles
    handles_sub = getHandles(pl_sub);
    hl_main = guidata(gui); %not using getHandles prevent guidata being overwritten
    
    %move sub panel
    set(handles_sub.(child_panel{i}), 'Parent', hl_main.(tartget_frame));
    set(handles_sub.(child_panel{i}), 'Visible', 'off');
    set(handles_sub.(child_panel{i}), 'Position', [0,0,160,48]);
    %clean up
    delete(pl_sub);
end

%update handle structure
%handles = updataGuidata(gui, guihandles(gui));
handles = getHandles(gui);

%display main frame
set(hl_main.(tartget_frame), 'Visible', 'on');



function handles = getHandles(obj)
 guidata(obj,guihandles(obj));
 handles = guidata(obj);

 
function handles = updataGuidata(gui, newHandles)
fields = fieldnames(newHandles);
handles = guidata(gui);
for i = 1:length(fields)
    handles.(fields{i}) = newHandles.(fields{i});
end
guidata(gui, handles);


function handles = addGuidata(gui, field, data)
handles = guidata(gui);
handles.(field) = data;
guidata(gui, handles);
handles = guidata(gui);
