%Project Training Application
%
%This GUI is responsible for downloading and installing MatConvNet as well
%as training Lib-SVM classifier using features extracted using
%imagenet-vgg-f.mat pretrained network
%
%Parts of the code for feature extraction come from MatConvNet tutorials:
%   http://www.vlfeat.org/matconvnet/quick/
%The Lib-SVM library comes from:
%   https://www.csie.ntu.edu.tw/~cjlin/libsvm/
%
%
%Authors:
%21285986 Wojciech Slabik
%19422753 Belinda Edmunds
%21301563 Jessica Jason


function varargout = projectTraining(varargin)
% PROJECTTRAINING MATLAB code for projectTraining.fig
%      PROJECTTRAINING, by itself, creates a new PROJECTTRAINING or raises the existing
%      singleton*.
%
%      H = PROJECTTRAINING returns the handle to a new PROJECTTRAINING or the handle to
%      the existing singleton*.
%
%      PROJECTTRAINING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTTRAINING.M with the given input arguments.
%
%      PROJECTTRAINING('Property','Value',...) creates a new PROJECTTRAINING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before projectTraining_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to projectTraining_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help projectTraining

% Last Modified by GUIDE v2.5 29-May-2017 00:20:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @projectTraining_OpeningFcn, ...
                   'gui_OutputFcn',  @projectTraining_OutputFcn, ...
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


% --- Executes just before projectTraining is made visible.
function projectTraining_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to projectTraining (see VARARGIN)

% Choose default command line output for projectTraining
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes projectTraining wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = projectTraining_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    
    tic;
    %Layer reduction
    %It removes last(unused) layers to improve training speed
    handles.convnet1 = {};

    numLayers = size(handles.convnet2.layers);
    handles.convnet1.layers ={};
    for i = 1:(numLayers(2)-3)
        handles.convnet1.layers(1,i) = handles.convnet2.layers(1,i);
        i = i+1;
    end
    numLayers = size(handles.convnet1.layers); 
    handles.convnet1.meta = handles.convnet2.meta;

    categories = {'Pedestrian', 'NonPedestrian'};
    imds = imageDatastore(fullfile(handles.training_data, categories), 'LabelSource', 'foldernames');
    tbl = countEachLabel(imds);
    
    %Taking minimum overlapping set
    minSetCount = min(tbl{:,2});
    imds = splitEachLabel(imds, minSetCount, 'randomize');
    countEachLabel(imds)

    %90% used for training, 10% used for testing
    [trainingSet, testSet] = splitEachLabel(imds, 0.9, 'randomize');
    
    %Training SVM Classifier for CNN Features
    trainingFeaturesCNN = zeros(4096,150);
    trainingSize = size(trainingSet.Files);
    
    %Feature extraction from pre-trained CNN
    for i = 1:trainingSize(1)
        im = imread(trainingSet.Files{i});
        im_ = single(im);
        im_ = imresize(im_, handles.convnet1.meta.normalization.imageSize(1:2)) ;
        im_ = im_ - handles.convnet1.meta.normalization.averageImage ;
        res = vl_simplenn(handles.convnet1, im_) ;
        resFeatureLayer = res(18).x;
        NewCA = resFeatureLayer(1:1:1, 1:1:4096);
        NewCA = NewCA';
        for j = 1:4096
            trainingFeaturesCNN(j,i) = NewCA(j);
            j = j+1;
        end
        i = i+1;
    end
    
    %This inverts the matrix into m-number of instances by n-number of features
    trainingFeaturesCNN = trainingFeaturesCNN';

    trainingLabels = trainingSet.Labels;
    cd ..
    cd libsvm-3.22;%Change the folder to call svm functions
    cd matlab;
    model = svmtrain(double(trainingLabels), trainingFeaturesCNN, '-s 0 -c 10 -t 1 -g 1 -r 1 -d 3 -b 1');%Parameters to be improved

    %Testing SVM
    testFeaturesCNN = zeros(150,4096);

    testingSize = size(testSet.Files);
    
    for i = 1:testingSize(1)
        im = imread(testSet.Files{i}) ;
        im_ = single(im) ;
        im_ = imresize(im_, handles.convnet1.meta.normalization.imageSize(1:2)) ;
        im_ = im_ - handles.convnet1.meta.normalization.averageImage ;
        res = vl_simplenn(handles.convnet1, im_) ;
        resFeatureLayer = res(18).x;
        NewCA = resFeatureLayer(1:1:1, 1:1:4096);
        for j = 1:4096
            testFeaturesCNN(i,j) = NewCA(1,j);
            j = j+1;
        end
        i = i+1;
    end
    testLabels = testSet.Labels;
    [predict_label, accuracy, dec_values] = svmpredict(double(testLabels), testFeaturesCNN, model);

    accuracy
    
%     cd handles.outputpath;
    file = fullfile(handles.outputpath,get(handles.edit1,'String'));
    save(file,'model');
    cd ..;
    cd ..;

    e = toc;
    handles.text6.String = strcat('Training time: ',num2str(e),' seconds');

    guidata(hObject, handles);

    

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     filename = uigetfile({'*.*','All Files';...
%                           '*.*','All Files' },'mytitle',...
%                           'C:\Work\setpos1.png');
    [filename, pathname] = ...
     uigetfile({'*.mat';'*.*'},'Choose CNN model file');
    handles.text2.String = (filename);
    set(handles.pushbutton2,'Enable','on');
    
%     handles.convnet2 = load('C:\Users\Wojtek\Desktop\Computer Vision\Project CNN Models\imagenet-vgg-f.mat');
    handles.convnet2 = load(strcat(pathname,filename));
    
    numLayers = size(handles.convnet2.layers);
    tableData = {};

    for i = 1:(numLayers(2))
        %convnet2.layers{end+1} = convnet1.layers(i);
        %handles.convnet1.layers(1,i) = handles.convnet2.layers(1,i);
         tableData{1,i} = handles.convnet2.layers{i}.name;
         if sum(strcmp(fieldnames(handles.convnet2.layers{i}), 'size')) == 1
             sizeString = '';
             length = size(handles.convnet2.layers{i}.size);
             length2 = length(2);
             for j = 1: length2
                 sizeString2 = strcat(sizeString,handles.convnet2.layers{i}.size(j));
                 sizeString = sizeString2;
%                 tableData{2,i} = {strjoin(string(handles.convnet2.layers{i}.size))};
             end
             tableData{2,i} = sizeString;
         else
             tableData{2,i} = 'no size';
         end
        i = i+1;
    end
    tableData = tableData';
%     set(handles.uitable2,Data,tableData);
tableData
handles.uitable2.Data = tableData;
    

    guidata(hObject, handles);




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.training_data = uigetdir;
    handles.text3.String = handles.training_data;
        set(handles.edit1,'Enable','on');
    guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.pushbutton4,'Enable','on');

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.outputpath = uigetdir;
    handles.text5.String = handles.outputpath;
    set(handles.pushbutton3,'Enable','on');
    guidata(hObject, handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in uitable2.
function uitable2_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd ..
cd matconvnet-1.0-beta24
mex -setup
run matlab/vl_compilenn ;
run matlab/vl_setupnn ;
cd ..;
cd TrainingGUI;


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd ..;
untar('http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta24.tar.gz') ;
cd TrainingGUI;