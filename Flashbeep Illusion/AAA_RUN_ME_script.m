clear all
Screen('Preference', 'SkipSyncTests', 1); 

InitializePsychSound;
% enter subjects information
subjID = input('Subject ID (e.g., 01xyz): ','s');
data.subjID = str2num(subjID);

sex = 'm';
if data.subjID > 40
    sex = 'f';
end
%sex = input('Subject sex (m or f): ','s');
data.sex=sex;

age = input('Subject age: ','s');
data.age = str2num(age);

date = date;
data.date = date;

%load and randomize trial orders
load order_shams
maxTrials = 275;
newOrder=randperm(maxTrials);
for i=1:maxTrials
    stimOrder(i,:)=order(newOrder(i),:);
end
clear newOrder order
data.stimOrder=stimOrder;
data.stimOrder_guide.Column1= 'number of flashes';
data.stimOrder_guide.Column2 = 'number of beeps';

%create file name to save
repeat=1;
while 1
    fname=sprintf('%s%sDATA%s%s_shams_post_%d.mat',pwd,filesep,filesep,subjID,repeat);
    if exist(fname)==2,
        repeat=repeat+1;
    else
        break;
    end
end

[outRect hz win0 rect0 cWhite0 cBlack0 cGrey0 scr0]= OpenScreenTwo;

%load files: stimuli, fixation; % stimulus RECT
stimSize=476;
rectS=CenterRect([1 1 stimSize stimSize],rect0);
load fixation
cross = Screen('MakeTexture',win0,fixation);
load ring
flash = Screen('MakeTexture',win0,ring);

%load audio files
load beeps

%allTrials(trial, modality, stimlevel, stimulus, onset time, word time,
%offset time, response, corect response, mark)
allTrials=zeros(1,10);

% create responses
allKeys='1234';

key='';
while 1,
    %wait screen
    Screen('DrawText',win0,'You will see anywhere from 1 to 4 visual flashes.',50,50,cWhite0);
    Screen('DrawText',win0,'Press the number of flashes you saw: 1, 2, 3, or 4.',50,100,cWhite0);
        Screen('DrawText',win0,'USE THE NUMBER PAD to press 1, 2, 3, or 4.',50,150,cWhite0);
    Screen('DrawText',win0,'Ignore the beeps.',50,200,cWhite0);
    Screen('DrawText',win0,'Press the spacebar to continue.',50,450,cWhite0);
    Screen('DrawText',win0,'Estimated time (275) = 7',50,550,cWhite0);
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
Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
Screen('Flip',win0);
HideCursor;

ans=0;
trial=1;

while trial<=50  % changed "maxTrials" to 50
    
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
    
    %find correct answer for upcomming trial
    corAns(trial) = stimOrder(trial,1);
    allTrials(trial,11)=corAns(trial);
    data.responses(trial,1)=corAns(trial);
    
    % put up ready screen
    Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
    Screen('Flip',win0);
    
    WaitSecs(.5+rand);
    
    %Present Stimulus
    FlushEvents('keydown');
    %beep following synchronous presentation
    if stimOrder(trial,2)> 0
        % choose beep with appropriate offset
        if stimOrder(trial,2) == 1;
            sound = beep_1;
        elseif stimOrder(trial,2) == 2;
            sound = beep_2;
        elseif stimOrder(trial,2) == 3;
            sound = beep_3;
        elseif stimOrder(trial,2) == 4;
            sound = beep_4;
        end
    end
    Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
    Screen('Flip',win0);
    if stimOrder(trial,2) > 0
        play(sound);
        timeA = toc;
    elseif stimOrder(trial,2) == 0
        timeA = 0;
    end
    %Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
    %Screen('Flip',win0);
    Screen('CopyWindow', flash, win0, [1 1 476 476], rectS)
    Screen('Flip',win0);
    timeV = toc;
    vTimes(trial,1) = timeV;
    Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
    Screen('Flip',win0);
    
    if stimOrder(trial,1) > 1
        WaitSecs(.03);
        Screen('CopyWindow', flash, win0, [1 1 476 476], rectS)
        Screen('Flip',win0);
        vTimes(trial,2) = toc-timeV;
        Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
        Screen('Flip',win0);
    end
    
    if stimOrder(trial,1) > 2
        WaitSecs(.03);
        Screen('CopyWindow', flash, win0, [1 1 476 476], rectS)
        Screen('Flip',win0);
        vTimes(trial,3) = toc-timeV-vTimes(trial,2);
        Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
        Screen('Flip',win0);
    end
    
    if stimOrder(trial,1) > 3
        WaitSecs(.03);
        Screen('CopyWindow', flash, win0, [1 1 476 476], rectS)
        Screen('Flip',win0);
        vTimes(trial,4) = toc-timeV-vTimes(trial,2)-vTimes(trial,3);
        Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
        Screen('Flip',win0);
    end
    
    realDelay = (timeA-timeV)*1000;
    
    allTrials(trial,5)=timeA;
    allTrials(trial,6)=timeV;
    allTrials(trial,7)=realDelay;
    allTrials(trial,8) = allTrials(trial,7)-allTrials(trial,3);
    
    data.timing(trial,1)=allTrials(trial,5);
    data.timing(trial,2)=allTrials(trial,6);
    data.timing(trial,3)=allTrials(trial,7);
    
    %present response screen
    WaitSecs(.25);
        Screen('CopyWindow', cross, win0, [1 1 476 476], rectS)
    Screen('DrawText',win0,'How many flashes did you see: 1, 2, 3, or 4?',190,350,cWhite0);
    Screen('Flip',win0);
    
    %collect response
    response = 0;
    while response == 0;
        if CharAvail
            key=GetChar;
            %key = '1';
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
                response = 1;
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
                response = 1;
            elseif key=='3'
                T=toc;
                allTrials(trial,9)=T;
                ans(trial)=3;
                allTrials(trial,12)=ans(trial);
                if allTrials(trial,11)==allTrials(trial,12)
                    mark(trial)=1;
                else
                    mark(trial)=0;
                end
                response = 1;
            elseif key=='4'
                T=toc;
                allTrials(trial,9)=T;
                ans(trial)=4;
                allTrials(trial,12)=ans(trial);
                if allTrials(trial,11)==allTrials(trial,12)
                    mark(trial)=1;
                else
                    mark(trial)=0;
                end
                response = 1;
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
    FlushEvents('keydown');
    
    data.allTrials=allTrials;
    
    save(fname,'data','allTrials');
    
    trial=trial+1;
end

Screen('FillRect',win0,160, rect0);
Screen('DrawText',win0,'saving...',300,rect0(4)/2,0);
Screen('Flip',win0);

clear SF trim  trial key ans mark corAns rectS ring fixation;

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

Screen('closeAll');

I = find(allTrials(:,2) ==1);
shamTrials = allTrials(I,:);
for i = 0:4
    accuracies(i+1,1) = i;
    J = find(shamTrials(:,3) == i);
    accuracies(i+1,2) = mean(shamTrials(J,12));
end
plot(accuracies(:,1), accuracies(:,2))

save(fname);

graph = 'should curve up as it goes right'