-- Texture Replacement - Keep egg pet animation, replace appearance with hand pet
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("TextureReplacement_GUI") then 
    CoreGui.TextureReplacement_GUI:Destroy() 
end

-- Storage
local isReplacementActive = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "TextureReplacement_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 280, 0, 160)
mainFrame.Position = UDim2.new(0.7, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(60, 0, 60)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎨 Texture Replacement"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "❌ Texture Replace: OFF"

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Disabled"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true

-- Debug Label
local debugLabel = Instance.new("TextLabel", mainFrame)
debugLabel.Size = UDim2.new(1, -10, 0, 20)
debugLabel.Position = UDim2.new(0, 5, 0.7, 0)
debugLabel.BackgroundTransparency = 1
debugLabel.Text = "Debug: Ready"
debugLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
debugLabel.Font = Enum.Font.Gotham
debugLabel.TextScaled = true

-- Info Label
local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Size = UDim2.new(1, -10, 0, 20)
infoLabel.Position = UDim2.new(0, 5, 0.85, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Keeps animation, changes appearance"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: Get appearance data from hand pet
local function getHandPetAppearance()
    local character = LocalPlayer.Character
    if not character then
        print("❌ No character")
        return nil
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ No tool in hand")
        return nil
    end
    
    print("🎨 Analyzing appearance of:", tool.Name)
    
    local appearanceData = {}
    
    -- Collect appearance data from all parts
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            appearanceData[part.Name] = {
                Color = part.Color,
                Material = part.Material,
                BrickColor = part.BrickColor,
                Transparency = part.Transparency,
                Reflectance = part.Reflectance,
                Size = part.Size
            }
            
            -- Collect textures/decals
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceGui") then
                    if not appearanceData[part.Name].Textures then
                        appearanceData[part.Name].Textures = {}
                    end
                    table.insert(appearanceData[part.Name].Textures, child:Clone())
                end
            end
            
            -- Collect SpecialMesh data
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                appearanceData[part.Name].Mesh = {
                    MeshType = mesh.MeshType,
                    MeshId = mesh.MeshId,
                    TextureId = mesh.TextureId,
                    Scale = mesh.Scale,
                    Offset = mesh.Offset
                }
            end
            
            print("  🎨 Collected appearance for:", part.Name)
        end
    end
    
    print("🎨 Collected appearance data for", #appearanceData, "parts")
    return appearanceData, tool.Name
end

-- Function: Apply appearance to egg pet (keep animation)
local function applyAppearanceToEggPet(eggPet, appearanceData, handPetName)
    if not eggPet or not appearanceData then return false end
    
    print("🎨 APPLYING APPEARANCE from", handPetName, "to", eggPet.Name)
    
    local partsModified = 0
    
    -- Apply appearance to matching parts
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            local appearance = appearanceData[part.Name]
            if appearance then
                -- Apply basic appearance
                part.Color = appearance.Color
                part.Material = appearance.Material
                part.BrickColor = appearance.BrickColor
                -- Keep original transparency for animation
                -- part.Transparency = appearance.Transparency
                part.Reflectance = appearance.Reflectance
                
                -- Apply mesh data
                if appearance.Mesh then
                    local mesh = part:FindFirstChildOfClass("SpecialMesh")
                    if not mesh then
                        mesh = Instance.new("SpecialMesh", part)
                    end
                    
                    mesh.MeshType = appearance.Mesh.MeshType
                    mesh.MeshId = appearance.Mesh.MeshId
                    mesh.TextureId = appearance.Mesh.TextureId
                    mesh.Scale = appearance.Mesh.Scale
                    mesh.Offset = appearance.Mesh.Offset
                    
                    print("  🎨 Applied mesh to:", part.Name)
                end
                
                -- Apply textures/decals
                if appearance.Textures then
                    -- Remove existing textures
                    for _, child in pairs(part:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceGui") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add new textures
                    for _, texture in ipairs(appearance.Textures) do
                        local newTexture = texture:Clone()
                        newTexture.Parent = part
                    end
                    
                    print("  🎨 Applied textures to:", part.Name)
                end
                
                partsModified = partsModified + 1
                print("  ✅ Modified appearance:", part.Name)
            else
                print("  ⚠️ No appearance data for:", part.Name)
            end
        end
    end
    
    print("🎨 Applied appearance to", partsModified, "parts")
    return partsModified > 0
end

-- Function: Replace appearance while keeping animation
local function replaceAppearanceKeepAnimation(eggPet)
    if not eggPet then return false end
    
    print("🎨 TEXTURE REPLACEMENT for:", eggPet.Name)
    
    -- Get hand pet appearance
    local appearanceData, handPetName = getHandPetAppearance()
    if not appearanceData then
        print("❌ Failed to get hand pet appearance")
        return false
    end
    
    -- Apply appearance to egg pet (keeps all animation and scaling)
    if applyAppearanceToEggPet(eggPet, appearanceData, handPetName) then
        print("🎨 TEXTURE REPLACEMENT SUCCESSFUL!")
        print("  ✅ Kept original animation and scaling")
        print("  ✅ Applied", handPetName, "appearance")
        
        debugLabel.Text = "Debug: TEXTURE " .. handPetName .. "→" .. eggPet.Name
        return true
    else
        print("❌ Failed to apply appearance")
        return false
    end
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
                print("🎨 EGG PET DETECTED:", child.Name)
                debugLabel.Text = "Debug: Found " .. child.Name
                statusLabel.Text = "Status: TEXTURE replacing " .. child.Name
                
                -- Small delay to let it load
                task.wait(0.1)
                
                -- Replace appearance only
                if replaceAppearanceKeepAnimation(child) then
                    statusLabel.Text = "Status: TEXTURE SUCCESS " .. child.Name
                else
                    statusLabel.Text = "Status: TEXTURE FAILED " .. child.Name
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
        toggleBtn.Text = "🎨 Texture Replace: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
        statusLabel.Text = "Status: TEXTURE replacement active"
        debugLabel.Text = "Debug: Changing appearance only"
    else
        toggleBtn.Text = "❌ Texture Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
    end
end)

print("🎨 Texture Replacement loaded!")
print("✅ Key features:")
print("  🎨 KEEPS original egg pet (with animation)")
print("  🎨 Changes ONLY appearance (colors, textures, meshes)")
print("  🎨 Preserves growth animation and scaling")
print("  🎨 Preserves all original effects")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Texture Replace'")
print("3. Open egg")
print("4. Should show hand pet appearance with egg animation!")
