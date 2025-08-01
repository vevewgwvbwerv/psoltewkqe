-- Egg Replacement Diagnostic - Find out what's happening with egg pet
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("EggDiagnostic_GUI") then 
    CoreGui.EggDiagnostic_GUI:Destroy() 
end

-- Storage
local isMonitoring = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "EggDiagnostic_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.7, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔍 Egg Replacement Diagnostic"
titleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Monitor Button
local monitorBtn = Instance.new("TextButton", mainFrame)
monitorBtn.Size = UDim2.new(1, -10, 0, 30)
monitorBtn.Position = UDim2.new(0, 5, 0.18, 0)
monitorBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
monitorBtn.TextColor3 = Color3.new(1, 1, 1)
monitorBtn.Font = Enum.Font.GothamBold
monitorBtn.TextSize = 14
monitorBtn.Text = "🔍 START MONITORING"

-- Info Labels
local infoLabel1 = Instance.new("TextLabel", mainFrame)
infoLabel1.Size = UDim2.new(1, -10, 0, 25)
infoLabel1.Position = UDim2.new(0, 5, 0.35, 0)
infoLabel1.BackgroundTransparency = 1
infoLabel1.Text = "Info1: Ready"
infoLabel1.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel1.Font = Enum.Font.Code
infoLabel1.TextSize = 12
infoLabel1.TextXAlignment = Enum.TextXAlignment.Left

local infoLabel2 = Instance.new("TextLabel", mainFrame)
infoLabel2.Size = UDim2.new(1, -10, 0, 25)
infoLabel2.Position = UDim2.new(0, 5, 0.5, 0)
infoLabel2.BackgroundTransparency = 1
infoLabel2.Text = "Info2: Ready"
infoLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel2.Font = Enum.Font.Code
infoLabel2.TextSize = 12
infoLabel2.TextXAlignment = Enum.TextXAlignment.Left

local infoLabel3 = Instance.new("TextLabel", mainFrame)
infoLabel3.Size = UDim2.new(1, -10, 0, 25)
infoLabel3.Position = UDim2.new(0, 5, 0.65, 0)
infoLabel3.BackgroundTransparency = 1
infoLabel3.Text = "Info3: Ready"
infoLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel3.Font = Enum.Font.Code
infoLabel3.TextSize = 12
infoLabel3.TextXAlignment = Enum.TextXAlignment.Left

local infoLabel4 = Instance.new("TextLabel", mainFrame)
infoLabel4.Size = UDim2.new(1, -10, 0, 25)
infoLabel4.Position = UDim2.new(0, 5, 0.8, 0)
infoLabel4.BackgroundTransparency = 1
infoLabel4.Text = "Info4: Ready"
infoLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel4.Font = Enum.Font.Code
infoLabel4.TextSize = 12
infoLabel4.TextXAlignment = Enum.TextXAlignment.Left

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: Analyze egg pet in detail
local function analyzeEggPet(eggPet)
    infoLabel1.Text = "Info1: Analyzing " .. eggPet.Name
    
    -- Count parts
    local children = eggPet:GetChildren()
    local descendants = eggPet:GetDescendants()
    local baseParts = {}
    
    for _, desc in pairs(descendants) do
        if desc:IsA("BasePart") then
            table.insert(baseParts, desc)
        end
    end
    
    infoLabel2.Text = "Info2: Children=" .. #children .. " Descendants=" .. #descendants .. " Parts=" .. #baseParts
    
    -- Find primary part
    local primaryPart = eggPet.PrimaryPart or eggPet:FindFirstChildWhichIsA("BasePart")
    if primaryPart then
        infoLabel3.Text = "Info3: Primary=" .. primaryPart.Name .. " Size=" .. tostring(primaryPart.Size)
        infoLabel4.Text = "Info4: Pos=" .. tostring(primaryPart.CFrame.Position)
    else
        infoLabel3.Text = "Info3: NO PRIMARY PART FOUND!"
        infoLabel4.Text = "Info4: Cannot get position"
    end
    
    print("🔍 EGG PET ANALYSIS:")
    print("  Name:", eggPet.Name)
    print("  Children:", #children)
    print("  Descendants:", #descendants)
    print("  BaseParts:", #baseParts)
    
    for i, part in ipairs(baseParts) do
        print("  Part[" .. i .. "]:", part.Name, "Size:", part.Size, "Transparency:", part.Transparency)
    end
    
    if primaryPart then
        print("  Primary Part:", primaryPart.Name)
        print("  Position:", primaryPart.CFrame.Position)
        print("  Size:", primaryPart.Size)
    end
end

-- Function: Test replacement without actually replacing
local function testReplacement(eggPet)
    print("🧪 TESTING REPLACEMENT FOR:", eggPet.Name)
    
    -- Check hand pet
    local character = LocalPlayer.Character
    if not character then
        print("❌ No character")
        return
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ No tool in hand")
        return
    end
    
    print("✅ Hand pet:", tool.Name)
    
    -- Analyze both pets
    print("📊 EGG PET ANALYSIS:")
    analyzeEggPet(eggPet)
    
    print("📊 HAND PET ANALYSIS:")
    local handChildren = tool:GetChildren()
    local handDescendants = tool:GetDescendants()
    local handBaseParts = {}
    
    for _, desc in pairs(handDescendants) do
        if desc:IsA("BasePart") then
            table.insert(handBaseParts, desc)
        end
    end
    
    print("  Hand pet children:", #handChildren)
    print("  Hand pet descendants:", #handDescendants)
    print("  Hand pet BaseParts:", #handBaseParts)
    
    -- Show what would happen
    print("🔄 REPLACEMENT SIMULATION:")
    print("  Would hide", #baseParts, "parts from egg pet")
    print("  Would show", #handBaseParts, "parts from hand pet")
    
    infoLabel1.Text = "Info1: TEST COMPLETE - Check console (F9)"
end

-- Monitor Workspace.Visuals with detailed analysis
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    infoLabel1.Text = "Info1: Visuals found, ready to monitor"
    
    visuals.ChildAdded:Connect(function(child)
        if not isMonitoring then return end
        
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
                
                -- Wait a moment for it to load
                task.wait(0.2)
                
                -- Test replacement
                testReplacement(child)
            else
                print("⚠️ Non-pet model:", child.Name, child.ClassName)
            end
        else
            print("⚠️ Non-model object:", child.Name, child.ClassName)
        end
    end)
else
    infoLabel1.Text = "Info1: ERROR - Workspace.Visuals not found!"
end

-- Button event
monitorBtn.MouseButton1Click:Connect(function()
    isMonitoring = not isMonitoring
    
    if isMonitoring then
        monitorBtn.Text = "🔍 MONITORING ACTIVE"
        monitorBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        infoLabel1.Text = "Info1: Monitoring for egg pets..."
        infoLabel2.Text = "Info2: Open an egg to see analysis"
        infoLabel3.Text = "Info3: Check console (F9) for details"
        infoLabel4.Text = "Info4: Ready"
    else
        monitorBtn.Text = "🔍 START MONITORING"
        monitorBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        infoLabel1.Text = "Info1: Monitoring stopped"
        infoLabel2.Text = "Info2: Ready"
        infoLabel3.Text = "Info3: Ready"
        infoLabel4.Text = "Info4: Ready"
    end
end)

print("🔍 Egg Replacement Diagnostic loaded!")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Click 'START MONITORING'")
print("3. Open egg")
print("4. Check console (F9) for detailed analysis")
print("5. This will show what's wrong with replacement!")
