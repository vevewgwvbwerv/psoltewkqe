-- Corrected Auto Pet Replacer - Proper pet detection
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
titleLabel.Text = "✅ Corrected Pet Replacer"
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

-- Function: Get pet from hand
local function getHandPet()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    print("🔍 Getting pet from hand:", tool.Name)
    
    -- Create model from tool
    local petModel = Instance.new("Model")
    petModel.Name = tool.Name
    
    -- Clone all children
    for _, child in pairs(tool:GetChildren()) do
        local childClone = child:Clone()
        childClone.Parent = petModel
    end
    
    -- Configure parts
    for _, part in pairs(petModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
            part.Transparency = 0
        end
    end
    
    return petModel
end

-- Function: Replace pet model
local function replacePetModel(tempModel)
    if not tempModel then return false end
    
    print("🔄 Replacing pet model:", tempModel.Name)
    
    -- Get hand pet
    local handPet = getHandPet()
    if not handPet then
        print("❌ No hand pet")
        return false
    end
    
    -- Get position from temp model
    local tempPrimaryPart = tempModel.PrimaryPart or tempModel:FindFirstChildWhichIsA("BasePart")
    if not tempPrimaryPart then
        print("❌ No temp primary part")
        return false
    end
    
    -- Position hand pet
    local handPrimaryPart = handPet.PrimaryPart or handPet:FindFirstChildWhichIsA("BasePart")
    if handPrimaryPart then
        handPrimaryPart.CFrame = tempPrimaryPart.CFrame
        handPrimaryPart.Size = tempPrimaryPart.Size
    end
    
    -- Hide original
    for _, part in pairs(tempModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    
    -- Add replacement
    handPet.Parent = Workspace
    
    print("✅ Replacement successful!")
    debugLabel.Text = "Debug: Replaced " .. handPet.Name
    
    -- Clean up
    game:GetService("Debris"):AddItem(handPet, 4)
    
    return true
end

-- CORRECTED MONITORING: Monitor ALL of Workspace, not just Visuals
local function monitorWorkspaceForPets()
    -- Monitor the entire Workspace for new pet models
    Workspace.ChildAdded:Connect(function(child)
        if not isReplacementActive then return end
        
        print("🔍 New object in Workspace:", child.Name, child.ClassName)
        
        if child:IsA("Model") then
            -- Check if it's a pet model
            local isPetModel = false
            for _, petName in ipairs(petNames) do
                if child.Name == petName then
                    isPetModel = true
                    break
                end
            end
            
            if isPetModel then
                print("🎯 PET MODEL FOUND IN WORKSPACE:", child.Name)
                debugLabel.Text = "Debug: Found " .. child.Name
                statusLabel.Text = "Status: Replacing " .. child.Name
                
                -- Small delay to ensure model is loaded
                task.wait(0.05)
                
                -- Replace it
                if replacePetModel(child) then
                    statusLabel.Text = "Status: SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: FAILED " .. child.Name
                end
            else
                print("⚠️ Not a pet model:", child.Name)
            end
        end
    end)
    
    print("✅ Monitoring Workspace for pet models")
end

-- ALSO monitor Workspace.Visuals as backup
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isReplacementActive then return end
        
        print("🔍 New object in Visuals:", child.Name, child.ClassName)
        
        if child:IsA("Model") then
            -- Check if it's a pet model
            local isPetModel = false
            for _, petName in ipairs(petNames) do
                if child.Name == petName then
                    isPetModel = true
                    break
                end
            end
            
            if isPetModel then
                print("🎯 PET MODEL FOUND IN VISUALS:", child.Name)
                debugLabel.Text = "Debug: Visuals " .. child.Name
                statusLabel.Text = "Status: Visuals " .. child.Name
                
                -- Small delay
                task.wait(0.05)
                
                -- Replace it
                if replacePetModel(child) then
                    statusLabel.Text = "Status: SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: FAILED " .. child.Name
                end
            end
        end
    end)
    
    print("✅ Also monitoring Workspace.Visuals")
else
    print("⚠️ Workspace.Visuals not found")
end

-- Start monitoring
monitorWorkspaceForPets()

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isReplacementActive = not isReplacementActive
    
    if isReplacementActive then
        toggleBtn.Text = "✅ Auto Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        statusLabel.Text = "Status: Monitoring workspace..."
        debugLabel.Text = "Debug: Watching for pets"
    else
        toggleBtn.Text = "❌ Auto Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("✅ CORRECTED Auto Pet Replacer loaded!")
print("🔧 Corrections applied:")
print("  ✅ Monitoring entire Workspace")
print("  ✅ Monitoring Workspace.Visuals as backup")
print("  ✅ Ignoring EggPoof and other effects")
print("  ✅ Only targeting actual pet Models")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Auto Replace'")
print("3. Open egg")
print("4. Pet should replace correctly!")
