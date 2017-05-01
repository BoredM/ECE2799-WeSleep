function varargout = ece(varargin)
% ECE MATLAB code for ece.fig
%      ECE, by itself, creates a new ECE or raises the existing
%      singleton*.
%
%      H = ECE returns the handle to a new ECE or the handle to
%      the existing singleton*.
%
%      ECE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ECE.M with the given input arguments.
%
%      ECE('Property','Value',...) creates a new ECE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ece_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ece_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ece

% Last Modified by GUIDE v2.5 17-Apr-2017 02:52:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ece_OpeningFcn, ...
                   'gui_OutputFcn',  @ece_OutputFcn, ...
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
end


% --- Executes just before ece is made visible.
function ece_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ece (see VARARGIN)

% Choose default command line output for ece
handles.output = hObject;

s = serial('COM4','BaudRate', 9600);
fopen(s);
x = linspace(1,20,20);
y = zeros(1,20);
handles.cry = 0;
handles.hiTemp = 0;
handles.temp = 0;
handles.counter = 0;
handles.hPlot = plot(x,y,'-o');
ylabel('temperature(C)');
title('Temperature Reading');
axis([1 20 20 50])
grid on;
set(handles.text2, 'String', 'Normal');
set(handles.text3, 'String', 'Normal');
handles.s = s;
handles.timer = timer('Period',0.25,                  ... 
                     'StartDelay',1,                 ... 
                     'TasksToExecute',inf,           ... 
                     'ExecutionMode','fixedSpacing', ...
                     'TimerFcn',{@timerCallback,hObject});
start(handles.timer);

% Update handles structure
guidata(hObject,handles);
end
% UIWAIT makes ece wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ece_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in swing.
function swing_Callback(hObject, eventdata, handles)
% hObject    handle to swing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.s, '2');
end

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.s, '1');
handles.cry = 0;
handles.hiTemp = 0;
set(handles.text2, 'String', 'Normal');
set(handles.text3, 'String', 'Normal');
guidata(hObject,handles);
end

function timerCallback(~,~,hObject)
handles = guidata(hObject);
if isfield(handles,'s')
        n = handles.s.BytesAvailable;
            if n > 0
                  in = fscanf(handles.s);
                  z = str2double(in);
                  disp(z);
                  if((z < 5)&&(z > 3))
                      handles.cry = 1;
                  elseif((z < 3)&&(z > 0))
                      handles.hiTemp = 1;
                  else
                      handles.temp = z;
                  end
                  
                  if(handles.counter >= 60)
                      thingSpeakWrite(258992,[handles.temp,handles.hiTemp,handles.cry],'WriteKey','PRUDOBHWBPUIJTOR');
                      handles.counter = 0;
                  else
                      handles.counter = handles.counter + 1;
                  end
                  
                  ydata = get(handles.hPlot,'YData');
                  ydata = [ydata(2:20) handles.temp];
                  set(handles.hPlot,'YData',ydata);
                  if(handles.cry == 1)
                    set(handles.text2, 'String', 'Cry Alert!');
                  end
                  
                  if(handles.hiTemp == 1)
                    set(handles.text3, 'String', 'High Temperature Alert!');
                  end
            end

end
guidata(hObject,handles);
end
