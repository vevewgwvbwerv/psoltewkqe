-- Simple Copy Test - Just copy pet from hand and place it nearby
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("SimpleCopyTest_GUI") then 
    CoreGui.SimpleCopyTest_GUI:Destroy() 
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "SimpleCopyTest_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🧪 Simple Copy Test"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Copy Button
local copyBtn = Instance.new("TextButton", mainFrame)
copyBtn.Size = UDim2.new(1, -10, 0, 40)
copyBtn.Position = UDim2.new(0, 5, 0.5, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 14
copyBtn.Text = "COPY PET FROM HAND"

-- Function: Simple copy test
local function simpleCopyTest()
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
    
    print("🧪 SIMPLE COPY TEST - Tool:", tool.Name)
    
    -- Method 1: Direct tool clone
    print("🔄 Method 1: Direct tool clone")
    local toolClone = tool:Clone()
    toolClone.Name = toolClone.Name .. "_Clone1"
    toolClone.Parent = Workspace
    
    -- Position it in front of player
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        toolClone:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(5, 0, 0))
    end
    
    print("✅ Method 1 complete - Tool clone added to workspace")
    
    -- Method 2: Create model and copy all descendants
    print("🔄 Method 2: Model with all descendants")
    local model = Instance.new("Model")
    model.Name = tool.Name .. "_Clone2"
    
    -- Copy ALL descendants
    for _, descendant in pairs(tool:GetDescendants()) do
        local clone = descendant:Clone()
        clone.Parent = model
        
        if clone:IsA("BasePart") then
            clone.CanCollide = false
            clone.Anchored = false
            clone.Transparency = 0
        end
    end
    
    model.Parent = Workspace
    
    -- Position it
    if humanoidRootPart then
        model:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(-5, 0, 0))
    end
    
    print("✅ Method 2 complete - Model with descendants added")
    
    -- Method 3: Find and clone inner model
    print("🔄 Method 3: Find inner model")
    local innerModel = tool:FindFirstChildOfClass("Model")
    if innerModel then
        local innerClone = innerModel:Clone()
        innerClone.Name = innerClone.Name .. "_Clone3"
        innerClone.Parent = Workspace
        
        -- Position it
        if humanoidRootPart then
            innerClone:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(0, 0, 5))
        end
        
        print("✅ Method 3 complete - Inner model cloned")
    else
        print("❌ Method 3 failed - No inner model found")
    end
    
    print("🧪 COPY TEST COMPLETE - Check around your character!")
    
    -- Clean up after 10 seconds
    game:GetService("Debris"):AddItem(toolClone, 10)
    game:GetService("Debris"):AddItem(model, 10)
    if innerModel then
        game:GetService("Debris"):AddItem(innerModel, 10)
    end
end

-- Button event
copyBtn.MouseButton1Click:Connect(function()
    simpleCopyTest()
end)

print("🧪 Simple Copy Test loaded!")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Click 'COPY PET FROM HAND'")
print("3. Look around your character for copies")
print("4. This will test if basic copying works!")
