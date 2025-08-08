-- DeepModelOriginDetective.lua
-- ДЕТЕКТИВНЫЙ АНАЛИЗАТОР: Глубокое исследование происхождения модели питомца
-- Отслеживает ВСЮ цепочку создания: ReplicatedStorage → Scripts → Events → Model

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local player = Players.LocalPlayer

print("🕵️ === DEEP MODEL ORIGIN DETECTIVE ===")
print("🎯 Цель: Найти ОТКУДА и КАК создается модель питомца")
print("=" .. string.rep("=", 60))

-- 📊 КОНФИГУРАЦИЯ ДЕТЕКТИВНОГО АНАЛИЗА
local CONFIG = {
    SEARCH_RADIUS = 300,
    MONITOR_DURATION = 120,
    DEEP_SCAN_INTERVAL = 0.02,
    TRACK_ALL_INSTANCES = true,
    ANALYZE_SCRIPTS = true,
    MONITOR_EVENTS = true
}

-- 🔍 ДЕТЕКТИВНЫЕ ДАННЫЕ
local DetectiveData = {
    -- Источники моделей
    modelSources = {},
    
    -- Скрипты и события
    activeScripts = {},
    detectedEvents = {},
    
    -- Цепочка создания
    creationChain = {},
    
    -- Снимки состояния
    beforeSnapshot = {},
    afterSnapshot = {},
    
    -- Временная линия
    timeline = {}
}

-- 🖥️ ДЕТЕКТИВНАЯ КОНСОЛЬ
local DetectiveConsole = nil
local ConsoleLines = {}
local MaxLines = 100

-- Создание детективной консоли
local function createDetectiveConsole()
    if DetectiveConsole then DetectiveConsole:Destroy() end
    
    DetectiveConsole = Instance.new("ScreenGui")
    DetectiveConsole.Name = "DeepModelOriginDetectiveConsole"
    DetectiveConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 700, 0, 500)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.02, 0.1)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.8, 0.2, 0.2)
    frame.Parent = DetectiveConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.8, 0.1, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🕵️ DEEP MODEL ORIGIN DETECTIVE"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.01, 0.01, 0.05)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🕵️ Детективный анализатор готов..."
    textLabel.TextColor3 = Color3.new(1, 0.9, 0.9)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция детективного логирования
local function detectiveLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local prefixes = {
        DETECTIVE = "🕵️", SOURCE = "📦", SCRIPT = "📜", EVENT = "⚡",
        CREATION = "🏗️", CHAIN = "🔗", TIMELINE = "⏱️", CRITICAL = "🔥",
        FOUND = "🎯", ANALYSIS = "🔬", MYSTERY = "❓", SOLVED = "✅"
    }
    
    local logLine = string.format("[%s] %s %s", timestamp, prefixes[category] or "ℹ️", message)
    
    if data and next(data) then
        for key, value in pairs(data) do
            logLine = logLine .. string.format("\n    %s: %s", key, tostring(value))
        end
    end
    
    table.insert(ConsoleLines, logLine)
    
    if #ConsoleLines > MaxLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Обновляем консоль
    if DetectiveConsole then
        local textLabel = DetectiveConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 🔍 ФАЗА 1: ГЛУБОКОЕ СКАНИРОВАНИЕ ИСТОЧНИКОВ
local function scanAllModelSources()
    detectiveLog("DETECTIVE", "🔍 НАЧАЛО ГЛУБОКОГО СКАНИРОВАНИЯ ИСТОЧНИКОВ")
    
    -- Сканирование ReplicatedStorage
    detectiveLog("SOURCE", "📦 Сканирование ReplicatedStorage...")
    local replicatedModels = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Tool") then
            local name = obj.Name:lower()
            if name:find("bunny") or name:find("dog") or name:find("pet") or name:find("animal") then
                replicatedModels = replicatedModels + 1
                DetectiveData.modelSources[obj:GetFullName()] = {
                    object = obj,
                    location = "ReplicatedStorage",
                    path = obj:GetFullName(),
                    children = #obj:GetChildren(),
                    className = obj.ClassName
                }
                
                detectiveLog("FOUND", "🎯 НАЙДЕН ИСТОЧНИК В REPLICATEDSTORAGE!", {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    ClassName = obj.ClassName,
                    Children = #obj:GetChildren()
                })
            end
        end
    end
    
    -- Сканирование ReplicatedFirst
    detectiveLog("SOURCE", "📦 Сканирование ReplicatedFirst...")
    for _, obj in pairs(ReplicatedFirst:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Tool") then
            local name = obj.Name:lower()
            if name:find("bunny") or name:find("dog") or name:find("pet") or name:find("animal") then
                DetectiveData.modelSources[obj:GetFullName()] = {
                    object = obj,
                    location = "ReplicatedFirst",
                    path = obj:GetFullName(),
                    children = #obj:GetChildren(),
                    className = obj.ClassName
                }
                
                detectiveLog("FOUND", "🎯 НАЙДЕН ИСТОЧНИК В REPLICATEDFIRST!", {
                    Name = obj.Name,
                    Path = obj:GetFullName()
                })
            end
        end
    end
    
    detectiveLog("SOURCE", string.format("📊 Найдено %d потенциальных источников", replicatedModels))
end

-- 📜 ФАЗА 2: АНАЛИЗ СКРИПТОВ
local function analyzeActiveScripts()
    detectiveLog("SCRIPT", "📜 АНАЛИЗ АКТИВНЫХ СКРИПТОВ...")
    
    -- Поиск скриптов в workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local scriptName = obj.Name:lower()
            if scriptName:find("pet") or scriptName:find("egg") or scriptName:find("tool") or 
               scriptName:find("model") or scriptName:find("spawn") or scriptName:find("create") then
                
                DetectiveData.activeScripts[obj:GetFullName()] = {
                    script = obj,
                    name = obj.Name,
                    path = obj:GetFullName(),
                    parent = obj.Parent and obj.Parent.Name or "NIL",
                    className = obj.ClassName
                }
                
                detectiveLog("SCRIPT", "📜 НАЙДЕН ПОДОЗРИТЕЛЬНЫЙ СКРИПТ!", {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Parent = obj.Parent and obj.Parent.Name or "NIL"
                })
            end
        end
    end
    
    -- Поиск скриптов в ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local scriptName = obj.Name:lower()
            if scriptName:find("pet") or scriptName:find("egg") or scriptName:find("tool") then
                detectiveLog("SCRIPT", "📜 СКРИПТ В REPLICATEDSTORAGE!", {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Type = obj.ClassName
                })
            end
        end
    end
end

-- ⚡ ФАЗА 3: МОНИТОРИНГ СОБЫТИЙ И ИЗМЕНЕНИЙ
local function monitorCreationEvents()
    detectiveLog("EVENT", "⚡ МОНИТОРИНГ СОБЫТИЙ СОЗДАНИЯ...")
    
    -- Мониторинг добавления новых объектов в workspace
    local workspaceConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") or obj:IsA("Tool") then
            local name = obj.Name:lower()
            if name:find("bunny") or name:find("dog") or name:find("pet") or name:find("animal") then
                local creationTime = tick()
                
                DetectiveData.creationChain[obj:GetFullName()] = {
                    object = obj,
                    createdAt = creationTime,
                    parent = obj.Parent and obj.Parent.Name or "NIL",
                    location = "Workspace"
                }
                
                detectiveLog("CREATION", "🏗️ НОВАЯ МОДЕЛЬ СОЗДАНА В WORKSPACE!", {
                    Name = obj.Name,
                    Parent = obj.Parent and obj.Parent.Name or "NIL",
                    ClassName = obj.ClassName,
                    Time = string.format("%.3f", creationTime)
                })
                
                -- Глубокий анализ новой модели
                analyzeNewModel(obj)
            end
        end
    end)
    
    -- Мониторинг добавления в character
    local character = player.Character
    if character then
        local characterConnection = character.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                local name = obj.Name:lower()
                if name:find("bunny") or name:find("dog") or name:find("pet") or name:find("animal") then
                    detectiveLog("CREATION", "🎮 TOOL ДОБАВЛЕН В CHARACTER!", {
                        Name = obj.Name,
                        ClassName = obj.ClassName,
                        Children = #obj:GetChildren()
                    })
                    
                    -- Анализ происхождения Tool
                    analyzeToolOrigin(obj)
                end
            end
        end)
    end
    
    return workspaceConnection
end

-- 🔬 ГЛУБОКИЙ АНАЛИЗ НОВОЙ МОДЕЛИ
local function analyzeNewModel(model)
    detectiveLog("ANALYSIS", "🔬 ГЛУБОКИЙ АНАЛИЗ НОВОЙ МОДЕЛИ: " .. model.Name)
    
    -- Анализ структуры
    local structure = {
        baseParts = 0,
        meshParts = 0,
        motor6ds = 0,
        welds = 0,
        scripts = 0,
        animators = 0,
        handles = 0
    }
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            structure.baseParts = structure.baseParts + 1
            if obj.Name == "Handle" then
                structure.handles = structure.handles + 1
            end
        elseif obj:IsA("MeshPart") then
            structure.meshParts = structure.meshParts + 1
        elseif obj:IsA("Motor6D") then
            structure.motor6ds = structure.motor6ds + 1
        elseif obj:IsA("Weld") then
            structure.welds = structure.welds + 1
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            structure.scripts = structure.scripts + 1
            detectiveLog("SCRIPT", "📜 СКРИПТ В МОДЕЛИ: " .. obj.Name)
        elseif obj:IsA("Animator") then
            structure.animators = structure.animators + 1
        end
    end
    
    detectiveLog("ANALYSIS", "📊 Структура модели:", structure)
    
    -- Поиск похожих моделей в источниках
    for sourcePath, sourceData in pairs(DetectiveData.modelSources) do
        if sourceData.object.Name == model.Name or 
           sourceData.object.Name:lower():find(model.Name:lower()) then
            detectiveLog("CHAIN", "🔗 ВОЗМОЖНАЯ СВЯЗЬ С ИСТОЧНИКОМ!", {
                Source = sourcePath,
                Model = model.Name,
                Match = "Name similarity"
            })
        end
    end
end

-- 🎯 АНАЛИЗ ПРОИСХОЖДЕНИЯ TOOL
local function analyzeToolOrigin(tool)
    detectiveLog("ANALYSIS", "🎯 АНАЛИЗ ПРОИСХОЖДЕНИЯ TOOL: " .. tool.Name)
    
    -- Проверяем Handle
    local handle = tool:FindFirstChild("Handle")
    if handle then
        detectiveLog("ANALYSIS", "🎮 Handle найден!", {
            Position = tostring(handle.Position),
            Size = tostring(handle.Size),
            Material = tostring(handle.Material)
        })
    end
    
    -- Анализ содержимого
    for _, child in pairs(tool:GetChildren()) do
        detectiveLog("ANALYSIS", string.format("📦 Содержимое Tool: %s (%s)", child.Name, child.ClassName))
        
        if child:IsA("Model") then
            detectiveLog("ANALYSIS", "🎯 МОДЕЛЬ ВНУТРИ TOOL!", {
                ModelName = child.Name,
                Children = #child:GetChildren()
            })
            
            -- Сравниваем с источниками
            for sourcePath, sourceData in pairs(DetectiveData.modelSources) do
                if sourceData.object.Name == child.Name then
                    detectiveLog("SOLVED", "✅ НАЙДЕНО СООТВЕТСТВИЕ С ИСТОЧНИКОМ!", {
                        ToolModel = child.Name,
                        SourcePath = sourcePath,
                        SourceLocation = sourceData.location
                    })
                end
            end
        end
    end
end

-- 📊 ГЕНЕРАЦИЯ ДЕТЕКТИВНОГО ОТЧЕТА
local function generateDetectiveReport()
    detectiveLog("CRITICAL", "📊 === ДЕТЕКТИВНЫЙ ОТЧЕТ ===")
    
    -- Источники моделей
    detectiveLog("SOURCE", string.format("📦 Найдено %d источников моделей:", #DetectiveData.modelSources))
    for path, data in pairs(DetectiveData.modelSources) do
        detectiveLog("SOURCE", string.format("  • %s (%s)", data.object.Name, data.location))
    end
    
    -- Активные скрипты
    detectiveLog("SCRIPT", string.format("📜 Найдено %d подозрительных скриптов:", #DetectiveData.activeScripts))
    for path, data in pairs(DetectiveData.activeScripts) do
        detectiveLog("SCRIPT", string.format("  • %s", data.name))
    end
    
    -- Цепочка создания
    detectiveLog("CREATION", string.format("🏗️ Отслежено %d событий создания:", #DetectiveData.creationChain))
    for path, data in pairs(DetectiveData.creationChain) do
        detectiveLog("CREATION", string.format("  • %s в %s", data.object.Name, data.location))
    end
    
    detectiveLog("CRITICAL", "🕵️ ДЕТЕКТИВНОЕ РАССЛЕДОВАНИЕ ЗАВЕРШЕНО!")
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ ДЕТЕКТИВНОГО АНАЛИЗА
local function startDetectiveInvestigation()
    detectiveLog("DETECTIVE", "🚀 ЗАПУСК ДЕТЕКТИВНОГО РАССЛЕДОВАНИЯ")
    detectiveLog("DETECTIVE", "🎯 Цель: Найти ОТКУДА и КАК создается модель питомца")
    
    -- Фаза 1: Сканирование источников
    scanAllModelSources()
    
    -- Фаза 2: Анализ скриптов
    analyzeActiveScripts()
    
    -- Фаза 3: Мониторинг событий
    local workspaceConnection = monitorCreationEvents()
    
    -- Основной цикл расследования
    local startTime = tick()
    local mainConnection
    mainConnection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        
        if elapsed > CONFIG.MONITOR_DURATION then
            detectiveLog("DETECTIVE", "⏰ Расследование завершено по таймауту")
            mainConnection:Disconnect()
            if workspaceConnection then workspaceConnection:Disconnect() end
            generateDetectiveReport()
        end
    end)
    
    detectiveLog("DETECTIVE", "🕵️ ДЕТЕКТИВНОЕ РАССЛЕДОВАНИЕ АКТИВНО!")
    detectiveLog("DETECTIVE", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ НАЧАЛА РАССЛЕДОВАНИЯ!")
end

-- Создаем GUI
local function createDetectiveGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeepModelOriginDetectiveGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 150)
    frame.Position = UDim2.new(1, -370, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.05, 0.05)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.8, 0.1, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🕵️ MODEL ORIGIN DETECTIVE"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 50)
    startBtn.Position = UDim2.new(0, 10, 0, 50)
    startBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🚀 НАЧАТЬ РАССЛЕДОВАНИЕ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 110)
    status.BackgroundTransparency = 1
    status.Text = "Готов к расследованию.\nОткройте яйцо после запуска."
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🕵️ Расследование активно!\nОткройте яйцо сейчас!"
        status.TextColor3 = Color3.new(1, 0.2, 0.2)
        startBtn.Text = "✅ РАССЛЕДОВАНИЕ АКТИВНО"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startDetectiveInvestigation()
    end)
end

-- Запускаем
local consoleTextLabel = createDetectiveConsole()
createDetectiveGUI()

detectiveLog("DETECTIVE", "✅ DeepModelOriginDetective готов!")
detectiveLog("DETECTIVE", "🕵️ Детективное расследование происхождения модели")
detectiveLog("DETECTIVE", "🚀 Нажмите 'НАЧАТЬ РАССЛЕДОВАНИЕ' и откройте яйцо!")
