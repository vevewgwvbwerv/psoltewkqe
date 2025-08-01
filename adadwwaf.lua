-- Pet Structure Analyzer - Find out what's in your pet
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("PetAnalyzer_GUI") then 
    CoreGui.PetAnalyzer_GUI:Destroy() 
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PetAnalyzer_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.7, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔍 Pet Structure Analyzer"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Analyze Button
local analyzeBtn = Instance.new("TextButton", mainFrame)
analyzeBtn.Size = UDim2.new(1, -10, 0, 40)
analyzeBtn.Position = UDim2.new(0, 5, 0.12, 0)
analyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
analyzeBtn.TextColor3 = Color3.new(1, 1, 1)
analyzeBtn.Font = Enum.Font.GothamBold
analyzeBtn.TextSize = 16
analyzeBtn.Text = "🔍 ANALYZE PET IN HAND"

-- Results ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, -10, 0.75, 0)
scrollFrame.Position = UDim2.new(0, 5, 0.23, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 1
scrollFrame.ScrollBarThickness = 8

local resultsList = Instance.new("TextLabel", scrollFrame)
resultsList.Size = UDim2.new(1, -10, 1, 0)
resultsList.Position = UDim2.new(0, 5, 0, 0)
resultsList.BackgroundTransparency = 1
resultsList.Text = "Click 'ANALYZE PET IN HAND' to see structure"
resultsList.TextColor3 = Color3.fromRGB(255, 255, 255)
resultsList.Font = Enum.Font.Code
resultsList.TextSize = 12
resultsList.TextXAlignment = Enum.TextXAlignment.Left
resultsList.TextYAlignment = Enum.TextYAlignment.Top
resultsList.TextWrapped = true

-- Function: Analyze pet structure
local function analyzePetStructure()
    local character = LocalPlayer.Character
    if not character then
        resultsList.Text = "❌ ERROR: No character found!"
        return
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        resultsList.Text = "❌ ERROR: No pet in hand!\nHold a pet and try again."
        return
    end
    
    local results = {}
    table.insert(results, "🔍 ANALYZING PET: " .. tool.Name)
    table.insert(results, "📊 Tool Class: " .. tool.ClassName)
    table.insert(results, "")
    
    -- Count children
    local childCount = #tool:GetChildren()
    table.insert(results, "👶 Direct Children: " .. childCount)
    table.insert(results, "")
    
    -- List all children with details
    table.insert(results, "📋 CHILDREN LIST:")
    for i, child in ipairs(tool:GetChildren()) do
        local childInfo = string.format("[%d] %s (%s)", i, child.Name, child.ClassName)
        
        if child:IsA("BasePart") then
            childInfo = childInfo .. string.format(" - Size: %.1f,%.1f,%.1f", 
                child.Size.X, child.Size.Y, child.Size.Z)
            childInfo = childInfo .. " - Color: " .. tostring(child.BrickColor)
            childInfo = childInfo .. " - Material: " .. tostring(child.Material)
            childInfo = childInfo .. " - Transparency: " .. child.Transparency
        end
        
        table.insert(results, childInfo)
        
        -- List grandchildren
        local grandchildren = child:GetChildren()
        if #grandchildren > 0 then
            for j, grandchild in ipairs(grandchildren) do
                local grandInfo = string.format("  └─ [%d.%d] %s (%s)", i, j, grandchild.Name, grandchild.ClassName)
                table.insert(results, grandInfo)
            end
        end
    end
    
    table.insert(results, "")
    
    -- Count total descendants
    local totalDescendants = #tool:GetDescendants()
    table.insert(results, "🌳 Total Descendants: " .. totalDescendants)
    table.insert(results, "")
    
    -- Find all BaseParts
    local baseParts = {}
    for _, descendant in pairs(tool:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(baseParts, descendant)
        end
    end
    
    table.insert(results, "🧱 BaseParts Found: " .. #baseParts)
    for i, part in ipairs(baseParts) do
        local partInfo = string.format("  [%d] %s - Size: %.1f,%.1f,%.1f - %s", 
            i, part.Name, part.Size.X, part.Size.Y, part.Size.Z, tostring(part.BrickColor))
        table.insert(results, partInfo)
    end
    
    table.insert(results, "")
    table.insert(results, "🔧 CLONE TEST:")
    
    -- Test cloning
    local success, cloneResult = pcall(function()
        local clone = tool:Clone()
        local cloneChildren = #clone:GetChildren()
        local cloneDescendants = #clone:GetDescendants()
        return string.format("✅ Clone successful! Children: %d, Descendants: %d", cloneChildren, cloneDescendants)
    end)
    
    if success then
        table.insert(results, cloneResult)
    else
        table.insert(results, "❌ Clone failed: " .. tostring(cloneResult))
    end
    
    -- Set results
    local finalText = table.concat(results, "\n")
    resultsList.Text = finalText
    
    -- Adjust canvas size
    local textBounds = game:GetService("TextService"):GetTextSize(
        finalText, 12, Enum.Font.Code, Vector2.new(scrollFrame.AbsoluteSize.X - 20, math.huge)
    )
    resultsList.Size = UDim2.new(1, -10, 0, textBounds.Y + 20)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 40)
    
    print("🔍 Pet analysis complete!")
end

-- Button event
analyzeBtn.MouseButton1Click:Connect(function()
    analyzePetStructure()
end)

print("🔍 Pet Structure Analyzer loaded!")
print("📋 Instructions:")
print("1. Hold any pet in your hand")
print("2. Click 'ANALYZE PET IN HAND'")
print("3. See detailed structure information")
print("4. This will help understand why only white square appears!")
