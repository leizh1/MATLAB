
%hMain = MainDialog;
%hap = initPanel;

hMain = MainDialog('Visible','off');
hap = initPanel('Visible', 'off');
d = guidata(hap);
dm = guidata(hMain);
set(d.initPanel,'Parent',dm.uipanel2);
guidata(hMain,guihandles(hMain));

set(hMain,'Visible','on');
delete(hap);
d1 = guidata(hMain);
