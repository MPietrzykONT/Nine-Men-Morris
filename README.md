# Nine Men Morris in MATLAB

## Project overview
The goal of the project is to create a MATLAB implementation of Nine Men Morris game that allows the player to compete against an AI opponent. All aspects of the game are to be prepared in MATLAB including game logic, AI opponent and GUI.

## Features
### Game logic
Game logic has been created by prompting MATLAB Copilot for specific aspects of the game and then implementing those snippets into the script. Those aspects include: board visualization, placing pieces, moving pieces, checking for mills (3 in a row), removing pieces, validating moves, and gameover logic. Estimating 70% of code and logic comes from MATLAB Copilot.

### To be added/implemented
1. Code cleanup - creating the project via MATLAB Copilot over multiple sessions has inadvertently introduced code that might use some general refactoring.
2. AI opponent - this has to be done in 2 phases:
   Phase 1: Training a Deep Learning model to play this implementation of the game and play it well
   Phase 2: Change the code to implement an AI opponent
3. Better GUI - currently there's only basic info in the plot title, this could be improved with more GUI elements and move history

## Getting started
### Prerequisites
So far no additional Toolboxes are needed to run the game. Project is created with MATLAB R2025a.

### Installation
1. Clone the repository: git clone https://github.com/MPietrzykONT/Nine-Men-Morris.git
2. Navigate to the project directory:cd Nine-Men-Morris
3. Open MATLAB and add the project directory to the path: addpath(genpath('path_to_project_directory'))

### Usage
1. Open project file in MATLAB
2. Run boardNMMClass

### License
The license is available in license.txt file in this GitHub repository.

Copyright 2025 Oprogramowanie Naukowo-Techniczne Sp. z o. o.


