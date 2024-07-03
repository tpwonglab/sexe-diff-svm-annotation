function createCsvIfNotExist(csvFileName, columnNames)
    if exist(csvFileName, 'file') ~= 2
        fid = fopen(csvFileName, 'w');
        for i = 1:length(columnNames) - 1
            fprintf(fid, '%s,', columnNames{i});
        end
        fprintf(fid, '%s\n', columnNames{end});
        fclose(fid);
    end
end