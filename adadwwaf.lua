-- Animation Analysis - Deep analysis of egg pet during growth animation
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("AnimationAnalysis_GUI") then 
    CoreGui.AnimationAnalysis_GUI:Destroy() 
end

-- Storage
local isAnalyzing = false
local currentEggPet = nil
local analysisConnection = nil

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AnimationAnalysis_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.65, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.08, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔬 Animation Analysis"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Start Analysis Button
local analyzeBtn = Instance.new("TextButton", mainFrame)
analyzeBtn.Size = UDim2.new(1, -10, 0, 30)
analyzeBtn.Position = UDim2.new(0, 5, 0.1, 0)
analyzeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
analyzeBtn.TextColor3 = Color3.new(0, 0, 0)
analyzeBtn.Font = Enum.Font.GothamBold
analyzeBtn.TextSize = 14
analyzeBtn.Text = "🔬 START DEEP ANALYSIS"

-- Scrolling Frame for detailed info
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, -10, 0.75, 0)
scrollFrame.Position = UDim2.new(0, 5, 0.2, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
scrollFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.ScrollBarThickness = 10
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0.05, 0)
statusLabel.Position = UDim2.new(0, 5, 0.95, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready for analysis"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: Add text to scroll frame
local function addAnalysisText(text, color)
    color = color or Color3.fromRGB(255, 255, 255)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 20)
    textLabel.Position = UDim2.new(0, 10, 0, #scrollFrame:GetChildren() * 22)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.Font = Enum.Font.Code
    textLabel.TextSize = 11
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = scrollFrame
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 22 + 50)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
    
    print(text)
end

-- Function: Clear analysis display
local function clearAnalysis()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- Function: Analyze pet structure in real-time
local function analyzeEggPetRealTime(eggPet)
    addAnalysisText("🔬 STARTING REAL-TIME ANALYSIS: " .. eggPet.Name, Color3.fromRGB(0, 255, 0))
    addAnalysisText("=" .. string.rep("=", 50), Color3.fromRGB(100, 100, 100))
    
    local startTime = tick()
    local frameCount = 0
    
    -- Track initial state
    local initialParts = {}
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            initialParts[part.Name] = {
                Size = part.Size,
                CFrame = part.CFrame,
                Transparency = part.Transparency,
                Color = part.Color,
                Material = part.Material
            }
        end
    end
    
    addAnalysisText("📊 Initial parts count: " .. #initialParts, Color3.fromRGB(255, 255, 0))
    
    -- Real-time monitoring
    analysisConnection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local elapsed = tick() - startTime
        
        if frameCount % 10 == 0 then -- Every 10 frames
            addAnalysisText(string.format("⏱️ Time: %.2fs | Frame: %d", elapsed, frameCount), Color3.fromRGB(150, 150, 150))
            
            -- Check for changes
            for _, part in pairs(eggPet:GetDescendants()) do
                if part:IsA("BasePart") and initialParts[part.Name] then
                    local initial = initialParts[part.Name]
                    local current = {
                        Size = part.Size,
                        CFrame = part.CFrame,
                        Transparency = part.Transparency,
                        Color = part.Color,
                        Material = part.Material
                    }
                    
                    -- Check for size changes (growth animation)
                    if (current.Size - initial.Size).Magnitude > 0.1 then
                        addAnalysisText(string.format("📏 %s size: %.2f,%.2f,%.2f → %.2f,%.2f,%.2f", 
                            part.Name, 
                            initial.Size.X, initial.Size.Y, initial.Size.Z,
                            current.Size.X, current.Size.Y, current.Size.Z), 
                            Color3.fromRGB(255, 200, 0))
                        initialParts[part.Name].Size = current.Size
                    end
                    
                    -- Check for transparency changes
                    if math.abs(current.Transparency - initial.Transparency) > 0.1 then
                        addAnalysisText(string.format("👁️ %s transparency: %.2f → %.2f", 
                            part.Name, initial.Transparency, current.Transparency), 
                            Color3.fromRGB(0, 255, 255))
                        initialParts[part.Name].Transparency = current.Transparency
                    end
                    
                    -- Check for position changes
                    if (current.CFrame.Position - initial.CFrame.Position).Magnitude > 0.5 then
                        addAnalysisText(string.format("📍 %s moved: %.1f,%.1f,%.1f → %.1f,%.1f,%.1f", 
                            part.Name,
                            initial.CFrame.Position.X, initial.CFrame.Position.Y, initial.CFrame.Position.Z,
                            current.CFrame.Position.X, current.CFrame.Position.Y, current.CFrame.Position.Z), 
                            Color3.fromRGB(255, 100, 255))
                        initialParts[part.Name].CFrame = current.CFrame
                    end
                end
            end
        end
        
        -- Stop after 6 seconds
        if elapsed > 6 then
            addAnalysisText("🏁 ANALYSIS COMPLETE", Color3.fromRGB(0, 255, 0))
            addAnalysisText("=" .. string.rep("=", 50), Color3.fromRGB(100, 100, 100))
            
            -- Final summary
            addAnalysisText("📋 SUMMARY:", Color3.fromRGB(255, 255, 0))
            addAnalysisText("• Total time analyzed: " .. string.format("%.2fs", elapsed), Color3.fromRGB(200, 200, 200))
            addAnalysisText("• Total frames: " .. frameCount, Color3.fromRGB(200, 200, 200))
            addAnalysisText("• Pet name: " .. eggPet.Name, Color3.fromRGB(200, 200, 200))
            
            -- Check if pet still exists
            if eggPet.Parent then
                addAnalysisText("• Pet status: Still exists", Color3.fromRGB(0, 255, 0))
                
                -- Final part analysis
                local finalParts = {}
                for _, part in pairs(eggPet:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(finalParts, part.Name)
                    end
                end
                addAnalysisText("• Final parts: " .. table.concat(finalParts, ", "), Color3.fromRGB(200, 200, 200))
            else
                addAnalysisText("• Pet status: DESTROYED/REMOVED", Color3.fromRGB(255, 0, 0))
            end
            
            analysisConnection:Disconnect()
            analysisConnection = nil
            statusLabel.Text = "Status: Analysis complete - Check details above"
        end
    end)
end

-- Monitor Workspace.Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isAnalyzing then return end
        
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
                addAnalysisText("🎯 EGG PET DETECTED: " .. child.Name, Color3.fromRGB(0, 255, 0))
                statusLabel.Text = "Status: Analyzing " .. child.Name .. " in real-time..."
                
                currentEggPet = child
                
                -- Start real-time analysis
                task.wait(0.1)
                analyzeEggPetRealTime(child)
            end
        end
    end)
else
    addAnalysisText("⚠️ Workspace.Visuals not found", Color3.fromRGB(255, 0, 0))
end

-- Button Logic
analyzeBtn.MouseButton1Click:Connect(function()
    isAnalyzing = not isAnalyzing
    
    if isAnalyzing then
        analyzeBtn.Text = "🔬 ANALYSIS ACTIVE"
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Status: Waiting for egg pet..."
        clearAnalysis()
        addAnalysisText("🔬 Deep Analysis Started", Color3.fromRGB(0, 255, 0))
        addAnalysisText("📋 Instructions:", Color3.fromRGB(255, 255, 0))
        addAnalysisText("1. Open an egg now", Color3.fromRGB(200, 200, 200))
        addAnalysisText("2. Watch real-time analysis", Color3.fromRGB(200, 200, 200))
        addAnalysisText("3. See growth animation details", Color3.fromRGB(200, 200, 200))
        addAnalysisText("", Color3.fromRGB(200, 200, 200))
    else
        analyzeBtn.Text = "🔬 START DEEP ANALYSIS"
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
        statusLabel.Text = "Status: Analysis stopped"
        
        if analysisConnection then
            analysisConnection:Disconnect()
            analysisConnection = nil
        end
    end
end)

print("🔬 Animation Analysis loaded!")
print("📋 This will show:")
print("  🔬 Real-time size changes (growth animation)")
print("  👁️ Transparency changes (fade in/out)")
print("  📍 Position changes (movement)")
print("  ⏱️ Timing of all changes")
print("  📊 Complete structure analysis")
print("🚀 Use this to understand EXACTLY what happens during egg opening!")
