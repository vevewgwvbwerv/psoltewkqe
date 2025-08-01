-- Working Egg Replacer - Replace egg pet with hand pet (WORKING VERSION)
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("WorkingEggReplacer_GUI") then 
    CoreGui.WorkingEggReplacer_GUI:Destroy() 
end

-- Storage
local isReplacementActive = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "WorkingEggReplacer_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔄 Working Egg Replacer"
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

-- Function: Create stable pet copy (WORKING METHOD)
local function createStablePetCopy()
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
    
    -- Clone the tool (WORKING METHOD)
    local toolClone = tool:Clone()
    toolClone.Name = toolClone.Name .. "_Replacement"
    
    -- CRITICAL: Anchor ALL parts to prevent falling (WORKING METHOD)
    for _, part in pairs(toolClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true  -- ANCHOR - no falling!
            part.CanCollide = false  -- No collision issues
            part.Transparency = 0  -- Make visible
            
            print("🔧 Anchored:", part.Name)
        end
    end
    
    print("🎉 Stable pet copy created!")
    return toolClone
end

-- Function: Replace egg pet with hand pet (WORKING METHOD)
local function replaceEggPet(eggPet)
    if not eggPet then return false end
    
    print("🔄 REPLACING EGG PET:", eggPet.Name)
    
    -- Create stable copy using WORKING METHOD
    local handPetCopy = createStablePetCopy()
    if not handPetCopy then
        print("❌ Failed to create hand pet copy")
        return false
    end
    
    -- Get position from egg pet
    local eggPrimaryPart = eggPet.PrimaryPart or eggPet:FindFirstChildWhichIsA("BasePart")
    if not eggPrimaryPart then
        print("❌ No primary part in egg pet")
        return false
    end
    
    local targetPosition = eggPrimaryPart.CFrame
    print("📍 Target position:", targetPosition)
    
    -- HIDE EGG PET FIRST
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    print("🙈 Egg pet hidden")
    
    -- ADD HAND PET COPY TO WORKSPACE
    handPetCopy.Parent = Workspace
    print("✅ Hand pet copy added to workspace")
    
    -- POSITION HAND PET COPY
    local handPrimaryPart = handPetCopy.PrimaryPart or handPetCopy:FindFirstChildWhichIsA("BasePart")
    if handPrimaryPart then
        handPrimaryPart.CFrame = targetPosition
        print("✅ Hand pet positioned")
    else
        handPetCopy:SetPrimaryPartCFrame(targetPosition)
        print("✅ Hand pet positioned (SetPrimaryPartCFrame)")
    end
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(handPetCopy, 4)
    
    print("🎉 EGG REPLACEMENT SUCCESSFUL!")
    debugLabel.Text = "Debug: Replaced " .. eggPet.Name
    
    return true
end

-- Monitor Workspace.Visuals for egg pets
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
                statusLabel.Text = "Status: Replacing " .. child.Name
                
                -- Small delay
                task.wait(0.1)
                
                -- Replace using WORKING METHOD
                if replaceEggPet(child) then
                    statusLabel.Text = "Status: SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: FAILED " .. child.Name
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
        toggleBtn.Text = "✅ Auto Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        statusLabel.Text = "Status: WORKING mode active"
        debugLabel.Text = "Debug: Using WORKING method"
    else
        toggleBtn.Text = "❌ Auto Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("🔄 Working Egg Replacer loaded!")
print("✅ Uses PROVEN WORKING METHOD:")
print("  ✅ Same cloning as SimpleStableCopy")
print("  ✅ Same anchoring to prevent falling")
print("  ✅ Same positioning method")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Auto Replace'")
print("3. Open egg")
print("4. Should work like SimpleStableCopy!")
