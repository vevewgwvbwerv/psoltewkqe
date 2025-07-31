-- Debug Auto Pet Replacer - Find out what's wrong
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
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.25, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔍 Debug Pet Replacer"
titleLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Text = "❌ Debug Replace: OFF"

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 0.45, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Disabled"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true

-- Debug Label 1
local debugLabel1 = Instance.new("TextLabel", mainFrame)
debugLabel1.Size = UDim2.new(1, -10, 0, 20)
debugLabel1.Position = UDim2.new(0, 5, 0.6, 0)
debugLabel1.BackgroundTransparency = 1
debugLabel1.Text = "Debug1: Ready"
debugLabel1.TextColor3 = Color3.fromRGB(150, 255, 150)
debugLabel1.Font = Enum.Font.Gotham
debugLabel1.TextScaled = true

-- Debug Label 2
local debugLabel2 = Instance.new("TextLabel", mainFrame)
debugLabel2.Size = UDim2.new(1, -10, 0, 20)
debugLabel2.Position = UDim2.new(0, 5, 0.75, 0)
debugLabel2.BackgroundTransparency = 1
debugLabel2.Text = "Debug2: Ready"
debugLabel2.TextColor3 = Color3.fromRGB(255, 255, 150)
debugLabel2.Font = Enum.Font.Gotham
debugLabel2.TextScaled = true

-- Debug Label 3
local debugLabel3 = Instance.new("TextLabel", mainFrame)
debugLabel3.Size = UDim2.new(1, -10, 0, 20)
debugLabel3.Position = UDim2.new(0, 5, 0.9, 0)
debugLabel3.BackgroundTransparency = 1
debugLabel3.Text = "Debug3: Ready"
debugLabel3.TextColor3 = Color3.fromRGB(255, 150, 255)
debugLabel3.Font = Enum.Font.Gotham
debugLabel3.TextScaled = true

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: Debug pet scan
local function debugScanHandPet()
    debugLabel1.Text = "Debug1: Scanning hand..."
    
    local character = LocalPlayer.Character
    if not character then
        debugLabel1.Text = "Debug1: NO CHARACTER!"
        return nil
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        debugLabel1.Text = "Debug1: NO TOOL IN HAND!"
        return nil
    end
    
    debugLabel1.Text = "Debug1: Found " .. tool.Name
    
    -- Create model
    local petModel = Instance.new("Model")
    petModel.Name = tool.Name
    
    -- Clone children
    local childCount = 0
    for _, child in pairs(tool:GetChildren()) do
        local childClone = child:Clone()
        childClone.Parent = petModel
        childCount = childCount + 1
    end
    
    debugLabel2.Text = "Debug2: Cloned " .. childCount .. " parts"
    
    -- Configure parts
    local partCount = 0
    for _, part in pairs(petModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
            part.Transparency = 0
            partCount = partCount + 1
        end
    end
    
    debugLabel3.Text = "Debug3: Config " .. partCount .. " parts"
    
    return petModel
end

-- Function: Debug replacement
local function debugReplace(tempModel)
    if not tempModel then
        debugLabel1.Text = "Debug1: NO TEMP MODEL!"
        return false
    end
    
    debugLabel1.Text = "Debug1: Replacing " .. tempModel.Name
    
    -- Get hand pet
    local handPet = debugScanHandPet()
    if not handPet then
        debugLabel1.Text = "Debug1: SCAN FAILED!"
        return false
    end
    
    -- Get positions
    local tempPrimaryPart = tempModel.PrimaryPart or tempModel:FindFirstChildWhichIsA("BasePart")
    if not tempPrimaryPart then
        debugLabel2.Text = "Debug2: NO TEMP PRIMARY!"
        return false
    end
    
    local handPrimaryPart = handPet.PrimaryPart or handPet:FindFirstChildWhichIsA("BasePart")
    if not handPrimaryPart then
        debugLabel2.Text = "Debug2: NO HAND PRIMARY!"
        return false
    end
    
    debugLabel2.Text = "Debug2: Positioning..."
    
    -- Position hand pet
    handPrimaryPart.CFrame = tempPrimaryPart.CFrame
    handPrimaryPart.Size = tempPrimaryPart.Size
    
    debugLabel3.Text = "Debug3: Hiding original..."
    
    -- Hide original
    local hiddenCount = 0
    for _, part in pairs(tempModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            hiddenCount = hiddenCount + 1
        end
    end
    
    debugLabel3.Text = "Debug3: Hidden " .. hiddenCount .. " parts"
    
    -- Add to workspace
    handPet.Parent = Workspace
    
    debugLabel1.Text = "Debug1: ADDED TO WORKSPACE!"
    debugLabel2.Text = "Debug2: Pet in workspace: " .. handPet.Name
    debugLabel3.Text = "Debug3: SUCCESS!"
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(handPet, 4)
    
    return true
end

-- Monitor Workspace.Visuals with detailed debugging
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    debugLabel1.Text = "Debug1: Visuals found!"
    
    visuals.ChildAdded:Connect(function(descendant)
        debugLabel1.Text = "Debug1: New child: " .. descendant.Name
        
        if not isReplacementActive then
            debugLabel2.Text = "Debug2: Replacement OFF"
            return
        end
        
        if descendant:IsA("Model") then
            debugLabel2.Text = "Debug2: Model detected"
            
            -- Check if pet model
            local isPetModel = false
            for _, petName in ipairs(petNames) do
                if descendant.Name == petName then
                    isPetModel = true
                    break
                end
            end
            
            if isPetModel then
                debugLabel3.Text = "Debug3: PET FOUND!"
                
                -- Try to replace
                if debugReplace(descendant) then
                    statusLabel.Text = "Status: SUCCESS " .. descendant.Name
                else
                    statusLabel.Text = "Status: FAILED " .. descendant.Name
                end
            else
                debugLabel3.Text = "Debug3: Not a pet: " .. descendant.Name
            end
        else
            debugLabel2.Text = "Debug2: Not a model: " .. descendant.ClassName
        end
    end)
else
    debugLabel1.Text = "Debug1: VISUALS NOT FOUND!"
    statusLabel.Text = "Status: NO VISUALS!"
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isReplacementActive = not isReplacementActive
    
    if isReplacementActive then
        toggleBtn.Text = "🔍 Debug Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        statusLabel.Text = "Status: DEBUG MODE ACTIVE"
        debugLabel1.Text = "Debug1: Monitoring..."
        debugLabel2.Text = "Debug2: Waiting for egg..."
        debugLabel3.Text = "Debug3: Ready to debug"
    else
        toggleBtn.Text = "❌ Debug Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel1.Text = "Debug1: Inactive"
        debugLabel2.Text = "Debug2: Inactive"
        debugLabel3.Text = "Debug3: Inactive"
    end
end)

print("🔍 DEBUG Auto Pet Replacer loaded!")
print("🔍 This version will show EXACTLY what happens:")
print("  - Debug1: Main process status")
print("  - Debug2: Secondary details")
print("  - Debug3: Final results")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Debug Replace'")
print("3. Open egg")
print("4. Watch debug messages!")
