-- 🔥 COMPREHENSIVE EGG PET ANIMATION ANALYZER
-- Основан на анализе 10 скриптов: EggAnimationDiagnostic, AdvancedEggDiagnostic, EggExplosionTracker,
-- CorrectEggDiagnostic, RealPetModelFinder, EggExplodeAnalyzer, PrecisePetModelFilter, 
-- AggressiveModelCatcher, UniversalTempModelAnalyzer, PreciseAnimationModelFinder
-- 
-- ЦЕЛЬ: Полный анализ анимации workspace.visuals и eggexplode
-- Находит модели: dog, bunny, golden lab и анализирует их анимацию

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 📊 КОНФИГУРАЦИЯ
local CONFIG = {
    SEARCH_RADIUS = 200,
    MONITOR_DURATION = 30,
    CHECK_INTERVAL = 0.05,
    ANALYSIS_DEPTH = 8,
    MIN_CHILD_COUNT = 10,
    MIN_MESH_COUNT = 1
}

-- 🎯 КЛЮЧЕВЫЕ СЛОВА ПИТОМЦЕВ (из всех скриптов)
local PET_KEYWORDS = {
    "dog", "bunny", "golden lab", "cat", "rabbit", "pet", "animal", "golden", "lab"
}

-- 🚫 ИСКЛЮЧЕНИЯ (из PrecisePetModelFilter и других)
local EXCLUDED_NAMES = {
    "EggExplode", "CraftingTables", "EventCraftingWorkBench", "Fruit", "Tree", 
    "Bush", "Platform", "Stand", "Bench", "Table", "Chair", "Decoration"
}

-- 📋 СИСТЕМА ЛОГИРОВАНИЯ
local Logger = {
    log = function(self, level, message, data)
        local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
        local prefixes = {
            EXPLOSION = "💥", PET = "🐾", ANIMATION = "🎬", STRUCTURE = "🏗️",
            MESH = "🎨", LIFECYCLE = "⏱️", CRITICAL = "🔥", FOUND = "🎯"
        }
        
        print(string.format("[%s] %s %s", timestamp, prefixes[level] or "ℹ️", message))
        
        if data and next(data) then
            for key, value in pairs(data) do
                print(string.format("    %s: %s", key, tostring(value)))
            end
        end
    end
}

-- 🔍 ФУНКЦИЯ ПОИСКА EGGEXPLODE (из CorrectEggDiagnostic)
local function checkForEggExplode()
    -- Ищем в ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name == "EggExplode" and obj:IsA("Model") then
            return true, obj, "ReplicatedStorage"
        end
    end
    
    -- Ищем в Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "EggExplode" and obj:IsA("Model") then
            return true, obj, "Workspace"
        elseif obj.Name:lower():find("eggexplode") or (obj.Name:lower():find("egg") and obj.Name:lower():find("explode")) then
            return true, obj, "Workspace"
        end
    end
    
    return false, nil, nil
end

-- 🎯 ФУНКЦИЯ ПРОВЕРКИ МОДЕЛИ ПИТОМЦА (объединение всех подходов)
local function isPetModel(model)
    -- 1. Должна быть Model
    if not model:IsA("Model") then return false end
    
    -- 2. Исключения
    for _, excluded in pairs(EXCLUDED_NAMES) do
        if model.Name:find(excluded) then return false end
    end
    
    -- 3. Исключаем модели инвентаря игроков
    if model.Name:find("%[") and model.Name:find("KG") and model.Name:find("Age") then
        return false
    end
    
    -- 4. Исключаем игроков
    for _, p in pairs(Players:GetPlayers()) do
        if model.Name == p.Name or model.Name:find(p.Name) then
            return false
        end
    end
    
    -- 5. Проверяем наличие мешей
    local meshCount = 0
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            meshCount = meshCount + 1
        end
    end
    
    if meshCount < CONFIG.MIN_MESH_COUNT then return false end
    
    -- 6. Проверяем количество детей
    if #model:GetChildren() < CONFIG.MIN_CHILD_COUNT then return false end
    
    -- 7. Проверяем расстояние до игрока
    local playerChar = player.Character
    if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            local distance = (modelCFrame.Position - playerChar.HumanoidRootPart.Position).Magnitude
            if distance > CONFIG.SEARCH_RADIUS then return false end
        end
    end
    
    return true
end

-- 🏗️ ГЛУБОКИЙ АНАЛИЗ СТРУКТУРЫ (из EggExplodeAnalyzer и UniversalTempModelAnalyzer)
local function deepAnalyzeStructure(obj, depth, parentPath)
    depth = depth or 0
    parentPath = parentPath or ""
    local indent = string.rep("  ", depth)
    
    if depth > CONFIG.ANALYSIS_DEPTH then return end
    
    local currentPath = parentPath .. "/" .. obj.Name
    
    Logger:log("STRUCTURE", indent .. "📦 " .. obj.Name .. " (" .. obj.ClassName .. ")", {
        FullPath = currentPath,
        Parent = obj.Parent and obj.Parent.Name or "nil"
    })
    
    -- Анализ BasePart
    if obj:IsA("BasePart") then
        local partData = {
            Size = tostring(obj.Size),
            Position = tostring(obj.Position),
            Transparency = obj.Transparency,
            Color = tostring(obj.Color),
            Material = obj.Material.Name,
            CanCollide = obj.CanCollide,
            Anchored = obj.Anchored
        }
        Logger:log("STRUCTURE", indent .. "  🧱 BasePart Properties", partData)
    end
    
    -- Анализ MeshPart/SpecialMesh
    if obj:IsA("MeshPart") then
        local meshData = {
            MeshId = obj.MeshId or "EMPTY",
            TextureId = obj.TextureId or "EMPTY",
            MeshSize = tostring(obj.MeshSize or "nil")
        }
        Logger:log("MESH", indent .. "  🎨 MeshPart Data", meshData)
    elseif obj:IsA("SpecialMesh") then
        local meshData = {
            MeshId = obj.MeshId or "EMPTY",
            TextureId = obj.TextureId or "EMPTY",
            MeshType = obj.MeshType.Name,
            Scale = tostring(obj.Scale)
        }
        Logger:log("MESH", indent .. "  🎨 SpecialMesh Data", meshData)
    end
    
    -- Анализ Motor6D для анимации
    if obj:IsA("Motor6D") then
        local motorData = {
            C0 = tostring(obj.C0),
            C1 = tostring(obj.C1),
            Part0 = obj.Part0 and obj.Part0.Name or "nil",
            Part1 = obj.Part1 and obj.Part1.Name or "nil"
        }
        Logger:log("ANIMATION", indent .. "  🎬 Motor6D Data", motorData)
    end
    
    -- Рекурсивный анализ детей
    for _, child in pairs(obj:GetChildren()) do
        deepAnalyzeStructure(child, depth + 1, currentPath)
    end
end

-- ⏱️ ОТСЛЕЖИВАНИЕ ЖИЗНЕННОГО ЦИКЛА (из всех скриптов)
local function trackLifecycle(model)
    local startTime = tick()
    local modelName = model.Name
    
    Logger:log("LIFECYCLE", "⏱️ НАЧАЛО ОТСЛЕЖИВАНИЯ: " .. modelName)
    
    -- Мониторинг изменений позиции/анимации
    local lastPosition = nil
    local animationFrames = {}
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not model or not model.Parent then
            connection:Disconnect()
            local lifetime = tick() - startTime
            
            Logger:log("LIFECYCLE", "⏱️ МОДЕЛЬ ИСЧЕЗЛА: " .. modelName, {
                lifetime = string.format("%.2f секунд", lifetime),
                animationFrames = #animationFrames
            })
            
            if #animationFrames > 0 then
                Logger:log("ANIMATION", "🎬 ЗАПИСАННЫЕ КАДРЫ АНИМАЦИИ: " .. #animationFrames)
            end
            return
        end
        
        -- Записываем кадры анимации
        local success, currentCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            if not lastPosition or (currentCFrame.Position - lastPosition).Magnitude > 0.1 then
                table.insert(animationFrames, {
                    time = tick() - startTime,
                    position = currentCFrame.Position,
                    rotation = currentCFrame.Rotation
                })
                lastPosition = currentCFrame.Position
                
                Logger:log("ANIMATION", "🎬 КАДР АНИМАЦИИ", {
                    frame = #animationFrames,
                    time = string.format("%.2f", tick() - startTime),
                    position = tostring(currentCFrame.Position)
                })
            end
        end
    end)
end

-- 🎯 ОСНОВНАЯ ФУНКЦИЯ АНАЛИЗА
local function startComprehensiveAnalysis()
    Logger:log("CRITICAL", "🔥 ЗАПУСК КОМПЛЕКСНОГО АНАЛИЗА АНИМАЦИИ ПИТОМЦЕВ ИЗ ЯИЦ")
    Logger:log("CRITICAL", "🎯 Цель: dog, bunny, golden lab и другие временные модели")
    Logger:log("CRITICAL", "📋 Анализ: workspace.visuals, eggexplode, структура, анимация")
    
    local eggExplodeDetected = false
    local analysisStartTime = 0
    local processedModels = {}
    local foundPetModels = {}
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        -- Фаза 1: Поиск EggExplode
        if not eggExplodeDetected then
            local found, eggObj, location = checkForEggExplode()
            if found then
                eggExplodeDetected = true
                analysisStartTime = tick()
                
                Logger:log("EXPLOSION", "💥 EGGEXPLODE ОБНАРУЖЕН В " .. location .. "!")
                Logger:log("EXPLOSION", "💥 Начинаем поиск и анализ моделей питомцев...")
                
                -- Анализируем сам EggExplode
                if eggObj then
                    Logger:log("EXPLOSION", "💥 АНАЛИЗ СТРУКТУРЫ EGGEXPLODE:")
                    deepAnalyzeStructure(eggObj, 0, "EggExplode")
                end
            end
        else
            -- Фаза 2: Поиск и анализ моделей питомцев
            local elapsed = tick() - analysisStartTime
            
            if elapsed > CONFIG.MONITOR_DURATION then
                Logger:log("CRITICAL", "🔥 АНАЛИЗ ЗАВЕРШЁН ПО ТАЙМАУТУ")
                connection:Disconnect()
                
                if #foundPetModels > 0 then
                    Logger:log("CRITICAL", "🔥 НАЙДЕННЫЕ МОДЕЛИ ПИТОМЦЕВ:")
                    for i, petData in pairs(foundPetModels) do
                        Logger:log("PET", string.format("🐾 Питомец %d: %s", i, petData.name), petData.summary)
                    end
                else
                    Logger:log("CRITICAL", "❌ МОДЕЛИ ПИТОМЦЕВ НЕ НАЙДЕНЫ!")
                end
                return
            end
            
            -- Сканируем все модели
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= player.Character and not processedModels[obj] then
                    processedModels[obj] = true
                    
                    if isPetModel(obj) then
                        -- Проверяем на ключевые слова питомцев
                        local isPotentialPet = false
                        for _, keyword in pairs(PET_KEYWORDS) do
                            if obj.Name:lower():find(keyword) then
                                isPotentialPet = true
                                break
                            end
                        end
                        
                        if isPotentialPet then
                            Logger:log("FOUND", "🎯 НАЙДЕНА МОДЕЛЬ ПИТОМЦА: " .. obj.Name)
                            
                            local petData = {
                                name = obj.Name,
                                foundTime = elapsed,
                                summary = {
                                    childCount = #obj:GetChildren(),
                                    hasHumanoid = obj:FindFirstChild("Humanoid") ~= nil,
                                    hasPrimaryPart = obj.PrimaryPart ~= nil
                                }
                            }
                            
                            table.insert(foundPetModels, petData)
                            
                            -- Полный анализ структуры
                            Logger:log("PET", "🐾 ПОЛНЫЙ АНАЛИЗ СТРУКТУРЫ: " .. obj.Name)
                            deepAnalyzeStructure(obj, 0, obj.Name)
                            
                            -- Отслеживание жизненного цикла и анимации
                            trackLifecycle(obj)
                        end
                    end
                end
            end
        end
    end)
    
    Logger:log("CRITICAL", "🔥 МОНИТОРИНГ АКТИВЕН. ОТКРОЙТЕ ЯЙЦО ДЛЯ АНАЛИЗА!")
end

-- 🖥️ GUI
local function createAnalysisGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ComprehensiveEggPetAnalyzerGUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 200)
    frame.Position = UDim2.new(0.5, -225, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "🔥 COMPREHENSIVE EGG PET ANALYZER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0.8, 0, 0, 40)
    startButton.Position = UDim2.new(0.1, 0, 0.3, 0)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    startButton.Text = "🚀 ЗАПУСТИТЬ АНАЛИЗ"
    startButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    startButton.TextScaled = true
    startButton.Font = Enum.Font.SourceSansBold
    startButton.Parent = frame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = startButton
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
    infoLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Анализирует: EggExplode → Dog/Bunny/Golden Lab\nСтруктура, анимация, жизненный цикл\nОткройте F9 для просмотра логов"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.Parent = frame
    
    startButton.MouseButton1Click:Connect(function()
        startButton.Text = "⏳ АНАЛИЗ АКТИВЕН..."
        startButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        startComprehensiveAnalysis()
    end)
end

-- 🚀 ЗАПУСК
createAnalysisGUI()
Logger:log("CRITICAL", "🔥 COMPREHENSIVE EGG PET ANIMATION ANALYZER ГОТОВ!")
Logger:log("CRITICAL", "📋 Основан на анализе 10 диагностических скриптов")
Logger:log("CRITICAL", "🎯 Нажмите кнопку для начала анализа")
