-- Appearance Diagnostic - Debug WHY appearance changes don't work
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("AppearanceDiagnostic_GUI") then 
    CoreGui.AppearanceDiagnostic_GUI:Destroy() 
end

-- Storage
local isDiagnosticActive = false
local handPetData = nil
local eggPetData = nil

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AppearanceDiagnostic_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.6, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.08, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔍 Appearance Diagnostic"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
toggleBtn.TextColor3 = Color3.new(0, 0, 0)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Text = "🔍 START DIAGNOSTIC"

-- Scrolling Frame for detailed comparison
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, -10, 0.8, 0)
scrollFrame.Position = UDim2.new(0, 5, 0.18, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
scrollFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.ScrollBarThickness = 10
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

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
local function addDiagnosticText(text, color)
    color = color or Color3.fromRGB(255, 255, 255)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 15)
    textLabel.Position = UDim2.new(0, 10, 0, #scrollFrame:GetChildren() * 17)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.Font = Enum.Font.Code
    textLabel.TextSize = 10
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = scrollFrame
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 17 + 50)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
    
    print(text)
end

-- Function: Clear diagnostic display
local function clearDiagnostic()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- Function: Analyze hand pet structure
local function analyzeHandPet()
    local character = LocalPlayer.Character
    if not character then
        addDiagnosticText("❌ No character", Color3.fromRGB(255, 0, 0))
        return false
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        addDiagnosticText("❌ No tool in hand", Color3.fromRGB(255, 0, 0))
        return false
    end
    
    addDiagnosticText("🔍 HAND PET ANALYSIS: " .. tool.Name, Color3.fromRGB(0, 255, 0))
    addDiagnosticText("=" .. string.rep("=", 50), Color3.fromRGB(100, 100, 100))
    
    handPetData = {
        name = tool.Name,
        parts = {}
    }
    
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            local partInfo = {
                Name = part.Name,
                Color = part.Color,
                Material = part.Material.Name,
                BrickColor = part.BrickColor.Name,
                Size = part.Size,
                Transparency = part.Transparency
            }
            
            -- Check for mesh
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                partInfo.Mesh = {
                    MeshType = mesh.MeshType.Name,
                    MeshId = mesh.MeshId,
                    TextureId = mesh.TextureId,
                    Scale = mesh.Scale
                }
            end
            
            -- Check for textures
            partInfo.Textures = {}
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    table.insert(partInfo.Textures, {
                        Type = child.ClassName,
                        Texture = child.Texture,
                        Face = child.Face and child.Face.Name or "N/A"
                    })
                end
            end
            
            handPetData.parts[part.Name] = partInfo
            
            addDiagnosticText(string.format("  📦 %s: Color=%s, Material=%s, Mesh=%s, Textures=%d", 
                part.Name, 
                tostring(part.Color), 
                part.Material.Name,
                mesh and mesh.MeshType.Name or "None",
                #partInfo.Textures), 
                Color3.fromRGB(200, 200, 200))
        end
    end
    
    addDiagnosticText("✅ Hand pet analysis complete: " .. #handPetData.parts .. " parts", Color3.fromRGB(0, 255, 0))
    return true
end

-- Function: Analyze egg pet and compare
local function analyzeEggPetAndCompare(eggPet)
    addDiagnosticText("", Color3.fromRGB(100, 100, 100))
    addDiagnosticText("🔍 EGG PET ANALYSIS: " .. eggPet.Name, Color3.fromRGB(255, 255, 0))
    addDiagnosticText("=" .. string.rep("=", 50), Color3.fromRGB(100, 100, 100))
    
    eggPetData = {
        name = eggPet.Name,
        parts = {}
    }
    
    local matchingParts = 0
    local totalEggParts = 0
    
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            totalEggParts = totalEggParts + 1
            
            local partInfo = {
                Name = part.Name,
                Color = part.Color,
                Material = part.Material.Name,
                BrickColor = part.BrickColor.Name,
                Size = part.Size,
                Transparency = part.Transparency
            }
            
            -- Check for mesh
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                partInfo.Mesh = {
                    MeshType = mesh.MeshType.Name,
                    MeshId = mesh.MeshId,
                    TextureId = mesh.TextureId,
                    Scale = mesh.Scale
                }
            end
            
            eggPetData.parts[part.Name] = partInfo
            
            -- Compare with hand pet
            local handPartInfo = handPetData and handPetData.parts[part.Name]
            if handPartInfo then
                matchingParts = matchingParts + 1
                
                addDiagnosticText(string.format("  🔄 %s: MATCH FOUND", part.Name), Color3.fromRGB(0, 255, 0))
                addDiagnosticText(string.format("    Egg:  Color=%s, Material=%s, Mesh=%s", 
                    tostring(part.Color), 
                    part.Material.Name,
                    mesh and mesh.MeshType.Name or "None"), 
                    Color3.fromRGB(255, 200, 200))
                addDiagnosticText(string.format("    Hand: Color=%s, Material=%s, Mesh=%s", 
                    tostring(handPartInfo.Color), 
                    handPartInfo.Material,
                    handPartInfo.Mesh and handPartInfo.Mesh.MeshType or "None"), 
                    Color3.fromRGB(200, 255, 200))
                
                -- Try to apply hand pet appearance
                addDiagnosticText("    🔧 ATTEMPTING CHANGE...", Color3.fromRGB(255, 255, 0))
                
                local originalColor = part.Color
                part.Color = handPartInfo.Color
                part.Material = Enum.Material[handPartInfo.Material]
                
                task.wait(0.1)
                
                -- Check if change stuck
                if part.Color == handPartInfo.Color then
                    addDiagnosticText("    ✅ COLOR CHANGE SUCCESSFUL!", Color3.fromRGB(0, 255, 0))
                else
                    addDiagnosticText("    ❌ COLOR CHANGE FAILED - Reverted to: " .. tostring(part.Color), Color3.fromRGB(255, 0, 0))
                end
                
            else
                addDiagnosticText(string.format("  ⚠️ %s: NO MATCH in hand pet", part.Name), Color3.fromRGB(255, 100, 0))
            end
        end
    end
    
    addDiagnosticText("", Color3.fromRGB(100, 100, 100))
    addDiagnosticText("📊 COMPARISON SUMMARY:", Color3.fromRGB(255, 255, 0))
    addDiagnosticText("  Egg pet parts: " .. totalEggParts, Color3.fromRGB(200, 200, 200))
    addDiagnosticText("  Hand pet parts: " .. (handPetData and #handPetData.parts or 0), Color3.fromRGB(200, 200, 200))
    addDiagnosticText("  Matching parts: " .. matchingParts, Color3.fromRGB(200, 200, 200))
    addDiagnosticText("  Match rate: " .. string.format("%.1f%%", (matchingParts / totalEggParts) * 100), Color3.fromRGB(200, 200, 200))
    
    if matchingParts == 0 then
        addDiagnosticText("❌ NO MATCHING PARTS - This is why appearance doesn't change!", Color3.fromRGB(255, 0, 0))
    elseif matchingParts < totalEggParts / 2 then
        addDiagnosticText("⚠️ LOW MATCH RATE - Pets have different structures!", Color3.fromRGB(255, 100, 0))
    else
        addDiagnosticText("✅ GOOD MATCH RATE - Should be able to change appearance", Color3.fromRGB(0, 255, 0))
    end
end

-- Monitor Workspace.Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isDiagnosticActive then return end
        
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
                addDiagnosticText("🎯 EGG PET DETECTED: " .. child.Name, Color3.fromRGB(0, 255, 255))
                
                -- Small delay to let it load
                task.wait(0.2)
                
                -- Analyze and compare
                analyzeEggPetAndCompare(child)
            end
        end
    end)
else
    addDiagnosticText("⚠️ Workspace.Visuals not found", Color3.fromRGB(255, 0, 0))
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isDiagnosticActive = not isDiagnosticActive
    
    if isDiagnosticActive then
        toggleBtn.Text = "🔍 DIAGNOSTIC ACTIVE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        clearDiagnostic()
        addDiagnosticText("🔍 Appearance Diagnostic Started", Color3.fromRGB(0, 255, 0))
        addDiagnosticText("", Color3.fromRGB(100, 100, 100))
        
        -- Analyze hand pet first
        if analyzeHandPet() then
            addDiagnosticText("📋 Now open an egg to compare structures!", Color3.fromRGB(255, 255, 0))
        end
    else
        toggleBtn.Text = "🔍 START DIAGNOSTIC"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
    end
end)

print("🔍 Appearance Diagnostic loaded!")
print("📋 This will show:")
print("  🔍 Detailed structure of hand pet")
print("  🔍 Detailed structure of egg pet")
print("  🔄 Part-by-part comparison")
print("  🧪 Live testing of appearance changes")
print("  📊 Match rate and compatibility")
print("🚀 Use this to find out WHY appearance changes don't work!")
