-- 🎯 PET GIVER ULTIMATE - Полная система выдачи питомцев
-- Создает GUI для выбора питомца, выдает в backpack с анимациями, размещает в workspace как UUID питомца

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

-- 🎨 GUI ПЕРЕМЕННЫЕ
local mainGui = nil
local petListFrame = nil
local selectedPetName = nil
local previewFrame = nil

-- 📝 ЛОГИРОВАНИЕ
local function logEvent(eventType, message, data)
    local timestamp = os.date("%H:%M:%S")
    local logMessage = string.format("[%s] %s: %s", timestamp, eventType, message)
    if data then
        for key, value in pairs(data) do
            logMessage = logMessage .. string.format(" | %s: %s", key, tostring(value))
        end
    end
    print(logMessage)
end

-- 🔧 ГЕНЕРАЦИЯ UUID
local function generateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- 📊 ДАННЫЕ ПИТОМЦЕВ (из Pets.lua)
local PetsData = {
    ["Dog"] = {
        ["Description"] = "Digging Buddy: Occasionally digs up a random seed",
        ["Model"] = "Dog",
        ["WeldOffset"] = CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966),
        ["Icon"] = "rbxassetid://135018170520317",
        ["MovementType"] = "Grounded",
        ["MovementSpeed"] = 10,
        ["Rarity"] = "Common"
    },
    ["Golden Lab"] = {
        ["Description"] = "Digging Friend: Occasionally digs up a random seed at a higher chance",
        ["Model"] = "Dog",
        ["Variant"] = "Golden Lab",
        ["WeldOffset"] = CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966),
        ["Icon"] = "rbxassetid://99376934607716",
        ["MovementType"] = "Grounded",
        ["MovementSpeed"] = 10,
        ["Rarity"] = "Common"
    },
    ["Bunny"] = {
        ["Description"] = "Carrot Chomper: Runs to carrots, eats them, and grants bonus sheckles",
        ["Model"] = "Bunny",
        ["WeldOffset"] = CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966),
        ["Icon"] = "rbxassetid://85830855120751",
        ["MovementType"] = "Grounded",
        ["MovementSpeed"] = 9,
        ["Rarity"] = "Common"
    },
    ["Cat"] = {
        ["Description"] = "Sleepy Kitty: Occasionally sleeps and grants bonus sheckles",
        ["Model"] = "Cat",
        ["WeldOffset"] = CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966),
        ["Icon"] = "rbxassetid://123456789",
        ["MovementType"] = "Grounded",
        ["MovementSpeed"] = 8,
        ["Rarity"] = "Common"
    },
    ["Dragon"] = {
        ["Description"] = "Mystical Dragon: Flies around and grants magical bonuses",
        ["Model"] = "Dragon",
        ["WeldOffset"] = CFrame.Angles(0, 1.5707963267948966, 3.141592653589793),
        ["Icon"] = "rbxassetid://987654321",
        ["MovementType"] = "Flying",
        ["MovementSpeed"] = 15,
        ["Rarity"] = "Legendary"
    }
}

-- 🎯 СОЗДАНИЕ TOOL С ПИТОМЦЕМ
local function createPetTool(petName, petData)
    logEvent("🔧 TOOL_CREATE", "Creating pet tool", {PetName = petName})
    
    local tool = Instance.new("Tool")
    tool.Name = petName .. "_Pet"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    
    -- Создаем Handle (основная часть питомца)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Material = Enum.Material.Neon
    handle.BrickColor = BrickColor.new("Bright blue")
    handle.Shape = Enum.PartType.Ball
    handle.CanCollide = false
    handle.Parent = tool
    
    -- Добавляем визуальные эффекты
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxasset://fonts/leftarm.mesh" -- Временный меш
    mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
    mesh.Parent = handle
    
    -- Добавляем свечение
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 1
    pointLight.Range = 10
    pointLight.Color = Color3.fromRGB(0, 162, 255)
    pointLight.Parent = handle
    
    -- Анимация вращения
    local rotationTween = TweenService:Create(handle, 
        TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {CFrame = handle.CFrame * CFrame.Angles(0, math.rad(360), 0)}
    )
    
    -- События Tool
    tool.Equipped:Connect(function()
        logEvent("🎮 TOOL_EQUIPPED", petName)
        rotationTween:Play()
        
        -- Применяем WeldOffset если есть
        if petData.WeldOffset then
            handle.CFrame = handle.CFrame * petData.WeldOffset
        end
    end)
    
    tool.Unequipped:Connect(function()
        logEvent("🎮 TOOL_UNEQUIPPED", petName)
        rotationTween:Cancel()
    end)
    
    -- Активация - размещение питомца в workspace
    tool.Activated:Connect(function()
        logEvent("🚀 TOOL_ACTIVATED", "Placing pet in workspace", {PetName = petName})
        createUUIDPetInWorkspace(petName, petData)
        tool:Destroy()
    end)
    
    return tool
end

-- 🌍 СОЗДАНИЕ UUID ПИТОМЦА В WORKSPACE
local function createUUIDPetInWorkspace(petName, petData)
    local uuid = generateUUID()
    local fullName = "{" .. uuid .. "}"
    
    logEvent("🌍 WORKSPACE_CREATE", "Creating UUID pet in workspace", {
        PetName = petName,
        UUID = uuid,
        MovementType = petData.MovementType,
        MovementSpeed = petData.MovementSpeed
    })
    
    -- Создаем основную модель
    local model = Instance.new("Model")
    model.Name = fullName
    
    -- Создаем Humanoid для движения
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.WalkSpeed = petData.MovementSpeed or 10
    humanoid.Parent = model
    
    -- Создаем HumanoidRootPart
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(1, 1, 1)
    rootPart.Material = Enum.Material.ForceField
    rootPart.BrickColor = BrickColor.new("Bright green")
    rootPart.CanCollide = false
    rootPart.Anchored = false
    rootPart.Parent = model
    
    -- Устанавливаем PrimaryPart
    model.PrimaryPart = rootPart
    
    -- Создаем тело питомца
    local bodyPart = Instance.new("Part")
    bodyPart.Name = "Body"
    bodyPart.Size = Vector3.new(2, 1, 1)
    bodyPart.Material = Enum.Material.Neon
    bodyPart.BrickColor = BrickColor.new("Bright red")
    bodyPart.CanCollide = true
    bodyPart.Parent = model
    
    -- Соединяем части через Motor6D
    local motor6D = Instance.new("Motor6D")
    motor6D.Name = "RootJoint"
    motor6D.Part0 = rootPart
    motor6D.Part1 = bodyPart
    motor6D.C0 = CFrame.new(0, 0, 0)
    motor6D.C1 = CFrame.new(0, 0.5, 0)
    motor6D.Parent = rootPart
    
    -- Добавляем голову
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1, 1, 1)
    head.Material = Enum.Material.Neon
    head.BrickColor = BrickColor.new("Bright yellow")
    head.Shape = Enum.PartType.Ball
    head.CanCollide = false
    head.Parent = model
    
    -- Соединяем голову
    local neckMotor = Instance.new("Motor6D")
    neckMotor.Name = "Neck"
    neckMotor.Part0 = bodyPart
    neckMotor.Part1 = head
    neckMotor.C0 = CFrame.new(0, 0.5, 0)
    neckMotor.C1 = CFrame.new(0, -0.5, 0)
    neckMotor.Parent = bodyPart
    
    -- Добавляем лицо
    local face = Instance.new("Decal")
    face.Texture = "rbxasset://textures/face.png"
    face.Face = Enum.NormalId.Front
    face.Parent = head
    
    -- Позиционируем рядом с игроком
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local playerPosition = character.HumanoidRootPart.Position
        local spawnPosition = playerPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
        model:SetPrimaryPartCFrame(CFrame.new(spawnPosition))
    end
    
    -- Размещаем в workspace
    model.Parent = workspace
    
    -- Добавляем простое AI движение
    spawn(function()
        wait(1) -- Даем время на загрузку
        
        while model.Parent and humanoid.Parent do
            wait(math.random(2, 5))
            
            if model.Parent then
                local randomDirection = Vector3.new(
                    math.random(-20, 20),
                    0,
                    math.random(-20, 20)
                )
                
                local currentPosition = model.PrimaryPart.Position
                local targetPosition = currentPosition + randomDirection
                
                humanoid:MoveTo(targetPosition)
                
                logEvent("🚶 PET_MOVEMENT", "Pet moving to new position", {
                    UUID = uuid,
                    From = tostring(currentPosition),
                    To = tostring(targetPosition)
                })
            end
        end
    end)
    
    logEvent("✅ PET_CREATED", "UUID pet successfully created", {
        PetName = petName,
        UUID = uuid,
        Position = tostring(model.PrimaryPart.Position)
    })
end

-- 🎨 СОЗДАНИЕ GUI
local function createMainGui()
    logEvent("🎨 GUI_CREATE", "Creating main GUI interface")
    
    -- Основной ScreenGui
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "PetGiverGUI"
    mainGui.ResetOnSpawn = false
    mainGui.Parent = playerGui
    
    -- Главное окно
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = mainGui
    
    -- Закругленные углы
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🎯 PET GIVER ULTIMATE"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleLabel
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleLabel
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        logEvent("🎨 GUI_CLOSE", "Closing GUI")
        mainGui:Destroy()
    end)
    
    -- Список питомцев
    petListFrame = Instance.new("ScrollingFrame")
    petListFrame.Name = "PetListFrame"
    petListFrame.Size = UDim2.new(0.6, -10, 1, -70)
    petListFrame.Position = UDim2.new(0, 10, 0, 60)
    petListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    petListFrame.BorderSizePixel = 0
    petListFrame.ScrollBarThickness = 8
    petListFrame.Parent = mainFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = petListFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = petListFrame
    
    -- Панель предпросмотра
    previewFrame = Instance.new("Frame")
    previewFrame.Name = "PreviewFrame"
    previewFrame.Size = UDim2.new(0.4, -10, 1, -70)
    previewFrame.Position = UDim2.new(0.6, 0, 0, 60)
    previewFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    previewFrame.BorderSizePixel = 0
    previewFrame.Parent = mainFrame
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 10)
    previewCorner.Parent = previewFrame
    
    -- Заполняем список питомцев
    populatePetList()
    createPreviewPanel()
    
    logEvent("✅ GUI_READY", "GUI interface created successfully")
end

-- 📋 ЗАПОЛНЕНИЕ СПИСКА ПИТОМЦЕВ
local function populatePetList()
    logEvent("📋 LIST_POPULATE", "Populating pet list")
    
    for petName, petData in pairs(PetsData) do
        local petButton = Instance.new("TextButton")
        petButton.Name = petName .. "_Button"
        petButton.Size = UDim2.new(1, -10, 0, 60)
        petButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        petButton.BorderSizePixel = 0
        petButton.Text = ""
        petButton.Parent = petListFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = petButton
        
        -- Иконка питомца
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 50, 0, 50)
        icon.Position = UDim2.new(0, 5, 0, 5)
        icon.BackgroundTransparency = 1
        icon.Image = petData.Icon or "rbxassetid://0"
        icon.Parent = petButton
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 5)
        iconCorner.Parent = icon
        
        -- Название питомца
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, -65, 0, 25)
        nameLabel.Position = UDim2.new(0, 60, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = petName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = petButton
        
        -- Редкость питомца
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Name = "RarityLabel"
        rarityLabel.Size = UDim2.new(1, -65, 0, 20)
        rarityLabel.Position = UDim2.new(0, 60, 0, 30)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = "🌟 " .. (petData.Rarity or "Unknown")
        rarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        rarityLabel.TextScaled = true
        rarityLabel.Font = Enum.Font.Gotham
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
        rarityLabel.Parent = petButton
        
        -- Обработка клика
        petButton.MouseButton1Click:Connect(function()
            selectPet(petName, petData)
        end)
        
        -- Эффект наведения
        petButton.MouseEnter:Connect(function()
            TweenService:Create(petButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        end)
        
        petButton.MouseLeave:Connect(function()
            local targetColor = (selectedPetName == petName) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(60, 60, 60)
            TweenService:Create(petButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        end)
    end
    
    -- Обновляем размер содержимого
    petListFrame.CanvasSize = UDim2.new(0, 0, 0, #PetsData * 65)
end

-- 🎯 ВЫБОР ПИТОМЦА
local function selectPet(petName, petData)
    logEvent("🎯 PET_SELECT", "Pet selected", {PetName = petName, Rarity = petData.Rarity})
    
    selectedPetName = petName
    
    -- Обновляем визуальное выделение
    for _, button in pairs(petListFrame:GetChildren()) do
        if button:IsA("TextButton") then
            local isSelected = button.Name == petName .. "_Button"
            local targetColor = isSelected and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(60, 60, 60)
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
        end
    end
    
    -- Обновляем панель предпросмотра
    updatePreviewPanel(petName, petData)
end

-- 🖼️ СОЗДАНИЕ ПАНЕЛИ ПРЕДПРОСМОТРА
local function createPreviewPanel()
    -- Заголовок предпросмотра
    local previewTitle = Instance.new("TextLabel")
    previewTitle.Name = "PreviewTitle"
    previewTitle.Size = UDim2.new(1, 0, 0, 40)
    previewTitle.Position = UDim2.new(0, 0, 0, 0)
    previewTitle.BackgroundTransparency = 1
    previewTitle.Text = "🖼️ Pet Preview"
    previewTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    previewTitle.TextScaled = true
    previewTitle.Font = Enum.Font.GothamBold
    previewTitle.Parent = previewFrame
    
    -- Область информации
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, -10, 1, -100)
    infoFrame.Position = UDim2.new(0, 5, 0, 45)
    infoFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = previewFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoFrame
    
    -- Кнопка "Взять питомца"
    local takeButton = Instance.new("TextButton")
    takeButton.Name = "TakeButton"
    takeButton.Size = UDim2.new(1, -10, 0, 40)
    takeButton.Position = UDim2.new(0, 5, 1, -45)
    takeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    takeButton.BorderSizePixel = 0
    takeButton.Text = "🎁 ВЗЯТЬ ПИТОМЦА"
    takeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    takeButton.TextScaled = true
    takeButton.Font = Enum.Font.GothamBold
    takeButton.Parent = previewFrame
    
    local takeCorner = Instance.new("UICorner")
    takeCorner.CornerRadius = UDim.new(0, 8)
    takeCorner.Parent = takeButton
    
    takeButton.MouseButton1Click:Connect(function()
        if selectedPetName then
            givePetToPlayer(selectedPetName, PetsData[selectedPetName])
        else
            logEvent("⚠️ WARNING", "No pet selected")
        end
    end)
    
    -- Эффекты для кнопки
    takeButton.MouseEnter:Connect(function()
        TweenService:Create(takeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play()
    end)
    
    takeButton.MouseLeave:Connect(function()
        TweenService:Create(takeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 180, 0)}):Play()
    end)
end

-- 🔄 ОБНОВЛЕНИЕ ПАНЕЛИ ПРЕДПРОСМОТРА
local function updatePreviewPanel(petName, petData)
    local infoFrame = previewFrame:FindFirstChild("InfoFrame")
    if not infoFrame then return end
    
    -- Очищаем старую информацию
    for _, child in pairs(infoFrame:GetChildren()) do
        if not child:IsA("UICorner") then
            child:Destroy()
        end
    end
    
    -- Создаем новую информацию
    local yOffset = 10
    
    -- Название
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 30)
    nameLabel.Position = UDim2.new(0, 5, 0, yOffset)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "📛 " .. petName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = infoFrame
    yOffset = yOffset + 35
    
    -- Описание
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -10, 0, 40)
    descLabel.Position = UDim2.new(0, 5, 0, yOffset)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "📝 " .. (petData.Description or "No description")
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.Parent = infoFrame
    yOffset = yOffset + 45
    
    -- Редкость
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Size = UDim2.new(1, -10, 0, 25)
    rarityLabel.Position = UDim2.new(0, 5, 0, yOffset)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = "🌟 Rarity: " .. (petData.Rarity or "Unknown")
    rarityLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    rarityLabel.TextScaled = true
    rarityLabel.Font = Enum.Font.GothamBold
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = infoFrame
    yOffset = yOffset + 30
    
    -- Тип движения
    local movementLabel = Instance.new("TextLabel")
    movementLabel.Size = UDim2.new(1, -10, 0, 25)
    movementLabel.Position = UDim2.new(0, 5, 0, yOffset)
    movementLabel.BackgroundTransparency = 1
    movementLabel.Text = "🚶 Movement: " .. (petData.MovementType or "Unknown")
    movementLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    movementLabel.TextScaled = true
    movementLabel.Font = Enum.Font.Gotham
    movementLabel.TextXAlignment = Enum.TextXAlignment.Left
    movementLabel.Parent = infoFrame
end

-- 🎁 ВЫДАЧА ПИТОМЦА ИГРОКУ
local function givePetToPlayer(petName, petData)
    logEvent("🎁 PET_GIVE", "Giving pet to player", {PetName = petName})
    
    local tool = createPetTool(petName, petData)
    tool.Parent = backpack
    
    logEvent("✅ PET_GIVEN", "Pet successfully given to player", {
        PetName = petName,
        ToolName = tool.Name
    })
end

-- 🚀 ЗАПУСК СИСТЕМЫ
local function startPetGiver()
    logEvent("🚀 STARTUP", "Starting Pet Giver System")
    createMainGui()
end

-- Горячая клавиша для открытия GUI (F для "Pet")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        if mainGui then
            mainGui:Destroy()
            mainGui = nil
        else
            startPetGiver()
        end
    end
end)

logEvent("🚀 SYSTEM_START", "PetGiver ULTIMATE initialized - Press P to open GUI")
