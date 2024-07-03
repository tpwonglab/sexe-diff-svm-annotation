function appendSpecialRowToCsv(csvFileName, rowData, mouseID)
    fid = fopen(csvFileName, 'a');
    fprintf(fid, '%s, ', mouseID);
    for i = 1:length(rowData)
        for j = 1:length(rowData(i, :))
            value = rowData(i, j);
            if value > 0
                fprintf(fid, '%s, ', rowData(i, j));
            else
                fprintf(fid, '%s, ', "0");
            end
        end
    end
    fprintf(fid, '\n');
    fclose(fid);
end