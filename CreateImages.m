% this is for creating face images and registered ones.
% also with fixations.

for i = 1: size(newImages(:, 1), 1)
    
    imwrite(newImages{i, 2}, newImages{i, 1});
    
end

imshow(newImages{1, 2})

X = [AllLandmarks{1, 2}; [1 1; 640 1; 1 480; 640 480]];
Tris = delaunayTriangulation(X);


imshow(BackgroundImages{1, 2})
hold on

triplot(Tris.ConnectivityList, X(:, 1), X(:, 2))
scatter(X(:, 1), X(:, 2), 40, 'blue', 'o');
scatter(X(:, 1), X(:, 2), 50, 'r', '+');
hold off

imshow(newImages{1, 2})

hold on

%triplot(Tris.ConnectivityList, Y(:, 1), Y(:, 2))
scatter(Y(:, 1), Y(:, 2), 40, 'blue', 'o');
scatter(Y(:, 1), Y(:, 2), 50, 'r', '+');
hold off



imshow(BackgroundImages{1, 2})
hold on


scatter(FixO(:, 1), FixO(:, 2), 50, 'r', '.');
hold off


imshow(newImages{1, 2})
hold on

scatter(FixTF(:, 1), FixTF(:, 2), 50, 'r', '.');
hold off