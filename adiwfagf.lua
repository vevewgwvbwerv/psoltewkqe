-- Full Texture Transfer - Transfer ALL textures, meshes, decals, not just colors
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("FullTextureTransfer_GUI") then 
    FullTextureTransfer_GUI:Destroy() 
end

-- Storage
local isFullTransferActive = false
local handPetTextureCache = nil
local currentTransferConnection = nil

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "FullTextureTransfer_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 320, 0, 200)
mainFrame.Position = UDim2.new(0.65, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 60, 60)
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎨 Full Texture Transfer"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
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
toggleBtn.Text = "❌ Full Transfer: OFF"

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

-- Transfer Counter Label
local transferLabel = Instance.new("TextLabel", mainFrame)
transferLabel.Size = UDim2.new(1, -10, 0, 20)
transferLabel.Position = UDim2.new(0, 5, 0.85, 0)
transferLabel.BackgroundTransparency = 1
transferLabel.Text = "Transfers: 0"
transferLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
transferLabel.Font = Enum.Font.Gotham
transferLabel.TextScaled = true

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: Cache FULL texture data from hand pet
local function cacheFullTextureData()
    local character = LocalPlayer.Character
    if not character then
        print("❌ No character for texture caching")
        return false
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("❌ No tool in hand for texture caching")
        return false
    end
    
    print("🎨 CACHING FULL TEXTURE DATA:", tool.Name)
    
    handPetTextureCache = {
        petName = tool.Name,
        parts = {}
    }
    
    -- Cache EVERYTHING for each part
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            local partData = {
                -- Basic appearance
                Color = part.Color,
                Material = part.Material,
                BrickColor = part.BrickColor,
                Reflectance = part.Reflectance,
                
                -- All children (textures, decals, meshes, etc.)
                Children = {}
            }
            
            -- Clone ALL children (textures, decals, meshes, etc.)
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture") or 
                   child:IsA("SurfaceGui") or child:IsA("BillboardGui") or child:IsA("SurfaceLight") then
                    
                    local childClone = child:Clone()
                    table.insert(partData.Children, childClone)
                    
                    print("  🎨 Cached child:", child.ClassName, "for", part.Name)
                end
            end
            
            handPetTextureCache.parts[part.Name] = partData
            print("  🎨 Cached part:", part.Name, "with", #partData.Children, "children")
        end
    end
    
    print("🎨 Full texture cache complete:", #handPetTextureCache.parts, "parts")
    return true
end

-- Function: Apply FULL texture data to single part
local function applyFullTextureData(eggPart, cachedData)
    if not cachedData then return false end
    
    -- Apply basic appearance
    eggPart.Color = cachedData.Color
    eggPart.Material = cachedData.Material
    eggPart.BrickColor = cachedData.BrickColor
    eggPart.Reflectance = cachedData.Reflectance
    
    -- REMOVE ALL existing visual children
    for _, child in pairs(eggPart:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture") or 
           child:IsA("SurfaceGui") or child:IsA("BillboardGui") or child:IsA("SurfaceLight") then
            child:Destroy()
        end
    end
    
    -- ADD ALL cached children (textures, meshes, decals)
    for _, childClone in ipairs(cachedData.Children) do
        local newChild = childClone:Clone()
        newChild.Parent = eggPart
    end
    
    return true
end

-- Function: Full texture transfer loop
local function startFullTextureTransfer(eggPet)
    if currentTransferConnection then
        currentTransferConnection:Disconnect()
    end
    
    print("🎨 STARTING FULL TEXTURE TRANSFER for:", eggPet.Name)
    
    local transferCount = 0
    local startTime = tick()
    
    currentTransferConnection = RunService.Heartbeat:Connect(function()
        if not eggPet.Parent then
            print("🎨 Egg pet destroyed, stopping transfer")
            currentTransferConnection:Disconnect()
            currentTransferConnection = nil
            return
        end
        
        transferCount = transferCount + 1
        local elapsed = tick() - startTime
        
        -- Transfer FULL texture data every frame
        local partsTransferred = 0
        for _, eggPart in pairs(eggPet:GetDescendants()) do
            if eggPart:IsA("BasePart") then
                local cachedData = handPetTextureCache.parts[eggPart.Name]
                if cachedData then
                    if applyFullTextureData(eggPart, cachedData) then
                        partsTransferred = partsTransferred + 1
                    end
                end
            end
        end
        
        -- Update UI every 10 frames
        if transferCount % 10 == 0 then
            transferLabel.Text = string.format("Transfers: %d | Parts: %d | Time: %.1fs", 
                transferCount, partsTransferred, elapsed)
        end
        
        -- Stop after 6 seconds
        if elapsed > 6 then
            print("🎨 FULL TEXTURE TRANSFER COMPLETE")
            print("  Total transfers:", transferCount)
            print("  Duration:", string.format("%.2fs", elapsed))
            
            currentTransferConnection:Disconnect()
            currentTransferConnection = nil
            statusLabel.Text = "Status: Transfer completed"
        end
    end)
end

-- Monitor Workspace.Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    visuals.ChildAdded:Connect(function(child)
        if not isFullTransferActive then return end
        
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
                print("🎨 EGG PET DETECTED - STARTING FULL TEXTURE TRANSFER:", child.Name)
                debugLabel.Text = "Debug: TRANSFERRING " .. child.Name
                statusLabel.Text = "Status: Full texture transfer..."
                
                -- Start full texture transfer
                task.wait(0.05)
                startFullTextureTransfer(child)
            end
        end
    end)
else
    print("⚠️ Workspace.Visuals not found")
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isFullTransferActive = not isFullTransferActive
    
    if isFullTransferActive then
        -- Cache full texture data when enabling
        if cacheFullTextureData() then
            toggleBtn.Text = "🎨 Full Transfer: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
            statusLabel.Text = "Status: Full texture transfer ready"
            debugLabel.Text = "Debug: Cached " .. handPetTextureCache.petName
            transferLabel.Text = "Transfers: Ready"
        else
            isFullTransferActive = false
            statusLabel.Text = "Status: FAILED - No pet in hand"
            debugLabel.Text = "Debug: Cache failed"
        end
    else
        toggleBtn.Text = "❌ Full Transfer: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
        transferLabel.Text = "Transfers: 0"
        
        if currentTransferConnection then
            currentTransferConnection:Disconnect()
            currentTransferConnection = nil
        end
        
        handPetTextureCache = nil
    end
end)

print("🎨 Full Texture Transfer loaded!")
print("✅ Key improvements:")
print("  🎨 Transfers ALL textures, decals, meshes")
print("  🗑️ Removes old visual elements first")
print("  📦 Clones and applies ALL visual children")
print("  🔄 Continuous transfer during animation")
print("  📊 Shows transfer statistics")
print("📋 Instructions:")
print("1. Hold pet in hand FIRST")
print("2. Enable 'Full Transfer' (will cache ALL textures)")
print("3. Open egg")
print("4. Should transfer COMPLETE visual appearance!")
