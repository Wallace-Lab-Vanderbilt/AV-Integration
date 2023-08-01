clear all


HideCursor;
%enter subjects information
subjID = input('Subject ID (e.g., 01xyz): ','s');
data.subjID = str2num(subjID);

sex = 'm';
if data.subjID > 50
    sex = 'f';
end
%sex = input('Subject sex (m or f): ','s');
data.sex=sex;

age = input('Subject age: ','s');
data.age = str2num(age);

date = date;
%input('Date (year-month-day): ','s');
data.date = date;
%str2num(date);

%create order 
offsets = [50];
%offsets = [150 100 50 0 0 0 0 0 0 -50 -100 -150];
trials = 12;
maxTrials = length(offsets)*trials;
order(1:maxTrials,1) = 3;
for i = 1:length(offsets)
    order(i*trials - trials+1:i*trials,2) = offsets(i);
    if offsets(i) == 0
        order(i*trials - trials+1:i*trials,3) = 0;
    elseif offsets(i) > 0
        order(i*trials - trials+1:i*trials,3) = 1;
    elseif offsets(i) < 0
        order(i*trials - trials+1:i*trials,3) = 2;
    end
end

%randomize trial orders
newOrder=randperm(maxTrials);
for i=1:maxTrials
    stimOrder(i,:)=order(newOrder(i),:);
end
clear newOrder order
data.stimOrder=stimOrder;
data.stimOrder_guide.Column1= 'modality: 1=A, 2=V, 3=AV';
data.stimOrder_guide.Column2 = 'temporal offset, + is VA, negative is AV';
data.stimOrder_guide.Column3 = 'order, 0 = sync, 1 = V first, 2 = A first';

%create file name to save
repeat=1;
while 1
    fname=sprintf('%s%sDATA%s%s_2AFCpercSync_%d.mat',pwd,filesep,filesep,subjID,repeat);
    if exist(fname)==2,
        repeat=repeat+1;
    else
        break;
    end
end



[outRect hz win0 rect0 cWhite0 cBlack0 cGrey0 scr0]= OpenStandardScreen;

%load files: stimuli, fixation; % stimulus RECT
stimSize=476;
stimRect = [1 1 stimSize stimSize];
rectS=CenterRect([1 1 stimSize stimSize],rect0);
load fixation
cross = Screen('MakeTexture',win0,fixation);
load ring
flash = Screen('MakeTexture',win0,ring);


%feedback
load feedbackcolor
cor = Screen('MakeTexture',win0,correct);
incor = Screen('MakeTexture',win0,incorrect);

%allTrials(trial, modality, stimlevel, stimulus, onset time, word time,
%offset time, response, corect response, mark)
allTrials=zeros(1,10);

% create responses
allKeys='12';
fused = '1';
unfused = '2';



key='';
while 1,
    %wait Screen
    oldtextsize=Screen('TextSize',win0,20);
    Screen('DrawText',win0,'You will be presented with a visual flash and an auditory beep.',50,50,cWhite0);
    Screen('DrawText',win0,'Your task will be to judge whether the flash and beep',50,100,cWhite0);
        Screen('DrawText',win0,'came at the same time.',50,125,cWhite0);
    Screen('DrawText',win0,'If they were synchronous, at the same time, press 1.',50,200,cWhite0);
    Screen('DrawText',win0,'If they were asynchronous, at different times, press 2.',50,250,cWhite0);
    Screen('DrawText',win0,'Press the spacebar to continue.',50,450,cWhite0);
    Screen('Flip',win0);
    if CharAvail
        key=GetChar;
    end
    if findstr(key,' '),
        break;
    end;
end
key='';
while 1

    %wait Screen
    oldtextsize=Screen('TextSize',win0,20)
    Screen('DrawText',win0,'If you make a correct response, a blue-green check will appear.',50,50,cWhite0);
    Screen('DrawText',win0,'If you make an incorrect response, a red X will appear.',50,100,cWhite0);
    Screen('DrawText',win0,'Press the spacebar to continue.',50,450,cWhite0);
    Screen('Flip',win0);
    if CharAvail
        key=GetChar;
    end
    if findstr(key,' '),
        break;
    end;
end

%%%Begin experiment
  tic;

  Screen('FillRect',win0,0, rect0);
  Screen('CopyWindow', cross, win0, stimRect, rectS)
  Screen('Flip',win0);
  
  ans=0;
  trial=1;
  
  while trial<=maxTrials
   
Fs = 10000;
InitializePsychSound;
pahandle = PsychPortAudio('Open', [], [], 0, Fs, 1);
beep=MakeBeep(1800,0.010,Fs);
PsychPortAudio('FillBuffer', pahandle, beep);   
      
      
      
      
      %TAKE A BREAK EVERY 100 TRIALS
      if trial > 1
          if mod(trial,100) == 0
              Screen('DrawText',win0,'Take a break if needed. Press the spacebar to continue.',50,450,cWhite0);
              Screen('Flip',win0);
              
              key='';
              while 1,
                  key=GetChar;
                  if findstr(key,' '),
                      break;
                  end;
              end
          end
      end
     
      FlushEvents('keydown');
      % update variable allTrials with next trials info
      allTrials(trial,1)=trial;
      allTrials(trial,2)=stimOrder(trial,1);
      allTrials(trial,3)=stimOrder(trial,2);
      allTrials(trial,4)=stimOrder(trial,3);
      
      %find correct answer for upcomming trial
      corAns(trial) = 2;
      if stimOrder(trial,2) == 0;
          corAns(trial) = 1;
      end
      allTrials(trial,11)=corAns(trial);
      data.responses(trial,1)=corAns(trial);
      
     
      
      % put up ready Screen
      Screen('CopyWindow', cross, win0, stimRect, rectS)
      Screen('Flip',win0);
      
      WaitSecs(.5+rand);
      
      Priority(2)
      
     
      
      FlushEvents('keydown');
      %Present Stimulus
      
      
      
      %Visual preceding Audio
      if stimOrder(trial,3)== 1
          delay = stimOrder(trial,2);
          numDelay = round(delay/hz); %hz is the framerate
          
          
          
          Screen('CopyWindow', flash, win0, stimRect, rectS)
          Screen('Flip',win0);
          timeV = toc;
          
         
          
          Screen('CopyWindow', cross, win0, stimRect, rectS)
          Screen('Flip',win0);
          WaitSecs(delay/1000-0.0045);%Screen('WaitBlanking',win0,numDelay)%numDelay is # frames to pause
          g=GetSecs;
          PsychPortAudio('Start', pahandle, 1, 0);
          h=GetSecs;
          
          timeA = toc;
          realDelay = (timeA-timeV)*1000;
          testtrials(trial,10)=h-g;
          
      end
      
      %Audio preceding Visual
      if stimOrder(trial,3)== 2
          delay = stimOrder(trial,2);
          numDelay = round(delay/hz); %hz is the framerate
          Screen('CopyWindow', cross, win0, stimRect, rectS)%make sure you are aligned with a refresh
          WaitSecs(.0055);
          PsychPortAudio('Start', pahandle, 1, 0);
          timeA = toc;
          Screen('Flip',win0);
          WaitSecs(abs(delay)/1000-.0065);%Screen('WaitBlanking',win0,numDelay)%numDelay is # frames to pause
          Screen('CopyWindow', flash, win0, stimRect, rectS)
          Screen('Flip',win0);
          timeV = toc;
          Screen('CopyWindow', cross, win0, stimRect, rectS)
          Screen('Flip',win0);
          realDelay = (timeA-timeV)*1000;
      end
      
      %AV synchronus
      if stimOrder(trial,3)== 0
          Screen('CopyWindow', cross, win0, stimRect, rectS)
          Screen('Flip',win0);
          PsychPortAudio('Start', pahandle, 1, 0);
          timeA = toc;
          WaitSecs(0.020);
          Screen('CopyWindow', flash, win0, stimRect, rectS)
          Screen('Flip',win0);
          timeV = toc;
          Screen('CopyWindow', cross, win0, stimRect, rectS)
          Screen('Flip',win0);
          realDelay = (timeA-timeV)*1000;
      end
      
      Priority(0)
      
      allTrials(trial,5)=timeA;
      allTrials(trial,6)=timeV;
      allTrials(trial,7)=realDelay;
      allTrials(trial,8) = allTrials(trial,7)-allTrials(trial,3);
      
      data.timing(trial,1)=allTrials(trial,5);
      data.timing(trial,2)=allTrials(trial,6);
      data.timing(trial,3)=allTrials(trial,7);
      
      %present response Screen
      WaitSecs(.25);
      Screen('CopyWindow', cross, win0, stimRect, rectS)
      Screen('DrawText',win0,'      same time = 1        different time = 2',outRect(3)/2-210,outRect(4)/2+50,cWhite0);
      Screen('Flip',win0);
      
      %collect response
      ans=0;
      while ans==0
          while CharAvail
              key=GetChar;
              %key = 'z';
              if key=='1'
                  T=toc;
                  allTrials(trial,9)=T;
                  ans(trial)=1;
                  allTrials(trial,12)=ans(trial);
                  if allTrials(trial,11)==allTrials(trial,12)
                      mark(trial)=1;
                  else
                      mark(trial)=0;
                  end
              elseif key=='2'
                  T=toc;
                  allTrials(trial,9)=T;
                  ans(trial)=2;
                  allTrials(trial,12)=ans(trial);
                  if allTrials(trial,11)==allTrials(trial,12)
                      mark(trial)=1;
                  else
                      mark(trial)=0;
                  end
              end
          end
      end
      
      allTrials(trial,10)=allTrials(trial,9)-min([allTrials(trial,5) allTrials(trial,6)]);
      
      data.responses(trial,2)=ans(trial);
      if allTrials(trial,11)==allTrials(trial,12)
          mark(trial)=1;
      else
          mark(trial)=0;
      end
      allTrials(trial,13)=mark(trial);
      data.responses(trial,3)=mark(trial);
      
      data.timing(trial,4)=allTrials(trial,9);
      
      
      if mark(trial) == 1
          Screen('CopyWindow', cor, win0, [1 1 476 476], rectS);
          Screen('Flip',win0);
      else
          Screen('CopyWindow', incor, win0, [1 1 476 476], rectS);
          Screen('Flip',win0);
      end
      WaitSecs(.5);
      Screen('CopyWindow', cross, win0, [1 1 476 476], rectS);
      Screen('Flip',win0);
      
      
      FlushEvents('keydown');
      
      data.allTrials=allTrials;
      
      save(fname,'data','allTrials');
      
      trial=trial+1;
  end
  
  Screen('FillRect',win0,160, rect0);
  Screen('DrawText',win0,'saving...',300,rect0(4)/2,0);
  Screen('Flip',win0);
  
  clear SF trim  trial key ans mark corAns rectS;
  
  save(fname);
  
  ShowCursor;
  
  Screen('FillRect',win0,0, rect0);
  Screen('DrawText',win0,'Thanks for your participation. Press spacebar to exit.',100,rect0(4)/2,255);
  Screen('Flip',win0);
  
  key='';
  while 1,
      key=GetChar;
      if findstr(key,' '),
          break;
      end;
  end
  
  Screen('CloseAll');
  
  for i = 1:length(offsets)
      accuracies(i,1) = offsets(i);
      I = find(allTrials(:,3) == offsets(i));
      accuracies(i,2) = 1-mean(allTrials(I,13));
  end
  figure(1);
  plot(accuracies(:,1), accuracies(:,2))
  
  for i = 1:ceil(length(accuracies(:,1))/2)
      avgAcc(i,1) = accuracies (i,1);
      avgAcc(i,2) = mean([accuracies(i,2) accuracies(length(accuracies(:,2))-i+1,2)]);
  end
  %figure(2);
  %plot(avgAcc(:,1), avgAcc(:,2))
  save(fname);
  
  graph = 'should peak in the middle'  