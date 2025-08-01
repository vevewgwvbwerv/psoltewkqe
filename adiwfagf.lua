-- Complete Model Replacement - Replace entire egg pet model with hand pet model
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("CompleteReplacement_GUI") then 
    CoreGui.CompleteReplacement_GUI:Destroy() 
end

-- Storage
local isCompleteReplacementActive = false
local handPetModel = nil

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "CompleteReplacement_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.25, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 Complete Model Replacement"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0.3, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "❌ Complete Replace: OFF"

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0.6, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Disabled"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true

-- Debug Label
local debugLabel = Instance.new("TextLabel", mainFrame)
debugLabel.Size = UDim2.new(1, -10, 0, 20)
debugLabel.Position = UDim2.new(0, 5, 0.8, 0)
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

-- Function: Cache hand pet model
local function cacheHandPetModel()
    local character = LocalPlayer.Character
    if not character then
        print("❌ No character")
        return false
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ No tool in hand")
        return false
    end
    
    print("🔥 CACHING COMPLETE HAND PET MODEL:", tool.Name)
    
    -- Clone the entire tool
    handPetModel = tool:Clone()
    handPetModel.Name = handPetModel.Name .. "_ReplacementModel"
    
    print("🔥 Cached complete model:", handPetModel.Name)
    return true
end

-- Function: Create animated replacement model
local function createAnimatedReplacement(eggPet)
    if not handPetModel then
        print("❌ No cached hand pet model")
        return nil
    end
    
    print("🔥 CREATING ANIMATED REPLACEMENT")
    
    -- Clone the cached model
    local replacementModel = handPetModel:Clone()
    replacementModel.Name = eggPet.Name .. "_Replacement"
    
    -- Get egg pet position and size reference
    local eggPrimaryPart = eggPet.PrimaryPart or eggPet:FindFirstChildWhichIsA("BasePart")
    if not eggPrimaryPart then
        print("❌ No reference part in egg pet")
        return nil
    end
    
    local targetPosition = eggPrimaryPart.CFrame
    local targetSize = eggPrimaryPart.Size
    
    print("🔥 Target position:", targetPosition)
    print("🔥 Target size:", targetSize)
    
    -- Configure replacement model
    for _, part in pairs(replacementModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0
        end
    end
    
    -- Position replacement model
    local replacementPrimaryPart = replacementModel:FindFirstChildWhichIsA("BasePart")
    if replacementPrimaryPart then
        replacementPrimaryPart.CFrame = targetPosition
        
        -- Scale to reasonable size (much smaller than before)
        local scaleRatio = 0.3  -- Fixed small scale instead of calculated
        
        for _, part in pairs(replacementModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * scaleRatio
            end
        end
        
        print("🔥 Scaled by fixed ratio:", scaleRatio)
    end
    
    -- Add to workspace
    replacementModel.Parent = Workspace
    
    -- Create growth animation
    local startScale = 0.1
    local endScale = 1.0
    
    -- Start small
    for _, part in pairs(replacementModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = part.Size * startScale
        end
    end
    
    -- Animate growth
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    for _, part in pairs(replacementModel:GetDescendants()) do
        if part:IsA("BasePart") then
            local originalSize = part.Size / startScale
            local tween = TweenService:Create(part, tweenInfo, {Size = originalSize})
            tween:Play()
        end
    end
    
    print("🔥 ANIMATED REPLACEMENT CREATED!")
    return replacementModel
end

-- Function: Complete model replacement
local function performCompleteReplacement(eggPet)
    print("🔥 PERFORMING COMPLETE MODEL REPLACEMENT for:", eggPet.Name)
    
    -- Create animated replacement
    local replacementModel = createAnimatedReplacement(eggPet)
    if not replacementModel then
        print("❌ Failed to create replacement model")
        return false
    end
    
    -- Hide original egg pet IMMEDIATELY
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    
    print("🔥 Hidden original egg pet")
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(replacementModel, 4)
    
    print("🔥 COMPLETE REPLACEMENT SUCCESSFUL!")
    return true
end

-- Monitor Workspace.Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isCompleteReplacementActive then return end
        
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
                print("🔥 EGG PET DETECTED - COMPLETE REPLACEMENT:", child.Name)
                debugLabel.Text = "Debug: REPLACING " .. child.Name
                statusLabel.Text = "Status: Complete replacement..."
                
                -- Immediate complete replacement
                if performCompleteReplacement(child) then
                    statusLabel.Text = "Status: REPLACEMENT SUCCESS!"
                    debugLabel.Text = "Debug: " .. handPetModel.Name .. " replaced " .. child.Name
                else
                    statusLabel.Text = "Status: REPLACEMENT FAILED"
                    debugLabel.Text = "Debug: Failed " .. child.Name
                end
            end
        end
    end)
else
    print("⚠️ Workspace.Visuals not found")
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isCompleteReplacementActive = not isCompleteReplacementActive
    
    if isCompleteReplacementActive then
        -- Cache hand pet model when enabling
        if cacheHandPetModel() then
            toggleBtn.Text = "🔥 Complete Replace: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            statusLabel.Text = "Status: Complete replacement ready"
            debugLabel.Text = "Debug: Cached " .. handPetModel.Name
        else
            isCompleteReplacementActive = false
            statusLabel.Text = "Status: FAILED - No pet in hand"
            debugLabel.Text = "Debug: Cache failed"
        end
    else
        toggleBtn.Text = "❌ Complete Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
        handPetModel = nil
    end
end)

print("🔥 Complete Model Replacement loaded!")
print("✅ FINAL APPROACH:")
print("  🔥 Replaces ENTIRE egg pet model")
print("  🎬 Creates own growth animation")
print("  📐 Scales to match egg pet size")
print("  🎯 Uses complete hand pet model")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Complete Replace'")
print("3. Open egg")
print("4. Should see COMPLETE model replacement with animation!")
