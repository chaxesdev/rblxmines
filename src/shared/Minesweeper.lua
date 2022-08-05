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
    assert(size.x > 0 and size.y > 0 and size.z > 0)
    assert(tileSize % pieceSize == 0)
    --10k brick limit
    assert(size.x * size.y * size.z * (tileSize / pieceSize) ^ 3 <= 10000)

    self.Mines = {}
    self.Spaces = {}
    self.XSelectors = {}
    self.ZSelectors = {}
    self.Events = {}
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
                space.Events.Click = space.Model.Click.ClickDetector.MouseClick:connect(function()
                    self:Select(i,j,k)
                end)
                space.Events.Flag = space.Model.Click.ClickDetector.RightMouseClick:connect(function()
                    self:Flag(i,j,k)
                end)
            end
            fastwait()
        end
    end

    if size.x ~= 1 and size.y ~= 1 and size.z ~= 1 then
        self:GenerateXDivs()
        self:GenerateZDivs()
    end

    for _, v in pairs(self.Mines) do
        local mineX, mineY, mineZ = v.x, v.y, v.z
        for i = math.max(1, mineX - 1), math.min(size.x, mineX + 1) do
            for j = math.max(1, mineY - 1), math.min(size.y, mineY + 1) do
                for k = math.max(1, mineZ - 1), math.min(size.z, mineZ + 1) do
                    local space = self.Spaces[i][j][k]
                    if not space.Mine then
                        space:UpdateNumber(space.Mines + 1)
                    end
                end
            end
        end
    end
    print("Generation complete")
end

function MinesweeperGame:GenerateXDivs()
    for i = 1, self.Dimensions.x - 1 do
        -- generate divider part
        local divider = Instance.new("Part")
        divider.Parent = self.Model
        divider.Name = "DividerX" .. i
        divider.Transparency = 1
        divider.CanCollide = false
        divider.Anchored = true
        divider.Size = Vector3.new(
            self.TileSize / 4,
            self.Dimensions.y * self.TileSize + 2,
            self.Dimensions.z * self.TileSize + 2)
        divider.Position = Vector3.new(
            (self.Spaces[i][1][1].Model.Base.Position.x + self.Spaces[i+1][1][1].Model.Base.Position.x) / 2,
            (self.Dimensions.y - 1) * self.TileSize / 2,
            (self.Dimensions.z - 1) * self.TileSize / 2)

        self.XSelectors[i] = divider

        --selection box
        local box = Instance.new("SelectionBox")
        box.Parent = divider
        box.Adornee = divider
        box.Color3 = Color3.fromRGB(0, 255, 255)
        box.Visible = false

        --click detector with events
        local click = Instance.new("ClickDetector")
        click.Parent = divider
        self.Events["Divider" .. i] = click.MouseClick:connect(function()
            if not self.Splitting then
                if self.ZSelected == -1 then
                    if self.XSelected == i then
                        self:SplitX(i, true)
                    elseif self.XSelected == -1 then
                        self:SplitX(i, false)
                    end
                end
            end
        end)
        self.Events["DividerHoverOverX" .. i] = click.MouseHoverEnter:connect(function()
            box.Visible = true
        end)
        self.Events["DividerHoverAwayX" .. i] = click.MouseHoverLeave:connect(function()
            box.Visible = false
        end)
    end
end

function MinesweeperGame:GenerateZDivs()
    for i = 1, self.Dimensions.z - 1 do
        --generate divider part
        local divider = Instance.new("Part")
        divider.Parent = self.Model
        divider.Name = "DividerZ" .. i
        divider.Transparency = 1
        divider.CanCollide = false
        divider.Anchored = true
        divider.Size = Vector3.new(
            self.Dimensions.x * self.TileSize + 2,
            self.Dimensions.y * self.TileSize + 2,
            self.TileSize / 4)
        divider.Position = Vector3.new(
            (self.Dimensions.x - 1) * self.TileSize / 2,
            (self.Dimensions.y - 1) * self.TileSize / 2,
            (self.Spaces[1][1][i].Model.Base.Position.z + self.Spaces[1][1][i+1].Model.Base.Position.z) / 2)

        self.ZSelectors[i] = divider

        --selection box
        local box = Instance.new("SelectionBox")
        box.Parent = divider
        box.Adornee = divider
        box.Color3 = Color3.fromRGB(0, 255, 255)
        box.Visible = false

        --click detector with events
        local click = Instance.new("ClickDetector")
        click.Parent = divider
        self.Events["Divider" .. i] = click.MouseClick:connect(function()
            if not self.Splitting then
                if self.XSelected == -1 then
                    if self.ZSelected == i then
                        self:SplitZ(i, true)
                    elseif self.ZSelected == -1 then
                        self:SplitZ(i, false)
                    end
                end
            end
        end)
        self.Events["DividerHoverOverZ" .. i] = click.MouseHoverEnter:connect(function()
            box.Visible = true
        end)
        self.Events["DividerHoverAwayZ" .. i] = click.MouseHoverLeave:connect(function()
            box.Visible = false
        end)
    end
end

function MinesweeperGame:Select(x,y,z)
    local space = self.Spaces[x][y][z]
    assert(space ~= nil)

    --do nothing if space is flagged
    if space.Flagged then
        return
    end

    --lose instantly if mine selected
    if space.Mine then
        self:Lose(x,y,z)
    else
        space.Marked = true
        --unbind and destroy all events in selected space
        for i, v in pairs(space.Events) do
            v:disconnect()
            space.Events[i] = nil
        end

        --destroy click part and its detector
        space.Model.Click:Destroy()
        space.Model.Pieces:Destroy()
        self.Remaining = self.Remaining - 1

        --win the game if no more spaces left
        if self.Remaining == 0 then
            self:Win()
        end
        
        --routine to clear adjacent spaces if 0-space selected
        if space.Mines == 0 then
            for i = math.max(1, x - 1), math.min(self.Dimensions.x, x + 1) do
                for j = math.max(1, y - 1), math.min(self.Dimensions.y, y + 1) do
                    for k = math.max(1, z - 1), math.min(self.Dimensions.z, z + 1) do
                        local chkSpace = self.Spaces[i][j][k]
                        if chkSpace ~= space and not chkSpace.Marked and not chkSpace.Mine and not chkSpace.Flagged then
                            self:Select(i,j,k)
                        end
                    end
                end
            end
        end
    end
end

function MinesweeperGame:Flag(x,y,z)
    local space = self.Spaces[x][y][z]
    --if flagged already, unflag
    if space.Flagged then
        space.Flagged = false
        for _, v in pairs(Enum.NormalId:GetNumItems()) do
            space.Model.Click["Flag" .. v.Name].Flag.Visible = false
        end
        self.RemainingFlags = self.RemainingFlags + 1
        --possibly remove this to not track flagged mines
        if space.Mine then
            self.Flagged = self.Flagged - 1
        end
    elseif self.RemainingFlags > 0 then
        space.Flagged = true
        for _, v in pairs(Enum.NormalId:GetNumItems()) do
            space.Model.Click["Flag" .. v.Name].Flag.Visible = true
        end
        self.RemainingFlags = self.RemainingFlags - 1
        --possibly remove this to not track flagged mines
        if space.Mine then
            self.Flagged = self.Flagged - 1
        end
    end
end

function MinesweeperGame:SplitX(x, undo)
    assert(x >= 1 and x <= self.Dimensions.x)
    --debounce so no other split may occur at the same time
    self.Splitting = true
    
    --if splitting
    if not undo then
        self.XSelected = x
        for _, v in pairs(self.ZSelectors) do
            v.Parent = nil
        end
        for i = 1, x do
            for j = 1, self.Dimensions.y do
                for k = 1, self.Dimensions.z do
                    local space = self.Spaces[i][j][k]
                    
