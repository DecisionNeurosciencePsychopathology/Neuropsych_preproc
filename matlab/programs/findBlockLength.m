function b=findBlockLength(b,str)
%Will use expect script to find subject specific block length for specific
%run

%Args:
%b (struct containing a lot of data for regressor generation)
%str (cell containing Thorndike paths to motion censor file)
    %ex '/Volumes/bek/explore/MR_Proc/id/shark_proc/shark1/'


%Needs to have b.total_blocks as a field - check for this...

fprintf('Logging into Thorndike now....\n')

%How many runs
for run = 1:b.total_blocks
    %set command string
    %cmd_str = sprintf('"c:/kod/CogEmoFaceReward/aux_scripts/expectTest.exp %s %s"', num2str(b.id),num2str(run));
    cmd_str = sprintf('"E:/Users/wilsonj3/workspace/aux_scripts/grabVolumes.exp %s"', str{run});
    %set cygwin path string
    cygwin_path_sting = 'E:\cygwin\bin\bash --login -c ';
    %Run it kick out if failed
    fprintf('Grabbing volumes....\n')
    [status,cmd_out]=system([cygwin_path_sting cmd_str]);
    if status==1
        error('Connection to Thorndike failed :(')
    end
    %Grab the volume number
    reg_out = regexp(cmd_out,'(?<=wc -l\s+)[0-9]{3,4}','match');
    %Make reg out a number
    b.block_length(run)=str2double(reg_out{1});
end