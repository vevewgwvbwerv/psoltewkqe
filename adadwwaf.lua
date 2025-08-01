-- Automatic Pet Replacer - Auto-scan pet in hand and replace temporary models
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
mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 100)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔄 Auto Pet Replacer"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
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
toggleBtn.Text = "❌ Auto Replace: OFF"

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

-- Function: Auto-scan pet in hand
local function autoScanPetInHand()
    local character = LocalPlayer.Character
    if not character then
        print("⚠️ No character found")
        return nil
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("⚠️ No pet in hand")
        return nil
    end
    
    print("🔍 Auto-scanning pet in hand:", tool.Name)
    
    -- Create a proper model from the tool
    local petModel = Instance.new("Model")
    petModel.Name = tool.Name
    
    -- Clone ALL descendants from tool to model (including nested parts)
    for _, descendant in pairs(tool:GetDescendants()) do
        if descendant:IsA("BasePart") or descendant:IsA("Attachment") or descendant:IsA("Motor6D") or descendant:IsA("Weld") then
            local clone = descendant:Clone()
            clone.Parent = petModel
        end
    end
    
    -- Ensure proper configuration for display
    for _, part in pairs(petModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = true  -- ANCHOR to prevent falling
            part.Transparency = 0
        end
    end
    
    print("✅ Auto-scanned pet:", petModel.Name)
    return petModel
end

-- Function: Replace temporary model with auto-scanned pet
local function replaceWithHandPet(tempModel)
    if not tempModel then return false end
    
    print("🔄 Auto-replacing temporary model:", tempModel.Name)
    
    -- Auto-scan pet in hand
    local handPet = autoScanPetInHand()
    if not handPet then
        print("❌ No pet in hand to replace with")
        return false
    end
    
    -- Get position of temporary model
    local tempPrimaryPart = tempModel.PrimaryPart or tempModel:FindFirstChildWhichIsA("BasePart")
    if not tempPrimaryPart then
        print("❌ No BasePart found in temporary model")
        return false
    end
    
    local targetPosition = tempPrimaryPart.CFrame
    local targetSize = tempPrimaryPart.Size
    
    print("📍 Target position:", targetPosition)
    print("📏 Target size:", targetSize)
    
    -- Position the hand pet clone
    local clonePrimaryPart = handPet.PrimaryPart or handPet:FindFirstChildWhichIsA("BasePart")
    if clonePrimaryPart then
        clonePrimaryPart.CFrame = targetPosition
        clonePrimaryPart.Size = targetSize  -- Match size of temporary model
        
        -- Make sure all parts match the temporary model's scale
        local sizeRatio = targetSize.Magnitude / clonePrimaryPart.Size.Magnitude
        for _, part in pairs(handPet:GetDescendants()) do
            if part:IsA("BasePart") and part ~= clonePrimaryPart then
                part.Size = part.Size * sizeRatio
            end
        end
        
        print("✅ Hand pet positioned and scaled")
    end
    
    -- Add to workspace FIRST
    handPet.Parent = Workspace
    print("✅ Hand pet added to Workspace")
    
    -- Hide the original temporary model
    for _, part in pairs(tempModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    print("🙈 Original temporary model hidden")
    
    -- Clean up after natural duration
    game:GetService("Debris"):AddItem(handPet, 4)
    
    print("🎉 Auto-replacement successful!")
    debugLabel.Text = "Debug: Replaced with " .. handPet.Name
    
    return true
end

-- Monitor for temporary pet models in Workspace.Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(descendant)
        if not isReplacementActive then return end
        
        if descendant:IsA("Model") then
            print("🔍 New model in Visuals:", descendant.Name)
            
            -- Check if this is a pet model (not egg or effect)
            local isPetModel = false
            for _, petName in ipairs(petNames) do
                if descendant.Name == petName then
                    isPetModel = true
                    break
                end
            end
            
            if isPetModel then
                print("🎯 Pet model detected:", descendant.Name)
                debugLabel.Text = "Debug: Found " .. descendant.Name
                
                -- Small delay to ensure model is fully loaded
                task.wait(0.1)
                
                -- Auto-replace with pet in hand
                if replaceWithHandPet(descendant) then
                    statusLabel.Text = "Status: Replaced " .. descendant.Name
                else
                    statusLabel.Text = "Status: Replacement failed"
                end
            else
                print("⚠️ Ignoring non-pet model:", descendant.Name)
            end
        end
    end)
else
    print("⚠️ Workspace.Visuals not found - monitoring disabled!")
    statusLabel.Text = "Status: Visuals not found"
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isReplacementActive = not isReplacementActive
    
    if isReplacementActive then
        toggleBtn.Text = "✅ Auto Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        statusLabel.Text = "Status: Monitoring for pets..."
        debugLabel.Text = "Debug: Active"
    else
        toggleBtn.Text = "❌ Auto Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("🔄 Auto Pet Replacer loaded!")
print("📋 Instructions:")
print("1. Hold any pet in your hand")
print("2. Enable 'Auto Replace'")
print("3. Open an egg")
print("4. Watch automatic replacement!")
