-- Plugin: ModelPlacer
-- Fully featured plugin to place models from ServerStorage into Workspace with random rotation, position, and custom UI

local toolbar = plugin:CreateToolbar("ModelPlacer")
local button = toolbar:CreateButton("ModelPlacer", "Place models in world", "rbxassetid://4458902242")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, false, false, 300, 250, 300, 250
)

local widget = plugin:CreateDockWidgetPluginGui("ModelPlacerGui", widgetInfo)
widget.Title = "Model Placer"

local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local placing = false
local pluginMouse = plugin:GetMouse()

local frame = Instance.new("Frame", widget)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local uiList = Instance.new("UIListLayout", frame)
uiList.Padding = UDim.new(0, 8)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top
uiList.SortOrder = Enum.SortOrder.LayoutOrder

local function getObjectByPath(path)
	local current = game
	for _, part in ipairs(string.split(path, ".")) do
		current = current:FindFirstChild(part)
		if not current then return nil end
	end
	return current
end

local function createInputField(labelText, settingKey)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 30)
	row.BackgroundTransparency = 1
	row.LayoutOrder = 0
	row.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.2, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.new(1,1,1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(0.55, 0, 1, 0)
	input.Position = UDim2.new(0.2, 5, 0, 0)
	input.Text = plugin:GetSetting(settingKey) or ""
	input.ClearTextOnFocus = false
	input.BackgroundColor3 = Color3.fromRGB(60,60,60)
	input.TextColor3 = Color3.new(1,1,1)
	input.PlaceholderText = "e.g. ServerStorage.Packages.Tree"
	input.Parent = row

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.1, -5, 1, 0)
	button.Position = UDim2.new(0.75, 10, 0, 0)
	button.Text = "Set"
	button.BackgroundColor3 = Color3.fromRGB(85, 85, 170)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = row

	local button2 = Instance.new("TextButton")
	button2.Size = UDim2.new(0.1, -5, 1, 0)
	button2.Position = UDim2.new(0.85, 10, 0, 0)
	button2.Text = "Sel"
	button2.BackgroundColor3 = Color3.fromRGB(170, 138, 20)
	button2.TextColor3 = Color3.new(1, 1, 1)
	button2.Parent = row

	button2.MouseButton1Click:Connect(function()
		local path = input.Text
		local obj = getObjectByPath(path)
		if obj then
			Selection:Set({obj})
		end
	end)

	button.MouseButton1Click:Connect(function()
		local selected = Selection:Get()[1]
		if selected then
			local path = selected:GetFullName()
			input.Text = path
			plugin:SetSetting(settingKey, path)
		end
	end)

	input.FocusLost:Connect(function()
		plugin:SetSetting(settingKey, input.Text)
	end)

	return input
end

-- Initialize inputs
local sourceInput = createInputField("Source Object:", "placerSource")
local folderInput = createInputField("Target Folder:", "placerTargetFolder")

-- Offset Input Row
local function createOffsetBox(name, pos, default, settingKey)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.25, -5, 1, 0)
	box.Position = pos
	box.PlaceholderText = name
	box.Text = plugin:GetSetting(settingKey) or default
	box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.ClearTextOnFocus = false
	box.FocusLost:Connect(function()
		plugin:SetSetting(settingKey, box.Text)
	end)
	return box
end

local offsetRow = Instance.new("Frame")
offsetRow.Size = UDim2.new(1, -10, 0, 30)
offsetRow.BackgroundTransparency = 1
offsetRow.Parent = frame

local offsetLabel = Instance.new("TextLabel")
offsetLabel.Size = UDim2.new(0.2, 0, 1, 0)
offsetLabel.BackgroundTransparency = 1
offsetLabel.Text = "Pos Offset"
offsetLabel.TextColor3 = Color3.new(1, 1, 1)
offsetLabel.TextXAlignment = Enum.TextXAlignment.Left
offsetLabel.Parent = offsetRow

local offsetX = createOffsetBox("X", UDim2.new(0.2, 5, 0, 0), "0", "offsetX")
offsetX.Parent = offsetRow
local offsetY = createOffsetBox("Y", UDim2.new(0.45, 5, 0, 0), "0", "offsetY")
offsetY.Parent = offsetRow
local offsetZ = createOffsetBox("Z", UDim2.new(0.7, 5, 0, 0), "0", "offsetZ")
offsetZ.Parent = offsetRow

-- Y Rotation Offset + Random Pos Radius Row
local yRotRow = Instance.new("Frame")
yRotRow.Size = UDim2.new(1, -10, 0, 30)
yRotRow.BackgroundTransparency = 1
yRotRow.Parent = frame

local yRotLabel = Instance.new("TextLabel")
yRotLabel.Size = UDim2.new(0.25, 0, 1, 0)
yRotLabel.Position = UDim2.new(0.0, 0, 0, 0)
yRotLabel.BackgroundTransparency = 1
yRotLabel.Text = "Y Rotation Offset"
yRotLabel.TextColor3 = Color3.new(1, 1, 1)
yRotLabel.TextXAlignment = Enum.TextXAlignment.Left
yRotLabel.Parent = yRotRow

local yRotInput = Instance.new("TextBox")
yRotInput.Size = UDim2.new(0.25, 0, 1, 0)
yRotInput.Position = UDim2.new(0.25, 5, 0, 0)
yRotInput.PlaceholderText = "Degrees"
yRotInput.Text = plugin:GetSetting("rotationYOffset") or "0"
yRotInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
yRotInput.TextColor3 = Color3.new(1, 1, 1)
yRotInput.ClearTextOnFocus = false
yRotInput.Parent = yRotRow
yRotInput.ClearTextOnFocus = false
yRotInput.FocusLost:Connect(function()
	plugin:SetSetting("rotationYOffset", yRotInput.Text)
end)

local randRadiusLabel = Instance.new("TextLabel")
randRadiusLabel.Size = UDim2.new(0.25, 0, 1, 0)
randRadiusLabel.Position = UDim2.new(0.58, 0, 0, 0)
randRadiusLabel.BackgroundTransparency = 1
randRadiusLabel.Text = "Rand Pos Radius"
randRadiusLabel.TextColor3 = Color3.new(1, 1, 1)
randRadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
randRadiusLabel.Parent = yRotRow

local randRadiusInput = Instance.new("TextBox")
randRadiusInput.Size = UDim2.new(0.17, 0, 1, 0)
randRadiusInput.Position = UDim2.new(0.83, 0, 0, 0)
randRadiusInput.PlaceholderText = "Units"
randRadiusInput.Text = plugin:GetSetting("randomRadius") or "0"
randRadiusInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
randRadiusInput.TextColor3 = Color3.new(1, 1, 1)
randRadiusInput.ClearTextOnFocus = false
randRadiusInput.Parent = yRotRow
randRadiusInput.FocusLost:Connect(function()
	plugin:SetSetting("randomRadius", randRadiusInput.Text)
end)

-- Random Rotation Toggles Row
local rotRow = Instance.new("Frame")
rotRow.Size = UDim2.new(1, -10, 0, 30)
rotRow.BackgroundTransparency = 1
rotRow.Parent = frame

local rotLabel = Instance.new("TextLabel")
rotLabel.Size = UDim2.new(0.3, 0, 1, 0)
rotLabel.BackgroundTransparency = 1
rotLabel.Text = "Random Rotation"
rotLabel.TextColor3 = Color3.new(1, 1, 1)
rotLabel.TextXAlignment = Enum.TextXAlignment.Left
rotLabel.Parent = rotRow

local function makeToggle(labelText, position)
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0.15, -5, 1, 0)
	toggle.Position = position
	toggle.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
	toggle.TextColor3 = Color3.new(1, 1, 1)
	toggle.Text = labelText .. " Off"
	toggle.MouseButton1Click:Connect(function()
		local on = toggle.Text:find("On") == nil
		toggle.Text = labelText .. (on and " On" or " Off")
		toggle.BackgroundColor3 = on and Color3.fromRGB(85, 170, 127) or Color3.fromRGB(170, 85, 85)
	end)
	toggle.Parent = rotRow
	return toggle
end

local randomX = makeToggle("X", UDim2.new(0.4, 0, 0, 0))
local randomY = makeToggle("Y", UDim2.new(0.57, 0, 0, 0))
local randomZ = makeToggle("Z", UDim2.new(0.74, 0, 0, 0))

-- Select Last + Auto Source Row
local bottomRow = Instance.new("Frame")
bottomRow.Size = UDim2.new(1, -10, 0, 30)
bottomRow.BackgroundTransparency = 1
bottomRow.Parent = frame

local selectLastButton = Instance.new("TextButton")
selectLastButton.Size = UDim2.new(0.48, -5, 1, 0)
selectLastButton.Text = "Select Last"
selectLastButton.BackgroundColor3 = Color3.fromRGB(85, 85, 170)
selectLastButton.TextColor3 = Color3.new(1, 1, 1)
selectLastButton.Parent = bottomRow

local lastCreated = nil
selectLastButton.MouseButton1Down:Connect(function()
	if lastCreated then
		Selection:Set({lastCreated})
	end
end)

local autoSource = false
local autoSourceButton = Instance.new("TextButton")
autoSourceButton.Size = UDim2.new(0.48, -5, 1, 0)
autoSourceButton.Position = UDim2.new(0.52, 0, 0, 0)
autoSourceButton.Text = "Auto Source Off"
autoSourceButton.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
autoSourceButton.TextColor3 = Color3.new(1, 1, 1)
autoSourceButton.Parent = bottomRow
autoSourceButton.MouseButton1Down:Connect(function()
	autoSource = not autoSource
	autoSourceButton.Text = autoSource and "Auto Source On" or "Auto Source Off"
	autoSourceButton.BackgroundColor3 = autoSource and Color3.fromRGB(85, 170, 127) or Color3.fromRGB(170, 85, 85)
end)

-- Placement Logic
pluginMouse.Button1Down:Connect(function()
	if not placing then return end
	if not pluginMouse.Target then return end

	if autoSource then
		local selected = Selection:Get()[1]
		if selected then
			local path = selected:GetFullName()
			sourceInput.Text = path
			plugin:SetSetting("placerSource", path)
		end
	end

	local source = getObjectByPath(sourceInput.Text)
	local folder = getObjectByPath(folderInput.Text)
	if not source or not folder then return end

	local clone = source:Clone()
	clone.Parent = folder
	lastCreated = clone

	local offset = Vector3.new(
		onumber(offsetX.Text) or 0,
		onumber(offsetY.Text) or 0,
		onumber(offsetZ.Text) or 0
	)

	local yRotOffsetDeg = tonumber(yRotInput.Text) or 0
	local yRotOffset = CFrame.Angles(0, math.rad(yRotOffsetDeg), 0)

	local radius = tonumber(randRadiusInput.Text) or 0
	local targetCFrame

	if radius > 0 then
		local angle = math.rad(math.random(0, 359))
		local offsetXZ = Vector3.new(math.cos(angle), 0, math.sin(angle)) * (math.random() * radius)
		local worldPos = pluginMouse.Hit.Position + offsetXZ

		local rayOrigin = Camera.CFrame.Position
		local direction = (worldPos - rayOrigin).Unit * 500
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {Camera}
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.IgnoreWater = true
		local result = workspace:Raycast(rayOrigin, direction, params)

		targetCFrame = result and CFrame.new(result.Position) or CFrame.new(worldPos)
	else
		targetCFrame = pluginMouse.Hit
	end

	targetCFrame = targetCFrame + offset

	local direction = (Camera.CFrame.Position - targetCFrame.Position).Unit
	local up = Vector3.new(0, 1, 0)
	local facing = CFrame.lookAt(targetCFrame.Position, targetCFrame.Position + Vector3.new(direction.X, 0, direction.Z), up) * yRotOffset

	local function getRandomRotation(xOn, yOn, zOn)
		local x = xOn and math.rad(math.random(0, 360)) or 0
		local y = yOn and math.rad(math.random(0, 360)) or 0
		local z = zOn and math.rad(math.random(0, 360)) or 0
		return CFrame.Angles(x, y, z)
	end

	if clone:IsA("Model") then
		if not clone.PrimaryPart then
			error("Model has no PrimaryPart set.")
		end
		clone:PivotTo(facing)
		clone:PivotTo(clone:GetPivot() * getRandomRotation(
			randomX.Text:find("On") ~= nil,
			randomY.Text:find("On") ~= nil,
			randomZ.Text:find("On") ~= nil
			))
	elseif clone:IsA("BasePart") then
		clone.CFrame = facing * getRandomRotation(
			randomX.Text:find("On") ~= nil,
			randomY.Text:find("On") ~= nil,
			randomZ.Text:find("On") ~= nil
		)
	end

	ChangeHistoryService:SetWaypoint("Placed Model")
end)

-- Toggle Button to Enable/Disable Placing
local placeButton = Instance.new("TextButton")
placeButton.Size = UDim2.new(1, -10, 0, 30)
placeButton.Text = "Placing Disabled"
placeButton.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
placeButton.TextColor3 = Color3.new(1,1,1)
placeButton.LayoutOrder = -100
placeButton.Parent = frame

placeButton.MouseButton1Click:Connect(function()
	placing = not placing
	placeButton.Text = placing and "Placing Enabled" or "Placing Disabled"
	placeButton.BackgroundColor3 = placing and Color3.fromRGB(85, 170, 127) or Color3.fromRGB(170, 85, 85)
	if placing then
		plugin:Activate(true)
	else
		plugin:Deactivate()
	end
end)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
