function newImage = CreateNewImage(moving, fix, AllLandmarksCT, Tris, TFMatrixC)

    Tris.Points = AllLandmarksCT;
     
    [X, Y] = meshgrid(1:size(moving, 2), 1:size(moving, 1));

    X = reshape(X, size(moving, 2) * size(moving, 1), 1);
    Y = reshape(Y, size(moving, 2) * size(moving, 1), 1);

    TriIndex = table(X, Y);

    TriIndex.TriangleIndex = pointLocation(Tris, X, Y); % new code
    
    TriIndex = sortrows(TriIndex,'TriangleIndex','ascend');

    func = @(X, Y) [X Y X./X];
   
    XXX = rowfun(func, TriIndex, 'GroupingVariables', 'TriangleIndex', 'OutputFormat', 'cell');
    
    C = cellfun(@mtimes, XXX, TFMatrixC(:, :, 3)', 'UniformOutput', false); % transformed coordinates
    
    C = cell2mat(C);
    
    TriIndex = TriIndex(TriIndex.TriangleIndex > 0, :);
    
    TriIndex.Xtf = C(:, 1);
    TriIndex.Ytf = C(:, 2);
    
    TriIndex = sortrows(TriIndex, {'X' 'Y'},'ascend');
    
    [X, Y] = meshgrid(1:size(fix, 2), 1:size(fix, 1));

    minX = min(AllLandmarksCT(:, 1));
    maxX = max(AllLandmarksCT(:, 1));
    minY = min(AllLandmarksCT(:, 2));
    maxY = max(AllLandmarksCT(:, 2));
    
    w = maxX - minX + 1;
    h = maxY - minY + 1;
    
    Xtf = reshape(TriIndex.Xtf, h, w);
    Ytf = reshape(TriIndex.Ytf, h, w);

    newImage = griddata(Xtf, Ytf, double(moving(minY:maxY, minX:maxX)), X, Y);

    newImage = uint8(newImage);

end