%% Resting-EEG



pausekey = KbName('p');
SITE = 'N';     % T = TCD, C = City College, E = EGI in City College
port=0;

par.runID= subj_ID{1,1};
par.ExaminationDate =subj_ID{2,1};
if subj_ID{3,1} == 'y'
par.recordEEG = 1;
else par.recordEEG = 0; end;

if subj_ID{4,1} == 'y'
par.useEL = 1;  % use the eye tracker?
else  par.useEL = 0; end;

if subj_ID{5,1} == 'y'
par.useEL_Calib = 1;  % use the eye tracker?
else par.useEL_Calib = 0; end;


%% connnect eyetracker
if par.useEL == 1; 
host='10.0.0.43';
port_EL=6666;
ivx=iViewXInitDefaults([],[], host, port_EL);
ivx.localport=4444;
% eyetracker calibration settings
% ivx.window = w;
ivx.screenHSize = 800;
ivx.screenVSize = 600;
ivx.absCalPos = [400 300; 200 6; 792 150; 600 594; 8 450];
end
%%


monitorwidth_cm = 40;   % monitor width in cm
dist_cm = 68;  % viewing distance in cm

whichScreen = 1;
%whichScreen_eye = 1;

[scresw, scresh]=Screen('WindowSize',whichScreen);  % Get screen resolution
center = [scresw scresh]/2;     % useful to have the pixel coordinates of the very center of the screen (usually where you have someone fixate)
fixRect = [center-2 center+2];  % fixation dot
hz=Screen('FrameRate', whichScreen,1);

cm2px = scresw/monitorwidth_cm;  % multiplication factor to convert cm to pixels
deg2px = dist_cm*cm2px*pi/180;      % multiplication factor to convert degrees to pixels (uses aproximation tanT ~= T).

load gammafnCRT   % load the gamma function parameters for this monitor - or some other CRT and hope they're similar! (none of our questions rely on precise quantification of physical contrast)
maxLum = GrayLevel2Lum(255,Cg,gam,b0);
par.BGcolor=Lum2GrayLevel(maxLum/2,Cg,gam,b0);

 
par.CD_START  = 90;
 par.CD_eyeO = 20;
 par.CD_eyeC = 30;
 

%Initiate NetStation Connection, Synchronization, and Recording
if par.recordEEG
    [status] = NetStation();
if status ~= 8,
    NetStation('Connect','10.0.0.42')
end
    %NetStation('Connect','10.0.0.42')
    NetStation('Synchronize')
    NetStation('StartRecording')
end

%% Sound Stuff

% dev = PsychPortAudio('GetDevices')
% count = PsychPortAudio('GetOpenDeviceCount')

wavfilename_probe1 = '/home/cmi_linux/PsychToolbox_Experiments/Simon/resting/open_eyes.wav'
wavfilename_probe2 = '/home/cmi_linux/PsychToolbox_Experiments/Simon/resting/close_eyes.wav'
 [y_probe1, freq1] = wavread(wavfilename_probe1);
 [y_probe2, freq2] = wavread(wavfilename_probe2);
    wavedata_probe1 = y_probe1';
     wavedata_probe2 = y_probe2';
     
     
     
    nrchannels = size(wavedata_probe1,1); % Number of rows == number of channels.

 
% Add 15 msecs latency on Windows, to protect against shoddy drivers:
sugLat = [];
if IsWin
    sugLat = 0.015;
end

InitializePsychSound

pahandle = PsychPortAudio('Open', [], [], 0, freq1, nrchannels, [], sugLat);

duration_probe1 = size(wavedata_probe1,2)/freq1
duration_probe2 = size(wavedata_probe2,2)/freq1


%%




%Place full path for movie here.  For example, 
% moviename = '/home/cmi_linux/Users/Desktop/moviename.avi'
 Screen('Preference','SkipSyncTests',1)
Screen('Preference', 'VisualDebugLevel', 0);
% PsychGPUControl('FullScreenWindowDisablesCompositor', 1, 1);
 window = Screen('OpenWindow', whichScreen, par.BGcolor);
% maxPrio = MaxPriority(window);
% Priority(maxPrio);
% ifi = Screen('GetFlipInterval', window);



eyeO = [10:60:310];
eyeC = [30:60:330];

% eyeO = [10:60:370];
% eyeC = [30:60:390];

%sec1 = zeros(count,1);
i = 1;
t = 1;
tt = 1;

files_eye_calib = dir('/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles/eye_calib.bmp')
filepath_eye_calib = '/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles/'
eye_calib_img = imread([filepath_eye_calib,files_eye_calib(1,1).name]);
eye_calib = Screen('MakeTexture', window, eye_calib_img);
stimrect_calib = [-20 -20 20 20];

if par.useEL, open_udp_socket; end

 if par.recordEEG, sendtrigger(par.CD_START,port,SITE,0), end
% if par.recordEEG,  NetStation('Event', num2str(par.CD_START)); end
    %if par.useEL, iViewX('message', ivx, num2str(num2str(par.CD_START))); end;
    Screen('TextSize', window, 21);
Screen('DrawText', window, 'Fixate on the central cross.', 0.05*scresw, 0.25*scresh, 255);
Screen('DrawText', window, 'Open or close your eyes', 0.05*scresw, 0.35*scresh, 255);
Screen('DrawText', window, 'when you hear the request for it.', 0.05*scresw, 0.45*scresh, 255);
Screen('DrawText', window, 'Press to begin.', 0.05*scresw, 0.5*scresh, 255);
if subj_ID{5,1} == 'y'
Screen('DrawText', window, 'First we have to measure the position of your eyes.', 0.05*scresw, 0.60*scresh, 255);
Screen('DrawText', window, 'Just follow with your eyes the circle:', 0.05*scresw, 0.65*scresh, 255);
Screen('DrawTexture', window, eye_calib, [], [center(1)-10 450 center(1)+10 470] + stimrect_calib);
else par.useEL_Calib = 0; end;

Screen('Flip', window); 
[clicks,x,y,whichButton] = GetClicks(whichScreen,0);    
fprintf('THE SUBJECT IS READING THE INSTRUCTIONS');
%% Calibration
if par.useEL && par.useEL_Calib; Eyetracker_connection_calib; 
elseif par.useEL == 1 && par.useEL_Calib == 0; Eyetracker_connection_passive; end
if par.useEL && par.useEL_Calib;
window = Screen('OpenWindow', whichScreen, par.BGcolor);
end
time = GetSecs;
if par.useEL, eyetr_sendtrigger(par.CD_START,sock); end;

%while ~KbCheck
    SetMouse(20,500,0);
    while t <7 %8 if  you want to run 6 cycles
   % tex = Screen('GetMovieImage', hsc, moviePtr);
    Screen('DrawLine', window,[0 0 0],center(1)-7,center(2), center(1)+7,center(2));
    Screen('DrawLine', window,[0 0 0],center(1),center(2)-7, center(1),center(2)+7);
 
    %hz = Screen('FrameRate',window);
      %vScreen('CopyWindow',buffer, window); % clc
  vbl = Screen('Flip',window); % clc
  %Screen('Flip',window); % clc
  %vbl1 = GetSecs;
  if vbl >=time+eyeO(t) %Tests if a second has passed 
        if par.recordEEG, sendtrigger(par.CD_eyeO(1),port,SITE,0); end
      %if par.recordEEG,  NetStation('Event', num2str(par.CD_eyeO(1))); end

        % if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_eyeO(1)))])));end;
         %if par.useEL, iViewX('message', ivx, num2str(num2str(par.CD_eyeO(1)))); end;
         if par.useEL,  eyetr_sendtrigger(par.CD_eyeO(1),sock); end;
         
        PsychPortAudio('FillBuffer', pahandle,wavedata_probe1)
        PsychPortAudio('Start', pahandle, 1, 0, 1);
 
               t = t+1;
            
  end
  
    if vbl >=time+eyeC(tt) %Tests if a second has passed  
        if par.recordEEG, sendtrigger(par.CD_eyeC(1),port,SITE,0); end
       % if par.recordEEG,  NetStation('Event', num2str(par.CD_eyeC(1))); end
        %if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_eyeC(1)))])));end;        
        %if par.useEL, iViewX('message', ivx, num2str(num2str(par.CD_eyeC(1)))); end;
        if par.useEL, eyetr_sendtrigger(par.CD_eyeC(1),sock); end;
        
        PsychPortAudio('FillBuffer', pahandle,wavedata_probe2)
        PsychPortAudio('Start', pahandle, 1, 0, 1);
  
                  tt = tt+1;   
    end
  
    end
    
    %Screen('Close',tex);
%end

 Screen('TextSize', window, 36);
Screen('DrawText', window, 'Finished!', 0.35*scresw, 0.45*scresh, 255);
 Screen('TextSize', window, 21);
Screen('DrawText', window, 'Now we are going to do some real tasks', 0.10*scresw, 0.55*scresh, 255);
Screen('Flip', window);  

WaitSecs(4)



    % stop recording eyetracker   
%     if par.useEL, 
% [success, ivx]=iViewX('stoprecording', ivx);
% [success, ivx]=iViewX('datafile', ivx, ['C:\PsychToolbox_Experiments\Simon\HBN\AA_eyetracker_data\' subj_ID{1,1} '_resting'  '.idf']);
% 
% [success, ivx]=iViewX('clearbuffer', ivx);
% [success, ivx]=iViewX('closeconnection', ivx);
% if success~=1
%     fprintf([mfilename ': could not close connection.\n']);
% end
%     end

if par.useEL,
%% EYE tracking stop recording
pnet(sock,'write','end')
pnet(sock,'writepacket')
end


NetStation('StopRecording')
Screen('CloseAll');
sca
clearvars -except select subj_ID metafile subj_Name
% j = find(sec1);
% sec1 = sec1(j);
% timediff = diff(sec1); % will give the difference of each value of sec1
