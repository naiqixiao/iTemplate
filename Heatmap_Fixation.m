function [HeatMap LongestFixation] = Heatmap_Fixation(index, FixationData, Image, type, ratio)

h = fspecial('gaussian', floor(100/ratio), floor(15/ratio^.5));

id = unique(FixationData.ParticipantName);
n = numel(id);

stimuli = unique(FixationData.Stimuli);
ns = numel(stimuli);

switch type
    
    case 'org' % original fixations
    
        XY = FixationData{index, {'X', 'Y', 'Duration'}};
        
%         h = fspecial('gaussian', [40, 40], 15);
    
    case 'tf' % transformed fixations
    
        XY = FixationData{index, {'Xtf', 'Ytf', 'Duration'}};
        
%         h = fspecial('gaussian', [40, 40], 15);
    
    case 'all' % all transformed fixations
        
        XY = FixationData{:, {'Xtf', 'Ytf', 'Duration'}};
        
        n = n * ns;
%         h = fspecial('gaussian', [30, 30], 12.5);
    
end

XY = round(XY);

%XY(:, 3) = XY(:, 3);

clear density

density = zeros(size(Image, 1), size(Image, 2));
 
for j = 1:size(XY, 1)


    if (XY(j, 2) > 0 && XY(j, 2) <= size(Image, 1) &&...
            XY(j, 1) > 0 && XY(j, 1) <= size(Image, 2))

        density(XY(j, 2), XY(j, 1)) = density(XY(j, 2), XY(j, 1)) + XY(j, 3);

    end


end

density = density ./ n;

HeatMap = imgaussfilt(density, 6, 'Padding', 'circular');

% HeatMap = imfilter(density, h, 'replicate');

LongestFixation = max(XY(:, 3));

end