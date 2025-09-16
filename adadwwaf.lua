-- ⚡ МГНОВЕННАЯ ВИЗУАЛЬНАЯ ЗАМЕНА - Быстрая подмена модели питомца
print("⚡ Запуск системы мгновенной визуальной замены...")

local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

-- Настройки
local espEnabled = true
local replacementActive = true

-- База данных питомцев по яйцам
local eggChances = {
    ["Common Egg"] = {"Dog", "Bunny", "Golden Lab"},
    ["Uncommon Egg"] = {"Black Bunny", "Chicken", "Cat", "Deer"},
    ["Rare Egg"] = {"Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey"},
    ["Legendary Egg"] = {"Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear"},
    ["Mythic Egg"] = {"Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox"},
    ["Bug Egg"] = {"Snail", "Giant Ant", "Caterpillar", "Praying Mantis", "Dragon Fly"},
    ["Night Egg"] = {"Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon"},
    ["Bee Egg"] = {"Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"},
    ["Anti Bee Egg"] = {"Wasp", "Tarantula Hawk", "Moth", "Butterfly", "Disco Bee"},
    ["Common Summer Egg"] = {"Starfish", "Seafull", "Crab"},
    ["Rare Summer Egg"] = {"Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal"},
    ["Paradise Egg"] = {"Ostrich", "Peacock", "Capybara", "Scarlet Macaw", "Mimic Octopus"},
    ["Premium Night Egg"] = {"Hedgehog", "Mole", "Frog", "Echo Frog"},
    ["Dinosaur Egg"] = {"Raptor", "Triceratops", "T-Rex", "Stegosaurus", "Pterodactyl", "Brontosaurus"}
}

-- Хранилище данных
local displayedEggs = {}
local replacementLog = {}
local petModels = {}

-- Кэш моделей питомцев для быстрого доступа
local function cachePetModels()
    print("🔍 Кэширование моделей питомцев...")
    
    -- Поиск в ReplicatedStorage
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local modelName = obj.Name
            petModels[modelName] = obj
            
            -- Также добавляем варианты названий
            petModels[modelName:lower()] = obj
            petModels[modelName:gsub(" ", "")] = obj
            petModels[modelName:gsub(" ", "_")] = obj
        end
    end
    
    print("✅ Закэшировано моделей: " .. #petModels)
end

-- Функция получения модели питомца
local function getPetModel(petName)
    -- Сначала проверяем кэш
    if petModels[petName] then
        return petModels[petName]
    end
    
    -- Проверяем варианты названий
    local variants = {
        petName,
        petName:lower(),
        petName:upper(),
        petName:gsub(" ", ""),
        petName:gsub(" ", "_"),
        petName:gsub(" ", "-")
    }
    
    for _, variant in pairs(variants) do
        if petModels[variant] then
            return petModels[variant]
        end
    end
    
    -- Если не найдено в кэше, ищем в реальном времени
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            for _, variant in pairs(variants) do
                if obj.Name == variant then
                    petModels[petName] = obj -- Добавляем в кэш
                    return obj
                end
            end
        end
    end
    
    return nil
end

-- Функция создания ESP
local function createEspGui(egg, eggName, petName)
    if egg:FindFirstChild("EggESP") then
        egg:FindFirstChild("EggESP"):Destroy()
    end
    
    local adornee = egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart
    if not adornee then return nil end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP"
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local eggLabel = Instance.new("TextLabel")
    eggLabel.Size = UDim2.new(1, 0, 0.5, 0)
    eggLabel.BackgroundTransparency = 1
    eggLabel.Text = eggName
    eggLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    eggLabel.TextStrokeTransparency = 0
    eggLabel.TextScaled = true
    eggLabel.Font = Enum.Font.SourceSansBold
    eggLabel.Parent = billboard

    local petLabel = Instance.new("TextLabel")
    petLabel.Name = "PetLabel"
    petLabel.Size = UDim2.new(1, 0, 0.5, 0)
    petLabel.Position = UDim2.new(0, 0, 0.5, 0)
    petLabel.BackgroundTransparency = 1
    petLabel.Text = petName
    petLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    petLabel.TextStrokeTransparency = 0
    petLabel.TextScaled = true
    petLabel.Font = Enum.Font.SourceSansBold
    petLabel.Parent = billboard

    billboard.Parent = egg
    return billboard
end

-- Функция поиска яиц
local function findEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, "Egg") then
            local eggName = obj.Name
            if eggChances[eggName] then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

-- Функция добавления ESP к яйцу
local function addESP(egg)
    if displayedEggs[egg] then return end
    
    local eggName = egg.Name
    if not eggChances[eggName] then return end

    local availablePets = eggChances[eggName]
    local randomPet = availablePets[math.random(1, #availablePets)]
    
    local espGui = nil
    if espEnabled then
        espGui = createEspGui(egg, eggName, randomPet)
    end
    
    displayedEggs[egg] = {
        egg = egg,
        gui = espGui,
        eggName = eggName,
        currentPet = randomPet,
        availablePets = availablePets
    }
    
    print("🥚 ESP добавлен: " .. eggName .. " → " .. randomPet)
end

-- Функция переключения ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    for egg, data in pairs(displayedEggs) do
        if espEnabled then
            if not data.gui then
                data.gui = createEspGui(egg, data.eggName, data.currentPet)
            end
        else
            if data.gui then
                data.gui:Destroy()
                data.gui = nil
            end
        end
    end
    
    print(espEnabled and "🟢 ESP включен" or "🔴 ESP выключен")
end

-- Функция рандомизации питомцев
local function randomizePets()
    local randomizedCount = 0
    
    for egg, data in pairs(displayedEggs) do
        local newPet = data.availablePets[math.random(1, #data.availablePets)]
        data.currentPet = newPet
        
        if espEnabled and data.gui then
            local petLabel = data.gui:FindFirstChild("PetLabel")
            if petLabel then
                petLabel.Text = newPet
            end
        end
        
        randomizedCount = randomizedCount + 1
        print("🎲 " .. data.eggName .. " → " .. newPet)
    end
    
    print("🎲 Рандомизировано питомцев: " .. randomizedCount)
end

-- ⚡ МГНОВЕННАЯ ЗАМЕНА ПИТОМЦА
local function instantReplacePet(originalPet, targetPetName, eggPosition)
    print("⚡ МГНОВЕННАЯ ЗАМЕНА: " .. originalPet.Name .. " → " .. targetPetName)
    
    -- Получаем модель целевого питомца
    local targetModel = getPetModel(targetPetName)
    if not targetModel then
        print("❌ Модель не найдена: " .. targetPetName)
        return false
    end
    
    -- Сохраняем важные данные оригинального питомца
    local originalData = {
        parent = originalPet.Parent,
        cframe = originalPet.PrimaryPart and originalPet.PrimaryPart.CFrame or 
                originalPet:FindFirstChildWhichIsA("BasePart") and originalPet:FindFirstChildWhichIsA("BasePart").CFrame,
        name = originalPet.Name,
        attributes = {}
    }
    
    -- Сохраняем все атрибуты
    for attr, value in pairs(originalPet:GetAttributes()) do
        originalData.attributes[attr] = value
    end
    
    -- Создаем новую модель
    local newPet = targetModel:Clone()
    newPet.Name = originalData.name -- Сохраняем оригинальное имя для совместимости
    
    -- Устанавливаем позицию
    if originalData.cframe then
        if newPet.PrimaryPart then
            newPet.PrimaryPart.CFrame = originalData.cframe
        elseif newPet:FindFirstChildWhichIsA("BasePart") then
            newPet:FindFirstChildWhichIsA("BasePart").CFrame = originalData.cframe
        end
    end
    
    -- Восстанавливаем атрибуты
    for attr, value in pairs(originalData.attributes) do
        newPet:SetAttribute(attr, value)
    end
    
    -- МГНОВЕННАЯ замена
    originalPet:Destroy()
    newPet.Parent = originalData.parent
    
    -- Логируем замену
    table.insert(replacementLog, {
        time = tick(),
        original = originalPet.Name,
        target = targetPetName,
        success = true,
        method = "instant_visual"
    })
    
    print("✅ МГНОВЕННАЯ ЗАМЕНА ЗАВЕРШЕНА: " .. targetPetName)
    return true
end

-- Функция проверки на питомца
local function isPetModel(obj)
    if not obj:IsA("Model") then return false end
    
    local humanoid = obj:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local hasHead = obj:FindFirstChild("Head")
    local hasTorso = obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
    
    return hasHead and hasTorso
end

-- ⚡ СИСТЕМА МГНОВЕННОГО МОНИТОРИНГА
local function setupInstantMonitoring()
    -- 1. Мониторинг workspace с мгновенной реакцией
    workspace.ChildAdded:Connect(function(child)
        if not replacementActive then return end
        
        if isPetModel(child) then
            -- МГНОВЕННАЯ обработка без задержек
            spawn(function()
                print("🐾 ОБНАРУЖЕН ПИТОМЕЦ: " .. child.Name)
                
                -- Ищем ближайший ESP для замены
                local targetPet = nil
                local minDistance = math.huge
                local childPos = child.PrimaryPart and child.PrimaryPart.Position or 
                                child:FindFirstChildWhichIsA("BasePart") and child:FindFirstChildWhichIsA("BasePart").Position
                
                if childPos then
                    for egg, data in pairs(displayedEggs) do
                        if data.currentPet then
                            local eggPos = egg.PrimaryPart and egg.PrimaryPart.Position or 
                                          egg:FindFirstChildWhichIsA("BasePart") and egg:FindFirstChildWhichIsA("BasePart").Position
                            
                            if eggPos then
                                local distance = (childPos - eggPos).Magnitude
                                if distance < minDistance and distance < 100 then
                                    minDistance = distance
                                    targetPet = data.currentPet
                                end
                            end
                        end
                    end
                    
                    -- Если найден ESP и питомец не соответствует - МГНОВЕННАЯ ЗАМЕНА
                    if targetPet and targetPet ~= child.Name then
                        print("🎯 НЕСООТВЕТСТВИЕ! ESP: " .. targetPet .. ", Выпал: " .. child.Name)
                        instantReplacePet(child, targetPet, childPos)
                    else
                        print("✅ Питомец соответствует ESP: " .. (targetPet or "нет ESP"))
                    end
                end
            end)
        end
    end)
    
    -- 2. Мониторинг NPCS папки
    local npcsFolder = workspace:FindFirstChild("NPCS")
    if npcsFolder then
        npcsFolder.ChildAdded:Connect(function(child)
            if not replacementActive then return end
            
            if isPetModel(child) then
                spawn(function()
                    print("👥 ПИТОМЕЦ В NPCS: " .. child.Name)
                    
                    -- Ищем любой ESP для замены
                    for egg, data in pairs(displayedEggs) do
                        if data.currentPet and data.currentPet ~= child.Name then
                            print("🔄 ЗАМЕНА В NPCS: " .. data.currentPet)
                            instantReplacePet(child, data.currentPet, nil)
                            break
                        end
                    end
                end)
            end
        end)
    end
    
    -- 3. Мониторинг каждый кадр для максимальной скорости
    runService.Heartbeat:Connect(function()
        if not replacementActive then return end
        
        -- Проверяем все новые питомцы в workspace
        for _, obj in pairs(workspace:GetChildren()) do
            if isPetModel(obj) and not obj:GetAttribute("ProcessedByReplacer") then
                obj:SetAttribute("ProcessedByReplacer", true)
                
                spawn(function()
                    -- Ищем соответствующий ESP
                    local objPos = obj.PrimaryPart and obj.PrimaryPart.Position or 
                                  obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position
                    
                    if objPos then
                        for egg, data in pairs(displayedEggs) do
                            if data.currentPet then
                                local eggPos = egg.PrimaryPart and egg.PrimaryPart.Position or 
                                              egg:FindFirstChildWhichIsA("BasePart") and egg:FindFirstChildWhichIsA("BasePart").Position
                                
                                if eggPos and (objPos - eggPos).Magnitude < 50 then
                                    if data.currentPet ~= obj.Name then
                                        print("⚡ HEARTBEAT ЗАМЕНА: " .. obj.Name .. " → " .. data.currentPet)
                                        instantReplacePet(obj, data.currentPet, objPos)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- Сканирование яиц
local function scanForEggs()
    local eggs = findEggs()
    for _, egg in pairs(eggs) do
        addESP(egg)
    end
    print("🔍 Найдено яиц: " .. #eggs)
end

-- Мониторинг новых яиц
workspace.ChildAdded:Connect(function(child)
    wait(0.1)
    if child:IsA("Model") and string.find(child.Name, "Egg") and eggChances[child.Name] then
        addESP(child)
    end
end)

-- 🎨 СОВРЕМЕННОЕ КРАСИВОЕ GUI
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Создание главного GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ModernInstantReplacerGUI"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Главная рамка с современным дизайном
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 340)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui

-- Закругленные углы для главной рамки
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Градиентный фон
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Тень для главной рамки
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 6, 1, 6)
shadow.Position = UDim2.new(0, -3, 0, -3)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = -1
shadow.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 15)
shadowCorner.Parent = shadow

-- Заголовок с эффектами
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 50)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleFrame

-- Градиент для заголовка
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 255))
}
titleGradient.Rotation = 90
titleGradient.Parent = titleFrame

-- Текст заголовка
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 40, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "EGG RANDOMIZER V2"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleFrame

-- Иконка в заголовке
local titleIcon = Instance.new("TextLabel")
titleIcon.Name = "TitleIcon"
titleIcon.Size = UDim2.new(0, 30, 0, 30)
titleIcon.Position = UDim2.new(0, 10, 0, 10)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "🥚"
titleIcon.TextColor3 = Color3.new(1, 1, 1)
titleIcon.TextSize = 20
titleIcon.Font = Enum.Font.Gotham
titleIcon.Parent = titleFrame

-- Кнопка минимизации
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -40, 0, 10)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 18
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = titleFrame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 15)
minimizeCorner.Parent = minimizeButton

-- Контейнер для кнопок
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -20, 1, -70)
buttonsFrame.Position = UDim2.new(0, 10, 0, 60)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

-- Функция создания современной кнопки
local function createModernButton(name, text, position, size, color1, color2, icon)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size or UDim2.new(1, 0, 0, 45)
    button.Position = position
    button.BackgroundColor3 = color1
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = buttonsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    }
    buttonGradient.Rotation = 45
    buttonGradient.Parent = button
    
    -- Иконка кнопки
    local buttonIcon = Instance.new("TextLabel")
    buttonIcon.Name = "Icon"
    buttonIcon.Size = UDim2.new(0, 25, 0, 25)
    buttonIcon.Position = UDim2.new(0, 10, 0, 10)
    buttonIcon.BackgroundTransparency = 1
    buttonIcon.Text = icon or "🔹"
    buttonIcon.TextColor3 = Color3.new(1, 1, 1)
    buttonIcon.TextSize = 16
    buttonIcon.Font = Enum.Font.Gotham
    buttonIcon.Parent = button
    
    -- Текст кнопки
    local buttonText = Instance.new("TextLabel")
    buttonText.Name = "Text"
    buttonText.Size = UDim2.new(1, -45, 1, 0)
    buttonText.Position = UDim2.new(0, 40, 0, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = text
    buttonText.TextColor3 = Color3.new(1, 1, 1)
    buttonText.TextSize = 14
    buttonText.Font = Enum.Font.GothamSemibold
    buttonText.TextXAlignment = Enum.TextXAlignment.Left
    buttonText.Parent = button
    
    -- Статус индикатор
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Name = "StatusIndicator"
    statusIndicator.Size = UDim2.new(0, 8, 0, 8)
    statusIndicator.Position = UDim2.new(1, -15, 0, 18)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    statusIndicator.BorderSizePixel = 0
    statusIndicator.Parent = button
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = statusIndicator
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {Size = UDim2.new(1, 5, 0, 50)})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {Size = size or UDim2.new(1, 0, 0, 45)})
        tween:Play()
    end)
    
    return button, buttonText, statusIndicator
end

-- Создание кнопок
local espButton, espText, espStatus = createModernButton(
    "ESPButton", "ESP SYSTEM", 
    UDim2.new(0, 0, 0, 0), 
    UDim2.new(1, 0, 0, 45),
    Color3.fromRGB(100, 200, 100), Color3.fromRGB(50, 150, 50), "👁️"
)

local randomizeButton, randomizeText, randomizeStatus = createModernButton(
    "RandomizeButton", "RANDOMIZE PETS", 
    UDim2.new(0, 0, 0, 55), 
    UDim2.new(1, 0, 0, 45),
    Color3.fromRGB(100, 100, 200), Color3.fromRGB(50, 50, 150), "🎲"
)

local replaceButton, replaceText, replaceStatus = createModernButton(
    "ReplaceButton", "INSTANT REPLACE", 
    UDim2.new(0, 0, 0, 110), 
    UDim2.new(1, 0, 0, 45),
    Color3.fromRGB(200, 100, 200), Color3.fromRGB(150, 50, 150), "⚡"
)

local logButton, logText, logStatus = createModernButton(
    "LogButton", "VIEW REPLACEMENTS", 
    UDim2.new(0, 0, 0, 165), 
    UDim2.new(1, 0, 0, 45),
    Color3.fromRGB(200, 150, 50), Color3.fromRGB(150, 100, 25), "📊"
)

-- Статистика внизу
local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.Size = UDim2.new(1, -20, 0, 30)
statsFrame.Position = UDim2.new(0, 10, 1, -60)
statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
statsFrame.BorderSizePixel = 0
statsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = statsFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, -10, 1, 0)
statsLabel.Position = UDim2.new(0, 5, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "📈 Replacements: 0 | 🥚 Eggs: 0 | ⚡ Active"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statsFrame

-- Подпись автора
local authorFrame = Instance.new("Frame")
authorFrame.Name = "AuthorFrame"
authorFrame.Size = UDim2.new(1, -20, 0, 20)
authorFrame.Position = UDim2.new(0, 10, 1, -30)
authorFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
authorFrame.BorderSizePixel = 0
authorFrame.Parent = mainFrame

local authorCorner = Instance.new("UICorner")
authorCorner.CornerRadius = UDim.new(0, 4)
authorCorner.Parent = authorFrame

local authorGradient = Instance.new("UIGradient")
authorGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
authorGradient.Rotation = 90
authorGradient.Parent = authorFrame

local authorLabel = Instance.new("TextLabel")
authorLabel.Name = "AuthorLabel"
authorLabel.Size = UDim2.new(1, -10, 1, 0)
authorLabel.Position = UDim2.new(0, 5, 0, 0)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "made by TW2LOCK"
authorLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
authorLabel.TextSize = 10
authorLabel.Font = Enum.Font.GothamSemibold
authorLabel.TextXAlignment = Enum.TextXAlignment.Center
authorLabel.Parent = authorFrame

-- Улучшенная система перетаскивания для мобильных устройств
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

titleFrame.InputBegan:Connect(function(input)
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

titleFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

-- Функция обновления статистики
local function updateStats()
    local eggCount = 0
    for _ in pairs(displayedEggs) do
        eggCount = eggCount + 1
    end
    
    local status = replacementActive and "⚡ Active" or "⏸️ Paused"
    statsLabel.Text = string.format("📈 Replacements: %d | 🥚 Eggs: %d | %s", #replacementLog, eggCount, status)
end

-- Функция анимации кнопки при нажатии
local function animateButtonPress(button)
    local originalSize = button.Size
    local tween1 = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(originalSize.X.Scale - 0.02, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset - 2)})
    local tween2 = TweenService:Create(button, TweenInfo.new(0.1), {Size = originalSize})
    
    tween1:Play()
    tween1.Completed:Connect(function()
        tween2:Play()
    end)
end

-- Обработчики событий кнопок
espButton.MouseButton1Click:Connect(function()
    animateButtonPress(espButton)
    toggleESP()
    if espEnabled then
        espText.Text = "ESP SYSTEM (ON)"
        espStatus.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    else
        espText.Text = "ESP SYSTEM (OFF)"
        espStatus.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
    updateStats()
end)

randomizeButton.MouseButton1Click:Connect(function()
    animateButtonPress(randomizeButton)
    randomizePets()
    updateStats()
end)

replaceButton.MouseButton1Click:Connect(function()
    animateButtonPress(replaceButton)
    replacementActive = not replacementActive
    if replacementActive then
        replaceText.Text = "INSTANT REPLACE (ON)"
        replaceStatus.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        print("⚡ Замена включена")
    else
        replaceText.Text = "INSTANT REPLACE (OFF)"
        replaceStatus.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        print("⏸️ Замена выключена")
    end
    updateStats()
end)

logButton.MouseButton1Click:Connect(function()
    animateButtonPress(logButton)
    print("\n⚡ ЛОГ МГНОВЕННЫХ ЗАМЕН:")
    for i, entry in ipairs(replacementLog) do
        print("✅ " .. entry.original .. " → " .. entry.target .. " (" .. entry.method .. ")")
    end
    print("📊 Всего замен: " .. #replacementLog)
    updateStats()
end)

-- Функция минимизации/разворачивания
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 50)})
        tween:Play()
        minimizeButton.Text = "+"
        buttonsFrame.Visible = false
        statsFrame.Visible = false
        authorFrame.Visible = false
    else
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 340)})
        tween:Play()
        minimizeButton.Text = "−"
        buttonsFrame.Visible = true
        statsFrame.Visible = true
        authorFrame.Visible = true
    end
end)

-- Инициализация статистики
updateStats()

-- Периодическое обновление статистики
spawn(function()
    while wait(2) do
        updateStats()
    end
end)

-- Запуск системы
cachePetModels()
scanForEggs()
setupInstantMonitoring()

-- Глобальные переменные
_G.InstantReplacer = {
    espEnabled = espEnabled,
    replacementActive = replacementActive,
    displayedEggs = displayedEggs,
    replacementLog = replacementLog,
    petModels = petModels,
    instantReplacePet = instantReplacePet
}

print("⚡ МГНОВЕННЫЙ ЗАМЕНИТЕЛЬ ЗАГРУЖЕН!")
print("🔥 Особенности:")
print("   - Кэширование моделей для скорости")
print("   - Мгновенная замена без задержек")
print("   - Тройной мониторинг (workspace, NPCS, heartbeat)")
print("   - Полное сохранение атрибутов")
print("⚡ Теперь замена должна быть МГНОВЕННОЙ!")
