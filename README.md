This is my attempt at an implementation at Minesweeper in Roblox. It allows for the creation of a minesweeper game of any dimensions (in 3D), any number of mines, any tile size, and any piece size (i.e. a tile size of 2 and a piece size of 1 will create tiles with 8 1x1x1 cubes), allowing for messy explosions upon losing the game.

To create a minesweeper game, first create a new instance of `MinesweeperGame` by calling `MinesweeperGame.new(sizeX, sizeY, sizeZ, mines, tileSize, pieceSize)`. Then, you can (re)generate the actual gameboard at any time by calling `MinesweeperGame:Generate()`.

Tiles can either be left clicked to select the space, or right clicked to flag the space, after which it will not be possible to select the space until it is unflagged. The space between tiles is also clickable, allowing for the playing field to be split open between two faces for easier viewing of the inside of the playing field in 3D minesweeper games. The field can be put back together by clicking in between the two halves on the floor.

This game makes use of CloneTrooper1019's fastwait module.

TODO LIST:
* refactor code using Rojo
* optimize code and memory usage (!!!)
* minor improvements (disable splitting field in 2D games, maximum number of pieces that can be generated)
