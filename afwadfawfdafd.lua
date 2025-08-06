-- Pet Animation Analyzer Script for Roblox
-- Place this in StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetAnalyzerGui"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = screenGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0.6, 0)
button.Position = UDim2.new(0.1, 0, 0.2, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
button.BorderSizePixel = 1
button.BorderColor3 = Color3.fromRGB(0, 100, 200)
button.Text = "Analyze Pet"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.Parent = frame

-- Function to find closest pet
local function findClosestPet()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPosition = character.HumanoidRootPart.Position
    local closestPet = nil
    local closestDistance = math.huge
    
    -- Search in workspace for pets (common pet names/folders)
    local searchFolders = {
        workspace:FindFirstChild("Pets"),
        workspace:FindFirstChild("pets"),
        workspace,  -- Direct search in workspace
    }
    
    for _, folder in pairs(searchFolders) do
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= character then
                    local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart") or 
                                           obj:FindFirstChild("Torso") or 
                                           obj:FindFirstChild("PrimaryPart") or
                                           obj:FindFirstChildOfClass("Part")
                    
                    if humanoidRootPart then
                        local distance = (humanoidRootPart.Position - playerPosition).Magnitude
                        
                        -- Check if it's likely a pet (close to player and has pet-like properties)
                        if distance < 20 and distance < closestDistance then
                            -- Additional checks for pet identification
                            local hasHumanoid = obj:FindFirstChild("Humanoid")
                            local hasAnimator = obj:FindFirstChild("Humanoid") and obj.Humanoid:FindFirstChild("Animator")
                            
                            -- Check for common pet indicators
                            local isPetLike = hasHumanoid or 
                                            obj.Name:lower():find("pet") or
                                            obj.Name:lower():find("companion") or
                                            obj.Name:lower():find("familiar")
                            
                            if isPetLike then
                                closestPet = obj
                                closestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPet
end

-- Function to analyze animations
local function analyzeAnimations(model)
    print("=== PET ANIMATION ANALYSIS ===")
    print("Pet Name: " .. model.Name)
    print("Distance from player: " .. string.format("%.2f", 
        (model:FindFirstChild("HumanoidRootPart") and 
        (model.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or "Unknown"))
    
    -- Analyze Humanoid and Animator
    local humanoid = model:FindFirstChild("Humanoid")
    if humanoid then
        print("\n--- HUMANOID INFO ---")
        print("WalkSpeed: " .. humanoid.WalkSpeed)
        print("JumpPower: " .. humanoid.JumpPower)
        print("Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
        
        local animator = humanoid:FindFirstChild("Animator")
        if animator then
            print("\n--- ANIMATOR INFO ---")
            print("Animator found: Yes")
            
            -- Get playing animation tracks
            local animationTracks = animator:GetPlayingAnimationTracks()
            print("Active Animation Tracks: " .. #animationTracks)
            
            for i, track in pairs(animationTracks) do
                print("\n--- ANIMATION TRACK " .. i .. " ---")
                print("Animation ID: " .. (track.Animation.AnimationId or "None"))
                print("Is Playing: " .. tostring(track.IsPlaying))
                print("Length: " .. track.Length)
                print("Speed: " .. track.Speed)
                print("Time Position: " .. track.TimePosition)
                print("Weight: " .. track.WeightCurrent)
                print("Priority: " .. tostring(track.Priority))
                print("Looped: " .. tostring(track.Looped))
            end
        else
            print("Animator: Not found")
        end
    end
    
    -- Analyze Motor6D joints
    print("\n--- MOTOR6D ANALYSIS ---")
    local motor6Ds = {}
    
    local function findMotor6Ds(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Motor6D") then
                table.insert(motor6Ds, child)
            end
            findMotor6Ds(child)
        end
    end
    
    findMotor6Ds(model)
    
    print("Total Motor6D joints found: " .. #motor6Ds)
    
    for i, motor in pairs(motor6Ds) do
        print("\n--- MOTOR6D " .. i .. ": " .. motor.Name .. " ---")
        print("Part0: " .. (motor.Part0 and motor.Part0.Name or "None"))
        print("Part1: " .. (motor.Part1 and motor.Part1.Name or "None"))
        print("C0: " .. tostring(motor.C0))
        print("C1: " .. tostring(motor.C1))
        print("CurrentAngle: " .. motor.CurrentAngle)
        print("DesiredAngle: " .. motor.DesiredAngle)
        print("MaxVelocity: " .. motor.MaxVelocity)
    end
    
    -- Analyze all parts and their CFrames
    print("\n--- PART CFRAME ANALYSIS ---")
    local parts = {}
    
    local function findParts(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("BasePart") then
                table.insert(parts, child)
            end
            findParts(child)
        end
    end
    
    findParts(model)
    
    print("Total parts found: " .. #parts)
    
    for i, part in pairs(parts) do
        print("\n--- PART " .. i .. ": " .. part.Name .. " ---")
        print("CFrame: " .. tostring(part.CFrame))
        print("Position: " .. tostring(part.Position))
        print("Rotation: " .. tostring(part.Rotation))
        print("Size: " .. tostring(part.Size))
        print("Material: " .. tostring(part.Material))
        print("Color: " .. tostring(part.Color))
    end
    
    -- Check for Animation objects
    print("\n--- ANIMATION OBJECTS ---")
    local animations = {}
    
    local function findAnimations(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Animation") then
                table.insert(animations, child)
            end
            findAnimations(child)
        end
    end
    
    findAnimations(model)
    
    print("Animation objects found: " .. #animations)
    
    for i, anim in pairs(animations) do
        print("Animation " .. i .. " ID: " .. anim.AnimationId)
    end
    
    print("\n=== ANALYSIS COMPLETE ===")
end

-- Button click event
button.MouseButton1Click:Connect(function()
    print("Searching for nearby pet...")
    
    local pet = findClosestPet()
    
    if pet then
        analyzeAnimations(pet)
    else
        print("No pet found nearby! Make sure your pet is close to you.")
        print("Searched areas: workspace.Pets, workspace.pets, and direct workspace children")
    end
end)

print("Pet Analyzer loaded! Click the 'Analyze Pet' button to scan for nearby pets.")
