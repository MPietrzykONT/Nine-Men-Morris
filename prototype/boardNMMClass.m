classdef boardNMMClass < handle
    properties
        BoardState % 2D array representing the game board
        BoardFigure % Board figure handle
        BoardPlot % Board plot handle
        Player1Pieces % Array to hold Player 1's pieces
        Player2Pieces % Array to hold Player 2's pieces
        CurrentTurn % Indicates whose turn it is (1 or 2)
        Score % Array to hold scores for both players
        MaxPieces = 9; % Maximum pieces per player
        Phase % Current phase of the game (1 for placing, 2 for moving)
        AllowedPositions % Allowed positions for placing and moving pieces
        MoveX % Clicked X coordinate
        MoveY % Clicked Y coordinate
        isGameOver % Check if game is still going on
    end

    methods
        function obj = boardNMMClass()
            obj.BoardState = zeros(7, 7); % Initialize a 7x7 board
            obj.Player1Pieces = zeros(1, obj.MaxPieces); % Initialize Player 1's pieces
            obj.Player2Pieces = zeros(1, obj.MaxPieces); % Initialize Player 2's pieces
            obj.CurrentTurn = 1; % Start with Player 1
            obj.Score = [0, 0]; % Initialize scores
            obj.Phase = 1; % Start in the placing phase
            obj.isGameOver = false; % Game is running

            % Define allowed positions
            obj.AllowedPositions = [1, 1; 1, 4; 1, 7; 4, 1; 4, 7; 7, 1; 7, 4; 7, 7;
                                                 2, 2; 2, 4; 2, 6; 4, 2; 4, 6; 6, 2; 6, 4; 6, 6;
                                                 3, 3; 3, 4; 3, 5; 4, 3; 4, 5; 5, 3; 5, 4; 5, 5];

            obj = obj.initialDraw(); % Initiate the visualization
        end

        %% Main game function that runs the game
        function obj = gameRun(obj)
            if ~obj.isGameOver % While game is not over
                if obj.Phase == 1 % Phase 1 is placing pieces
                    obj = obj.placePiece(obj.MoveX,obj.MoveY); % Place the piece
                   
                    % Check if the current player has formed a mill
                    if obj.checkForMill(obj.CurrentTurn)
                        % Prompt the player to remove an opponent's piece
                        obj = obj.removeOpponentPiece();
                    end
    
                    % Check for end of phase
                    pieces = sum(obj.Player1Pieces) + sum(obj.Player2Pieces);
                    if pieces == obj.MaxPieces*2
                        obj.Phase = 2; % Switch to moving phase
                        disp('All pieces have been placed. Now entering the moving phase.');
                    end
                elseif obj.Phase == 2 % Phase 2 is movement
                    obj = obj.makeMove(obj.MoveX,obj.MoveY);
                end
                obj = obj.refreshBoard();
            else
                displayScore(obj)
                obj.resetGame();
            end
        end
        
        %% Placing pieces
        function obj = placePiece(obj, row, col)
            if obj.Phase == 1
                % Placing phase
                if ismember([row, col], obj.AllowedPositions, 'rows') % Check if the cell is allowed
                    if obj.BoardState(row, col) == 0 % Check if the cell is empty
                        if obj.CurrentTurn == 1 && sum(obj.Player1Pieces) <= obj.MaxPieces
                            obj.BoardState(row, col) = obj.CurrentTurn; % Place Player 1's piece
                            obj.Player1Pieces(sum(obj.Player1Pieces)+1) = 1; % Mark piece as used
                        elseif obj.CurrentTurn == 2 && sum(obj.Player2Pieces) <= obj.MaxPieces
                            obj.BoardState(row, col) = obj.CurrentTurn; % Place Player 2's piece
                            obj.Player2Pieces(sum(obj.Player2Pieces)+1) = 1; % Mark piece as used
                        else
                            error('All pieces have been placed.');
                        end
                    else
                        error('Cell is already occupied. Choose another cell.');
                    end
                else
                    error('Invalid position. Choose from allowed positions.');
                end
            else
                error('Invalid game phase.');
            end
            % Switch turns
            obj.CurrentTurn = 3 - obj.CurrentTurn;
            obj = obj.refreshBoard();
        end
        
        %% Making moves
        function obj = makeMove(obj, row, col)
           if obj.Phase == 2
                % Moving phase
                % Check the number of pieces left for the current player
                piecesLeft = sum(obj.BoardState(:) == obj.CurrentTurn);
            
                % If the player has only 3 pieces left, allow movement to any unoccupied position
                if piecesLeft == 3
                    if obj.BoardState(row, col) ~= 0
                        disp('Invalid move: Cannot move to an occupied position.');
                        return;
                    end
                else
                    if ismember([row, col], obj.AllowedPositions, 'rows') % Check if the target cell is allowed
                        if obj.BoardState(row, col) == 0 % Check if the target cell is empty
                            % Find the piece to move
                            [r, c] = find(obj.BoardState == obj.CurrentTurn, 1); % Find the first piece of the current player
                            if ~isempty(r)
                                if obj.isValidMove(r, c, row, col) % Check if the move is valid
                                    obj.BoardState(row, col) = obj.CurrentTurn; % Move the piece
                                    obj.BoardState(r, c) = 0; % Clear the old position
                                else
                                    error('Invalid move. You can only move to connected non-occupied positions.');
                                end
                            else
                                error('No pieces to move.');
                            end
                        else
                            error('Target cell is already occupied.');
                        end
                    else
                        error('Invalid position. Choose from allowed positions.');
                    end
                end
                % Check the number of pieces left for both players
                player1Pieces = nnz(obj.BoardState(:) == 1);
                player2Pieces = nnz(obj.BoardState(:) == 2);
            
                % Check for losing condition
                if player1Pieces <= 2
                    disp('Player 1 has lost the game!');
                    return; % End the game
                elseif player2Pieces <= 2
                    disp('Player 2 has lost the game!');
                    return; % End the game
                end

                % Check if the current player has formed a mill
                if obj.checkForMill(obj.CurrentTurn)
                    % Prompt the player to remove an opponent's piece
                    obj = obj.removeOpponentPiece();
                end
            else
                error('Invalid game phase.');
           end
            % Switch turns
            obj.CurrentTurn = 3 - obj.CurrentTurn; 
       end

        function hasMill = checkForMill(obj, player)
            hasMill = false;
            % Check rows and columns for mills
            for row = 1:size(obj.BoardState, 1)
                if sum(obj.BoardState(row, :) == player) == 3
                    hasMill = true;
                    return;
                end
                if sum(obj.BoardState(:, row) == player) == 3
                    hasMill = true;
                    return;
                end
            end
        end

        function obj = removeOpponentPiece(obj)
            % Get the positions of the opponent's pieces assuming 1 and 2
            % in BoardState are player pieces
            opponentPieces = find(obj.BoardState == 3 - obj.CurrentTurn); 
            if isempty(opponentPieces)
                disp('No opponent pieces to remove.');
                return; % No pieces to remove
            end
        
            % Loop until a valid piece is selected
            validSelection = false;
            while ~validSelection
                pieceIndex = input('Select the index of the piece to remove: ');
        
                % Validate the selection
                if pieceIndex >= 1 && pieceIndex <= length(opponentPieces)
                    validSelection = true; % Valid index selected
                else
                    disp('Invalid selection. Please choose a valid index.');
                end
            end
        
            % Get the selected piece's position
            selectedPiece = opponentPieces(pieceIndex);
            [removeRow, removeCol] = ind2sub(size(obj.BoardState), selectedPiece);
        
            % Remove the piece from the board
            obj.BoardState(removeRow, removeCol) = 0; % Assuming 0 means empty
        
            % Notify the player
            fprintf('Removed opponent piece at Row %d, Column %d.\n', removeRow, removeCol);
        end

        function valid = isValidMove(startRow, startCol, targetRow, targetCol)
            % Define adjacency for each position
            adjacencyList = containers.Map('KeyType', 'char', 'ValueType', 'any');
            adjacencyList('1,1') = {[1, 4], [4, 1]}; % Corner
            adjacencyList('1,4') = {[1, 1], [1, 7], [4, 4]}; % Edge
            adjacencyList('1,7') = {[1, 4], [4, 7]}; % Corner
            adjacencyList('4,1') = {[1, 1], [4, 4], [7, 1]}; % Edge
            adjacencyList('4,4') = {[1, 4], [4, 1], [4, 7], [7, 4]}; % Center
            adjacencyList('4,7') = {[4, 4], [1, 7], [7, 7]}; % Edge
            adjacencyList('7,1') = {[4, 1], [7, 4]}; % Corner
            adjacencyList('7,4') = {[7, 1], [7, 7], [4, 4]}; % Edge
            adjacencyList('7,7') = {[7, 4], [4, 7]}; % Corner
            adjacencyList('2,2') = {[2, 4], [4, 2]}; % Edge
            adjacencyList('2,4') = {[2, 2], [2, 6], [4, 4]}; % Edge
            adjacencyList('2,6') = {[2, 4], [4, 6]}; % Edge
            adjacencyList('4,2') = {[2, 2], [4, 4], [6, 2]}; % Edge
            adjacencyList('4,6') = {[4, 4], [2, 6], [6, 6]}; % Edge
            adjacencyList('6,2') = {[4, 2], [6, 4]}; % Edge
            adjacencyList('6,4') = {[6, 2], [6, 6], [4, 4]}; % Edge
            adjacencyList('6,6') = {[6, 4], [4, 6]}; % Edge
            adjacencyList('3,3') = {[3, 4], [4, 3]}; % Edge
            adjacencyList('3,4') = {[3, 3], [3, 5], [4, 4]}; % Edge
            adjacencyList('3,5') = {[3, 4], [4, 5]}; % Edge
            adjacencyList('4,3') = {[3, 3], [4, 4], [5, 3]}; % Edge
            adjacencyList('4,5') = {[4, 4], [3, 5], [5, 5]}; % Edge
            adjacencyList('5,3') = {[4, 3], [5, 4]}; % Edge
            adjacencyList('5,4') = {[5, 3], [5, 5], [4, 4]}; % Edge
            adjacencyList('5,5') = {[5, 4], [4, 5]}; % Edge
        
            % Check if the target position is in the adjacency list of the start position
            startKey = sprintf('%d,%d', startRow, startCol);
            targetKey = sprintf('%d,%d', targetRow, targetCol);
        
            if isKey(adjacencyList, startKey)
                validMovesFromStart = adjacencyList(startKey);
                valid = any(cellfun(@(x) isequal(x, targetKey), validMovesFromStart));
            else
                valid = false; % Invalid start position
            end
        end

        function obj = updateScore(obj)
            % Example scoring logic (modify as needed)
            obj.Score(obj.CurrentTurn) = obj.Score(obj.CurrentTurn) + 1;
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

            title(sprintf('Current Turn: Player %d', obj.CurrentTurn), 'Position', [4, 8]);
            
            axis off;
            axis equal
            xlim([0 9])
            ylim([0 9])
        end

        function obj = refreshBoard(obj)
            hold on;
        
            % Draw current pieces on the board
            for row = 1:size(obj.BoardState, 1)
                for col = 1:size(obj.BoardState, 2)
                    if obj.BoardState(row, col) == 1
                        obj.BoardPlot = plot(row, col, 'ro', 'MarkerSize', 20, 'MarkerFaceColor', 'r'); % Player 1's piece
                    elseif obj.BoardState(row, col) == 2
                        obj.BoardPlot = plot(row, col, 'bo', 'MarkerSize', 20, 'MarkerFaceColor', 'b'); % Player 2's piece
                    end
                end
            end

            hold off;
        
            % Set the title and axis properties
            title(sprintf('Current Turn: Player %d', obj.CurrentTurn), 'Position', [4, 8]);
        end

        function obj = resetGame(obj)
            % Reset the game state for a new game
            obj.BoardState = zeros(7, 7);
            obj.Player1Pieces = zeros(1, obj.MaxPieces);
            obj.Player2Pieces = zeros(1, obj.MaxPieces);
            obj.CurrentTurn = 1;
            obj.Score = [0, 0];
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