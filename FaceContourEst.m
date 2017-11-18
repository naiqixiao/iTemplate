function[P] = FaceContourEst(points)

    left = points(:, 1) == min(points(:, 1));
    right = points(:, 1) == max(points(:, 1));
    up = points(:, 2) == min(points(:, 2));
    down = points(:, 2) == max(points(:, 2));

    Xc = mean(points(up | down, 1));
    Yc = mean(points(left | right, 2));

    a = pdist(points(up | down, :),'euclidean')/2;
    b = pdist(points(left | right, :),'euclidean')/2;
    
    angle = atan2(points(down, 2) - points(up, 2), points(down, 1) - points(up, 1));
    
    contour = [];
    
    Angles = [30 60 120 150 210 240 300 330];
    
    for i = 1:8
        
        k = Angles(i);
        
        x = Xc + a * cos(k/180 * pi) * cos(angle) - b * sin(k/180 * pi) * sin(angle);
        y = Yc + a * cos(k/180 * pi) * sin(angle) + b * sin(k/180 * pi) * cos(angle);
        
        contour(i, :) = [x y];
        
    end
    
    
    P = contour;


end






