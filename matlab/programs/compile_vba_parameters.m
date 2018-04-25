function parameter_table=compile_vba_parameters(vba_data_dir)
%Given a directory load in the individual vba files and pull all paramteres
%into a table

%Grab the data
mat_files = glob([vba_data_dir '.mat']);
if isempty(mat_files), mat_files = glob([vba_data_dir filesep '*.mat']); end

parameter_table = table();

%Initialize empty arrays to store all parameters
subj_id = [];
mu_theta = [];
mu_phi = [];

for mat_file = mat_files'
    load(mat_file{:}, 'posterior'); %should load only posterior
    
    %Pull the ids
    id_tmp=regexp(mat_file{:}, '[0-9]{4,6}','match'); %This expression might have to become an input argument...
    id_tmp=id_tmp{:};
    subj_id = [subj_id; str2double(id_tmp)];

    %Compile evolution funciton parameters
    mu_theta = concat_param(mu_theta, posterior.muTheta);
    %mu_theta = [mu_theta; posterior.muTheta'];
    
    %Compile observation function parameters
    mu_phi = concat_param(mu_phi, posterior.muPhi);
    %mu_phi = [mu_phi; posterior.muPhi'];
    
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

function param_out = concat_param(param_in, params_to_concat)
cols = @(x) size(x,2);
params_diff = cols(param_in)-length(params_to_concat);
if params_diff>0 && ~isempty(param_in)
    params_to_concat = [params_to_concat; nan(params_diff,1)];
end

param_out = [param_in; params_to_concat'];
    