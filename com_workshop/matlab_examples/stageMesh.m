function meshBoatSTLURI = stageMesh(stlFileName)
    [~, modelName, ~] = fileparts(stlFileName);
    meshBoatSTLURI = ['model://',modelName,'/meshes/',stlFileName];
    if ismac || ispc
        % we are running through docker.  Eventually we will use
        % docker cp to sync the files to models directory and the
        % gzweb directory
        modelFolderPath = fullfile('GazeboStaging',modelName);
        system(['/usr/local/bin/docker cp ',modelFolderPath,' neato:/root/.gazebo/models']);
        system(['/usr/local/bin/docker cp ',modelFolderPath,' neato:/root/gzweb/http/client/assets']);
    else
        % this is when we are running outside of Docker
        mkdir(fullfile('~','.gazebo'));
        mkdir(fullfile('~','.gazebo','models'));
        copyfile(fullfile('./GazeboStaging',modelName),fullfile('~','.gazebo','models',modelName));
    end
end