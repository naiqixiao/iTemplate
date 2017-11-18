Image = imread('Template.png');

X = 1:size(Image, 2);

X = repmat(X, size(Image, 1), 1);

Y = 1:size(Image, 1);

Y = Y';

Y = repmat(Y, 1, size(Image, 2));


XY = FixationData{:, {'Xtf', 'Ytf', 'Duration'}};

XY = round(XY);

%XY(:, 3) = XY(:, 3);

clear density

density = zeros(size(Image, 1), size(Image, 2));
 
for j = 1:size(XY, 1)


    if (XY(j, 2) > 0 & XY(j, 2) <= size(Image, 1) &...
            XY(j, 1) > 0 & XY(j, 1) <= size(Image, 2))

        density(XY(j, 2), XY(j, 1)) = density(XY(j, 2), XY(j, 1)) + XY(j, 3)/1000;

    end
    
end

h = fspecial('gaussian', 5, 5);

HeatMap = imfilter(density, h, 'replicate');


surf(X, Y, HeatMap, 'LineStyle', 'none', 'FaceAlpha', 0.4)
hold on
imshow(Image)
hold off
colormap jet