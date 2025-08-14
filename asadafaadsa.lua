-- kumikinangina [spoofed by Adrian Scripts]

-- 🔓 spoof HWID using RbxAnalyticsService
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
hookfunction(RbxAnalyticsService.GetClientId, function()
    return "86bd1b56-962b-43ce-894e-1535e6b677bc"
end)

-- 🔑 auto insert lifetime key
getgenv().UserKey = "BVmECSjKvfyMggWPZNUVOqOmoivcmdOP"

-- 🛎️ show loading notification
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "AdrianHub V2",
        Text = "Script is running... Please wait.",
        Duration = 5
    })
end)

-- 🧽 auto remove key gui if it appears
task.spawn(function()
    repeat wait() until game.CoreGui:FindFirstChild("KeyUI") or game.Players.LocalPlayer.PlayerGui:FindFirstChild("KeyUI")
    local gui = game.CoreGui:FindFirstChild("KeyUI") or game.Players.LocalPlayer.PlayerGui:FindFirstChild("KeyUI")
    if gui then gui:Destroy() end
end)

-- 🧠 load actual spawner
local TweenService = game:GetService("TweenService")
local Spawner = loadstring(game:HttpGet("https://codeberg.org/GrowAFilipino/GrowAGarden/raw/branch/main/Spawner.lua"))()

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "SpawnerGUI"
gui.ResetOnSpawn = false

local function applyRoundCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
end

local darkBackground = Color3.fromRGB(30, 30, 30)
local darkBorder = Color3.fromRGB(50, 50, 50)
local textColor = Color3.fromRGB(255, 255, 255)
local buttonColor = Color3.fromRGB(30, 144, 255)
local buttonTextColor = Color3.fromRGB(255, 255, 255)
local categoryButtonColor = Color3.fromRGB(34, 177, 76)

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Text = "Open Spawner"
toggleButton.Size = UDim2.new(0, 130, 0, 35)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = buttonColor
toggleButton.TextColor3 = buttonTextColor
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18
applyRoundCorners(toggleButton)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 240)
frame.Position = UDim2.new(0.5, -160, 0.5, -120)
frame.BackgroundColor3 = darkBackground
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
applyRoundCorners(frame, 10)

local title = Instance.new("TextLabel", frame)
title.Text = "Adrian Scripts"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = textColor
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
applyRoundCorners(title)

local tabButtonsFrame = Instance.new("Frame", frame)
tabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
tabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
tabButtonsFrame.BackgroundColor3 = darkBorder

local function createTabButton(name, positionX)
    local button = Instance.new("TextButton", tabButtonsFrame)
    button.Text = name
    button.Size = UDim2.new(0, 100, 1, 0)
    button.Position = UDim2.new(0, positionX, 0, 0)
    button.BackgroundColor3 = categoryButtonColor
    button.TextColor3 = textColor
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    applyRoundCorners(button)
    return button
end

local petsTab = createTabButton("Pets", 0)
local seedsTab = createTabButton("Seeds", 100)
local eggsTab = createTabButton("Eggs", 200)

local contentFrame = Instance.new("Frame", frame)
contentFrame.Size = UDim2.new(1, 0, 1, -70)
contentFrame.Position = UDim2.new(0, 0, 0, 70)
contentFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
applyRoundCorners(contentFrame)

local function createTabPanel()
    local panel = Instance.new("Frame", contentFrame)
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.Visible = false
    return panel
end

local function createTextBoxInput(parent, y, placeholderText)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -20, 0, 30)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = textColor
    box.TextSize = 16
    box.Font = Enum.Font.SourceSans
    box.PlaceholderText = placeholderText
    applyRoundCorners(box)
    return box
end

local petUI = createTabPanel()
local petBox = createTextBoxInput(petUI, 0, "Pet Name (e.g. T-Rex)")
local kgBox = createTextBoxInput(petUI, 40, "Kg (e.g. 2)")
local ageBox = createTextBoxInput(petUI, 80, "Age (e.g. 1)")

local spawnPetBtn = Instance.new("TextButton", petUI)
spawnPetBtn.Text = "Spawn Pet"
spawnPetBtn.Size = UDim2.new(1, -20, 0, 30)
spawnPetBtn.Position = UDim2.new(0, 10, 0, 130)
spawnPetBtn.BackgroundColor3 = categoryButtonColor
spawnPetBtn.TextColor3 = buttonTextColor
spawnPetBtn.TextSize = 16
applyRoundCorners(spawnPetBtn)

spawnPetBtn.MouseButton1Click:Connect(function()
    local pet = petBox.Text
    local kg = tonumber(kgBox.Text)
    local age = tonumber(ageBox.Text)
    if pet ~= "" and kg and age then
        Spawner.SpawnPet(pet, kg, age)
    end
end)

local seedUI = createTabPanel()
local seedBox = createTextBoxInput(seedUI, 0, "Seed Name (e.g. Candy Blossom)")

local spawnSeedBtn = Instance.new("TextButton", seedUI)
spawnSeedBtn.Text = "Spawn Seed"
spawnSeedBtn.Size = UDim2.new(1, -20, 0, 30)
spawnSeedBtn.Position = UDim2.new(0, 10, 0, 40)
spawnSeedBtn.BackgroundColor3 = categoryButtonColor
spawnSeedBtn.TextColor3 = buttonTextColor
spawnSeedBtn.TextSize = 16
applyRoundCorners(spawnSeedBtn)

spawnSeedBtn.MouseButton1Click:Connect(function()
    if seedBox.Text ~= "" then
        Spawner.SpawnSeed(seedBox.Text)
    end
end)

local eggUI = createTabPanel()
local eggBox = createTextBoxInput(eggUI, 0, "Egg Name (e.g. Night Egg)")

local spawnEggBtn = Instance.new("TextButton", eggUI)
spawnEggBtn.Text = "Spawn Egg"
spawnEggBtn.Size = UDim2.new(1, -20, 0, 30)
spawnEggBtn.Position = UDim2.new(0, 10, 0, 40)
spawnEggBtn.BackgroundColor3 = categoryButtonColor
spawnEggBtn.TextColor3 = buttonTextColor
spawnEggBtn.TextSize = 16
applyRoundCorners(spawnEggBtn)

spawnEggBtn.MouseButton1Click:Connect(function()
    if eggBox.Text ~= "" then
        Spawner.SpawnEgg(eggBox.Text)
    end
end)

local function animateResize(targetSize)
    local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize
    })
    tween:Play()
end

local function fadeIn(content)
    for _, child in pairs(content:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Visible = true
            child.BackgroundTransparency = 1
            child.TextTransparency = 1
            local fade = TweenService:Create(child, TweenInfo.new(0.3), {
                BackgroundTransparency = 0,
                TextTransparency = 0
            })
            fade:Play()
        end
    end
end

local function showTab(tab)
    petUI.Visible = false
    seedUI.Visible = false
    eggUI.Visible = false
    tab.Visible = true
    fadeIn(tab)
    animateResize(UDim2.new(0, 320, 0, 240))
end

petsTab.MouseButton1Click:Connect(function() showTab(petUI) end)
seedsTab.MouseButton1Click:Connect(function() showTab(seedUI) end)
eggsTab.MouseButton1Click:Connect(function() showTab(eggUI) end)

local open = false
toggleButton.MouseButton1Click:Connect(function()
    open = not open
    frame.Visible = open
    toggleButton.Text = open and "Hide Spawner" or "Open Spawner"
    if open then showTab(petUI) end
end)
