function x = PointsEst(fixedAllLandmarks, TrisEST, TFMatrixEST)

    fixedAllLandmarks(:, 3) = 1;
    
    %TrisEST.Points = fixedFaceLocationRef;
    
    fixedAllLandmarks(:, 4) = pointLocation(TrisEST, fixedAllLandmarks(:, 1), fixedAllLandmarks(:, 2));
    
    x = cell(size(fixedAllLandmarks, 1), 1);
    
    for i = 1:size(fixedAllLandmarks, 1)
            
        x{i, 1} = mrdivide(fixedAllLandmarks(i, [1 2 3]), TFMatrixEST{fixedAllLandmarks(i, 4), 3});    
        
    end
    
    x = cell2mat(x);
    
    x = x(:, [1 2]);
    
end