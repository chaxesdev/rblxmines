math.randomseed(tick())
tween = game:GetService("TweenService")
fastwait = require(game:GetService("ReplicatedStorage").FastWait)

-- colors for mine count numbers
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

function Space.new(x,y,z,	tileSize,pieceSize)
	local newspace = {}
	setmetatable(newspace, Space)
	
	--fixed values for space
	newspace.Position = Vector3.new(x,y,z)
	newspace.Marked = false
	newspace.Flagged = false
	newspace.Mine = false
	newspace.TileSize = tileSize
	newspace.PieceSize = pieceSize
	
	--model for all parts of cube
	newspace.Model = Instance.new("Model")
	newspace.Model.Parent = workspace
	newspace.Model.Name = "Space" .. x .. "_" .. y .. "_" .. z
	
	--base of whole unit
	local base = Instance.new("Part")
	base.Parent = newspace.Model
	base.Size = Vector3.new(tileSize*0.9,tileSize*0.9,tileSize*0.9)
	base.Color = Color3.new(50,50,50)
	base.Anchored = true
	base.CanCollide = true
	base.CFrame = CFrame.new((x-1)*tileSize,(y-1)*tileSize,(z-1)*tileSize)
	base.TopSurface = Enum.SurfaceType.SmoothNoOutlines
	base.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	base.Name = "Base"
	
	--cube for showing numbers on each side
	local labelPart = Instance.new("Part")
	labelPart.Parent = newspace.Model
	labelPart.Size = Vector3.new(tileSize*0.9,tileSize*0.9,tileSize*0.9)
	labelPart.Transparency = 1
	labelPart.Anchored = false
	labelPart.CanCollide = false
	labelPart.CFrame = CFrame.new((x-1)*tileSize,(y-1)*tileSize,(z-1)*tileSize)
	labelPart.Name = "Label"
	
	--weld label to base
	local labelweld = Instance.new("WeldConstraint")
	labelweld.Part0 = labelPart
	labelweld.Part1 = base
	labelweld.Parent = labelPart
	
	--textbox template
	local text = Instance.new("TextBox")
	text.Size = UDim2.new(0,100,0,100)
	text.TextColor3 = Color3.fromRGB(255,0,255)
	text.BackgroundTransparency = 1
	text.TextSize = 100
	text.Text = "X"
	text.Font = Enum.Font.SourceSans
	
	--create surfacegui and add text to each side of label cube
	for i,v in pairs(Enum.NormalId:GetEnumItems()) do
		local surface = Instance.new("SurfaceGui")
		surface.Parent = labelPart
		surface.Face = v
		surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surface.CanvasSize = Vector2.new(100,100)
		surface.Name = v.Name
		
		local clone = text:Clone()
		clone.Parent = surface
	end
	
	--clickable cube of unit
	local clickpart = Instance.new("Part")
	clickpart.Parent = newspace.Model
	clickpart.Size = Vector3.new(tileSize*1.05,tileSize*1.05,tileSize*1.05)
	clickpart.Color = Color3.new(50,50,50)
	clickpart.Anchored = false
	clickpart.CanCollide = false
	clickpart.CFrame = CFrame.new((x-1)*tileSize,(y-1)*tileSize,(z-1)*tileSize)
	clickpart.Transparency = 1
	clickpart.Name = "Click"
	
	--weld click part to base
	local clickWeld = Instance.new("WeldConstraint")
	clickWeld.Part0 = clickpart
	clickWeld.Part1 = base
	clickWeld.Parent = clickpart
	
	--grouping for each individual piece surrounding base
	local model = Instance.new("Model")
	model.Parent = newspace.Model
	model.Name = "Pieces"
	
	--create pieces (tileSize/pieceSize cubes for each dimension)
	for i=0,tileSize/pieceSize-1 do
		for j=0,tileSize/pieceSize-1 do
			for k=0, tileSize/pieceSize-1 do
				--individual piece generation
				local stud = Instance.new("Part")
				stud.Parent = model
				stud.Size = Vector3.new(pieceSize,pieceSize,pieceSize)
				stud.Color = Color3.new(127,127,127)
				--weird position calculation
				stud.CFrame = CFrame.new(
					(x-1)*tileSize+i*pieceSize-(tileSize-pieceSize)/2,
					(y-1)*tileSize+j*pieceSize-(tileSize-pieceSize)/2,
					(z-1)*tileSize+k*pieceSize-(tileSize-pieceSize)/2)
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
	local text2 = Instance.new("TextBox")
	--text2.Parent = surface2
	text2.Size = UDim2.new(0,100,0,100)
	text2.TextColor3 = Color3.fromRGB(255,0,0)
	text2.BackgroundTransparency = 1
	text2.TextSize = 100
	text2.Text = "F"
	text2.Font = Enum.Font.SourceSans
	text2.Name = "Flag"
	text2.Visible = false
	
	--flag gui
	for i,v in pairs(Enum.NormalId:GetEnumItems()) do
		local surface = Instance.new("SurfaceGui")
		surface.Parent = clickpart
		surface.Face = v
		surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surface.CanvasSize = Vector2.new(100,100)
		surface.Name = "Flag" .. v.Name
		
		local clone = text2:Clone()
		clone.Parent = surface
	end
	
	
	local selection = Instance.new("SelectionBox")
	selection.Parent = clickpart
	selection.Adornee = model
	selection.Color3 = Color3.fromRGB(0,255,0)
	selection.Visible = false
	
	local detector = Instance.new("ClickDetector")
	detector.Parent = clickpart
	--detector.MouseClick:connect(function()
		--clickpart:Destroy()
	--end)
	detector.MouseHoverEnter:connect(function()
		selection.Visible = true
	end)
	
	detector.MouseHoverLeave:connect(function()
		selection.Visible = false
	end)
	
	return newspace
end


NumberSpace = {}
NumberSpace.__index = NumberSpace
setmetatable(NumberSpace, Space)

function NumberSpace.new(x,y,z,tileSize,pieceSize)
	local numsp = Space.new(x,y,z,tileSize,pieceSize)
	setmetatable(numsp, NumberSpace)
	
	numsp.Mines = 0
	for i,v in pairs(Enum.NormalId:GetEnumItems()) do
		numsp.Model.Label[v.Name].TextBox.Text = ""
	end
	
	return numsp
end

function NumberSpace:UpdateNumber(num)
	self.Mines = num
	for i,v in pairs(Enum.NormalId:GetEnumItems()) do
		self.Model.Label[v.Name].TextBox.Text = num
		self.Model.Label[v.Name].TextBox.TextColor3 = numColors[num]
	end
end


MineSpace = {}
MineSpace.__index = NumberSpace
setmetatable(MineSpace, Space)

function MineSpace.new(x,y,z,tileSize,pieceSize)
	local minesp = Space.new(x,y,z,tileSize,pieceSize)
	setmetatable(minesp, MineSpace)
	minesp.Mine = true
	
	return minesp
end

MinesweeperGame = {}
MinesweeperGame.__index = MinesweeperGame

function MinesweeperGame.new(x,y,z,mines,tileSize,pieceSize)
	assert(tileSize % pieceSize == 0)
	local newgame = {}
	setmetatable(newgame, MinesweeperGame)
	newgame.Model = Instance.new("Model")
	newgame.Model.Parent = workspace
	newgame:Generate(x,y,z,mines,tileSize,pieceSize)
	
	return newgame
end

function MinesweeperGame:Generate(x,y,z,mines,tileSize,pieceSize)
	self.Mines = {}
	self.XSelectors = {}
	self.ZSelectors = {}
	self.XSelected = -1
	self.ZSelected = -1
	self.Splitting = false
	self.Status = "Progress"
	self.Dimensions = {x,y,z}
	self.TileSize = tileSize
	self.PieceSize = pieceSize
	self.MineCount = mines
	self.Remaining = x * y * z - mines
	self.RemainingFlags = mines
	self.Flagged = 0
	
	local function isMine(_x, _y, _z)
		for _,v in pairs(self.Mines) do
			if v[1] == _x and v[2] == _y and v[3] == _z then
				return true
			end
		end
		return false
	end

	for i=1,mines do
		local success = false
		while not success do
			local newX = math.random(1,x)
			local newY = math.random(1,y)
			local newZ = math.random(1,z)
			if isMine(newX, newY, newZ) then
				continue
			end
			self.Mines[i] = {newX, newY, newZ}
			success = true
		end
	end

	self.Spaces = {}
	for i=1,x do
		self.Spaces[i] = {}
		for j=1,y do
			self.Spaces[i][j] = {}
			for k=1,z do
				if isMine(i, j, k) then			
					self.Spaces[i][j][k] = MineSpace.new(i,j,k,tileSize,pieceSize)
					self.Spaces[i][j][k].Model.Parent = self.Model
				else
					self.Spaces[i][j][k] = NumberSpace.new(i,j,k,tileSize,pieceSize)
					self.Spaces[i][j][k].Model.Parent = self.Model
				end
				self.Spaces[i][j][k].Model.Click.ClickDetector.MouseClick:connect(function()
					self:Select(i,j,k)
				end)
				self.Spaces[i][j][k].Model.Click.ClickDetector.RightMouseClick:connect(function()
					self:Flag(i,j,k)
				end)
			end
			fastwait()
		end
	end
	
	for i=1,x-1 do
		local divider = Instance.new("Part")
		divider.Parent = self.Model
		divider.Name ="DividerX"..i
		divider.Transparency = 1
		divider.CanCollide = false
		divider.Anchored = true
		divider.Size = Vector3.new(tileSize / 4, y * tileSize + 2, z * tileSize + 2)
		divider.Position = Vector3.new(
			(self.Spaces[i][1][1].Model.Base.Position.x + self.Spaces[i+1][1][1].Model.Base.Position.x)/2,
			(y-1) * tileSize / 2,
			(z-1) * tileSize / 2
		)
		self.XSelectors[i] = divider
		
		local box = Instance.new("SelectionBox")
		box.Parent = divider
		box.Adornee = divider
		box.Color3 = Color3.fromRGB(0,255,255)
		box.Visible = false
		
		local click = Instance.new("ClickDetector")
		click.Parent = divider
		click.MouseClick:connect(function()
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
		click.MouseHoverEnter:connect(function()
			box.Visible = true
		end)
		click.MouseHoverLeave:connect(function()
			box.Visible = false
		end)
	end
	
	for i=1,z-1 do
		local divider = Instance.new("Part")
		divider.Parent = self.Model
		divider.Name ="DividerZ"..i
		divider.Transparency = 1
		divider.CanCollide = false
		divider.Anchored = true
		divider.Size = Vector3.new(x * tileSize + 2, y * tileSize + 2, tileSize / 4)
		divider.Position = Vector3.new(
			(x-1) * tileSize / 2,
			(y-1) * tileSize / 2,
			(self.Spaces[1][1][i].Model.Base.Position.z + self.Spaces[1][1][i+1].Model.Base.Position.z)/2
		)
		self.ZSelectors[i] = divider

		local box = Instance.new("SelectionBox")
		box.Parent = divider
		box.Adornee = divider
		box.Color3 = Color3.fromRGB(0,255,255)
		box.Visible = false

		local click = Instance.new("ClickDetector")
		click.Parent = divider
		click.MouseClick:connect(function()
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
		click.MouseHoverEnter:connect(function()
			box.Visible = true
		end)
		click.MouseHoverLeave:connect(function()
			box.Visible = false
		end)
	end

	for i,v in pairs(self.Mines) do
		local mineX, mineY, mineZ = v[1], v[2], v[3]
		for i=math.max(1, mineX-1), math.min(x, mineX+1) do
			for j=math.max(1, mineY-1), math.min(y, mineY+1) do
				for k=math.max(1, mineZ-1), math.min(z, mineZ+1) do
					if not self.Spaces[i][j][k].Mine then
						local num = self.Spaces[i][j][k].Mines
						self.Spaces[i][j][k]:UpdateNumber(num+1)
					end
				end
			end
		end
	end
	print("Generation complete")
end

function MinesweeperGame:Cleanup()
	self.Status = "Cleanup"
	local count = 0
	for i,v in pairs(self.Model:GetChildren()) do
		v:Destroy()
		count = count + 1
		if count == 10 then
			fastwait()
			count = 0
		end
	end
	self.Mines = nil
	for i=1, #self.XSelectors do
		self.XSelectors[i] = nil
	end
	self.XSelectors = nil
	for i=1, #self.ZSelectors do
		self.ZSelectors[i] = nil
	end
	self.ZSelectors = nil
	for i=1, self.Dimensions[1] do
		for j=1, self.Dimensions[2] do 
			for k=1, self.Dimensions[3] do 
				local space = self.Spaces[i][j][k]
				space.Model = nil
				self.Spaces[i][j][k] = nil
			end
		end
	end
	self.Spaces = nil
end

function MinesweeperGame:Select(x,y,z)
	local space = self.Spaces[x][y][z]
	assert(space ~= nil)
	if space.Flagged then
		return
	end
	
	if space.Mine then
		self:Lose(x,y,z)
	else
		space.Marked = true
		space.Model.Click.ClickDetector:Destroy()
		space.Model.Click.SelectionBox:Destroy()
		self.Remaining = self.Remaining - 1
		if self.Remaining == 0 then
			self:Win()
		end
		
		local info = TweenInfo.new(0.5)
		for _,v in pairs(space.Model.Pieces:GetChildren()) do
			local goal = {
				["Transparency"] = 1,
				["CFrame"] = v.CFrame * CFrame.Angles(0,math.rad(180),0)
			}
			local newTween = tween:Create(v, info, goal)
			v.CanCollide = false
			newTween:Play()
		end
		coroutine.wrap(function()
			fastwait(0.5)
			space.Model.Pieces:Destroy()
			space.Model.Click:Destroy()
		end)()
		
		if space.Mines == 0 then
			fastwait(0.2)
			--space.Model.Base.Transparency = 1
			--space.Model.Base.CanCollide = false
			for i=math.max(1, x-1), math.min(self.Dimensions[1],x+1) do
				for j=math.max(1,y-1), math.min(self.Dimensions[2], y+1) do
					for k=math.max(1,z-1), math.min(self.Dimensions[3], z+1) do
						local space1 = self.Spaces[i][j][k]
						if space1 ~= space and not space1.Marked and not space1.Mine and not space1.Flagged then
							coroutine.wrap(function()
								self:Select(i,j,k)
							end)()
						end
					end
				end
			end
		end
	end
end

function MinesweeperGame:Flag(x,y,z)
	local ngSpace = self.Spaces[x][y][z]
	if ngSpace.Flagged then
		ngSpace.Flagged = false
		for i,v in pairs(Enum.NormalId:GetEnumItems()) do
			ngSpace.Model.Click["Flag" .. v.Name].Flag.Visible = false
		end
		self.RemainingFlags = self.RemainingFlags + 1
		if ngSpace.Mine then
			self.Flagged = self.Flagged - 1
		end
	elseif self.RemainingFlags ~= 0 then
		ngSpace.Flagged = true
		for i,v in pairs(Enum.NormalId:GetEnumItems()) do
			ngSpace.Model.Click["Flag" .. v.Name].Flag.Visible = true
		end
		self.RemainingFlags = self.RemainingFlags - 1
		if ngSpace.Mine then
			self.Flagged = self.Flagged + 1
			if self.Flagged == self.MineCount then
				self:Win()
			end
		end
	end
end

function MinesweeperGame:SplitX(x, undo)
	assert(x >= 1 and x <= self.Dimensions[1])
	self.Splitting = true
	local tinfo = TweenInfo.new(0.25)
	if not undo then
		self.XSelected = x
		for i,v in pairs(self.ZSelectors) do
			v.Parent = nil
		end
		for i = 1, x do
			for j = 1, self.Dimensions[2] do
				for k = 1, self.Dimensions[3] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new((i-2)*self.TileSize,(j-1)*self.TileSize,(k-1)*self.TileSize)})
					t:Play()
				end
			end
			if i-1 > 0 and i-1 ~= x then
				self.XSelectors[i-1].Parent = nil
			end
			fastwait()
		end
		self.XSelectors[x].Size = Vector3.new(self.XSelectors[x].Size.x, 1, self.XSelectors[x].Size.z)
		self.XSelectors[x].Position = Vector3.new(self.XSelectors[x].Position.x, -self.TileSize / 2 + 0.5, self.XSelectors[x].Position.z)
		print("after resizing small")
		for i = self.Dimensions[1], x+1, -1 do
			for j = 1, self.Dimensions[2] do
				for k = 1, self.Dimensions[3] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new(i*self.TileSize,(j-1)*self.TileSize,(k-1)*self.TileSize)})
					t:Play()
				end
			end
			if i-1 > 0 and i-1 ~= x then
				self.XSelectors[i-1].Parent = nil
			end
			fastwait()
		end
	else
		self.XSelected = -1
		for i,v in pairs(self.ZSelectors) do
			v.Parent = self.Model
		end
		for i = x, 1, -1 do
			for j = 1, self.Dimensions[2] do
				for k = 1, self.Dimensions[3] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new((i-1)*self.TileSize,(j-1)*self.TileSize,(k-1)*self.TileSize)})
					t:Play()
				end
			end
			if i-1 > 0 and i-1 ~= x then
				self.XSelectors[i-1].Parent = self.Model
			end
			fastwait()
		end
		self.XSelectors[x].Size = Vector3.new(self.XSelectors[x].Size.x, self.Dimensions[2] * self.TileSize + 2, self.XSelectors[x].Size.z)
		self.XSelectors[x].Position = Vector3.new(self.XSelectors[x].Position.x, (self.Dimensions[2] - 1) * self.TileSize / 2, self.XSelectors[x].Position.z)
		print("after resizing big")
		for i = x+1, self.Dimensions[1] do
			for j = 1, self.Dimensions[2] do
				for k = 1, self.Dimensions[3] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new((i-1)*self.TileSize,(j-1)*self.TileSize,(k-1)*self.TileSize)})
					t:Play()
				end
			end
			if i-1 > 0 and i-1 ~= x then
				self.XSelectors[i-1].Parent = self.Model
			end
			fastwait()
		end
	end
	self.Splitting = false
end

function MinesweeperGame:SplitZ(z, undo)
	assert(z >= 1 and z <= self.Dimensions[3])
	self.Splitting = true
	local tinfo = TweenInfo.new(0.25)
	if not undo then
		self.ZSelected = z
		for i,v in pairs(self.XSelectors) do
			v.Parent = nil
		end
		for k = 1, z do
			for j = 1, self.Dimensions[2] do
				for i = 1, self.Dimensions[1] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new((i-1)*self.TileSize,(j-1)*self.TileSize,(k-2)*self.TileSize)})
					t:Play()
				end
			end
			if k-1 > 0 and k-1 ~= z then
				self.ZSelectors[k-1].Parent = nil
			end
			fastwait()
		end
		self.ZSelectors[z].Size = Vector3.new(self.ZSelectors[z].Size.x, 1, self.ZSelectors[z].Size.z)
		self.ZSelectors[z].Position = Vector3.new(self.ZSelectors[z].Position.x, -self.TileSize / 2 + 0.5, self.ZSelectors[z].Position.z)
		print("after resizing small")
		for k = self.Dimensions[3], z+1, -1 do
			for j = 1, self.Dimensions[2] do
				for i = 1, self.Dimensions[1] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new((i-1)*self.TileSize,(j-1)*self.TileSize,k*self.TileSize)})
					t:Play()
				end
			end
			if k-1 > 0 and k-1 ~= z then
				self.ZSelectors[k-1].Parent = nil
			end
			fastwait()
		end
	else
		self.ZSelected = -1
		for i,v in pairs(self.XSelectors) do
			v.Parent = self.Model
		end
		for k = z, 1, -1 do
			for j = 1, self.Dimensions[2] do
				for i = 1, self.Dimensions[1] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new((i-1)*self.TileSize,(j-1)*self.TileSize,(k-1)*self.TileSize)})
					t:Play()
				end
			end
			if k-1 > 0 and k-1 ~= z then
				self.ZSelectors[k-1].Parent = self.Model
			end
			fastwait()
		end
		self.ZSelectors[z].Size = Vector3.new(self.ZSelectors[z].Size.x, self.Dimensions[2] * self.TileSize + 2, self.ZSelectors[z].Size.z)
		self.ZSelectors[z].Position = Vector3.new(self.ZSelectors[z].Position.x, (self.Dimensions[2] - 1) * self.TileSize / 2, self.ZSelectors[z].Position.z)
		print("after resizing big")
		for k = z+1, self.Dimensions[3] do
			for j = 1, self.Dimensions[2] do
				for i = 1, self.Dimensions[1] do
					local space = self.Spaces[i][j][k]
					local t = tween:Create(space.Model.Base, tinfo, {["CFrame"] = CFrame.new((i-1)*self.TileSize,(j-1)*self.TileSize,(k-1)*self.TileSize)})
					t:Play()
				end
			end
			if k-1 > 0 and k-1 ~= z then
				self.ZSelectors[k-1].Parent = self.Model
			end
			fastwait()
		end
	end
	self.Splitting = false
end

function MinesweeperGame:Win()
	self.Status = "Win"
	print("Win")
	for i=1,self.Dimensions[1] do
		for j=1,self.Dimensions[2] do
			for k=1,self.Dimensions[3] do
				local space = self.Spaces[i][j][k]
				if not space.Marked then
					space.Model.Click.SelectionBox:Destroy()
					space.Model.Click.ClickDetector:Destroy()
				end
			end
		end
	end
end

function MinesweeperGame:Lose(x,y,z)
	self.Status = "Lose"
	print("Lose")
	for i=1, self.Dimensions[1] do
		for j=1, self.Dimensions[2] do
			for k=1, self.Dimensions[3] do
				local space = self.Spaces[i][j][k]
				if not space.Marked then
					space.Model.Click.ClickDetector:Destroy()
					space.Model.Click.SelectionBox:Destroy()
					--if not space.Mine then
					--	for _,v in pairs(space.Model.Pieces:GetChildren()) do
					--		v.Anchored = false
					--	end
					--end
				end
			end
		end
	end	
	local boom = Instance.new("Explosion")
	local sound = Instance.new("Sound")
	local curSpace = self.Spaces[x][y][z]
	--curSpace.Model.Label.WeldConstraint:Destroy()
	--curSpace.Model.Label.Anchored = true
	for _,v in pairs(curSpace.Model.Pieces:GetChildren()) do
		--v.Anchored= false
		v.WeldConstraint:Destroy()
		v:SetNetworkOwner(nil)
		local t = tween:Create(v, TweenInfo.new(10), {["Transparency"] = 1})
		t.Completed:connect(function()
			v:Destroy()
		end)
		t:Play()	
	end
	sound.Parent = curSpace.Model.Click
	sound.PlayOnRemove = true
	sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
	boom.Parent = curSpace.Model
	boom.Position = curSpace.Model.Click.Position - Vector3.new(0,1,0)
	boom.BlastRadius = curSpace.Model.Click.Size.x+3
	boom.BlastPressure = 500000*curSpace.PieceSize/2
	boom.DestroyJointRadiusPercent = -1
	curSpace.Model.Click:Destroy()
	fastwait(0.5)
	for _,v in pairs(self.Mines) do
		local space = self.Spaces[v[1]][v[2]][v[3]]
		if space ~= curSpace then
			--space.Model.Label.WeldConstraint:Destroy()
			--space.Model.Label.Anchored = true
			for _,v in pairs(space.Model.Pieces:GetChildren()) do
				--v.Anchored = false
				v.WeldConstraint:Destroy()
				v:SetNetworkOwner(nil)
				local t = tween:Create(v, TweenInfo.new(10), {["Transparency"] = 1})
				t.Completed:connect(function()
					v:Destroy()
				end)
				t:Play()	
			end
			local boom = Instance.new("Explosion")
			local sound = Instance.new("Sound")
			sound.Parent = space.Model.Click
			sound.PlayOnRemove = true
			sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
			boom.Parent = space.Model
			boom.Position = space.Model.Click.Position	
			boom.BlastRadius = space.Model.Click.Size.x+2
			boom.BlastPressure = 500000*space.PieceSize/2
			boom.DestroyJointRadiusPercent = -1
			space.Model.Click:Destroy()
			fastwait(0.2)
		end
	end
end

gameboard = MinesweeperGame.new(5,4,5,10,4,4)
debounce = false
workspace.Button.ClickDetector.MouseClick:connect(function()
	if debounce == true then
		return
	end
	debounce = true
	local button = workspace.Button
	button.BrickColor = BrickColor.new("Black")
	gameboard:Cleanup()
	--fastwait(2)
	local size = button.GameSize.Value
	local tile = button.TileSize.Value
	local piece = button.PieceSize.Value
	local mines = button.Mines.Value
	
	gameboard:Generate(size.x, size.y, size.z, mines, tile, piece)
	button.BrickColor = BrickColor.new("Royal purple")
	debounce = false
end)
