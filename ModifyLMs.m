function AllLandmarksC = ModifyLMs(CurrentImage, AllLandmarksC, fixedLandmarks, handles.axes1, handles.axes2)

    axes(handles.axes2);
    imshow(CurrentImage);
    
    x = cell(size(AllLandmarksC, 1), 1);

    for i = 1:size(AllLandmarksC, 1)

        x{i, 1} = impoint(gca, AllLandmarksC(i, :));

        addNewPositionCallback(x{i, 1}, @(pos) mycb(x{i, 1},pos, i, fixedLandmarks, handles.axes1));

        x{i, 1}.setString(i);

    end

AllLandmarksC = cellfun(@(y) getPosition(y), x, 'UniformOutput', false);
