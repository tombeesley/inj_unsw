function convertCSV

for s = [1:4 6:12 14:28 30:32 34:38 40:81 83:87 92:99 101:103]
    s
    load(['Raw Data\',int2str(s), '_OUTPUT']);
    
    subName = sprintf('%03d',s);
    
    trial_ids = cell2mat(DATA.imagepair(1,1));
    exportName = ['CSV Data/' subName '_trial_ids.csv'];
    csvwrite(exportName,trial_ids');
        
    % fixation period
    e = DATA.fixEG;
    for t = 1:60
        ['sub_' int2str(s) '_fix_' int2str(t)]
        eg_data = squeeze(e(t,1));
        eg_data = double(cell2mat(eg_data));
        eg_data = eg_data(:,[7 8 20 21]);
        eg_data(:,5) = t;
        eg_data(:,6) = cell2mat(squeeze(e(t,2)));
        exportName = ['CSV Data/' subName '_EG_fix.csv'];
        dlmwrite(exportName,eg_data,'precision', '%i', '-append')
    end
    
    % stimulus period
    e = DATA.stimEG;
    for t = 1:60
        ['sub_' int2str(s) '_stim_' int2str(t)]
        eg_data = squeeze(e(t,1));
        eg_data = double(cell2mat(eg_data));
        eg_data = eg_data(:,[7 8 20 21]);
        eg_data(:,5) = t;
        eg_data(:,6) = cell2mat(squeeze(e(t,2)));
        exportName = ['CSV Data/' subName '_EG_stim.csv'];
        dlmwrite(exportName,eg_data,'precision', '%i', '-append')
    end
 
    
       
end