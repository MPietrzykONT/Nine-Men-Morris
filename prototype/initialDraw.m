function [figHandle] = initialDraw()

figHandle = figure;
figHandle.Name="Nine Man's Morris";

positions = [1, 1; 1, 4; 1, 7; 4, 1; 4, 7; 7, 1; 7, 4; 7, 7; ... % Outer rim
             2, 2; 2, 4; 2, 6; 4, 2; 4, 6; 6, 2; 6, 4; 6, 6; ... % Middle rim
             3, 3; 3, 4; 3, 5; 4, 3; 4, 5; 5, 3; 5, 4; 5, 5]; % Inner rim

hold on

% Draw the positions
for i = 1:size(positions, 1)
    plot(positions(i, 1), positions(i, 2), 'ko', 'MarkerSize', 20, 'MarkerFaceColor', '#808080');
end

hold off

% Draw the lines connecting the points
lineCoordinatesX = [1, 1, 7, 7, 1];
lineCoordinatesY = [1, 7, 7, 1, 1];
line(lineCoordinatesX,lineCoordinatesY,'Color','w');

lineCoordinatesX = [2, 2, 6, 6, 2];
lineCoordinatesY = [2, 6, 6, 2, 2];
line(lineCoordinatesX,lineCoordinatesY,'Color','w');

lineCoordinatesX = [3, 3, 5, 5, 3];
lineCoordinatesY = [3, 5, 5, 3, 3];
line(lineCoordinatesX,lineCoordinatesY,'Color','w');

% Connecting lines
lineCoordinatesX = [3, 1, 1, 4, 4, 5, 5, 7, 7, 4, 4];
lineCoordinatesY = [4, 4, 1, 1, 3, 3, 4, 4, 7, 7, 5];
line(lineCoordinatesX,lineCoordinatesY,'Color','w');

title("Place your stone: Player 1","Position", [4, 8])

axis off;
axis equal
xlim([0 9])
ylim([0 9])

end

%[appendix]{"version":"1.0"}
%---
