-- Exact Working Method - Use EXACTLY the same code that worked in SimpleStableCopy
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("ExactWorkingMethod_GUI") then 
    CoreGui.ExactWorkingMethod_GUI:Destroy() 
end

-- Storage
local isReplacementActive = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "ExactWorkingMethod_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⭐ Exact Working Method"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
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
toggleBtn.Text = "❌ Exact Replace: OFF"

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

-- EXACT COPY of working function from SimpleStableCopy.lua
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
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        print("❌ No HumanoidRootPart")
        return nil
    end
    
    print("✅ Creating stable copy of:", tool.Name)
    
    -- Clone the tool (EXACT SAME CODE)
    local toolClone = tool:Clone()
    toolClone.Name = toolClone.Name .. "_StableCopy"
    
    -- CRITICAL: Anchor ALL parts to prevent falling (EXACT SAME CODE)
    for _, part in pairs(toolClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true  -- ANCHOR - no falling!
            part.CanCollide = false  -- No collision issues
            part.Transparency = 0  -- Make visible
            
            print("🔧 Anchored:", part.Name, "Size:", part.Size)
        end
    end
    
    -- Add to workspace FIRST (EXACT SAME CODE)
    toolClone.Parent = Workspace
    
    print("🎉 Stable copy created and positioned!")
    
    return toolClone
end

-- Function: Replace egg pet using EXACT working method
local function replaceWithExactMethod(eggPet)
    if not eggPet then return false end
    
    print("⭐ REPLACING WITH EXACT METHOD:", eggPet.Name)
    
    -- Get egg pet position FIRST
    local eggPrimaryPart = eggPet.PrimaryPart or eggPet:FindFirstChildWhichIsA("BasePart")
    if not eggPrimaryPart then
        print("❌ No primary part in egg pet")
        return false
    end
    
    local targetPosition = eggPrimaryPart.CFrame
    print("📍 Target position:", targetPosition)
    
    -- Create stable copy using EXACT working method
    local stableCopy = createStableCopy()
    if not stableCopy then
        print("❌ Failed to create stable copy")
        return false
    end
    
    -- Position it at egg location (EXACT SAME POSITIONING CODE)
    local primaryPart = stableCopy.PrimaryPart or stableCopy:FindFirstChildWhichIsA("BasePart")
    if primaryPart then
        primaryPart.CFrame = targetPosition
        print("✅ Positioned at:", targetPosition)
    else
        print("⚠️ No primary part found, using SetPrimaryPartCFrame")
        stableCopy:SetPrimaryPartCFrame(targetPosition)
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
    
    print("⭐ EXACT METHOD REPLACEMENT SUCCESSFUL!")
    debugLabel.Text = "Debug: EXACT " .. eggPet.Name
    
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
                print("⭐ EGG PET DETECTED:", child.Name)
                debugLabel.Text = "Debug: Found " .. child.Name
                statusLabel.Text = "Status: EXACT replacing " .. child.Name
                
                -- Small delay
                task.wait(0.1)
                
                -- Replace using EXACT method
                if replaceWithExactMethod(child) then
                    statusLabel.Text = "Status: EXACT SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: EXACT FAILED " .. child.Name
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
        toggleBtn.Text = "⭐ Exact Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 0)
        statusLabel.Text = "Status: EXACT method active"
        debugLabel.Text = "Debug: Using EXACT working code"
    else
        toggleBtn.Text = "❌ Exact Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("⭐ Exact Working Method loaded!")
print("✅ Uses EXACT SAME CODE from SimpleStableCopy:")
print("  ✅ Same tool cloning")
print("  ✅ Same anchoring loop")
print("  ✅ Same workspace addition")
print("  ✅ Same positioning method")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Exact Replace'")
print("3. Open egg")
print("4. Should work EXACTLY like SimpleStableCopy!")
