function varargout = DrawAOI(varargin)
% DRAWAOI MATLAB code for DrawAOI.fig
%      DRAWAOI, by itself, creates a new DRAWAOI or raises the existing
%      singleton*.
%
%      H = DRAWAOI returns the handle to a new DRAWAOI or the handle to
%      the existing singleton*.
%
%      DRAWAOI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAWAOI.M with the given input arguments.
%
%      DRAWAOI('Property','Value',...) creates a new DRAWAOI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DrawAOI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DrawAOI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DrawAOI

% Last Modified by GUIDE v2.5 28-Jul-2017 11:20:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DrawAOI_OpeningFcn, ...
    'gui_OutputFcn',  @DrawAOI_OutputFcn, ...
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


% --- Executes just before DrawAOI is made visible.
function DrawAOI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DrawAOI (see VARARGIN)

data = varargin{1};
handles.CurrentProject = data.CurrentProject;

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

%% load the AOI parameters
if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'file') == 2
    
    load(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'));
    
else
    
    AOIEllipse = cell(0, 3);
    AOIRect = cell(0, 3);
    AOIPoly = cell(0, 3);
    
    AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'AOI', 'AOIEllipse', 'AOIRect', 'AOIPoly')
    
end


%% load the reference image

fix = data.fix;

handles.fixedAllLandmarks = data.fixedAllLandmarks;
handles.fix = fix;

axes(handles.axes1)

imshow(fix);

%%
handles.AOINameC = 'AOI_Name';
set(handles.Edit_AOIName, 'String', 'AOI_Name');

%% load the table with AOI

AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];

AOIPlot(AOI) % plot all AOIs

set(handles.Table_AOI, 'Data', AOI(:, [2 3]));

handles.AOI = AOI;
handles.AOIEllipse = AOIEllipse;
handles.AOIRect = AOIRect;
handles.AOIPoly = AOIPoly;

% Choose default command line output for DrawAOI
handles.output = hObject;

set(handles.Button_Save, 'enable', 'off')
set(handles.Button_Delete, 'enable', 'off')

%% check whether fixation is ready to present

FixationReady = get(data.PresentationOptions, 'enable');

if strcmp(FixationReady, 'on')
    
    handles.FixationData = data.FixationData;
    handles.BlurRatio = data.BlurRatio;
    handles.scale = data.scale;
    
    %% scale fixations
    
    handles.FixationData{:, 'X'} = handles.FixationData{:, 'X'} * handles.scale;
    handles.FixationData{:, 'Y'} = handles.FixationData{:, 'Y'} * handles.scale;
    
    handles.FixationData{:, 'Xtf'} = handles.FixationData{:, 'Xtf'} * handles.scale;
    handles.FixationData{:, 'Ytf'} = handles.FixationData{:, 'Ytf'} * handles.scale;
    
    set(handles.FixationPresetation, 'enable', 'on');
    
else
    
    set(handles.FixationPresetation, 'enable', 'off');
    
end

clear 'data'

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DrawAOI wait for user response (see UIRESUME)
uiwait(handles.Figure_AOIDraw);


% --- Outputs from this function are returned to the command line.
function varargout = DrawAOI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.AOI;
varargout{2} = handles.AOIEllipse;
varargout{3} = handles.AOIRect;
varargout{4} = handles.AOIPoly;

delete(handles.Figure_AOIDraw)


% --- Executes on button press in Button_Save.
function Button_Save_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

if isfield(handles, 'Shape') == 1
    
    Shape = handles.Shape;
    
    AOIEllipse = handles.AOIEllipse;
    AOIRect = handles.AOIRect;
    AOIPoly = handles.AOIPoly;
    
    AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];
    
    handles.AOINameC = get(handles.Edit_AOIName, 'String');
    
    switch Shape
        
        case 'Ellipse'
            
            nrow = size(AOIEllipse, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to update it with the current one?', ...
                    '', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 3} = 'Ellipse';
                            
                        end
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            
                            AOIRect(find(strcmp(AOIRect(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                            AOIEllipse{nrow + 1, 3} = 'Ellipse';
                            
                        end
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly(find(strcmp(AOIPoly(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                            AOIEllipse{nrow + 1, 3} = 'Ellipse';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                AOIEllipse{nrow + 1, 3} = 'Ellipse';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
        case 'Rectangle'
            
            nrow = size(AOIRect, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to overwirte it?', ...
                    'Overwirte?', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 3} = 'Rectangle';
                            
                        end
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            
                            AOIEllipse(find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIRect{nrow + 1, 2} = handles.AOINameC;
                            AOIRect{nrow + 1, 3} = 'Rectangle';
                            
                        end
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly(find(strcmp(AOIPoly(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIRect{nrow + 1, 2} = handles.AOINameC;
                            AOIRect{nrow + 1, 3} = 'Rectangle';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIRect{nrow + 1, 2} = handles.AOINameC;
                AOIRect{nrow + 1, 3} = 'Rectangle';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
        case 'Polygon'
            
            nrow = size(AOIPoly, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to overwirte it?', ...
                    'Overwirte?', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 3} = 'Polygon';
                            
                        end
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            
                            AOIEllipse(find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIPoly{nrow + 1, 2} = handles.AOINameC;
                            AOIPoly{nrow + 1, 3} = 'Polygon';
                            
                        end
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            AOIRect(find(strcmp(AOIRect(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIPoly{nrow + 1, 2} = handles.AOINameC;
                            AOIPoly{nrow + 1, 3} = 'Polygon';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIPoly{nrow + 1, 2} = handles.AOINameC;
                AOIPoly{nrow + 1, 3} = 'Polygon';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
    end
    
    AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];
    
    handles.AOI = AOI;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'AOI', 'AOIEllipse', 'AOIRect', 'AOIPoly')
    
    set(handles.Table_AOI, 'Data', AOI(:, [2 3]));
    
    set(handles.Button_Save, 'enable', 'off');
    
    
    if any(strcmp(version('-release'), {'2015a', '2015b', '2016a', '2016b', '2017a'}))
        
        if isfield(handles, 'AOIC')
            
            delete(handles.AOIC)
            
        end
        
    end
    
    guidata(hObject, handles);
    
end

%% plot fixations and AOIs
contents = cellstr(get(handles.FixationPresetation,'String'));

PresentationOption = contents{get(handles.FixationPresetation, 'Value')};

axes(handles.axes1)

if isfield(handles, 'FixationData')
    
    FixationData = handles.FixationData;
    
    ShowFixationinAOIWin
    
else
    
    imshow(handles.fix)
    
end

AOIPlot(AOI) % plot all AOIs

uiwait(handles.Figure_AOIDraw);



% --- Executes during object creation, after setting all properties.
function Edit_AOIName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_AOIName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Button_Delete.
function Button_Delete_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

AOINameC = handles.AOINameC;

if isfield(handles, 'IndexC')
    
    IndexC = handles.IndexC;
    
    AOI = handles.AOI;
    
    AOI(IndexC, :) = [];
    
    if any(strcmp(AOI(:, 3), 'Ellipse'))
        
        AOIEllipse = AOI(find(strcmp(AOI(:, 3), 'Ellipse')), :);
        
    else
        
        AOIEllipse = cell(0, 3);
        
    end
    
    
    if any(strcmp(AOI(:, 3), 'Polygon'))
        
        AOIPoly = AOI(find(strcmp(AOI(:, 3), 'Polygon')), :);
        
    else
        
        AOIPoly = cell(0, 3);
        
    end
    
    
    if any(strcmp(AOI(:, 3), 'Rectangle'))
        
        AOIRect = AOI(find(strcmp(AOI(:, 3), 'Rectangle')), :);
        
    else
        
        AOIRect = cell(0, 3);
        
    end
    
    set(handles.Table_AOI, 'Data', AOI(:, [2 3]));
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'AOI', 'AOIEllipse', 'AOIRect', 'AOIPoly')
    
    handles.AOI = AOI;
    handles.AOIPoly = AOIPoly;
    handles.AOIRect = AOIRect;
    handles.AOIEllipse = AOIEllipse;
    
    %% plot fixations and AOIs
    contents = cellstr(get(handles.FixationPresetation,'String'));
    
    PresentationOption = contents{get(handles.FixationPresetation, 'Value')};
    
    axes(handles.axes1)
    
    if isfield(handles, 'FixationData')
        
        FixationData = handles.FixationData;
        
        ShowFixationinAOIWin
        
    else
        
        imshow(handles.fix)
        
    end
    
    AOIPlot(AOI) % plot all AOIs
    
    guidata(hObject, handles)
        
end

set(hObject, 'enable', 'off')



% --- Executes on selection change in Popup_ChooseShape.
function Popup_ChooseShape_Callback(hObject, eventdata, handles)
% hObject    handle to Popup_ChooseShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% uiresume(handles.Figure_AOIDraw);

% if any(strcmp(version('-release'), {'2015a', '2015b', '2016a', '2016b', '2017a'}))
%
if isfield(handles, 'AOIC')
    
    delete(handles.AOIC)
    
end

% end

% save('~/Desktop/handles.mat', 'handles')

contents = cellstr(get(handles.FixationPresetation,'String'));

PresentationOption = contents{get(handles.FixationPresetation, 'Value')};

fix = handles.fix;

axes(handles.axes1)

if isfield(handles, 'FixationData')
    
    FixationData = handles.FixationData;
    
    ShowFixationinAOIWin
    
else
    
    imshow(handles.fix)
    
end

%% draw an AOI
set(handles.Button_Save, 'enable', 'on');
set(handles.Edit_AOIName, 'String', 'AOI_Name');
set(handles.Edit_AOIName, 'enable', 'on');

contents = cellstr(get(hObject,'String'));

Shape = contents{get(hObject, 'Value')};

switch Shape
    
    case 'Ellipse'
        
        AOIC = imellipse(gca);
        fcn = makeConstrainToRectFcn('imellipse', get(gca, 'XLim'), get(gca, 'YLim'));
        
    case 'Rectangle'
        
        AOIC = imrect(gca, [10 10 100 100]);
        fcn = makeConstrainToRectFcn('imrect', get(gca, 'XLim'), get(gca, 'YLim'));
        
    case 'Polygon'
        
        AOIC = impoly(gca);
        fcn = makeConstrainToRectFcn('impoly', get(gca, 'XLim'), get(gca, 'YLim'));
        
end

if exist('AOIC', 'var')
    
    setPositionConstraintFcn(AOIC, fcn);
    
    handles.Shape = Shape;
    handles.AOIC = AOIC;
    
end

guidata(hObject, handles);

uiwait(handles.Figure_AOIDraw);


% --- Executes during object creation, after setting all properties.
function Popup_ChooseShape_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Popup_ChooseShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close Figure_AOIDraw.
function Figure_AOIDraw_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Figure_AOIDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Save the previous AOI

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

Saved = {get(handles.Button_Save, 'enable')};

if strcmp(Saved, 'on')
    
    Shape = handles.Shape;
    
    AOIEllipse = handles.AOIEllipse;
    AOIRect = handles.AOIRect;
    AOIPoly = handles.AOIPoly;
    
    AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];
    
    handles.AOINameC = get(handles.Edit_AOIName, 'String');
    
    switch Shape
        
        case 'Ellipse'
            
            nrow = size(AOIEllipse, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to update it with the current one?', ...
                    '', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 3} = 'Ellipse';
                            
                        end
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            
                            AOIRect(find(strcmp(AOIRect(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                            AOIEllipse{nrow + 1, 3} = 'Ellipse';
                            
                        end
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly(find(strcmp(AOIPoly(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                            AOIEllipse{nrow + 1, 3} = 'Ellipse';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                AOIEllipse{nrow + 1, 3} = 'Ellipse';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
        case 'Rectangle'
            
            nrow = size(AOIRect, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to overwirte it?', ...
                    'Overwirte?', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 3} = 'Rectangle';
                            
                        end
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            
                            AOIEllipse(find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIRect{nrow + 1, 2} = handles.AOINameC;
                            AOIRect{nrow + 1, 3} = 'Rectangle';
                            
                        end
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly(find(strcmp(AOIPoly(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIRect{nrow + 1, 2} = handles.AOINameC;
                            AOIRect{nrow + 1, 3} = 'Rectangle';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIRect{nrow + 1, 2} = handles.AOINameC;
                AOIRect{nrow + 1, 3} = 'Rectangle';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
        case 'Polygon'
            
            nrow = size(AOIPoly, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to overwirte it?', ...
                    'Overwirte?', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 3} = 'Polygon';
                            
                        end
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            
                            AOIEllipse(find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIPoly{nrow + 1, 2} = handles.AOINameC;
                            AOIPoly{nrow + 1, 3} = 'Polygon';
                            
                        end
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            AOIRect(find(strcmp(AOIRect(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIPoly{nrow + 1, 2} = handles.AOINameC;
                            AOIPoly{nrow + 1, 3} = 'Polygon';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIPoly{nrow + 1, 2} = handles.AOINameC;
                AOIPoly{nrow + 1, 3} = 'Polygon';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
    end
    
    AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];
    
    handles.AOI = AOI;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'AOI', 'AOIEllipse', 'AOIRect', 'AOIPoly')
    
    set(handles.Table_AOI, 'Data', AOI(:, [2 3]));
    
    guidata(hObject, handles);
    
    set(handles.Button_Save, 'enable', 'off');
    
end

uiresume(handles.Figure_AOIDraw)
% Hint: delete(hObject) closes the figure
% delete(hObject);



function Edit_AOIName_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_AOIName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_AOIName as text
%        str2double(get(hObject,'String')) returns contents of Edit_AOIName as a double
handles.AOINameC = get(hObject, 'String');

guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in Table_AOI.
function Table_AOI_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Table_AOI (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

%% Save the previous AOI

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

Saved = {get(handles.Button_Save, 'enable')};

if strcmp(Saved, 'on')
    
    Shape = handles.Shape;
    
    AOIEllipse = handles.AOIEllipse;
    AOIRect = handles.AOIRect;
    AOIPoly = handles.AOIPoly;
    
    AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];
    
    handles.AOINameC = get(handles.Edit_AOIName, 'String');
    
    switch Shape
        
        case 'Ellipse'
            
            nrow = size(AOIEllipse, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to update it with the current one?', ...
                    '', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIEllipse{find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), 3} = 'Ellipse';
                            
                        end
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            
                            AOIRect(find(strcmp(AOIRect(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                            AOIEllipse{nrow + 1, 3} = 'Ellipse';
                            
                        end
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly(find(strcmp(AOIPoly(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                            AOIEllipse{nrow + 1, 3} = 'Ellipse';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIEllipse{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIEllipse{nrow + 1, 2} = handles.AOINameC;
                AOIEllipse{nrow + 1, 3} = 'Ellipse';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
        case 'Rectangle'
            
            nrow = size(AOIRect, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to overwirte it?', ...
                    'Overwirte?', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIRect{find(strcmp(AOIRect(:, 2), handles.AOINameC)), 3} = 'Rectangle';
                            
                        end
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            
                            AOIEllipse(find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIRect{nrow + 1, 2} = handles.AOINameC;
                            AOIRect{nrow + 1, 3} = 'Rectangle';
                            
                        end
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly(find(strcmp(AOIPoly(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIRect{nrow + 1, 2} = handles.AOINameC;
                            AOIRect{nrow + 1, 3} = 'Rectangle';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIRect{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIRect{nrow + 1, 2} = handles.AOINameC;
                AOIRect{nrow + 1, 3} = 'Rectangle';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
        case 'Polygon'
            
            nrow = size(AOIPoly, 1);
            
            if any(strcmp(AOI(:, 2), handles.AOINameC))
                
                choice = questdlg('An AOI with the same name has been created, do you want to overwirte it?', ...
                    'Overwirte?', ...
                    'Yes', 'No', 'No');
                
                % Handle response
                switch choice
                    
                    case 'Yes'
                        
                        if any(strcmp(AOIPoly(:, 2), handles.AOINameC))
                            
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 1} = handles.AOIC.getPosition;
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 2} = handles.AOINameC;
                            AOIPoly{find(strcmp(AOIPoly(:, 2), handles.AOINameC)), 3} = 'Polygon';
                            
                        end
                        
                        if any(strcmp(AOIEllipse(:, 2), handles.AOINameC))
                            
                            
                            AOIEllipse(find(strcmp(AOIEllipse(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIPoly{nrow + 1, 2} = handles.AOINameC;
                            AOIPoly{nrow + 1, 3} = 'Polygon';
                            
                        end
                        
                        if any(strcmp(AOIRect(:, 2), handles.AOINameC))
                            
                            AOIRect(find(strcmp(AOIRect(:, 2), handles.AOINameC)), :) = [];
                            
                            AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                            AOIPoly{nrow + 1, 2} = handles.AOINameC;
                            AOIPoly{nrow + 1, 3} = 'Polygon';
                            
                        end
                        
                    case 'No'
                        
                end
                
            else
                
                AOIPoly{nrow + 1, 1} = handles.AOIC.getPosition;
                AOIPoly{nrow + 1, 2} = handles.AOINameC;
                AOIPoly{nrow + 1, 3} = 'Polygon';
                
            end
            
            handles.AOIEllipse = AOIEllipse;
            handles.AOIRect = AOIRect;
            handles.AOIPoly = AOIPoly;
            
    end
    
    AOI = [AOIEllipse(:,:); AOIRect(:,:); AOIPoly(:, :)];
    
    handles.AOI = AOI;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'AOI', 'AOIEllipse', 'AOIRect', 'AOIPoly')
    
    set(handles.Table_AOI, 'Data', AOI(:, [2 3]));
    
    guidata(hObject, handles);
    
    set(handles.Button_Save, 'enable', 'off');
    
end

%% Change the selected AOI

if any(strcmp(version('-release'), {'2015a', '2015b', '2016a', '2016b', '2017a'}))
    
    if isfield(handles, 'AOIC')
        
        delete(handles.AOIC)
        
    end
    
end

contents = cellstr(get(handles.FixationPresetation,'String'));

PresentationOption = contents{get(handles.FixationPresetation, 'Value')};

fix = handles.fix;

axes(handles.axes1)

if isfield(handles, 'FixationData')
    
    FixationData = handles.FixationData;
    
    ShowFixationinAOIWin
    
else
    
    imshow(handles.fix)
    
end

if numel(eventdata.Indices) > 0
    
    IndexC = eventdata.Indices(:, 1);
    
    AOI = handles.AOI;
    
    AOIPlot(AOI) % plot all AOIs
    
    AOINameC = AOI{IndexC, 2};
    
    AOIC = AOI(IndexC, :);
    
    if size(IndexC, 1) == 1 % select one AOI
        
        %set(handles.Button_Save, 'enable', 'on');
        set(handles.Button_Delete, 'enable', 'on')
        set(handles.Edit_AOIName, 'String', AOINameC);
        set(handles.Edit_AOIName, 'enable', 'on');
        handles.Shape = AOI{IndexC, 3};
        handles.AOINameC = AOI{IndexC, 2};
        
        handles.IndexC = IndexC;
        
        %% show editable AOI
        if any(strcmp(AOIC(:, 3), 'Ellipse'))
            
            AOIEllipseC = AOIC(find(strcmp(AOIC(:, 3), 'Ellipse')), :);
            fcn = makeConstrainToRectFcn('imellipse', get(gca, 'XLim'), get(gca, 'YLim'));
            
            for i = 1:size(AOIEllipseC, 1)
                
                handles.AOIC = imellipse(gca, AOIEllipseC{i, 1});
                
            end
            
        end
        
        if any(strcmp(AOIC(:, 3), 'Rectangle'))
            
            AOIRectC = AOIC(find(strcmp(AOIC(:, 3), 'Rectangle')), :);
            fcn = makeConstrainToRectFcn('imrect', get(gca,'XLim'), get(gca, 'YLim'));
            
            for i = 1:size(AOIRectC, 1)
                
                handles.AOIC = imrect(gca, AOIRectC{i, 1});
                
            end
            
        end
        
        if any(strcmp(AOIC(:, 3), 'Polygon'))
            
            AOIPolyC = AOIC(find(strcmp(AOIC(:, 3), 'Polygon')), :);
            fcn = makeConstrainToRectFcn('impoly', get(gca,'XLim'), get(gca, 'YLim'));
            
            for i = 1:size(AOIPolyC, 1)
                
                handles.AOIC = impoly(gca, AOIPolyC{i, 1});
                
            end
            
        end
        
        setPositionConstraintFcn(handles.AOIC, fcn);
        addNewPositionCallback(handles.AOIC, @(h) set(handles.Button_Save, 'enable', 'on'));
        
    else % select more than one AOI
        
        set(handles.Button_Save, 'enable', 'off');
        set(handles.Edit_AOIName, 'String', 'multi AOIs');
        set(handles.Edit_AOIName, 'enable', 'off');
        set(handles.Button_Delete, 'enable', 'on')
        
    end
    
end

guidata(hObject, handles);

% --- Executes on selection change in FixationPresetation.
function FixationPresetation_Callback(hObject, eventdata, handles)
% hObject    handle to FixationPresetation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));

PresentationOption = contents{get(hObject, 'Value')};

axes(handles.axes1)

if isfield(handles, 'FixationData')
    
    FixationData = handles.FixationData;
    
    ShowFixationinAOIWin
    
else
    
    imshow(handles.fix)
    
end

%% Draw AOIs
AOI = handles.AOI;

AOIPlot(AOI) % plot all AOIs

% Save the handles structure.
guidata(hObject,handles)


% Hints: contents = cellstr(get(hObject,'String')) returns FixationPresetation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FixationPresetation


% --- Executes during object creation, after setting all properties.
function FixationPresetation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FixationPresetation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
