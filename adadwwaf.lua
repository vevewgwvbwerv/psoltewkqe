-- Simple Stable Copy - Copy pet from hand, place nearby, NO FALLING
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("SimpleStableCopy_GUI") then 
    CoreGui.SimpleStableCopy_GUI:Destroy() 
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "SimpleStableCopy_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✅ Stable Copy Test"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Copy Button
local copyBtn = Instance.new("TextButton", mainFrame)
copyBtn.Size = UDim2.new(1, -10, 0, 30)
copyBtn.Position = UDim2.new(0, 5, 0.5, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 12
copyBtn.Text = "COPY & PLACE STABLE"

-- Function: Create stable copy
local function createStableCopy()
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
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        print("❌ No HumanoidRootPart")
        return
    end
    
    print("✅ Creating stable copy of:", tool.Name)
    
    -- Clone the tool
    local toolClone = tool:Clone()
    toolClone.Name = toolClone.Name .. "_StableCopy"
    
    -- CRITICAL: Anchor ALL parts to prevent falling
    for _, part in pairs(toolClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true  -- ANCHOR - no falling!
            part.CanCollide = false  -- No collision issues
            part.Transparency = 0  -- Make visible
            
            print("🔧 Anchored:", part.Name, "Size:", part.Size)
        end
    end
    
    -- Add to workspace FIRST
    toolClone.Parent = Workspace
    
    -- Position it 5 studs in front of player, 2 studs above ground
    local targetPosition = humanoidRootPart.CFrame * CFrame.new(0, 2, -5)
    
    -- Set position for primary part
    local primaryPart = toolClone.PrimaryPart or toolClone:FindFirstChildWhichIsA("BasePart")
    if primaryPart then
        primaryPart.CFrame = targetPosition
        print("✅ Positioned at:", targetPosition)
    else
        print("⚠️ No primary part found, using SetPrimaryPartCFrame")
        toolClone:SetPrimaryPartCFrame(targetPosition)
    end
    
    print("🎉 Stable copy created and positioned!")
    
    -- Clean up after 15 seconds
    game:GetService("Debris"):AddItem(toolClone, 15)
    
    return toolClone
end

-- Button event
copyBtn.MouseButton1Click:Connect(function()
    createStableCopy()
end)

print("✅ Simple Stable Copy loaded!")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Click 'COPY & PLACE STABLE'")
print("3. Pet should appear in front of you and NOT fall!")
print("4. If this works, we can apply same logic to egg replacement!")
