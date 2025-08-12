-- CORRECTED EGG CLONE DIAGNOSTIC SCRIPT
-- Правильный анализ яйца с мониторингом Workspace.Visuals

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

print("🥚 === CORRECTED EGG DIAGNOSTIC STARTED ===")
print("🎯 Цель: Правильный анализ яйца с мониторингом Workspace.Visuals")

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 50,
    ANALYSIS_TIME = 60, -- 60 секунд анализа
    EGG_NAMES = {
        "Common Egg", "Rare Egg", "Legendary Egg", "Mythical Egg",
        "Bug Egg", "Bee Egg", "Anti Bee Egg", "Night Egg",
        "Oasis Egg", "Paradise Egg", "Dinosaur Egg", "Primal Egg",
        "Common Summer Egg", "Rare Summer Egg", "Zen Egg"
    }
}

-- Полный список питомцев из яиц (ОБНОВЛЕННЫЙ из PetScaler_v222222234.lua)
local eggPets = {
    -- Anti Bee Egg
    "wasp", "tarantula hawk", "moth", "butterfly", "disco bee (divine)",
    -- Bee Egg  
    "bee", "honey bee", "bear bee", "petal bee", "queen bee",
    -- Bug Egg
    "snail", "giant ant", "caterpillar", "praying mantis", "dragonfly (divine)",
    -- Common Egg
    "dog", "bunny", "golden lab",
    -- Common Summer Egg
    "starfish", "seagull", "crab",
    -- Dinosaur Egg
    "raptor", "triceratops", "stegosaurus", "pterodactyl", "brontosaurus", "t-rex (divine)",
    -- Legendary Egg
    "cow", "silver monkey", "sea otter", "turtle", "polar bear",
    -- Mythical Egg
    "grey mouse", "brown mouse", "squirrel", "red giant ant", "red fox",
    -- Night Egg
    "hedgehog", "mole", "frog", "echo frog", "night owl", "raccoon",
    -- Oasis Egg
    "meerkat", "sand snake", "axolotl", "hyacinth macaw", "fennec fox",
    -- Paradise Egg
    "ostrich", "peacock", "capybara", "scarlet macaw", "mimic octopus",
    -- Primal Egg
    "parasaurolophus", "iguanodon", "pachycephalosaurus", "dilophosaurus", "ankylosaurus", "spinosaurus (divine)",
    -- Rare Egg
    "orange tabby", "spotted deer", "pig", "rooster", "monkey",
    -- Rare Summer Egg
    "flamingo", "toucan", "sea turtle", "orangutan", "seal",
    -- Uncommon Egg
    "black bunny", "chicken", "cat", "deer",
    -- Zen Egg
    "shiba inu", "nihonzaru", "tanuki", "tanchozuru", "kappa", "kitsune"
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
    textures = {},
    petLifecycle = {} -- НОВОЕ: данные о жизненном цикле питомца
}

-- Функция проверки является ли модель питомцем из яйца (ТОЧНОЕ СООТВЕТСТВИЕ как в PetScaler_v222222234.lua)
local function isPetFromEgg(model)
    if not model:IsA("Model") then return false end
    local modelName = model.Name:lower()
    
    for _, petName in pairs(eggPets) do
        if modelName == petName then
            return true
        end
    end
    return false
end

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
                source = "Недоступен",
                parent = obj.Parent.Name
            }
            
            table.insert(scripts, scriptData)
            print("📜 СКРИПТ:", obj.Name, "(" .. obj.ClassName .. ") в", obj.Parent.Name)
            
            -- Пытаемся получить исходный код
            local success, source = pcall(function() return obj.Source end)
            if success and source and #source > 0 then
                scriptData.source = source
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

-- Функция мониторинга Workspace.Visuals (УЛУЧШЕННАЯ ЛОГИКА как в PetScaler_v222222234.lua)
local function monitorWorkspaceVisuals()
    print("\n👁️ === МОНИТОРИНГ WORKSPACE.VISUALS ===")
    print("🎯 Отслеживаем появление питомцев в Workspace.Visuals!")
    print("⚡ Используем ChildAdded события вместо постоянного мониторинга!")
    
    local visualsFolder = Workspace:FindFirstChild("Visuals")
    if not visualsFolder then
        print("❌ Workspace.Visuals не найден!")
        return nil, nil
    end
    
    print("✅ Найден Workspace.Visuals, настраиваю мониторинг...")
    
    local petLifecycleData = {
        pets = {},
        timeline = {},
        totalPets = 0
    }
    
    local processedModels = {}
    
    -- Мониторинг появления новых питомцев (ChildAdded) - КАК В РАБОЧЕМ СКРИПТЕ
    local childAddedConnection = visualsFolder.ChildAdded:Connect(function(child)
        if child:IsA("Model") and isPetFromEgg(child) then
            local spawnTime = tick()
            local petId = tostring(child)
            
            print("⚡ СОБЫТИЕ: Новый питомец появился в Visuals:", child.Name, "время:", os.date("%H:%M:%S"))
            
            -- Записываем данные о питомце
            petLifecycleData.pets[petId] = {
                name = child.Name,
                spawnTime = spawnTime,
                despawnTime = nil,
                lifetime = nil,
                model = child,
                structure = {},
                effects = {},
                animations = {}
            }
            
            petLifecycleData.totalPets = petLifecycleData.totalPets + 1
            processedModels[petId] = true
            
            table.insert(petLifecycleData.timeline, {
                time = spawnTime,
                event = "pet_spawned",
                petName = child.Name,
                petId = petId
            })
            
            -- ДИАГНОСТИЧЕСКИЙ АНАЛИЗ ПИТОМЦА (не скрываем, только анализируем)
            spawn(function()
                wait(0.05) -- Минимальная задержка для загрузки модели
                
                -- Анализируем структуру питомца
                print("🔍 АНАЛИЗ СТРУКТУРЫ ПИТОМЦА:", child.Name)
                local structure = analyzeModelStructure(child)
                petLifecycleData.pets[petId].structure = structure
                
                -- Анализируем эффекты
                for _, descendant in pairs(child:GetDescendants()) do
                    if descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Smoke") then
                        table.insert(petLifecycleData.pets[petId].effects, {
                            name = descendant.Name,
                            className = descendant.ClassName,
                            parent = descendant.Parent.Name
                        })
                        print("✨ НАЙДЕН ЭФФЕКТ:", descendant.Name, "(", descendant.ClassName, ")")
                    end
                end
            end)
            
            -- Мониторим исчезновение этого конкретного питомца
            spawn(function()
                while child and child.Parent do
                    wait(0.1) -- Проверяем каждые 0.1 секунды
                end
                
                -- Питомец исчез
                local despawnTime = tick()
                local lifetime = despawnTime - spawnTime
                
                print("💀 ПИТОМЕЦ ИСЧЕЗ:", petLifecycleData.pets[petId].name, 
                      "время жизни:", string.format("%.2f секунд", lifetime))
                
                -- Обновляем данные
                petLifecycleData.pets[petId].despawnTime = despawnTime
                petLifecycleData.pets[petId].lifetime = lifetime
                
                table.insert(petLifecycleData.timeline, {
                    time = despawnTime,
                    event = "pet_despawned",
                    petName = petLifecycleData.pets[petId].name,
                    petId = petId,
                    lifetime = lifetime
                })
            end)
        end
    end)
    
    -- НАЧАЛЬНАЯ ПРОВЕРКА уже существующих питомцев в Visuals (КАК В РАБОЧЕМ СКРИПТЕ)
    print("🔍 НАЧАЛЬНАЯ ПРОВЕРКА: Ищем уже существующих питомцев в Visuals...")
    for _, child in pairs(visualsFolder:GetChildren()) do
        if child:IsA("Model") and isPetFromEgg(child) then
            local petId = tostring(child)
            if not processedModels[petId] then
                print("🔍 НАЧАЛЬНАЯ ПРОВЕРКА: Найден питомец в Visuals:", child.Name)
                
                local spawnTime = tick()
                petLifecycleData.pets[petId] = {
                    name = child.Name,
                    spawnTime = spawnTime,
                    despawnTime = nil,
                    lifetime = nil,
                    model = child,
                    structure = {},
                    effects = {},
                    animations = {},
                    foundOnStartup = true
                }
                
                petLifecycleData.totalPets = petLifecycleData.totalPets + 1
                processedModels[petId] = true
                
                table.insert(petLifecycleData.timeline, {
                    time = spawnTime,
                    event = "pet_found_on_startup",
                    petName = child.Name,
                    petId = petId
                })
            end
        end
    end
    
    -- Мониторинг нажатия E для открытия яйца
    local keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.E then
            print("🔑 НАЖАТА КЛАВИША E - ВОЗМОЖНОЕ ОТКРЫТИЕ ЯЙЦА!")
            table.insert(petLifecycleData.timeline, {
                time = tick(),
                event = "e_key_pressed",
                petName = "N/A",
                petId = "player_input"
            })
        end
    end)
    
    print("🔄 Событийная система активна!")
    print("💡 Все новые питомцы в Visuals будут автоматически отслежены")
    print("🎯 Откройте яйцо для полного анализа!")
    
    return petLifecycleData, childAddedConnection, keyConnection
end

-- Функция анализа эффектов взрыва
local function monitorExplosionEffects()
    print("\n💥 === МОНИТОРИНГ ЭФФЕКТОВ ВЗРЫВА ===")
    
    local explosionData = {
        effects = {},
        timeline = {}
    }
    
    -- Мониторим появление EggExplode эффектов
    local effectConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj.Name:find("EggExplode") or obj.Name:find("Explosion") then
            local effectTime = tick()
            print("💥 ЭФФЕКТ ВЗРЫВА:", obj.Name, "время:", os.date("%H:%M:%S"))
            
            table.insert(explosionData.effects, {
                name = obj.Name,
                className = obj.ClassName,
                spawnTime = effectTime,
                parent = obj.Parent and obj.Parent.Name or "nil"
            })
            
            table.insert(explosionData.timeline, {
                time = effectTime,
                event = "explosion_effect",
                effectName = obj.Name
            })
        end
    end)
    
    return explosionData, effectConnection
end

-- Основная функция диагностики (УЛУЧШЕННАЯ)
local function runCorrectedDiagnostic(eggModel, statusLabel)
    print("\n🥚 === ЗАПУСК УЛУЧШЕННОЙ ДИАГНОСТИКИ ===")
    print("🎯 Яйцо найдено:", eggModel.Name)
    print("📍 Позиция:", eggModel:GetModelCFrame().Position)
    print("⚡ Используем логику из PetScaler_v222222234.lua для точного отслеживания!")
    
    -- Обновляем статус
    statusLabel.Text = "🔍 Анализирую яйцо: " .. eggModel.Name
    statusLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    
    -- Сохраняем данные о яйце
    EggData.model = eggModel
    EggData.position = eggModel:GetModelCFrame().Position
    
    -- Анализируем структуру яйца
    print("\n📐 Анализирую структуру яйца...")
    EggData.structure = analyzeModelStructure(eggModel)
    
    -- Анализируем скрипты яйца
    print("\n📜 Анализирую скрипты яйца...")
    EggData.scripts = analyzeScripts(eggModel)
    
    -- Анализируем звуки яйца
    print("\n🔊 Анализирую звуки яйца...")
    local sounds = {}
    for _, obj in pairs(eggModel:GetDescendants()) do
        if obj:IsA("Sound") then
            table.insert(sounds, {
                name = obj.Name,
                soundId = obj.SoundId,
                volume = obj.Volume,
                pitch = obj.Pitch,
                parent = obj.Parent.Name
            })
            print("🔊 НАЙДЕН ЗВУК:", obj.Name, "ID:", obj.SoundId)
        end
    end
    EggData.sounds = sounds
    
    -- Анализируем материалы и текстуры яйца
    print("\n🎨 Анализирую материалы и текстуры...")
    local materials = {}
    local textures = {}
    for _, obj in pairs(eggModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(materials, {
                name = obj.Name,
                material = obj.Material.Name,
                color = obj.Color,
                transparency = obj.Transparency,
                reflectance = obj.Reflectance
            })
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            table.insert(textures, {
                name = obj.Name,
                className = obj.ClassName,
                texture = obj.Texture,
                transparency = obj.Transparency,
                parent = obj.Parent.Name
            })
            print("🎨 НАЙДЕНА ТЕКСТУРА:", obj.Name, "ID:", obj.Texture)
        end
    end
    EggData.materials = materials
    EggData.textures = textures
    
    -- Запускаем мониторинг Workspace.Visuals (ГЛАВНОЕ УЛУЧШЕНИЕ!)
    print("\n👁️ Запускаю улучшенный мониторинг Workspace.Visuals...")
    local petLifecycleData, childConnection, keyConnection = monitorWorkspaceVisuals()
    
    if petLifecycleData then
        EggData.petLifecycle = petLifecycleData
        statusLabel.Text = "✅ Мониторинг активен! Откройте яйцо (E)"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        statusLabel.Text = "❌ Ошибка мониторинга Visuals"
        statusLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        return
    end
    
    -- Запускаем мониторинг эффектов взрыва
    print("\n💥 Запускаю мониторинг эффектов взрыва...")
    local explosionData, explosionConnection = monitorExplosionEffects()
    EggData.explosionEffects = explosionData
    
    -- Ждем анализа
    print("\n⏰ Анализ активен на", CONFIG.ANALYSIS_TIME, "секунд")
    print("🔑 Нажмите E рядом с яйцом для открытия!")
    print("🎯 Все питомцы в Workspace.Visuals будут отслежены автоматически!")
    
    spawn(function()
        wait(CONFIG.ANALYSIS_TIME)
        
        -- Отключаем соединения безопасно
        if childConnection then
            pcall(function() childConnection:Disconnect() end)
        end
        if keyConnection then
            pcall(function() keyConnection:Disconnect() end)
        end
        if explosionConnection then
            pcall(function() explosionConnection:Disconnect() end)
        end
        
        -- Выводим финальный отчет
        print("\n📊 === ФИНАЛЬНЫЙ ОТЧЕТ УЛУЧШЕННОЙ ДИАГНОСТИКИ ===")
        print("🥚 Яйцо:", EggData.model.Name)
        print("📐 Структура: проанализирована (", #EggData.structure.children, "элементов)")
        print("📜 Скрипты:", #EggData.scripts, "найдено")
        print("🔊 Звуки:", #EggData.sounds, "найдено")
        print("🎨 Материалы:", #EggData.materials, "найдено")
        print("🎨 Текстуры:", #EggData.textures, "найдено")
        print("🐾 Питомцы отслежено:", EggData.petLifecycle.totalPets)
        print("💥 Эффекты взрыва:", #EggData.explosionEffects.effects)
        print("📈 События в timeline:", #EggData.petLifecycle.timeline)
        
        -- Детальная информация о питомцах
        if EggData.petLifecycle.totalPets > 0 then
            print("\n🐾 === ДЕТАЛИ ПИТОМЦЕВ (ИЗ WORKSPACE.VISUALS) ===")
            for petId, petData in pairs(EggData.petLifecycle.pets) do
                print("🐾 Питомец:", petData.name)
                if petData.foundOnStartup then
                    print("  🔍 Найден при запуске (уже был в Visuals)")
                else
                    print("  ⚡ Появился во время мониторинга")
                end
                if petData.lifetime then
                    print("  ⏱️ Время жизни:", string.format("%.2f секунд", petData.lifetime))
                else
                    print("  ⏱️ Время жизни: еще активен")
                end
                print("  📦 Структура: проанализирована")
                print("  ✨ Эффекты:", #petData.effects)
                if #petData.effects > 0 then
                    for _, effect in pairs(petData.effects) do
                        print("    ✨", effect.name, "(", effect.className, ") на", effect.parent)
                    end
                end
            end
        end
        
        -- Информация о timeline событий
        if #EggData.petLifecycle.timeline > 0 then
            print("\n📈 === TIMELINE СОБЫТИЙ ===")
            for _, event in pairs(EggData.petLifecycle.timeline) do
                local timeStr = os.date("%H:%M:%S", event.time)
                print("📅", timeStr, "-", event.event, ":", event.petName)
            end
        end
        
        statusLabel.Text = "✅ УЛУЧШЕННАЯ диагностика завершена! Проверьте консоль"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        print("\n🎯 === УЛУЧШЕННАЯ ДИАГНОСТИКА ЗАВЕРШЕНА ===")
        print("💡 Все данные собраны для создания 1:1 визуального симулятора яйца!")
        print("⚡ Использована точная логика отслеживания из PetScaler_v222222234.lua!")
        print("🔍 Данные включают: структуру яйца, скрипты, звуки, текстуры, эффекты")
        print("🐾 И ТОЧНОЕ отслеживание жизненного цикла питомцев в Workspace.Visuals!")
    end)
end    
    return EggData
end

-- Создание GUI
local function createCorrectedGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CorrectedEggDiagnosticGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 250)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    mainFrame.Parent = screenGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    titleLabel.Text = "🥚 CORRECTED EGG DIAGNOSTIC"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    local startButton = Instance.new("TextButton")
    startButton.Name = "StartButton"
    startButton.Size = UDim2.new(0.9, 0, 0, 40)
    startButton.Position = UDim2.new(0.05, 0, 0, 40)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    startButton.Text = "🔍 ЗАПУСТИТЬ ПРАВИЛЬНУЮ ДИАГНОСТИКУ"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextScaled = true
    startButton.Font = Enum.Font.SourceSansBold
    startButton.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0.9, 0, 0, 80)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 90)
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statusLabel.Text = "📍 Подойдите к яйцу и нажмите кнопку\n🎯 Будет мониториться Workspace.Visuals!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Size = UDim2.new(0.9, 0, 0, 50)
    infoLabel.Position = UDim2.new(0.05, 0, 0, 180)
    infoLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    infoLabel.Text = "⚡ ИСПРАВЛЕНО: Теперь отслеживается\nWorkspace.Visuals и реальное время жизни питомцев!"
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextWrapped = true
    infoLabel.Parent = mainFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.9, 0, 0, 30)
    closeButton.Position = UDim2.new(0.05, 0, 0, 240)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeButton.Text = "❌ ЗАКРЫТЬ"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    -- Обработчики событий
    startButton.MouseButton1Click:Connect(function()
        statusLabel.Text = "🔍 Ищу яйцо рядом с игроком..."
        statusLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
        
        spawn(function()
            local eggModel = findNearbyEgg()
            if not eggModel then
                statusLabel.Text = "❌ Яйцо не найдено! Подойдите ближе"
                statusLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                return
            end
            
            statusLabel.Text = "✅ Яйцо найдено: " .. eggModel.Name
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            
            runCorrectedDiagnostic(eggModel, statusLabel)
        end)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

-- Запуск
createCorrectedGUI()
print("🎮 ИСПРАВЛЕННЫЙ GUI создан! Теперь мониторится Workspace.Visuals!")
