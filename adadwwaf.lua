-- Full Model Positioning - Move ENTIRE pet model, not just one part
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("FullModelPositioning_GUI") then 
    CoreGui.FullModelPositioning_GUI:Destroy() 
end

-- Storage
local isReplacementActive = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "FullModelPositioning_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 240, 0, 130)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.25, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎯 Full Model Positioning"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0.3, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "❌ Full Replace: OFF"

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

-- Function: Move ENTIRE model to new position
local function moveEntireModel(model, targetCFrame)
    print("🎯 Moving ENTIRE model:", model.Name, "to", targetCFrame)
    
    -- Find current primary part or any visible part
    local currentPrimaryPart = model.PrimaryPart
    if not currentPrimaryPart then
        -- Find first visible part
        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                currentPrimaryPart = part
                break
            end
        end
    end
    
    if not currentPrimaryPart then
        print("❌ No reference part found for positioning")
        return false
    end
    
    -- Calculate offset from current position
    local currentCFrame = currentPrimaryPart.CFrame
    local offset = targetCFrame * currentCFrame:Inverse()
    
    print("📍 Current position:", currentCFrame)
    print("📍 Target position:", targetCFrame)
    print("📍 Calculated offset:", offset)
    
    -- Move ALL parts by the same offset
    local partsMoved = 0
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CFrame = offset * part.CFrame
            partsMoved = partsMoved + 1
            print("  ✅ Moved part:", part.Name, "to", part.CFrame.Position)
        end
    end
    
    print("🎉 Moved", partsMoved, "parts of entire model!")
    return true
end

-- Function: Create full stable copy with proper positioning
local function createFullStableCopy(targetCFrame)
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
    
    print("✅ Creating FULL stable copy of:", tool.Name)
    
    -- Clone the tool
    local toolClone = tool:Clone()
    toolClone.Name = toolClone.Name .. "_FullCopy"
    
    -- Anchor ALL parts and make them visible
    local partsProcessed = 0
    for _, part in pairs(toolClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0  -- Force all parts visible
            partsProcessed = partsProcessed + 1
            
            print("🔧 Processed part:", part.Name, "Size:", part.Size, "Transparency:", part.Transparency)
        end
    end
    
    print("🔧 Processed", partsProcessed, "parts")
    
    -- Add to workspace FIRST
    toolClone.Parent = Workspace
    
    -- Wait a moment for it to settle
    task.wait(0.1)
    
    -- Now move ENTIRE model to target position
    if moveEntireModel(toolClone, targetCFrame) then
        print("🎉 FULL model positioned successfully!")
        return toolClone
    else
        print("❌ Failed to position full model")
        toolClone:Destroy()
        return nil
    end
end

-- Function: Replace with FULL model positioning
local function replaceWithFullModel(eggPet)
    if not eggPet then return false end
    
    print("🎯 REPLACING WITH FULL MODEL:", eggPet.Name)
    
    -- Find reference part in egg pet for target position
    local eggReferencePart = eggPet.PrimaryPart
    if not eggReferencePart then
        -- Find first visible part
        for _, part in pairs(eggPet:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                eggReferencePart = part
                break
            end
        end
    end
    
    if not eggReferencePart then
        print("❌ No reference part in egg pet")
        return false
    end
    
    local targetCFrame = eggReferencePart.CFrame
    print("📍 Target CFrame from egg pet:", eggReferencePart.Name, targetCFrame)
    
    -- Create FULL stable copy at target position
    local fullCopy = createFullStableCopy(targetCFrame)
    if not fullCopy then
        print("❌ Failed to create full copy")
        return false
    end
    
    -- Hide egg pet
    local partsHidden = 0
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            partsHidden = partsHidden + 1
        end
    end
    print("🙈 Hidden", partsHidden, "parts of egg pet")
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(fullCopy, 4)
    
    print("🎯 FULL MODEL REPLACEMENT SUCCESSFUL!")
    debugLabel.Text = "Debug: FULL " .. eggPet.Name
    
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
                print("🎯 EGG PET DETECTED:", child.Name)
                debugLabel.Text = "Debug: Found " .. child.Name
                statusLabel.Text = "Status: FULL replacing " .. child.Name
                
                -- Small delay
                task.wait(0.1)
                
                -- Replace with FULL model
                if replaceWithFullModel(child) then
                    statusLabel.Text = "Status: FULL SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: FULL FAILED " .. child.Name
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
        toggleBtn.Text = "🎯 Full Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        statusLabel.Text = "Status: FULL model active"
        debugLabel.Text = "Debug: Moving entire models"
    else
        toggleBtn.Text = "❌ Full Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("🎯 Full Model Positioning loaded!")
print("✅ Key improvements:")
print("  🎯 Moves ENTIRE model, not just one part")
print("  🎯 Calculates offset and applies to ALL parts")
print("  🎯 Preserves relative positions of all body parts")
print("  🎯 Forces all parts visible (Transparency = 0)")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Full Replace'")
print("3. Open egg")
print("4. Should show COMPLETE pet with all textures!")
