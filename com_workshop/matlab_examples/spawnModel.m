function spawnModel(modelName,xml,x,y,z,roll,pitch,yaw,useSDF,deleteSvc,spawnModelSvc)
global qeaSimStarted;
if nargin < 6
    roll = 0;
    pitch = 0;
    yaw = 0;
end
if nargin < 9
    useSDF = false;
end
if ismac
    docker_bin = '/usr/local/bin/docker';
elseif ispc || isunix
    docker_bin = 'docker';
end
if ismac || ispc || size(qeaSimStarted,1)
    % In Docker on Mac this hangs until you delete the model from the gzweb GUI
    % Workaround based this issue
    % (https://answers.gazebosim.org/question/24982/delete_model-hangs-for-several-mins-after-repeated-additionsdeletions-of-a-sdf-model-which-sometimes-entirely-vanishes-from-the-scene-too-in-gazebo/)
    system([docker_bin,' exec neato gz model -m ',modelName,' -d']);
    % Not sure why, but this 'pause' seems necessary
    pause(3);
else
    old_ld_library_path = getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH', ['/usr/lib/x86_64-linux-gnu:',getenv('LD_LIBRARY_PATH')]);
    system(['gz model -m ',modelName,' -d']);
    setenv('LD_LIBRARY_PATH',old_ld_library_path);
    pause(3);
end
if nargin < 11
    if useSDF
        spawnModelSvc = rossvcclient('/gazebo/spawn_sdf_model');
    else
        spawnModelSvc = rossvcclient('/gazebo/spawn_urdf_model');
    end
end

msg = rosmessage(spawnModelSvc);
msg.ModelName = modelName;
msg.ModelXml = xml;

msg.InitialPose.Position.X = x;
msg.InitialPose.Position.Y = y;
msg.InitialPose.Position.Z = z;

quat = eul2quat([yaw pitch roll]);
msg.InitialPose.Orientation.W = quat(1);
msg.InitialPose.Orientation.X = quat(2);
msg.InitialPose.Orientation.Y = quat(3);
msg.InitialPose.Orientation.Z = quat(4);
call(spawnModelSvc, msg)
if nargin < 11
    clear spawnModelSvc;
end
end