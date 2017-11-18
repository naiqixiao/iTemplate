switch PresentationOption
    
    case 'No fixation'
        
        axes(handles.axes1);
        
        imshow(handles.fix);
        
    case 'Fixations'
        
        axes(handles.axes1);
        
        imshow(handles.fix);
        xlim manual
        
        hold on
        
        plot(FixationData{:, 'Xtf'}, FixationData{:, 'Ytf'}, '.b');
        
        hold off
        
    case 'HeatMap - All Stimuli'
        
        axes(handles.axes1);
        
        imshow(handles.fix);
        
        FixationIndex = ones(size(FixationData, 1), 1);
        [FixHM LongestFixation] = Heatmap_Fixation(FixationIndex,...
            FixationData, handles.fix, 'all', handles.BlurRatio);
        
        hold on
        
        X = imagesc(FixHM);
        colormap(handles.axes1, 'jet');
        
        hold off
        
        set(X, 'AlphaData', FixHM ./ max(FixHM(:)));
        
        c = colorbar('Ticks',[0:max(FixHM(:))/4: max(FixHM(:))],...
            'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
            'FontSize', 6);
        
        c.Label.String = 'Fixation duration (ms)';
        
        c.Label.FontSize = 8;
        
end
