function mycb(point_number, fixedAllLandmarks, handles)

if strcmp(get(handles.Button_SaveLMs, 'enable'), 'off')
    
    set(handles.Button_SaveLMs, 'enable', 'on');
    
end
%
%     %     ms = randi(10,1);
%     %
%     %     if mod(ms, 10) == 1
%     %
%     fixedFaceLocation = fixedAllLandmarks(end - 3:end, :);
%
%     axes(handles.axes1);
%     imshow(handles.fix, 'Parent', handles.axes1);
%
%     %zoom(handles.axes1, 'on')
%
%     xlim([min(fixedFaceLocation(:, 1)) - 30, max(fixedFaceLocation(:, 1)) + 30])
%     ylim([min(fixedFaceLocation(:, 2)) - 30, max(fixedFaceLocation(:, 2)) + 30])
%
%     %         switch point_number
%     %
%     %         zoom(handles.axes1, 2)
%
%     hold on
%
%     if size(fixedAllLandmarks, 1) == 9
%
%         plot(fixedAllLandmarks(:, 1), fixedAllLandmarks(:, 2), '.y');
%         scatter(fixedAllLandmarks(:, 1), fixedAllLandmarks(:, 2), 40, 'green', 'o');
%         plot(fixedAllLandmarks(point_number, 1), fixedAllLandmarks(point_number, 2), '*y',...
%             'MarkerSize', 15);
%
%     else
%
%         plot(fixedAllLandmarks(handles.LMSelected, 1), fixedAllLandmarks(handles.LMSelected, 2), '.y');
%         scatter(fixedAllLandmarks(handles.LMSelected, 1), fixedAllLandmarks(handles.LMSelected, 2), 40, 'green', 'o');
%         plot(fixedAllLandmarks(point_number, 1), fixedAllLandmarks(point_number, 2), '*y',...
%             'MarkerSize', 15);
%     end
%
%     hold off

%    end

end