-- 🔬 EGG ANIMATION SOURCE TRACKER
-- Исследует ОТКУДА и КАК игра создает временную анимированную модель питомца
-- Отслеживает все события, скрипты, источники анимации во время взрыва яйца

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 📊 КОНФИГУРАЦИЯ
local CONFIG = {
    SEARCH_RADIUS = 300,
    MONITOR_DURATION = 45,
    DEEP_SCAN_INTERVAL = 0.1
}

-- 🖥️ СИСТЕМА ОТДЕЛЬНОЙ КОНСОЛИ
local ConsoleGUI = nil
local ConsoleFrame = nil
local ConsoleScrollFrame = nil
local ConsoleTextLabel = nil
local ConsoleLines = {}
local MaxConsoleLines = 100

-- 📋 СОСТОЯНИЕ ОТСЛЕЖИВАНИЯ
local TrackingState = {
    isActive = false,
    eggExplodeDetected = false,
    startTime = 0,
    beforeSnapshot = {},
    afterSnapshot = {},
    detectedEvents = {},
    foundScripts = {},
    animationSources = {}
}

-- Функция создания отдельной консоли
local function createResearchConsole()
    if ConsoleGUI then
        ConsoleGUI:Destroy()
    end
    
    ConsoleGUI = Instance.new("ScreenGui")
    ConsoleGUI.Name = "EggAnimationSourceTrackerConsole"
    ConsoleGUI.Parent = player:WaitForChild("PlayerGui")
    
    -- Основной фрейм консоли
    ConsoleFrame = Instance.new("Frame")
    ConsoleFrame.Size = UDim2.new(0, 700, 0, 500)
    ConsoleFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    ConsoleFrame.BorderSizePixel = 2
    ConsoleFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    ConsoleFrame.Parent = ConsoleGUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = ConsoleFrame
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔬 EGG ANIMATION SOURCE TRACKER - ИССЛЕДОВАТЕЛЬСКАЯ КОНСОЛЬ"
    titleLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = ConsoleFrame
    
    -- Панель кнопок
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.Position = UDim2.new(0, 0, 0, 45)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = ConsoleFrame
    
    -- Кнопка запуска
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0, 150, 0, 30)
    startButton.Position = UDim2.new(0, 10, 0, 5)
    startButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    startButton.Text = "🚀 НАЧАТЬ ИССЛЕДОВАНИЕ"
    startButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    startButton.TextScaled = true
    startButton.Font = Enum.Font.SourceSansBold
    startButton.Parent = buttonFrame
    
    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 5)
    startCorner.Parent = startButton
    
    -- Кнопка очистки
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0, 100, 0, 30)
    clearButton.Position = UDim2.new(0, 170, 0, 5)
    clearButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    clearButton.Text = "🗑️ ОЧИСТИТЬ"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.Parent = buttonFrame
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 5)
    clearCorner.Parent = clearButton
    
    -- Кнопка сводки
    local summaryButton = Instance.new("TextButton")
    summaryButton.Size = UDim2.new(0, 120, 0, 30)
    summaryButton.Position = UDim2.new(0, 280, 0, 5)
    summaryButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    summaryButton.Text = "📊 СВОДКА"
    summaryButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    summaryButton.TextScaled = true
    summaryButton.Font = Enum.Font.SourceSansBold
    summaryButton.Parent = buttonFrame
    
    local summaryCorner = Instance.new("UICorner")
    summaryCorner.CornerRadius = UDim.new(0, 5)
    summaryCorner.Parent = summaryButton
    
    -- Скролл фрейм для консоли
    ConsoleScrollFrame = Instance.new("ScrollingFrame")
    ConsoleScrollFrame.Size = UDim2.new(1, -20, 1, -100)
    ConsoleScrollFrame.Position = UDim2.new(0, 10, 0, 90)
    ConsoleScrollFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 8)
    ConsoleScrollFrame.BorderSizePixel = 1
    ConsoleScrollFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    ConsoleScrollFrame.ScrollBarThickness = 12
    ConsoleScrollFrame.Parent = ConsoleFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 5)
    scrollCorner.Parent = ConsoleScrollFrame
    
    -- Текстовая метка для консоли
    ConsoleTextLabel = Instance.new("TextLabel")
    ConsoleTextLabel.Size = UDim2.new(1, -10, 1, 0)
    ConsoleTextLabel.Position = UDim2.new(0, 5, 0, 0)
    ConsoleTextLabel.BackgroundTransparency = 1
    ConsoleTextLabel.Text = "🔬 Исследовательская консоль готова.\\n📋 Нажмите 'НАЧАТЬ ИССЛЕДОВАНИЕ' для запуска глубокого анализа источников анимации."
    ConsoleTextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ConsoleTextLabel.TextSize = 11
    ConsoleTextLabel.Font = Enum.Font.SourceSans
    ConsoleTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    ConsoleTextLabel.TextYAlignment = Enum.TextYAlignment.Top
    ConsoleTextLabel.TextWrapped = true
    ConsoleTextLabel.Parent = ConsoleScrollFrame
    
    return startButton, clearButton, summaryButton
end

-- Функция добавления строки в консоль
local function addResearchLog(level, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local prefixes = {
        RESEARCH = "🔬", EVENT = "⚡", SCRIPT = "📜", ANIMATION = "🎬",
        CREATION = "⚙️", SOURCE = "🎯", DISCOVERY = "💡", WARNING = "⚠️"
    }
    
    local logLine = string.format("[%s] %s %s", timestamp, prefixes[level] or "ℹ️", message)
    
    if data and next(data) then
        for key, value in pairs(data) do
            logLine = logLine .. string.format("\\n    %s: %s", key, tostring(value))
        end
    end
    
    table.insert(ConsoleLines, logLine)
    
    -- Ограничиваем количество строк
    if #ConsoleLines > MaxConsoleLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Обновляем текст консоли
    if ConsoleTextLabel then
        ConsoleTextLabel.Text = table.concat(ConsoleLines, "\\n")
        
        -- Автоскролл вниз
        spawn(function()
            wait(0.1)
            ConsoleScrollFrame.CanvasPosition = Vector2.new(0, ConsoleTextLabel.TextBounds.Y)
        end)
    end
end

-- 🔍 ФУНКЦИЯ СОЗДАНИЯ СНИМКА СОСТОЯНИЯ
local function createStateSnapshot(name)
    local snapshot = {
        name = name,
        timestamp = tick(),
        workspace = {},
        replicatedStorage = {},
        scripts = {},
        events = {}
    }
    
    -- Снимок Workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            snapshot.workspace[obj.Name] = {
                className = obj.ClassName,
                childCount = #obj:GetChildren()
            }
        end
    end
    
    -- Снимок ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        snapshot.replicatedStorage[obj.Name] = {
            className = obj.ClassName,
            childCount = #obj:GetChildren()
        }
    end
    
    -- Поиск скриптов
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            table.insert(snapshot.scripts, {
                name = obj.Name,
                className = obj.ClassName,
                parent = obj.Parent and obj.Parent.Name or "nil"
            })
        end
    end
    
    return snapshot
end

-- 📊 ФУНКЦИЯ СРАВНЕНИЯ СНИМКОВ
local function compareSnapshots(before, after)
    local differences = {
        newWorkspaceObjects = {},
        newReplicatedObjects = {},
        newScripts = {},
        modifiedObjects = {}
    }
    
    -- Сравнение Workspace
    for name, data in pairs(after.workspace) do
        if not before.workspace[name] then
            table.insert(differences.newWorkspaceObjects, {name = name, data = data})
        elseif before.workspace[name].childCount ~= data.childCount then
            table.insert(differences.modifiedObjects, {name = name, location = "Workspace", data = data})
        end
    end
    
    -- Сравнение ReplicatedStorage
    for name, data in pairs(after.replicatedStorage) do
        if not before.replicatedStorage[name] then
            table.insert(differences.newReplicatedObjects, {name = name, data = data})
        end
    end
    
    -- Сравнение скриптов
    for _, script in pairs(after.scripts) do
        local found = false
        for _, beforeScript in pairs(before.scripts) do
            if beforeScript.name == script.name and beforeScript.parent == script.parent then
                found = true
                break
            end
        end
        if not found then
            table.insert(differences.newScripts, script)
        end
    end
    
    return differences
end

-- 🎬 ФУНКЦИЯ АНАЛИЗА АНИМАЦИИ
local function analyzeAnimationSources(model)
    local animationData = {
        animators = {},
        animationTracks = {},
        motor6ds = {},
        tweens = {},
        scripts = {}
    }
    
    -- Поиск Animator и AnimationTrack
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Animator") then
            table.insert(animationData.animators, {
                name = obj.Name,
                parent = obj.Parent and obj.Parent.Name or "nil"
            })
            
            -- Получаем активные треки анимации
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                table.insert(animationData.animationTracks, {
                    animationId = track.Animation and track.Animation.AnimationId or "Unknown",
                    isPlaying = track.IsPlaying,
                    speed = track.Speed,
                    weight = track.Weight
                })
            end
        elseif obj:IsA("Motor6D") then
            table.insert(animationData.motor6ds, {
                name = obj.Name,
                c0 = tostring(obj.C0),
                c1 = tostring(obj.C1),
                part0 = obj.Part0 and obj.Part0.Name or "nil",
                part1 = obj.Part1 and obj.Part1.Name or "nil"
            })
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            table.insert(animationData.scripts, {
                name = obj.Name,
                className = obj.ClassName,
                parent = obj.Parent and obj.Parent.Name or "nil"
            })
        end
    end
    
    return animationData
end

-- 🔍 ФУНКЦИЯ ПОИСКА EGGEXPLODE
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
        end
    end
    
    return false, nil, nil
end

-- 🚀 ОСНОВНАЯ ФУНКЦИЯ ИССЛЕДОВАНИЯ
local function startDeepResearch()
    addResearchLog("RESEARCH", "🚀 ЗАПУСК ГЛУБОКОГО ИССЛЕДОВАНИЯ ИСТОЧНИКОВ АНИМАЦИИ")
    addResearchLog("RESEARCH", "🎯 Цель: Найти КАК и ОТКУДА создается временная анимированная модель")
    
    TrackingState.isActive = true
    TrackingState.startTime = tick()
    
    -- Создаем снимок ДО взрыва яйца
    addResearchLog("RESEARCH", "📸 Создание снимка состояния ДО взрыва яйца...")
    TrackingState.beforeSnapshot = createStateSnapshot("BEFORE_EGG_EXPLODE")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not TrackingState.isActive then
            connection:Disconnect()
            return
        end
        
        local elapsed = tick() - TrackingState.startTime
        
        -- Фаза 1: Ожидание EggExplode
        if not TrackingState.eggExplodeDetected then
            local found, eggObj, location = checkForEggExplode()
            if found then
                TrackingState.eggExplodeDetected = true
                
                addResearchLog("EVENT", "⚡ EGGEXPLODE ОБНАРУЖЕН В " .. location .. "!")
                addResearchLog("RESEARCH", "📸 Создание снимка состояния ПОСЛЕ взрыва...")
                
                -- Создаем снимок ПОСЛЕ взрыва
                wait(0.5) -- Небольшая задержка для стабилизации
                TrackingState.afterSnapshot = createStateSnapshot("AFTER_EGG_EXPLODE")
                
                -- Сравниваем снимки
                local differences = compareSnapshots(TrackingState.beforeSnapshot, TrackingState.afterSnapshot)
                
                addResearchLog("DISCOVERY", "💡 АНАЛИЗ ИЗМЕНЕНИЙ ПОСЛЕ ВЗРЫВА ЯЙЦА:")
                
                if #differences.newWorkspaceObjects > 0 then
                    addResearchLog("CREATION", "⚙️ НОВЫЕ ОБЪЕКТЫ В WORKSPACE:", {
                        count = #differences.newWorkspaceObjects
                    })
                    for _, obj in pairs(differences.newWorkspaceObjects) do
                        addResearchLog("CREATION", "  📦 " .. obj.name, obj.data)
                    end
                end
                
                if #differences.newReplicatedObjects > 0 then
                    addResearchLog("CREATION", "⚙️ НОВЫЕ ОБЪЕКТЫ В REPLICATEDSTORAGE:", {
                        count = #differences.newReplicatedObjects
                    })
                    for _, obj in pairs(differences.newReplicatedObjects) do
                        addResearchLog("CREATION", "  📦 " .. obj.name, obj.data)
                    end
                end
                
                if #differences.newScripts > 0 then
                    addResearchLog("SCRIPT", "📜 НОВЫЕ СКРИПТЫ ОБНАРУЖЕНЫ:", {
                        count = #differences.newScripts
                    })
                    for _, script in pairs(differences.newScripts) do
                        addResearchLog("SCRIPT", "  📜 " .. script.name, script)
                    end
                end
                
                -- Начинаем поиск анимированных моделей
                addResearchLog("RESEARCH", "🔍 Начинаем поиск временных анимированных моделей...")
            end
        else
            -- Фаза 2: Поиск и анализ анимированных моделей
            if elapsed > CONFIG.MONITOR_DURATION then
                addResearchLog("RESEARCH", "⏰ Исследование завершено по таймауту")
                TrackingState.isActive = false
                return
            end
            
            -- Поиск моделей питомцев
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("dog") or 
                   obj.Name:lower():find("bunny") or obj.Name:lower():find("golden") then
                    
                    if not TrackingState.animationSources[obj] then
                        TrackingState.animationSources[obj] = true
                        
                        addResearchLog("DISCOVERY", "💡 НАЙДЕНА АНИМИРОВАННАЯ МОДЕЛЬ: " .. obj.Name)
                        
                        -- Глубокий анализ анимации
                        local animationData = analyzeAnimationSources(obj)
                        
                        addResearchLog("ANIMATION", "🎬 АНАЛИЗ ИСТОЧНИКОВ АНИМАЦИИ:")
                        addResearchLog("ANIMATION", "  Animators: " .. #animationData.animators)
                        addResearchLog("ANIMATION", "  Animation Tracks: " .. #animationData.animationTracks)
                        addResearchLog("ANIMATION", "  Motor6Ds: " .. #animationData.motor6ds)
                        addResearchLog("ANIMATION", "  Scripts: " .. #animationData.scripts)
                        
                        if #animationData.animationTracks > 0 then
                            for _, track in pairs(animationData.animationTracks) do
                                addResearchLog("ANIMATION", "  🎬 Animation Track:", track)
                            end
                        end
                        
                        if #animationData.scripts > 0 then
                            for _, script in pairs(animationData.scripts) do
                                addResearchLog("SCRIPT", "  📜 Script in model:", script)
                            end
                        end
                        
                        -- Отслеживаем время жизни
                        spawn(function()
                            local startTime = tick()
                            local modelName = obj.Name
                            
                            while obj and obj.Parent do
                                wait(0.2)
                            end
                            
                            local lifetime = tick() - startTime
                            addResearchLog("DISCOVERY", string.format("⏱️ %s исчез через %.2f сек", modelName, lifetime))
                        end)
                    end
                end
            end
        end
    end)
    
    addResearchLog("RESEARCH", "🔍 Глубокое исследование активно. Откройте яйцо для анализа!")
end

-- 📊 ФУНКЦИЯ СОЗДАНИЯ СВОДКИ
local function generateSummary()
    addResearchLog("RESEARCH", "📊 === СВОДКА ИССЛЕДОВАНИЯ ===")
    addResearchLog("RESEARCH", "🎯 Найдено источников анимации: " .. #TrackingState.animationSources)
    addResearchLog("RESEARCH", "📜 Обнаружено скриптов: " .. #TrackingState.foundScripts)
    addResearchLog("RESEARCH", "⚡ Зафиксировано событий: " .. #TrackingState.detectedEvents)
    
    if TrackingState.beforeSnapshot and TrackingState.afterSnapshot then
        local differences = compareSnapshots(TrackingState.beforeSnapshot, TrackingState.afterSnapshot)
        addResearchLog("RESEARCH", "📦 Новых объектов в Workspace: " .. #differences.newWorkspaceObjects)
        addResearchLog("RESEARCH", "📦 Новых объектов в ReplicatedStorage: " .. #differences.newReplicatedObjects)
        addResearchLog("RESEARCH", "📜 Новых скриптов: " .. #differences.newScripts)
    end
    
    addResearchLog("RESEARCH", "📋 === КОНЕЦ СВОДКИ ===")
end

-- 🖥️ СОЗДАНИЕ GUI И ЗАПУСК
local function initializeResearchTracker()
    local startButton, clearButton, summaryButton = createResearchConsole()
    
    startButton.MouseButton1Click:Connect(function()
        if not TrackingState.isActive then
            startButton.Text = "⏳ ИССЛЕДОВАНИЕ АКТИВНО..."
            startButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            startDeepResearch()
        end
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        ConsoleLines = {}
        TrackingState = {
            isActive = false,
            eggExplodeDetected = false,
            startTime = 0,
            beforeSnapshot = {},
            afterSnapshot = {},
            detectedEvents = {},
            foundScripts = {},
            animationSources = {}
        }
        if ConsoleTextLabel then
            ConsoleTextLabel.Text = "🔬 Консоль очищена. Готов к новому исследованию."
        end
    end)
    
    summaryButton.MouseButton1Click:Connect(function()
        generateSummary()
    end)
    
    addResearchLog("RESEARCH", "✅ EGG ANIMATION SOURCE TRACKER ГОТОВ!")
    addResearchLog("RESEARCH", "🔬 Исследует ОТКУДА берется анимация временной модели питомца")
    addResearchLog("RESEARCH", "📋 Отслеживает события, скрипты, источники анимации")
    addResearchLog("RESEARCH", "🎯 Нажмите 'НАЧАТЬ ИССЛЕДОВАНИЕ' для запуска")
end

-- 🚀 ЗАПУСК
initializeResearchTracker()
