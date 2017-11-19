% Vector field representation of fixation transformation

Fixation = Fixation(Fixation(:, 1) > 0, :);

x = zscore(Fixation(:, 3));
% x = x .* 1920 / range(x);
y = zscore(Fixation(:, 4));
% y = y .* 1080 / range(y);
u = zscore(Fixation(:, 1));
% u = u .* 491  / range(u);
v = zscore(Fixation(:, 2));
% v = v .* 657 / range(v);

figure('Position', [0 0 491 657]); 
quiver(x, y, u - x, v - y, 'LineWidth', 1)
title('Vector field representation of fixation transformation')
set(gca,'Ydir','reverse')
set(gca,'xtick',[])
set(gca,'ytick',[])


