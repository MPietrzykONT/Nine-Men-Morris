classdef boardNMMClass < handle
    properties
        BoardState % 2D array representing the game board
        BoardFigure % Board figure handle
        BoardPlot % Board plot handle
        PlayerPieces % Array to hold Player pieces
        CurrentTurn % Indicates whose turn it is (1 or 2)
        Score % Array to hold scores for both players
        MaxPieces = 9; % Maximum pieces per player
        Phase % Current phase of the game (1 for placing, 2 for moving, 3 for mill)
        isEndOfPhase1 % Flag to signify end of Phase 1 and to never come back to it
        adjacencyList % List of adjacent positions
        isMovingX % X coordinate of piece to be moved
        isMovingY % Y coordinate of piece to be moved
        isMoving % Flag to signify if piece to be moved has been chosen
        AllowedPositions % Allowed positions for placing and moving pieces
        MoveX % Clicked X coordinate
        MoveY % Clicked Y coordinate
        isGameOver % Check if game is still going on
    end

    methods
        function obj = boardNMMClass()
            obj.BoardState = zeros(7, 7); % Initialize a 7x7 board
            obj.PlayerPieces = zeros(2, obj.MaxPieces); % Initialize Player pieces
            obj.CurrentTurn = 1; % Start with Player 1
            obj.Score = [0, 0]; % Initialize scores
            obj.Phase = 1; % Start in the placing phase
            obj.isEndOfPhase1 = false; % and keep it this way
            obj.isGameOver = false; % Game is running
            obj.isMoving = false; % Preparation for Phase 2
            

            % Define allowed positions
            obj.AllowedPositions = [1, 1; 1, 4; 1, 7; 4, 1; 4, 7; 7, 1; 7, 4; 7, 7;
                                                 2, 2; 2, 4; 2, 6; 4, 2; 4, 6; 6, 2; 6, 4; 6, 6;
                                                 3, 3; 3, 4; 3, 5; 4, 3; 4, 5; 5, 3; 5, 4; 5, 5];
            % Define adjacency for each position
            obj.adjacencyList = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.adjacencyList('1,1') = {[1, 4], [4, 1]}; % Corner
            obj.adjacencyList('1,4') = {[1, 1], [1, 7], [2, 4]}; % Edge
            obj.adjacencyList('1,7') = {[1, 4], [4, 7]}; % Corner
            obj.adjacencyList('4,1') = {[1, 1], [4, 2], [7, 1]}; % Edge
            obj.adjacencyList('4,7') = {[4, 6], [1, 7], [7, 7]}; % Edge
            obj.adjacencyList('7,1') = {[4, 1], [7, 4]}; % Corner
            obj.adjacencyList('7,4') = {[7, 1], [7, 7], [6, 4]}; % Edge
            obj.adjacencyList('7,7') = {[7, 4], [4, 7]}; % Corner
            obj.adjacencyList('2,2') = {[2, 4], [4, 2]}; % Corner
            obj.adjacencyList('2,4') = {[1, 4], [2, 2], [2, 6], [3, 4]}; % Edge
            obj.adjacencyList('2,6') = {[2, 4], [4, 6]}; % Corner
            obj.adjacencyList('4,2') = {[2, 2], [4, 1], [4, 3], [6, 2]}; % Edge
            obj.adjacencyList('4,6') = {[4, 5], [2, 6], [6, 6], [4, 7]}; % Edge
            obj.adjacencyList('6,2') = {[4, 2], [6, 4]}; % Corner
            obj.adjacencyList('6,4') = {[6, 2], [6, 6], [5, 4], [7, 4]}; % Edge
            obj.adjacencyList('6,6') = {[6, 4], [4, 6]}; % Corner
            obj.adjacencyList('3,3') = {[3, 4], [4, 3]}; % Corner
            obj.adjacencyList('3,4') = {[3, 3], [3, 5], [2, 4]}; % Edge
            obj.adjacencyList('3,5') = {[3, 4], [4, 5]}; % Corner
            obj.adjacencyList('4,3') = {[3, 3], [4, 2], [5, 3]}; % Edge
            obj.adjacencyList('4,5') = {[4, 6], [3, 5], [5, 5]}; % Edge
            obj.adjacencyList('5,3') = {[4, 3], [5, 4]}; % Corner
            obj.adjacencyList('5,4') = {[5, 3], [5, 5], [6, 4]}; % Edge
            obj.adjacencyList('5,5') = {[5, 4], [4, 5]}; % Corner

            obj = obj.initialDraw(); % Initiate the visualization
        end

        %% Main game function that runs the game
        function obj = gameRun(obj)
            if ~obj.isGameOver % While game is not over
                switch obj.Phase 
                    case 1 % Phase 1 is placing pieces
                        obj = obj.placePiece(obj.MoveX,obj.MoveY); % Place the piece
                       
                        % Check if the current player has formed a mill
                        if obj.checkForMill(obj.CurrentTurn,obj.MoveX,obj.MoveY)
                            % Change Phase flag to mill
                            obj.Phase = 3;
                            obj.refreshBoard();
                            return
                        end
        
                        % Check for end of phase
                        if sum(obj.PlayerPieces,"all") == obj.MaxPieces*2
                            obj.Phase = 2; % Switch to moving phase
                            obj.isEndOfPhase1 = true;
                            disp('All pieces have been placed. Now entering the moving phase.');
                        end
                        obj.CurrentTurn = 3- obj.CurrentTurn;

                    case 2 % Phase 2 is movement
                        if obj.isMoving
                            if obj.isValidMove(obj.isMovingX, obj.isMovingY, obj.MoveX, obj.MoveY)
                                obj = obj.makeMove(obj.isMovingX, obj.isMovingY, obj.MoveX,obj.MoveY);
                                obj.isMoving = false;
        
                                % Check if the current player has formed a mill
                                if obj.checkForMill(obj.CurrentTurn,obj.MoveX,obj.MoveY)
                                    % Change Phase flag to mill
                                    obj.Phase = 3;
                                    obj.refreshBoard();
                                    return
                                end
                            else
                                fprintf('Invalid selection. Please select a valid position to move to.\n');
                                return; % Exit if the selection is invalid
                            end
                        else
                            % Check if the selected piece is valid to move
                            if obj.BoardState(obj.MoveX,obj.MoveY) == obj.CurrentTurn
                                if obj.isValidMove(obj.MoveX, obj.MoveY)
                                    obj.isMovingX = obj.MoveX;
                                    obj.isMovingY = obj.MoveY;
                                    obj.isMoving = true;
                                    return;
                                else
                                    fprintf('Invalid selection. Please select a valid piece to move.\n');
                                    return; % Exit if the selection is invalid
                                end
                            else
                                fprintf('Invalid selection. Please select a valid piece to move.\n');
                                return; % Exit if the selection is invalid
                            end
                        end
                        obj.CurrentTurn = 3- obj.CurrentTurn;

                    case 3 % Phase 3 is mill
                        % Get the positions of the opponent's pieces assuming 1 and 2
                        % in BoardState are player pieces
            
                        opponentPieces = obj.BoardState == 3 - obj.CurrentTurn; 
                        if isempty(opponentPieces)
                            disp('No opponent pieces to remove.');
                            if obj.isEndOfPhase1
                                obj.Phase = 2;
                            else
                                obj.Phase = 1;
                            end
                            return; % No pieces to remove
                        end
    
                        % Validate the selection
                        if obj.BoardState(obj.MoveX,obj.MoveY) == 3- obj.CurrentTurn
                            if ~obj.checkForMill(3-obj.CurrentTurn, obj.MoveX, obj.MoveY)
                                % Remove the piece from the board
                                obj.BoardState(obj.MoveX,obj.MoveY) = 0; % Assuming 0 means empty
                                
                                % Check for losing condition
                                if obj.isEndOfPhase1 && sum(opponentPieces,'all') < 3
                                    fprintf('Player %d has lost the game!',3-obj.CurrentTurn);
                                    obj.isGameOver = true;
                                    obj.Score(:,obj.CurrentTurn) =+ 1;
                                    obj.displayScore();
                                else
                                    % Come back to correct Phase
                                    if obj.isEndOfPhase1
                                        obj.Phase = 2;
                                    else
                                        obj.Phase = 1;
                                    end
                                    obj.CurrentTurn = 3- obj.CurrentTurn;
                                end
                            else
                                disp('Invalid selection. Please choose a valid piece.');
                                return % Invalid piece chosen, don't change anything
                            end
                        else
                            disp('Invalid selection. Please choose a valid piece.');
                            return % Invalid piece chosen, don't change anything
                        end
                end
                obj = obj.refreshBoard();
            else
                obj.resetGame();
            end
        end
        
        %% Placing pieces
        function obj = placePiece(obj, row, col)
            if obj.Phase == 1
                % Placing phase
                if ismember([row, col], obj.AllowedPositions, 'rows') % Check if the cell is allowed
                    if obj.BoardState(row, col) == 0 % Check if the cell is empty
                        if obj.CurrentTurn == 1 && sum(obj.PlayerPieces(obj.CurrentTurn,:)) < obj.MaxPieces
                            obj.BoardState(row, col) = obj.CurrentTurn; % Place Player 1's piece
                            obj.PlayerPieces(obj.CurrentTurn,sum(obj.PlayerPieces(obj.CurrentTurn,:))+1) = 1; % Mark piece as used
                        elseif obj.CurrentTurn == 2 && sum(obj.PlayerPieces(obj.CurrentTurn,:)) < obj.MaxPieces
                            obj.BoardState(row, col) = obj.CurrentTurn; % Place Player 2's piece
                            obj.PlayerPieces(obj.CurrentTurn,sum(obj.PlayerPieces(obj.CurrentTurn,:))+1) = 1; % Mark piece as used
                        else
                            disp('All pieces have been placed.');
                        end
                    else
                        disp('Cell is already occupied. Choose another cell.');
                    end
                else
                    disp('Invalid position. Choose from allowed positions.');
                end
            else
                disp('Invalid game phase.');
            end
        end
        
        %% Making moves
        function obj = makeMove(obj, moveFromX, moveFromY, moveToX, moveToY)
           if obj.Phase == 2
                % Moving phase
                % Check the number of pieces left for the current player
                piecesLeft = sum(obj.BoardState(:) == obj.CurrentTurn);
            
                % If the player has only 3 pieces left, allow movement to any unoccupied position
                if piecesLeft == 3
                    if obj.BoardState(moveToX, moveToY) ~= 0
                        disp('Invalid move: Cannot move to an occupied position.');
                        return;
                    end
                else
                    if ismember([moveToX, moveToY], obj.AllowedPositions, 'rows') % Check if the target cell is allowed
                        if obj.BoardState(moveToX, moveToY) == 0 % Check if the target cell is empty
                            obj.BoardState(moveToX, moveToY) = obj.CurrentTurn; % Move the piece
                            obj.BoardState(moveFromX, moveFromY) = 0; % Clear the old position
                        else
                            disp('Target cell is already occupied.');
                            return;
                        end
                    else
                        disp('Invalid position. Choose from allowed positions.');
                        return;
                    end
                end
            else
                error('Invalid game phase.');
           end
         end

        function hasMill = checkForMill(obj, player, recentMoveX, recentMoveY)
            % Check if the player has a mill based on their positions
            % player: player number
        
            % Check if the player has less than 3 pieces
            playerPiecesCount = nnz(obj.BoardState == player);
            if playerPiecesCount < 3 && obj.Phase ~= 3
                hasMill = false;
                return; % Cannot form a mill with less than 3 pieces
            end
                
            % Define the winning combinations (mills)
            mills = [
                1, 1, 1, 4, 1, 7;  % Row 1
                2, 2, 2, 4, 2, 6;  % Row 2
                3, 3, 3, 4, 3, 5;  % Row 3
                4, 1, 4, 2, 4, 3;  % Row 4 (first set)
                4, 5, 4, 6, 4, 7;  % Row 4 (second set)
                5, 3, 5, 4, 5, 5;  % Row 5
                6, 2, 6, 4, 6, 6;  % Row 6
                7, 1, 7, 4, 7, 7;  % Row 7

                1, 1, 4, 1, 7, 1;  % Column 1
                2, 2, 4, 2, 6, 2;  % Column 2
                3, 3, 4, 3, 5, 3;  % Column 3
                1, 4, 2, 4, 3, 4;  % Column 4 (first set)
                5, 4, 6, 4, 7, 4;  % Column 4 (second set)
                3, 5, 4, 5, 5, 5;  % Column 5
                2, 6, 4, 6, 6, 6;  % Column 6
                1, 7, 4, 7, 7, 7];  % Column 7

                % Get player positions
                playerPositions = find(obj.BoardState == player);
                playerPositions = arrayfun(@(x) [mod(x-1, 7) + 1, floor((x-1) / 7) + 1], playerPositions, 'UniformOutput', false);
                playerPositions = vertcat(playerPositions{:});

                % Check for a mill
                hasMill = false;

                for i = 1:size(mills, 1)
                    millPositions = mills(i, :);
                    % Check if the recent move is part of the current mill
                    if ismember([recentMoveX, recentMoveY], reshape(millPositions, 2, [])', 'rows') && ...
                       all(ismember(reshape(millPositions, 2, [])', playerPositions, 'rows'))
                        hasMill = true;
                        break;
                    end
                end
        end

        function valid = isValidMove(obj, startRow, startCol, targetRow, targetCol)
            % Check the number of input arguments
            if nargin == 3
                % If only 3 arguments are provided, assume checking if
                % adjacent positions are empty
                startKey = sprintf('%d,%d', startRow, startCol);

                % Check if there are empty adjacent positions to the chosen piece
                valid = any(cellfun(@(x) obj.BoardState(x(1), x(2)) == 0, obj.adjacencyList(startKey)));
            else
                if sum(obj.BoardState(:) == obj.CurrentTurn) > 3
                    valid = true;
                else
                    % Check if the target position is in the adjacency list of the start position
                    startKey = sprintf('%d,%d', startRow, startCol);
                    targetKey = [targetRow, targetCol];
                
                    if isKey(obj.adjacencyList, startKey)
                        valid = any(cellfun(@(x) isequal(x, targetKey), obj.adjacencyList(startKey)));
                    else
                        valid = false; % Invalid start position
                    end
                end
            end
        end

        function obj = initialDraw(obj)
            obj.BoardFigure = figure;
            obj.BoardFigure.Name="Nine Man's Morris";
            
            hold on
            % Draw the positions
            obj.BoardPlot = plot(obj.AllowedPositions(:,1),obj.AllowedPositions(:,2),'ko','MarkerSize',20,'MarkerFaceColor', '#808080');
            set(obj.BoardPlot,'ButtonDownFcn', @(src,event) obj.onClick(src,event));
            
            % Draw the lines connecting the points
            lineCoordinatesX = [1, 1, 7, 7, 1];
            lineCoordinatesY = [1, 7, 7, 1, 1];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');
            
            lineCoordinatesX = [2, 2, 6, 6, 2];
            lineCoordinatesY = [2, 6, 6, 2, 2];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');
            
            lineCoordinatesX = [3, 3, 5, 5, 3];
            lineCoordinatesY = [3, 5, 5, 3, 3];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');
            
            % Connecting lines
            lineCoordinatesX = [3, 1, 1, 4, 4, 5, 5, 7, 7, 4, 4];
            lineCoordinatesY = [4, 4, 1, 1, 3, 3, 4, 4, 7, 7, 5];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');
            
            hold off

            title(sprintf('Current Turn: Player %d, place your piece', obj.CurrentTurn), 'Position', [4, 8]);
            
            axis off;
            axis equal
            xlim([0 9])
            ylim([0 9])
        end

        function obj = refreshBoard(obj)
            cla(obj.BoardPlot)
            hold on;
        
            % Draw the positions
            obj.BoardPlot = plot(obj.AllowedPositions(:,1),obj.AllowedPositions(:,2),'ko','MarkerSize',20,'MarkerFaceColor', '#808080');
            set(obj.BoardPlot,'ButtonDownFcn', @(src,event) obj.onClick(src,event));

            % Draw current pieces on the board
            for row = 1:size(obj.BoardState, 1)
                for col = 1:size(obj.BoardState, 2)
                    if obj.BoardState(row, col) == 1
                        obj.BoardPlot = plot(row, col, 'ro', 'MarkerSize', 20, 'MarkerFaceColor', 'r'); % Player 1's piece
                        set(obj.BoardPlot,'ButtonDownFcn', @(src,event) obj.onClick(src,event));
                    elseif obj.BoardState(row, col) == 2
                        obj.BoardPlot = plot(row, col, 'bo', 'MarkerSize', 20, 'MarkerFaceColor', 'b'); % Player 2's piece
                        set(obj.BoardPlot,'ButtonDownFcn', @(src,event) obj.onClick(src,event));
                    end
                end
            end

            % Draw the lines connecting the points
            lineCoordinatesX = [1, 1, 7, 7, 1];
            lineCoordinatesY = [1, 7, 7, 1, 1];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');
            
            lineCoordinatesX = [2, 2, 6, 6, 2];
            lineCoordinatesY = [2, 6, 6, 2, 2];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');
            
            lineCoordinatesX = [3, 3, 5, 5, 3];
            lineCoordinatesY = [3, 5, 5, 3, 3];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');
            
            % Connecting lines
            lineCoordinatesX = [3, 1, 1, 4, 4, 5, 5, 7, 7, 4, 4];
            lineCoordinatesY = [4, 4, 1, 1, 3, 3, 4, 4, 7, 7, 5];
            obj.BoardPlot = line(lineCoordinatesX,lineCoordinatesY,'Color','w');

            hold off;
        
            % Set the title and axis properties
            switch obj.Phase
                case 1
                    title(sprintf('Current Turn: Player %d, place your piece', obj.CurrentTurn), 'Position', [4, 8]);
                case 2
                    title(sprintf('Current Turn: Player %d, move your piece', obj.CurrentTurn), 'Position', [4, 8]);
                case 3
                    title(sprintf('Player %d has mill, choose opponent piece to remove', obj.CurrentTurn), 'Position', [4, 8]);
            end
        end

        function obj = resetGame(obj)
            % Reset the game state for a new game
            obj.BoardState = zeros(7, 7);
            obj.PlayerPieces = zeros(2, obj.MaxPieces);
            obj.CurrentTurn = 1;
            obj.Phase = 1;
            obj.initialDraw();
        end

        function displayScore(obj)
            fprintf('Player 1 Score: %d\n', obj.Score(1));
            fprintf('Player 2 Score: %d\n', obj.Score(2));
        end

        function obj = onClick(obj, ~, event)
            obj.MoveX = event.IntersectionPoint(1);
            obj.MoveY = event.IntersectionPoint(2);
            obj = obj.gameRun();
        end

    end
end