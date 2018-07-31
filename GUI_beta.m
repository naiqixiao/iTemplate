function varargout = GUI_beta(varargin)
% GUI_beta MATLAB code for GUI_beta.fig
%   GUI_beta, by itself, creates a new GUI_beta or raises the existing
%   singleton*.
%
%   H = GUI_beta returns the handle to a new GUI_beta or the handle to
%   the existing singleton*.
%
%   GUI_beta('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in GUI_beta.M with the given input arguments.
%
%   GUI_beta('Property','Value',...) creates a new GUI_beta or raises the
%   existing singleton*. Starting from the left, property value pairs are
%   applied to the GUI_beta before GUI_beta_OpeningFcn gets called. An
%   unrecognized property name or invalid value makes property application
%   stop. All inputs are passed to GUI_beta_OpeningFcn via varargin.
%
%   *See GUI_beta Options on GUIDE's Tools menu. Choose "GUI_beta allows only one
%   instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_beta

% Last Modified by GUIDE v2.5 17-Nov-2017 23:07:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',    mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @GUI_beta_OpeningFcn, ...
    'gui_OutputFcn', @GUI_beta_OutputFcn, ...
    'gui_LayoutFcn', [] , ...
    'gui_Callback',  []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT

% --- Executes just before GUI_beta is made visible.
function GUI_beta_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject  handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)
% varargin  command line arguments to GUI_beta (see VARARGIN)

set(handles.Table_Stimuli, 'enable', 'off');
set(handles.Table_Fixation, 'enable', 'off');

%%set(handles.Button_ShowFolder, 'enable', 'on');
set(handles.Button_NewDraw, 'enable', 'off');
set(handles.Button_FixationDataProcessing, 'enable', 'off');
set(handles.Button_ExportiMap, 'enable', 'off');
set(handles.Button_ModifyReferenceImage, 'enable', 'off');
set(handles.Button_Transform, 'enable', 'off');
set(handles.Button_AOI, 'enable', 'off');
set(handles.Button_Reset, 'enable', 'off');

data = varargin{1};

addpath(data.ScriptFolder);

handles.BackgroundImages = data.BackgroundImages;
handles.AllLandmarks = data.AllLandmarks;
handles.TFMatrix = data.TFMatrix;
handles.newImages = data.newImages;
handles.Tris = data.Tris;
handles.fix = data.fix;
handles.fixedAllLandmarks = data.fixedAllLandmarks;
handles.CurrentProject = data.CurrentProject;
handles.LMSelected = data.LMSelected;

handles.fixedFaceLocation = handles.fixedAllLandmarks(end -3 : end, :);

handles.row = 0;
handles.VarList = {};

%% image resize
if ~exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Scale.mat'), 'file')
    
    SampleImage = handles.BackgroundImages{1, 2};
    [H W] = size(SampleImage);
    
    W1 = W ./ 540;
    H1 = H ./ 405;
    
    scale = 1 / min(H1, W1);
    handles.scale = scale;
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Scale.mat'), 'scale');
    
    %% resize BackgroundImages
    
    for i = 1:size(handles.BackgroundImages, 1)
        
        handles.BackgroundImages{i, 2} = imresize(handles.BackgroundImages{i, 2}, scale);
        
        w = size(handles.BackgroundImages{i, 2}, 2);
        h = size(handles.BackgroundImages{i, 2}, 1);
        
        handles.BackgroundImages{i, 3} = [1 1; w 1; 1 h; w h];
        
    end
    
    BackgroundImages = handles.BackgroundImages;
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/BackgroundImages.mat'), 'BackgroundImages');
    
    %% resize the landmarks
    for i = 1:size(handles.AllLandmarks, 1)
        
        handles.AllLandmarks{i, 2} = handles.AllLandmarks{i, 2} .* scale;
        
    end
    
    AllLandmarks = handles.AllLandmarks;
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks');

else
    
    load('Scale.mat');
    
    handles.scale = scale;
    
end
%%

handles.ImageName = handles.BackgroundImages(1, 1);

set(hObject, 'Name', handles.CurrentProject);

if strcat(strrep(userpath, ':', '/'), 'Eye Tracking Projects/', handles.CurrentProject, '/Template-new.png')
    
    set(handles.Button_ResetReference, 'enable', 'on')
    
else
    
    set(handles.Button_ResetReference, 'enable', 'off')
    
end


if isfield(data, 'FixationData')
    
    handles.FixationData = data.FixationData;
    
    %% list Fixation Data
    VarList = handles.FixationData.Properties.VariableNames;
    
    VarList = VarList(~ismember(VarList, ['ParticipantName']));
    VarList = VarList(~ismember(VarList, ['FixationIndex']));
    VarList = VarList(~ismember(VarList, ['Stimuli']));
    VarList = VarList(~ismember(VarList, ['X']));
    VarList = VarList(~ismember(VarList, ['Y']));
    VarList = VarList(~ismember(VarList, ['Duration']));
    VarList = VarList(~ismember(VarList, ['Xtf']));
    VarList = VarList(~ismember(VarList, ['Ytf']));
    
    VarList(2, :) = {false};
    
    set(handles.Table_Fixation, 'Data', VarList');
    
    
end

set(handles.Table_Stimuli, 'Data', handles.AllLandmarks(:, [1 3 4]));

%% present the first image to the frames
handles.CurrentImage = handles.BackgroundImages{1, 2};
handles.ModifiedImage = handles.newImages{1, 2};

handles.BlurRatio = size(handles.CurrentImage, 2) / size(handles.ModifiedImage, 2);

axes(handles.axes_ImageShowOriginal);
imshow(handles.CurrentImage);

axes(handles.axes_ImageShowModified);
imshow(handles.ModifiedImage);

if handles.AllLandmarks{1, 3}
    
    xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
    ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
    
end

%%

set(handles.Table_Fixation, 'enable', 'off');

set(handles.Table_Stimuli, 'enable', 'on');
set(handles.Button_NewDraw, 'enable', 'on');
set(handles.Button_FixationDataProcessing, 'enable', 'on');

% UI options given certain conditions
PlacedBefore = any([handles.AllLandmarks{:, 3}]);

if PlacedBefore
    
    set(handles.Button_ModifyReferenceImage, 'enable', 'on');
    set(handles.Button_Transform, 'enable', 'on');
    set(handles.Button_Reset, 'enable', 'on');
    
else
    
    set(handles.Button_Reset, 'enable', 'off');
    set(handles.Button_ModifyReferenceImage, 'enable', 'off');
    set(handles.Button_Transform, 'enable', 'off');

end

if isfield(handles, 'FixationData')
    
    FixationTransformed = isfield(handles.FixationData, 'Xft');
    
else
    
    FixationTransformed = 0;
    
end

if FixationTransformed
    
    set(handles.PresentationOptions, 'enable', 'on');
    set(handles.Button_AOI, 'enable', 'on');
    set(handles.Button_ExportiMap, 'enable', 'on');
    
else
    
    set(handles.PresentationOptions, 'enable', 'off');
    set(handles.Button_AOI, 'enable', 'off');
    set(handles.Button_ExportiMap, 'enable', 'off');
    
end

% Choose default command line output for GUI_beta
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if exist('data', 'var')
    
    clear 'data';
    
end

uiwait(handles.MainGUI)


% UIWAIT makes GUI_beta wait for user response (see UIRESUME)
% uiwait(handles.MainGUI);
function varargout = GUI_beta_OutputFcn(hObject, eventdata, handles)
% This function has no output args, see OutputFcn.
% hObject  handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)
% varargin  command line arguments to GUI_beta (see VARARGIN)
varargout{1} = 1;


% Hints: contents = cellstr(get(hObject,'String')) returns Listbox_ImageList contents as cell array
%    contents{get(hObject,'Value')} returns selected item from Listbox_ImageList


% --- Executes on button press in Button_FixationDataProcessing.
function Button_FixationDataProcessing_Callback(hObject, eventdata, handles)
% hObject  handle to Button_FixationDataProcessing (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)
if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

if all([handles.AllLandmarks{:, 4}])
    
    % in the future release one might be able to choose .xls or .csv
    % formates
    
    if ~isfield(handles, 'FixationData')
        
        [FixationFile, FixationPath] = uigetfile({'*.xlsx; *.xls; *.csv', 'Excel File (*.xlsx, .xls) or CSV file (*.csv)'}, 'Select the Fixation File');
        
        if FixationFile ~= 0
            
            set(handles.Table_Stimuli, 'enable', 'off');
            set(handles.Table_Fixation, 'enable', 'off');
            
            %set(handles.Button_ShowFolder, 'enable', 'off');
            set(handles.Button_NewDraw, 'enable', 'off');
            set(handles.Button_FixationDataProcessing, 'enable', 'off');
            set(handles.Button_ExportiMap, 'enable', 'off');
            
            set(handles.PresentationOptions, 'enable', 'off');
            
            FixationFile = strcat(FixationPath, '/', FixationFile);
            
            [pathstr, name, ext] = fileparts(FixationFile);
            
            if strcmp(ext, '.xlsx') | strcmp(ext, '.xls')
                
                [k1 k2 FixationData] = xlsread(FixationFile);
                
                Names = FixationData(1, :);
                
                for i = 1: size(Names, 2)
                    
                    Names{1, i} = strrep(Names{1, i}, ' ', '_');
                    
                end
                
                FixationData(1, :) = [];
                
                FixationData = cell2table(FixationData, 'VariableNames', Names);
                
            elseif strcmp(ext, '.csv')
                
                FixationData = readtable(FixationFile);
                Names = FixationData.Properties.VariableNames;
                % FixationData = table2cell(FixationData);
                
            end
            
            FixationData = sortrows(FixationData, {'Stimuli' 'X' 'Y'},'ascend');
            handles.FixationData = FixationData;
            
        else
            
            warndlg('Where is the Fixation data?');
            
        end
        
    else
        
        FixationData = handles.FixationData;
        
    end
    
    %% transform fixation data
    % FixationData(:, y) = strrep(FixationData(:, y), '"', '');
    if exist('FixationData', 'var')
        
        ImageName = get(handles.Table_Stimuli, 'Data');
        ImageName = ImageName(:, 1);
        
        FixationData{:, 'X'} = FixationData{:, 'X'} * handles.scale;
        FixationData{:, 'Y'} = FixationData{:, 'Y'} * handles.scale;
        
        FixationData{:, 'Xtf'} = 0;
        FixationData{:, 'Ytf'} = 0;
        
        TFMatrix = handles.TFMatrix;
        AllLandmarks = handles.AllLandmarks;
        
        Tris = handles.Tris; % delaunayTriangulation(AllLandmarks{j, 1});
        
        steps = size(ImageName, 1);
        step = 0;
        
        h = waitbar(step/steps, {'Fixation transformation is running.'; 'Please wait....'});
        
        for j = 1:size(ImageName, 1)
            
            CurrentStimuli = ImageName{j, 1};
            
            if any(ismember(FixationData.Stimuli, CurrentStimuli))
                
                TriIndex = FixationData(ismember(FixationData.Stimuli, CurrentStimuli), {'X' 'Y'});
                
                AllLandmarksC = AllLandmarks{j, 2};
                
                AllLandmarksC = AllLandmarksC(handles.LMSelected, :);
                
                Tris.Points = [AllLandmarksC; handles.BackgroundImages{j, 3}];
                
                TriIndex.TriangleIndex = pointLocation(Tris, TriIndex.X, TriIndex.Y);
                
                TriIndex = sortrows(TriIndex, 'TriangleIndex', 'ascend');
                
                k = unique(TriIndex.TriangleIndex); % get the trianale list
                k = k(k > 0);
                
                func = @(X, Y) [X Y X./X];
                
                XXX = rowfun(func, TriIndex, 'GroupingVariables', 'TriangleIndex', 'OutputFormat', 'cell');
                
                C = cellfun(@mtimes, XXX, TFMatrix(j, k, 3)', 'UniformOutput', false); % transformed coordinates
                
                C = cell2mat(C);
                
                TriIndex{:, 'Xtf'} = -1;
                TriIndex{:, 'Ytf'} = -1;
                
                TriIndex{TriIndex.TriangleIndex > 0, 'Xtf'} = C(:, 1);
                TriIndex{TriIndex.TriangleIndex > 0, 'Ytf'} = C(:, 2);
                
                TriIndex = sortrows(TriIndex, {'X' 'Y'},'ascend');
                
                FixationData{ismember(FixationData.Stimuli, CurrentStimuli), 'Xtf'} = TriIndex.Xtf;
                FixationData{ismember(FixationData.Stimuli, CurrentStimuli), 'Ytf'} = TriIndex.Ytf;
                
                step = step + 1;
                
                waitbar(step/steps, h)
                
            else
                
                step = step + 1;
                
                waitbar(step/steps, h)
                
            end
            
        end
        
        %% scales back the fixation data
        
        FixationData{:, 'X'} = FixationData{:, 'X'} / handles.scale;
        FixationData{:, 'Y'} = FixationData{:, 'Y'} / handles.scale;
        
        FixationData{:, 'Xtf'} = FixationData{:, 'Xtf'} / handles.scale;
        FixationData{:, 'Ytf'} = FixationData{:, 'Ytf'} / handles.scale;
        
        %% list Fixation Data
        VarList = FixationData.Properties.VariableNames;
        
        VarList = VarList(~ismember(VarList, ['ParticipantName']));
        VarList = VarList(~ismember(VarList, ['FixationIndex']));
        VarList = VarList(~ismember(VarList, ['Stimuli']));
        VarList = VarList(~ismember(VarList, ['X']));
        VarList = VarList(~ismember(VarList, ['Y']));
        VarList = VarList(~ismember(VarList, ['Xtf']));
        VarList = VarList(~ismember(VarList, ['Ytf']));
        VarList = VarList(~ismember(VarList, ['Duration']));
        
        VarList(2, :) = {false};
        
        handles.FixationData = FixationData;
        
        close(h)
        
        %% Export
        
        if ismac
            
            cd(strrep(userpath, ':', ''))
            
        elseif ispc
            
            cd(strrep(userpath, ';', ''))
            
        end
        
        save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/FixationData.mat'), 'FixationData')
        SaveCSV(strcat('Eye Tracking Projects/', handles.CurrentProject, '/FixationTF.csv'), FixationData);
        
        choice = questdlg({'Fixations have been transformed and registered to the template.';...
            'Do you want to export the transformed data?'}, ...
            '', ...
            'Yes', 'No', 'Yes');
        
        switch choice
            
            case 'Yes'
                
                [FileName, PathName] = uiputfile('FixationTF.csv', 'Save Fixation File');
                
                if PathName ~= 0
                    
                    copyfile(strcat('Eye Tracking Projects/', handles.CurrentProject, '/FixationTF.csv'),...
                        strcat(PathName, FileName), 'f')
                    
                    msgbox('Export done!')
                    
                end
                
        end
        
        %%
        set(handles.Table_Fixation, 'Data', VarList');
        
        set(handles.Table_Stimuli, 'enable', 'on');
        set(handles.Table_Fixation, 'enable', 'on');
        
        set(handles.Button_NewDraw, 'enable', 'on');
        set(handles.Button_FixationDataProcessing, 'enable', 'on');
        set(handles.Button_ExportiMap, 'enable', 'on');
        set(handles.Button_AOI, 'enable', 'on');
        
        set(handles.PresentationOptions, 'enable', 'on');
        
    else
        
        set(handles.Table_Stimuli, 'enable', 'on');
        set(handles.Table_Fixation, 'enable', 'on');
        
        set(handles.Button_NewDraw, 'enable', 'on');
        set(handles.Button_FixationDataProcessing, 'enable', 'on');
        
    end
    
else
    
    msgbox('Please transform all the images before analyzing fixation data.');
    
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in Button_ExportiMap.
function Button_ExportiMap_Callback(hObject, eventdata, handles)
% hObject  handle to Button_ExportiMap (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% Export for iMap

ExportFolder = uigetdir('~/', 'Choose your export location.');

if ExportFolder ~= 0
    
    FixationData = handles.FixationData;
    
    %% iMap4
    SaveCSV_iMap4(ExportFolder, handles.CurrentProject, FixationData);
    
    %     %% iMap2
    %
    %     % provide a list of variable names
    %
    %     VarList = handles.VarList;
    %
    %     VarList = {VarList{find([VarList{:, 2}]), 1}, 'ParticipantName' };
    %
    %     %VarList = {VarList{:, }, 'ParticipantName'};
    %
    %     k = FixationData(:, VarList);
    %     UniValue = unique(k);
    %     UniValue.Index = [UniValue{:, VarList}];
    %     FixationData.Index = [FixationData{:, VarList}];
    %
    %     % change stimuli names to numbers
    %     Stimuli = FixationData(:, 'Stimuli');
    %     Stimuli = unique(Stimuli);
    %     Stimuli.StimuliName = [1:numel(Stimuli)]';
    %
    %     FixationData = join(FixationData, Stimuli);
    %
    %     x = dir(ExportFolder);
    %
    %     if all(ismember({x.name}, strcat('iMap2_', handles.CurrentProject)))
    %
    %         rmdir(strcat(ExportFolder, '/iMap2_', handles.CurrentProject), 's');
    %
    %     end
    %
    %     mkdir(strcat(ExportFolder, '/iMap2_', handles.CurrentProject));
    %
    %     steps = size(UniValue, 1);
    %     step = 0;
    %
    %     h = waitbar(step/steps, {'iMap2 data export is running.';'Please wait....'});
    %
    %     for i = 1:size(UniValue, 1)
    %
    %         DataIndex = ismember(FixationData{:, 'Index'}, UniValue{i, 'Index'});
    %
    %         if size(DataIndex, 2) == 1
    %
    %             I = DataIndex(:,1);
    %
    %         else
    %
    %             I = DataIndex(:,1) .* DataIndex(:,2);
    %
    %         end
    %
    %         I = logical(I);
    %
    %         vars = {'FixationIndex', 'Duration', 'Xtf', 'Ytf', 'StimuliName'};
    %         summary = FixationData(I, vars); % FixationIndex; Duration; X; Y; Stimuli
    %
    %         summary = table2cell(summary);
    %         summary = cell2mat(summary);
    %
    %         add = strcat(ExportFolder, '/iMap2_', handles.CurrentProject, '/data', num2str(i), '.mat');
    %
    %         save(add, 'summary');
    %
    %         UniValue{i, 'FileName'} = {strcat('data', num2str(i))};
    %
    %         step = step + 1;
    %
    %         waitbar(step / steps, h)
    %
    %         %uistack(h, 'top')
    %
    %     end
    %
    %     %UniValue = UniValue(:, {VarList{:}, 'FileName'});
    %     UniValue = UniValue(:, [VarList, 'FileName']);
    %
    %     %writetable(UniValue, 'iMapData/iMap_Condition_List.csv');
    %
    %     SaveCSV(strcat(ExportFolder, '/iMap2_', handles.CurrentProject, '/iMap_Condition_List.csv'), UniValue);
    %
    %     close(h)
    %
    %%
    msgbox('iMap files are ready to use. Find them in the iMapData folder!')
    
else
    
    msgbox('You have not select an export location yet.')
    
end



% --- Executes when selected cell(s) is changed in Table_Stimuli.
function Table_Stimuli_CellSelectionCallback(hObject, eventdata, handles)
% hObject  handle to Table_Stimuli (see GCBO)
% eventdata structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles  structure with handles and user data (see GUIDATA)

ImageList = get(handles.Table_Stimuli, 'Data');

set(handles.text2, 'String', 'Transformed Image');

if numel(eventdata.Indices) > 0
    
    row = eventdata.Indices(1);
    
    ImageName = ImageList{row, 1};
    
    BackgroundImages = handles.BackgroundImages;
    
    newImages = handles.newImages;
    
    ImageIndex = ismember(newImages(:, 1), ImageName);
    
    handles.CurrentImage = BackgroundImages{ImageIndex, 2};
    
    handles.ModifiedImage = newImages{ImageIndex, 2};
    
    handles.BlurRatio = size(handles.CurrentImage, 2) / size(handles.ModifiedImage, 2);
    
    contents = cellstr(get(handles.PresentationOptions,'String'));
    
    PresentationOption = contents{get(handles.PresentationOptions, 'Value')};
    
    handles.ImageName = ImageName;
    
    if isfield(handles, 'FixationData')
        
        FixationData = handles.FixationData;
        
        FixationIndex = ismember(FixationData{:, 'Stimuli'}, handles.ImageName);
        
        %% scale fixations
        if ismember('X', FixationData.Properties.VariableNames)
            
            FixationData{:, 'X'} = FixationData{:, 'X'} * handles.scale;
            FixationData{:, 'Y'} = FixationData{:, 'Y'} * handles.scale;
            
        end
        
        if ismember('Xtf', FixationData.Properties.VariableNames)
            
            FixationData{:, 'Xtf'} = FixationData{:, 'Xtf'} * handles.scale;
            FixationData{:, 'Ytf'} = FixationData{:, 'Ytf'} * handles.scale;
            
        end
        
    end
    
    switch PresentationOption
        
        case 'Stimuli'
            
            axes(handles.axes_ImageShowOriginal);
            imshow(handles.CurrentImage);
            
            axes(handles.axes_ImageShowModified);
            imshow(handles.ModifiedImage);
            
            if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
                
                xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
                ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
                
            end
            
        case 'Fixations'
            
            axes(handles.axes_ImageShowOriginal)
            
            if any(FixationIndex)
                
                CurrentImage = repmat(handles.CurrentImage, [1, 1, 3]);
                B = imshow(CurrentImage);
                
                hold on
                
                plot(FixationData{FixationIndex, 'X'}, FixationData{FixationIndex, 'Y'}, '.b');
                
                hold off
                
            end
            
            axes(handles.axes_ImageShowModified);
            
            if any(FixationIndex)
                
                CurrentImage = repmat(handles.ModifiedImage, [1, 1, 3]);
                B = imshow(CurrentImage);
                
                xlim manual
                
                hold on
                
                plot(FixationData{FixationIndex, 'Xtf'}, FixationData{FixationIndex, 'Ytf'}, '.b');
                
                hold off
                
            end
            
            if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
                
                xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
                ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
                
            end
            
        case 'HeatMap'
            
            axes(handles.axes_ImageShowOriginal)
            
            if any(FixationIndex)
                
                [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex, FixationData, handles.CurrentImage, 'org', 1);
                
                CurrentImage = repmat(handles.CurrentImage, [1, 1, 3]);
                B = imshow(CurrentImage);
                
                xlim manual
                
                hold on
                
                X = imagesc(FixHM);
                colormap(handles.axes_ImageShowOriginal, 'jet');
                
                hold off
                
                %       set(B, 'AlphaData', .5);
                set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
                
                c = colorbar('Ticks', [0:max(FixHM(:))/4: max(FixHM(:))],...
                    'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                    'FontSize', 6);
                
                c.Label.String = 'Fixation duration (ms)';
                
                c.Label.FontSize = 8;
            end
            
            axes(handles.axes_ImageShowModified);
            
            if any(FixationIndex)
                
                
                CurrentImage = repmat(handles.ModifiedImage, [1, 1, 3]);
                B = imshow(CurrentImage);
                %       set(B, 'AlphaData', .5);
                
                [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex, FixationData, handles.ModifiedImage, 'tf', handles.BlurRatio);
                
                hold on
                
                X = imagesc(handles.axes_ImageShowModified, FixHM);
                colormap(handles.axes_ImageShowModified, 'jet');
                
                hold off
                
                set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
                
                c = colorbar('Ticks', [0:max(FixHM(:))/4: max(FixHM(:))],...
                    'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                    'FontSize', 6);
                
                c.Label.String = 'Fixation duration (ms)';
                
                c.Label.FontSize = 8;
                
            end
            
            if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
                
                xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
                ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
                
            end
            
        case 'HeatMap - All Stimuli'
            
            axes(handles.axes_ImageShowOriginal)
            
            if any(FixationIndex)
                
                [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex, FixationData, handles.fix, 'org', 1);
                
                CurrentImage = repmat(handles.CurrentImage, [1, 1, 3]);
                B = imshow(CurrentImage);
                
                hold on
                
                X = imagesc(FixHM);
                colormap(handles.axes_ImageShowOriginal, 'jet');
                
                hold off
                
                set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
                
                c = colorbar('Ticks',[0:max(FixHM(:))/4: max(FixHM(:))],...
                    'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                    'FontSize', 6);
                
                c.Label.String = 'Fixation duration (ms)';
                
                c.Label.FontSize = 8;
                
            end
            
            axes(handles.axes_ImageShowModified);
            
            if any(FixationIndex)
                
                CurrentImage = repmat(handles.ModifiedImage, [1, 1, 3]);
                B = imshow(CurrentImage);
                
                [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex,...
                    FixationData, handles.ModifiedImage, 'all', handles.BlurRatio);
                
                xlim manual
                
                hold on
                
                X = imagesc(handles.axes_ImageShowModified, FixHM);
                colormap(handles.axes_ImageShowModified, 'jet');
                
                hold off
                
                set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
                
                c = colorbar('Ticks', [0:max(FixHM(:))/4: max(FixHM(:))],...
                    'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                    'FontSize', 6);
                
                c.Label.String = 'Fixation duration (ms)';
                
                c.Label.FontSize = 8;
                
            end
            
            if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
                
                xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
                ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
                
            end
            
    end
    
    set(handles.Button_NewDraw, 'enable', 'on');
    
end

% Save the handles structure.
guidata(hObject,handles)

% --- Executes on button press in Button_ModifyReferenceImage.
function Button_ModifyReferenceImage_Callback(hObject, eventdata, handles)
% hObject  handle to Button_ModifyReferenceImage (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% read the current image from list
ImageName = handles.ImageName;

PlacedBefore = handles.AllLandmarks{ismember(handles.AllLandmarks(:, 1), ImageName), 3};

% whether this image has been marked before
if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

if ~PlacedBefore
    
    msgbox('Please place Landmarks for this image before using it as a reference image.');
    
else
    %% update the current reference image with the current one
    handles.fix = handles.BackgroundImages{ismember(handles.BackgroundImages(:, 1), ImageName), 2};
    handles.fixedAllLandmarks = handles.AllLandmarks{ismember(handles.AllLandmarks(:, 1), ImageName), 2};
    
    %% reset TFMatrix and newImage
    ImageName = handles.AllLandmarks(:,1);
    handles.TFMatrix = cell(numel(ImageName), size(handles.Tris, 1), 3); % three dimentions: 1, image name; 2, tranangle points; and 3, TFmatrix
    
    for i = 1: numel(ImageName)
        
        handles.TFMatrix(i, :, 1) = ImageName(i);
        
    end
    
    TFMatrix = handles.TFMatrix;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/TFMatrix'), 'TFMatrix');
    
    %% newImages
    handles.newImages = handles.BackgroundImages;
    
    newImages = handles.newImages;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/newImages.mat'), 'newImages');
        
    %% reset Landmark status
    handles.AllLandmarks(1:end, 4) = {false}; % transformed or not
    
    AllLandmarks = handles.AllLandmarks;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks');
    
    set(handles.Table_Stimuli, 'Data', AllLandmarks(:, [1 3 4]));
    
    %% save the Landmarks to hard drive
    fixedAllLandmarks = handles.fixedAllLandmarks;
    
    handles.fixedFaceLocation = handles.fixedAllLandmarks(end -3 : end, :);
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/fixedLandmarks-new.mat'), 'fixedAllLandmarks');
    
    imwrite(handles.fix, strcat('Eye Tracking Projects/', handles.CurrentProject, '/Template-new.png'))
    
    set(handles.Button_Transform, 'enable', 'on');
    set(handles.Button_NewDraw, 'enable', 'on');
    
    msgbox('The template image has been changed, please perform the Transformation one more time.');
    
    set(handles.Button_ResetReference, 'enable', 'on')
    set(handles.Button_ModifyReferenceImage, 'enable', 'off')
    
    
end

% AOI delete
if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'file')
    
    msgbox('Existing AOIs are removed.');
    
    delete(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'))
    
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in Button_Transform.
function Button_Transform_Callback(hObject, eventdata, handles)
% hObject  handle to Button_Transform (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

if any([handles.AllLandmarks{:, 3}])
    
    %%
    set(handles.Button_NewDraw, 'enable', 'off');
    set(handles.Button_ResetReference, 'enable', 'off');
    set(handles.Button_Transform, 'enable', 'off');
    set(handles.Button_FixationDataProcessing, 'enable', 'off');
    set(handles.Button_ExportiMap, 'enable', 'off');
    set(handles.Button_ModifyReferenceImage, 'enable', 'off');
    set(handles.Button_AOI, 'enable', 'off');
    set(handles.Button_Reset, 'enable', 'off');
    
    set(handles.Table_Stimuli, 'enable', 'off');
    set(handles.Table_Fixation, 'enable', 'off');
    %%
    
    % load the reference image
    fix = handles.fix;
    fixedAllLandmarks = handles.fixedAllLandmarks;
    
    fixedAllLandmarks = fixedAllLandmarks(handles.LMSelected, :);
    
    newImages = handles.newImages;
    
    Width = size(fix, 2);
    Height = size(fix, 1);
    
    Tris = handles.Tris;
    
    TFMatrix = handles.TFMatrix;
    ImageList = handles.AllLandmarks(:, 1);
    
    steps = size(handles.AllLandmarks(cell2mat(handles.AllLandmarks(:, 3)) == true, 1), 1);
    step = 0;
    
    h = waitbar(step/steps, {'Transformation is running.'; 'Please wait....'});
    
    for i = 1:size(ImageList, 1)
        
        ImageName = ImageList(i);
        
        if handles.AllLandmarks{i, 3} && ~handles.AllLandmarks{i, 4}
            %% Generate transformation matrix for the current face
            AllLandmarksC = handles.AllLandmarks{i, 2};
            
            TFMatrixC = TFMatrix(i, :, :);
            
            AllLandmarksC = AllLandmarksC(handles.LMSelected, :);
            
            %% examine whether any landmark is out side the image
            FrameC = handles.BackgroundImages{ismember(handles.BackgroundImages(:, 1), ImageName), 3};
            
            IndexRight = AllLandmarksC(:, 1) >= max(FrameC(:, 1));
            if any(IndexRight)
                
                AllLandmarksC(IndexRight, 1) = max(FrameC(:, 1)) - 1;
                
            end
            
            IndexBottom = AllLandmarksC(:, 2) >= max(FrameC(:, 2));
            if any(IndexBottom)
                
                AllLandmarksC(IndexBottom, 2) = max(FrameC(:, 2)) - 1;
                
            end
            
            IndexLeft = AllLandmarksC(:, 1) <= min(FrameC(:, 1));
            if any(IndexLeft)
                
                AllLandmarksC(IndexLeft, 1) = min(FrameC(:, 1)) + 1;
                
            end
            
            IndexTop = AllLandmarksC(:, 2) <= min(FrameC(:, 2));
            if any(IndexTop)
                
                AllLandmarksC(IndexTop, 2) = min(FrameC(:, 2)) + 1;
                
            end
            
            %%
            AllLandmarksCT = [AllLandmarksC; FrameC]; % add points for four corners
            fixedAllLandmarksT = [fixedAllLandmarks; [1 1; Width 1; 1 Height; Width Height]]; % add corners points
            
            TFMatrixC = CreateTFMatrices(AllLandmarksCT, fixedAllLandmarksT, Tris, TFMatrixC);
            
            handles.TFMatrix(ismember(handles.TFMatrix(:, 1), ImageName), :, :) = TFMatrixC;
            
            TFMatrix = handles.TFMatrix;
            
            %% Create modified image
            % Read images
            moving = handles.BackgroundImages{i, 2};
            
            newImage = CreateNewImage(moving, fix, AllLandmarksCT, Tris, TFMatrixC);
            
            % in the future, one might consider add a if else based on whether draw
            % fixations
            
            %       % update the modified image
            %       if strcmp(ImageName, handles.ImageName)
            %
            %         axes(handles.axes_ImageShowModified);
            %         imshow(newImage);
            %
            %         if handles.AllLandmarks{i, 3}
            %
            %           xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
            %           ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
            %
            %         end
            %
            %       end
            
            handles.newImages(i, 2) = {newImage};
            
            newImages = handles.newImages;
            
            handles.AllLandmarks{i, 4} = true;
            
            step = step + 1;
            waitbar(step / steps, h)
            %uistack(h, 'top')
            
        end
        
    end
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/TFMatrix.mat'), 'TFMatrix');
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/newImages'), 'newImages');
    
    AllLandmarks = handles.AllLandmarks;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks');
    
    close(h)
    
    % show it in the table
    set(handles.Table_Stimuli, 'Data', handles.AllLandmarks(:, [1 3 4]));
    
    msgbox('The transformation is done!')
    
    %set(handles.Button_ShowFolder, 'enable', 'on');
    set(handles.Button_ModifyReferenceImage, 'enable', 'on');
    
    set(handles.Button_NewDraw, 'enable', 'on');
    set(handles.Button_FixationDataProcessing, 'enable', 'on');
    
    %%
    
    set(handles.Button_ResetReference, 'enable', 'on');
    set(handles.Button_Transform, 'enable', 'on');
    
    set(handles.Button_ExportiMap, 'enable', 'off');
    set(handles.Button_AOI, 'enable', 'on');
    set(handles.Button_Reset, 'enable', 'off');
    
    set(handles.Table_Stimuli, 'enable', 'on');
    set(handles.Table_Fixation, 'enable', 'on');
    
else
    
    msgbox('Please place Landmarks before transforming images.')
    
end
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in Radio_ShowAllFixations.
function Radio_ShowAllFixations_Callback(hObject, eventdata, handles)
% hObject  handle to Radio_ShowAllFixations (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

RadioState = get(hObject,'Value');
FixationData = handles.FixationData;

switch RadioState
    
    case 0
        
        BackgroundImages = handles.BackgroundImages;
        newImages = handles.newImages;
        
        handles.CurrentImage = BackgroundImages{ismember(BackgroundImages(:,1), handles.ImageName), 2};
        handles.ModifiedImage = newImages{ismember(newImages(:, 1), handles.ImageName), 2};
        
        set(handles.text2, 'String', 'Transformed Image');
        
        axes(handles.axes_ImageShowOriginal);
        hold on;
        
        if any(ismember(FixationData{:, 'Stimuli'}, handles.ImageName))
            
            plot(FixationData{ismember(FixationData{:, 'Stimuli'}, handles.ImageName), 'X'}, FixationData{ismember(FixationData{:, 'Stimuli'}, handles.ImageName), 'Y'}, '.b');
            
        end
        hold off;
        
        axes(handles.axes_ImageShowModified);
        hold on;
        
        if any(ismember(FixationData{:, 'Stimuli'}, handles.ImageName))
            
            plot(FixationData{ismember(FixationData{:, 'Stimuli'}, handles.ImageName), 'Xtf'}, FixationData{ismember(FixationData{:, 'Stimuli'}, handles.ImageName), 'Ytf'}, '.b');
            
        end
        hold off;
        
    case 1
        
        set(handles.text2, 'String', 'All transformed fixations');
        
        axes(handles.axes_ImageShowModified);
        
        imshow(handles.fix);
        hold on; plot(FixationData{:, 'Xtf'}, FixationData{:, 'Ytf'}, '.b'); hold off
        
end

% Hint: get(hObject,'Value') returns toggle state of Radio_ShowAllFixations


% --- Executes on button press in Button_NewDraw.
function Button_NewDraw_Callback(hObject, eventdata, handles)
% hObject  handle to Button_NewDraw (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

set(handles.MainGUI, 'Visible', 'off');

[AllLandmarks, Tris, LMSelected, TFMatrix] = DrawLMs(handles);

set(handles.MainGUI, 'Visible', 'on');

BackgroundImages = handles.BackgroundImages;

% define the face area
for i = 1:numel(AllLandmarks(:, 1))
    
    if AllLandmarks{i, 3}
        
        minX = min(AllLandmarks{i, 2}(:, 1));
        minY = min(AllLandmarks{i, 2}(:, 2));
        maxX = max(AllLandmarks{i, 2}(:, 1));
        maxY = max(AllLandmarks{i, 2}(:, 2));
        
        if round(minX) - 10 < 1
            
            minX = 1;
            
        else
            
            minX = round(minX) - 10;
            
        end
        
        if round(minY) - 10 < 1
            
            minY = 1;
            
        else
            
            minY = round(minY) - 10;
            
        end
        
        if round(maxX) + 10 > size(BackgroundImages{i, 2}, 2)
            
            maxX = size(BackgroundImages{i, 2}, 2);
            
        else
            
            maxX = round(maxX) + 10;
            
        end
        
        if round(maxY) + 10 > size(BackgroundImages{i, 2}, 1)
            
            maxY = size(BackgroundImages{i, 2}, 1);
            
        else
            
            maxY = round(maxY) + 10;
            
        end
        
        BackgroundImages{i, 3} = [minX minY; maxX minY; minX maxY; maxX maxY];
        
    end
    
end

handles.AllLandmarks = AllLandmarks;
handles.BackgroundImages = BackgroundImages;
handles.Tris = Tris;
handles.LMSelected = LMSelected;
handles.TFMatrix = TFMatrix;

set(handles.Table_Stimuli, 'Data', AllLandmarks(:, [1 3 4]));

%%
set(handles.Button_Transform, 'enable', 'on');

guidata(hObject, handles);


% --- Executes on button press in Button_AOI.
function Button_AOI_Callback(hObject, eventdata, handles)
% hObject  handle to Button_AOI (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

%% load the AOI parameters
if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'file') == 2
    
    load(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'))
    
    if size(AOI, 1) > 0
        
        choice = questdlg('You already have created AOIs, do you want to make further AOI changes?', ...
            '', ...
            'Yes', 'No', 'No');
        
        % Handle response
        switch choice
            
            case 'Yes'
                
                set(handles.MainGUI, 'Visible', 'off');
                
                [AOI, AOIEllipse, AOIRect, AOIPoly] = DrawAOI(handles);
                
                set(handles.MainGUI, 'Visible', 'on');
                
            case 'No'
                
        end
        
    else
        
        set(handles.MainGUI, 'Visible', 'off');

        [AOI, AOIEllipse, AOIRect, AOIPoly] = DrawAOI(handles);
        
        set(handles.MainGUI, 'Visible', 'on');
        
    end
    
else
    
    set(handles.MainGUI, 'Visible', 'off');

    [AOI, AOIEllipse, AOIRect, AOIPoly] = DrawAOI(handles);
    
    set(handles.MainGUI, 'Visible', 'on');
    
end

%% Define fixation accroding to AOIsimellipse(gca, mouth);
if isfield(handles, 'FixationData')

    if all(ismember({'Xtf', 'Ytf'}, handles.FixationData.Properties.VariableNames))
        
        FixationData = handles.FixationData;
        
%         if ismember('X', FixationData.Properties.VariableNames)
%             
%             FixationData{:, 'X'} = FixationData{:, 'X'} * handles.scale;
%             FixationData{:, 'Y'} = FixationData{:, 'Y'} * handles.scale;
%             
%         end
%         
%         if ismember('Xtf', FixationData.Properties.VariableNames)
%             
%             FixationData{:, 'Xtf'} = FixationData{:, 'Xtf'} * handles.scale;
%             FixationData{:, 'Ytf'} = FixationData{:, 'Ytf'} * handles.scale;
%             
%         end
        
        % Ellipse AOIs
        for i = 1: size(AOIEllipse, 1)
            
            if numel(strfind(AOIEllipse{i, 2}, ' ')) > 0
                
                AOIEllipse{i, 2} = strrep(AOIEllipse{i, 2}, ' ', '_');
                
            end
            
            FixationData{:, AOIEllipse{i, 2}} = EllipseAOI(AOIEllipse{i, 1}, FixationData{:, 'Xtf'}, FixationData{:, 'Ytf'});
            
        end
        
        % Rectangle AOIs
        for i = 1: size(AOIRect, 1)
            
            if numel(strfind(AOIRect{i, 2}, ' ')) > 0
                
                AOIRect{i, 2} = strrep(AOIRect{i, 2}, ' ', '_');
                
            end
            
            FixationData{:, AOIRect{i, 2}} = RectAOI(AOIRect{i, 1}, FixationData{:, 'Xtf'}, FixationData{:, 'Ytf'});
            
        end
        
        % Polygon AOIs
        for i = 1: size(AOIPoly, 1)
            
            if numel(strfind(AOIPoly{i, 2}, ' ')) > 0
                
                AOIPoly{i, 2} = strrep(AOIPoly{i, 2}, ' ', '_');
                
            end
            
            FixationData{:, AOIPoly{i, 2}} = inpolygon(FixationData{:, 'Xtf'}, FixationData{:, 'Ytf'}, AOIPoly{i, 1}(:, 1), AOIPoly{i, 1}(:, 2));
            
        end
        
        %% save data
        
        choice = questdlg({'AOIs have been labeled.';...
            'Do you want to export the transformed data?'}, ...
            '', ...
            'Yes', 'No', 'Yes');
        
        switch choice
            
            case 'Yes'
                
                [FileName, PathName] = uiputfile('FixationTFwithAOI.csv', 'Save Fixation File');
                
                if PathName ~= 0
                    
                    SaveCSV(strcat(PathName, FileName), FixationData);
                    
                end
        end
        
        msgbox('AOI analysis finished!')
        
    else
        
        msgbox({'AOIs are ready, but no transformed fixation data file has not been transformed yet!'; ...
            'Please do the fixation transform and run AOI analysis again.'})
        
    end
    
else
    msgbox({'AOIs are ready, but no transformed fixation data file has not been imported!'; ...
        'Please import the fixation data and perform transform first, then run AOI analysis again.'})
    
end


% --- Executes on button press in Button_Reset.
function Button_Reset_Callback(hObject, eventdata, handles)
% hObject  handle to Button_Reset (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

choice = questdlg('All the Landmark files will be reset to default', ...
    'Do you want to reset', ...
    'Yes', 'No', 'No');

switch choice
    
    case 'Yes'
        
        if ~(exist('Eye Tracking Projects/Previous files', 'dir') == 7)
            
            mkdir('Eye Tracking Projects/Previous files')
            
        end
        
        if exist('Eye Tracking Projects/Landmarks.mat', 'file') == 2
            
            movefile('Eye Tracking Projects/Landmarks.mat', 'Parameters/Previous files/Landmarks-previous.mat');
            
        end
        
        if exist('Eye Tracking Projects/BackgroundImages.mat', 'file') == 2
            
            movefile('Eye Tracking Projects/BackgroundImages.mat', 'Parameters/Previous files/BackgroundImages-previous.mat');
            
        end
        
        if exist('Eye Tracking Projects/newImages.mat', 'file') == 2
            
            movefile('Eye Tracking Projects/newImages.mat', 'Parameters/Previous files/newImages-previous.mat');
            
        end
        
        if exist('Eye Tracking Projects/TFMatrix.mat', 'file') == 2
            
            movefile('Eye Tracking Projects/TFMatrix.mat', 'Parameters/Previous files/TFMatrix-previous.mat');
            
        end
        
        if exist('Eye Tracking Projects/fixedLandmarks-new.mat', 'file') == 2
            
            delete('Eye Tracking Projects/fixedLandmarks-new.mat')
            
        end
        
        if exist('Eye Tracking Projects/Template-new.png', 'file') == 2
            
            delete('Eye Tracking Projects/Template-new.png')
            
        end
        
        GUI
        
    case 'No'
        
end


% --- Executes on button press in Button_ResetReference.
function Button_ResetReference_Callback(hObject, eventdata, handles)
% hObject  handle to Button_ResetReference (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

choice = questdlg('All the transformation and AOIs will be reset.', ...
    'Do you want to reset', ...
    'Yes', 'No', 'No');

switch choice
    
    case 'Yes'
        
        if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Template-new.png'), 'file') == 2
            
            delete(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Template-new.png'),...
                strcat('Eye Tracking Projects/', handles.CurrentProject, '/fixedLandmarks-new.mat'));
            
        end
        
        if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/newImages.mat'), 'file') == 2
            
            delete(strcat('Eye Tracking Projects/', handles.CurrentProject, '/newImages.mat'));
            
        end
        
        if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Previous files/newImages-previous.mat'), 'file')
            
            delete(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Previous files/newImages-previous.mat'))
            
        end
        
        if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/TFMatrix.mat'), 'file') == 2
            
            delete(strcat('Eye Tracking Projects/', handles.CurrentProject, '/TFMatrix.mat'));
            
        end
        
        if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Previous files/TFMatrix-previous.mat'), 'file')
            
            delete(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Previous files/TFMatrix-previous.mat'))
            
        end
        
        % AOI delete
        if exist(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'), 'file')
            
            delete(strcat('Eye Tracking Projects/', handles.CurrentProject, '/AOI.mat'))
            
        end
        
        %% reset fixed image and its Landmarks
        
        fix = imread(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Template.png'));
        load(strcat('Eye Tracking Projects/', handles.CurrentProject, '/fixedLandmarks.mat'));
        
        handles.fix = fix;
        handles.fixedAllLandmarks = fixedAllLandmarks;
        
        handles.fixedFaceLocation = handles.fixedAllLandmarks(end -3 : end, :);
        
        %% reset TFMatrix and newImage
        ImageName = handles.AllLandmarks(:,1);
        
        handles.TFMatrix = cell(numel(ImageName), size(handles.Tris, 1), 3); % three dimentions: 1, image name; 2, tranangle points; and 3, TFmatrix
        
        for i = 1: numel(ImageName)
            
            handles.TFMatrix(i, :, 1) = ImageName(i);
            
        end
        
        TFMatrix = handles.TFMatrix;
        
        save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/TFMatrix'), 'TFMatrix');
        
        %% newImages
        handles.newImages = handles.BackgroundImages;
        
        newImages = handles.newImages;
        
        save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/newImages.mat'), 'newImages');
                
        %% reset Landmark status
        handles.AllLandmarks(1:end, 4) = {false}; % transformed or not
        
        AllLandmarks = handles.AllLandmarks;
        
        save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/Landmarks.mat'), 'AllLandmarks');
        
        set(handles.Table_Stimuli, 'Data', AllLandmarks(:, [1 3 4]));
        
        set(handles.Button_ResetReference, 'enable', 'off')
        set(handles.Button_ModifyReferenceImage, 'enable', 'on')
        
        % reset the presented images
        set(handles.Button_AOI, 'enable', 'off');
        set(handles.PresentationOptions, 'enable', 'off');
        
        axes(handles.axes_ImageShowModified);
        imshow(handles.CurrentImage)

    case 'No'
        
end

guidata(hObject, handles)


% --------------------------------------------------------------------
function Import_Menu_Callback(hObject, eventdata, handles)
% hObject  handle to Import_Menu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Analyze_Menu_Callback(hObject, eventdata, handles)
% hObject  handle to Analyze_Menu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to Open_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% Save the handles structure.
guidata(hObject, handles)


% --------------------------------------------------------------------
function Landmarks_Menu_Callback(hObject, eventdata, handles)
% hObject  handle to Landmarks_Menu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function DrawLM_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to DrawLM_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

guidata(hObject, handles);

% --------------------------------------------------------------------
function ChangeRefFace_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to ChangeRefFace_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)



% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function Transform_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to Transform_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function ResetRefFace_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to ResetRefFace_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function AOIAnalysis_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to AOIAnalysis_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ScanPath_SubMenue_Callback(hObject, eventdata, handles)
% hObject  handle to ScanPath_SubMenue (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function iMap_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to iMap_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Save_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to Save_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Export_Menu_Callback(hObject, eventdata, handles)
% hObject  handle to Export_Menu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FixationExport_SubMenue_Callback(hObject, eventdata, handles)
% hObject  handle to FixationExport_SubMenue (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ImageExport_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to ImageExport_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function AOIExport_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to AOIExport_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Quit_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to Quit_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function ImportFixation_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to ImportFixation_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

if ismac
    
    cd(strrep(userpath, ':', ''))
    
elseif ispc
    
    cd(strrep(userpath, ';', ''))
    
end

% in the future release one might be able to choose .xls or .csv
% formates

[FixationFile, FixationPath] = uigetfile({'*.xlsx; *.xls; *.csv', 'Excel File (*.xlsx, .xls) or CSV file (*.csv)'}, 'Select the Fixation File');

if FixationFile ~= 0
    
    set(handles.Table_Stimuli, 'enable', 'off');
    set(handles.Table_Fixation, 'enable', 'off');
    
    set(handles.Button_NewDraw, 'enable', 'off');
    set(handles.Button_FixationDataProcessing, 'enable', 'off');
    set(handles.Button_ExportiMap, 'enable', 'off');
    
    set(handles.PresentationOptions, 'enable', 'off');
    
    FixationFile = strcat(FixationPath, '/', FixationFile);
    
    [pathstr, name, ext] = fileparts(FixationFile);
    
    if strcmp(ext, '.xlsx') | strcmp(ext, '.xls')
        
        [k1 k2 FixationData] = xlsread(FixationFile);
        
        Names = FixationData(1, :);
        
        for i = 1: size(Names, 2)
            
            Names{1, i} = strrep(Names{1, i}, ' ', '_');
            
        end
        
        FixationData(1, :) = [];
        
        FixationData = cell2table(FixationData, 'VariableNames', Names);
        
    elseif strcmp(ext, '.csv')
        
        FixationData = readtable(FixationFile);
        Names = FixationData.Properties.VariableNames;
        % FixationData = table2cell(FixationData);
        
    end
    
    FixationData = sortrows(FixationData, {'Stimuli' 'X' 'Y'},'ascend');
    handles.FixationData = FixationData;
    
    save(strcat('Eye Tracking Projects/', handles.CurrentProject, '/FixationData.mat'), 'FixationData')
    
    %% Update the Fixation variable list
    
    VarList = handles.FixationData.Properties.VariableNames;
    
    VarList = VarList(~ismember(VarList, ['ParticipantName']));
    VarList = VarList(~ismember(VarList, ['FixationIndex']));
    VarList = VarList(~ismember(VarList, ['Stimuli']));
    VarList = VarList(~ismember(VarList, ['X']));
    VarList = VarList(~ismember(VarList, ['Y']));
    VarList = VarList(~ismember(VarList, ['Duration']));
    VarList = VarList(~ismember(VarList, ['Xtf']));
    VarList = VarList(~ismember(VarList, ['Ytf']));
    
    VarList(2, :) = {false};
    
    set(handles.Table_Fixation, 'Data', VarList');
    
    msgbox('Fixation has been successfully imported!')
    
else
    
    warndlg('No Fixation data was imported.');
    
end

%%
set(handles.Table_Stimuli, 'enable', 'on');
set(handles.Table_Fixation, 'enable', 'on');

set(handles.Button_NewDraw, 'enable', 'on');
set(handles.Button_FixationDataProcessing, 'enable', 'on');
set(handles.Button_ExportiMap, 'enable', 'off');

set(handles.PresentationOptions, 'enable', 'off');

% Update handles structure
guidata(hObject, handles);



% --------------------------------------------------------------------
function ShowAllFixation_SubMenu_Callback(hObject, eventdata, handles)
% hObject  handle to ShowAllFixation_SubMenu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function AOI_Menu_Callback(hObject, eventdata, handles)
% hObject  handle to AOI_Menu (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close MainGUI.
function MainGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject  handle to MainGUI (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

rmpath(strcat('Eye Tracking Projects/', handles.CurrentProject))
uiresume(handles.MainGUI)

delete(hObject);


% --- Executes on selection change in PresentationOptions.
function PresentationOptions_Callback(hObject, eventdata, handles)
% hObject  handle to PresentationOptions (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PresentationOptions contents as cell array
%    contents{get(hObject,'Value')} returns selected item from PresentationOptions

contents = cellstr(get(hObject,'String'));

PresentationOption = contents{get(hObject, 'Value')};

BackgroundImages = handles.BackgroundImages;
newImages = handles.newImages;

ImageIndex = ismember(newImages(:, 1), handles.ImageName);

handles.CurrentImage = BackgroundImages{ImageIndex, 2};
handles.ModifiedImage = newImages{ImageIndex, 2};

handles.BlurRatio = size(handles.CurrentImage, 2) / size(handles.ModifiedImage, 2);

set(handles.text2, 'String', 'Transformed Image');

if isfield(handles, 'FixationData')
    
    FixationData = handles.FixationData;
    
    FixationIndex = ismember(FixationData{:, 'Stimuli'}, handles.ImageName);
    
    %% scale fixations
    
    if ismember('X', FixationData.Properties.VariableNames)
        
        FixationData{:, 'X'} = FixationData{:, 'X'} * handles.scale;
        FixationData{:, 'Y'} = FixationData{:, 'Y'} * handles.scale;
        
    end
    
    if ismember('Xtf', FixationData.Properties.VariableNames)
        
        FixationData{:, 'Xtf'} = FixationData{:, 'Xtf'} * handles.scale;
        FixationData{:, 'Ytf'} = FixationData{:, 'Ytf'} * handles.scale;
        
    end
    
end

switch PresentationOption
    
    case 'Stimuli'
        
        axes(handles.axes_ImageShowOriginal);
        imshow(handles.CurrentImage);
        
        axes(handles.axes_ImageShowModified);
        imshow(handles.ModifiedImage);
        
        if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
            
            xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
            ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
            
        end
        
    case 'Fixations'
        
        axes(handles.axes_ImageShowOriginal)
        
        if any(FixationIndex)
            
            CurrentImage = repmat(handles.CurrentImage, [1, 1, 3]);
            B = imshow(CurrentImage);
            
            hold on
            
            plot(FixationData{FixationIndex, 'X'}, FixationData{FixationIndex, 'Y'}, '.b');
            
            hold off
            
        end
        
        axes(handles.axes_ImageShowModified);
        
        if any(FixationIndex)
            
            CurrentImage = repmat(handles.ModifiedImage, [1, 1, 3]);
            B = imshow(CurrentImage);
            
            xlim manual
            
            hold on
            
            plot(FixationData{FixationIndex, 'Xtf'}, FixationData{FixationIndex, 'Ytf'}, '.b');
            
            hold off
            
        end
        
        if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
            
            xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
            ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
            
        end
        
    case 'HeatMap'
        
        axes(handles.axes_ImageShowOriginal)
        
        if any(FixationIndex)
            
            [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex, FixationData, handles.CurrentImage, 'org', 1);
            
            CurrentImage = repmat(handles.CurrentImage, [1, 1, 3]);
            B = imshow(CurrentImage);
            
            hold on
            
            X = imagesc(FixHM);
            colormap(handles.axes_ImageShowOriginal, 'jet');
            
            hold off
            
            %       set(B, 'AlphaData', .5);
            set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
            
            c = colorbar('Ticks',[0:max(FixHM(:))/4: max(FixHM(:))],...
                'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                'FontSize', 6);
            
            c.Label.String = 'Fixation duration (ms)';
            
            c.Label.FontSize = 8;
            
        end
        
        axes(handles.axes_ImageShowModified);
        
        if any(FixationIndex)
            
            CurrentImage = repmat(handles.ModifiedImage, [1, 1, 3]);
            B = imshow(CurrentImage);
            %       set(B, 'AlphaData', .5);
            
            [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex, FixationData, handles.ModifiedImage, 'tf', handles.BlurRatio);
            
            xlim manual
            
            hold on
            
            X = imagesc(handles.axes_ImageShowModified, FixHM);
            colormap(handles.axes_ImageShowModified, 'jet');
            
            hold off
            
            set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
            
            c = colorbar('Ticks', [0:max(FixHM(:))/4: max(FixHM(:))],...
                'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                'FontSize', 6);
            
            c.Label.String = 'Fixation duration (ms)';
            
            c.Label.FontSize = 8;
            
        end
        
        if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
            
            xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
            ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
            
        end
        
    case 'HeatMap - All Stimuli'
        
        axes(handles.axes_ImageShowOriginal)
        
        if any(FixationIndex)
            
            [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex, FixationData, handles.CurrentImage, 'org', 1);
            
            CurrentImage = repmat(handles.CurrentImage, [1, 1, 3]);
            B = imshow(CurrentImage);
            
            hold on
            
            X = imagesc(FixHM);
            colormap(handles.axes_ImageShowOriginal, 'jet');
            
            hold off
            
            set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
            
            c = colorbar('Ticks',[0:max(FixHM(:))/4: max(FixHM(:))],...
                'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                'FontSize', 6);
            
            c.Label.String = 'Fixation duration (ms)';
            
            c.Label.FontSize = 8;
            
        end
        
        axes(handles.axes_ImageShowModified);
        
        if any(FixationIndex)
            
            CurrentImage = repmat(handles.ModifiedImage, [1, 1, 3]);
            B = imshow(CurrentImage);
            
            [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex,...
                FixationData, handles.ModifiedImage, 'all', handles.BlurRatio);
            
            xlim manual
            
            hold on
            
            X = imagesc(handles.axes_ImageShowModified, FixHM);
            colormap(handles.axes_ImageShowModified, 'jet');
            
            hold off
            
            set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
            
            c = colorbar('Ticks', [0:max(FixHM(:))/4: max(FixHM(:))],...
                'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                'FontSize', 6);
            
            c.Label.String = 'Fixation duration (ms)';
            
            c.Label.FontSize = 8;
            
        end
        
        if handles.AllLandmarks{ImageIndex, 3} && handles.AllLandmarks{ImageIndex, 4}
            
            xlim([min(handles.fixedFaceLocation(:, 1)) - 30, max(handles.fixedFaceLocation(:, 1)) + 30])
            ylim([min(handles.fixedFaceLocation(:, 2)) - 30, max(handles.fixedFaceLocation(:, 2)) + 30])
            
        end
        
end

% Save the handles structure.
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function PresentationOptions_CreateFcn(hObject, eventdata, handles)
% hObject  handle to PresentationOptions (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles  empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%    See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Table_Fixation_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Table_Fixation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in Table_Fixation.
function Table_Fixation_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Table_Fixation (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
