function SaveCSV(fileName, TableData)

    Header = TableData.Properties.VariableNames;
    
    h = waitbar(0, {'Data is exporting.'; 'Please wait....'});

    k = table2cell(TableData);
    
    [nrows, ncols] = size(k);
    %% generate the coloumn format
    format = [];

    for i = 1:ncols

        if isstr(k{1, i})

            format = [format '%s,'];

        elseif isinteger(k{1, i})

            format = [format '%i,'];

        elseif isfloat(k{1, i})

            format = [format '%10.2f,'];
            
        elseif islogical(k{1, i})

            format = [format '%i,'];

        else
            
            format = [format '%s,'];
            
        end

    end

    format = format(1: size(format, 2) - 1);
    format = [format '\n'];

    %% write data

    Data = fopen(fileName, 'w');
    
    % write header
    fprintf(Data,[sprintf(['%s,'], Header{1, 1:ncols-1}) Header{1, ncols} '\n']);
    
    for i = 1:nrows

        fprintf(Data, sprintf(format, k{i, :}));
        waitbar(i/nrows, h)

    end

    close(h)
    
    fclose(Data);
    
end

