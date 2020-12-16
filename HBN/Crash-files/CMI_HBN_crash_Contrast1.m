clear all

addpath('/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles')
addpath(genpath('/home/cmi_linux/PsychToolbox_Experiments/Simon/WISC_PS'))
addpath(genpath('/home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics'))
addpath('/home/cmi_linux/PsychToolbox_Experiments/Simon/HBN/Crash-files')
addpath('/home/cmi_linux/PsychToolbox_Experiments/Simon/HBN/Clips')
%loadlibrary('iViewXAPI.dll', 'iViewXAPI.h');
% tasklist = {'Resting-EEG','Video','Change Detection', 'Surround Suppression','Learning Paradigm','Auditory Psychophysics', 'Processing Speed'};
%   
% [select] = listdlg('PromptString','Select Task', 'SelectionMode','single', 'ListSize',[150 120],'ListString',...
%                     tasklist)
% date
clc
    cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
              subj_Name =inputdlg({'Enter Subjects ID:'},'CMI-EEG',1,{''});

%       fake_vid_q =questdlg({'Do you want to run the Video Test'},'CMI-EEG');
%   if strmatch('Yes', fake_vid_q,'exact');
% 
% h = msgbox('VIDEO TESTING - PLEASE WAIT FOR FURTHER INSTRUCTIONS');
% close(h) 
% fake_video
% else
%delete('run_fake_movie.mat');


       if exist([subj_Name{1,1}, '_SAIIT_2AFC_Block1.mat']) >0
     subj_Name =inputdlg({'Task already recorded for that subject! Choose a different one:'},'CMI-EEG',1,{''});
      end
    
     cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
    
      if exist([subj_Name{1,1}, '_metafile.mat']) >0
     load([subj_Name{1,1}, '_metafile'])
       else
           subj_Name =inputdlg({'Subject ID not found! Choose a different one:'},'CMI-EEG',1,{''});
          load([subj_Name{1,1}, '_metafile'])
      end         
      
       
      conn_EEG =inputdlg({'Record EEG:'},'CMI-EEG',1,{'Yes'});
      if strmatch('Yes', conn_EEG,'exact');
    NetStation('Connect','10.0.0.42')
      end
     
     
      %% Contrast 1
           start_Contrast1 =questdlg('Would you like to start the Contrast Change Detection (1st Block) ?');
             if strmatch('Cancel', start_Contrast1,'exact');
          return
           elseif strmatch('Yes', start_Contrast1,'exact');
     metafile.tasks{end+1,1} = 'Contrast1';
     metafile.tasks{end,2} = start_Contrast1;
     subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:', 'Example Trials:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y', 'y'});
        if strmatch('y', subj_ID(6,1),'exact');
     ContrastChangeDetect_2AFC_CMI_example_new_5examples  
        end
         start_Contrast_task1 =questdlg('Would you like to start the actual task?');
       if strmatch('Yes', start_Contrast_task1,'exact');
           ContrastChangeDetect_2AFC_CMI_new_Block1
        else
       start_Contrast_example2 =questdlg('Would you like to start the the practice task again?');
        if strmatch('Yes', start_Contrast_example2,'exact');
       ContrastChangeDetect_2AFC_CMI_example_new_5examples 
        end
       start_Contrast_task1_new =questdlg('Would you like to start the actual task?');
       if strmatch('Yes', start_Contrast_task1_new,'exact');
       ContrastChangeDetect_2AFC_CMI_new_Block1
       else
        start_Contrast_example3 =questdlg('Would you like to start the the practice task again?');
        if strmatch('Yes', start_Contrast_example3,'exact');
       ContrastChangeDetect_2AFC_CMI_example_new_5examples 
        end
       start_Contrast_task1_new =questdlg('Would you like to start the actual task?');
       if strmatch('Yes', start_Contrast_task1_new,'exact');
       ContrastChangeDetect_2AFC_CMI_new_Block1   
       end
       end
       end
             end
     
       cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
      save([subj_Name{1,1}, '_metafile'],'metafile')
      
      
       
       
       
       
      %% Video 1
      start_Video1 =questdlg('Would you like to start the 1st Video ?');
        if strmatch('Cancel', start_Video1,'exact');
          return
      elseif strmatch('Yes', start_Video1,'exact');
     metafile.tasks{end+1,1} = 'Video1';
     metafile.tasks{end,2} = start_Video1;
     subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y'});
     VIDEO1_without1sec_trigger
     %VIDEO1
      end

       cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
      save([subj_Name{1,1}, '_metafile'],'metafile')
      
      
     %% BREAK
       start_Break =questdlg('Time for a Break! Break Over?');
           
      
  
      
      %% Contrast 2
                 start_Contrast2 =questdlg('Would you like to start the Contrast Change Detection (2nd Block) ?');
                   if strmatch('Cancel', start_Contrast2,'exact');
          return
                 elseif strmatch('Yes', start_Contrast2,'exact');
     metafile.tasks{end+1,1} = 'Contrast2';
     metafile.tasks{end,2} = start_Contrast2;
      subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:', 'Example Trials:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y', 'y'});
        if strmatch('y', subj_ID(6,1),'exact');
     ContrastChangeDetect_2AFC_CMI_example_new  
        end
        start_Contrast_task2 =questdlg('Would you like to start the actual task?');
       if strmatch('Yes', start_Contrast_task2,'exact');
       ContrastChangeDetect_2AFC_CMI_new_Block2
       else
       start_Contrast_example2 =questdlg('Would you like to start the the practice task again?');
        if strmatch('Yes', start_Contrast_example2,'exact');
       ContrastChangeDetect_2AFC_CMI_example_new 
        end
       start_Contrast_task2_new =questdlg('Would you like to start the actual task?');
       if strmatch('Yes', start_Contrast_task2_new,'exact');
       ContrastChangeDetect_2AFC_CMI_new_Block2
       end
       end
      end

      cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
     save([subj_Name{1,1}, '_metafile'],'metafile')
     % 
      %% Video 2
            start_Video2 =questdlg('Would you like to start the 2nd Video ?');
              if strmatch('Cancel', start_Video2,'exact');
          return
            elseif strmatch('Yes', start_Video2,'exact');
      metafile.tasks{end+1,1} = 'Video2';
      metafile.tasks{end,2} = start_Video2;
     subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y'});
     VIDEO2_without1sec_trigger
     %VIDEO2
      end
   
      cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
      save([subj_Name{1,1}, '_metafile'],'metafile')
      
      %% Contrast 3
                       start_Contrast3 =questdlg('Would you like to start the Contrast Change Detection (3rd Block) ?');
                         if strmatch('Cancel', start_Contrast3,'exact');
          return
                       elseif strmatch('Yes', start_Contrast3,'exact');
      metafile.tasks{end+1,1} = 'Contrast3';
      metafile.tasks{end,2} = start_Contrast3;
      subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:', 'Example Trials:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y', 'y'});
        if strmatch('y', subj_ID(6,1),'exact');
     ContrastChangeDetect_2AFC_CMI_example_new  
        end
        start_Contrast_task3 =questdlg('Would you like to start the actual task?');
       if strmatch('Yes', start_Contrast_task3,'exact');
       ContrastChangeDetect_2AFC_CMI_new_Block3
    else
       start_Contrast_example2 =questdlg('Would you like to start the the practice task again?');
        if strmatch('Yes', start_Contrast_example2,'exact');
       ContrastChangeDetect_2AFC_CMI_example_new 
        end
       start_Contrast_task3_new =questdlg('Would you like to start the actual task?');
       if strmatch('Yes', start_Contrast_task3_new,'exact');
       ContrastChangeDetect_2AFC_CMI_new_Block3
       end
       end
      end

       cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
     save([subj_Name{1,1}, '_metafile'],'metafile')
      
    
      
      
      
      %% Video 3
            start_Video3 =questdlg('Would you like to start the 3rd Video?');
              if strmatch('Cancel', start_Video3,'exact');
          return
            elseif strmatch('Yes', start_Video3,'exact');
     metafile.tasks{end+1,1} = 'Video3';
     metafile.tasks{end,2} = start_Video3;
     subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y'});
     VIDEO3_without1sec_trigger     
     %VIDEO3
      end

      cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
     save([subj_Name{1,1}, '_metafile'],'metafile')
     
     
     
      %% Surround Suppression 2
      start_Surr_Supp2 =questdlg('Would you like to start the Surroud Suppression (2nd Block)?');
        if strmatch('Cancel', start_Surr_Supp2,'exact');
          return
      elseif strmatch('Yes', start_Surr_Supp2,'exact');
     metafile.tasks{end+1,1} = 'Surr_Supp2';
     metafile.tasks{end,2} = start_Surr_Supp2;
     subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y'});
     SurroundSupp4circCMI_new_fixed_order_Block2
      end

      cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
     save([subj_Name{1,1}, '_metafile'],'metafile')
      
     
              %% Video 4
            start_Video4 =questdlg('Would you like to start the 4th Video?');
              if strmatch('Cancel', start_Video4,'exact');
          return
            elseif strmatch('Yes', start_Video4,'exact');
     metafile.tasks{end+1,1} = 'Video4';
     metafile.tasks{end,2} = start_Video4;
subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:'},'CMI-EEG',1,{subj_Name{1,1},date,'y','y', 'y'});
        subj_ID {4,1} = 'y'; 
        VIDEO4_without1sec_trigger     
     %VIDEO3
      end

      cd /home/cmi_linux/PsychToolbox_Experiments/Simon/HBN;
     save([subj_Name{1,1}, '_metafile'],'metafile')
      
% end      
      
      
%      %% IAT
%             start_IAT =questdlg('Would you like to start the Implicit Association Task');
%         if strmatch('Cancel', start_IAT,'exact');
%           return
%         elseif strmatch('Yes', start_IAT,'exact');
%      metafile.tasks{end+1,1} = 'Surr_IAT';
%      metafile.tasks{end,2} = start_IAT;
%      cd '/home/cmi_linux/Program Files/FreeIAT'
%      !FreeIAT_1.3.3.exe
%       end
% 
%         cd /home/cmi_linux/PsychToolbox_Experiments/Simon;
%      save([subj_Name{1,1}, '_metafile'],'metafile')
%       
%       %% PTICH Auditory Discrimination
%       
%       disp('DID YOU CHANGE THE AUDIOCABLE?');
%                   start_MLP_pitch =questdlg('Would you like to start the Pitch - Auditory Discrimination Task');
%                     if strmatch('Cancel', start_MLP_pitch,'exact');
%           return
%                   elseif strmatch('Yes', start_MLP_pitch,'exact');
%      metafile.tasks{end+1,1} = 'MLP_pitch';
%      metafile.tasks{end,2} = start_MLP_pitch;
%           cd /home/cmi_linux/PsychToolbox_Experiments/Simon;
%      save([subj_Name{1,1}, '_metafile'],'metafile')
%      %randomize order!
%      
%   cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_example_pitch
%            cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_CMI_pitch_500ms_ISI
%           
%            cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_example_pitch
%            cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_CMI_pitch_250ms_ISI
%       end
% 
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  %% GAP Auditory Discrimination
%   disp('DID YOU CHANGE THE AUDIOCABLE?');
%                   start_MLP_gap =questdlg('Would you like to start the Gap - Auditory Discrimination Task');
%                     if strmatch('Cancel', start_MLP_gap,'exact');
%           return
%                   elseif strmatch('Yes', start_MLP_gap,'exact');
%      metafile.tasks{end+1,1} = 'MLP_gap';
%      metafile.tasks{end,2} = start_MLP_gap;
%         cd /home/cmi_linux/PsychToolbox_Experiments/Simon;
%      save([subj_Name{1,1}, '_metafile'],'metafile')
%      
%   cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_example_gap
%           cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_CMI_gap
%       end
% 
%   %% FORMANT Auditory Discrimination
%    disp('DID YOU CHANGE THE AUDIOCABLE?');
%                   start_MLP_formant =questdlg('Would you like to start the Formant - Auditory Discrimination Task');
%                     if strmatch('Cancel', start_MLP_formant,'exact');
%           return
%                   elseif strmatch('Yes', start_MLP_formant,'exact');
%      metafile.tasks{end+1,1} = 'MLP_formant';
%      metafile.tasks{end,2} = start_MLP_formant;
%         cd /home/cmi_linux/PsychToolbox_Experiments/Simon;
%      save([subj_Name{1,1}, '_metafile'],'metafile')
%      
%   cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_example_formant
%           cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics/
%           MLP_CMI_formant
%       end 
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
     
      
%%

% clear all
% 
% addpath('/home/cmi_linux/PsychToolbox_Experiments/Simon/general_matlabfiles')
% addpath('/home/cmi_linux/PsychToolbox_Experiments/Simon/WISC_PS')
% tasklist = {'Resting-EEG','Video','Change Detection', 'Surround Suppression','Learning Paradigm','Auditory Psychophysics', 'Processing Speed'};
%   
% [select] = listdlg('PromptString','Select Task', 'SelectionMode','single', 'ListSize',[150 120],'ListString',...
%                     tasklist)
% date
%                 subj_ID =inputdlg({'Enter Subjects ID:', 'Enter Date:','Use EEG:', 'Use Eye-Tracker:', 'Eye-Tracker Calibration:'},'CMI-EEG',1,{'',date,'y','y', 'y'});
%                 
%       if select == 1
%      cd /home/cmi_linux/PsychToolbox_Experiments/Simon
%      Resting_EEG           
%  
%       elseif select == 2
%      cd /home/cmi_linux/PsychToolbox_Experiments/Simon
%      VIDEO
%  elseif select == 3
%      cd /home/cmi_linux/PsychToolbox_Experiments/Simon
%      ContrastChangeDetect_2AFC_CMI_example_new
%      start_Contrast =questdlg('Would you like to start the actual task?');
%      if start_Contrast =='Yes';
%      ContrastChangeDetect_2AFC_CMI_new
%      end
%  elseif select == 4
%      cd /home/cmi_linux/PsychToolbox_Experiments/Simon
%      SurroundSupp4circCMI_new
%  elseif select == 5
%       cd /home/cmi_linux/PsychToolbox_Experiments/Simon
%      Explicit_Sequence_Learning_paradigm_visual_spatial_CMI_example
%      start_Learning =questdlg('Would you like to start the actual task?');
%      if start_Learning =='Yes';
%      Explicit_Sequence_Learning_paradigm_visual_spatial_CMI
%      end;
%  elseif select == 6
%      cd /home/cmi_linux/PsychToolbox_Experiments/Simon/psychoacoustics
%      MLP
%      elseif select == 7
%      cd /home/cmi_linux/PsychToolbox_Experiments/Simon
%      WISC_ProcessingSpeed_paradigm_example
%      start_Learning =questdlg('Would you like to start the actual task?');
%      if start_Learning =='Yes';
%      WISC_ProcessingSpeed_paradigm
%      end
%  end
%      