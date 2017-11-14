function parameter_table=compile_vba_parameters(vba_data_dir)
%Given a directory load in the individual vba files and pull all paramteres
%into a table

%Grab the data
mat_files = glob([vba_data_dir '/*.mat']);
parameter_table = table();

%Initialize empty arrays to store all parameters
subj_id = [];
mu_theta = [];
mu_phi = [];

for mat_file = mat_files'
    load(mat_file{:}); %should load out and posterior
    
    %Pull the ids
    id_tmp=regexp(mat_file{:}, '[0-9]{4,6}','match');
    id_tmp=id_tmp{:};
    subj_id = [subj_id; str2double(id_tmp)];

    %Compile evolution funciton parameters
    mu_theta = [mu_theta; posterior.muTheta'];
    
    %Compile observation function parameters
    mu_phi = [mu_phi; posterior.muPhi'];
    
end

%Create the columns for the table
[~,cols]=size(mu_theta);
theta_var_names=create_table_var_names('theta_param_',cols);

[~,cols]=size(mu_phi);
phi_var_names=create_table_var_names('phi_param_',cols);

%Compile all data into a table
parameter_table = array2table([subj_id mu_theta mu_phi],...
    'VariableNames',{'ID', theta_var_names{:}, phi_var_names{:}});

%Print out some basic stats for each set
summary(parameter_table)

function var_names=create_table_var_names(prefix,num_vars)
for i = 1:num_vars
    var_names{i} = [prefix num2str(i)];
end
