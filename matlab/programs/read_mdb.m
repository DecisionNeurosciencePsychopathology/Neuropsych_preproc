function out = read_mdb(DBName, TableName)
% Takes in an MS Access Database name and table name and returns a dataset

s=['PROVIDER=MSDASQL;'];
s=[s 'DRIVER=fMicrosoft Access Driver (*.accdb)g;'];
s=[s 'DBQ=' DBName ';'];

% Timeout if connection to DB can't be made in 60s
try
    cn=COM.OWC11_DataSourceControl_11;
catch
    cn=COM.OWC10_DataSourceControl_10;
end

cn.ConnectionString=s;
cn.Connection.CommandTimeout=60;
cn.RecordsetType=1;

% Limit rows returned to 20,000
sql=strcat('select top 20000 * from', TableName);
r = cn.connection.invoke('execute', sql);

if r.state && r.recordcount>0
    x=invoke(r,'getrows');
    x=x';
else
    x=[];
end

invoke(r,'release');
out = x;

return