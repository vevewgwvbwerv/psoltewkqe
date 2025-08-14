-- 🐾 PET VISUAL COPY SYSTEM
-- Создание визуальных копий питомцев с полным сохранением всех компонентов

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- Глобальные переменные
local gui = nil
local petDatabase = {} -- База данных доступных питомцев
local selectedPet = nil

print("🚀 Pet Visual Copy System - Запуск системы...")

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===

-- Генерация UUID имени
local function generateUUIDName(baseName)
    local uuid = HttpService:GenerateGUID(false)
    return baseName .. "_" .. uuid
end

-- Поиск питомцев с визуальными компонентами
local function hasPetVisuals(model)
    local meshCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") and obj.MeshId ~= "" then
            meshCount = meshCount + 1
        elseif obj:IsA("SpecialMesh") and (obj.MeshId ~= "" or obj.TextureId ~= "") then
            meshCount = meshCount + 1
        end
    end
    
    return meshCount > 0
end

-- Поиск доступных питомцев в Workspace
local function findAvailablePets()
    print("🔍 Поиск доступных питомцев в Workspace...")
    
    local foundPets = {}
    local SEARCH_RADIUS = 100
    
    -- Получаем позицию игрока
    local playerChar = player.Character
    local playerPos = Vector3.new(0, 0, 0)
    if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
        playerPos = playerChar.HumanoidRootPart.Position
    end
    
    -- Поиск моделей с UUID именами
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= SEARCH_RADIUS then
                    local hasVisuals = hasPetVisuals(obj)
                    if hasVisuals then
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance,
                            name = obj.Name
                        })
                        print("🐾 Найден питомец: " .. obj.Name .. " (" .. math.floor(distance) .. " studs)")
                    end
                end
            end
        end
    end
    
    -- Сортировка по расстоянию
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    
    print("📊 Найдено питомцев: " .. #foundPets)
    return foundPets
end

-- Копирование всех компонентов питомца
local function copyPetComponents(originalPet)
    print("📋 Копирование компонентов питомца: " .. originalPet.Name)
    
    -- Клонируем модель
    local petClone = originalPet:Clone()
    petClone.Name = generateUUIDName("VisualCopy")
    
    -- Убедимся что все важные компоненты сохранены
    local components = {
        Motor6D = 0,
        MeshParts = 0,
        SpecialMeshes = 0,
        Animations = 0,
        Humanoids = 0,
        BaseParts = 0
    }
    
    -- Подсчет и проверка компонентов
    for _, obj in pairs(petClone:GetDescendants()) do
        if obj:IsA("Motor6D") then
            components.Motor6D = components.Motor6D + 1
        elseif obj:IsA("MeshPart") then
            components.MeshParts = components.MeshParts + 1
        elseif obj:IsA("SpecialMesh") then
            components.SpecialMeshes = components.SpecialMeshes + 1
        elseif obj:IsA("Animation") then
            components.Animations = components.Animations + 1
        elseif obj:IsA("Humanoid") then
            components.Humanoids = components.Humanoids + 1
        elseif obj:IsA("BasePart") then
            components.BaseParts = components.BaseParts + 1
        end
    end
    
    print("📊 Компоненты клона:")
    for componentName, count in pairs(components) do
        print("  " .. componentName .. ": " .. count)
    end
    
    return petClone, components
end

-- Настройка анимаций для клона
local function setupCloneAnimations(petClone)
    print("🎭 Настройка анимаций для клона...")
    
    -- Поиск AnimationController и Animator
    local animationController = nil
    local animator = nil
    
    for _, obj in pairs(petClone:GetDescendants()) do
        if obj:IsA("AnimationController") then
            animationController = obj
        elseif obj:IsA("Animator") then
            animator = obj
        end
    end
    
    if animationController and animator then
        print("✅ Найдены AnimationController и Animator")
        
        -- Запуск всех анимаций в цикле
        local success, tracks = pcall(function()
            return animator:GetPlayingAnimationTracks()
        end)
        
        if success and tracks then
            for _, track in pairs(tracks) do
                pcall(function()
                    track.Looped = true
                    track:Play()
                end)
            end
            print("✅ Анимации запущены в цикле")
        end
        
        return true
    else
        print("❌ AnimationController или Animator не найдены")
        return false
    end
end

-- === ФУНКЦИИ GUI ===

-- Создание современного GUI
local function createModernGUI()
    print("🎨 Создание современного GUI...")
    
    -- Удаление предыдущего GUI если есть
    if player:FindFirstChild("PlayerGui"):FindFirstChild("PetVisualCopyGUI") then
        player:FindFirstChild("PlayerGui").PetVisualCopyGUI:Destroy()
    end
    
    -- Создание нового GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetVisualCopyGUI"
    screenGui.Parent = player:FindFirstChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Основной фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Закругленные углы
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Тень
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🐾 PET VISUAL COPY SYSTEM"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Разделитель
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.Position = UDim2.new(0, 0, 0, 45)
    separator.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    separator.Parent = mainFrame
    
    -- Список питомцев
    local listLabel = Instance.new("TextLabel")
    listLabel.Size = UDim2.new(1, 0, 0, 30)
    listLabel.Position = UDim2.new(0, 0, 0, 55)
    listLabel.BackgroundTransparency = 1
    listLabel.Text = "Доступные питомцы рядом:"
    listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    listLabel.TextSize = 16
    listLabel.Font = Enum.Font.Gotham
    listLabel.TextXAlignment = Enum.TextXAlignment.Left
    listLabel.Parent = mainFrame
    
    -- Фрейм для списка
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, -20, 0, 200)
    listFrame.Position = UDim2.new(0, 10, 0, 90)
    listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    listFrame.BorderSizePixel = 0
    listFrame.Parent = mainFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = listFrame
    
    -- Скроллбар для списка
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = listFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    -- Кнопка обновления списка
    local refreshButton = Instance.new("TextButton")
    refreshButton.Size = UDim2.new(0, 180, 0, 40)
    refreshButton.Position = UDim2.new(0, 10, 0, 300)
    refreshButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    refreshButton.Text = "🔄 Обновить список"
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.TextSize = 16
    refreshButton.Font = Enum.Font.Gotham
    refreshButton.Parent = mainFrame
    
    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 8)
    refreshCorner.Parent = refreshButton
    
    -- Кнопка "Взять питомца"
    local takeButton = Instance.new("TextButton")
    takeButton.Size = UDim2.new(0, 180, 0, 40)
    takeButton.Position = UDim2.new(0, 210, 0, 300)
    takeButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    takeButton.Text = "🐾 Взять питомца"
    takeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    takeButton.TextSize = 16
    takeButton.Font = Enum.Font.Gotham
    takeButton.Parent = mainFrame
    
    local takeCorner = Instance.new("UICorner")
    takeCorner.CornerRadius = UDim.new(0, 8)
    takeCorner.Parent = takeButton
    
    -- Информация о выбранном питомце
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, -20, 0, 120)
    infoFrame.Position = UDim2.new(0, 10, 0, 350)
    infoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = mainFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 10)
    infoCorner.Parent = infoFrame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 30)
    infoLabel.Position = UDim2.new(0, 0, 0, 5)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Информация о выбранном питомце:"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 16
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = infoFrame
    
    local petInfo = Instance.new("TextLabel")
    petInfo.Size = UDim2.new(1, -10, 0, 80)
    petInfo.Position = UDim2.new(0, 5, 0, 35)
    petInfo.BackgroundTransparency = 1
    petInfo.Text = "Питомец не выбран"
    petInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
    petInfo.TextSize = 14
    petInfo.Font = Enum.Font.Gotham
    petInfo.TextWrapped = true
    petInfo.TextXAlignment = Enum.TextXAlignment.Left
    petInfo.TextYAlignment = Enum.TextYAlignment.Top
    petInfo.Parent = infoFrame
    
    -- Закрытие GUI
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Drag functionality
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            update(dragInput)
        end
    end)
    
    -- Функциональность кнопок
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    refreshButton.MouseButton1Click:Connect(function()
        refreshPetList(scrollFrame, petInfo)
    end)
    
    takeButton.MouseButton1Click:Connect(function()
        if selectedPet then
            takePetCopy(selectedPet)
        else
            print("❌ Питомец не выбран!")
        end
    end)
    
    -- Инициализация списка
    refreshPetList(scrollFrame, petInfo)
    
    return screenGui, scrollFrame, petInfo
end

-- Обновление списка питомцев
local function refreshPetList(scrollFrame, petInfo)
    print("🔄 Обновление списка питомцев...")
    
    -- Очистка списка
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Поиск питомцев
    petDatabase = findAvailablePets()
    
    -- Обновление размера канваса
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #petDatabase * 35)
    
    -- Создание кнопок для каждого питомца
    for i, petData in ipairs(petDatabase) do
        local petButton = Instance.new("TextButton")
        petButton.Size = UDim2.new(1, -10, 0, 30)
        petButton.Position = UDim2.new(0, 5, 0, (i-1) * 35)
        petButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        petButton.Text = petData.name .. " (" .. math.floor(petData.distance) .. " studs)"
        petButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        petButton.TextSize = 14
        petButton.Font = Enum.Font.Gotham
        petButton.Parent = scrollFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = petButton
        
        -- Обработчик выбора питомца
        petButton.MouseButton1Click:Connect(function()
            selectedPet = petData.model
            
            -- Обновление информации
            local infoText = "Имя: " .. petData.name .. "\n"
            infoText = infoText .. "Расстояние: " .. math.floor(petData.distance) .. " studs\n"
            infoText = infoText .. "Статус: Готов к копированию"
            petInfo.Text = infoText
            
            -- Подсветка выбранной кнопки
            for _, child in pairs(scrollFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end
            end
            petButton.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
        end)
    end
    
    print("✅ Список обновлен. Найдено питомцев: " .. #petDatabase)
end

-- Создание копии питомца и помещение в backpack
local function takePetCopy(originalPet)
    print("🐾 Создание копии питомца: " .. originalPet.Name)
    
    -- Копирование компонентов
    local petClone, components = copyPetComponents(originalPet)
    
    -- Настройка анимаций
    setupCloneAnimations(petClone)
    
    -- Создание инструмента для backpack
    local petTool = Instance.new("Tool")
    petTool.Name = "Visual Pet Copy"
    petTool.RequiresHandle = false
    
    -- Добавление клона как потомка инструмента
    petClone.Parent = petTool
    
    -- Скрытие клона до активации
    petClone.Enabled = false
    
    -- Обработчик активации инструмента
    petTool.Equipped:Connect(function()
        print("🔧 Инструмент активирован. Показ питомца...")
        petClone.Enabled = true
        
        -- Позиционирование питомца в руке
        local character = player.Character
        if character and character:FindFirstChild("RightHand") then
            petClone:SetPrimaryPartCFrame(character.RightHand.CFrame)
        elseif character and character:FindFirstChild("HumanoidRootPart") then
            petClone:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0))
        end
    end)
    
    -- Обработчик деактивации инструмента
    petTool.Unequipped:Connect(function()
        print("🔧 Инструмент деактивирован. Скрытие питомца...")
        petClone.Enabled = false
    end)
    
    -- Обработчик использования инструмента (спавн питомца)
    petTool.Activated:Connect(function()
        print("🚀 Спаун питомца в Workspace...")
        spawnPetInWorkspace(petClone, components)
        
        -- Удаление инструмента после спавна
        petTool:Destroy()
    end)
    
    -- Помещение инструмента в backpack
    petTool.Parent = backpack
    
    print("✅ Копия питомца создана и помещена в backpack!")
    print("💡 Активируйте инструмент, чтобы увидеть питомца в руке")
    print("💡 Нажмите ЛКМ, чтобы заспавнить питомца в мире")
end

-- Спаун питомца в Workspace
local function spawnPetInWorkspace(originalClone, components)
    print("🌍 Спаун питомца в Workspace...")
    
    -- Создание новой копии для спавна
    local spawnClone = originalClone:Clone()
    spawnClone.Name = generateUUIDName("SpawnedPet")
    spawnClone.Enabled = true
    
    -- Получение позиции игрока
    local playerChar = player.Character
    local spawnPosition = Vector3.new(0, 5, 0)
    
    if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
        spawnPosition = playerChar.HumanoidRootPart.Position + Vector3.new(3, 0, 0)
    end
    
    -- Установка позиции
    spawnClone:PivotTo(CFrame.new(spawnPosition))
    
    -- Настройка анимаций для спавн-копии
    setupCloneAnimations(spawnClone)
    
    -- Помещение в Workspace
    spawnClone.Parent = Workspace
    
    -- Запуск плавного появления
    spawnClone.Transparency = 1
    
    for _, part in pairs(spawnClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    
    -- Анимация появления
    spawn(function()
        for i = 1, 10 do
            local transparency = 1 - (i / 10)
            
            for _, part in pairs(spawnClone:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = transparency
                end
            end
            
            wait(0.05)
        end
        
        -- Установка полной видимости
        for _, part in pairs(spawnClone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        
        print("🎉 Питомец успешно заспавнен в Workspace!")
        print("🆔 Уникальное имя: " .. spawnClone.Name)
        
        -- Запуск поведения питомца
        setupPetBehavior(spawnClone)
    end)
end

-- Настройка поведения питомца
local function setupPetBehavior(petModel)
    print("🤖 Настройка поведения питомца...")
    
    -- Поиск Humanoid
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        print("❌ Humanoid не найден. Создание нового...")
        humanoid = Instance.new("Humanoid")
        humanoid.Parent = petModel
    end
    
    -- Поиск PrimaryPart
    if not petModel.PrimaryPart then
        for _, part in pairs(petModel:GetDescendants()) do
            if part:IsA("BasePart") then
                petModel.PrimaryPart = part
                break
            end
        end
    end
    
    -- Плавающее поведение
    spawn(function()
        local floatOffset = 0
        local rootPart = petModel.PrimaryPart
        
        if rootPart then
            local originalPosition = rootPart.Position
            
            while petModel and petModel.Parent do
                floatOffset = floatOffset + 0.1
                local yOffset = math.sin(floatOffset) * 0.5
                
                rootPart.Position = originalPosition + Vector3.new(0, yOffset, 0)
                
                wait(0.1)
            end
        end
    end)
    
    -- Поворот к игроку
    spawn(function()
        local rootPart = petModel.PrimaryPart
        
        if rootPart then
            while petModel and petModel.Parent do
                local playerChar = player.Character
                if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                    local lookAtPos = playerChar.HumanoidRootPart.Position
                    local currentPos = rootPart.Position
                    
                    local lookCFrame = CFrame.lookAt(currentPos, Vector3.new(lookAtPos.X, currentPos.Y, lookAtPos.Z))
                    rootPart.CFrame = lookCFrame
                end
                
                wait(0.5)
            end
        end
    end)
    
    print("✅ Поведение питомца настроено!")
end

-- === ОСНОВНАЯ ФУНКЦИЯ ===

-- Запуск системы
local function init()
    print("\n🚀 === ЗАПУСК PET VISUAL COPY SYSTEM ===")
    print("🎯 Цель: Создание визуальных копий питомцев с полным сохранением компонентов")
    print("💡 Компоненты: MeshId, Motor6D, CFrame, Animation, Humanoid, Parts")
    print("💡 Функции: GUI выбор, копирование, backpack, спавн с UUID именем")
    
    -- Создание GUI
    local screenGui, scrollFrame, petInfo = createModernGUI()
    gui = screenGui
    
    print("✅ Система готова к использованию!")
    print("💡 Нажмите 'Обновить список' для поиска питомцев")
    print("💡 Выберите питомца и нажмите 'Взять питомца'")
end

-- Автозапуск
spawn(function()
    wait(2) -- Ожидание загрузки персонажа
    init()
end)

-- Команда для ручного запуска
print("\n💡 Для ручного запуска используйте: init()")
