-- 🚀 IMPROVED PET SCALER v3.0
-- Cleaner architecture, better error handling, optimized performance

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- 📊 Configuration
local Config = {
    Search = {
        radius = 100,
        petIdentifiers = {"{", "}", "Pet", "pet"}
    },
    Animation = {
        startScale = 0.2,
        targetScale = 1.0,
        tweenTime = 2.5,
        easingStyle = Enum.EasingStyle.Back,
        easingDirection = Enum.EasingDirection.Out,
        recordDuration = 6.0,
        playbackFPS = 30
    },
    Positioning = {
        offset = Vector3.new(12, 0, 0),
        heightCorrection = 1.5,
        groundRayDistance = 200
    }
}

-- 🛠️ Utility Classes
local Logger = {
    info = function(msg) print("ℹ️ " .. msg) end,
    success = function(msg) print("✅ " .. msg) end,
    warning = function(msg) print("⚠️ " .. msg) end,
    error = function(msg) print("❌ " .. msg) end
}

local PetDetector = {}
function PetDetector.findNearbyPets(playerPosition, radius)
    local pets = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and PetDetector.isPetModel(obj) then
            local success, modelCFrame = pcall(function() 
                return obj:GetModelCFrame() 
            end)
            
            if success then
                local distance = (modelCFrame.Position - playerPosition).Magnitude
                if distance <= radius then
                    local visualCount = PetDetector.countVisualElements(obj)
                    if visualCount > 0 then
                        table.insert(pets, {
                            model = obj,
                            distance = distance,
                            visualElements = visualCount
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(pets, function(a, b) return a.distance < b.distance end)
    return pets
end

function PetDetector.isPetModel(model)
    local name = model.Name:lower()
    for _, identifier in pairs(Config.Search.petIdentifiers) do
        if name:find(identifier) then return true end
    end
    return false
end

function PetDetector.countVisualElements(model)
    local count = 0
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") or obj:IsA("Decal") then
            count = count + 1
        end
    end
    return count
end

-- 🎭 Animation System
local AnimationRecorder = {}
function AnimationRecorder.new(model)
    local self = {
        model = model,
        motors = {},
        frames = {},
        isRecording = false,
        humanoid = model:FindFirstChild("Humanoid"),
        rootPart = model:FindFirstChild("RootPart") or model:FindFirstChild("HumanoidRootPart")
    }
    
    -- Find all Motor6D joints
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(self.motors, obj)
        end
    end
    
    setmetatable(self, {__index = AnimationRecorder})
    return self
end

function AnimationRecorder:isIdle()
    if self.humanoid then
        return self.humanoid.MoveDirection.Magnitude < 0.1
    elseif self.rootPart then
        -- Position-based detection for non-humanoid pets
        if not self.lastPosition then
            self.lastPosition = self.rootPart.Position
            return false
        end
        
        local movement = (self.rootPart.Position - self.lastPosition).Magnitude
        self.lastPosition = self.rootPart.Position
        return movement < 0.05
    end
    return true
end

function AnimationRecorder:startRecording(duration)
    if #self.motors == 0 then
        Logger.error("No Motor6D joints found for recording")
        return false
    end
    
    Logger.info("Starting animation recording for " .. duration .. " seconds")
    self.isRecording = true
    self.frames = {}
    
    local startTime = tick()
    local frameRate = Config.Animation.playbackFPS
    local frameInterval = 1 / frameRate
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if tick() - startTime >= duration then
            connection:Disconnect()
            self.isRecording = false
            Logger.success("Recording completed: " .. #self.frames .. " frames")
            return
        end
        
        if (tick() - startTime) % frameInterval < 0.016 then -- ~60fps recording
            local frame = {}
            for i, motor in ipairs(self.motors) do
                if motor.Parent then
                    frame[i] = {
                        C0 = motor.C0,
                        C1 = motor.C1,
                        Transform = motor.Transform
                    }
                end
            end
            table.insert(self.frames, frame)
        end
    end)
    
    return true
end

-- 🎯 Pet Copier
local PetCopier = {}
function PetCopier.createScaledCopy(originalModel, scaleFactor)
    Logger.info("Creating scaled copy of: " .. originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_Enhanced_Copy"
    copy.Parent = Workspace
    
    -- Fix attachment issues immediately
    PetCopier.fixAttachments(copy)
    
    -- Position the copy
    PetCopier.positionCopy(copy, originalModel, Config.Positioning.offset)
    
    -- Setup physics
    PetCopier.setupPhysics(copy, scaleFactor)
    
    return copy
end

function PetCopier.fixAttachments(model)
    local fixed = 0
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Attachment") and obj.Parent and not obj.Parent:IsA("BasePart") then
            local basePart = obj.Parent
            while basePart and not basePart:IsA("BasePart") do
                basePart = basePart.Parent
            end
            
            if basePart then
                obj.Parent = basePart
                fixed = fixed + 1
            else
                obj:Destroy()
            end
        end
    end
    Logger.info("Fixed " .. fixed .. " attachment issues")
end

function PetCopier.positionCopy(copy, original, offset)
    if not (copy.PrimaryPart and original.PrimaryPart) then
        Logger.warning("Missing PrimaryPart for positioning")
        return
    end
    
    local originalCFrame = original.PrimaryPart.CFrame
    local targetPosition = originalCFrame.Position + offset
    
    -- Ground raycast
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {copy, original}
    
    local rayResult = Workspace:Raycast(
        targetPosition + Vector3.new(0, 100, 0),
        Vector3.new(0, -Config.Positioning.groundRayDistance, 0),
        rayParams
    )
    
    local finalPosition = rayResult and rayResult.Position or targetPosition
    finalPosition = finalPosition + Vector3.new(0, Config.Positioning.heightCorrection, 0)
    
    -- Maintain original orientation
    local newCFrame = CFrame.lookAt(
        finalPosition,
        finalPosition + originalCFrame.LookVector,
        originalCFrame.UpVector
    )
    
    copy:SetPrimaryPartCFrame(newCFrame)
    Logger.success("Copy positioned successfully")
end

function PetCopier.setupPhysics(model, scaleFactor)
    local parts = {}
    local rootPart = nil
    
    -- Collect all parts
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
            if obj.Name:find("Root") or obj.Name:find("Torso") then
                rootPart = obj
            end
        end
    end
    
    rootPart = rootPart or parts[1]
    
    -- Smart anchoring: only root is anchored
    for _, part in ipairs(parts) do
        part.Anchored = (part == rootPart)
    end
    
    Logger.info("Physics setup complete - Root: " .. (rootPart and rootPart.Name or "None"))
end

-- 🎬 Animation Player
local AnimationPlayer = {}
function AnimationPlayer.new(targetModel, recordedFrames, sourceMotors)
    local self = {
        model = targetModel,
        frames = recordedFrames,
        motors = {},
        isPlaying = false,
        currentFrame = 1
    }
    
    -- Map target motors
    for _, obj in pairs(targetModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(self.motors, obj)
        end
    end
    
    setmetatable(self, {__index = AnimationPlayer})
    return self
end

function AnimationPlayer:play()
    if #self.frames == 0 or #self.motors == 0 then
        Logger.error("No frames or motors available for playback")
        return
    end
    
    self.isPlaying = true
    Logger.success("Starting infinite animation playback")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not self.isPlaying or not self.model.Parent then
            connection:Disconnect()
            return
        end
        
        local frameData = self.frames[self.currentFrame]
        if frameData then
            for i, motor in ipairs(self.motors) do
                if motor.Parent and frameData[i] then
                    pcall(function()
                        motor.C0 = frameData[i].C0
                        motor.C1 = frameData[i].C1
                        motor.Transform = frameData[i].Transform
                    end)
                end
            end
        end
        
        -- Advance frame with smooth looping
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > #self.frames then
            self.currentFrame = 1
        end
    end)
end

-- 🚀 Main System
local PetScalerSystem = {}
function PetScalerSystem.execute()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        Logger.error("Player character not found")
        return
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    Logger.info("Searching for pets near player...")
    
    -- Find pets
    local nearbyPets = PetDetector.findNearbyPets(playerPos, Config.Search.radius)
    if #nearbyPets == 0 then
        Logger.error("No pets found within " .. Config.Search.radius .. " studs")
        return
    end
    
    local targetPet = nearbyPets[1].model
    Logger.success("Selected pet: " .. targetPet.Name)
    
    -- Create copy
    local petCopy = PetCopier.createScaledCopy(targetPet, Config.Animation.targetScale)
    if not petCopy then
        Logger.error("Failed to create pet copy")
        return
    end
    
    -- Animate scaling
    PetScalerSystem.animateScaling(petCopy)
    
    -- Setup animation recording and playback
    wait(Config.Animation.tweenTime + 1)
    PetScalerSystem.setupAnimationSystem(targetPet, petCopy)
end

function PetScalerSystem.animateScaling(model)
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    -- Store original sizes and positions
    local originalData = {}
    local centerCFrame = model:GetModelCFrame()
    
    for _, part in ipairs(parts) do
        originalData[part] = {
            size = part.Size,
            cframe = part.CFrame
        }
        
        -- Set to start scale
        part.Size = part.Size * Config.Animation.startScale
        local relativeCFrame = centerCFrame:Inverse() * part.CFrame
        local scaledRelative = CFrame.new(relativeCFrame.Position * Config.Animation.startScale) * 
                              (relativeCFrame - relativeCFrame.Position)
        part.CFrame = centerCFrame * scaledRelative
    end
    
    wait(0.5)
    
    -- Animate to full size
    local tweenInfo = TweenInfo.new(
        Config.Animation.tweenTime,
        Config.Animation.easingStyle,
        Config.Animation.easingDirection
    )
    
    for _, part in ipairs(parts) do
        local tween = TweenService:Create(part, tweenInfo, {
            Size = originalData[part].size,
            CFrame = originalData[part].cframe
        })
        tween:Play()
    end
    
    Logger.success("Scaling animation started")
end

function PetScalerSystem.setupAnimationSystem(originalPet, copyPet)
    Logger.info("Setting up animation system...")
    
    local recorder = AnimationRecorder.new(originalPet)
    
    -- Wait for idle state
    local idleFrames = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if recorder:isIdle() then
            idleFrames = idleFrames + 1
        else
            idleFrames = 0
        end
        
        if idleFrames >= 60 then -- 1 second of idle
            connection:Disconnect()
            
            -- Start recording
            recorder:startRecording(Config.Animation.recordDuration)
            
            -- Wait for recording to complete, then start playback
            spawn(function()
                while recorder.isRecording do
                    wait(0.1)
                end
                
                local player = AnimationPlayer.new(copyPet, recorder.frames, recorder.motors)
                player:play()
                
                Logger.success("🎉 Pet Scaler v3.0 Complete!")
                Logger.success("✨ Enhanced copy with infinite animation is ready!")
            end)
        end
    end)
end

-- 🖥️ GUI System
local function createModernGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Clean up old GUI
    local oldGui = playerGui:FindFirstChild("EnhancedPetScalerGUI")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedPetScalerGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 100)
    mainFrame.Position = UDim2.new(0, 50, 0, 200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Modern rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    local actionButton = Instance.new("TextButton")
    actionButton.Name = "ActionButton"
    actionButton.Size = UDim2.new(0, 260, 0, 50)
    actionButton.Position = UDim2.new(0, 10, 0, 25)
    actionButton.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    actionButton.BorderSizePixel = 0
    actionButton.Text = "🚀 Enhanced Pet Scaler v3.0"
    actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionButton.TextSize = 16
    actionButton.Font = Enum.Font.GothamBold
    actionButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = actionButton
    
    -- Button functionality
    actionButton.MouseButton1Click:Connect(function()
        actionButton.Text = "⚡ Creating Enhanced Copy..."
        actionButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        
        spawn(function()
            PetScalerSystem.execute()
            
            wait(2)
            actionButton.Text = "🚀 Enhanced Pet Scaler v3.0"
            actionButton.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
        end)
    end)
    
    -- Hover effects
    actionButton.MouseEnter:Connect(function()
        actionButton.BackgroundColor3 = Color3.fromRGB(0, 200, 140)
        actionButton.Size = UDim2.new(0, 265, 0, 52)
        actionButton.Position = UDim2.new(0, 7.5, 0, 24)
    end)
    
    actionButton.MouseLeave:Connect(function()
        actionButton.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
        actionButton.Size = UDim2.new(0, 260, 0, 50)
        actionButton.Position = UDim2.new(0, 10, 0, 25)
    end)
    
    Logger.success("Enhanced GUI created successfully!")
end

-- 🎯 Initialize System
createModernGUI()
Logger.success("🚀 Enhanced Pet Scaler v3.0 Loaded!")
Logger.info("Click the button to create an enhanced animated pet copy!")
