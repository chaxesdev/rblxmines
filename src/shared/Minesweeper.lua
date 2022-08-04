math.randomseed(tick())
tween = game:GetService("TweenService")
fastwait = require(game:GetService("ReplicatedStorage").FastWait)
tiles = require(game:GetService("ReplicatedStorage").Tiles)

--gameboard class
MinesweeperGame = {}
MinesweeperGame.__index = MinesweeperGame

function MinesweeperGame.new()
    local newGame = {}
    setmetatable(newGame, MinesweeperGame)
    newGame.Model = Instance.new("Model")
    newGame.Model.Parent = workspace

    return newGame
end

--generate a game with any size
function MinesweeperGame:Generate(size, mines, tileSize, pieceSize)
    assert(tileSize % pieceSize == 0)
    assert(size.x * size.y * size.z * (tileSize / pieceSize) <= 10000)

    self.Mines = {}
    self.Spaces = {}
    self.XSelectors = {}
    self.ZSelectors = {}
    self.XSelected = -1
    self.ZSelected = -1
    self.Splitting = false
    self.Status "Progress"
    self.Dimensions = size
    self.TileSize = tileSize
    self.PieceSize = pieceSize
    self.MineCount = mines
    self.Remaining = size.x * size.y * size.z - mines
    self.RemainingFlags = mines
    self.Flagged = 0

    local function isMine(x,y,z)
        for _, v in pairs(self.Mines) do
            if v.x == x and v.y == y and v.z == z then
                return true
            end
        end
        return false
    end

    --init random mines
    for i = 1, mines do
        local success = false
        while not success do
            local x = math.random(1, size.x)
            local y = math.random(1, size.y)
            local z = math.random(1, size.z)
            if isMine(x,y,z) then
                continue
            end
            self.Mines[i] = Vector3.new(x,y,z)
            success = true
        end
    end

    for i = 1, size.x do
        self.Spaces[i] = {}
        for j = 1, size.y do
            self.Spaces[i][j] = {}
            for k = 1, size.z do
                local space = nil
                if isMine(i, j, k) then
                    space = tiles.Mine(Vector3.new(i,j,k), tileSize, pieceSize)
                else
                    space = tiles.Number(Vector3.new(i,j,k), tileSize, pieceSize)
                end
                space.Model.Parent = self.Model
                self.Spaces[i][j][k] = space
            end
            fastwait()
        end
    end


