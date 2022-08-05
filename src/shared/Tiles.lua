fastwait = require(game:GetService("ReplicatedStorage").FastWait)

--colors for mine count numbers
numColors = { 
    Color3.fromRGB(0,0,255), --1 
    Color3.fromRGB(0,255,0), --2 
    Color3.fromRGB(255,0,0), --3 
    Color3.fromRGB(0,0,127), --4 
    Color3.fromRGB(127,0,0), --5 
    Color3.fromRGB(64,224,208), --6 
    Color3.fromRGB(0,0,0), --7 
    Color3.fromRGB(80,80,80), --8 
    Color3.fromRGB(255,234,0), --9 
    Color3.fromRGB(255,0,255), --10
    Color3.fromRGB(175,250,170), --11
    Color3.fromRGB(149,87,41), --12
    Color3.fromRGB(157,197,187), --13
    Color3.fromRGB(86, 86, 187), --14
    Color3.fromRGB(174,255,0), --15
    Color3.fromRGB(255, 106, 0), --16
    Color3.fromRGB(255,0,198), --17
    Color3.fromRGB(181, 55, 0), --18
    Color3.fromRGB(213, 141, 109), --19
    Color3.fromRGB(255, 112, 247), --20
    Color3.fromRGB(182, 158, 131), --21
    Color3.fromRGB(197, 136, 45), --22
    Color3.fromRGB(52, 152, 219), --23
    Color3.fromRGB(170, 174, 63), --24
    Color3.fromRGB(255, 72, 85), --25
    Color3.fromRGB(246, 63, 238) --26   
}

Space = {}
Space.__index = Space

--update with 3d/2d
function Space.new(coords, tileSize, pieceSize)
    local newSpace = {}
    setmetatable(newSpace, Space)

    local x = coords.x
    local y = coords.y
    local z = coords.z

    --fixed values for space
    newSpace.Position = coords
    newSpace.Marked = false
    newSpace.Flagged = false
    newSpace.Mine = false
    newSpace.TileSize = tileSize
    newSpace.PieceSize = pieceSize

    --model for all parts of space
    newSpace.Model = Instance.new("Model")
    --newSpace.Model.Parent = workspace
    newSpace.Model.Name = "Space".. x .. "_" .. y .. "_" .. z

    --base of whole space
    local base = Instance.new("Part")
    base.Parent = newSpace.Model
    base.Size = Vector3.one * (0.9 * tileSize)
    base.Color = Color3.new(50,50,50)
    base.Anchored = true
    base.CanCollide = true
    base.CFrame = CFrame.new(
        (x-1) * tileSize,
        (y-1) * tileSize,
        (z-1) * tileSize)
    base.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    base.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
    base.Name = "Base"

    --cube for showing numbers on each side
    local labelPart = Instance.new("Part")
    labelPart.Parent = newSpace.Model
    labelPart.Size = Vector3.one * (0.9 * tileSize)
    labelPart.Transparency = 1
    labelPart.Anchored = true
    labelPart.CanCollide = false
    labelPart.CFrame = CFrame.new(
        (x-1) * tileSize,
        (y-1) * tileSize,
        (z-1) * tileSize)
    labelPart.Name = "Label"

    --textbox template for labelPart
    local text = Instance.new("TextBox")
    text.Size = UDim2.new(0, 100, 0, 100)
    text.TextColor3 = Color3.fromRGB(255, 0, 255)
    text.BackgroundTransparency = 1
    text.TextSize = 100
    text.Text = "X"
    text.Font = Enum.Font.SourceSans

    --create surfacegui and add text to each side of label cube
    for _,v in pairs(Enum.NormalId:GetEnumItems()) do
        local surface = Instance.new("SurfaceGui")
        surface.Parent = labelPart
        surface.Face = v
        surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
        surface.CanvasSize = Vector2.new(100, 100)
        surface.Name = v.Name

        local textClone = text:Clone()
        textClone.Parent = surface
    end

    --clickable cube of unit
    local clickPart = Instance.new("Part")
    clickPart.Parent = newSpace.Model
    clickPart.Size = Vector3.one * (1.05 * tileSize)
    clickPart.Anchored = true
    clickPart.CanCollide = false
    clickPart.CFrame = CFrame.new(
        (x-1) * tileSize,
        (y-1) * tileSize,
        (z-1) * tileSize)
    clickPart.Transparency = 1
    clickPart.Name = "Click"

    --grouping for each individual piece surrounding base
    local pieceModel = Instance.new("Model")
    pieceModel.Parent = newSpace.Model
    pieceModel.Name = "Pieces"

    --create pieces (tileSize/pieceSize cubes in each dimension)
    for i = 0, tileSize / pieceSize - 1 do
        for j = 0, tileSize / pieceSize - 1 do
            for k = 0, tileSize / pieceSize - 1 do
                --individual piece generation
                local stud = Instance.new("Part")
                stud.Parent = pieceModel
                stud.Size = Vector3.one * pieceSize
                stud.Color = Color3.new(127,127,127)
                
                --weird position calculation
                stud.CFrame = CFrame.new(
                    (x - 1) * tileSize + i * pieceSize - (tileSize - pieceSize) / 2,
                    (y - 1) * tileSize + j * pieceSize - (tileSize - pieceSize) / 2,
                    (z - 1) * tileSize + k * pieceSize - (tileSize - pieceSize) / 2)
                stud.Anchored = false
                stud.CanCollide = true
                stud.TopSurface = Enum.SurfaceType.SmoothNoOutlines
                stud.BottomSurface = Enum.SurfaceType.SmoothNoOutlines

                --weld stud to base
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = stud
                weld.Part1 = base
                weld.Parent = stud
            end
        end
    end

    --flag text template
    local flagText = Instance.new("TextBox")
    flagText.Size = UDim2.new(0, 100, 0, 100)
    flagText.TextColor3 = Color3.fromRGB(255, 0, 0)
    flagText.BackgroundTransparency = 1
    flagText.TextSize = 100

    --generate flag gui around surface cube
    for _,v in pairs(Enum.NormalId:GetEnumItems()) do
        local surface = Instance.new("SurfaceGui")
        surface.Parent = clickPart
        surface.Face = v
        surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
        surface.CanvasSize = Vector2.new(100, 100)
        surface.Name = "Flag" .. v.Name

        local textClone = flagText:Clone()
        textClone.Parent = clickPart
    end

    --create selectionbox upon highlight
    local selection = Instance.new("SelectionBox")
    selection.Parent = clickPart
    selection.Adornee = pieceModel
    selection.Color3 = Color3.fromRGB(0, 255, 0)
    selection.Visible = false

    local detector = Instance.new("ClickDetector")
    detector.Parent = clickPart

    newSpace.Events = {}

    newSpace.Events.HoverOverEvent = detector.MouseHoverEnter:connect(function()
        selection.Visible = true
    end)
    newSpace.Events.HoverAwayEvent = detector.MouseHoverLeave:connect(function()
        selection.Visible = false
    end)

    return newSpace
end

--number space class
NumberSpace = {}
NumberSpace.__index = NumberSpace
setmetatable(NumberSpace, Space)

function NumberSpace.new(coords, tileSize, pieceSize)
    local numSpace = Space.new(coords, tileSize, pieceSize)
    setmetatable(numSpace, NumberSpace)

    numSpace.Mines = 0
    for _, v in pairs(Enum.NormalId:GetEnumItems()) do
        numSpace.Model.Label[v.Name].TextBox.Text = ""
    end

    return numSpace
end

function NumberSpace:UpdateNumber(num)
    self.Mines = num
    for _, v in pairs(Enum.NormalId:GetEnumItems()) do
        self.Model.Label[v.Name].TextBox.Text = num
        self.Model.Label[v.Name].TextBox.TextColor3 = numColors[num]
    end
end

--mine space
MineSpace = {}
MineSpace.__index = MineSpace
setmetatable(MineSpace, Space)

function MineSpace.new(coords, tileSize, pieceSize)
    local mineSpace = Space.new(coords, tileSize, pieceSize)
    setmetatable(mineSpace, MineSpace)
    mineSpace.Mine = true

    return mineSpace
end

local module = {}

function module.Mine(coords, tileSize, pieceSize)
    return MineSpace.new(coords, tileSize, pieceSize)
end

function module.Number(coords, tileSize, pieceSize)
    return NumberSpace.new(coords, tileSize, pieceSize)
end

return module
