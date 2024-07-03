function appendDefaultRowToCsv(csvFileName, rowData, mouseID)
    fid = fopen(csvFileName, 'a');
    fprintf(fid, '%s, ', mouseID);
    fprintf(fid, '%s, ', rowData(1));
    fprintf(fid, '%s\n', rowData(2));
    fclose(fid);
end