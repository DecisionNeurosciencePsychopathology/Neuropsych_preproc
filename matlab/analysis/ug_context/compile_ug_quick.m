files = {'context_master_data_frame.csv', 'baseline_master_data_frame.csv'};

remove_ids=[214710;
219944;
219392;
220889;
217008;
220330;
204015];

for file = files
   df=readtable(file{:}) ;
   remove_idx = ismember(df.id,remove_ids);
   df(remove_idx,:)=[];
   writetable(df,file{:})
end