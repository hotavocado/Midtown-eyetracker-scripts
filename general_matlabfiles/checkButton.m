% check for button down
clear buttons
[xblah,yblah,buttons] = GetMouse(whichScreen); 
if any(buttons)
    press(n) = 1;
    if ButtonDown==0
       
        numResp=numResp+1; RespT(numResp)=GetSecs;
        if buttons(1)
            RespLR(numResp)=1;
            disp('Button 1')
        elseif buttons(end)
            RespLR(numResp)=2;
            disp('Button 2')
        end
        if par.recordEEG, sendtrigger(par.CD_BUTTONS(RespLR(numResp)),port,SITE,1); portUP=1; lastTTL=GetSecs; end
        % if par.useEL, calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8([ num2str(num2str(par.CD_BUTTONS(RespLR(numResp))))])));end;
            if par.useEL, [success, ivx]=iViewX('message', ivx, [ num2str(num2str(numResp))]);end;

    
    end    
    ButtonDown = 1;
else
    ButtonDown = 0;
    
  
end