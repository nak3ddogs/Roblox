local toolbar = plugin:CreateToolbar("Object Replacer")
local button = toolbar:CreateButton("Replace", "Replace Objects", "rbxassetid://4458902242")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, false, false, 300, 250, 300, 250
)

local widget = plugin:CreateDockWidgetPluginGui("ReplaceObjectsGui", widgetInfo)
widget.Title = "Object Replacer"

local frame = Instance.new("Frame", widget)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local uiList = Instance.new("UIListLayout", frame)
uiList.Padding = UDim.new(0, 8)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top

local function getObjectByPath(path)
	local segments = string.split(path, ".")
	local current = game
	for _, segment in ipairs(segments) do
		current = current:FindFirstChild(segment)
		if not current then
			return nil
		end
	end
	return current
end

local Selection = game:GetService("Selection")

local function createInputField(labelText, placeholder, settingKey)
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
	input.Size = UDim2.new(0.6, 0, 1, 0)
	input.Position = UDim2.new(0.2, 5, 0, 0)
	input.Text = plugin:GetSetting(settingKey) or ""
	input.ClearTextOnFocus = false
	input.BackgroundColor3 = Color3.fromRGB(60,60,60)
	input.TextColor3 = Color3.new(1,1,1)
	input.PlaceholderText = placeholder
	input.Parent = row

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.1, -5, 1, 0)
	button.Position = UDim2.new(0.8, 10, 0, 0)
	button.Text = "Set"
	button.BackgroundColor3 = Color3.fromRGB(85, 85, 170)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = row

	local button2 = Instance.new("TextButton")
	button2.Size = UDim2.new(0.1, -5, 1, 0)
	button2.Position = UDim2.new(0.9, 10, 0, 0)
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

local exactSearch = plugin:GetSetting("search") or false

local function createTargetObjectNameField(labelText, placeholder, settingKey)
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
	input.Size = UDim2.new(0.6, 0, 1, 0)
	input.Position = UDim2.new(0.2, 5, 0, 0)
	input.Text = plugin:GetSetting(settingKey) or ""
	input.ClearTextOnFocus = false
	input.BackgroundColor3 = Color3.fromRGB(60,60,60)
	input.TextColor3 = Color3.new(1,1,1)
	input.PlaceholderText = placeholder
	input.Parent = row

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.1, -5, 1, 0)
	button.Position = UDim2.new(0.8, 10, 0, 0)
	button.Text = "Set"
	button.BackgroundColor3 = Color3.fromRGB(85, 85, 170)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = row


	button.MouseButton1Click:Connect(function()
		local selected = Selection:Get()[1]
		if selected then
			local path = selected.Name
			input.Text = path
			plugin:SetSetting(settingKey, path)
		end
	end)
	
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0.1, -5, 1, 0)
	toggle.Position = UDim2.new(0.9, 10, 0, 0)
	toggle.Text = exactSearch and "Exact" or "Contains"
	toggle.TextScaled = true
	toggle.BackgroundColor3 = Color3.fromRGB(148, 81, 170)
	toggle.TextColor3 = Color3.new(1, 1, 1)
	toggle.Parent = row
	
	toggle.MouseButton1Click:Connect(function()
		exactSearch = not exactSearch
		plugin:SetSetting("search", exactSearch)
		toggle.Text = exactSearch and "Exact" or "Contains"
	end)

	input.FocusLost:Connect(function()
		plugin:SetSetting(settingKey, input.Text)
	end)

	return input
end

local function CreateInputRow_3Fields(labelText, settingName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.new(1,1,1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local inputs = {}
	for i = 1, 3 do
		local input = Instance.new("TextBox")
		input.Size = UDim2.new(0.2, 0, 1, 0)
		input.Position = UDim2.new(0.4 + 0.2 * (i - 1), 5, 0, 0)
		input.PlaceholderText = "0"
		input.Text = plugin:GetSetting(settingName .. tostring(i)) or "0"
		input.ClearTextOnFocus = false
		input.BackgroundColor3 = Color3.fromRGB(60,60,60)
		input.TextColor3 = Color3.new(1,1,1)
		input.Parent = row
		table.insert(inputs, input)
	end
	return table.unpack(inputs)
end

local objectNameToReplace = createTargetObjectNameField("Object Name:", "the replacable object", "template")
local sourceFolderInput = createInputField("Source Folder:", "Workspace.test", "sourceFolder")
local targetFolderInput = createInputField("Target Folder:", "same as source if empty", "targetFolder")
local sourceFileInput = createInputField("Template:", "ServerStorage.WorldObjects.Enemies.RatBomb", "sourceFile")

local posOffsetInputX, posOffsetInputY, posOffsetInputZ = CreateInputRow_3Fields("Offset Pos", "offsetPos")
local rotOffsetInputX, rotOffsetInputY, rotOffsetInputZ = CreateInputRow_3Fields("Offset Rotation", "offsetRot")

local replaceBtn = Instance.new("TextButton", frame)
replaceBtn.Size = UDim2.new(1, -10, 0, 30)
replaceBtn.Text = "Replace"
replaceBtn.BackgroundColor3 = Color3.fromRGB(85,170,127)
replaceBtn.TextColor3 = Color3.new(1,1,1)

local deleteBtn = Instance.new("TextButton", frame)
deleteBtn.Size = UDim2.new(1, -10, 0, 30)
deleteBtn.Text = "Delete ReplaceTool_Delete Folder"
deleteBtn.BackgroundColor3 = Color3.fromRGB(170,85,85)
deleteBtn.TextColor3 = Color3.new(1,1,1)

local resultLabel = Instance.new("TextLabel", frame)
resultLabel.Size = UDim2.new(1, -10, 0, 20)
resultLabel.BackgroundTransparency = 1
resultLabel.TextColor3 = Color3.new(1,1,1)
resultLabel.Text = ""

deleteBtn.MouseButton1Click:Connect(function()
	local folder = game:GetService("ServerStorage"):FindFirstChild("ReplaceTool_Delete")
	if folder then
		folder:Destroy()
		resultLabel.Text = "🗑️ Folder deleted."
	else
		resultLabel.Text = "⚠️ Folder not found."
	end
end)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

local function saveSettings()
	plugin:SetSetting("sourceFolder", sourceFolderInput.Text)
	plugin:SetSetting("targetFolder", targetFolderInput.Text)
	plugin:SetSetting("template", objectNameToReplace.Text)
	plugin:SetSetting("sourceFile", sourceFileInput.Text)
end

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local function replaceObjects()
	local sourceFolder = getObjectByPath(sourceFolderInput.Text)
	local targetFolder = targetFolderInput.Text == "" and sourceFolder or getObjectByPath(targetFolderInput.Text)
	local templatePath = sourceFileInput.Text
	local sourceObject = getObjectByPath(templatePath)

	if not sourceFolder then
		resultLabel.Text = "❌ Source folder not found!"
		return
	end
	if not targetFolder then
		resultLabel.Text = "❌ Target folder not found!"
		return
	end
	if not sourceObject then
		resultLabel.Text = "❌ Source object not found!"
		return
	end

	local offsetPos = Vector3.new(
		tonumber(posOffsetInputX.Text) or 0,
		tonumber(posOffsetInputY.Text) or 0,
		tonumber(posOffsetInputZ.Text) or 0
	)

	local offsetRot = Vector3.new(
		tonumber(rotOffsetInputX.Text) or 0,
		tonumber(rotOffsetInputY.Text) or 0,
		tonumber(rotOffsetInputZ.Text) or 0
	)

	local trashBin = game:GetService("ServerStorage"):FindFirstChild("ReplaceTool_Delete")
	if not trashBin then
		trashBin = Instance.new("Folder")
		trashBin.Name = "ReplaceTool_Delete"
		trashBin.Parent = game:GetService("ServerStorage")
	end

	local replacedCount = 0
	for _, obj in pairs(sourceFolder:GetDescendants()) do
		
		if exactSearch then
			if obj.Name ~= objectNameToReplace.Text then
				continue
			end
		else
			if not obj.Name:find(objectNameToReplace.Text) then
				continue
			end
		end
		
		local newObj = sourceObject:Clone()
		newObj.Parent = targetFolder

		if obj:IsA("Model") and obj.PrimaryPart and newObj.PrimaryPart then
			local offsetCFrame = CFrame.new(offsetPos) * CFrame.Angles(math.rad(offsetRot.X), math.rad(offsetRot.Y), math.rad(offsetRot.Z))
			newObj:SetPrimaryPartCFrame(obj.PrimaryPart.CFrame * offsetCFrame)
		elseif obj:IsA("BasePart") and newObj:IsA("BasePart") then
			local offsetCFrame = CFrame.new(offsetPos) * CFrame.Angles(math.rad(offsetRot.X), math.rad(offsetRot.Y), math.rad(offsetRot.Z))
			newObj.CFrame = obj.CFrame * offsetCFrame
		end

		if sourceFolder == targetFolder then
			obj.Parent = trashBin
		end
		replacedCount += 1
	end

	resultLabel.Text = "✅ Replaced objects: " .. replacedCount
	ChangeHistoryService:SetWaypoint("Replace Objects")
end

replaceBtn.MouseButton1Click:Connect(function()
	saveSettings()
	replaceObjects()
end)
