function varargout = ResetLandMarks(varargin)
% RESETLANDMARKS MATLAB code for ResetLandMarks.fig
%      RESETLANDMARKS, by itself, creates a new RESETLANDMARKS or raises the existing
%      singleton*.
%
%      H = RESETLANDMARKS returns the handle to a new RESETLANDMARKS or the handle to
%      the existing singleton*.
%
%      RESETLANDMARKS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESETLANDMARKS.M with the given input arguments.
%
%      RESETLANDMARKS('Property','Value',...) creates a new RESETLANDMARKS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ResetLandMarks_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ResetLandMarks_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ResetLandMarks

% Last Modified by GUIDE v2.5 28-Jul-2017 19:04:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ResetLandMarks_OpeningFcn, ...
    'gui_OutputFcn',  @ResetLandMarks_OutputFcn, ...
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


% --- Executes just before ResetLandMarks is made visible.
function ResetLandMarks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ResetLandMarks (see VARARGIN)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

data = varargin{1};

%% load the template image and plot the Landmarks.

handles.fixedAllLandmarks = data.fixedAllLandmarks;
fixedAllLandmarks = data.fixedAllLandmarks;

handles.fix = data.fix;
LMSelected = data.LMSelected;

handles.Tris = data.Tris;
handles.LMSelected = data.LMSelected;
handles.CurrentProject = data.CurrentProject;

fixedFaceLocation = handles.fixedAllLandmarks(end - 3:end, :);
%fixedLM = fixedAllLandmarks(1: end - 4, :);

axes(handles.Axis_FixImage);
imshow(handles.fix, 'Parent', handles.Axis_FixImage);

%zoom(handles.Axis_FixImage, 'on')

xlim([min(fixedFaceLocation(:, 1)) - 30, max(fixedFaceLocation(:, 1)) + 30])
ylim([min(fixedFaceLocation(:, 2)) - 30, max(fixedFaceLocation(:, 2)) + 30])

hold on

plot(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), '.y');
scatter(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), 40, 'green', 'o');

hold off

for i = 1: size(fixedAllLandmarks, 1)
    
    text(fixedAllLandmarks(i, 1) + 7, fixedAllLandmarks(i, 2) + 5, num2str(i), 'FontSize', 11,...
        'FontWeight', 'bold', 'BackgroundColor', 'w')
    
end

%% load landmarks into table

LMList = [LMSelected, (1:size(fixedAllLandmarks, 1))'];

LMList = mat2cell(LMList, ones(size(fixedAllLandmarks, 1), 1), [1, 1]);

for i = 1:size(fixedAllLandmarks, 1)
    
    LMList{i, 1} = LMSelected(i);
    
end

handles.LMList = LMList;

set(handles.Table_LMList, 'Data', LMList);

% Choose default command line output for ResetLandMarks
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ResetLandMarks wait for user response (see UIRESUME)
uiwait(handles.ResetLMWindow);


% --- Outputs from this function are returned to the command line.
function varargout = ResetLandMarks_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.LMSelected;
varargout{2} = handles.fixedAllLandmarks;
varargout{3} = handles.Tris;

delete(handles.ResetLMWindow);
%delete(hObject);

% --- Executes when selected cell(s) is changed in Table_LMList.
function Table_LMList_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Table_LMList (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.ResetLMWindow);

%% Save Previous
fixedAllLandmarks = handles.fixedAllLandmarks;
size(fixedAllLandmarks);

if isfield(handles, 'CustomizedPoint')
    
    LMSelected = get(hObject, 'Data');
    IndexLM = handles.IndexLM;
    
    if LMSelected{IndexLM, 1}
        
        CustomizedPoint = handles.CustomizedPoint;
        
        pos = getPosition(CustomizedPoint);
        
        fixedAllLandmarks(IndexLM, 1) = pos(1);
        fixedAllLandmarks(IndexLM, 2) = pos(2);
        
    end
    
    delete(handles.CustomizedPoint)
    
end

%% highlight the selected landmark

if numel(eventdata.Indices) > 0
    
    IndexLM = eventdata.Indices(1);
    
    LMSelected = get(hObject, 'Data');
    
    LMSelected = LMSelected(:, 1);
    
    if (eventdata.Indices(2) == 1)
        
        LMSelected{IndexLM, 1} = ~LMSelected{IndexLM, 1};
        
    end
    
    LMSelected = cell2mat(LMSelected);
    
    handles.LMSelected = LMSelected;
    
    fix = handles.fix;
    
    fixedFaceLocation = fixedAllLandmarks(end - 3:end, :);
    %fixedLM = fixedAllLandmarks(1: end - 4, :);
    
    axes(handles.Axis_FixImage)
    CA = handles.Axis_FixImage;
    
    imshow(fix, 'Parent', CA);
    
    fcn = makeConstrainToRectFcn('impoint', get(CA,'XLim'), get(CA,'YLim'));
    
    xlim([min(fixedFaceLocation(:, 1)) - 30, max(fixedFaceLocation(:, 1)) + 30])
    ylim([min(fixedFaceLocation(:, 2)) - 30, max(fixedFaceLocation(:, 2)) + 30])
    
    hold on
    
    plot(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), '.y');
    scatter(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), 40, 'green', 'o');
    
    for i = 1: size(fixedAllLandmarks, 1)
        
        text(fixedAllLandmarks(i, 1) + 7, fixedAllLandmarks(i, 2) + 5, num2str(i), 'FontSize', 11,...
            'FontWeight', 'bold', 'BackgroundColor', 'w')
        
    end
    
    hold off
    
    if LMSelected(IndexLM)
        
        CustomizedPoint = impoint(CA, fixedAllLandmarks(IndexLM, 1), fixedAllLandmarks(IndexLM, 2));
        
        setString(CustomizedPoint, num2str(IndexLM));
        
        setColor(CustomizedPoint, 'y')
        
        setPositionConstraintFcn(CustomizedPoint, fcn);
        
        if isprop(CustomizedPoint, 'Deletable')
            
            CustomizedPoint.Deletable = false;
            
        end
        
        handles.CustomizedPoint = CustomizedPoint;
        
    end
    
    handles.IndexLM = IndexLM;
    
end

handles.fixedAllLandmarks = fixedAllLandmarks;

guidata(hObject, handles)

uiwait(handles.ResetLMWindow);


% --- Executes when user attempts to close ResetLMWindow.
function ResetLMWindow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ResetLMWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

fixedAllLandmarks = handles.fixedAllLandmarks;


if isfield(handles, 'CustomizedPoint')
    
    LMSelected = get(handles.Table_LMList, 'Data');
    IndexLM = handles.IndexLM;
    
    if LMSelected{IndexLM, 1}
        
        CustomizedPoint = handles.CustomizedPoint;
        
        pos = getPosition(CustomizedPoint);
        
        fixedAllLandmarks(IndexLM, 1) = pos(1);
        fixedAllLandmarks(IndexLM, 2) = pos(2);
        
    end
    
    delete(handles.CustomizedPoint)
    
end

if isfield(handles, 'LMSelected')
    
    LMSelected = handles.LMSelected;
    
    Width = size(handles.fix, 2);
    Height = size(handles.fix, 1);
    
    fixedAllLandmarksT = [fixedAllLandmarks(LMSelected, :); [1 1; Width 1; 1 Height; Width Height]];
    Tris = delaunayTriangulation(fixedAllLandmarksT);
    
    handles.Tris = Tris;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/fixedLandmarks-new.mat'), 'fixedAllLandmarks');
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Tris.mat'), 'Tris');
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/LMSelection.mat'), 'LMSelected');
    
end

handles.fixedAllLandmarks = fixedAllLandmarks;

guidata(hObject, handles)
uiresume(handles.ResetLMWindow);
%delete(hObject);
