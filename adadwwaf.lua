-- Force Visible Auto Pet Replacer - FORCE pet to be visible
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("AutoPetReplacer_GUI") then 
    CoreGui.AutoPetReplacer_GUI:Destroy() 
end

-- Storage
local isReplacementActive = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AutoPetReplacer_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "💥 FORCE Visible Replacer"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0.35, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "❌ Force Replace: OFF"

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0.65, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Disabled"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true

-- Debug Label
local debugLabel = Instance.new("TextLabel", mainFrame)
debugLabel.Size = UDim2.new(1, -10, 0, 20)
debugLabel.Position = UDim2.new(0, 5, 0.85, 0)
debugLabel.BackgroundTransparency = 1
debugLabel.Text = "Debug: Ready"
debugLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
debugLabel.Font = Enum.Font.Gotham
debugLabel.TextScaled = true

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: FORCE create visible pet from hand
local function forceCreateVisiblePet()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    print("💥 FORCE creating visible pet:", tool.Name)
    
    -- Create model
    local petModel = Instance.new("Model")
    petModel.Name = tool.Name
    
    -- Clone all children
    for _, child in pairs(tool:GetChildren()) do
        local childClone = child:Clone()
        childClone.Parent = petModel
    end
    
    -- FORCE VISIBILITY - make EVERYTHING visible and big
    for _, part in pairs(petModel:GetDescendants()) do
        if part:IsA("BasePart") then
            -- FORCE visible properties
            part.Transparency = 0
            part.CanCollide = false
            part.Anchored = true  -- ANCHOR to prevent falling
            
            -- FORCE bright color to make it obvious
            part.BrickColor = BrickColor.new("Really red")
            part.Material = Enum.Material.Neon
            
            -- FORCE bigger size if too small
            if part.Size.Magnitude < 2 then
                part.Size = Vector3.new(2, 2, 2)
            end
            
            print("💥 FORCED part visible:", part.Name, "Size:", part.Size)
        end
    end
    
    return petModel
end

-- Function: FORCE replacement with maximum visibility
local function forceReplacement(tempModel)
    if not tempModel then return false end
    
    print("💥 FORCE REPLACEMENT:", tempModel.Name)
    
    -- Get FORCE visible pet
    local forcePet = forceCreateVisiblePet()
    if not forcePet then
        print("❌ No force pet")
        return false
    end
    
    -- Get temp model position
    local tempPrimaryPart = tempModel.PrimaryPart or tempModel:FindFirstChildWhichIsA("BasePart")
    if not tempPrimaryPart then
        print("❌ No temp primary")
        return false
    end
    
    -- Position FORCE pet
    local forcePrimaryPart = forcePet.PrimaryPart or forcePet:FindFirstChildWhichIsA("BasePart")
    if forcePrimaryPart then
        -- Position ABOVE the temp model to make sure it's visible
        local targetCFrame = tempPrimaryPart.CFrame * CFrame.new(0, 5, 0)  -- 5 studs above
        forcePrimaryPart.CFrame = targetCFrame
        
        print("💥 FORCE positioned at:", targetCFrame)
    end
    
    -- HIDE original COMPLETELY
    tempModel:Destroy()  -- DESTROY instead of hiding
    print("💥 DESTROYED original model")
    
    -- ADD FORCE pet to workspace
    forcePet.Parent = Workspace
    print("💥 FORCE pet added to workspace")
    
    -- Make it FLASH to be extra visible
    task.spawn(function()
        for i = 1, 10 do
            for _, part in pairs(forcePet:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = i % 2 == 0 and 0 or 0.5
                end
            end
            task.wait(0.1)
        end
        
        -- Make fully visible after flashing
        for _, part in pairs(forcePet:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end)
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(forcePet, 4)
    
    print("💥 FORCE REPLACEMENT COMPLETE!")
    debugLabel.Text = "Debug: FORCED " .. forcePet.Name
    
    return true
end

-- Monitor Workspace.Visuals for pets
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isReplacementActive then return end
        
        if child:IsA("Model") then
            -- Check if pet model
            local isPetModel = false
            for _, petName in ipairs(petNames) do
                if child.Name == petName then
                    isPetModel = true
                    break
                end
            end
            
            if isPetModel then
                print("💥 PET FOUND - FORCE REPLACING:", child.Name)
                debugLabel.Text = "Debug: FORCING " .. child.Name
                statusLabel.Text = "Status: FORCING " .. child.Name
                
                -- FORCE replacement
                if forceReplacement(child) then
                    statusLabel.Text = "Status: FORCED SUCCESS"
                else
                    statusLabel.Text = "Status: FORCE FAILED"
                end
            end
        end
    end)
else
    print("⚠️ Workspace.Visuals not found")
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isReplacementActive = not isReplacementActive
    
    if isReplacementActive then
        toggleBtn.Text = "💥 Force Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 120)
        statusLabel.Text = "Status: FORCE MODE ACTIVE"
        debugLabel.Text = "Debug: FORCE ready"
    else
        toggleBtn.Text = "❌ Force Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("💥 FORCE VISIBLE Auto Pet Replacer loaded!")
print("💥 EXTREME MEASURES:")
print("  💥 BRIGHT RED NEON pets")
print("  💥 BIGGER size if too small")
print("  💥 POSITIONED ABOVE original")
print("  💥 FLASHING effect")
print("  💥 DESTROYS original instead of hiding")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Force Replace'")
print("3. Open egg")
print("4. See BRIGHT RED FLASHING pet!")
