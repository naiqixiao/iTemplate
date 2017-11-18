function varargout = DrawLMs(varargin)
% DRAWLMS MATLAB code for DrawLMs.fig
%      DRAWLMS, by itself, creates a new DRAWLMS or raises the existing
%      singleton*.
%
%      H = DRAWLMS returns the handle to a new DRAWLMS or the handle to
%      the existing singleton*.
%
%      DRAWLMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAWLMS.M with the given input arguments.
%
%      DRAWLMS('Property','Value',...) creates a new DRAWLMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DrawLMs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DrawLMs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DrawLMs

% Last Modified by GUIDE v2.5 30-Jul-2017 12:59:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DrawLMs_OpeningFcn, ...
    'gui_OutputFcn',  @DrawLMs_OutputFcn, ...
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


% --- Executes just before DrawLMs is made visible.
function DrawLMs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DrawLMs (see VARARGIN)

% Choose default command line output for Draw
handles.output = hObject;

% Is the changeme_main gui's handle is passed in varargin?
% if the name 'changeme_main' is found, and the next argument
% varargin{mainGuiInput+1} is a handle, assume we can open it.
if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

data = varargin{1};

handles.CurrentProject = data.CurrentProject;

%% load the template image and plot the Landmarks.

handles.fixedAllLandmarks = data.fixedAllLandmarks;
fixedAllLandmarks = data.fixedAllLandmarks;
handles.fix = data.fix;

handles.Tris = data.Tris;
handles.LMSelected = data.LMSelected;

Width = size(handles.fix, 2);
Height = size(handles.fix, 1);

handles.fixedFaceLocation = handles.fixedAllLandmarks(end - 3:end, :);
fixedFaceLocation = handles.fixedFaceLocation;

handles.LMSelected = data.LMSelected;
LMSelected = data.LMSelected;

axes(handles.axes1);
imshow(handles.fix, 'Parent', handles.axes1);

%zoom(handles.axes1, 'on')

xlim([min(fixedFaceLocation(:, 1)) - 30, max(fixedFaceLocation(:, 1)) + 30])
ylim([min(fixedFaceLocation(:, 2)) - 30, max(fixedFaceLocation(:, 2)) + 30])

hold on

plot(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), '.y');
scatter(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), 40, 'green', 'o');

for i = 1: size(fixedAllLandmarks, 1)
    
    if LMSelected(i)
        
        text(fixedAllLandmarks(i, 1) + 7, fixedAllLandmarks(i, 2) + 5, num2str(i), 'FontSize', 11,...
            'FontWeight', 'bold', 'BackgroundColor', 'w')
        
    end
    
end

hold off

%% show the image list and the current image.

handles.FeaturePoints = [17 18 25 30 31 36:39];

handles.BackgroundImages = data.BackgroundImages;

set(handles.Table_ImageList, 'Data', data.AllLandmarks(:, [3 1]));

CurrentImage = handles.BackgroundImages{1, 2};

ax = handles.axes2;

imshow(CurrentImage, 'Parent', ax);

handles.IndexC = 1;

%% plot landmarks if they exist.
AllLandmarks = data.AllLandmarks;

PlacedBefore = AllLandmarks{1, 3};

handles.PlacedBefore = PlacedBefore;

fcn = makeConstrainToRectFcn('impoint', get(ax,'XLim'), get(ax,'YLim'));

if PlacedBefore
    
    AllLandmarksC = AllLandmarks{1, 2};
    
    AllLandmarksC(AllLandmarksC(:, 1) < 0, 1) = 1;
    AllLandmarksC(AllLandmarksC(:, 2) < 0, 2) = 1;
    
    AllLandmarksC(AllLandmarksC(:, 1) > size(CurrentImage, 2), 1) = size(CurrentImage, 2) - 1;
    AllLandmarksC(AllLandmarksC(:, 2) > size(CurrentImage, 1), 2) = size(CurrentImage, 1) - 1;
    
    x = cell(size(AllLandmarksC, 1), 1);
    
    LMList = 1:size(AllLandmarksC, 1);
    
    for i = LMList
        
        if LMSelected(i)
            
            x{i, 1} = impoint(ax, AllLandmarksC(i, 1), AllLandmarksC(i, 2));
            
            setString(x{i, 1}, num2str(i));
            
        else
            
            x{i, 1} = impoint(ax, -1, -1);
            
        end
        
        if isprop(x{i, 1}, 'Deletable')
            
            x{i, 1}.Deletable = false;
            
        end
        
        setColor(x{i, 1}, 'y');
        
        addNewPositionCallback(x{i, 1}, @(h) mycb(i, fixedAllLandmarks, handles));
        
        setPositionConstraintFcn(x{i, 1}, fcn);
        
    end
    
    set(handles.Button_SaveLMs, 'enable', 'off');
    handles.AllLandmarksC = AllLandmarksC;
    
else % if the first face has never been drawn before
    
    FaceLocation = AllLandmarks{handles.IndexC, 2};
    
    %fixedFaceLocation = fixedAllLandmarks(end - 3:end, :);
    
    fixedFaceLocation = fixedAllLandmarks(handles.FeaturePoints, :);
    
    %% Draw face template
    axes(handles.axes1);
    imshow(handles.fix, 'Parent', handles.axes1);

    xlim([min(fixedFaceLocation(:, 1)) - 30, max(fixedFaceLocation(:, 1)) + 30])
    ylim([min(fixedFaceLocation(:, 2)) - 30, max(fixedFaceLocation(:, 2)) + 30])
    
    hold on
    
    plot(fixedFaceLocation(:, 1), fixedFaceLocation(:, 2), '.y');
    scatter(fixedFaceLocation(:, 1), fixedFaceLocation(:, 2), 40, 'green', 'o');
    
    for i = 1: size(fixedFaceLocation, 1)
        
        text(fixedFaceLocation(i, 1) + 7, fixedFaceLocation(i, 2) + 5, num2str(i), 'FontSize', 11,...
            'FontWeight', 'bold', 'BackgroundColor', 'w')
        
    end
    
    hold off
    
    if size(FaceLocation, 1) == 0 || all(all(FaceLocation == 0)) % no points have been drawn before.
        
        %% calculate the image size difference between the reference and moving images.
        WRatio = get(ax,'XLim') / Width;
        HRatio = get(ax,'YLim') / Height;
        
        WRatio = WRatio(2) - WRatio(1);
        HRatio = HRatio(2) - HRatio(1);
        
        %% locate the face
        
        FaceLocation = fixedFaceLocation * [WRatio, 0; 0, HRatio];
        
        set(handles.Button_SaveLMs, 'enable', 'off');
        
    else
        
        set(handles.Button_SaveLMs, 'enable', 'on');
        
    end
    
    x = cell(size(FaceLocation, 1), 1);
    
    for i = 1:size(FaceLocation, 1)
        
        x{i, 1} = impoint(ax, FaceLocation(i, 1), FaceLocation(i, 2));
        
        setString(x{i, 1}, num2str(i));
        
        if isprop(x{i, 1}, 'Deletable')
            
            x{i, 1}.Deletable = false;
            
        end
        
        setColor(x{i, 1}, 'y');
        
        setPositionConstraintFcn(x{i, 1}, fcn);
        
        addNewPositionCallback(x{i, 1}, @(h) mycb(i, fixedFaceLocation, handles));
        
    end
    
end

handles.LMSelected = LMSelected;
handles.AllLandmarks = AllLandmarks;

handles.x = x; % save the dragable points
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Draw wait for user response (see UIRESUME)
uiwait(handles.LandMarks);


% --- Outputs from this function are returned to the command line.
function varargout = DrawLMs_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

varargout{1} = handles.AllLandmarks;

if isfield(handles, 'Tris')
    
    varargout{2} = handles.Tris;
    
    TFMatrixNew = cell(size(handles.BackgroundImages, 1), size(handles.Tris, 1), 3);
    
    for i = 1: size(TFMatrixNew, 1)
        
        TFMatrixNew(i, :, 1) = handles.BackgroundImages(i, 1)';
        
    end
    
    TFMatrix = TFMatrixNew;
    
    varargout{4} = TFMatrix;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/TFMatrix.mat'), 'TFMatrix');
    
else
    
    load(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Tris.mat'))
    varargout{2} = Tris;
    load(strcat('Eye Tracking Projects/', handles.CurrentProject, '/TFMatrix.mat'))
    varargout{4} = TFMatrix;
    
end

varargout{3} = handles.LMSelected;

delete(handles.LandMarks)

% --- Executes on button press in Button_Close.
function Button_Close_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

%% Save Previous
Saved = get(handles.Button_SaveLMs, 'enable');

if strcmp(Saved, 'on') % if not saved
    
    x = handles.x;
    
    if size(x, 1) == size(handles.fixedAllLandmarks, 1) % only the face is located
        
        TempLMs = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
        
        TempLMs = cell2mat(TempLMs);
        
        AllLandmarksC = handles.AllLandmarksC;
        AllLandmarksC(handles.LMSelected, :) = TempLMs(handles.LMSelected, :);
        
        handles.AllLandmarks{handles.IndexC, 2} = AllLandmarksC;
        
        handles.AllLandmarks{handles.IndexC, 3} = true;
        
        handles.AllLandmarks{handles.IndexC, 4} = false;
        
    else
        
        FaceLocation = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
        
        FaceLocation = cell2mat(FaceLocation);
        
        IndexC = handles.IndexC;
        
        %% save the face location to AllLandmarks
        
        handles.AllLandmarks{IndexC, 2} = FaceLocation;
        
    end
    
    
end

AllLandmarks = handles.AllLandmarks;

save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks')

% update the table
set(handles.Table_ImageList, 'Data', AllLandmarks(:, [3 1]))
guidata(hObject, handles)

uiresume(handles.LandMarks)


% --- Executes on button press in Button_SaveLMs.
function Button_SaveLMs_Callback(hObject, eventdata, handles)
% hObject    handle to Button_SaveLMs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.LandMarks);

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

set(handles.Button_SaveLMs, 'enable', 'off');

axes(handles.axes2)
x = handles.x;

ax = handles.axes2;

fcn = makeConstrainToRectFcn('impoint', get(ax,'XLim'), get(ax,'YLim'));

if size(x, 1) == 9 % only the face is located
    
    fix = handles.fix;
    
    FaceLocation = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
    
    FaceLocation = cell2mat(FaceLocation);
    
    IndexC = handles.IndexC;
    
    %% save the face location to AllLandmarks
    
    handles.AllLandmarks{IndexC, 2} = FaceLocation;
    
    if any(strcmp(version('-release'), {'2015a', '2015b', '2016a', '2016b', '2017a'}))
        
        for i = 1:size(handles.x, 1)
            
            delete(handles.x{i, 1})
            
        end
        
    end
    
    %% Estimate the rest points
    minFaceLocationX = min(FaceLocation(:, 1)) - 10;
    minFaceLocationY = min(FaceLocation(:, 2)) - 10;
    maxFaceLocationX = max(FaceLocation(:, 1)) + 10;
    maxFaceLocationY = max(FaceLocation(:, 2)) + 10;
    
    FaceLocationRef = [FaceLocation; minFaceLocationX, minFaceLocationY; minFaceLocationX maxFaceLocationY;...
        maxFaceLocationX, minFaceLocationY; maxFaceLocationX maxFaceLocationY];
    
    fixedFaceLocation = handles.fixedAllLandmarks(handles.FeaturePoints, :);
    
    minFaceLocationXfix = min(fixedFaceLocation(:, 1)) - 10;
    minFaceLocationYfix = min(fixedFaceLocation(:, 2)) - 10;
    maxFaceLocationXfix = max(fixedFaceLocation(:, 1)) + 10;
    maxFaceLocationYfix = max(fixedFaceLocation(:, 2)) + 10;
    
    fixedFaceLocationRef = [fixedFaceLocation; minFaceLocationXfix, minFaceLocationYfix; minFaceLocationXfix maxFaceLocationYfix;...
        maxFaceLocationXfix, minFaceLocationYfix; maxFaceLocationXfix maxFaceLocationYfix];
    
    TrisEST = delaunayTriangulation(fixedFaceLocationRef);
    
    TFMatrixEST = cell(1, size(TrisEST, 1), 3);
    
    TFMatrixEST = CreateLMTFMatrices(FaceLocationRef, fixedFaceLocationRef, TrisEST, TFMatrixEST);
    
    TFMatrixEST = squeeze(TFMatrixEST);
    
    AllLandmarksC = PointsEst(handles.fixedAllLandmarks, TrisEST, TFMatrixEST);
    
    %% plot all Landmarks
    
    CurrentImage = handles.BackgroundImages{IndexC, 2};
    
    imshow(CurrentImage);
    
    x = cell(size(AllLandmarksC, 1), 1);
    
    LMList = 1:size(AllLandmarksC, 1);
    
    for i = LMList
        
        if handles.LMSelected(i)
            
            x{i, 1} = impoint(ax, AllLandmarksC(i, 1), AllLandmarksC(i, 2));
            
            setString(x{i, 1}, num2str(i));
            
        else
            
            x{i, 1} = impoint(ax, -1, -1);
            
        end
        
        if isprop(x{i, 1}, 'Deletable')
            
            x{i, 1}.Deletable = false;
            
        end
        
        setColor(x{i, 1}, 'y');
        
        setPositionConstraintFcn(x{i, 1}, fcn);
        
               addNewPositionCallback(x{i, 1}, @(h) mycb(i, handles.fixedAllLandmarks, handles));
        
    end
    
    handles.x = x;
    
    handles.AllLandmarks{IndexC, 3} = false;
    
    AllLandmarks = handles.AllLandmarks;
    handles.AllLandmarksC = AllLandmarksC;
    
    %% load the template image and plot the Landmarks.
    fixedAllLandmarks = handles.fixedAllLandmarks;
    LMSelected = handles.LMSelected;
    
    axes(handles.axes1);
    imshow(handles.fix, 'Parent', handles.axes1);
    
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
    
    
else
    
    TempLMs = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
    
    TempLMs = cell2mat(TempLMs);
    
    AllLandmarksC = handles.AllLandmarksC;
    AllLandmarksC(handles.LMSelected, :) = TempLMs(handles.LMSelected, :);
    
    AllLandmarks = handles.AllLandmarks;
    IndexC = handles.IndexC;
    
    AllLandmarks{IndexC, 2} = AllLandmarksC;
    
    AllLandmarks{IndexC, 3} = true;
    
    AllLandmarks{IndexC, 4} = false;
    
    handles.AllLandmarks = AllLandmarks;
    
end

save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks')
% msgbox('Landmarks are saved.')

% update the table
set(handles.Table_ImageList, 'Data', AllLandmarks(:, [3 1]))

guidata(hObject, handles)

uiwait(handles.LandMarks);


% --- Executes on button press in Button_Reset.
function Button_Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Button_SaveLMs, 'enable', 'off');

IndexC = handles.IndexC;

CurrentImage = handles.BackgroundImages{IndexC, 2};

AllLandmarks = handles.AllLandmarks;

AllLandmarks{IndexC, 3} = false;

AllLandmarks{IndexC, 2} = [];

% update the table
set(handles.Table_ImageList, 'Data', AllLandmarks(:, [3 1]))

fix = handles.fix;

fixedFaceLocation = handles.fixedAllLandmarks(handles.FeaturePoints, :);


% draw image
axes(handles.axes2);
ax = handles.axes2;
imshow(CurrentImage);

% get the sizes of fixed and current images

fixWidth = size(fix, 2);
fixHeight = size(fix, 1);

%% calculate the image size difference between the reference and moving images.

WRatio = get(ax,'XLim') / fixWidth;
HRatio = get(ax,'YLim') / fixHeight;

WRatio = WRatio(2) - WRatio(1);
HRatio = HRatio(2) - HRatio(1);

%% locate the face

if any(strcmp(version('-release'), {'2015a', '2015b', '2016a', '2016b'}))
    
    if isfield(handles, 'x')
        
        for i = 1:size(handles.x, 1)
            
            delete(handles.x{i, 1})
            
        end
        
    end
    
end

FaceLocation = fixedFaceLocation * [WRatio, 0; 0, HRatio];

set(handles.Button_SaveLMs, 'enable', 'off');

handles.FLC = FaceLocation;

x = cell(size(FaceLocation, 1), 1);

ax = handles.axes2;
fcn = makeConstrainToRectFcn('impoint', get(ax,'XLim'),get(ax,'YLim'));

for i = 1:size(FaceLocation, 1)
    
    x{i, 1} = impoint(ax, FaceLocation(i, 1), FaceLocation(i, 2));
    
    setString(x{i, 1}, num2str(i));
    
    if isprop(x{i, 1}, 'Deletable')
        
        x{i, 1}.Deletable = false;
        
    end
    
    setColor(x{i, 1}, 'y');
    
    setPositionConstraintFcn(x{i, 1}, fcn);
    
    addNewPositionCallback(x{i, 1}, @(h) mycb(i, fixedFaceLocation, handles));
    
end

handles.LMSaved = false;

handles.x = x;

handles.AllLandmarks = AllLandmarks;

guidata(hObject, handles)


% --- Executes when selected cell(s) is changed in Table_ImageList.
function Table_ImageList_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Table_ImageList (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.LandMarks)

fixedFaceLocation = handles.fixedFaceLocation;

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

%% Save Previous
Saved = {get(handles.Button_SaveLMs, 'enable')};

LMSelected = handles.LMSelected;

if strcmp(Saved, 'on') % if not saved
    
    x = handles.x;
    
    if size(x, 1) == size(handles.fixedAllLandmarks, 1)
        
        TempLMs = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
        
        TempLMs = cell2mat(TempLMs);
        
        AllLandmarksC = handles.AllLandmarksC;
        AllLandmarksC(handles.LMSelected, :) = TempLMs(handles.LMSelected, :);
        
        handles.AllLandmarks{handles.IndexC, 2} = AllLandmarksC;
        
        handles.AllLandmarks{handles.IndexC, 3} = true;
        
        handles.AllLandmarks{handles.IndexC, 4} = false;
        
        AllLandmarks = handles.AllLandmarks;
        
        save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks')
        
        % update the table
        set(handles.Table_ImageList, 'Data', AllLandmarks(:, [3 1]))
        guidata(hObject, handles)
        
    else
        
        FaceLocation = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
        
        FaceLocation = cell2mat(FaceLocation);
        
        IndexC = handles.IndexC;
        
        %% save the face location to AllLandmarks
        
        handles.AllLandmarks{IndexC, 2} = FaceLocation;
        
    end
    
    set(handles.Button_SaveLMs, 'enable', 'off');
    
end

% axes(handles.axes2)
fix = handles.fix;

%% load the current image and its landmarks

if numel(eventdata.Indices) > 0
    
    IndexC = eventdata.Indices(1);
    
    handles.IndexC = IndexC;
    
    CurrentImage = handles.BackgroundImages{IndexC, 2};
    
    PlacedBefore = handles.AllLandmarks{IndexC, 3};
    
    fixedAllLandmarks = handles.fixedAllLandmarks;
    
    ax = handles.axes2;
    axes(handles.axes2)
    
    imshow(CurrentImage, 'Parent', ax);
    
    fcn = makeConstrainToRectFcn('impoint', get(ax,'XLim'), get(ax,'YLim'));
    
    if any(strcmp(version('-release'), {'2015a', '2015b', '2016a', '2016b', '2017a'}))
        
        if isfield(handles, 'x')
            
            for i = 1:size(handles.x, 1)
                
                delete(handles.x{i, 1})
                
            end
            
        end
        
    end
    
    %%
    if PlacedBefore
        
        AllLandmarksC = handles.AllLandmarks{IndexC, 2};
        
        AllLandmarksC(AllLandmarksC(:, 1) < 0, 1) = 1;
        AllLandmarksC(AllLandmarksC(:, 2) < 0, 2) = 1;
        
        AllLandmarksC(AllLandmarksC(:, 1) > size(CurrentImage, 2), 1) = size(CurrentImage, 2) - 1;
        AllLandmarksC(AllLandmarksC(:, 2) > size(CurrentImage, 1), 2) = size(CurrentImage, 1) - 1;
        
        x = cell(size(AllLandmarksC, 1), 1);
        
        LMList = 1:size(AllLandmarksC, 1);
        
        for i = LMList
            
            if LMSelected(i)
                
                x{i, 1} = impoint(ax, AllLandmarksC(i, 1), AllLandmarksC(i, 2));
                
                setString(x{i, 1}, num2str(i));
                
            else
                
                x{i, 1} = impoint(ax, -1, -1);
                
            end
            
            if isprop(x{i, 1}, 'Deletable')
                
                x{i, 1}.Deletable = false;
                
            end
            
            setColor(x{i, 1}, 'y');
            
            setPositionConstraintFcn(x{i, 1}, fcn);
            
            addNewPositionCallback(x{i, 1}, @(h) mycb(i, fixedAllLandmarks, handles));
            
        end
        
        handles.AllLandmarksC = AllLandmarksC;
        
        %% Draw the face template
        
        axes(handles.axes1);
        imshow(handles.fix, 'Parent', handles.axes1);

        xlim([min(fixedFaceLocation(:, 1)) - 30, max(fixedFaceLocation(:, 1)) + 30])
        ylim([min(fixedFaceLocation(:, 2)) - 30, max(fixedFaceLocation(:, 2)) + 30])
        
        hold on
        
        plot(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), '.y');
        scatter(fixedAllLandmarks(LMSelected, 1), fixedAllLandmarks(LMSelected, 2), 40, 'green', 'o');
        
        for i = 1: size(fixedAllLandmarks, 1)
            
            if LMSelected(i)
                
                text(fixedAllLandmarks(i, 1) + 7, fixedAllLandmarks(i, 2) + 5, num2str(i), 'FontSize', 11,...
                    'FontWeight', 'bold', 'BackgroundColor', 'w')
                
            end
            
        end
        
        hold off

    else
        
        FaceLocation = handles.AllLandmarks{IndexC, 2};
        
        fixedFaceLocation = fixedAllLandmarks(handles.FeaturePoints, :);
        
        %% Draw the face template
        axes(handles.axes1);
        imshow(handles.fix, 'Parent', handles.axes1);
        
        xlim([min(fixedFaceLocation(:, 1)) - 30, max(fixedFaceLocation(:, 1)) + 30])
        ylim([min(fixedFaceLocation(:, 2)) - 30, max(fixedFaceLocation(:, 2)) + 30])
        
        hold on
        
        plot(fixedFaceLocation(:, 1), fixedFaceLocation(:, 2), '.y');
        scatter(fixedFaceLocation(:, 1), fixedFaceLocation(:, 2), 40, 'green', 'o');
        
        for i = 1: size(fixedFaceLocation, 1)
            
            text(fixedFaceLocation(i, 1) + 7, fixedFaceLocation(i, 2) + 5, num2str(i), 'FontSize', 11,...
                'FontWeight', 'bold', 'BackgroundColor', 'w')
            
        end
        
        hold off
        
        if size(FaceLocation, 1) == 0 || all(all(FaceLocation == 0))
            
            % get the sizes of fixed and current images
            
            fixWidth = size(fix, 2);
            fixHeight = size(fix, 1);
            
            %% calculate the image size difference between the reference and moving images.
            
            WRatio = get(ax,'XLim') / fixWidth;
            HRatio = get(ax,'YLim') / fixHeight;
            
            WRatio = WRatio(2) - WRatio(1);
            HRatio = HRatio(2) - HRatio(1);
            
            %% locate the face
            
            % tic
            
            FaceLocation = fixedFaceLocation * [WRatio, 0; 0, HRatio];
            
            set(handles.Button_SaveLMs, 'enable', 'off');
            
        else
            
            set(handles.Button_SaveLMs, 'enable', 'on');
            
        end
        
        x = cell(size(FaceLocation, 1), 1);
        
        for i = 1:size(FaceLocation, 1)
            
            x{i, 1} = impoint(ax, FaceLocation(i, 1), FaceLocation(i, 2));
            
            setString(x{i, 1}, num2str(i));
            
            if isprop(x{i, 1}, 'Deletable')
                
                x{i, 1}.Deletable = false;
                
            end
            
            setColor(x{i, 1}, 'y');
            
            setPositionConstraintFcn(x{i, 1}, fcn);
            
            addNewPositionCallback(x{i, 1}, @(h) mycb(i, fixedFaceLocation, handles));
            
        end
        
    end
    
    handles.x = x;
    
end

guidata(hObject, handles)

uiwait(handles.LandMarks)


% --------------------------------------------------------------------
function Toggle_ZoomIn_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Toggle_ZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = zoom;

Pressed = {get(hObject, 'State')};

if strcmp(Pressed, 'on')
    
    set(h,'Direction','in','Enable','on')
    %zoom(1.5)
    setAllowAxesZoom(h,handles.axes1,false)
    setAllowAxesZoom(h,handles.axes2,true)
    
else
    
    set(h,'Direction','in','Enable','off')
    
end


% --------------------------------------------------------------------
function toggle_ZoomOut_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to toggle_ZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Pressed = {get(hObject, 'State')};

if strcmp(Pressed, 'on')
    h = zoom;
    
    set(h,'Direction','out', 'Enable','on');
    %zoom(0.6)
    setAllowAxesZoom(h,handles.axes1,false)
    setAllowAxesZoom(h,handles.axes2,true)
    
else
    h = zoom;
    set(h,'Direction','out','Enable','off')
    
end


% --------------------------------------------------------------------
function Toggle_Pan_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Toggle_Pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = pan;

Pressed = {get(hObject, 'State')};

if strcmp(Pressed, 'on')
    
    set(pan,'Enable','on');
    setAllowAxesPan(h, handles.axes1, false)
    setAxesPanMotion(h, handles.axes2, 'both')
    
else
    
    set(pan,'Enable','off')
    
end


% --- Executes when user attempts to close LandMarks.
function LandMarks_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to LandMarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

%% Save Previous
Saved = get(handles.Button_SaveLMs, 'enable');

x = handles.x;

LMSelected = handles.LMSelected;

if strcmp(Saved, 'on') % if not saved
    
    if size(x, 1) == size(handles.fixedAllLandmarks, 1)
        
        TempLMs = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
        
        TempLMs = cell2mat(TempLMs);
        
        AllLandmarksC = handles.AllLandmarksC;
        AllLandmarksC(handles.LMSelected, :) = TempLMs(handles.LMSelected, :);
        
        handles.AllLandmarks{handles.IndexC, 2} = AllLandmarksC;
        
        handles.AllLandmarks{handles.IndexC, 3} = true;
        
    end
    
end

AllLandmarks = handles.AllLandmarks;

save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks')

% update the table
set(handles.Table_ImageList, 'Data', AllLandmarks(:, [3 1]))
guidata(hObject, handles)

uiresume(handles.LandMarks)


% --------------------------------------------------------------------
function Toggle_Pointer_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Toggle_Pointer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(zoom,'Direction','in','Enable','off')

set(pan,'Enable','off');


% --- Executes on button press in Button_CustomizeLM.
function Button_CustomizeLM_Callback(hObject, eventdata, handles)
% hObject    handle to Button_CustomizeLM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.LandMarks);

set(handles.LandMarks, 'Visible', 'off');

[LMSelected, fixedAllLandmarks, Tris] = ResetLandMarks(handles);

set(handles.LandMarks, 'Visible', 'on');


%% reset the existing points for each image

% TO BE UPDATED...

%% update the current image
if any(strcmp(version('-release'), {'2015a', '2015b', '2016a', '2016b'}))
    
    for i = 1:size(handles.x, 1)
        
        delete(handles.x{i, 1})
        
    end
    
end

IndexC = handles.IndexC;

CurrentImage = handles.BackgroundImages{IndexC, 2};

PlacedBefore = handles.AllLandmarks{IndexC, 3};

if PlacedBefore
    
    fixedAllLandmarks = handles.fixedAllLandmarks;
    
    ax = handles.axes2;
    axes(handles.axes2)
    
    imshow(CurrentImage, 'Parent', ax);
    
    fcn = makeConstrainToRectFcn('impoint', get(ax,'XLim'), get(ax,'YLim'));
    
    AllLandmarksC = handles.AllLandmarks{IndexC, 2};
    
    AllLandmarksC(AllLandmarksC(:, 1) < 0, 1) = 1;
    AllLandmarksC(AllLandmarksC(:, 2) < 0, 2) = 1;
    
    AllLandmarksC(AllLandmarksC(:, 1) > size(CurrentImage, 2), 1) = size(CurrentImage, 2) - 1;
    AllLandmarksC(AllLandmarksC(:, 2) > size(CurrentImage, 1), 2) = size(CurrentImage, 1) - 1;
    
    x = cell(size(AllLandmarksC, 1), 1);
    
    LMList = 1:size(AllLandmarksC, 1);
    
    for i = LMList
        
        if LMSelected(i)
            
            x{i, 1} = impoint(ax, AllLandmarksC(i, 1), AllLandmarksC(i, 2));
            
            setString(x{i, 1}, num2str(i));
            
        else
            
            x{i, 1} = impoint(ax, -1, -1);
            
        end
        
        if isprop(x{i, 1}, 'Deletable')
            
            x{i, 1}.Deletable = false;
            
        end
        
        setColor(x{i, 1}, 'y');
        
        addNewPositionCallback(x{i, 1}, @(h) mycb(i, fixedAllLandmarks, handles));
        
        setPositionConstraintFcn(x{i, 1}, fcn);
        
    end
    
    handles.x = x;
    
end

%%
handles.fixedAllLandmarks = fixedAllLandmarks;
handles.LMSelected = LMSelected;
handles.Tris = Tris;
handles.AllLandmarks(:, 4) = {false};

save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/fixedLandmarks-new.mat'), 'fixedAllLandmarks');
imwrite(handles.fix, strcat('Eye Tracking Projects/', handles.CurrentProject, '/Template-new.png'))
save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Tris.mat'), 'Tris');
save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/LMSelection.mat'), 'LMSelected');

guidata(hObject, handles)

uiwait(handles.LandMarks);


% --------------------------------------------------------------------
function ZoomIn_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function ZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function HandTool_Callback(hObject, eventdata, handles)
% hObject    handle to HandTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Mouse_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Operation_Callback(hObject, eventdata, handles)
% hObject    handle to Operation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
