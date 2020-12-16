function [dur, delay] = playfakemovie(movie, trg1, trg2, ivx, n)

%movie = '/Users/shenin/Dropbox/CCNY/CMI/Black_Screen_Test.mp4';
%movie = '/home/simon/video_scripts/Black_Screen_Test.mp4';
%movie = '/home/shenin/video_scripts/EHow_Math_v2.mp4';
%movie = '/home/simon/video_scripts/ReadingClip_Cut.mp4';

AssertOpenGL;

color_white = [255 255 255];
par.BGcolor = color_white ;
whichScreen = 1;



%[scresw, scresh]=Screen('WindowSize',whichScreen);
Screen('CloseAll');
PsychGPUControl('FullScreenWindowDisablesCompositor', 1, 1);
window = Screen('OpenWindow', whichScreen, par.BGcolor,[],32, 2);
HideCursor;
maxPrio = MaxPriority(window);

Priority(maxPrio);
ifi = Screen('GetFlipInterval', window);
slack = ifi;
Priority(0);


async = [];
preloadSecs = [];
specialFlag = 1;
tend = 0;

par.CD_START  = 88;
par.CD_END = 108;
GetSecs;num2str(1);
counter = 1;

Priority(maxPrio);
%Try if adding a Screen('Preference', 'ConserveVRAM', x);
% with x=1 or 2 or 3 or 4 to the top of your script makes things better or worse.
% Reduced VRAM pressure, but higher load for system RAM and bus.
% Under these settings, PTB doesn't cache textures in VRAM anymore but only keeps them in system memory.
mode = 0;
Screen('Preference', 'ConserveVRAM', mode);

[moviePtr, duration, fps, width, height, count] = Screen('OpenMovie',window, movie, async, preloadSecs, specialFlag, 4);
%timing = NaN*zeros(count,10);

% Screen('PlayMovie',moviePtr,1,0,1.0);
% Screen('PlayMovie',moviePtr,0,0,1.0);

KbReleaseWait;
Screen('Flip',window);

% [vbl, StimulusOnsetTime, FlipTimestamp, Missed] = Screen('Flip',window);
% timing(counter,:) = [-0.01 vbl StimulusOnsetTime FlipTimestamp Missed];

%[vblstart, StimulusOnsetTime, Flipstart, Missed] = Screen('Flip',window);
%timing(counter,:) = [-0.01 0 0 0 0 0 0 0 Flipstart-vblstart Missed];

% Screen('PlayMovie',moviePtr,1,0,1.0);
% [tex, pts] = Screen('GetMovieImage', window, moviePtr, 1);
% Screen('PlayMovie',moviePtr,0);
% Screen('SetMovieTimeIndex', moviePtr, 0);

tplay = GetSecs;
Screen('PlayMovie',moviePtr,1,0,1.0);
tstart = GetSecs;

fprintf(1, 'trigger delay %2.4f\n', GetSecs-tstart);

clc
fprintf('PRESS CTRL+C and type "sca" in 5 seconds. then run CMI_EEG again')


while 1
    [tex, pts] = Screen('GetMovieImage', window, moviePtr, 0);
    if tex>0,
        
        
        t1 = GetSecs;
        
        Screen('DrawTexture',window,tex);
        Screen('DrawingFinished', window,2);

        [vbl, StimulusOnsetTime, FlipTimestamp, Missed] = Screen('Flip',window, t1+slack,2);
        %[vbl, StimulusOnsetTime, FlipTimestamp, Missed] = Screen('Flip',window, pts+slack,2);
        Screen('Close',tex);
        
        %tttime = GetSecs;
        
        counter = counter+1;
        %timing(counter,:) = [pts vbl-tstart FlipTimestamp-tstart vbl-vblstart FlipTimestamp-Flipstart t_to_next_tex t_to_draw FlipTimestamp-vbl ttime-tstart Missed];
        %timing(counter,:) = [pts (t1-ctime)+(tttime-t1) FlipTimestamp-tstart 0 0 0 0 0 0 0];
        timing(counter,:) = [pts vbl-tstart FlipTimestamp-tstart 0 0 0 0 0 0 0];
        %ctime = GetSecs;
    elseif tex<0
        %lptwriter(trg2, 0.002);
        t0 = GetSecs;
        
      %  fprintf(1, 'trigger delay %2.4f\n', GetSecs-t0);
        tend = GetSecs;
        break;
    end

    %fprintf('pts %4.4f vbl %4.4f\n', pts, vbl);
    %     counter = counter+1;
    %     timing(counter,:) = [pts vbl-vblstart tload StimulusOnsetTime FlipTimestamp Missed];
    
    % Check keyboard:
    %     [down secs keycode] = KbCheck;
    %     if down
    %         % Key pressed, break out of loop.
    %         break;
    %     end
end

% Stop playback:
dur=  tend-tstart;
delay = tstart-tplay;

Screen('CloseMovie', moviePtr);
%Screen('CloseAll');

Priority(0);

% save(['results/timing-noasync-' num2str(n) '.mat'], 'timing');
