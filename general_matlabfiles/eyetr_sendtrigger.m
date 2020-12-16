function eyetr_sendtrigger(eye_trg,sock)
%% SEND TRIGGER WITH NEW SMI RED-n and Python
pnet(sock,'write',num2str(num2str(eye_trg)));
 pnet(sock,'writepacket');
end
