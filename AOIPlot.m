function AOIPlot(AOI)

if any(strcmp(AOI(:, 3), 'Ellipse'))

    AOIEllipseC = AOI(find(strcmp(AOI(:, 3), 'Ellipse')), :);

    for i = 1:size(AOIEllipseC, 1)

        rectangle('Position', AOIEllipseC{i, 1}, 'Curvature', [1,1], ...
            'LineWidth', 2, 'EdgeColor', 'c');

    end

end

if any(strcmp(AOI(:, 3), 'Rectangle'))

    AOIRectC = AOI(find(strcmp(AOI(:, 3), 'Rectangle')), :);

    for i = 1:size(AOIRectC, 1)

        rectangle('Position', AOIRectC{i, 1}, ...
            'LineWidth', 2, 'EdgeColor', 'c')

    end

end

if any(strcmp(AOI(:, 3), 'Polygon'))

    AOIPolyC = AOI(find(strcmp(AOI(:, 3), 'Polygon')), :);

    for i = 1:size(AOIPolyC, 1)

        AOIPolyC{i, 1} = [AOIPolyC{i, 1}; AOIPolyC{i, 1}(1, :)];
        
        line(AOIPolyC{i, 1}(:, 1), AOIPolyC{i, 1}(:, 2), ...
            'LineWidth', 2, 'Color', 'c')      

    end

end




