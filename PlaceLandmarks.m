function[AllLandmarks, fixedAllLandmarks, FaceLocation] = PlaceLandmarks(moving, fix, fixedAllLandmarks, fixedFaceLocation)

    % get the sizes of fixed and current images
    
    movingWidth = size(moving, 2);
    movingHeight = size(moving, 1);
    
    fixWidth = size(fix, 2);
    fixHeight = size(fix, 1);
    
    %% calculate the image size difference between the reference and moving images.
    
    WRatio = movingWidth / fixWidth;
    HRatio = movingHeight / fixHeight;
    
    %% locate the face
    
    FaceLocation = fixedFaceLocation * [WRatio, 0; 0, HRatio];

    [FaceLocation fixedFaceLocation] = cpselect(moving, fix, FaceLocation, fixedFaceLocation, 'wait', true);
     
    %% generate facial feature points
    TF = fitgeotrans(FaceLocation, fixedFaceLocation, 'affine');
         
    AllLandmarks = transformPointsInverse(TF, fixedAllLandmarks);
     
    %%
    
    [AllLandmarks fixedAllLandmarks] = cpselect(moving, fix, AllLandmarks, fixedAllLandmarks, 'wait', true);
    
end