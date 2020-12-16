

for pp=1:par.numtargets

    %if par.useEL, 
    %        Screen('DrawDots', window_eye, pos(pp,:), radius/3, color, [center_eye/3], [1]); 
     %           
                 
    %end;

    Screen('DrawDots', window, pos(pp,:), radius, color, center, [1]);
    Screen('DrawDots', window, pos(pp,:), radius_in, color_gray, center, [1]);
end

%if par.useEL,  if (calllib('iViewXAPI', 'iV_GetSample', pSampleData) == 1); Smp = libstruct('SampleStruct', pSampleData); x0 = Smp.leftEye.gazeX; y0 = Smp.leftEye.gazeY;	
%             shg; 	h2 = plot(x0,y0,'or'); end; end;
     
Screen('DrawDots', window, [0 0], [3], color_fix, center, [1]);
