%Pedestrian Detection Program
%
%This GUI is responsible for:
%   Loading pre-trained cnn model(imagenet-vgg-f.mat)
%   Loading a trained classifier(Lib-SVM)
%   Loading an image for processing
%   Detection of pedestrians in loaded image(using one of the fuctions:
%       quick function - faster but less accurate
%       accurate function - more accurate but slower
%   'Real Time' detection of pedestrians on the image from computers
%       inbuilt webcam(requires free matlab add-on for support of usb
%                       cameras)
%
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





function varargout = cv_project(varargin)
% CV_PROJECT MATLAB code for cv_project.fig
%      CV_PROJECT, by itself, creates a new CV_PROJECT or raises the existing
%      singleton*.
%
%      H = CV_PROJECT returns the handle to a new CV_PROJECT or the handle to
%      the existing singleton*.
%
%      CV_PROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CV_PROJECT.M with the given input arguments.
%
%      CV_PROJECT('Property','Value',...) creates a new CV_PROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cv_project_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cv_project_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cv_project

% Last Modified by GUIDE v2.5 31-May-2017 13:55:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cv_project_OpeningFcn, ...
                   'gui_OutputFcn',  @cv_project_OutputFcn, ...
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


% --- Executes just before cv_project is made visible.
function cv_project_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cv_project (see VARARGIN)

% Choose default command line output for cv_project
handles.output = hObject;

image = imread('Title.png');   %load title image on startup
imshow(image, 'Parent', handles.axes1);

handles.imageRGB = image;       %retain peppers image if required

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cv_project wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cv_project_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% % --- Executes on button press in pushbutton1.
% % Loads CNN model
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Load CNN Model

    [filename, pathname] = ...
        uigetfile({'*.mat';'*.*'},'Choose CNN model file');
    handles.text6.String = (filename);
    convnet2 = load(strcat(pathname,filename));
    
   %Reducing number of layers for faster processing 
    handles.convnet = {};
    numLayers = size(convnet2.layers);
    handles.convnet.layers ={};
    for i = 1:(numLayers(2)-3)
        handles.convnet.layers(1,i) = convnet2.layers(1,i);
        i = i+1;
    end
    handles.convnet.meta = convnet2.meta;
    
    
    guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Chooses SVM Classifier File

set(handles.pushbutton4,'Enable','on');

% initialise convnet matrices to ensure empty before processing
[filename, pathname] = uigetfile({'*.mat';'*.*'},'Choose SVM Classifier File');
handles.text8.String = (filename);  %displays classifer name

load(strcat(pathname,filename),'model');
handles.model = model;
guidata(hObject, handles);
    

% --- Executes on button press in pushbutton3.
%loads image for pedestrian detection
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Selects Image file for Detection

set(handles.pushbutton5,'Enable','on');

[filename,pathname] = uigetfile({'*.*','All Files';...
                          '*.*','All Files' },'mytitle',...
                          'C:\Work\setpos1.png');
image = imread(strcat(pathname,filename));

[height,width,~] = size(image);
if width > 1000
    resizeFactor = 1000/width;
    image = imresize(image, [resizeFactor*height resizeFactor*width]);
end
    
cla(handles.axes1);
handles.RGB = image;
imshow(image, 'Parent', handles.axes1);

%use guidata to retain variables for other functions
guidata(hObject, handles); 


% --- Executes on button press in pushbutton1.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.pushbutton5,'Enable','on');

%SMALLER GRID SEARCH FOR MULTIPLE DETECTION

imshow(handles.RGB, 'Parent', handles.axes1);
    
[height,width,layers] = size(handles.RGB)

tic

[height,width,layers] = size(handles.RGB)
cd ..;
cd libsvm-3.22;%Change the folder to call svm functions
cd matlab;

% Initialise variables for bounding box analysis

scale = 0.17;  % proportional width of bounding box to image width
scaleBox = 3;  % height of bounding box compared to width
bboxWidth = scale * width;  
bboxHeight = scaleBox * bboxWidth; %aspect ratio 3 to 1
numXSteps = 12;  % width of image is divided by step function to perform search
numYSteps = 8; % proportionate height of image step function
maxScore = 0.25; % detection has occured when score is below 0.25
% initialise matrix variables for detection score retention
M = [];   
j = 1;     
k = 1;

gridY = 2; %only search top few sections as bounding box depth covers majority of height

x = 5; % where x is the number of pixels beginning from the left of the image
       % begin search 5 pixels inside image so bounding box is not off the edge
       
% Commence loop to search through a grid pattern on the image:
% Several cropped sections will be checked in a column beginning from  
% the left side of the image. If a positive score is returned, the searching 
% box is expanded until the best score is found.  Then the search continues
% from left to right.

while (x < (width-bboxWidth))
    verticalCount = false; % flag returns true when pedestrian detected
    k = 1;
    for y = 0:gridY
        bboxWidth = scale*width;
        bboxHeight = scaleBox*bboxWidth;
        yVal = y*(height/numYSteps);
        if yVal <= 0
            yVal = 5;
        end
        if (yVal + bboxHeight) > (height-5)
             bboxHeight = (height-5-yVal);
        end
        % define search area within image
        rect = [x yVal bboxWidth bboxHeight];
        %CNN Score Detection
        imageCropped = imcrop(handles.RGB,rect);
        img_ = single(imageCropped) ; % note: 255 range
        img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
        img_ = img_ - handles.convnet.meta.normalization.averageImage ;
        res = vl_simplenn(handles.convnet, img_) ;
        resFeatureLayer = res(18).x;
        NewCA = resFeatureLayer(1:1:1, 1:1:4096);
        [~,~,score] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');
        % store scores with x,y coordinates 
        M(k,j,1) = [x]; 
        M(k,j,2) = [yVal];
        M(k,j,3) = [score(2)];
        k = k+1;
    end

    % find the best score for the column searched
    singleScore = maxScore;
    for c = 1:(gridY+1) 
        if M(c,j,3) < singleScore     
            singleScore = M(c,j,3);
            verticalCount = true;
            xVal = M(c,j,1);
            yVal = M(c,j,2);
        end 
    end
    
    % try to improve bounding box accuracy if a pedestrian is detected
    if verticalCount
        scoreTry = 0;
        while scoreTry < singleScore
            xTry = xVal; % retain x value so boxes don't overlap
            if xTry < 5
                xTry = 5;
            end
            yTry = yVal - 0.05*height; % proportionately expand y value
            if yTry < 5
                yTry = 5;
            end
            bbox = bboxWidth + 0.1*width; % attempt 10% increase in box size
            bboxHeightTry = bbox*scaleBox;
            if (yTry + bboxHeightTry) > (height-5) % keep box within height
                 bboxHeightTry = (height-5-yTry);
            end
            % new bounding box search dimensions
            rect = [xTry yTry bbox bboxHeightTry];
            %CNN Score Detection
            imageCropped = imcrop(handles.RGB,rect);
            img_ = single(imageCropped) ; % note: 255 range
            img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
            img_ = img_ - handles.convnet.meta.normalization.averageImage ;
            res = vl_simplenn(handles.convnet, img_) ;
            resFeatureLayer = res(18).x;
            NewCA = resFeatureLayer(1:1:1, 1:1:4096);
            [~,~,score] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');
            
            scoreTry = score(2);  %only increase box if detection score improves
            if scoreTry <= singleScore
                singleScore = scoreTry;
                xVal = xTry;
                yVal = yTry;
                bboxWidth = bbox;
                bboxHeight = bboxHeightTry;
            end
       end
       % draw final bounding box on the image
       axes(handles.axes1);
       rectangle('Position', [xVal yVal bboxWidth bboxHeight], ...
           'EdgeColor','g','LineWidth',2);
       txt = 'Score ';
       txt2 = num2str(1-singleScore);
       txt1 = strcat(txt1, txt2);
       text(xVal+5, yVal+10 ,txt1 ,'Color','green','FontSize',10);
    end
    j = j+1;
    % define x parameter for next column search
    if verticalCount
        x = xVal+bboxWidth+5;
        bboxWidth = scale*width;
    else 
        x = x + width/numXSteps;
    end
end

cd ..
cd ..
cd DetectionGUI;

% display time taken for pedestrian detection
handles.text10.String = toc;



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%QUICK DETECTION FUNCTION

    %Refreshing the image to make sure it does not have any bounding boxes
    imshow(handles.RGB, 'Parent', handles.axes1);
    axes(handles.axes1);
    
    [height,width,layers] = size(handles.RGB);
    %Cd into libsvm folder to use svm functions
    %This folder is to be in parent directory of DetectionGUI folder
    cd ..;
    cd libsvm-3.22;%Change the folder to call svm functions
    cd matlab;

    %Switches for pop up menus with settings
        val = get(handles.popupmenu3,'Value');
        switch val
        case 1
           splitWidth = 3;    
        case 2
           splitWidth = 4; 
        case 3
           splitWidth = 5;
        case 4
           splitWidth = 6;
        case 5
           splitWidth = 7;
        case 6
           splitWidth = 8;
        case 7
           splitWidth = 9;
        case 8
           splitWidth = 10;
        otherwise
                warning('Warning.');
        end
        widthOfSearchBox = uint16(width/splitWidth);

        val = get(handles.popupmenu2,'Value');
        switch val
        case 1
           horizontalSearchSteps = 5;    
        case 2
           horizontalSearchSteps = 10; 
        case 3
           horizontalSearchSteps = 15;
        case 4
           horizontalSearchSteps = 20;
        case 5
           horizontalSearchSteps = 25;
        case 6
           horizontalSearchSteps = 30;
        case 7
           horizontalSearchSteps = 35;
        case 8
           horizontalSearchSteps = 40;
        case 9
           horizontalSearchSteps = 45;
        case 10
           horizontalSearchSteps = 50;
        otherwise
                warning('Warning.');
        end

        stepsPerWidth = uint16(horizontalSearchSteps/splitWidth);
        halfSteps = uint16(stepsPerWidth/2);

        val = get(handles.popupmenu4,'Value');
        switch val
        case 1
           proportion = 2.5;    
        case 2
           proportion = 3.0; 
        case 3
           proportion = 3.5;
        case 4
           proportion = 4.0;
        otherwise
                warning('Warning.');
        end


        val = get(handles.popupmenu1,'Value');
        switch val
        case 1
           verticalSteps = 0;    
        case 2
           verticalSteps = 1; 
        case 3
           verticalSteps = 2;
        otherwise
                warning('Warning.');
        end

    if proportion*widthOfSearchBox > height
        widthOfSearchBox = height / proportion;
    end
    

    searched = zeros(1,horizontalSearchSteps);
    
    tic
    
    %For number of vertical searches
    for y = 0: +1: verticalSteps
        searchHeight = height - y/2*0.5*height;
        %Do number of horizontal search steps
        for x = 1: +halfSteps: horizontalSearchSteps-halfSteps
            %Checking if current x position has been already checked and
            %pedestrian has been found in this location
            if searched(1,x) == 0
                searchWidth = ((x-1)*width * (1/horizontalSearchSteps)) + 1;%X location, constant through the iteration
                yLocation = height-(int16((proportion*widthOfSearchBox)))-(height-searchHeight);
   
                %Initial rectangle
                rect = [searchWidth yLocation (int16(widthOfSearchBox)) searchHeight-(height-(int16((proportion*widthOfSearchBox))))];
                lastHeight = yLocation;
                lastSearchHeight = searchHeight-(height-(int16((proportion*widthOfSearchBox))));
                lastWidth = (int16(widthOfSearchBox));

                %CNN Score Detection
                imageCropped = imcrop(handles.RGB,rect);
                img_ = single(imageCropped);
                img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2));
                img_ = img_ - handles.convnet.meta.normalization.averageImage;
                res = vl_simplenn(handles.convnet, img_);
                resFeatureLayer = res(18).x;
                NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                [~,~,score] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');
                %We take 0.1(0 - 100% pedestrian) as a good indicator for a
                %pedestrian in the box
                if score(2) < 0.1%0.2
                    for i = 0: stepsPerWidth-1
                        searched(1,x+i) = 1;%Marking all x points along current search box as pedestrian found in it
                        i = i + 1;
                    end
                x2 = x+stepsPerWidth;
                rectOld = rect;
                scoreOld = score(1);
                score2(2) = score(2);

                
                    %Streching process
                    %Once the initial box has been classified as a
                    %pedestrian we start streching process
                    %This involves:
                    %   Diagonal streching to the top right corner
                    %   Vertical streching to the top
                    %   Horizontal streching to the right
                    % Streching continous till it improves the results

                    %Diagonal streching
                    while round(score2(2),6) <= round(score(2)+0.01,6) && yLocation >= 1%Starts from extending the box diagonally
                        %Resizing scale
                        resizing = double(x2+1-x)/double(stepsPerWidth);
                        yLocation = int16(height-(proportion*widthOfSearchBox*resizing)-(height-searchHeight));
                        if yLocation < 1
                            yLocation = 1;
                        end

                        currentWidth = widthOfSearchBox*resizing;
                        if x2 <= horizontalSearchSteps && yLocation >= 1 && (uint16(searchWidth)+uint16(currentWidth)) <= width && searched(1,x2) == 0

                            rect2 = [searchWidth yLocation currentWidth searchHeight-yLocation];
                            %CNN Score Detection
                            imageCropped2 = imcrop(handles.RGB,rect2);
                            img_ = single(imageCropped2);
                            img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
                            img_ = img_ - handles.convnet.meta.normalization.averageImage;
                            res = vl_simplenn(handles.convnet, img_);
                            resFeatureLayer = res(18).x;
                            NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                            score = score2;
                            [~,~,score2] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');

                            if round(score2(2),6) <= round(score(2)+0.01,6)
                                searched(1,x2) = 1;
                                searched(1,x2+1) = 1;
                                x2 = x2 + 2;
                                rectOld = rect2;
                                scoreOld = score2(1);
                                lastHeight = yLocation;
                                lastSearchHeight = searchHeight-yLocation;
                                lastWidth = currentWidth;
                            else
                                score2(2) = 3;
                            end
                        else
                            score2(2) = 3;
                        end
                    end

                    %Vertical streching
                    score2(2) = score(2);
                    if yLocation >=1
                        while round(score2(2),6) <= round(score(2),6) && lastHeight >= 10
                            newHeight = lastHeight*0.9;
                                rect2 = [searchWidth newHeight lastWidth searchHeight-newHeight];
                                %CNN Score Detection
                                imageCropped2 = imcrop(handles.RGB,rect2);
                                img_ = single(imageCropped2);
                                img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
                                img_ = img_ - handles.convnet.meta.normalization.averageImage ;
                                res = vl_simplenn(handles.convnet, img_);
                                resFeatureLayer = res(18).x;
                                NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                                score(2) = score2(2);
                                [~,~,score2] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');

                                if round(score2(2),6) <= round(score(2),6)  
                                    rectOld = rect2;
                                    scoreOld = score2(1);
                                    lastHeight = newHeight;
                                    lastSearchHeight = searchHeight-newHeight;
                                else
                                    score2(2) = 3;
                                end
                        end
                    end




                     score2 = score;
                     %Horizontal streching
                    while round(score2(2),6) <= round(score(2),6)
                        %If maximum height reached, extending the search box
                        %horizontally only
                       if x2 <= horizontalSearchSteps && (searchWidth + widthOfSearchBox*(double(x2+1-x)/double(stepsPerWidth))) <= width && searched(1,x2) == 0    
                            rect2 = [searchWidth lastHeight int16(widthOfSearchBox*(double(x2+1-x)/double(stepsPerWidth))) lastSearchHeight];
                            %CNN Score Detection
                            imageCropped2 = imcrop(handles.RGB,rect2);
                            img_ = single(imageCropped2);
                            img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
                            img_ = img_ - handles.convnet.meta.normalization.averageImage ;
                            res = vl_simplenn(handles.convnet, img_);
                            resFeatureLayer = res(18).x;
                            NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                            score = score2;
                            [~,~,score2] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');

                            if round(score2(2),6) <= round(score(2),6)
                                searched(1,x2) = 1;
                                searched(1,x2+1) = 1;
                                x2 = x2 + 2;
                                rectOld = rect2;
                                scoreOld = score2(1);
                            else

                                score2(2) = 2;
                            end
                        else

                            score2(2) = 2;
                        end
                    end
                    if rectOld(4) >= height
                        rectOld(4) = height - 1;
                    end
                    if rectOld(2) < 1
                        rectOld(2) = 1;
                    end
                    
                         rectangle('Position', rectOld, 'EdgeColor','g','LineWidth',2);
                         txt = 'Score:';
                         txt2 = num2str(scoreOld);%Putting in score of the nonpedestrian class because its (1-pedestrian score)
                         txt1 = strcat(txt,txt2);
                         text(double(rectOld(1)),double(rectOld(2)+6),txt1,'Color','green','FontSize',12);
                          x = x2;
                           end

                    end
                end

    end

    handles.text10.String = toc;

    cd ..;
    cd ..;
    cd DetectionGUI;


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.dm
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%REAL TIME VIEW FUNCTION
%THIS IS A VERSION OF QUICK DETECTION FUNCTION
%WHICH HAS REDUCED ACCURACY AND THEREFORE REDUCES SPEED OF AROUND 4 FPS
    axes(handles.axes1);
    handles.continue = 1;
    
    cam = webcam(1);
    image = snapshot(cam);
    
    handles.text10.String = 'REAL TIME';

    [height,width,layers] = size(image);
    %Cd into libsvm folder to use svm functions
    %This folder is to be in parent directory of DetectionGUI folder
    cd ..;
    cd libsvm-3.22;%Change the folder to call svm functions
    cd matlab;

    splitWidth = 5;%5
    widthOfSearchBox = uint16(width/splitWidth);
    horizontalSearchSteps = 10;
    stepsPerWidth = uint16(horizontalSearchSteps/splitWidth);
    halfSteps = uint16(stepsPerWidth/2);
    proportion = 3.5;%3.5

    if proportion*widthOfSearchBox > height
        widthOfSearchBox = height / proportion;
    end
    
    searched = zeros(1,horizontalSearchSteps);
    
    while (get(handles.popupmenu5,'Value')) == 1
    
        pause(0.1);
        searched = zeros(1,horizontalSearchSteps);

        image = snapshot(cam);
        imshow(image);
        %For number of vertical searches
        for y = 0: +1: 0
            searchHeight = height - y/2*0.5*height;
            %Do number of horizontal search steps
            for x = 1: +halfSteps: horizontalSearchSteps-halfSteps
                %Checking if current x position has been already checked and
                %pedestrian has been found in this location
                if searched(1,x) == 0
                    searchWidth = ((x-1)*width * (1/horizontalSearchSteps)) + 1;%X location, constant through the iteration
                    yLocation = height-(int16((proportion*widthOfSearchBox)))-(height-searchHeight);
                    %Initial rectangle
                    rect = [searchWidth yLocation (int16(widthOfSearchBox)) searchHeight-(height-(int16((proportion*widthOfSearchBox))))];
                    lastHeight = yLocation;
                    lastSearchHeight = searchHeight-(height-(int16((proportion*widthOfSearchBox))));
                    lastWidth = (int16(widthOfSearchBox));

                    %CNN Score Detection
                    imageCropped = imcrop(image,rect);
                    img_ = single(imageCropped);
                    img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2));
                    img_ = img_ - handles.convnet.meta.normalization.averageImage ;
                    res = vl_simplenn(handles.convnet, img_) ;
                    resFeatureLayer = res(18).x;
                    NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                    [~,~,score] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');
                    %We take 0.1(0 - 100% pedestrian) as a good indicator for a
                    %pedestrian in the box
                    if score(2) < 0.1%0.2
                        for i = 0: stepsPerWidth-1
                            searched(1,x+i) = 1;%Marking all x points along current search box as pedestrian found in it
                            i = i + 1;
                        end
                    x2 = x+stepsPerWidth;
                    rectOld = rect;
                    scoreOld = score(1);
                    score2(2) = score(2);


                        %Streching process
                        %Once the initial box has been classified as a
                        %pedestrian we start streching process
                        %This involves:
                        %   Diagonal streching to the top right corner
                        %   Vertical streching to the top
                        %   Horizontal streching to the right
                        % Streching continous till it improves the results

                        %Diagonal streching
                        while round(score2(2),6) <= round(score(2)+0.01,6) && yLocation >= 1%Starts from extending the box diagonally
                            %Resizing scale
                            resizing = double(x2+1-x)/double(stepsPerWidth);%TUTAJ 2
                            yLocation = int16(height-(proportion*widthOfSearchBox*resizing)-(height-searchHeight));
                            if yLocation < 1
                                yLocation = 1;
                            end

                            currentWidth = widthOfSearchBox*resizing;
                            if x2 <= horizontalSearchSteps && yLocation >= 1 && (uint16(searchWidth)+uint16(currentWidth)) <= width && searched(1,x2) == 0

                                rect2 = [searchWidth yLocation currentWidth searchHeight-yLocation];
                                %CNN Score Detection
                                imageCropped2 = imcrop(image,rect2);
                                img_ = single(imageCropped2);
                                img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
                                img_ = img_ - handles.convnet.meta.normalization.averageImage ;
                                res = vl_simplenn(handles.convnet, img_);
                                resFeatureLayer = res(18).x;
                                NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                                score = score2;
                                [~,~,score2] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');



                                if round(score2(2),6) <= round(score(2)+0.01,6)
                                    searched(1,x2) = 1;
                                    searched(1,x2+1) = 1;
                                    x2 = x2 + 2;
                                    rectOld = rect2;
                                    scoreOld = score2(1);
                                    lastHeight = yLocation;
                                    lastSearchHeight = searchHeight-yLocation;
                                    lastWidth = currentWidth;
                                else
                                    score2(2) = 3;
                                end
                            else
                                score2(2) = 3;
                            end
                        end

                        %Vertical streching
                        score2(2) = score(2);
                        if yLocation >=1
                            while round(score2(2),6) <= round(score(2),6) && lastHeight >= 10
                                newHeight = lastHeight*0.9;

                                    rect2 = [searchWidth newHeight lastWidth searchHeight-newHeight];
                                    %CNN Score Detection
                                    imageCropped2 = imcrop(image,rect2);
                                    img_ = single(imageCropped2) ; % note: 255 range
                                    img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
                                    img_ = img_ - handles.convnet.meta.normalization.averageImage ;
                                    res = vl_simplenn(handles.convnet, img_) ;
                                    resFeatureLayer = res(18).x;
                                    NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                                    score(2) = score2(2);
                                    [~,~,score2] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');

                                    if round(score2(2),6) <= round(score(2),6)  
                                        rectOld = rect2;
                                        scoreOld = score2(1);
                                        lastHeight = newHeight;
                                        lastSearchHeight = searchHeight-newHeight;
                                    else
                                        score2(2) = 3;
                                    end
                            end
                        end




                         score2 = score;
                         %Horizontal streching
                        while round(score2(2),6) <= round(score(2),6)
                            %If maximum height reached, extending the search box
                            %horizontally only
                           if x2 <= horizontalSearchSteps && (searchWidth + widthOfSearchBox*(double(x2+1-x)/double(stepsPerWidth))) <= width && searched(1,x2) == 0    
                                rect2 = [searchWidth lastHeight int16(widthOfSearchBox*(double(x2+1-x)/double(stepsPerWidth))) lastSearchHeight];
                                %CNN Score Detection
                                imageCropped2 = imcrop(image,rect2);
                                img_ = single(imageCropped2);
                                img_ = imresize(img_, handles.convnet.meta.normalization.imageSize(1:2)) ;
                                img_ = img_ - handles.convnet.meta.normalization.averageImage;
                                res = vl_simplenn(handles.convnet, img_);
                                resFeatureLayer = res(18).x;
                                NewCA = resFeatureLayer(1:1:1, 1:1:4096);
                                score = score2;
                                [~,~,score2] = svmpredict(double([2]),double(NewCA), handles.model, '-b 1 -q');

                                if round(score2(2),6) <= round(score(2),6)
                                    searched(1,x2) = 1;
                                    searched(1,x2+1) = 1;
                                    x2 = x2 + 2;
                                    rectOld = rect2;
                                    scoreOld = score2(1);
                                else

                                    score2(2) = 2;
                                end
                            else

                                score2(2) = 2;
                            end
                        end
                        if rectOld(4) >= height
                            rectOld(4) = height - 1;
                        end
                        if rectOld(2) < 1
                            rectOld(2) = 1;
                        end


                             rectangle('Position', rectOld, 'EdgeColor','g','LineWidth',2);
                             txt = 'Score:';
                             txt2 = num2str(scoreOld);%Putting in score of the nonpedestrian class because its (1-pedestrian score)
                             txt1 = strcat(txt,txt2);
                             text(double(rectOld(1)),double(rectOld(2)+6),txt1,'Color','green','FontSize',12);
                              x = x2;
                               end
                        end
            end
        end

    end

    clear cam;
    cd ..;
    cd ..;
    cd DetectionGUI;
    guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
