function varargout = iTemplate(varargin)
% PROJECTMANAGEMENT MATLAB code for ProjectManagement.fig
%      PROJECTMANAGEMENT, by itself, creates a new PROJECTMANAGEMENT or raises the existing
%      singleton*.
%
%      H = PROJECTMANAGEMENT returns the handle to a new PROJECTMANAGEMENT or the handle to
%      the existing singleton*.
%
%      PROJECTMANAGEMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTMANAGEMENT.M with the given input arguments.
%
%      PROJECTMANAGEMENT('Property','Value',...) creates a new PROJECTMANAGEMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProjectManagement_OpeningFcn gets called.  An
%      unrecognized prop`erty name or invalid value makes property application
%      stop.  All inputs are passed to ProjectManagement_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProjectManagement

% Last Modified by GUIDE v2.5 30-Jul-2017 11:04:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProjectManagement_OpeningFcn, ...
                   'gui_OutputFcn',  @ProjectManagement_OutputFcn, ...
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


% --- Executes just before ProjectManagement is made visible.
function ProjectManagement_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProjectManagement (see VARARGIN)
% clear all;

[ScriptFolder, name, ext] = fileparts(mfilename('fullpath'));

addpath(genpath(ScriptFolder));

handles.ScriptFolder = ScriptFolder;

if ismac

    cd(strrep(userpath, ':', ''))

elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

if isdir('Eye Tracking Projects')

    FileList = dir('Eye Tracking Projects/Proj_*');
    
    if size(FileList, 1) > 0

        set(handles.Button_New, 'enable', 'on')
        set(handles.Button_Open, 'enable', 'off')
        set(handles.Button_Close, 'enable', 'on')
        set(handles.Button_Delete, 'enable', 'off')

        FileList = FileList([FileList.isdir] == 1);

        NameList = {FileList.name}'; % project name list
        DateList = {FileList.date}'; % project modified date list
        DateOrder = [FileList.datenum]';

        % sort the lists according to the modified dates
        [k, Order] = sort(DateOrder, 'descend');

        DispNameList = NameList;

        % generate displayed names
        for i = 1:size(NameList, 1)

            DispNameList{i, 1} = strrep(DispNameList{i, 1}, 'Proj_', '');
            DispNameList{i, 1} = strrep(DispNameList{i, 1}, '_', ' ');

        end

        ProjList = [DispNameList, DateList, NameList];

        ProjList = ProjList(Order, :);

        set(handles.Table_ProjList, 'Data', ProjList(:, [1 2])); % the most recent project will be presented on the top

        handles.ProjList = ProjList;
    
    end

else

    mkdir('Eye Tracking Projects')

    % set(handles.Button_New, 'enable', 'on')
    set(handles.Button_Open, 'enable', 'off')
    set(handles.Button_Close, 'enable', 'on')
    set(handles.Button_Delete, 'enable', 'off')

end
    
% end
% Choose default command line output for ProjectManagement
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProjectManagement wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProjectManagement_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Button_New.
function Button_New_Callback(hObject, eventdata, handles)
% hObject    handle to Button_New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.figure1, 'Visible', 'off')

% name the new project

prompt = {'Input a name for your project:'};
dlg_title = 'New Project';
num_lines = 1;
def = {''};
name = inputdlg(prompt,dlg_title,num_lines,def);
    
% create a project folder
if size(name, 1) > 0
    
    FolderName = strrep(name, ' ', '_');
    FolderName = strcat('Eye Tracking Projects/Proj_', FolderName);

    while exist(FolderName{1}, 'dir') == 7

        choice = questdlg('A project folder with the same name exists, please choose another name.', ...
            'Change another name', ...
            'Yes', 'No', 'Yes');

        switch choice

            case 'yes'

                prompt = {'Input a name for your project:'};
                dlg_title = 'New Project';
                num_lines = 1;
                def = {''};
                name = inputdlg(prompt,dlg_title,num_lines,def);

                FolderName = strrep(name, ' ', '_');
                FolderName = strcat('Eye Tracking Projects/Proj_', FolderName);

        end

    end

    mkdir(FolderName{1})

    FolderName = strrep(FolderName{1}, 'Eye Tracking Projects/', '');
    
    NewProject(FolderName, name);
    
end

delete(handles.figure1)

% --- Executes on button press in Button_Open.
function Button_Open_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load the files in the current Project folder

handles.row = 0;
handles.VarList = {};

scale = 1; % change this might spee6d up image registration process.
handles.scale = scale;

addpath(genpath('Eye Tracking Projects'))

rmpath(genpath('Eye Tracking Projects'))

addpath(genpath(strcat('Eye Tracking Projects/', handles.CurrentProject)))

FileList = dir(strcat('Eye Tracking Projects/', handles.CurrentProject));

if size([FileList.name], 1) ~= 0

    if exist('BackgroundImages.mat', 'file') == 2

        load('BackgroundImages.mat')
    
    else

        msgbox('BackgroundImages.mat is missing!')
        
    end

    if exist('newImages.mat', 'file') == 2

       load('newImages.mat')
       
    else

        msgbox('newImages.mat is missing!')

    end

    if exist('Landmarks.mat', 'file') == 2

        load('Landmarks.mat')
    
    else
        
        msgbox('Landmarks.mat is missing!')

    end

    if exist('Tris.mat', 'file') == 2

        load('Tris.mat')
        
    else
        
        msgbox('Tris.mat is missing!')

    end

    if exist('TFMatrix.mat', 'file') == 2

       load('TFMatrix.mat')
       
    else
        
        msgbox('TFMatrix.mat is missing!')

    end

    if exist('Template-new.png', 'file') == 2

        fix = imread('Template-new.png');
        load('fixedLandmarks-new.mat');

    else

        if exist('Template.png', 'file') == 2
            
            fix = imread('Template.png');
            load('fixedLandmarks.mat');
            
        else
            
            msgbox('Reference image or fixedLandmarks.mat is missing!')
            
        end

    end
    
    if exist('LMSelection.mat', 'file') == 2

       load('LMSelection.mat')
       
    else
        
        %msgbox('LMSelection.mat is missing!')
        LMSelected = true(size(fixedAllLandmarks, 1), 1);
        save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/LMSelection.mat'), 'LMSelected')

    end
    
    if exist('FixationData.mat', 'file') == 2

       load('FixationData.mat')
       handles.FixationData = FixationData;
       
    end
    
    handles.newImages = newImages;
    handles.TFMatrix = TFMatrix;
    handles.BackgroundImages = BackgroundImages;
    handles.AllLandmarks = AllLandmarks;
    handles.Tris = Tris;
    handles.fix = fix;
    handles.fixedAllLandmarks = fixedAllLandmarks;
    handles.LMSelected = LMSelected;
    
else
    
    msgbox('The project folder is empty!')
    
end

set(handles.figure1, 'Visible', 'off')

x = GUI_beta(handles);

delete(handles.figure1)


% --- Executes on button press in Button_Close.
function Button_Close_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1)


% --- Executes when selected cell(s) is changed in Table_ProjList.
function Table_ProjList_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Table_ProjList (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

CurrentProject = get(handles.Table_ProjList, 'Data');

if numel(eventdata.Indices) > 0
    
    row = eventdata.Indices(1);
    col = eventdata.Indices(2);

    handles.CurrentProject = handles.ProjList{row, 3};
    
    set(handles.Button_Open, 'enable', 'on')
    set(handles.Button_Delete, 'enable', 'on')
    
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in Button_Delete.
function Button_Delete_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load the files in the current Project folder

if isfield(handles, 'CurrentProject')
    
     choice = questdlg('Are you going to delete this project?', ...
        '', ...
        'Yes', 'No', 'Yes');
    
    % Handle response
    switch choice
        
        case 'Yes'
            
            rmdir(strcat('Eye Tracking Projects/', handles.CurrentProject), 's')

            handles = rmfield(handles, 'CurrentProject');

            if ismac

                cd(strrep(userpath, ':', ''))

            elseif ispc

                cd(strrep(userpath, ';', ''))

            end

            FileList = dir('Eye Tracking Projects/Proj_*');
            FileList = FileList([FileList.isdir] == 1);

            NameList = {FileList.name}'; % project name list
            DateList = {FileList.date}'; % project modified date list
            DateOrder = [FileList.datenum]';

            % sort the lists according to the modified dates
            [k, Order] = sort(DateOrder, 'descend');

            DispNameList = NameList;

            % generate displayed names
            for i = 1:size(NameList, 1)

                DispNameList{i, 1} = strrep(DispNameList{i, 1}, 'Proj_', '');
                DispNameList{i, 1} = strrep(DispNameList{i, 1}, '_', ' ');

            end

            ProjList = [DispNameList, DateList, NameList];
            
            ProjList = ProjList(Order, :);

            set(handles.Table_ProjList, 'Data', ProjList(:, [1 2])); % the most recent project will be presented on the top

            handles.ProjList = ProjList;

            guidata(hObject, handles)
            
            set(handles.Button_Delete, 'enable', 'off')
            set(handles.Button_Open, 'enable', 'off')
    
    end

end
