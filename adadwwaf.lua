-- Pose Matching - Copy exact pose and orientation from egg pet
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("PoseMatching_GUI") then 
    CoreGui.PoseMatching_GUI:Destroy() 
end

-- Storage
local isReplacementActive = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PoseMatching_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 250, 0, 140)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 60)
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.25, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎭 Pose Matching"
titleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0.3, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "❌ Pose Match: OFF"

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

-- Function: Map parts by name between two models
local function mapPartsByName(sourceModel, targetModel)
    local sourceMap = {}
    local targetMap = {}
    
    -- Build maps of part names
    for _, part in pairs(sourceModel:GetDescendants()) do
        if part:IsA("BasePart") then
            sourceMap[part.Name] = part
        end
    end
    
    for _, part in pairs(targetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            targetMap[part.Name] = part
        end
    end
    
    return sourceMap, targetMap
end

-- Function: Copy exact pose from egg pet to hand pet copy
local function copyExactPose(eggPet, handPetCopy)
    print("🎭 COPYING EXACT POSE from", eggPet.Name, "to", handPetCopy.Name)
    
    -- Map parts by name
    local eggParts, handParts = mapPartsByName(eggPet, handPetCopy)
    
    local posesCopied = 0
    local posesSkipped = 0
    
    -- Copy CFrame of each matching part
    for partName, eggPart in pairs(eggParts) do
        local handPart = handParts[partName]
        if handPart then
            -- Copy exact CFrame (position + rotation)
            handPart.CFrame = eggPart.CFrame
            posesCopied = posesCopied + 1
            
            print("  🎭 Copied pose:", partName, "CFrame:", eggPart.CFrame)
        else
            posesSkipped = posesSkipped + 1
            print("  ⚠️ No matching part for:", partName)
        end
    end
    
    print("🎭 Pose copy complete:", posesCopied, "copied,", posesSkipped, "skipped")
    return posesCopied > 0
end

-- Function: Create copy with exact pose matching
local function createPoseMatchedCopy(eggPet)
    local character = LocalPlayer.Character
    if not character then
        print("❌ No character")
        return nil
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ No tool in hand")
        return nil
    end
    
    print("✅ Creating POSE-MATCHED copy of:", tool.Name)
    
    -- Clone the tool
    local toolClone = tool:Clone()
    toolClone.Name = toolClone.Name .. "_PoseMatched"
    
    -- Anchor ALL parts and make them visible
    local partsProcessed = 0
    for _, part in pairs(toolClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0  -- Force all parts visible
            partsProcessed = partsProcessed + 1
        end
    end
    
    print("🔧 Processed", partsProcessed, "parts")
    
    -- Add to workspace FIRST
    toolClone.Parent = Workspace
    
    -- Wait a moment for it to settle
    task.wait(0.1)
    
    -- Copy EXACT pose from egg pet
    if copyExactPose(eggPet, toolClone) then
        print("🎭 POSE MATCHING SUCCESSFUL!")
        return toolClone
    else
        print("❌ Failed to match pose")
        toolClone:Destroy()
        return nil
    end
end

-- Function: Replace with pose-matched copy
local function replaceWithPoseMatching(eggPet)
    if not eggPet then return false end
    
    print("🎭 REPLACING WITH POSE MATCHING:", eggPet.Name)
    
    -- Create pose-matched copy
    local poseMatchedCopy = createPoseMatchedCopy(eggPet)
    if not poseMatchedCopy then
        print("❌ Failed to create pose-matched copy")
        return false
    end
    
    -- Hide egg pet IMMEDIATELY (no delay)
    local partsHidden = 0
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            partsHidden = partsHidden + 1
        end
    end
    print("🙈 Hidden", partsHidden, "parts of egg pet IMMEDIATELY")
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(poseMatchedCopy, 4)
    
    print("🎭 POSE MATCHING REPLACEMENT SUCCESSFUL!")
    debugLabel.Text = "Debug: POSE " .. eggPet.Name
    
    return true
end

-- Monitor Workspace.Visuals
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
                print("🎭 EGG PET DETECTED:", child.Name)
                debugLabel.Text = "Debug: Found " .. child.Name
                statusLabel.Text = "Status: POSE matching " .. child.Name
                
                -- NO DELAY - immediate replacement
                if replaceWithPoseMatching(child) then
                    statusLabel.Text = "Status: POSE SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: POSE FAILED " .. child.Name
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
        toggleBtn.Text = "🎭 Pose Match: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 120)
        statusLabel.Text = "Status: POSE matching active"
        debugLabel.Text = "Debug: Copying exact poses"
    else
        toggleBtn.Text = "❌ Pose Match: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("🎭 Pose Matching loaded!")
print("✅ Key improvements:")
print("  🎭 Copies EXACT pose from egg pet")
print("  🎭 Maps parts by name between models")
print("  🎭 Copies CFrame (position + rotation) of each part")
print("  🎭 IMMEDIATE replacement (no delay)")
print("  🎭 Should match standing pose perfectly!")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Pose Match'")
print("3. Open egg")
print("4. Should show pet in EXACT same pose as egg!")
