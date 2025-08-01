-- Fixed Positioning - Use VISIBLE part for positioning, not invisible RootPart
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("FixedPositioning_GUI") then 
    CoreGui.FixedPositioning_GUI:Destroy() 
end

-- Storage
local isReplacementActive = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "FixedPositioning_GUI"
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
titleLabel.Text = "🎯 Fixed Positioning"
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
toggleBtn.Text = "❌ Fixed Replace: OFF"

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

-- Function: Find VISIBLE part for positioning (not invisible RootPart)
local function findVisiblePart(model)
    local visibleParts = {}
    
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            table.insert(visibleParts, part)
        end
    end
    
    if #visibleParts > 0 then
        -- Find the biggest visible part (usually Torso or Head)
        local biggestPart = visibleParts[1]
        for _, part in ipairs(visibleParts) do
            if part.Size.Magnitude > biggestPart.Size.Magnitude then
                biggestPart = part
            end
        end
        
        print("🎯 Found visible part for positioning:", biggestPart.Name, "Size:", biggestPart.Size)
        return biggestPart
    end
    
    print("❌ No visible parts found!")
    return nil
end

-- Function: Create stable copy (WORKING METHOD)
local function createStableCopy()
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
    
    print("✅ Creating stable copy of:", tool.Name)
    
    -- Clone the tool
    local toolClone = tool:Clone()
    toolClone.Name = toolClone.Name .. "_FixedCopy"
    
    -- Anchor ALL parts to prevent falling
    for _, part in pairs(toolClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0  -- Make sure all parts are visible
            
            print("🔧 Anchored:", part.Name, "Transparency:", part.Transparency)
        end
    end
    
    -- Add to workspace
    toolClone.Parent = Workspace
    
    print("🎉 Stable copy created!")
    return toolClone
end

-- Function: Replace with VISIBLE part positioning
local function replaceWithVisiblePositioning(eggPet)
    if not eggPet then return false end
    
    print("🎯 REPLACING WITH VISIBLE POSITIONING:", eggPet.Name)
    
    -- Find VISIBLE part in egg pet (not invisible RootPart)
    local eggVisiblePart = findVisiblePart(eggPet)
    if not eggVisiblePart then
        print("❌ No visible part in egg pet")
        return false
    end
    
    local targetPosition = eggVisiblePart.CFrame
    print("📍 Target position from VISIBLE part:", eggVisiblePart.Name, targetPosition)
    
    -- Create stable copy
    local stableCopy = createStableCopy()
    if not stableCopy then
        print("❌ Failed to create stable copy")
        return false
    end
    
    -- Find VISIBLE part in hand pet copy
    local handVisiblePart = findVisiblePart(stableCopy)
    if handVisiblePart then
        handVisiblePart.CFrame = targetPosition
        print("✅ Positioned VISIBLE part:", handVisiblePart.Name, "at target")
    else
        print("⚠️ No visible part in hand copy, using fallback")
        local anyPart = stableCopy:FindFirstChildWhichIsA("BasePart")
        if anyPart then
            anyPart.CFrame = targetPosition
        end
    end
    
    -- Hide egg pet
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    print("🙈 Egg pet hidden")
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(stableCopy, 4)
    
    print("🎯 VISIBLE POSITIONING REPLACEMENT SUCCESSFUL!")
    debugLabel.Text = "Debug: VISIBLE " .. eggPet.Name
    
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
                statusLabel.Text = "Status: VISIBLE replacing " .. child.Name
                
                -- Small delay
                task.wait(0.1)
                
                -- Replace using VISIBLE positioning
                if replaceWithVisiblePositioning(child) then
                    statusLabel.Text = "Status: VISIBLE SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: VISIBLE FAILED " .. child.Name
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
        toggleBtn.Text = "🎯 Fixed Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 120)
        statusLabel.Text = "Status: VISIBLE positioning active"
        debugLabel.Text = "Debug: Using VISIBLE parts"
    else
        toggleBtn.Text = "❌ Fixed Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("🎯 Fixed Positioning loaded!")
print("✅ Key fix:")
print("  🎯 Uses VISIBLE parts for positioning")
print("  🎯 Ignores invisible RootPart")
print("  🎯 Finds biggest visible part (Torso/Head)")
print("  🎯 Positions based on visible geometry")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Fixed Replace'")
print("3. Open egg")
print("4. Should position correctly using visible parts!")
