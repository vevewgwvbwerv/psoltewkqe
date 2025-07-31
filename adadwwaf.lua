-- Instant Auto Pet Replacer - IMMEDIATE replacement, no delays
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
titleLabel.Text = "⚡ Instant Pet Replacer"
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
toggleBtn.Text = "❌ Instant Replace: OFF"

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

-- Function: Get pet from hand INSTANTLY
local function getHandPetInstant()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    print("⚡ INSTANT pet scan:", tool.Name)
    
    -- Create model from tool INSTANTLY
    local petModel = Instance.new("Model")
    petModel.Name = tool.Name
    
    -- Clone all children INSTANTLY
    for _, child in pairs(tool:GetChildren()) do
        local childClone = child:Clone()
        childClone.Parent = petModel
    end
    
    -- Configure for display INSTANTLY
    for _, part in pairs(petModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
            part.Transparency = 0
        end
    end
    
    return petModel
end

-- Function: INSTANT replacement - NO DELAYS!
local function instantReplace(tempModel)
    if not tempModel then return false end
    
    print("⚡ INSTANT REPLACE:", tempModel.Name)
    
    -- Get hand pet INSTANTLY
    local handPet = getHandPetInstant()
    if not handPet then
        print("❌ No hand pet")
        return false
    end
    
    -- Get position INSTANTLY
    local tempPrimaryPart = tempModel.PrimaryPart or tempModel:FindFirstChildWhichIsA("BasePart")
    if not tempPrimaryPart then
        print("❌ No temp primary part")
        return false
    end
    
    local targetCFrame = tempPrimaryPart.CFrame
    local targetSize = tempPrimaryPart.Size
    
    -- Position hand pet INSTANTLY
    local handPrimaryPart = handPet.PrimaryPart or handPet:FindFirstChildWhichIsA("BasePart")
    if handPrimaryPart then
        handPrimaryPart.CFrame = targetCFrame
        handPrimaryPart.Size = targetSize
    end
    
    -- HIDE ORIGINAL FIRST (INSTANTLY!)
    for _, part in pairs(tempModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    
    -- ADD REPLACEMENT IMMEDIATELY AFTER HIDING
    handPet.Parent = Workspace
    
    print("⚡ INSTANT replacement done!")
    debugLabel.Text = "Debug: INSTANT " .. handPet.Name
    
    -- Clean up after 4 seconds (normal duration)
    game:GetService("Debris"):AddItem(handPet, 4)
    
    return true
end

-- Monitor Workspace.Visuals with INSTANT response
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(descendant)
        if not isReplacementActive then return end
        
        if descendant:IsA("Model") then
            print("⚡ NEW MODEL DETECTED:", descendant.Name)
            
            -- Check if pet model
            local isPetModel = false
            for _, petName in ipairs(petNames) do
                if descendant.Name == petName then
                    isPetModel = true
                    break
                end
            end
            
            if isPetModel then
                print("⚡ PET DETECTED - INSTANT REPLACE!")
                debugLabel.Text = "Debug: INSTANT " .. descendant.Name
                
                -- NO DELAYS! INSTANT REPLACEMENT!
                if instantReplace(descendant) then
                    statusLabel.Text = "Status: INSTANT " .. descendant.Name
                else
                    statusLabel.Text = "Status: INSTANT failed"
                end
            else
                print("⚠️ Not a pet:", descendant.Name)
            end
        end
    end)
else
    print("⚠️ Workspace.Visuals not found!")
    statusLabel.Text = "Status: Visuals not found"
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isReplacementActive = not isReplacementActive
    
    if isReplacementActive then
        toggleBtn.Text = "⚡ Instant Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        statusLabel.Text = "Status: INSTANT mode active"
        debugLabel.Text = "Debug: INSTANT ready"
    else
        toggleBtn.Text = "❌ Instant Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("⚡ INSTANT Auto Pet Replacer loaded!")
print("🚀 Features:")
print("  ⚡ ZERO delays")
print("  ⚡ INSTANT hide original")
print("  ⚡ INSTANT show replacement")
print("  ⚡ NO waiting periods")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Instant Replace'")
print("3. Open egg")
print("4. See INSTANT replacement!")
