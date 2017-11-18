function varargout = NewProject(varargin)
% NEWPROJECT MATLAB code for NewProject.fig
%      NEWPROJECT, by itself, creates a new NEWPROJECT or raises the existing
%      singleton*.
%
%      H = NEWPROJECT returns the handle to a new NEWPROJECT or the handle to
%      the existing singleton*.
%
%      NEWPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWPROJECT.M with the given input arguments.
%
%      NEWPROJECT('Property','Value',...) creates a new NEWPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewProject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewProject

% Last Modified by GUIDE v2.5 30-Jul-2017 13:33:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NewProject_OpeningFcn, ...
    'gui_OutputFcn',  @NewProject_OutputFcn, ...
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


% --- Executes just before NewProject is made visible.
function NewProject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewProject (see VARARGIN)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

[ScriptFolder, name, ext] = fileparts(mfilename('fullpath'));

addpath(genpath(ScriptFolder));

handles.ScriptFolder = ScriptFolder;

handles.Ready = false;

handles.ProjName = varargin{1};
handles.ProjName = strcat('Eye Tracking Projects/', handles.ProjName);

set(handles.Text_ProjName, 'String', varargin{2});

% Choose default command line output for NewProject
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

uiwait(handles.NewProjectWindow)

% UIWAIT makes NewProject wait for user response (see UIRESUME)
% uiwait(handles.NewProjectWindow);


% --- Outputs from this function are returned to the command line.
function varargout = NewProject_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 1;


% --- Executes on button press in Button_ImptImages.
function Button_ImptImages_Callback(hObject, eventdata, handles)
% hObject    handle to Button_ImptImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

ImageDataFolder = uigetdir('~/', 'Choose the image folder');

if ImageDataFolder ~= 0
    
    addpath(ImageDataFolder);
    
    ImageList = dir(ImageDataFolder);
    
    ImageList = ImageList([ImageList.isdir] == 0);
    
    rmList = [];
    
    for i = 1:size(ImageList, 1)
        
        [folder, name, extension] = fileparts(ImageList(i).name);
        
        if ~ismember(extension, {'.jpg', '.bmp', '.png', '.tiff', '.tif', '.gif'})
            
            rmList = [rmList, i];
            
        end
        
    end
    
    ImageList(rmList) = [];
    
    handles.row = 0;
    handles.VarList = {};
    
    scale = 1; % change this might spee6d up image registration process.
    handles.scale = scale;
    
    %% Read images
    % Exclude the index files
    ImageName = {ImageList.name}';
    
    ImageName = sortrows(ImageName, 1);
    
    BackgroundImages = cell(numel(ImageName), 3);
    
    BackgroundImages(:, 1) = ImageName;
    
    handles.ImageName = ImageName;
    
    if isfield(handles, 'FixationData')
        
        StimuliListFix = unique(handles.FixationData(:, 'Stimuli'));
        
        ImageList = table(handles.ImageName, repmat(true, [numel(handles.ImageName) 1]),...
            'VariableNames',{'Stimuli','Image'});
        
        StimuliListFix{:, 'Fixation'} = repmat(true, [numel(StimuliListFix) 1]);
        
        K = outerjoin(ImageList, StimuliListFix, 'MergeKeys', true);
        
        StimuliListFix = table2cell(K);
        
    else
        
        ImageList = table(handles.ImageName, repmat(true, [numel(handles.ImageName) 1]),...
            repmat(false, [numel(handles.ImageName) 1]),...
            'VariableNames',{'Stimuli','Image', 'Fixation'});
        
        StimuliListFix = table2cell(ImageList);
        
    end
    
    set(handles.Table_StimuliList, 'Data', StimuliListFix);
    
    handles.Ready = all([StimuliListFix{:, 2}]);
    
    % ready for start?
    if all([StimuliListFix{:, 2}])
        
        set(handles.Button_Start, 'enable', 'on')
        
    else
        
        set(handles.Button_Start, 'enable', 'off')
        
    end
    
    WBh = waitbar(0, {'Images are importing'; 'Please wait....'});
    
    for i = 1:numel(ImageName)
        
        x = imread(ImageName{i});
        
        info = imfinfo(ImageName{i});
        
        if any(info.ColorType ~= 'grayscale')
            
            x = rgb2gray(x);
            
        end
        
        x = imresize(x, scale);
        
        BackgroundImages{i, 2} = x;
        
        % record the corner for each image
        w = size(x, 2);
        h = size(x, 1);
        
        BackgroundImages{i, 3} = [1 1; w 1; 1 h; w h];
        
        waitbar(i/numel(ImageName), WBh)
        
    end
    
    save(strcat(handles.ProjName, '/BackgroundImages.mat'), 'BackgroundImages');
    
    close(WBh)
    %% new images
    
    newImages = BackgroundImages;
    save(strcat(handles.ProjName, '/newImages.mat'), 'newImages');
    
    %% fixed image and fixedlandmarks
    
    [pathstr, name, ext] = fileparts(mfilename('fullpath'));
    [DataFolder, name, ext] = fileparts(pathstr);
    
    if ~any(exist('Template.png', 'file') == 2 | exist('fixedLandmarks.mat', 'file') == 2 |...
            exist('Tris.mat', 'file') == 2)
        
        warndlg('Where is the template image(Template.png) and the fixedLandmarks.mat file?')
        
    else
        
        % load the reference image
        
        fix = imread('Template.png');
        
        Width = size(fix, 2);
        Height = size(fix, 1);
        
        cd(handles.DataFolder)
        
        load('fixedLandmarks.mat');
        
        load('Tris.mat');
        
        if ismac
            
            cd(strrep(userpath, ':', ''))
            
        elseif ispc
            
            cd(strrep(userpath, ';', ''))
            
        end
        
        imwrite(fix, strcat(handles.ProjName, '/Template.png'));
        save(strcat(handles.ProjName, '/fixedLandmarks.mat'), 'fixedAllLandmarks');
        save(strcat(handles.ProjName, '/Tris.mat'), 'Tris')
        
    end
    
    %% Landmarks
    if ismac
        
        cd(strrep(userpath, ':', ''))
        
    elseif ispc
        
        cd(strrep(userpath, ';', ''))
        
    end
    
    AllLandmarks = cell(numel(ImageName), 4);
    
    AllLandmarks(1:end, 1) = ImageName;
    AllLandmarks(1:end, 2) = {zeros(size(fixedAllLandmarks, 1), 2)};
    AllLandmarks(1:end, 3) = {false}; % Landmarks placed or not
    AllLandmarks(1:end, 4) = {false}; % transformed or not
    
    save(strcat(handles.ProjName, '/Landmarks.mat'), 'AllLandmarks'); %, 'FaceLocations');
    
    %% LandMark selection
    
    LMSelected = true(size(fixedAllLandmarks, 1), 1);
    save(strcat(handles.ProjName, '/LMSelection.mat'), 'LMSelected')
    handles.LMSelected = LMSelected;
    
    %% Transform matrix
    
    fixedAllLandmarksT = [fixedAllLandmarks; [1 1; 1 Width; Height 1; Width Height]];
    
    Tris = delaunayTriangulation(fixedAllLandmarksT);
    
    TFMatrix = cell(numel(ImageName), size(Tris, 1), 3); % three dimentions: 1, image name; 2, tranangle points; and 3, TFmatrix
    
    for i = 1: numel(ImageName)
        
        TFMatrix(i, :, 1) = ImageName(i);
        
    end
    
    save(strcat(handles.ProjName, '/TFMatrix.mat'), 'TFMatrix');
    
    % handles.ImageName = ImageName{1};
    
    handles.newImages = newImages;
    handles.TFMatrix = TFMatrix;
    handles.BackgroundImages = BackgroundImages;
    handles.AllLandmarks = AllLandmarks;
    handles.Tris = Tris;
    handles.fix = fix;
    handles.fixedAllLandmarks = fixedAllLandmarks;
    
    msgbox('All images are imported!')
    
end

guidata(hObject, handles)


% --- Executes on button press in Button_ImptFixation.
function Button_ImptFixation_Callback(hObject, eventdata, handles)
% hObject    handle to Button_ImptFixation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

[FixationFile, FixationPath] = uigetfile({'*.xlsx; *.xls; *.csv',  'Excel File (*.xlsx, .xls) or CSV file (*.csv)'}, 'Select the Fixation File');

if FixationFile ~= 0
    
    %% UI Control
    
    set(hObject, 'enable', 'off')
    set(handles.Button_Start, 'enable', 'off')
    set(handles.Button_ImptImages, 'enable', 'off')
    
    %%
    
    FixationFile = strcat(FixationPath, '/', FixationFile);
    
    [pathstr, name, ext] = fileparts(FixationFile);
    
    if strcmp(ext, '.xlsx') | strcmp(ext, '.xls')
        
        [k1 k2 FixationData] = xlsread(FixationFile);
        
        Names = FixationData(1, :);
        FixationData(1, :) = [];
        
        FixationData = cell2table(FixationData, 'VariableNames', Names);
        
    elseif strcmp(ext, '.csv')
        
        FixationData = readtable(FixationFile);
        
    end
    
    FixationData = sortrows(FixationData, {'Stimuli' 'X' 'Y'}, 'ascend');
    
    handles.FixationData = FixationData;
    
    StimuliListFix = unique(FixationData(:, 'Stimuli'));
    
    if isfield(handles, 'ImageName')
        
        ImageName = table(handles.ImageName, repmat(true, [numel(handles.ImageName) 1]),...
            'VariableNames',{'Stimuli','Image'});
        
        StimuliListFix{:, 'Fixation'} = repmat(true, [numel(StimuliListFix) 1]);
        
        K = outerjoin(ImageName, StimuliListFix, 'MergeKeys', true);
        
        StimuliListFix = table2cell(K);
        
    else
        
        StimuliListFix{:, 'Image'} = repmat(false, [numel(StimuliListFix) 1]);
        
        StimuliListFix{:, 'Fixation'} = repmat(true, [numel(StimuliListFix) 1]);
        
        StimuliListFix = table2cell(StimuliListFix);
        
    end
    
    set(handles.Table_StimuliList, 'Data', StimuliListFix);
    
    save(strcat(handles.ProjName, '/FixationData.mat'), 'FixationData')
    
    handles.Ready = all([StimuliListFix{:, 2}]);
    
    msgbox('Fixation files has been imported!')
    
    %% ready for start?
    if all([StimuliListFix{:, 2}])
        
        set(handles.Button_Start, 'enable', 'on')
        
    else
        
        set(handles.Button_Start, 'enable', 'off')
        
    end
    
end

set(hObject, 'enable', 'on')
set(handles.Button_ImptImages, 'enable', 'on')

guidata(hObject, handles)


% --- Executes on button press in Button_Start.
function Button_Start_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.CurrentProject = strrep(handles.ProjName, 'Eye Tracking Projects/', '');

handles = rmfield(handles, 'ProjName');

set(handles.NewProjectWindow, 'Visible', 'off');

GUI_beta(handles);

delete(handles.NewProjectWindow)

% --- Executes when user attempts to close NewProjectWindow.
function NewProjectWindow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to NewProjectWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

choice = questdlg('Are you going to close the window now? The current project will NOT be saved.', ...
    '', ...
    'Yes', 'No', 'Yes');

% Handle response
switch choice
    
    case 'Yes'
        
        rmdir(strcat(handles.ProjName), 's')
        
        % Hint: delete(hObject) closes the figure
        uiresume(handles.NewProjectWindow)
        delete(hObject);
end
