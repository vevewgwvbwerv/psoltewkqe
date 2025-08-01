-- Instant Appearance Replace - Intercept egg pet IMMEDIATELY and replace appearance BEFORE animation
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("InstantReplace_GUI") then 
    CoreGui.InstantReplace_GUI:Destroy() 
end

-- Storage
local isInstantReplaceActive = false
local handPetAppearanceCache = nil

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "InstantReplace_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 280, 0, 150)
mainFrame.Position = UDim2.new(0.7, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.25, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Instant Appearance Replace"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0.3, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "❌ Instant Replace: OFF"

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0.6, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Disabled"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true

-- Debug Label
local debugLabel = Instance.new("TextLabel", mainFrame)
debugLabel.Size = UDim2.new(1, -10, 0, 20)
debugLabel.Position = UDim2.new(0, 5, 0.8, 0)
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

-- Function: Cache hand pet appearance (call once when enabled)
local function cacheHandPetAppearance()
    local character = LocalPlayer.Character
    if not character then
        print("❌ No character for caching")
        return false
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ No tool in hand for caching")
        return false
    end
    
    print("💾 CACHING hand pet appearance:", tool.Name)
    
    handPetAppearanceCache = {
        petName = tool.Name,
        parts = {}
    }
    
    -- Cache ALL appearance data
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            local partData = {
                Color = part.Color,
                Material = part.Material,
                BrickColor = part.BrickColor,
                Reflectance = part.Reflectance,
                Size = part.Size
            }
            
            -- Cache mesh data
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                partData.Mesh = {
                    MeshType = mesh.MeshType,
                    MeshId = mesh.MeshId,
                    TextureId = mesh.TextureId,
                    Scale = mesh.Scale,
                    Offset = mesh.Offset
                }
            end
            
            -- Cache textures/decals
            partData.Textures = {}
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceGui") then
                    table.insert(partData.Textures, child:Clone())
                end
            end
            
            handPetAppearanceCache.parts[part.Name] = partData
            print("  💾 Cached:", part.Name)
        end
    end
    
    print("💾 Cached appearance for", #handPetAppearanceCache.parts, "parts")
    return true
end

-- Function: INSTANTLY apply cached appearance to egg pet
local function instantlyApplyAppearance(eggPet)
    if not handPetAppearanceCache then
        print("❌ No cached appearance data")
        return false
    end
    
    print("⚡ INSTANTLY APPLYING appearance to:", eggPet.Name)
    print("⚡ From cached pet:", handPetAppearanceCache.petName)
    
    local partsModified = 0
    local startTime = tick()
    
    -- Apply appearance to ALL matching parts INSTANTLY
    for _, part in pairs(eggPet:GetDescendants()) do
        if part:IsA("BasePart") then
            local cachedData = handPetAppearanceCache.parts[part.Name]
            if cachedData then
                -- Apply basic appearance INSTANTLY
                part.Color = cachedData.Color
                part.Material = cachedData.Material
                part.BrickColor = cachedData.BrickColor
                part.Reflectance = cachedData.Reflectance
                -- DON'T change size - let animation handle that
                
                -- Apply mesh INSTANTLY
                if cachedData.Mesh then
                    local mesh = part:FindFirstChildOfClass("SpecialMesh")
                    if not mesh then
                        mesh = Instance.new("SpecialMesh", part)
                    end
                    
                    mesh.MeshType = cachedData.Mesh.MeshType
                    mesh.MeshId = cachedData.Mesh.MeshId
                    mesh.TextureId = cachedData.Mesh.TextureId
                    mesh.Scale = cachedData.Mesh.Scale
                    mesh.Offset = cachedData.Mesh.Offset
                end
                
                -- Apply textures INSTANTLY
                if #cachedData.Textures > 0 then
                    -- Remove existing textures
                    for _, child in pairs(part:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceGui") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add cached textures
                    for _, texture in ipairs(cachedData.Textures) do
                        local newTexture = texture:Clone()
                        newTexture.Parent = part
                    end
                end
                
                partsModified = partsModified + 1
            end
        end
    end
    
    local elapsed = tick() - startTime
    print("⚡ INSTANT APPLICATION COMPLETE!")
    print("  ✅ Modified", partsModified, "parts")
    print("  ⚡ Time taken:", string.format("%.3fs", elapsed))
    
    return partsModified > 0
end

-- Monitor Workspace.Visuals with INSTANT response
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isInstantReplaceActive then return end
        
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
                print("⚡ EGG PET DETECTED - INSTANT INTERCEPT:", child.Name)
                debugLabel.Text = "Debug: INTERCEPTED " .. child.Name
                statusLabel.Text = "Status: INSTANT applying..."
                
                -- NO DELAY - INSTANT APPLICATION
                if instantlyApplyAppearance(child) then
                    statusLabel.Text = "Status: INSTANT SUCCESS " .. child.Name
                    debugLabel.Text = "Debug: " .. handPetAppearanceCache.petName .. "→" .. child.Name
                    print("⚡ SUCCESS! Egg pet will now grow with hand pet appearance!")
                else
                    statusLabel.Text = "Status: INSTANT FAILED " .. child.Name
                    debugLabel.Text = "Debug: FAILED " .. child.Name
                end
            end
        end
    end)
else
    print("⚠️ Workspace.Visuals not found")
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isInstantReplaceActive = not isInstantReplaceActive
    
    if isInstantReplaceActive then
        -- Cache appearance when enabling
        if cacheHandPetAppearance() then
            toggleBtn.Text = "⚡ Instant Replace: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            statusLabel.Text = "Status: INSTANT replacement ready"
            debugLabel.Text = "Debug: Cached " .. handPetAppearanceCache.petName
        else
            isInstantReplaceActive = false
            statusLabel.Text = "Status: FAILED - No pet in hand"
            debugLabel.Text = "Debug: Cache failed"
        end
    else
        toggleBtn.Text = "❌ Instant Replace: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
        handPetAppearanceCache = nil
    end
end)

print("⚡ Instant Appearance Replace loaded!")
print("✅ Key features:")
print("  ⚡ INSTANT interception (no delay)")
print("  💾 Pre-caches hand pet appearance")
print("  🎯 Applies appearance BEFORE animation starts")
print("  🎬 Lets original animation run with new appearance")
print("📋 Instructions:")
print("1. Hold pet in hand FIRST")
print("2. Enable 'Instant Replace' (will cache appearance)")
print("3. Open egg")
print("4. Egg pet should grow with hand pet appearance!")
