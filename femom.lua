-- ULTIMATE EGG CLONE DIAGNOSTIC SCRIPT
-- Полный анализ яйца для создания визуального симулятора

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

print("🥚 === ULTIMATE EGG DIAGNOSTIC STARTED ===")
print("🎯 Цель: Полный анализ яйца для создания визуального симулятора")

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 50,
    ANALYSIS_TIME = 30, -- 30 секунд анализа
    EGG_NAMES = {
        "Common Egg", "Rare Egg", "Legendary Egg", "Mythical Egg",
        "Bug Egg", "Bee Egg", "Anti Bee Egg", "Night Egg",
        "Oasis Egg", "Paradise Egg", "Dinosaur Egg", "Primal Egg",
        "Common Summer Egg", "Rare Summer Egg", "Zen Egg"
    }
}

-- Структура для хранения данных яйца
local EggData = {
    model = nil,
    position = nil,
    structure = {},
    animations = {},
    effects = {},
    scripts = {},
    sounds = {},
    clickDetector = nil,
    timer = nil,
    petChances = {},
    materials = {},
    textures = {}
}

-- Функция поиска яйца рядом с игроком
local function findNearbyEgg()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local objName = obj.Name
            
            -- Проверяем является ли это яйцом
            for _, eggName in pairs(CONFIG.EGG_NAMES) do
                if objName:find(eggName) or objName:lower():find("egg") then
                    local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
                    if success then
                        local distance = (modelCFrame.Position - playerPos).Magnitude
                        if distance <= CONFIG.SEARCH_RADIUS then
                            print("🥚 НАЙДЕНО ЯЙЦО:", objName, "на расстоянии", math.floor(distance))
                            return obj
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Функция анализа структуры модели
local function analyzeModelStructure(model)
    print("\n📐 === АНАЛИЗ СТРУКТУРЫ МОДЕЛИ ===")
    print("📛 Имя модели:", model.Name)
    print("📍 Позиция:", model:GetModelCFrame().Position)
    print("📏 Размер:", model:GetModelSize())
    
    local structure = {
        name = model.Name,
        className = model.ClassName,
        position = model:GetModelCFrame().Position,
        size = model:GetModelSize(),
        children = {}
    }
    
    -- Анализируем всех детей
    for _, child in pairs(model:GetChildren()) do
        local childData = {
            name = child.Name,
            className = child.ClassName,
            properties = {}
        }
        
        -- Анализируем свойства BasePart
        if child:IsA("BasePart") then
            childData.properties = {
                size = child.Size,
                material = child.Material.Name,
                color = child.Color,
                transparency = child.Transparency,
                canCollide = child.CanCollide,
                anchored = child.Anchored,
                cframe = child.CFrame
            }
            
            -- Проверяем текстуры
            for _, desc in pairs(child:GetChildren()) do
                if desc:IsA("Decal") or desc:IsA("Texture") then
                    childData.properties.texture = desc.Texture
                    print("🎨 Найдена текстура:", desc.Texture)
                end
            end
        end
        
        table.insert(structure.children, childData)
        print("  📦 Ребенок:", child.Name, "(" .. child.ClassName .. ")")
    end
    
    return structure
end

-- Функция анализа скриптов
local function analyzeScripts(model)
    print("\n📜 === АНАЛИЗ СКРИПТОВ ===")
    local scripts = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            local scriptData = {
                name = obj.Name,
                className = obj.ClassName,
                source = obj.Source or "Недоступен",
                parent = obj.Parent.Name
            }
            
            table.insert(scripts, scriptData)
            print("📜 СКРИПТ:", obj.Name, "(" .. obj.ClassName .. ") в", obj.Parent.Name)
            
            -- Пытаемся получить исходный код
            local success, source = pcall(function() return obj.Source end)
            if success and source and #source > 0 then
                print("  💻 Код доступен:", #source, "символов")
                -- Ищем ключевые слова
                if source:find("timer") or source:find("Timer") then
                    print("  ⏰ НАЙДЕН ТАЙМЕР в скрипте!")
                end
                if source:find("random") or source:find("Random") then
                    print("  🎲 НАЙДЕН РАНДОМ в скрипте!")
                end
                if source:find("pet") or source:find("Pet") then
                    print("  🐾 НАЙДЕНЫ ПИТОМЦЫ в скрипте!")
                end
            else
                print("  ❌ Код недоступен (защищен)")
            end
        end
    end
    
    return scripts
end

-- Функция анализа ClickDetector
local function analyzeClickDetector(model)
    print("\n🖱️ === АНАЛИЗ CLICK DETECTOR ===")
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("ClickDetector") then
            print("🖱️ НАЙДЕН ClickDetector в:", obj.Parent.Name)
            print("  MaxActivationDistance:", obj.MaxActivationDistance)
            print("  CursorIcon:", obj.CursorIcon)
            
            return {
                maxDistance = obj.MaxActivationDistance,
                cursorIcon = obj.CursorIcon,
                parent = obj.Parent.Name
            }
        end
    end
    
    print("❌ ClickDetector не найден")
    return nil
end

-- Функция анализа звуков
local function analyzeSounds(model)
    print("\n🎵 === АНАЛИЗ ЗВУКОВ ===")
    local sounds = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Sound") then
            local soundData = {
                name = obj.Name,
                soundId = obj.SoundId,
                volume = obj.Volume,
                pitch = obj.Pitch,
                looped = obj.Looped,
                parent = obj.Parent.Name
            }
            
            table.insert(sounds, soundData)
            print("🎵 ЗВУК:", obj.Name, "ID:", obj.SoundId, "в", obj.Parent.Name)
        end
    end
    
    return sounds
end

-- Функция анализа эффектов
local function analyzeEffects(model)
    print("\n✨ === АНАЛИЗ ЭФФЕКТОВ ===")
    local effects = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or 
           obj:IsA("Sparkles") or obj:IsA("PointLight") or obj:IsA("SpotLight") then
            
            local effectData = {
                name = obj.Name,
                className = obj.ClassName,
                parent = obj.Parent.Name,
                properties = {}
            }
            
            -- Анализируем свойства эффекта
            if obj:IsA("ParticleEmitter") then
                effectData.properties = {
                    texture = obj.Texture,
                    rate = obj.Rate,
                    lifetime = obj.Lifetime,
                    speed = obj.Speed,
                    color = obj.Color
                }
            elseif obj:IsA("PointLight") then
                effectData.properties = {
                    brightness = obj.Brightness,
                    color = obj.Color,
                    range = obj.Range
                }
            end
            
            table.insert(effects, effectData)
            print("✨ ЭФФЕКТ:", obj.Name, "(" .. obj.ClassName .. ") в", obj.Parent.Name)
        end
    end
    
    return effects
end

-- Функция анализа GUI элементов
local function analyzeGUI(model)
    print("\n🖼️ === АНАЛИЗ GUI ЭЛЕМЕНТОВ ===")
    local guiElements = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            local guiData = {
                name = obj.Name,
                className = obj.ClassName,
                parent = obj.Parent.Name,
                children = {}
            }
            
            -- Анализируем содержимое GUI
            for _, child in pairs(obj:GetChildren()) do
                table.insert(guiData.children, {
                    name = child.Name,
                    className = child.ClassName,
                    text = child:IsA("TextLabel") and child.Text or nil
                })
                
                if child:IsA("TextLabel") and child.Text then
                    print("📝 GUI ТЕКСТ:", child.Text, "в", child.Name)
                    
                    -- Ищем таймер в тексте
                    if child.Text:find(":") or child.Text:find("timer") or child.Text:find("Timer") then
                        print("⏰ ВОЗМОЖНЫЙ ТАЙМЕР найден в GUI!")
                    end
                end
            end
            
            table.insert(guiElements, guiData)
            print("🖼️ GUI:", obj.Name, "(" .. obj.ClassName .. ") в", obj.Parent.Name)
        end
    end
    
    return guiElements
end

-- Функция поиска связанных объектов
local function findRelatedObjects(eggModel)
    print("\n🔗 === ПОИСК СВЯЗАННЫХ ОБЪЕКТОВ ===")
    local related = {}
    
    -- Ищем EggExplode эффекты
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:find("EggExplode") or obj.Name:find("Explosion") then
            print("💥 НАЙДЕН ЭФФЕКТ ВЗРЫВА:", obj.Name, "в", obj.Parent and obj.Parent.Name or "nil")
            table.insert(related, {
                name = obj.Name,
                type = "explosion",
                className = obj.ClassName,
                parent = obj.Parent and obj.Parent.Name or "nil"
            })
        end
    end
    
    -- Ищем связанные скрипты в ReplicatedStorage
    if ReplicatedStorage then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if obj.Name:lower():find("egg") or obj.Name:lower():find("hatch") then
                    print("📡 НАЙДЕН REMOTE:", obj.Name, "(" .. obj.ClassName .. ")")
                    table.insert(related, {
                        name = obj.Name,
                        type = "remote",
                        className = obj.ClassName
                    })
                end
            end
        end
    end
    
    return related
end

-- Функция мониторинга открытия яйца
local function monitorEggOpening(eggModel)
    print("\n👁️ === МОНИТОРИНГ ОТКРЫТИЯ ЯЙЦА ===")
    print("🎯 Нажмите E рядом с яйцом для анализа процесса открытия!")
    
    local openingData = {
        timeline = {},
        startTime = nil,
        endTime = nil,
        petSpawned = nil,
        effectsUsed = {}
    }
    
    -- Отслеживаем нажатие клавиши E
    local keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.E then
            local playerChar = player.Character
            if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                local playerPos = playerChar.HumanoidRootPart.Position
                local eggPos = eggModel:GetModelCFrame().Position
                local distance = (eggPos - playerPos).Magnitude
                
                if distance <= 10 then -- В пределах 10 единиц от яйца
                    if not openingData.startTime then
                        openingData.startTime = tick()
                        print("🚀 НАЖАТА КЛАВИША E - НАЧАЛО ОТКРЫТИЯ ЯЙЦА!")
                        table.insert(openingData.timeline, {
                            time = 0,
                            event = "e_key_pressed",
                            object = "player_input"
                        })
                    end
                end
            end
        end
    end)
    
    -- Отслеживаем изменения в модели
    local connection = RunService.Heartbeat:Connect(function()
        if not eggModel or not eggModel.Parent then
            print("🥚 Яйцо исчезло!")
            if openingData.startTime then
                openingData.endTime = tick()
                local duration = openingData.endTime - openingData.startTime
                print("⏱️ ВРЕМЯ ОТКРЫТИЯ:", string.format("%.2f секунд", duration))
            end
            connection:Disconnect()
            keyConnection:Disconnect()
            return
        end
        
        -- Ищем новые эффекты
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("EggExplode") and not openingData.effectsUsed[obj.Name] then
                if not openingData.startTime then
                    openingData.startTime = tick()
                    print("🚀 НАЧАЛО ОТКРЫТИЯ ЯЙЦА!")
                end
                
                openingData.effectsUsed[obj.Name] = true
                table.insert(openingData.timeline, {
                    time = tick() - openingData.startTime,
                    event = "effect_spawned",
                    object = obj.Name
                })
                print("💥 ЭФФЕКТ:", obj.Name, "время:", string.format("%.2f", tick() - openingData.startTime))
            end
        end
        
        -- Ищем появившихся питомцев
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= player.Character then
                local objName = obj.Name:lower()
                local eggPets = {
                    "dog", "bunny", "golden lab", "cat", "rabbit", "crab",
                    "wasp", "snail", "bee", "cow", "monkey", "hedgehog"
                }
                
                for _, petName in pairs(eggPets) do
                    if objName == petName and not openingData.petSpawned then
                        openingData.petSpawned = obj.Name
                        table.insert(openingData.timeline, {
                            time = tick() - (openingData.startTime or tick()),
                            event = "pet_spawned",
                            object = obj.Name
                        })
                        print("🐾 ПИТОМЕЦ ПОЯВИЛСЯ:", obj.Name, "время:", string.format("%.2f", tick() - (openingData.startTime or tick())))
                        break
                    end
                end
            end
        end
    end)
    
    return openingData, connection
end

-- Главная функция диагностики
local function runEggDiagnostic()
    print("🔍 Ищу яйцо рядом с игроком...")
    
    local eggModel = findNearbyEgg()
    if not eggModel then
        print("❌ Яйцо не найдено в радиусе", CONFIG.SEARCH_RADIUS, "единиц")
        print("💡 Подойдите ближе к яйцу и запустите скрипт снова")
        return
    end
    
    print("✅ Найдено яйцо для анализа:", eggModel.Name)
    EggData.model = eggModel
    
    -- Запускаем все виды анализа
    EggData.structure = analyzeModelStructure(eggModel)
    EggData.scripts = analyzeScripts(eggModel)
    EggData.clickDetector = analyzeClickDetector(eggModel)
    EggData.sounds = analyzeSounds(eggModel)
    EggData.effects = analyzeEffects(eggModel)
    EggData.gui = analyzeGUI(eggModel)
    EggData.related = findRelatedObjects(eggModel)
    
    -- Запускаем мониторинг открытия
    local openingData, connection = monitorEggOpening(eggModel)
    
    print("\n📊 === ИТОГОВЫЙ ОТЧЕТ ===")
    print("🥚 Модель:", EggData.model.Name)
    print("📜 Скриптов:", #EggData.scripts)
    print("🎵 Звуков:", #EggData.sounds)
    print("✨ Эффектов:", #EggData.effects)
    print("🖼️ GUI элементов:", #EggData.gui)
    print("🔗 Связанных объектов:", #EggData.related)
    print("🖱️ ClickDetector:", EggData.clickDetector and "Найден" or "Не найден")
    
    print("\n🎯 === ГОТОВНОСТЬ К КЛОНИРОВАНИЮ ===")
    print("📐 Структура модели: ✅ Проанализирована")
    print("🎨 Визуальные данные: ✅ Извлечены")
    print("🔧 Механика клика: " .. (EggData.clickDetector and "✅ Найдена" or "❌ Не найдена"))
    print("📜 Скрипты: " .. (#EggData.scripts > 0 and "✅ Найдены" or "❌ Не найдены"))
    
    print("\n💡 Нажмите E рядом с яйцом для анализа процесса открытия!")
    print("⏰ Мониторинг активен в течение", CONFIG.ANALYSIS_TIME, "секунд")
    print("🎯 Скрипт отслеживает: нажатие E, эффекты, звуки, появление питомца")
    
    -- Автоматическое завершение через время
    spawn(function()
        wait(CONFIG.ANALYSIS_TIME)
        if connection then
            connection:Disconnect()
        end
        print("\n🏁 === ДИАГНОСТИКА ЗАВЕРШЕНА ===")
        print("📊 Все данные собраны для создания визуального симулятора!")
    end)
    
    return EggData
end

-- Создание GUI для управления
local function createDiagnosticGUI()
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EggDiagnosticGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Главный фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
    titleLabel.Text = "🥚 EGG CLONE DIAGNOSTIC"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Кнопка запуска диагностики
    local startButton = Instance.new("TextButton")
    startButton.Name = "StartButton"
    startButton.Size = UDim2.new(0.9, 0, 0, 40)
    startButton.Position = UDim2.new(0.05, 0, 0, 40)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startButton.Text = "🔍 ЗАПУСТИТЬ ДИАГНОСТИКУ"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextScaled = true
    startButton.Font = Enum.Font.SourceSansBold
    startButton.Parent = mainFrame
    
    -- Статус лейбл
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0.9, 0, 0, 60)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 90)
    statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    statusLabel.Text = "📍 Подойдите к яйцу и нажмите кнопку"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.9, 0, 0, 30)
    closeButton.Position = UDim2.new(0.05, 0, 0, 160)
    closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    closeButton.Text = "❌ ЗАКРЫТЬ"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    -- Обработчик кнопки запуска
    startButton.MouseButton1Click:Connect(function()
        statusLabel.Text = "🔍 Ищу яйцо рядом с игроком..."
        statusLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
        
        spawn(function()
            local eggModel = findNearbyEgg()
            if not eggModel then
                statusLabel.Text = "❌ Яйцо не найдено! Подойдите ближе"
                statusLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                return
            end
            
            statusLabel.Text = "✅ Яйцо найдено: " .. eggModel.Name
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            
            -- Запускаем полную диагностику
            runEggDiagnosticWithGUI(eggModel, statusLabel)
        end)
    end)
    
    -- Обработчик кнопки закрытия
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui, statusLabel
end

-- Модифицированная функция диагностики с GUI обновлениями
local function runEggDiagnosticWithGUI(eggModel, statusLabel)
    print("✅ Найдено яйцо для анализа:", eggModel.Name)
    EggData.model = eggModel
    
    statusLabel.Text = "📐 Анализирую структуру модели..."
    wait(0.5)
    
    -- Запускаем все виды анализа
    EggData.structure = analyzeModelStructure(eggModel)
    statusLabel.Text = "📜 Анализирую скрипты..."
    wait(0.5)
    
    EggData.scripts = analyzeScripts(eggModel)
    statusLabel.Text = "🖱️ Ищу ClickDetector..."
    wait(0.5)
    
    EggData.clickDetector = analyzeClickDetector(eggModel)
    statusLabel.Text = "🎵 Анализирую звуки..."
    wait(0.5)
    
    EggData.sounds = analyzeSounds(eggModel)
    statusLabel.Text = "✨ Анализирую эффекты..."
    wait(0.5)
    
    EggData.effects = analyzeEffects(eggModel)
    statusLabel.Text = "🖼️ Анализирую GUI элементы..."
    wait(0.5)
    
    EggData.gui = analyzeGUI(eggModel)
    statusLabel.Text = "🔗 Ищу связанные объекты..."
    wait(0.5)
    
    EggData.related = findRelatedObjects(eggModel)
    
    statusLabel.Text = "👁️ ГОТОВ! Нажмите E на яйце для мониторинга"
    statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
    
    -- Запускаем мониторинг открытия
    local openingData, connection = monitorEggOpening(eggModel)
    
    print("\n📊 === ИТОГОВЫЙ ОТЧЕТ ===")
    print("🥚 Модель:", EggData.model.Name)
    print("📜 Скриптов:", #EggData.scripts)
    print("🎵 Звуков:", #EggData.sounds)
    print("✨ Эффектов:", #EggData.effects)
    print("🖼️ GUI элементов:", #EggData.gui)
    print("🔗 Связанных объектов:", #EggData.related)
    print("🖱️ ClickDetector:", EggData.clickDetector and "Найден" or "Не найден")
    
    print("\n🎯 === ГОТОВНОСТЬ К КЛОНИРОВАНИЮ ===")
    print("📐 Структура модели: ✅ Проанализирована")
    print("🎨 Визуальные данные: ✅ Извлечены")
    print("🔧 Механика клика: " .. (EggData.clickDetector and "✅ Найдена" or "❌ Не найдена"))
    print("📜 Скрипты: " .. (#EggData.scripts > 0 and "✅ Найдены" or "❌ Не найдены"))
    
    print("\n💡 Нажмите E рядом с яйцом для анализа процесса открытия!")
    print("⏰ Мониторинг активен в течение", CONFIG.ANALYSIS_TIME, "секунд")
    print("🎯 Скрипт отслеживает: нажатие E, эффекты, звуки, появление питомца")
    
    -- Автоматическое завершение через время
    spawn(function()
        wait(CONFIG.ANALYSIS_TIME)
        if connection then
            connection:Disconnect()
        end
        statusLabel.Text = "🏁 Диагностика завершена!"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        print("\n🏁 === ДИАГНОСТИКА ЗАВЕРШЕНА ===")
        print("📊 Все данные собраны для создания визуального симулятора!")
    end)
    
    return EggData
end

-- Создание GUI и запуск
createDiagnosticGUI()
print("🎮 GUI создан! Используйте кнопки для управления диагностикой.")
