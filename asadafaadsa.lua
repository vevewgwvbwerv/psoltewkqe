-- CompleteEggToHandAnalyzer.lua
-- КОМПЛЕКСНЫЙ АНАЛИЗАТОР: Яйцо → workspace.visuals → Handle
-- Анализирует ПОЛНЫЙ путь появления питомца от взрыва яйца до руки игрока

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === COMPLETE EGG TO HAND ANALYZER ===")
print("🎯 Анализ: Яйцо → workspace.visuals → Handle")
print("=" .. string.rep("=", 60))

-- 📊 КОНФИГУРАЦИЯ
local CONFIG = {
    SEARCH_RADIUS = 250,
    MONITOR_DURATION = 60,
    CHECK_INTERVAL = 0.05,
    DEEP_ANALYSIS = true,
    TRACK_ALL_CHANGES = true
}

-- 🎯 КЛЮЧЕВЫЕ СЛОВА ПИТОМЦЕВ
local PET_KEYWORDS = {
    "dog", "bunny", "golden lab", "dragonfly", "cat", "rabbit", "pet", "animal"
}

-- 📋 СИСТЕМА ОТСЛЕЖИВАНИЯ
local TrackingData = {
    -- Фаза 1: Взрыв яйца
    eggExplosion = {
        detected = false,
        location = nil,
        timestamp = 0
    },
    
    -- Фаза 2: Появление в workspace.visuals
    visualsAppearance = {
        detected = false,
        model = nil,
        timestamp = 0,
        structure = {}
    },
    
    -- Фаза 3: Появление в руке/handle
    handAppearance = {
        detected = false,
        tool = nil,
        timestamp = 0,
        structure = {}
    },
    
    -- Общие данные
    timeline = {},
    allModels = {},
    allTools = {}
}

-- 🖥️ КОНСОЛЬ ЛОГИРОВАНИЯ
local ConsoleGUI = nil
local ConsoleLines = {}
local MaxLines = 50

-- Создание консоли
local function createAnalysisConsole()
    if ConsoleGUI then ConsoleGUI:Destroy() end
    
    ConsoleGUI = Instance.new("ScreenGui")
    ConsoleGUI.Name = "CompleteEggAnalyzerConsole"
    ConsoleGUI.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 400)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.15)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0.2, 0.4, 0.8)
    frame.Parent = ConsoleGUI
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.1, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🔬 COMPLETE EGG TO HAND ANALYZER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundColor3 = Color3.new(0.02, 0.02, 0.08)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🔬 Анализатор готов. Откройте яйцо для начала анализа..."
    textLabel.TextColor3 = Color3.new(0.9, 0.9, 1)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования в консоль
local function logToConsole(level, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local prefixes = {
        EGG = "🥚", VISUALS = "🌍", HANDLE = "🎮", STRUCTURE = "🏗️",
        TIMELINE = "⏱️", CRITICAL = "🔥", FOUND = "🎯", ERROR = "❌"
    }
    
    local logLine = string.format("[%s] %s %s", timestamp, prefixes[level] or "ℹ️", message)
    
    if data and next(data) then
        for key, value in pairs(data) do
            logLine = logLine .. string.format("\n    %s: %s", key, tostring(value))
        end
    end
    
    table.insert(ConsoleLines, logLine)
    
    -- Ограничиваем количество строк
    if #ConsoleLines > MaxLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Обновляем консоль
    if ConsoleGUI then
        local textLabel = ConsoleGUI:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
        end
    end
    
    -- Также в обычную консоль
    print(logLine)
end

-- 🥚 ФАЗА 1: Детекция взрыва яйца
local function detectEggExplosion()
    local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not playerPos then return false end
    
    -- Поиск EggExplode в workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "EggExplode" and obj:IsA("Model") then
            local distance = (obj:GetModelCFrame().Position - playerPos.Position).Magnitude
            if distance <= CONFIG.SEARCH_RADIUS then
                TrackingData.eggExplosion.detected = true
                TrackingData.eggExplosion.location = obj:GetModelCFrame().Position
                TrackingData.eggExplosion.timestamp = tick()
                
                logToConsole("EGG", "💥 ВЗРЫВ ЯЙЦА ОБНАРУЖЕН!", {
                    Position = tostring(obj:GetModelCFrame().Position),
                    Distance = string.format("%.1f", distance),
                    Children = #obj:GetChildren()
                })
                
                -- Добавляем в timeline
                table.insert(TrackingData.timeline, {
                    phase = "EGG_EXPLOSION",
                    timestamp = tick(),
                    data = obj
                })
                
                return true, obj
            end
        end
    end
    
    return false
end

-- 🌍 ФАЗА 2: Мониторинг workspace.visuals
local function monitorWorkspaceVisuals()
    local visuals = Workspace:FindFirstChild("visuals")
    if not visuals then
        logToConsole("ERROR", "❌ workspace.visuals не найден!")
        return
    end
    
    logToConsole("VISUALS", "🌍 Мониторинг workspace.visuals активен")
    
    -- Снимок ДО взрыва
    local beforeModels = {}
    for _, child in pairs(visuals:GetChildren()) do
        if child:IsA("Model") then
            beforeModels[child.Name] = child
        end
    end
    
    -- Мониторинг изменений
    local connection
    connection = visuals.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            -- Проверяем является ли это питомцем
            local isPet = false
            local petName = child.Name:lower()
            for _, keyword in ipairs(PET_KEYWORDS) do
                if petName:find(keyword) then
                    isPet = true
                    break
                end
            end
            
            if isPet then
                TrackingData.visualsAppearance.detected = true
                TrackingData.visualsAppearance.model = child
                TrackingData.visualsAppearance.timestamp = tick()
                
                logToConsole("VISUALS", "🎯 ПИТОМЕЦ ПОЯВИЛСЯ В VISUALS!", {
                    Name = child.Name,
                    ClassName = child.ClassName,
                    Children = #child:GetChildren(),
                    Position = tostring(child:GetModelCFrame().Position)
                })
                
                -- Глубокий анализ структуры
                analyzeModelStructure(child, "VISUALS")
                
                -- Добавляем в timeline
                table.insert(TrackingData.timeline, {
                    phase = "VISUALS_APPEARANCE",
                    timestamp = tick(),
                    data = child
                })
                
                -- Отслеживаем жизненный цикл
                trackModelLifecycle(child, "VISUALS")
            end
        end
    end)
    
    return connection
end

-- 🎮 ФАЗА 3: Мониторинг появления в руке/handle
local function monitorHandAppearance()
    logToConsole("HANDLE", "🎮 Мониторинг появления в руке активен")
    
    local character = player.Character
    if not character then
        logToConsole("ERROR", "❌ Character не найден!")
        return
    end
    
    -- Мониторинг добавления Tool в character
    local connection
    connection = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            -- Проверяем является ли это питомцем
            local isPet = false
            local toolName = child.Name:lower()
            for _, keyword in ipairs(PET_KEYWORDS) do
                if toolName:find(keyword) then
                    isPet = true
                    break
                end
            end
            
            if isPet then
                TrackingData.handAppearance.detected = true
                TrackingData.handAppearance.tool = child
                TrackingData.handAppearance.timestamp = tick()
                
                logToConsole("HANDLE", "🎯 ПИТОМЕЦ ПОЯВИЛСЯ В РУКЕ!", {
                    Name = child.Name,
                    ClassName = child.ClassName,
                    Children = #child:GetChildren(),
                    Handle = child:FindFirstChild("Handle") and "✅" or "❌"
                })
                
                -- Глубокий анализ структуры Tool
                analyzeModelStructure(child, "HANDLE")
                
                -- Добавляем в timeline
                table.insert(TrackingData.timeline, {
                    phase = "HANDLE_APPEARANCE",
                    timestamp = tick(),
                    data = child
                })
                
                -- Отслеживаем жизненный цикл
                trackModelLifecycle(child, "HANDLE")
            end
        end
    end)
    
    return connection
end

-- 🏗️ АНАЛИЗ СТРУКТУРЫ МОДЕЛИ
local function analyzeModelStructure(model, phase)
    logToConsole("STRUCTURE", string.format("🏗️ АНАЛИЗ СТРУКТУРЫ [%s]", phase), {
        Name = model.Name,
        ClassName = model.ClassName,
        Parent = model.Parent and model.Parent.Name or "NIL"
    })
    
    -- Анализ содержимого
    local structure = {
        baseParts = 0,
        meshParts = 0,
        specialMeshes = 0,
        motor6ds = 0,
        welds = 0,
        attachments = 0,
        scripts = 0,
        animators = 0
    }
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            structure.baseParts = structure.baseParts + 1
        elseif obj:IsA("MeshPart") then
            structure.meshParts = structure.meshParts + 1
        elseif obj:IsA("SpecialMesh") then
            structure.specialMeshes = structure.specialMeshes + 1
        elseif obj:IsA("Motor6D") then
            structure.motor6ds = structure.motor6ds + 1
        elseif obj:IsA("Weld") then
            structure.welds = structure.welds + 1
        elseif obj:IsA("Attachment") then
            structure.attachments = structure.attachments + 1
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            structure.scripts = structure.scripts + 1
            logToConsole("STRUCTURE", "📜 Найден скрипт: " .. obj.Name)
        elseif obj:IsA("Animator") then
            structure.animators = structure.animators + 1
        end
    end
    
    logToConsole("STRUCTURE", string.format("📊 Структура [%s]:", phase), structure)
    
    -- Сохраняем структуру
    if phase == "VISUALS" then
        TrackingData.visualsAppearance.structure = structure
    elseif phase == "HANDLE" then
        TrackingData.handAppearance.structure = structure
    end
end

-- ⏱️ ОТСЛЕЖИВАНИЕ ЖИЗНЕННОГО ЦИКЛА
local function trackModelLifecycle(model, phase)
    local startTime = tick()
    local modelName = model.Name
    
    logToConsole("TIMELINE", string.format("⏱️ НАЧАЛО ОТСЛЕЖИВАНИЯ [%s]: %s", phase, modelName))
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not model or not model.Parent then
            connection:Disconnect()
            local lifetime = tick() - startTime
            
            logToConsole("TIMELINE", string.format("💀 МОДЕЛЬ УДАЛЕНА [%s]: %s", phase, modelName), {
                Lifetime = string.format("%.2f сек", lifetime)
            })
            
            return
        end
        
        -- Проверяем изменения каждые 2 секунды
        if math.floor((tick() - startTime) * 10) % 20 == 0 then
            local currentPos = model:GetModelCFrame().Position
            logToConsole("TIMELINE", string.format("📍 ПОЗИЦИЯ [%s]: %s", phase, modelName), {
                Position = tostring(currentPos),
                Alive = string.format("%.1f сек", tick() - startTime)
            })
        end
    end)
end

-- 🔍 ПОИСК ИСТОЧНИКОВ СОЗДАНИЯ МОДЕЛИ
local function analyzeModelSources()
    logToConsole("CRITICAL", "🔍 АНАЛИЗ ИСТОЧНИКОВ СОЗДАНИЯ МОДЕЛИ")
    
    -- Анализ ReplicatedStorage
    logToConsole("CRITICAL", "📦 Анализ ReplicatedStorage...")
    local petModelsFound = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            for _, keyword in ipairs(PET_KEYWORDS) do
                if name:find(keyword) then
                    petModelsFound = petModelsFound + 1
                    logToConsole("FOUND", "🎯 НАЙДЕНА МОДЕЛЬ В REPLICATEDSTORAGE!", {
                        Name = obj.Name,
                        Path = obj:GetFullName(),
                        Children = #obj:GetChildren()
                    })
                end
            end
        end
    end
    
    logToConsole("CRITICAL", string.format("📊 Найдено %d моделей питомцев в ReplicatedStorage", petModelsFound))
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ АНАЛИЗА
local function startCompleteAnalysis()
    logToConsole("CRITICAL", "🚀 ЗАПУСК КОМПЛЕКСНОГО АНАЛИЗА")
    logToConsole("CRITICAL", "🎯 Цель: Полный путь Яйцо → workspace.visuals → Handle")
    
    -- Сброс данных
    TrackingData = {
        eggExplosion = {detected = false, location = nil, timestamp = 0},
        visualsAppearance = {detected = false, model = nil, timestamp = 0, structure = {}},
        handAppearance = {detected = false, tool = nil, timestamp = 0, structure = {}},
        timeline = {},
        allModels = {},
        allTools = {}
    }
    
    -- Анализ источников
    analyzeModelSources()
    
    -- Запуск мониторинга
    local visualsConnection = monitorWorkspaceVisuals()
    local handConnection = monitorHandAppearance()
    
    -- Основной цикл анализа
    local startTime = tick()
    local mainConnection
    mainConnection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        
        -- Фаза 1: Поиск взрыва яйца
        if not TrackingData.eggExplosion.detected then
            local found, eggObj = detectEggExplosion()
            if found then
                logToConsole("EGG", "💥 ПЕРЕХОД К ФАЗЕ 2: Мониторинг workspace.visuals")
            end
        end
        
        -- Проверка завершения анализа
        if elapsed > CONFIG.MONITOR_DURATION then
            logToConsole("CRITICAL", "⏰ Анализ завершен по таймауту")
            mainConnection:Disconnect()
            if visualsConnection then visualsConnection:Disconnect() end
            if handConnection then handConnection:Disconnect() end
            generateCompleteReport()
        end
        
        -- Проверка завершения всех фаз
        if TrackingData.eggExplosion.detected and 
           TrackingData.visualsAppearance.detected and 
           TrackingData.handAppearance.detected then
            logToConsole("CRITICAL", "✅ ВСЕ ФАЗЫ ЗАВЕРШЕНЫ! Генерация отчета...")
            mainConnection:Disconnect()
            if visualsConnection then visualsConnection:Disconnect() end
            if handConnection then handConnection:Disconnect() end
            generateCompleteReport()
        end
    end)
    
    logToConsole("CRITICAL", "🔬 КОМПЛЕКСНЫЙ АНАЛИЗ АКТИВЕН!")
    logToConsole("CRITICAL", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ НАЧАЛА АНАЛИЗА!")
end

-- 📊 ГЕНЕРАЦИЯ ПОЛНОГО ОТЧЕТА
local function generateCompleteReport()
    logToConsole("CRITICAL", "📊 === ПОЛНЫЙ ОТЧЕТ АНАЛИЗА ===")
    
    -- Фаза 1: Взрыв яйца
    if TrackingData.eggExplosion.detected then
        logToConsole("EGG", "✅ ФАЗА 1: Взрыв яйца обнаружен", {
            Timestamp = string.format("%.2f сек", TrackingData.eggExplosion.timestamp),
            Location = tostring(TrackingData.eggExplosion.location)
        })
    else
        logToConsole("EGG", "❌ ФАЗА 1: Взрыв яйца НЕ обнаружен")
    end
    
    -- Фаза 2: workspace.visuals
    if TrackingData.visualsAppearance.detected then
        local delay = TrackingData.visualsAppearance.timestamp - TrackingData.eggExplosion.timestamp
        logToConsole("VISUALS", "✅ ФАЗА 2: Появление в workspace.visuals", {
            Model = TrackingData.visualsAppearance.model.Name,
            Delay = string.format("%.3f сек после взрыва", delay),
            BaseParts = TrackingData.visualsAppearance.structure.baseParts,
            Motor6Ds = TrackingData.visualsAppearance.structure.motor6ds
        })
    else
        logToConsole("VISUALS", "❌ ФАЗА 2: Появление в workspace.visuals НЕ обнаружено")
    end
    
    -- Фаза 3: Handle/рука
    if TrackingData.handAppearance.detected then
        local delay = TrackingData.handAppearance.timestamp - TrackingData.eggExplosion.timestamp
        logToConsole("HANDLE", "✅ ФАЗА 3: Появление в руке/handle", {
            Tool = TrackingData.handAppearance.tool.Name,
            Delay = string.format("%.3f сек после взрыва", delay),
            BaseParts = TrackingData.handAppearance.structure.baseParts,
            Motor6Ds = TrackingData.handAppearance.structure.motor6ds
        })
    else
        logToConsole("HANDLE", "❌ ФАЗА 3: Появление в руке/handle НЕ обнаружено")
    end
    
    -- Timeline
    logToConsole("TIMELINE", "⏱️ ВРЕМЕННАЯ ЛИНИЯ:")
    for i, event in ipairs(TrackingData.timeline) do
        logToConsole("TIMELINE", string.format("  %d. %s (%.3f сек)", i, event.phase, event.timestamp))
    end
    
    logToConsole("CRITICAL", "🎯 АНАЛИЗ ЗАВЕРШЕН! Проверьте результаты выше.")
end

-- Создаем GUI с кнопкой запуска
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CompleteEggAnalyzerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(1, -320, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🔬 EGG TO HAND ANALYZER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 50)
    startBtn.Position = UDim2.new(0, 10, 0, 50)
    startBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🚀 НАЧАТЬ АНАЛИЗ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 110)
    status.BackgroundTransparency = 1
    status.Text = "Готов к анализу.\nОткройте яйцо после запуска."
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🔬 Анализ активен!\nОткройте яйцо сейчас!"
        status.TextColor3 = Color3.new(0, 1, 0)
        startBtn.Text = "✅ АНАЛИЗ АКТИВЕН"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startCompleteAnalysis()
    end)
end

-- Запускаем
local consoleTextLabel = createAnalysisConsole()
createMainGUI()

logToConsole("CRITICAL", "✅ CompleteEggToHandAnalyzer готов!")
logToConsole("CRITICAL", "🔬 Анализирует: Яйцо → workspace.visuals → Handle")
logToConsole("CRITICAL", "🚀 Нажмите 'НАЧАТЬ АНАЛИЗ' и откройте яйцо!")
