% SurroundSuppression - no task for subject - just fixation, while a sequence of screens come up with different center
% and surround contrasts, with "center" refering to regions of the screen that flicker

% ***************************************************** BASIC SET - UP 
%clear all;
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
midgray = par.BGcolor;

%Define TemporalFreq, SpatialFreq for BG and CNT, SpatialPhaseShift and Orientations
par.videoFrate = 100; %60 for 7.5 100 for 25Hz
par.FlickF = 25; %25Hz or less..7.2

par.numconds = 3;   % 4 3 number of stimulus conditions (does not include contrasts)
par.spatfreqBG = 1 *ones(par.numconds,1); %1 cpd to 7 cpd
par.spatfreqCNT = 1 *ones(par.numconds,1);
par.spatphaseBG = [pi 0 pi]; %[pi 0]; 0 = Spatial IN-phase, pi = spatial OUT-OF-Phase
par.spatphaseCNT = [0] *ones(par.numconds,1);
par.oriBG = [0 0 pi/2];  %[0 0] BG's stripes orientation 0 = vertical, pi/2 = horizontal
par.oriCNT = 0 *ones(par.numconds,1); %  Disc's stripes orientation 0 = vertical, pi/2 = horizontal
par.contrastsBG = [0 100]/100; %
par.contrastsCNT =  [0 30 60 100]/100;
par.trialsPerCond = nan;
par.trialdur = 2.4;
par.discrad_deg = 2;    % disc radius
par.posx = [4.7 -4.7 -3.5 3.5]; par.posy = [- 1.7 -1.7 3.5 3.5]; %Use this for four discs
%par.posx = [0]; par.posy = [0]; %Use this for one disc in the center

par.gap_deg = 0.3

par.leadintime = 1000;

%Initiate NetStation Connection, Synchronization, and Recording
if par.recordEEG
%    NetStation('Connect','10.0.0.42')
    NetStation('Synchronize')
    NetStation('StartRecording')
end

% for contrasts:
alph = [0:0.0001:1];
alpha2contrast=(((255-midgray)*alph+midgray).^gam - (midgray-midgray*alph).^gam)./(((255-midgray)*alph+midgray).^gam+(midgray-midgray*alph).^gam+2*b0./Cg);

%if par.useEL, ELCalibrateDialog, end

% Opens a graphics window on the main monitor
Screen('Preference','SkipSyncTests',1);
Screen('Preference', 'VisualDebugLevel', 0);
window = Screen('OpenWindow', whichScreen, par.BGcolor);

% Instructions:

files_eye_calib = dir('/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles/eye_calib.bmp');
filepath_eye_calib = '/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles/';
eye_calib_img = imread([filepath_eye_calib,files_eye_calib(1,1).name]);
eye_calib = Screen('MakeTexture', window, eye_calib_img);
stimrect_calib = [-20 -20 20 20];

Screen('TextSize', window, 12);
Screen('DrawText', window, 'Just maintain fixation on the central spot at all times.', 0.05*scresw, 0.25*scresh, 255);
Screen('DrawText', window, 'Press to begin', 0.05*scresw, 0.45*scresh, 255);
if subj_ID{5,1} == 'y'
Screen('DrawText', window, 'First we have to measure the position of your eyes.', 0.05*scresw, 0.60*scresh, 255);
Screen('DrawText', window, 'Just follow with your eyes the circle:', 0.05*scresw, 0.65*scresh, 255);
Screen('DrawTexture', window, eye_calib, [], [center(1)-10 450 center(1)+10 470] + stimrect_calib);
else par.useEL_Calib = 0; end;
Screen('Flip', window, [],[],1); 
fprintf('THE SUBJECT IS READING THE INSTRUCTIONS...');
% Things that we'll save on a trial by trial basis
clear TargOnT RespLR RespT
numResp=1;

% Waits for the user to press a button.
[clicks,x,y,whichButton] = GetClicks(whichScreen,0);

if par.useEL, open_udp_socket; end
if par.useEL && par.useEL_Calib; Eyetracker_connection_calib; 
elseif par.useEL == 1 && par.useEL_Calib == 0; Eyetracker_connection_passive; end


Screen('Preference','SkipSyncTests',1)
Screen('Preference', 'VisualDebugLevel', 0);
window = Screen('OpenWindow', whichScreen, par.BGcolor);

HideCursor; SetMouse(20,500,0);
%if par.useEL, cross = [400,300];f = figure;h1 = plot(cross(1), cross(2),'+');xlim([0 800]);ylim([0 600]);hold ;end
    %window_eye = Screen('OpenWindow', whichScreen_eye, [], [0 0 1280/3 1024/3]); end;

if abs(hz-par.videoFrate)>1
    error(['The monitor is NOT SET to the desired frame rate of ' num2str(par.videoFrate) ' Hz. Change it.'])
end

% if par.useEL
%     %%%%%%%%% EYETRACKING PARAMETERS
%     par.FixWinSize = 3;    % RADIUS of fixation (circular) window in degrees
%     par.TgWinSize = 3;    % RADIUS of fixation (circular) window in degrees
%     ELsetupCalib
%     Eyelink('Command', 'clear_screen 0')
%     Eyelink('command', 'draw_box %d %d %d %d 15', center(1)-deg2px*par.FixWinSize, center(2)-deg2px*par.FixWinSize, center(1)+deg2px*par.FixWinSize, center(2)+deg2px*par.FixWinSize);
% end

%  *************************** TIMING
% all in ms - in the task trial loop /1000 to sec
par.fixperiod = 500;    % how long to wait after fixation to start stimulating
par.ITI = 500;

%  **********************  MAKE STIMULI
%%%%%%%%%%%%%%%%%%%%%%% checkerboard wedge
% Stimuli specified as array of numbers between -1 (black) and 1 (white), called "A"
R = round(deg2px*par.discrad_deg);  % in pixels
gap = round(deg2px*par.gap_deg);  % in pixels

% make mesh...
[x,y] = meshgrid([1:scresw]-scresw/2,[1:scresh]-scresh/2);
stimrect = [1 1 scresw scresh]-[center center];
Screen('BlendFunction',window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

for c=1:par.numconds
    for i=1:4 % make four versions of each, with phase shifts, and these will be stepped through from trial to trial to minimize adaptation across trials
        % make Full-screen grating for background
        A = sin(par.spatfreqBG(c)/deg2px*2*pi*(x.*cos(par.oriBG(c))+y.*sin(par.oriBG(c))) + par.spatphaseBG(c) + (i-1)*pi/2); 
        % cut out the circles for the BG texture
        for n=1:length(par.posx)
            rr = sqrt((x-deg2px*par.posx(n)).^2 + (y-deg2px*par.posy(n)).^2);
            A(find(rr < (R+gap/2))) = 0;
            A(find(rr >= (R+gap/2) & rr < (R+gap))) = A(find(rr >= (R+gap/2) & rr < (R+gap))).*0.5.*(1-cos((rr(find(rr >= (R+gap/2) & rr < (R+gap)))-(R+gap/2))*pi/(gap/2)));
        end
    %     A(1:30,1:30)=0; % cut out the top left for the photodiode
        plane= cat(3,round((A+1)*255/2),255*(A~=0));    % set transparency values - all gray area
        BG(1,c,i) = Screen('MakeTexture', window, plane);

        % "CENTER" (CNT) Discs
        FULL = sin(par.spatfreqCNT(c)/deg2px*2*pi*(x.*cos(par.oriCNT(c))+y.*sin(par.oriCNT(c))) + par.spatphaseCNT(c) + (i-1)*pi/2); 
        for n=1:length(par.posx)
            rr = sqrt((x-deg2px*par.posx(n)).^2 + (y-deg2px*par.posy(n)).^2);
            A=FULL;
            A(find(rr > R+gap/2)) = 0;
            A(find(rr > R & rr <= (R+gap/2))) = A(find(rr > R & rr <= (R+gap/2))).*0.5.*(1+cos((rr(find(rr > R & rr <= (R+gap/2)))-R)*pi/(gap/2)));
            plane = cat(3,round((A+1)*255/2),255*(A~=0));
            CNT(n,c,i) = Screen('MakeTexture', window, plane);
        end
    end
end

%  ************************************************* CODES AND TRIAL SEQUENCE
% trigger codes - can only use these 15: [1 4 5 8 9 12 13 16 17 20 21 24 25 28 29]
par.CD_RESP  = 93;
par.CD_FIX_ON = 4;
par.CD_TGOFF = 5;   % target off
par.CD_TG = 8;   % target   % one for each target type
par.CD_BUTTONS = [12 13];

contrastconds = [];
for n=1:length(par.contrastsBG) %Increasing CNT within increasing BG
    for m=1:length(par.contrastsCNT)
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end
for m=1:length(par.contrastsCNT) %Decreasing BG within increasing CNT
    for n=fliplr(1:length(par.contrastsBG))
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end
for n=fliplr(1:length(par.contrastsBG)) %Increasing CNT within decreasing BG
    for m=1:length(par.contrastsCNT)
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end
for m=fliplr(1:length(par.contrastsCNT)) %Decreasing BG within decreasing CNT
    for n=fliplr(1:length(par.contrastsBG))
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end
for n=1:length(par.contrastsBG) %Decreasing CNT within increasing BG
    for m=fliplr(1:length(par.contrastsCNT))
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end
for m=1:length(par.contrastsCNT) %Increasing BG within increasing CNT
    for n=1:length(par.contrastsBG)
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end
for n=fliplr(1:length(par.contrastsBG)) %Decreasing CNT within decreasing BG
    for m=fliplr(1:length(par.contrastsCNT))
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end
for m=fliplr(1:length(par.contrastsCNT)) %Increasing BG within decreasing CNT
    for n=1:length(par.contrastsBG)
        contrastconds = [contrastconds [par.contrastsBG(n);par.contrastsCNT(m)]];
    end
end

block = [];
for c=1:par.numconds
    condseq2repeat = [1:par.numconds]; for j=1:c-1, condseq2repeat = [condseq2repeat(end) condseq2repeat(1:end-1)]; end
    condseq = repmat(condseq2repeat,[1,ceil(size(contrastconds,2)/par.numconds)]);
    block = [block [contrastconds ; condseq(1:size(contrastconds,2))]];
end

% get rid of redundant conditions for 0% background - we don't need to vary spatial phase and orientation!
% if there are 3 conditions, then get rid of 2 out of every three 0-background trials of a given foreground, i.e. keep only every third one
trials2delete = [];
for m=1:length(par.contrastsCNT)
    zeroBG = find(block(2,:)==par.contrastsCNT(m) & block(1,:)==0);
    trials2delete = [trials2delete zeroBG(1:3:end) zeroBG(2:3:end)];
end
block(:,sort(trials2delete)) = [];

BGcon = block(1,1:size(block,2)/2);
CNTcon = block(2,1:size(block,2)/2);
StimCond = block(3,1:size(block,2)/2);   % stimulus condition

% test
% Screen('DrawTexture', window, CNT(3,3), [], [1 1 scres],[],[],1);
% Screen('Flip', window); 
% return
% *********************************************************************************** START TASK
%if par.useEL, Eyelink('Message', ['TASK_START']); end
if par.recordEEG, sendtrigger(par.CD_RESP,port,SITE,0), end
%if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_RESP))])));end;
%if par.useEL, [success, ivx]=iViewX('message', ivx, [ num2str(num2str(par.CD_RESP))]);end;
if par.useEL, eyetr_sendtrigger([ num2str(num2str(par.CD_RESP))],sock); end;
fprintf('THE SUBJECT IS PERFORMING THE TASK...');
RespT(1) = GetSecs;
RespLR(1)=whichButton;  if RespLR(numResp)==3, RespLR(numResp)=2; end  % The first response will be the one that sets the task going, after subject reads instructions

%%%%%%%%%%%%%%%%%%%% START TRIALS

tic
% initial lead-in:
%if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = Smp.leftEye.gazeX;y0 = Smp.leftEye.gazeY;	
 %            shg, h2 = plot(x0,y0,'or'); end; end;

Screen('FillRect',window, 255, fixRect);
Screen('Flip', window);
WaitSecs(par.leadintime/1000);

PTlen = round(par.trialdur*par.videoFrate);
framesperflickercycle = round(par.videoFrate./par.FlickF);
ONframes = floor(framesperflickercycle/2);

PT(:,1) = repmat([ones(1,ONframes) zeros(1,framesperflickercycle-ONframes)],1,round(PTlen/framesperflickercycle))';          % fixed stimulus flicker=25hZ
PT(:,2) = PT(:,1);
PT(:,3) = 1-PT(:,1);
PT(:,4) = 1-PT(:,1);
PTsync = PT(:,1);
PTsync(find(PTsync(2:end)==PTsync(1:end-1))+1)=0;

phase_step = 0;

% Start Flicker:
pause = 0; Ptime = GetSecs;
for n=1:size(block,2)/2
    
    phase_step = phase_step+1; if phase_step>4, phase_step=1; end % step the phase of both background and foreground by pi/2 to avoide adaptation across trials
    %close(f)
    %if par.useEL, cross = [300,400]; f = figure;h1 = plot(cross(1), cross(2),'+');xlim([0 600]);ylim([0 800]);hold ;end
    %window_eye = Screen('OpenWindow', whichScreen_eye, [], [0 0 1280/3 1024/3]); end;

    bg = alph(find(alpha2contrast>=BGcon(n),1));    % background
    cnt = alph(find(alpha2contrast>=CNTcon(n),1));    % "center"
    
    % ITI
    
   
   % if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = Smp.leftEye.gazeX; y0 = Smp.leftEye.gazeY;	
   %          shg; 	h2 = plot(x0,y0,'or'); end; end;
 
    
    Screen('FillRect',window, par.BGcolor, fixRect);
    Screen('DrawText', window, 'Trial:', 0.45*scresw, 0.2*scresh, 255);
    Screen('DrawText', window, [num2str(n) ' of ' num2str(size(block,2) /2)], 0.44*scresw, 0.25*scresh, 255);

    Screen('Flip', window);
    t_start=GetSecs; t_now=GetSecs;
    while t_now-t_start < par.ITI/1000
        [keyIsDown, secs, keyCode] = KbCheck; % check for keyboard press
        if keyCode(pausekey), pause=1; Ptime = GetSecs; end
        t_now = GetSecs;
    end
    if pause
        while 1
            [keyIsDown, secs, keyCode] = KbCheck; % check for keyboard press
            if keyCode(pausekey) & GetSecs-Ptime > 1, pause=0; Ptime = GetSecs; break; end
        end
    end
    
    % Fixation period
    disp(['TRIAL ' num2str(n) ' OF ' num2str(size(block,2)/2)])
    %if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = randi([0 600]); y0 = randi([0 800]);%x0 = Smp.leftEye.gazeX;y0 = Smp.leftEye.gazeY;	
     %        shg, h2 = plot(x0,y0,'or'); end; end;

    Screen('FillRect',window, 255, fixRect);
    if par.recordEEG, sendtrigger(par.CD_FIX_ON,port,SITE,0); end
 % if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_FIX_ON))])));end;
%if par.useEL, [success, ivx]=iViewX('message', ivx, [ num2str(num2str(par.CD_FIX_ON))]);end;
if par.useEL, eyetr_sendtrigger([ num2str(num2str(par.CD_FIX_ON))],sock); end;
    %if par.useEL, Eyelink('Message', ['TRIAL' num2str(n) 'FIXON' num2str(par.CD_FIX_ON)]); end
    Screen('Flip', window, [], 1);
    t_start=GetSecs; t_now=GetSecs;
    while t_now-t_start < par.fixperiod/1000
        [keyIsDown, secs, keyCode] = KbCheck; % check for keyboard press
        if keyCode(pausekey) & GetSecs-Ptime>1, pause=1; Ptime = GetSecs; end
        t_now = GetSecs;
    end

    if par.recordEEG, sendtrigger(par.CD_TG,port,SITE,0); end
    %if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_TG))])));end;
    %if par.useEL, [success, ivx]=iViewX('message', ivx, [ num2str(num2str(par.CD_TG))]);end;
if par.useEL, eyetr_sendtrigger([ num2str(num2str(par.CD_TG))],sock); end;
    %if par.useEL, Eyelink('Message', ['TRIAL' num2str(n) 'TG' num2str(par.CD_TG)]); end
    TargOnT(n) = GetSecs;
    for p=1:size(PT,1)
        [keyIsDown, secs, keyCode] = KbCheck; % check for keyboard press
        if keyCode(pausekey) & GetSecs-Ptime > 1, pause=1; Ptime = GetSecs; end
 %      if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = randi([0 600]); y0 = randi([0 800]);%x0 = Smp.leftEye.gazeX;y0 = Smp.leftEye.gazeY;	
 %            shg, h2 = plot(x0,y0,'or'); end; end;
     
        Screen('DrawTexture', window, BG(1,StimCond(n),phase_step), [], [center center] + stimrect,[],[],bg);
        for m=1:length(par.posx)
            if PT(p,m)
 %          if par.useEL, if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = randi([0 600]); y0 = randi([0 800]);%x0 = Smp.leftEye.gazeX;y0 = Smp.leftEye.gazeY;	
 %            shg, h2 = plot(x0,y0,'or'); end; end;
  
                Screen('DrawTexture', window, CNT(m,StimCond(n),phase_step), [], [center center] + stimrect,[],[],cnt);
            end
        end
%         if PTsync(p)
%             Screen('FillRect',window, 255, syncRect);
%         end
        Screen('FillRect',window, 255, fixRect);
        Screen('Flip', window);
    end
    
end




toc

Screen('TextSize', window, 36);
Screen('DrawText', window, 'Finished!', 0.35*scresw, 0.45*scresh, 255);
Screen('Flip', window);  
WaitSecs(3)

%if par.useEL, 
%    Eyelink('StopRecording');
 %   Eyelink('CloseFile');
 %   ELdownloadDataFile
%end
% if par.useEL, 
%     
%         
% [success, ivx]=iViewX('stoprecording', ivx);
% [success, ivx]=iViewX('datafile', ivx, ['C:\PsychToolbox_Experiments\Simon\HBN\AA_eyetracker_data\' subj_ID{1,1} '_SurrSupp_Block1'  '.idf']);
% 
% [success, ivx]=iViewX('clearbuffer', ivx);
% [success, ivx]=iViewX('closeconnection', ivx);
% if success~=1
%     fprintf([mfilename ': could not close connection.\n']);
% end
% end

if par.useEL,
%% EYE tracking stop recording
pnet(sock,'write','end')
pnet(sock,'writepacket')
end

sca

save([par.runID , '_SurroundSupp_Block1'],'TargOnT','BGcon','CNTcon','StimCond','RespT','RespLR','par') 
NetStation('StopRecording')

SetMouse(700,800,1)
ShowCursor(0,whichScreen)
clearvars -except select subj_ID metafile subj_Name
close all

