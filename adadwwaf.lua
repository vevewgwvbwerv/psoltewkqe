-- Proper Model Auto Pet Replacer - Clone the Model inside Tool, not Handle
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
titleLabel.Text = "🔄 Proper Model Replacer"
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

-- Function: Get PROPER pet model from hand (the Model inside Tool, not Handle)
local function getProperPetModel()
    local character = LocalPlayer.Character
    if not character then
        print("❌ No character found")
        return nil
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ No pet in hand")
        return nil
    end
    
    print("🔍 Analyzing tool:", tool.Name)
    
    -- Look for the Model inside the Tool (this contains all the body parts)
    local petModel = tool:FindFirstChildOfClass("Model")
    if not petModel then
        print("❌ No Model found inside Tool")
        return nil
    end
    
    print("✅ Found pet model inside tool:", petModel.Name)
    print("📊 Model has", #petModel:GetChildren(), "children and", #petModel:GetDescendants(), "descendants")
    
    -- Clone the MODEL (not the Tool)
    local modelClone = petModel:Clone()
    
    -- Make sure all parts are visible and properly configured
    for _, part in pairs(modelClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
            part.Transparency = 0  -- Make sure everything is visible
            
            print("✅ Configured part:", part.Name, "Size:", part.Size)
        end
    end
    
    print("🎉 Proper pet model cloned successfully!")
    return modelClone
end

-- Function: Replace with proper model
local function replaceWithProperModel(tempModel)
    if not tempModel then return false end
    
    print("🔄 Replacing with proper model:", tempModel.Name)
    
    -- Get proper pet model
    local properPetModel = getProperPetModel()
    if not properPetModel then
        print("❌ Failed to get proper pet model")
        return false
    end
    
    -- Get position from temp model
    local tempPrimaryPart = tempModel.PrimaryPart or tempModel:FindFirstChildWhichIsA("BasePart")
    if not tempPrimaryPart then
        print("❌ No temp primary part")
        return false
    end
    
    -- Position the proper pet model
    local petPrimaryPart = properPetModel.PrimaryPart or properPetModel:FindFirstChildWhichIsA("BasePart")
    if petPrimaryPart then
        petPrimaryPart.CFrame = tempPrimaryPart.CFrame
        print("✅ Proper model positioned")
    else
        -- If no PrimaryPart, position the whole model
        properPetModel:SetPrimaryPartCFrame(tempPrimaryPart.CFrame)
        print("✅ Whole model positioned")
    end
    
    -- Hide original temp model
    for _, part in pairs(tempModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    print("🙈 Original temp model hidden")
    
    -- Add proper pet model to workspace
    properPetModel.Parent = Workspace
    print("✅ Proper pet model added to workspace")
    
    -- Clean up after 4 seconds
    game:GetService("Debris"):AddItem(properPetModel, 4)
    
    print("🎉 Proper model replacement successful!")
    debugLabel.Text = "Debug: Proper " .. properPetModel.Name
    
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
                print("🎯 Pet detected:", child.Name)
                debugLabel.Text = "Debug: Found " .. child.Name
                statusLabel.Text = "Status: Replacing " .. child.Name
                
                -- Small delay
                task.wait(0.1)
                
                -- Replace with proper model
                if replaceWithProperModel(child) then
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
        statusLabel.Text = "Status: Proper model mode active"
        debugLabel.Text = "Debug: Ready for proper model"
    else
        toggleBtn.Text = "❌ Auto Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("🔄 Proper Model Auto Pet Replacer loaded!")
print("✅ Key improvements:")
print("  ✅ Clones the Model inside Tool (not Handle)")
print("  ✅ Gets all 17 body parts (head, legs, ears, etc.)")
print("  ✅ Makes all parts visible")
print("  ✅ Proper positioning")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Auto Replace'")
print("3. Open egg")
print("4. See FULL pet model (not just white square)!")
