function TFMatrix = CreateTFMatrices(movingAllLandmarks, fixedAllLandmarks, Tris, TFMatrix)

    Tris.Points = movingAllLandmarks;
    
    for i = 1:size(Tris.ConnectivityList, 1)

        M = movingAllLandmarks(Tris.ConnectivityList(i, :), :);
        F = fixedAllLandmarks(Tris.ConnectivityList(i, :), :);

        T1 = fitgeotrans(M, F, 'affine');

        TFMatrix{1, i, 2} = M;
        TFMatrix{1, i, 3} = T1.T;

    end

end