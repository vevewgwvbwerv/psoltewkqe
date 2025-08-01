-- Low-Level Interception - Hook into Roblox's internal systems
-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Clear previous GUI
if CoreGui:FindFirstChild("LowLevelInterception_GUI") then 
    CoreGui.LowLevelInterception_GUI:Destroy() 
end

-- Storage
local isInterceptionActive = false
local handPetReference = nil
local originalConnections = {}

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "LowLevelInterception_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 320, 0, 180)
mainFrame.Position = UDim2.new(0.65, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 40)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 Low-Level Interception"
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
toggleBtn.Text = "❌ Interception: OFF"

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

-- Hook Counter Label
local hookLabel = Instance.new("TextLabel", mainFrame)
hookLabel.Size = UDim2.new(1, -10, 0, 20)
hookLabel.Position = UDim2.new(0, 5, 0.85, 0)
hookLabel.BackgroundTransparency = 1
hookLabel.Text = "Hooks: 0"
hookLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
hookLabel.Font = Enum.Font.Gotham
hookLabel.TextScaled = true

-- List of known pet names
local petNames = {
    "Dog", "Bunny", "Golden Lab", "Black Bunny", "Chicken", "Cat", "Deer",
    "Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey",
    "Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear",
    "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox",
    "Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon",
    "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}

-- Function: Get hand pet reference
local function getHandPetReference()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    return tool
end

-- Function: Hook into Instance.new to intercept model creation
local originalInstanceNew = Instance.new
local hookCount = 0

local function hookedInstanceNew(className, parent)
    hookCount = hookCount + 1
    
    if hookCount % 100 == 0 then
        hookLabel.Text = "Hooks: " .. hookCount
    end
    
    -- Create the instance normally first
    local instance = originalInstanceNew(className, parent)
    
    -- If it's a Model being created in Workspace.Visuals, intercept it
    if className == "Model" and parent and parent.Name == "Visuals" and isInterceptionActive then
        print("🔥 INTERCEPTED Model creation in Visuals!")
        
        -- Wait for it to be named
        spawn(function()
            local attempts = 0
            while instance.Name == "Model" and attempts < 50 do
                wait(0.1)
                attempts = attempts + 1
            end
            
            -- Check if it's a pet model
            local isPetModel = false
            for _, petName in ipairs(petNames) do
                if instance.Name == petName then
                    isPetModel = true
                    break
                end
            end
            
            if isPetModel then
                print("🔥 INTERCEPTED PET MODEL:", instance.Name)
                debugLabel.Text = "Debug: HOOKED " .. instance.Name
                statusLabel.Text = "Status: Intercepted " .. instance.Name
                
                -- Try to replace with hand pet immediately
                local handPet = getHandPetReference()
                if handPet then
                    print("🔥 ATTEMPTING DEEP REPLACEMENT")
                    
                    -- Wait for the model to fully load
                    wait(0.2)
                    
                    -- Try to replace the ENTIRE model structure
                    local handPetClone = handPet:Clone()
                    handPetClone.Name = instance.Name
                    handPetClone.Parent = instance.Parent
                    
                    -- Copy position from original
                    local originalPart = instance:FindFirstChildWhichIsA("BasePart")
                    local clonePart = handPetClone:FindFirstChildWhichIsA("BasePart")
                    
                    if originalPart and clonePart then
                        clonePart.CFrame = originalPart.CFrame
                        
                        -- Configure clone
                        for _, part in pairs(handPetClone:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false  -- Let it be animated
                                part.CanCollide = false
                                part.Transparency = 0
                            end
                        end
                    end
                    
                    -- DESTROY the original model
                    instance:Destroy()
                    
                    print("🔥 DEEP REPLACEMENT COMPLETE!")
                    statusLabel.Text = "Status: REPLACED " .. instance.Name
                else
                    print("❌ No hand pet for replacement")
                end
            end
        end)
    end
    
    return instance
end

-- Function: Hook into workspace changes
local function hookWorkspaceChanges()
    print("🔥 HOOKING WORKSPACE CHANGES")
    
    -- Hook Instance.new globally
    getgenv().Instance = getgenv().Instance or {}
    getgenv().Instance.new = hookedInstanceNew
    
    print("🔥 Instance.new HOOKED!")
    
    -- Also hook ChildAdded events at multiple levels
    local visuals = Workspace:FindFirstChild("Visuals")
    if visuals then
        local connection = visuals.ChildAdded:Connect(function(child)
            if not isInterceptionActive then return end
            
            print("🔥 VISUALS CHILD ADDED:", child.Name, child.ClassName)
            
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
                    print("🔥 DIRECT PET MODEL DETECTED:", child.Name)
                    
                    -- Immediate intervention
                    local handPet = getHandPetReference()
                    if handPet then
                        print("🔥 IMMEDIATE REPLACEMENT ATTEMPT")
                        
                        -- Clone hand pet
                        local replacement = handPet:Clone()
                        replacement.Name = child.Name .. "_DirectReplacement"
                        
                        -- Get position from original
                        local originalPart = child:FindFirstChildWhichIsA("BasePart")
                        local replacementPart = replacement:FindFirstChildWhichIsA("BasePart")
                        
                        if originalPart and replacementPart then
                            replacement.Parent = child.Parent
                            replacementPart.CFrame = originalPart.CFrame
                            
                            -- Configure replacement
                            for _, part in pairs(replacement:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = false
                                    part.CanCollide = false
                                    part.Transparency = 0
                                end
                            end
                            
                            -- Hide original
                            for _, part in pairs(child:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                end
                            end
                            
                            print("🔥 DIRECT REPLACEMENT SUCCESS!")
                            statusLabel.Text = "Status: DIRECT SUCCESS " .. child.Name
                        end
                    end
                end
            end
        end)
        
        table.insert(originalConnections, connection)
    end
end

-- Function: Unhook everything
local function unhookAll()
    print("🔥 UNHOOKING ALL")
    
    -- Restore original Instance.new
    if getgenv().Instance then
        getgenv().Instance.new = originalInstanceNew
    end
    
    -- Disconnect all connections
    for _, connection in ipairs(originalConnections) do
        connection:Disconnect()
    end
    originalConnections = {}
    
    print("🔥 ALL HOOKS REMOVED")
end

-- Toggle Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    isInterceptionActive = not isInterceptionActive
    
    if isInterceptionActive then
        -- Check for hand pet
        local handPet = getHandPetReference()
        if handPet then
            handPetReference = handPet
            
            toggleBtn.Text = "🔥 Interception: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            statusLabel.Text = "Status: LOW-LEVEL hooks active"
            debugLabel.Text = "Debug: Hooked " .. handPet.Name
            hookLabel.Text = "Hooks: Ready"
            
            -- Start hooking
            hookWorkspaceChanges()
        else
            isInterceptionActive = false
            statusLabel.Text = "Status: FAILED - No pet in hand"
            debugLabel.Text = "Debug: No hand pet"
        end
    else
        toggleBtn.Text = "❌ Interception: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
        statusLabel.Text = "Status: Disabled"
        debugLabel.Text = "Debug: Inactive"
        hookLabel.Text = "Hooks: 0"
        
        -- Unhook everything
        unhookAll()
        
        handPetReference = nil
        hookCount = 0
    end
end)

print("🔥 Low-Level Interception loaded!")
print("✅ DEEP METHODS:")
print("  🔥 Hooks Instance.new globally")
print("  🔥 Intercepts model creation in real-time")
print("  🔥 Replaces models DURING creation")
print("  🔥 Multiple interception points")
print("📋 Instructions:")
print("1. Hold pet in hand")
print("2. Enable 'Interception'")
print("3. Open egg")
print("4. Should intercept and replace during creation!")
