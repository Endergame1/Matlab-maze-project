fig=figure('Name','Robot Controller',...
    'Color',[0.15 0.15 0.15],...
    'MenuBar','none',...
    'ToolBar','none',...
    'NumberTitle','off',...
    'Position',[500,400,250,100],...
    'WindowKeyPressFcn',@keyPressHandler,...
    'WindowKeyReleaseFcn',@keyReleaseHandler);
fig.UserData=struct('allowKeyboard',true,'spacePressed',false,...
    'keys',struct('w',false,'a',false,'s',false,'d',false));
armAngle=45;
armUp=false;
lastCmd=[0 0];
while isvalid(fig)
    k=fig.UserData.keys; %keys pressed
    f=double(k.w)-double(k.s); %f=1 when w pressed -1 when s pressed
    t=double(k.a)-double(k.d); %t=1 when a pressed -1 when d pressed

    if fig.UserData.spacePressed
        fig.UserData.spacePressed=false; %doesnt allow space to be pressed more than once
        if armUp
            brick.MoveMotorAngleRel('C',30,-armAngle,'Brake'); %moves motor c with 30 speed 45 degrees down and then stops
        else
            brick.MoveMotorAngleRel('C',30,armAngle,'Brake'); %moves motor c with 30 speed 45 degrees up and then stops
        end
        armUp=~armUp;
    end

    if f~=0&&t~=0
        if t>0
            cmd=[100*f,40*f]; %move forward to right
        else
            cmd=[40*f,100*f]; %move forward to left
        end
    elseif f~=0
        cmd=[100*f,100*f]; % move forward
    elseif t~=0
        cmd=[70*t,-70*t]; %turn
    else
        cmd=[0 0]; %stop
    end

    if ~isequal(cmd,lastCmd) %if you are holding same keys nothing happens
        if cmd(1)==0
            brick.StopMotor('A');
            brick.StopMotor('B');
        else
            brick.MoveMotor('A',cmd(1));
            brick.MoveMotor('B',cmd(2));
        end
        lastCmd=cmd;
    end

    drawnow limitrate; %matlab updates window, and gets knew keyboard presses
    pause(0.02);
end

brick.StopMotor('A'); %once the window that is the controller is closed the motors automatically stop
brick.StopMotor('B');
brick.StopMotor('C');

function keyPressHandler(src,event)
    if ~src.UserData.allowKeyboard,return;end
    if strcmp(event.Key,'space')
        src.UserData.spacePressed=true;
    elseif isfield(src.UserData.keys,event.Key)
        src.UserData.keys.(event.Key)=true;
    end
end
function keyReleaseHandler(src,event)
    if ~src.UserData.allowKeyboard,return;end
    if isfield(src.UserData.keys,event.Key)
        src.UserData.keys.(event.Key)=false;
    end
end