%clear all;
SITE = 'N';     % N for netstation (EGI)

port=0;
par.runID= subj_ID{1,1};
par.ExaminationDate = subj_ID{2,1};

par.recordEEG = 0; 

if subj_ID{4,1} == 'y'
par.useEL = 1;  % use the eye tracker?
else par.useEL = 0; end;
% cd C:\PsychToolbox_Experiments\Simon

if subj_ID{5,1} == 'y'
par.useEL_Calib = 1;  % use the eye tracker?
else par.useEL_Calib = 0; end;

whichScreen = 1;
whichScreen_eye = 0;

% 
% % serial port:
% if par.recordEEG
%     if SITE=='C'
%         [port, errmsg] = IOPort('OpenSerialPort','COM1','BaudRate=115200'); % This is necessary for the Cedrus StimTracker box we use in CCNY
%         IOPort('Write',port,uint8([1 1 1 1 1 1 1 1]))
%     end
% end

TGonT=[];
ITIstartT=[];


% commandwindow;  % puts focus on command window, so if any keyboard buttons are pressed, they'll come up in the comand window rather than in your program!

% 
% %%%%%%%%% IMPORTANT SETTINGS
par.videoFrate = 100;   % Monitor refresh rate
 
duration = 0.5;   % in sec
fading = 0.1; % in sec
ITI = 1.3;   % in sec

par.numtargets = 8 % change if you want to have less STIMULI
par.sequence = [1 6 8 5 2]; %8
%par.sequence = [1 6 5 3]; %6
radius = 20;
radius_in = 16;
color_dot = [0 0 0];
color_fix = [255 255 0];
%color = [0 0 0] % black
color = [255 255 255]; %white
%color_gray = [220 220 220]
color_gray = [131 131 131];
BGcolor = color_gray ;
hz = 100;
%r = 100 % distance from center
%radian = 0.785398163 % 45 grad

% 
% commandwindow;  % puts focus on command window, so if any keyboard buttons are pressed, they'll come up in the comand window rather than in your program!
% %port = 888; lptwrite(port,0);
% 
% 
monitorwidth_cm = 40;   % monitor width in cm
dist_cm = 68;  % viewing distance in cm


% 
[scresw, scresh]=Screen('WindowSize',whichScreen);  % Get screen resolution
center = [scresw scresh]/2;     % useful to have the pixel coordinates of the very center of the screen (usually where you have someone fixate)
fixRect = [center-2 center+2];  % fixation dot
%hz=Screen('FrameRate', whichScreen,1);
%hz = 60;
%if par.useEL, cross = [400,300];f = figure;h1 = plot(cross(1), cross(2),'+');xlim([0 800]);ylim([0 600]);hold ;end


par.eyeFBK = 0; %sound feedback, use only for trial block

% if par.useEL  Eyetracker_connection_example, end

%%
Screen('Preference','SkipSyncTests',1)

Screen('Preference', 'VisualDebugLevel', 0);
window = Screen('OpenWindow', whichScreen, BGcolor);
%if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = Smp.leftEye.gazeX; y0 = Smp.leftEye.gazeY;	
 %            shg; 	h2 = plot(x0,y0,'or'); end; end;
% 


%%NEW
r = 100; % distance from center

radian = (360/par.numtargets)*pi/180; % degree to radian: degree*pi/180

clear pos

for p = 1:par.numtargets
    
    pos(p,:) = [(0 + r * cos((p-1)*radian)) (0 + (r * sin((p-1)*radian)))];
    
end
% 
% % 
% % 
% % %double x = x0 + r * Math.Cos(theta * Math.PI / 180);
% % %double y = y0 + r * Math.Sin(theta * Math.PI / 180);
% pos(1,:) = [(0 + r * cos(0)) (0 + (r * sin(0)))];
% pos(2,:) = [(0 + r * cos(1*radian)) (0 + (r * sin(1*radian)))];
% pos(3,:) = [(0 + r * cos(2*radian)) (0 + (r * sin(2*radian)))];
% pos(4,:) = [(0 + r * cos(3*radian)) (0 + (r * sin(3*radian)))];
% pos(5,:) = [(0 + r * cos(4*radian)) (0 + (r * sin(4*radian)))];
% pos(6,:) = [(0 + r * cos(5*radian)) (0 + (r * sin(5*radian)))];
% pos(7,:) = [(0 + r * cos(6*radian)) (0 + (r * sin(6*radian)))];
% pos(8,:) = [(0 + r * cos(7*radian)) (0 + (r * sin(7*radian)))];
% 



%resp_field(1,:) = [(0 + r_resp * cos(0)) (0 + (r_resp * sin(0)))];
%resp_field(2,:) = [(0 + r_resp * cos(1*radian)) (0 + (r_resp * sin(1*radian)))];
%resp_field(3,:) = [(0 + r_resp * cos(2*radian)) (0 + (r_resp * sin(2*radian)))];
%resp_field(4,:) = [(0 + r_resp * cos(3*radian)) (0 + (r_resp * sin(3*radian)))];
%resp_field(5,:) = [(0 + r_resp * cos(4*radian)) (0 + (r_resp * sin(4*radian)))];
%resp_field(6,:) = [(0 + r_resp * cos(5*radian)) (0 + (r_resp * sin(5*radian)))];
%resp_field(7,:) = [(0 + r_resp * cos(6*radian)) (0 + (r_resp * sin(6*radian)))];
%resp_field(8,:) = [(0 + r_resp * cos(7*radian)) (0 + (r_resp * sin(7*radian)))];

%Initiate NetStation Connection, Synchronization, and Recording
if par.recordEEG
  %  NetStation('Connect','10.0.0.42')
    NetStation('Synchronize')
    NetStation('StartRecording')
end


%  ************************************************* CODES AND TRIAL SEQUENCE
par.CD_START  = 1;
%par.CD_RESP  = 30;
par.CD_Dot_ON = 10+[1:8];
par.CD_Dot_OFF = 20+[1:8];
par.CD_TRIAL  = [31 32 33];
par.CD_END  = 50;

% *********************************************************************************** START TASK
% Instructions:
Screen('TextSize', window, 16);
Screen('DrawText', window, 'Fixate on the central yellow dot.', 0.05*scresw, 0.25*scresh, 255);
Screen('DrawText', window, 'Try to remember the sequence of the flashing dots.', 0.05*scresw, 0.35*scresh, 255);
Screen('DrawText', window, 'Press the mouse button to begin the EXAMPLE', 0.05*scresw, 0.45*scresh, 255);
Screen('Flip', window, [],[],1); 
fprintf('THE SUBJECT IS READING THE INSTRUCTIONS...');
% Things that we'll save on a trial by trial basis
clear ITIstartT TargOnT RespLR RespT
numResp=1;

% Waits for the user to press a button before starting
[clicks,x,y,whichButton] = GetClicks(whichScreen,0);
%if par.recordEEG, sendtrigger(par.CD_START,port,SITE,0), end
%if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_START))])));end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%par.sequence = [1 6 8 5 2 4 7 3 5 1 4 2 6 8 3 7];
%par.sequence = [1 6 4 2 7 3 8 5 3 5 2 4 7 1 6 8];
%par.sequence = [1 6 8 5 2 4];
%par.sequence = [1 6 8];
par.numrepet = 1;
r_resp = 35;
right_text_shift = 20;
left_text_shift = 30;
par.resp_click = zeros(par.numrepet,length(par.sequence),1);
correction = zeros(par.numrepet,length(par.sequence),1);
fprintf('THE SUBJECT IS PERFORMING THE EXAMPLE TASK...');
for r = 1:par.numrepet
    
    Screen('TextSize', window, 21);
Screen('DrawText', window, ['START EXAMPLE'], 0.38*scresw, 0.25*scresh, 255);
Screen('Flip', window); WaitSecs(2)
    
iti 
background

  %  if par.recordEEG, sendtrigger(par.CD_TRIAL(r),port,SITE,0), end
%if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_TRIAL(r)))])));end;
    for n=1:length(par.sequence)
      pos_num = par.sequence(n);
      Target_eye_example;
    end
    WaitSecs(1);
    
    Screen('TextSize', window, 21);
Screen('DrawText', window, 'END of EXAMPLE', 0.38*scresw, 0.05*scresh, 255);
Screen('DrawText', window, 'Repeat the sequence with the mouse', 0.15*scresw, 0.15*scresh, 255);
Screen('Flip', window,[],1); 

%% get response

HideCursor
%mp =get(0,'MonitorPosition')
SetMouse(400,300,1) %SetMouse(1680,300,1)
ShowCursor(0,whichScreen)

c =0;
while c <  length(par.sequence)
%for c = 1:length(par.sequence)
    c = c+1;
    if c>1 &&  correction(r,c-1,1) == 1 ;
        c = c-1;
        
    end
         
        [clicks,x(c),y(c),whichButton] = GetClicks(whichScreen,0);
    disp('Button Press');
      if whichButton == 1
    check_response_learning_paradigm
    
    %if c>1 && correction(r,c,1) == 1;
    %  c = c-1;
    %end
   elseif c == 1 && whichButton == 3  && correction(r,c,1) == 0 ;
    Screen('TextSize', window, 21);
Screen('DrawText', window, 'YOU ARE PRESSING THE WRONG BUTTON', 0.05*scresw, 0.2*scresh, 255);
Screen('Flip', window); 

     
      elseif whichButton == 3  && correction(r,c,1) == 0 ;
     correction(r,c-1,1) = 1;
    
    if c<9  
    Screen('FillRect',window, color_gray, [0.25*scresw 0.8*scresh 0.25*scresw+400 0.8*scresh+20]);
     Screen('FillRect',window, color_gray, [[center(1,1)+pos(par.resp_click(r,c-1,1),1)+right_text_shift] [center(1,2)+pos(par.resp_click(r,c-1,1),2)-5] [center(1,1)+pos(par.resp_click(r,c-1,1),1)+right_text_shift+20] [center(1,2)+pos(par.resp_click(r,c-1,1),2)+20]]);  
    Screen(window, 'Flip',[],1);
     par.resp_click(r,c-1,1) = 0;
    %Screen('DrawText', window, [num2str(c-1)], center(1,1)+pos(j,1)+right_text_shift,center(1,2)+pos(j,2)-5,[0 0 0]); Screen(window, 'Flip',[],1);
    elseif c>8
    Screen('FillRect',window, color_gray, [0.25*scresw 0.8*scresh 0.25*scresw+400 0.8*scresh+20]);  
        Screen('FillRect',window, color_gray, [[center(1,1)+pos(par.resp_click(r,c-1,1),1)-left_text_shift] [center(1,2)+pos(par.resp_click(r,c-1,1),2)-5] [center(1,1)+pos(par.resp_click(r,c-1,1),1)-left_text_shift+20] [center(1,2)+pos(par.resp_click(r,c-1,1),2)+20]]);  
    Screen(window, 'Flip',[],1);
    par.resp_click(r,c-1,1) = 0;
    %Screen('DrawText', window, [num2str(c)], center(1,1)+pos(j,1)-left_text_shift,center(1,2)+pos(j,2)-5,[0 0 0]); Screen(window, 'Flip',[],1);
    end
    c = c-1;
    
    
    % if right mouse clicked already before
      elseif whichButton == 3  && correction(r,c,1) == 1 ;
    % correction(r,c-1,1) = 1;
    % par.resp_click(r,c-1,1) = 0;
 
    end
end
end
num_cor = 0;
for k =1:size(par.sequence,2)
if par.resp_click(r,k) == par.sequence(k); num_cor = num_cor+1; disp(['Stimulus ', num2str(k), ': Correct']); else; disp(['Stimulus ', num2str(k), ': Wrong']);end;
end;



Screen('FillRect',window, BGcolor, [0.05*scresw 0.05*scresh 0.99*scresw 0.05*scresh+100]);
Screen('TextSize', window, 21);
Screen('DrawText', window, ['YOU DID ', num2str(num_cor), ' OF ',num2str(length(par.sequence)), ' CORRECT'], 0.05*scresw, 0.1*scresh, 255);
Screen('DrawText', window, 'PRESS THE MOUSE BUTTON TO START THE TASK', 0.05*scresw, 0.2*scresh, 255);
%Screen('DrawText', window, 'TO START THE ACTUAL TASK', 0.15*scresw, 0.25*scresh, 255);
Screen('Flip', window); 
[nrC,nr1,nr2,nrB] = GetClicks(whichScreen,0);


clearvars -except select subj_ID metafile subj_Name
% Waits for the user to press a button before starting
%[clicks,x,y,whichButton] = GetClicks(whichScreen,0);
%if par.recordEEG, sendtrigger(par.CD_END,port,SITE,0), end
%if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_END))])));end;

%save([par.runID , '_vis_learn'],'par','TGonT','ITIstartT')
%if par.useEL, 
    
    % stop recording
	%	calllib('iViewXAPI', 'iV_StopRecording');

		% save recorded data
	%	eyetr_data = formatString(64, int8('User1'));
	%	description = formatString(64, int8('Description1'));
	%	ovr = int32(1);
	%	filename = formatString(256, int8(['C:\PsychToolbox_Experiments\Simon\AA_eyetracker_data\' subj_ID{1,1} '_vis_learn' '.idf']));
	%	calllib('iViewXAPI', 'iV_SaveData', filename, description, eyetr_data, ovr)
    
   % calllib('iViewXAPI', 'iV_Disconnect'); end; %unloadlibrary('iViewXAPI');end

sca;
exitLoop = 1
close all
 %NetStation('StopRecording')