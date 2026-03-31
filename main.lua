-- main.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local DataStoreService = game:GetService("DataStoreService")

local localPlayer = Players.LocalPlayer

local Settings = {
	ESPEnabled = true,
	ShowName = true,
	ShowHealth = true,
	ShowDistance = true,
	MaxDistance = 500,
	EnemyColor = Color3.fromRGB(255, 80, 80),
	TextColor = Color3.fromRGB(255, 255, 255),

	HitboxEnabled = true,
	HitboxSize = Vector3.new(10, 15, 10),
	ShowHitbox = true,
	HitboxColor = Color3.fromRGB(255, 80, 80),
	HitboxTransparency = 0.5,
}

local ESPObjects = {}
local HitboxObjects = {}
local OriginalSizes = {}

-- Pringles färger
local GREEN = Color3.fromRGB(78, 153, 64)
local DARK_GREEN = Color3.fromRGB(50, 110, 40)
local RED = Color3.fromRGB(180, 30, 40)
local WHITE = Color3.fromRGB(255, 255, 255)
local LIGHT_GREEN = Color3.fromRGB(200, 230, 180)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PringlesSmatrish"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 470)
mainFrame.Position = UDim2.new(0, 20, 0.5, -235)
mainFrame.BackgroundColor3 = GREEN
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke")
stroke.Color = DARK_GREEN
stroke.Thickness = 3
stroke.Parent = mainFrame

local silverTop = Instance.new("Frame")
silverTop.Size = UDim2.new(1, 0, 0, 14)
silverTop.Position = UDim2.new(0, 0, 0, 0)
silverTop.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
silverTop.BorderSizePixel = 0
silverTop.Parent = mainFrame
Instance.new("UICorner", silverTop).CornerRadius = UDim.new(0, 16)

local redBanner = Instance.new("Frame")
redBanner.Size = UDim2.new(1, -20, 0, 36)
redBanner.Position = UDim2.new(0, 10, 0, 20)
redBanner.BackgroundColor3 = RED
redBanner.BorderSizePixel = 0
redBanner.Parent = mainFrame
Instance.new("UICorner", redBanner).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = WHITE
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.Text = "PRINGLES smatrish'"
titleLabel.Parent = redBanner

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, 0, 0, 18)
subTitle.Position = UDim2.new(0, 0, 0, 58)
subTitle.BackgroundTransparency = 1
subTitle.TextColor3 = LIGHT_GREEN
subTitle.Font = Enum.Font.GothamBold
subTitle.TextSize = 11
subTitle.Text = "SOUR CREAM & ONION"
subTitle.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 2)
divider.Position = UDim2.new(0, 10, 0, 78)
divider.BackgroundColor3 = DARK_GREEN
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- Hide hint label
local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, -20, 0, 16)
hintLabel.Position = UDim2.new(0, 10, 1, -20)
hintLabel.BackgroundTransparency = 1
hintLabel.TextColor3 = LIGHT_GREEN
hintLabel.Font = Enum.Font.Gotham
hintLabel.TextSize = 10
hintLabel.Text = "Right Shift = Visa/Göm"
hintLabel.Parent = mainFrame

local function createSection(text, yPos)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 22)
	label.Position = UDim2.new(0, 10, 0, yPos)
	label.BackgroundColor3 = DARK_GREEN
	label.TextColor3 = LIGHT_GREEN
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.Text = text
	label.Parent = mainFrame
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
end

-- Config sparning (använder en tabell i minnet + writefile om executor stödjer det)
local function saveConfig()
	local config = {
		ESPEnabled = Settings.ESPEnabled,
		ShowName = Settings.ShowName,
		ShowHealth = Settings.ShowHealth,
		ShowDistance = Settings.ShowDistance,
		MaxDistance = Settings.MaxDistance,
		HitboxEnabled = Settings.HitboxEnabled,
		HitboxSizeX = Settings.HitboxSize.X,
		ShowHitbox = Settings.ShowHitbox,
	}
	local encoded = game:GetService("HttpService"):JSONEncode(config)
	if writefile then
		writefile("pringles_config.json", encoded)
		print("✅ Config sparad!")
	else
		warn("Executor stödjer inte writefile")
	end
end

local function loadConfig()
	if readfile and isfile and isfile("pringles_config.json") then
		local ok, data = pcall(function()
			return game:GetService("HttpService"):JSONDecode(readfile("pringles_config.json"))
		end)
		if ok and data then
			Settings.ESPEnabled = data.ESPEnabled ~= nil and data.ESPEnabled or Settings.ESPEnabled
			Settings.ShowName = data.ShowName ~= nil and data.ShowName or Settings.ShowName
			Settings.ShowHealth = data.ShowHealth ~= nil and data.ShowHealth or Settings.ShowHealth
			Settings.ShowDistance = data.ShowDistance ~= nil and data.ShowDistance or Settings.ShowDistance
			Settings.MaxDistance = data.MaxDistance or Settings.MaxDistance
			Settings.HitboxEnabled = data.HitboxEnabled ~= nil and data.HitboxEnabled or Settings.HitboxEnabled
			Settings.ShowHitbox = data.ShowHitbox ~= nil and data.ShowHitbox or Settings.ShowHitbox
			if data.HitboxSizeX then
				Settings.HitboxSize = Vector3.new(data.HitboxSizeX, data.HitboxSizeX * 1.5, data.HitboxSizeX)
			end
			print("✅ Config laddad!")
		end
	end
end

local function createToggle(labelText, yPos, settingKey)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -20, 0, 28)
	row.Position = UDim2.new(0, 10, 0, yPos)
	row.BackgroundTransparency = 1
	row.Parent = mainFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = WHITE
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = labelText
	label.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 48, 0, 22)
	btn.Position = UDim2.new(1, -48, 0.5, -11)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = row
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local function updateBtn()
		if Settings[settingKey] then
			btn.Text = "ON"
			btn.BackgroundColor3 = Color3.fromRGB(50, 200, 90)
			btn.TextColor3 = WHITE
		else
			btn.Text = "OFF"
			btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
			btn.TextColor3 = WHITE
		end
	end

	updateBtn()
	btn.MouseButton1Click:Connect(function()
		Settings[settingKey] = not Settings[settingKey]
		updateBtn()
	end)

	return updateBtn
end

local sliderUpdaters = {}

local function createSlider(labelText, yPos, settingKey, minVal, maxVal, isHitbox)
	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Size = UDim2.new(1, -20, 0, 20)
	sizeLabel.Position = UDim2.new(0, 10, 0, yPos)
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.TextColor3 = WHITE
	sizeLabel.Font = Enum.Font.GothamBold
	sizeLabel.TextSize = 12
	sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	sizeLabel.Text = labelText .. ": " .. minVal
	sizeLabel.Parent = mainFrame

	local sizeFrame = Instance.new("Frame")
	sizeFrame.Size = UDim2.new(1, -20, 0, 14)
	sizeFrame.Position = UDim2.new(0, 10, 0, yPos + 22)
	sizeFrame.BackgroundColor3 = DARK_GREEN
	sizeFrame.BorderSizePixel = 0
	sizeFrame.Parent = mainFrame
	Instance.new("UICorner", sizeFrame).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = WHITE
	fill.BorderSizePixel = 0
	fill.Parent = sizeFrame
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, -7, 0.5, -7)
	knob.BackgroundColor3 = WHITE
	knob.BorderSizePixel = 0
	knob.Parent = sizeFrame
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false

	local function updateSlider(ratio)
		ratio = math.clamp(ratio, 0, 1)
		local val = math.floor(minVal + ratio * (maxVal - minVal))
		if isHitbox then
			Settings[settingKey] = Vector3.new(val, val * 1.5, val)
		else
			Settings[settingKey] = val
		end
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		knob.Position = UDim2.new(ratio, -7, 0.5, -7)
		sizeLabel.Text = labelText .. ": " .. val
	end

	-- Spara referens så vi kan synka efter config load
	sliderUpdaters[settingKey] = function()
		local val = isHitbox and Settings[settingKey].X or Settings[settingKey]
		local ratio = (val - minVal) / (maxVal - minVal)
		updateSlider(ratio)
	end

	sizeFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local ratio = (input.Position.X - sizeFrame.AbsolutePosition.X) / sizeFrame.AbsoluteSize.X
			updateSlider(ratio)
		end
	end)

	sizeFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local ratio = (input.Position.X - sizeFrame.AbsolutePosition.X) / sizeFrame.AbsoluteSize.X
			updateSlider(ratio)
		end
	end)
end

createSection("— ESP —", 88)
local espToggle = createToggle("ESP", 116, "ESPEnabled")
local nameToggle = createToggle("Visa Namn", 146, "ShowName")
local healthToggle = createToggle("Visa Hälsa", 176, "ShowHealth")
local distToggle = createToggle("Visa Avstånd", 206, "ShowDistance")
createSlider("Max Avstånd", 238, "MaxDistance", 100, 1000, false)

createSection("— Hitbox —", 290)
local hitboxToggle = createToggle("Hitbox", 318, "HitboxEnabled")
local showHitboxToggle = createToggle("Visa Hitbox", 348, "ShowHitbox")
createSlider("Storlek", 380, "HitboxSize", 10, 100, true)

-- Spara config knapp
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -20, 0, 26)
saveBtn.Position = UDim2.new(0, 10, 0, 432)
saveBtn.BackgroundColor3 = RED
saveBtn.TextColor3 = WHITE
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.Text = "💾 Spara Config"
saveBtn.BorderSizePixel = 0
saveBtn.Parent = mainFrame
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

saveBtn.MouseButton1Click:Connect(function()
	saveConfig()
	saveBtn.Text = "✅ Sparad!"
	task.wait(1.5)
	saveBtn.Text = "💾 Spara Config"
end)

-- =====================
-- Höger Shift toggle
-- =====================
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		guiVisible = not guiVisible
		mainFrame.Visible = guiVisible
	end
end)

-- =====================
-- ESP Logic
-- =====================
local function removeESP(player)
	if ESPObjects[player] then
		ESPObjects[player]:Destroy()
		ESPObjects[player] = nil
	end
end

local function createESP(player)
	if player == localPlayer then return end
	removeESP(player)

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 55)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false
	billboard.Enabled = false

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Settings.EnemyColor
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextScaled = false
	nameLabel.Parent = billboard

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "InfoLabel"
	infoLabel.Size = UDim2.new(1, 0, 0.55, 0)
	infoLabel.Position = UDim2.new(0, 0, 0.45, 0)
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = Settings.TextColor
	infoLabel.TextStrokeTransparency = 0
	infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 14
	infoLabel.TextScaled = false
	infoLabel.Parent = billboard

	ESPObjects[player] = billboard

	local function attachESP(character)
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root then
			billboard.Adornee = root
			billboard.Parent = root
		end
	end

	if player.Character then attachESP(player.Character) end
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		attachESP(character)
	end)
end

-- =====================
-- Hitbox Logic
-- =====================
local function removeHitbox(player)
	if HitboxObjects[player] then
		local root = HitboxObjects[player]
		if root and root.Parent and OriginalSizes[player] then
			root.Size = OriginalSizes[player]
			root.Transparency = 1
			root.Material = Enum.Material.SmoothPlastic
			root.Color = Color3.fromRGB(163, 162, 165)
		end
		HitboxObjects[player] = nil
		OriginalSizes[player] = nil
	end
end

local function createHitbox(player)
	if player == localPlayer then return end
	removeHitbox(player)

	local function applyHitbox(character)
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if not root then return end
		OriginalSizes[player] = root.Size
		HitboxObjects[player] = root
		root.Size = Settings.HitboxSize
		if Settings.ShowHitbox then
			root.Transparency = Settings.HitboxTransparency
			root.Material = Enum.Material.ForceField
			root.Color = Settings.HitboxColor
		end
	end

	if player.Character then applyHitbox(player.Character) end
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		applyHitbox(character)
	end)
end

-- =====================
-- Render Loop
-- =====================
RunService.RenderStepped:Connect(function()
	for player, billboard in pairs(ESPObjects) do
		if not billboard or not billboard.Parent then continue end
		local character = player.Character
		local localCharacter = localPlayer.Character
		if not Settings.ESPEnabled or not character or not localCharacter then
			billboard.Enabled = false
			continue
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not root or not localRoot or not humanoid or humanoid.Health <= 0 then
			billboard.Enabled = false
			continue
		end
		local distance = (root.Position - localRoot.Position).Magnitude
		if distance > Settings.MaxDistance then
			billboard.Enabled = false
			continue
		end
		billboard.Enabled = true
		billboard.NameLabel.Text = Settings.ShowName and player.Name or ""
		local info = ""
		if Settings.ShowHealth then
			info = "❤️ " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
		end
		if Settings.ShowDistance then
			info = info .. (info ~= "" and "  " or "") .. "📍 " .. math.floor(distance)
		end
		billboard.InfoLabel.Text = info
	end

	for player, root in pairs(HitboxObjects) do
		if not root or not root.Parent then continue end
		if Settings.HitboxEnabled then
			root.Size = Settings.HitboxSize
			if Settings.ShowHitbox then
				root.Transparency = Settings.HitboxTransparency
				root.Material = Enum.Material.ForceField
				root.Color = Settings.HitboxColor
			else
				root.Transparency = 1
				root.Material = Enum.Material.SmoothPlastic
			end
		else
			if OriginalSizes[player] then
				root.Size = OriginalSizes[player]
				root.Transparency = 1
				root.Material = Enum.Material.SmoothPlastic
				root.Color = Color3.fromRGB(163, 162, 165)
			end
		end
	end
end)

-- Init + ladda config
loadConfig()
for k, updater in pairs(sliderUpdaters) do
	updater()
end

for _, p in ipairs(Players:GetPlayers()) do
	createESP(p)
	createHitbox(p)
end

Players.PlayerAdded:Connect(function(p)
	createESP(p)
	createHitbox(p)
end)

Players.PlayerRemoving:Connect(function(p)
	removeESP(p)
	removeHitbox(p)
end)

print("🥔 pringles smatrish' laddat!")
