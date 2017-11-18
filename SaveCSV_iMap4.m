function SaveCSV(fileName, ProjectName, TableData)

    Header = TableData.Properties.VariableNames;
    
    h = waitbar(0, {'iMap4 data is exporting.';'Please wait....'});

    k = table2cell(TableData);
    
    [nrows, ncols] = size(k);
    %% generate the coloumn format, separat columns by a tab
    format = [];

    for i = 1:ncols

        if isstr(k{1, i})

            format = [format '%s '];

        elseif isinteger(k{1, i})

            format = [format '%i '];

        elseif isfloat(k{1, i})

            format = [format '%10.2f '];
            
        elseif islogical(k{1, i})

            format = [format '%i '];

        end  

    end

    %format = format(1: size(format, 2) - 1);
    %format = [format '\n'];

    %% write data
    
    % Save labels
    if exist(strcat(fileName, '/iMap4_', ProjectName), 'dir') == 0
       
        mkdir(strcat(fileName, '/iMap4_', ProjectName))
        
    end
    
    Data = fopen(strcat(strcat(fileName, '/iMap4_', ProjectName), '/label.txt'), 'w');
  
    
    for i = 1:numel(Header)

        fprintf(Data, [Header{1, i} '\n']);    

    end

    fclose(Data);

    % save data
    Data = fopen(strcat(strcat(fileName, '/iMap4_', ProjectName), '/data_subset.txt'), 'w');

    for i = 1:nrows

        fprintf(Data, [sprintf(format, k{i, :}) '\n']);
        
        waitbar(i/nrows, h)

    end

    close(h)
    
    fclose(Data);
    
end

