% SAIIT with 2AFC - press left if left-tilted grating gets brighter than right, press right if right brighter
% Contents:
% 1) load monitor params, set task parameters
% 2) Get filename
% 3) set up triggers and open PTB window
% 4) make stimuli
% 5) make stimulus sequences, save as vectors of textures
% 6) designate trigger codes
% 7) make randomized sequence of trial types
% 8) present instructions to subject
% 9) Start trials

%clear all;

SITE = 'N';     % N for netstation (EGI)
port=0;
par.runID=subj_ID{1,1};
par.ExaminationDate =subj_ID{2,1};
par.recordEEG = 0; 

if subj_ID{4,1} == 'y'
par.useEL = 1;  % use the eye tracker?
else par.useEL = 0; end;

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

%%%%%%%%% IMPORTANT SETTINGS
par.videoFrate = 100%75% 100%%60 ;   % Monitor refresh rate
par.FlickF = par.videoFrate./[5 4];      % Flicker frequencies of two stimuli in Hz
% par.FlickF = par.FlickF(randperm(2));   % randomize frequency assignment
% to left and right (this was done for the PD study but I don't think it's necessary becaus we're not interested in asymmetries in left-tilted vs right-tilted perception - if there are differences, it is quite possible that it is due to the different flicker rates, but that's fine)

% Note the left-tilted stimulus is always stimulus "1" and right-tilted stimulus "2"
par.ReverseOrPulse = 1; % Phase reversing = 1, pattern pulse = 2.
par.numtargets = 5;
par.secs_btw_targs =  [2.8 4.4 6]%[2 2 2]; %[6 9 12]*40/75; %[2 2 2]*40/100% [2 2 2]*40/75 %[2 2 2]*40/60  %[6 9 12]*40/75;%;
par.spatfreq = 1;       % Spatial frequency of gratings
par.outerrad_deg = 6;   % in DEGREES
par.innerrad_deg = 1;   % in DEGREES
par.targrampdur = 1.6 %80/75 %80/60%; % 1.6 % in sec. Return ramp will be at double rate. Choose multiple of 0.2!
par.BLcontrast = 0.5;    % contrast
par.targChange = 0.5; % Max 0.5 for complete disappearance of other grating

par.eyeFBK = 0;

% Other Settings
par.leadintime = 1000; % how long to pause before experiment starts

Screen('Preference','SkipSyncTests',1)

if abs(hz-par.videoFrate)>1
    error(['The monitor is NOT SET to the desired frame rate of ' num2str(par.videoFrate) ' Hz. Change it.'])
end
if exist([par.runID '.mat'],'file'), 
   error([par.runID '.mat EXISTS ALREADY - CHOOSE ANOTHER, OR DELETE THAT ONE IF IT IS RUBBISH'])
end

% SOUND STUFF (don't think it works in Octave)
if par.eyeFBK
    Fs = 22050; % Hz
    High = 0.3*sin(2*pi*500*[0:1/Fs:0.1]);
    si = hanning(Fs/100)';
    env = [si(1:round(length(si)/2)) ones(1,length(High)-2*round(length(si)/2)) fliplr(si(1:round(length(si)/2)))];
    hHigh = audioplayer(High.*env, Fs);

    Low = 0.4*sin(2*pi*200*[0:1/Fs:0.3]);
    si = hanning(Fs/100)';
    env = [si(1:round(length(si)/2)) ones(1,length(Low)-2*round(length(si)/2)) fliplr(si(1:round(length(si)/2)))];
    hLow = audioplayer(Low.*env, Fs);
end

if par.useEL;  Eyetracker_connection_passive, end
%Initiate NetStation Connection, Synchronization, and Recording
if par.recordEEG
 %   NetStation('Connect','10.0.0.42')
    NetStation('Synchronize')
    NetStation('StartRecording')
end

% Opens a graphics window on the main monitor
Screen('Preference', 'VisualDebugLevel', 0);
window = Screen('OpenWindow', whichScreen, par.BGcolor);
%if par.useEL, cross = [400,300];f = figure;h1 = plot(cross(1), cross(2),'+');xlim([0 800]);ylim([0 600]);hold ;end
    %window_eye = Screen('OpenWindow', whichScreen_eye, [], [0 0 1280/3 1024/3]); end;
tic
% for n=1:75*4
%     Screen('Flip',window)
% end
% toc
% sca;
% return

	


%if par.useEL
    %%%%%%%%% EYETRACKING PARAMETERS
    %par.FixWinSize = 3;    % RADIUS of fixation (circular) window in degrees
    %par.TgWinSize = 3;    % RADIUS of fixation (circular) window in degrees
    %ELsetupCalib
    %Eyelink('Command', 'clear_screen 0')
    %Eyelink('command', 'draw_box %d %d %d %d 15', center(1)-deg2px*par.FixWinSize, center(2)-deg2px*par.FixWinSize, center(1)+deg2px*par.FixWinSize, center(2)+deg2px*par.FixWinSize);
%end


%  **********************  MAKE STIMULI
par.oriL = 135 * pi/180;
par.oriR = 45 * pi/180;
Rout = round(deg2px*par.outerrad_deg);  % radii in pix
Rin = round(deg2px*par.innerrad_deg);
D=Rout*2+1;                             % full stimulus size "D"
% Make a sinusoidal grating filling the stimulus rectangle:
[x,y] = meshgrid([1:D]-(D+1)/2,[1:D]-(D+1)/2);
GL = sin(par.spatfreq/deg2px*2*pi*(x.*cos(par.oriL)+y.*sin(par.oriL)));    % range -1 to 1 (needs to be transformed to brightness scale)
GR = sin(par.spatfreq/deg2px*2*pi*(x.*cos(par.oriR)+y.*sin(par.oriR)));    % range -1 to 1 (needs to be transformed to brightness scale)

midLum = GrayLevel2Lum(par.BGcolor,Cg,gam,b0);   % The very middle luminance on the monitor in cd/m^2
lumAmpl = floor(midLum);   % luminance amplitude (divergence from midLum) in cd/m^2
GL(find(GL>0))=lumAmpl; GL(find(GL<0))=-lumAmpl;    % convert sinusoidal luminance modulation of the spatial pattern to square wave
GR(find(GR>0))=lumAmpl; GR(find(GR<0))=-lumAmpl;

% Cut out the annulus shape:
for j=1:D
    for k=1:D
        [th,r]=cart2pol(x(j,k),y(j,k)); % cartesian to polar
        if r < Rin | r > Rout
            GL(j,k)= 0; GR(j,k)= 0;
        end
    end
end

% Now we'll make frame sequences, which comprise just a vector of multipliers for the pattern stimuli we've generated
% above (mostly 0 and 1 for off and on, and -1 for reversed pattern)
framesperflickercycle = round(par.videoFrate./par.FlickF);
BLframeseq = []; TGframeseq = [];

% baseline frame sequence length (this will be repeated again and again in the ITI)
BLframeseqlen = LCM_SK(framesperflickercycle);

% A standard baseline frame sequence:
if par.ReverseOrPulse == 1
    BLframeseqlen = BLframeseqlen*2;    % double it because every second "cycle" is phase reversed
    for f=1:length(par.FlickF)
        BLframeseq(:,f) = repmat([ones(1,framesperflickercycle(f)) -1*ones(1,framesperflickercycle(f))],1,BLframeseqlen/(2*framesperflickercycle(f)))';
    end
elseif par.ReverseOrPulse == 2
    for f=1:length(par.FlickF)
        ONframes = floor(framesperflickercycle(f)/2);
        BLframeseq(:,f) = repmat([ones(1,ONframes) zeros(1,framesperflickercycle(f)-ONframes)],1,BLframeseqlen/framesperflickercycle(f))';
    end
end

% make the blended baseline frame sequence specifically for 2 gratings superimposed:
CIF=par.BLcontrast;
for n=1:size(BLframeseq,1)
    stim = midLum + (CIF)*BLframeseq(n,1)*GL+(1-CIF)*BLframeseq(n,2)*GR;
    % Fixation point
    stim(Rout:Rout+2,Rout:Rout+2)=GrayLevel2Lum(255,Cg,gam,b0);
    BLstim(n) = Screen('MakeTexture', window, Lum2GrayLevel(stim,Cg,gam,b0));
end

% make targets:
numrefr = round(par.targrampdur*par.videoFrate);  % Target frame sequence length, just the ramp down
CIF=[par.BLcontrast+[1:numrefr]*par.targChange/numrefr fliplr(par.BLcontrast+[1:2:numrefr]*par.targChange/numrefr)];
TGframeseqlen = length(CIF);
if par.ReverseOrPulse == 1
    for f=1:length(par.FlickF)
        TGframeseq(:,f) = repmat([ones(1,framesperflickercycle(f)) -1*ones(1,framesperflickercycle(f))],1,TGframeseqlen/(2*framesperflickercycle(f)))';
    end
elseif par.ReverseOrPulse == 2
    for f=1:length(par.FlickF)
        ONframes = floor(framesperflickercycle(f)/2);
        TGframeseq(:,f) = repmat([ones(1,ONframes) zeros(1,framesperflickercycle(f)-ONframes)],1,TGframeseqlen/framesperflickercycle(f))';
    end
end
% BLENDING for targets and make textures (dealing in actual luminance until last step):
for n=1:size(TGframeseq,1)
    % A Left-tilt target:
    stim = midLum + (CIF(n))*TGframeseq(n,1)*GL+(1-CIF(n))*TGframeseq(n,2)*GR;
     % Fixation point
    stim(Rout:Rout+2,Rout:Rout+2)=GrayLevel2Lum(255,Cg,gam,b0);
    targstim(n,1) = Screen('MakeTexture', window, Lum2GrayLevel(stim,Cg,gam,b0));
    % A Right-tilt target:
    stim = midLum + (1-CIF(n))*TGframeseq(n,1)*GL+(CIF(n))*TGframeseq(n,2)*GR;
     % Fixation point
    stim(Rout:Rout+2,Rout:Rout+2)=GrayLevel2Lum(255,Cg,gam,b0);
    targstim(n,2) = Screen('MakeTexture', window, Lum2GrayLevel(stim,Cg,gam,b0));
end

stimrect = round([-1 -1 1 1]*D/2);

% test:
% for m=1:round(5*(2+3*rand))
%     for s=1:length(BLstim)
%         Screen('DrawTexture', window, BLstim(s), [], [center center] + stimrect);
%         Screen('Flip', window);
% %         WaitSecs(.5)
%     end
% end
% for n=1:length(targL)
%     Screen('DrawTexture', window, targL(n), [], [center center] + stimrect);
%     Screen('Flip', window);
% end
%return

%  ************************************************* CODES AND TRIAL SEQUENCE
% trigger codes - Using Cedrus we can only use these 15: [1 4 5 8 9 12 13 16 17 20 21 24 25 28 29]
par.CD_RESP  = 1;
par.CD_FIXON = 4;
par.CD_TGOFF = 5;   % target off
par.CD_TG = [8 9];   % target   % one for each target type
par.CD_BUTTONS = [12 13];
par.CD_BEEP = 29;

% TRIAL SEQUENCE RANDOMIZATION
% Factors varying trial to trial: ITI (3) x Tilt (2, left/right)
% first make the smallest block of trial types that cover all possibilities:
block = [ones(1,length(par.secs_btw_targs)) 2*ones(1,length(par.secs_btw_targs)) ; ...
        repmat(1:length(par.secs_btw_targs),1,2)];
% Then repeat that smallest block enough times to get the desired number of trials:
temp = repmat(block,[1,ceil(par.numtargets/size(block,2))]);
temp = temp(:,randperm(size(temp,2)));  % shuffle
trialITI = par.secs_btw_targs(temp(2,:));   % in seconds
trialLR = temp(1,:);


hands_file_path = '/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles/';
hands_filename1 = 'Instruct_Hands.tiff';
hands = imread([hands_file_path  hands_filename1]);
hands_tex = Screen('MakeTexture', window, hands);
stimrect_hands = [-50 -60 50 60];


HideCursor;
%SetMouse(1680,300,1) % middle of the second screen
%SetMouse([1280+638-20],300,1)
SetMouse([1280+638-20],550,1);
% *********************************************************************************** START TASK
% Instructions:
stimrect_example = [-75 -75 75 75];
stimrect_example_middle = [-50 -50 50 50];
%window = Screen('OpenWindow', 2, par.BGcolor);
Screen('DrawTexture', window, targstim(120,1), [], [250 450 250 450] + stimrect_example);
Screen('DrawTexture', window, targstim(120,2), [], [550 450 550 450] + stimrect_example);
Screen('DrawTexture', window, stim(1,1), [], [400 510 400 510] + stimrect_example_middle);
%Screen('Flip', window); 
 Screen('TextSize', window, 11);
Screen('DrawText', window, 'Fixate on the central dot.', 0.05*scresw, 0.25*scresh, 255);
Screen('DrawText', window, 'Press the LEFT button with LEFT hand when the LEFT-tilted pattern gets stronger.', 0.05*scresw, 0.30*scresh, 255); %0.05*scresw, 0.35*scresh
Screen('DrawText', window, 'Press the RIGHT button with RIGHT hand when the RIGHT-tilted pattern gets stronger.', 0.05*scresw, 0.35*scresh, 255);
% Screen('DrawTexture', window, targstim(s,trialLR(n)), [], [center center] + stimrect);
Screen('DrawText', window, 'Work as quickly as you can without making mistakes.', 0.05*scresw, 0.40*scresh, 255);
Screen('DrawText', window, 'Press the mouse button to begin', 0.05*scresw, 0.45*scresh, 255);
Screen('DrawText', window, 'Example:', 0.05*scresw, 0.70*scresh, 255);
Screen('DrawText', window, 'Left Target', 0.25*scresw, 0.90*scresh, 255);
Screen('DrawText', window, 'Right Target', 0.62*scresw, 0.90*scresh, 255);
Screen('DrawTexture', window, hands_tex, [], [center(1)-10 360 center(1)+10 390] + stimrect_hands);

Screen('Flip', window, [],[],1); 
fprintf('THE SUBJECT IS READING THE INSTRUCTIONS...');
% Things that we'll save on a trial by trial basis
clear ITIstartT TargOnT RespLR RespT
numResp=1;

HideCursor
%SetMouse(1680,300,1) % middle of the second screen
%SetMouse([1280+638-20],300,1)
SetMouse([1280+638-20],550,1)
%ShowCursor(0,whichScreen)


% Waits for the user to press a button before starting
[clicks,x,y,whichButton] = GetClicks(whichScreen,0);
%if par.recordEEG, sendtrigger(par.CD_RESP,port,SITE,0), end
%if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(par.CD_RESP)]))); end %iV_SendImageMessage'
RespT(1) = GetSecs;
RespLR(1) = whichButton;  if RespLR(numResp)==3, RespLR(numResp)=2; end  % The first response will be the one that sets the task going, after subject reads instructions


%% FEEDBACK  should be presented with the start of the ITI
        
feedback_file_path = '/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles/';
feedback_filename1 = 'feedback_correct.tiff';
feedback_filename2 = 'feedback_wrong.tiff';

feedback_correct = imread([feedback_file_path  feedback_filename1]);
feedback_wrong = imread([feedback_file_path feedback_filename2]);

feedback_correct_tex = Screen('MakeTexture', window, feedback_correct);
feedback_wrong_tex = Screen('MakeTexture', window, feedback_wrong);

stimrect_feedback = [-50 -50 50 50];

%%%%%%%%%%%%%%%%%%%% START TRIALS





% 
% 
% %%Feedback      
%window = Screen('OpenWindow', whichScreen, par.BGcolor);

%feedback_correct_tex = Screen('MakeTexture', window, feedback_correct);
%feedback_wrong_tex = Screen('MakeTexture', window, feedback_wrong);
%         if RespLR(numResp) == num2str(trialLR(n))
%            Screen('DrawTexture', window, feedback_correct_tex, [], [0.45*scresw, 0.1*scresh 0.45*scresw, 0.1*scresh]+ stimrect_feedback); Screen('Flip', window);
      
%elseif abs(RespLR(numResp) - num2str(trialLR(n)))== 1;
%              Screen('DrawTexture', window, feedback_wrong_tex, [], [center center] + [0.45*scresw, 0.05*scresh]+ stimrect_feedback); Screen('Flip', window);
%         end
%         


fprintf('THE SUBJECT IS PERFORMING THE TASK...');
% initial lead-in:
Screen('FillRect',window, 255, fixRect);
Screen('Flip', window);
WaitSecs(par.leadintime/1000);

% Start Task:
ButtonDown=0;
for n=1:par.numtargets
    
        
    % First show standard during ITI - the baseline frame sequence
    for m=1:round(trialITI(n)*par.videoFrate/BLframeseqlen)
        
        for s=1:BLframeseqlen
            
       
            
            
            %if par.recordEEG, if portUP & GetSecs-lastTTL>0.01, lptwrite(port,0); portUP=0; end, end
       % if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = Smp.leftEye.gazeX; y0 = Smp.leftEye.gazeY;	
       %      shg; 	h2 = plot(x0,y0,'or'); end; end;           
        Screen('DrawTexture', window, BLstim(s), [], [center center] + stimrect);
          %Feedback      
        if  m == 1 && numResp>1 && RespLR(numResp) == trialLR(n-1); % Problem if the subj forget to press button
            %Screen('DrawTexture', window, feedback_correct_tex, [], [0.485*scresw, 0.18*scresh 0.485*scresw, 0.18*scresh]+ stimrect_feedback);% Screen('Flip', window);
     Screen('DrawTexture', window, feedback_correct_tex, [], [center center]+ stimrect_feedback);% Screen('Flip', window);
 
        elseif m == 1 && numResp>1 && abs(RespLR(numResp) - trialLR(n-1))== 1 ;
            % Screen('DrawTexture', window, feedback_wrong_tex, [], [0.485*scresw, 0.18*scresh 0.485*scresw, 0.18*scresh]+ stimrect_feedback); %Screen('Flip', window);
        Screen('DrawTexture', window, feedback_wrong_tex, [], [center center]+ stimrect_feedback); %Screen('Flip', window);

        end    
        if m==1 & s==1
                % Whole bunch of triggers
                 % Screen('FillRect',window, 255, syncRect);
                
    
    
    [VBLTimestamp ITIstartT(n)] = Screen('Flip', window);
            else
                Screen('Flip', window);
            end
            checkButton
            if par.useEL
                if par.eyeFBK
                    checkeyeSK
                    if isnan(x) & isnan(y) % blink
                        play(hHigh)
                     elseif sqrt(x^2+y^2)>deg2px*par.FixWinSize
                        play(hLow)
                
                    end
                end
            end
        end
    end
    % present target
    for s=1:TGframeseqlen
       % if par.recordEEG, if portUP & GetSecs-lastTTL>0.01, lptwrite(port,0); portUP=0; end, end
        %if par.useEL, if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = Smp.leftEye.gazeX;	y0 = Smp.leftEye.gazeY;	
        %      	Screen('DrawTexture', window_eye, targstim(s,trialLR(n)), [], [0 0 1600/3 1200/3]); Screen('DrawDots', window_eye, [x0/2,y0/2], 20, [255 0 0]); Screen(window_eye, 'Flip');  end; end 
       
        
        Screen('DrawTexture', window, targstim(s,trialLR(n)), [], [center center] + stimrect);
        if s==1
            if par.recordEEG, sendtrigger(par.CD_TG(trialLR(n)),port,SITE,1); end
          %  if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_TG(trialLR(n))))])));end;
          %    if par.useEL, [success, ivx]=iViewX('message', ivx, [ num2str(num2str(par.CD_TG(trialLR(n))))]);end;

            
            [VBLTimestamp TargOnT(n)] = Screen('Flip', window);
            disp(['Target ' num2str(trialLR(n))]);
        else
            Screen('Flip', window);
        end
        checkButton;
        if par.useEL;
            if par.eyeFBK;
                checkeyeSK;
                if isnan(x) & isnan(y) ;% blink
                    play(hHigh);
                   elseif sqrt(x^2+y^2)>deg2px*par.FixWinSize;
                    play(hLow);
                end;
            end;
        end;
    end;
end;



% Lead-out
for m=1:round(par.secs_btw_targs(1)*par.videoFrate/BLframeseqlen); % shortest ITI...
    for s=1:BLframeseqlen;
   %     if par.recordEEG, if portUP & GetSecs-lastTTL>0.01, lptwrite(port,0); portUP=0; end, end
   % if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = Smp.leftEye.gazeX; y0 = Smp.leftEye.gazeY;	
    %         shg; 	h2 = plot(x0,y0,'or'); end; end;
        Screen('DrawTexture', window, BLstim(s), [], [center center] + stimrect);
        
 %Feedback for last trial   
        if  numResp>1 && RespLR(numResp) == trialLR(n); % Problem if the subj forget to press button
            %Screen('DrawTexture', window, feedback_correct_tex, [], [0.485*scresw, 0.18*scresh 0.485*scresw, 0.18*scresh]+ stimrect_feedback);% Screen('Flip', window);
     Screen('DrawTexture', window, feedback_correct_tex, [], [center center]+ stimrect_feedback);% Screen('Flip', window);
 
        elseif numResp>1 && abs(RespLR(numResp) - trialLR(n))== 1 ;
            % Screen('DrawTexture', window, feedback_wrong_tex, [], [0.485*scresw, 0.18*scresh 0.485*scresw, 0.18*scresh]+ stimrect_feedback); %Screen('Flip', window);
        Screen('DrawTexture', window, feedback_wrong_tex, [], [center center]+ stimrect_feedback); %Screen('Flip', window);

        end    
        
        
        if m==1 & s==1;
            if par.recordEEG, sendtrigger(par.CD_TGOFF,port,SITE,1); end;
             [VBLTimestamp ITIstartT(par.numtargets+1)] = Screen('Flip', window);
        else
            Screen('Flip', window);
        end
        checkButton;
        if par.useEL;
            if par.eyeFBK;
                checkeyeSK;
                if isnan(x) & isnan(y); % blink
                    play(hHigh);
                    elseif sqrt(x^2+y^2)>deg2px*par.FixWinSize;
                    play(hLow);
                                  end;
            end;
        end;
    end;
end;

%if par.useEL, 
%    Eyelink('StopRecording');
%    Eyelink('CloseFile');
%    ELdownloadDataFile
%    Eyelink('Shutdown');
%end

sca; ListenChar(0);
toc ;
% nr_correct = 0;
% for i = 2:size(RespLR,2)
% if RespLR(i) == trialLR(i-1);
% nr_correct = nr_correct+1;
% end
% end
% 
% disp(['SUBJECT PERFORMED ',num2str(nr_correct),' CORRECT OUT OF ',num2str(size(RespLR,2)-1), ' TRIALS']);
ShowCursor(0,whichScreen)
close all;
% clearvars -except select subj_ID metafile subj_Name;

%if par.useEL, 
    
    % stop recording
	%	calllib('iViewXAPI', 'iV_StopRecording');

		% save recorded data
	%	eyetr_data = formatString(64, int8('User1'));
	%	description = formatString(64, int8('Description1'));
	%	ovr = int32(1);
	%	filename = formatString(256, int8(['/home/cmi_linux/PsychToolbox_Experiments/Simon/AA_eyetracker_data/' subj_ID{1,1} '_SAIIT_2AFC' '.idf']));
	%	calllib('iViewXAPI', 'iV_SaveData', filename, description, eyetr_data, ovr)
    
  %  calllib('iViewXAPI', 'iV_Disconnect');end; %unloadlibrary('iViewXAPI');end

		
%NetStation('StopRecording')
% save([par.runID , '_SAIIT_2AFC'],'ITIstartT','TargOnT','RespT','RespLR','trialITI','trialLR','par') 

