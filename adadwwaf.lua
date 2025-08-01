-- Real-Time Sync - Continuously synchronize appearance during animation
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("RealTimeSync_GUI") then 
    CoreGui.RealTimeSync_GUI:Destroy() 
end

-- Storage
local isRealTimeSyncActive = false
local handPetAppearanceCache = nil
local currentSyncConnection = nil
local currentEggPet = nil

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "RealTimeSync_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0.65, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 50)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔄 Real-Time Sync"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "❌ Real-Time Sync: OFF"

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

-- Sync Counter Label
local syncLabel = Instance.new("TextLabel", mainFrame)
syncLabel.Size = UDim2.new(1, -10, 0, 20)
syncLabel.Position = UDim2.new(0, 5, 0.85, 0)
syncLabel.BackgroundTransparency = 1
syncLabel.Text = "Syncs: 0"
syncLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
syncLabel.Font = Enum.Font.Gotham
syncLabel.TextScaled = true

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: Cache hand pet appearance
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
                Reflectance = part.Reflectance
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

-- Function: Apply appearance to single part
local function applyAppearanceToPart(part, cachedData)
    if not cachedData then return false end
    
    -- Apply basic appearance
    part.Color = cachedData.Color
    part.Material = cachedData.Material
    part.BrickColor = cachedData.BrickColor
    part.Reflectance = cachedData.Reflectance
    
    -- Apply mesh
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
    
    -- Apply textures
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
    
    return true
end

-- Function: Real-time synchronization loop
local function startRealTimeSync(eggPet)
    if currentSyncConnection then
        currentSyncConnection:Disconnect()
    end
    
    print("🔄 STARTING REAL-TIME SYNC for:", eggPet.Name)
    
    local syncCount = 0
    local startTime = tick()
    
    currentSyncConnection = RunService.Heartbeat:Connect(function()
        if not eggPet.Parent then
            print("🔄 Egg pet destroyed, stopping sync")
            currentSyncConnection:Disconnect()
            currentSyncConnection = nil
            return
        end
        
        syncCount = syncCount + 1
        local elapsed = tick() - startTime
        
        -- Update every frame
        local partsUpdated = 0
        for _, part in pairs(eggPet:GetDescendants()) do
            if part:IsA("BasePart") then
                local cachedData = handPetAppearanceCache.parts[part.Name]
                if cachedData then
                    if applyAppearanceToPart(part, cachedData) then
                        partsUpdated = partsUpdated + 1
                    end
                end
            end
        end
        
        -- Update UI every 10 frames
        if syncCount % 10 == 0 then
            syncLabel.Text = string.format("Syncs: %d | Parts: %d | Time: %.1fs", syncCount, partsUpdated, elapsed)
        end
        
        -- Stop after 6 seconds
        if elapsed > 6 then
            print("🔄 REAL-TIME SYNC COMPLETE")
            print("  Total syncs:", syncCount)
            print("  Duration:", string.format("%.2fs", elapsed))
            
            currentSyncConnection:Disconnect()
            currentSyncConnection = nil
            statusLabel.Text = "Status: Sync completed"
        end
    end)
end

-- Monitor Workspace.Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isRealTimeSyncActive then return end
        
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
                print("🔄 EGG PET DETECTED - STARTING REAL-TIME SYNC:", child.Name)
                debugLabel.Text = "Debug: SYNCING " .. child.Name
                statusLabel.Text = "Status: Real-time syncing..."
                
                currentEggPet = child
                
                -- Start real-time sync
                task.wait(0.05) -- Tiny delay to let it load
                startRealTimeSync(child)
            end
        end
    end)
else
    print("⚠️ Workspace.Visuals not found")
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isRealTimeSyncActive = not isRealTimeSyncActive
    
    if isRealTimeSyncActive then
        -- Cache appearance when enabling
        if cacheHandPetAppearance() then
            toggleBtn.Text = "🔄 Real-Time Sync: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            statusLabel.Text = "Status: Real-time sync ready"
            debugLabel.Text = "Debug: Cached " .. handPetAppearanceCache.petName
            syncLabel.Text = "Syncs: Ready"
        else
            isRealTimeSyncActive = false
            statusLabel.Text = "Status: FAILED - No pet in hand"
            debugLabel.Text = "Debug: Cache failed"
        end
    else
        toggleBtn.Text = "❌ Real-Time Sync: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
        syncLabel.Text = "Syncs: 0"
        
        if currentSyncConnection then
            currentSyncConnection:Disconnect()
            currentSyncConnection = nil
        end
        
        handPetAppearanceCache = nil
    end
end)

print("🔄 Real-Time Sync loaded!")
print("✅ Key features:")
print("  🔄 Synchronizes appearance EVERY FRAME")
print("  💾 Pre-caches hand pet appearance")
print("  📊 Shows sync statistics in real-time")
print("  🎬 Maintains sync during entire animation")
print("📋 Instructions:")
print("1. Hold pet in hand FIRST")
print("2. Enable 'Real-Time Sync' (will cache appearance)")
print("3. Open egg")
print("4. Watch sync counter - should update continuously!")
