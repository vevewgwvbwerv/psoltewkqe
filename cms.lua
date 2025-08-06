-- 🔥 PET SCALER v3.221 - CLEAN VERSION WITHOUT SYNTAX ERRORS
-- CFrame Animation System for Roblox Pets

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v3.221 - CLEAN VERSION ===")

-- Configuration
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 1.0,
    INTERPOLATION_SPEED = 0.3,
    POSITION_OFFSET = Vector3.new(15, 0, 0),
    TWEEN_TIME = 3.0
}

-- Get all BasePart from model
local function getAllParts(model)
    local parts = {}
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(parts, descendant)
        end
    end
    return parts
end

-- Check if model has pet visuals
local function hasPetVisuals(model)
    local meshCount = 0
    local parts = getAllParts(model)
    
    for _, part in ipairs(parts) do
        if part:FindFirstChildOfClass("SpecialMesh") or 
           part:FindFirstChildOfClass("MeshPart") then
            meshCount = meshCount + 1
        end
    end
    
    return meshCount > 0 and #parts > 3
end

-- Find pet in hand (Tool)
local function findHandPet()
    local playerChar = player.Character
    if not playerChar then return nil end
    
    for _, tool in pairs(playerChar:GetChildren()) do
        if tool:IsA("Tool") then
            for _, child in pairs(tool:GetDescendants()) do
                if child:IsA("Model") and child.Name ~= "Handle" then
                    if hasPetVisuals(child) then
                        return child, tool
                    end
                end
            end
        end
    end
    return nil
end

-- Find pet nearby player
local function findNearbyPet()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    
    for _, model in pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model ~= playerChar then
            -- Check if it's player's pet (has UUID or player name)
            if string.find(model.Name, player.Name) or string.find(model.Name, "%d+%-") then
                if model.PrimaryPart then
                    local distance = (model.PrimaryPart.Position - playerPos).Magnitude
                    if distance <= CONFIG.SEARCH_RADIUS then
                        if hasPetVisuals(model) then
                            return model
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Create pet copy
local function createPetCopy(originalModel)
    print("📋 Creating pet copy:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_ANIMATED_COPY"
    copy.Parent = Workspace
    
    -- Position copy next to original
    if originalModel.PrimaryPart and copy.PrimaryPart then
        local originalPos = originalModel.PrimaryPart.Position
        local newPos = originalPos + CONFIG.POSITION_OFFSET
        copy:SetPrimaryPartCFrame(CFrame.new(newPos))
    end
    
    -- Set Anchored states
    local copyParts = getAllParts(copy)
    for _, part in ipairs(copyParts) do
        if part.Name == "RootPart" or part.Name == "Torso" or part.Name == "HumanoidRootPart" then
            part.Anchored = true -- Only root is anchored
        else
            part.Anchored = false -- Other parts free for animation
        end
    end
    
    print("✅ Copy created with", #copyParts, "parts")
    return copy
end

-- Scale model smoothly
local function scaleModel(model, scaleFactor)
    print("📏 Scaling model to", scaleFactor .. "x")
    
    local parts = getAllParts(model)
    local originalData = {}
    
    -- Store original data
    for _, part in ipairs(parts) do
        originalData[part] = {
            size = part.Size,
            cframe = part.CFrame
        }
    end
    
    -- Scale all parts
    for _, part in ipairs(parts) do
        local targetSize = originalData[part].size * scaleFactor
        part.Size = targetSize
    end
    
    print("✅ Model scaled successfully")
    return true
end

-- CFrame animation system
local function startCFrameAnimation(handPet, copyModel)
    print("🎭 Starting CFrame animation...")
    
    -- Get all animatable parts from hand pet (exclude Handle)
    local handParts = {}
    for _, part in ipairs(handPet:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "Handle" then
            handParts[part.Name] = part
        end
    end
    
    -- Get corresponding parts in copy
    local copyParts = {}
    for _, part in ipairs(copyModel:GetDescendants()) do
        if part:IsA("BasePart") and handParts[part.Name] then
            copyParts[part.Name] = part
        end
    end
    
    print("🔗 Found", table.getn(copyParts), "part correspondences")
    
    -- Start animation loop
    local connection = RunService.Heartbeat:Connect(function()
        -- Check if models still exist
        if not handPet.Parent or not copyModel.Parent then
            print("⚠️ Model deleted, stopping animation")
            connection:Disconnect()
            return
        end
        
        -- Copy CFrame states
        for partName, handPart in pairs(handParts) do
            local copyPart = copyParts[partName]
            if copyPart and copyPart.Parent and not copyPart.Anchored then
                -- Scale and apply CFrame
                local handCFrame = handPart.CFrame
                local scaledPosition = handCFrame.Position * CONFIG.SCALE_FACTOR
                local scaledCFrame = CFrame.new(scaledPosition) * (handCFrame - handCFrame.Position)
                
                -- Smooth interpolation
                copyPart.CFrame = copyPart.CFrame:Lerp(scaledCFrame, CONFIG.INTERPOLATION_SPEED)
            end
        end
    end)
    
    print("✅ CFrame animation started!")
    return connection
end

-- Main function
local function main()
    print("🚀 Starting PetScaler...")
    
    -- Find pet in hand
    local handPet, tool = findHandPet()
    if handPet then
        print("🎒 Found pet in hand:", handPet.Name)
        
        -- Create copy
        local petCopy = createPetCopy(handPet)
        
        -- Scale copy
        scaleModel(petCopy, CONFIG.SCALE_FACTOR)
        
        -- Start animation
        local animConnection = startCFrameAnimation(handPet, petCopy)
        
        if animConnection then
            print("🎉 === SUCCESS! ===")
            print("✅ Animated copy created")
            print("✅ CFrame animation started")
            print("🦅 Wings and all parts should move!")
        else
            print("❌ Failed to start animation")
        end
        return
    end
    
    -- Find pet nearby
    local nearbyPet = findNearbyPet()
    if nearbyPet then
        print("🐾 Found pet nearby:", nearbyPet.Name)
        print("⚠️ Take pet in hand for animation")
        return
    end
    
    print("❌ No pet found!")
end

-- Create GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Remove old GUI
    local existingGui = playerGui:FindFirstChild("PetScalerGUI")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Create new GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 100)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 50)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    button.BorderSizePixel = 0
    button.Text = "🔥 ANIMATE PET v3.221"
    button.TextColor3 = Color3.white
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 65)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready - Take pet in hand"
    statusLabel.TextColor3 = Color3.white
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        statusLabel.Text = "Working..."
        button.Text = "⏳ Creating..."
        
        spawn(function()
            main()
            wait(2)
            statusLabel.Text = "Done!"
            button.Text = "🔥 ANIMATE PET v3.221"
        end)
    end)
    
    print("🖱️ GUI created - click button to start!")
end

-- Start
createGUI()
print("🎯 Take Dragonfly in hand and click the green button!")
print("🦅 Animated copy with flapping wings will appear!")
