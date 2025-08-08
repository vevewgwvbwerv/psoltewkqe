-- SimpleCreationWatcher.lua
-- ПРОСТОЙ НАБЛЮДАТЕЛЬ: Отслеживает ВСЕ новые объекты без сложных хуков
-- Фокус на ТОЧНОМ моменте появления модели питомца

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("👁️ === SIMPLE CREATION WATCHER ===")
print("🎯 Цель: Отследить появление модели питомца БЕЗ хуков")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ НАБЛЮДАТЕЛЯ
local WatcherData = {
    targetModel = nil,
    allNewObjects = {},
    petModels = {},
    startTime = nil,
    isWatching = false
}

-- 🖥️ КОНСОЛЬ
local WatcherConsole = nil
local ConsoleLines = {}
local MaxLines = 150

-- Создание консоли
local function createWatcherConsole()
    if WatcherConsole then WatcherConsole:Destroy() end
    
    WatcherConsole = Instance.new("ScreenGui")
    WatcherConsole.Name = "SimpleCreationWatcherConsole"
    WatcherConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 800, 0, 600)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.15)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.3, 0.3, 1)
    frame.Parent = WatcherConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.3, 0.3, 1)
    title.BorderSizePixel = 0
    title.Text = "👁️ SIMPLE CREATION WATCHER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.02, 0.02, 0.08)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "👁️ Простой наблюдатель готов..."
    textLabel.TextColor3 = Color3.new(0.9, 0.9, 1)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования
local function watcherLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local relativeTime = WatcherData.startTime and string.format("+%.3f", tick() - WatcherData.startTime) or "0.000"
    
    local prefixes = {
        WATCHER = "👁️", NEW = "🆕", PET = "🐕", ANALYSIS = "📊",
        FOUND = "🎯", CRITICAL = "🔥", SUCCESS = "✅", ERROR = "❌", 
        INFO = "ℹ️", DETAIL = "📝"
    }
    
    local logLine = string.format("[%s] (%s) %s %s", timestamp, relativeTime, prefixes[category] or "ℹ️", message)
    
    if data and next(data) then
        for key, value in pairs(data) do
            logLine = logLine .. string.format("\n      %s: %s", key, tostring(value))
        end
    end
    
    table.insert(ConsoleLines, logLine)
    
    if #ConsoleLines > MaxLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Обновляем консоль
    if WatcherConsole then
        local textLabel = WatcherConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 🔍 ПОИСК СУЩЕСТВУЮЩИХ ИСТОЧНИКОВ
local function findExistingSources()
    watcherLog("WATCHER", "🔍 Поиск существующих источников...")
    
    local sources = {}
    
    -- Поиск в ReplicatedStorage
    local function searchInService(service, serviceName)
        local found = 0
        for _, obj in pairs(service:GetDescendants()) do
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                if name == "dog" or name == "bunny" or name == "golden lab" or 
                   name == "cat" or name == "rabbit" or name == "puppy" then
                    
                    sources[obj:GetFullName()] = {
                        object = obj,
                        name = obj.Name,
                        location = serviceName,
                        children = #obj:GetChildren()
                    }
                    
                    found = found + 1
                    watcherLog("FOUND", string.format("🎯 Источник в %s: %s", serviceName, obj.Name), {
                        Path = obj:GetFullName(),
                        Children = #obj:GetChildren()
                    })
                end
            end
        end
        return found
    end
    
    local totalFound = 0
    totalFound = totalFound + searchInService(ReplicatedStorage, "ReplicatedStorage")
    totalFound = totalFound + searchInService(Workspace, "Workspace")
    
    watcherLog("WATCHER", string.format("📊 Всего найдено источников: %d", totalFound))
    return sources
end

-- 🆕 МОНИТОРИНГ НОВЫХ ОБЪЕКТОВ
local function monitorNewObjects()
    watcherLog("WATCHER", "🆕 Мониторинг новых объектов...")
    
    -- Мониторинг Workspace
    local workspaceConnection = Workspace.DescendantAdded:Connect(function(obj)
        local relativeTime = WatcherData.startTime and (tick() - WatcherData.startTime) or 0
        
        -- Записываем ВСЕ новые объекты
        WatcherData.allNewObjects[obj] = {
            time = tick(),
            relativeTime = relativeTime,
            name = obj.Name,
            className = obj.ClassName,
            parent = obj.Parent and obj.Parent.Name or "NIL"
        }
        
        -- Особое внимание к Model
        if obj:IsA("Model") then
            watcherLog("NEW", "🆕 НОВАЯ МОДЕЛЬ: " .. obj.Name, {
                ClassName = obj.ClassName,
                Parent = obj.Parent and obj.Parent.Name or "NIL",
                RelativeTime = string.format("%.3f сек", relativeTime)
            })
            
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" then
                
                WatcherData.targetModel = obj
                
                watcherLog("CRITICAL", "🔥 ПИТОМЕЦ ОБНАРУЖЕН: " .. obj.Name, {
                    Parent = obj.Parent and obj.Parent.Name or "NIL",
                    ParentPath = obj.Parent and obj.Parent:GetFullName() or "NIL",
                    RelativeTime = string.format("%.3f сек", relativeTime),
                    Children = #obj:GetChildren()
                })
                
                -- Глубокий анализ питомца
                analyzePetModel(obj)
                
                -- Поиск похожих источников
                findSimilarSources(obj)
            end
        end
        
        -- Особое внимание к Tool
        if obj:IsA("Tool") then
            local name = obj.Name:lower()
            if name:find("dog") or name:find("bunny") or name:find("lab") or 
               name:find("cat") or name:find("rabbit") or name:find("puppy") then
                
                watcherLog("PET", "🐕 TOOL ПИТОМЦА: " .. obj.Name, {
                    Parent = obj.Parent and obj.Parent.Name or "NIL",
                    RelativeTime = string.format("%.3f сек", relativeTime)
                })
            end
        end
    end)
    
    return workspaceConnection
end

-- 📊 АНАЛИЗ МОДЕЛИ ПИТОМЦА
local function analyzePetModel(model)
    watcherLog("ANALYSIS", "📊 АНАЛИЗ МОДЕЛИ ПИТОМЦА: " .. model.Name)
    
    -- Базовая информация
    local info = {
        Name = model.Name,
        ClassName = model.ClassName,
        Parent = model.Parent and model.Parent.Name or "NIL",
        ParentPath = model.Parent and model.Parent:GetFullName() or "NIL",
        Children = #model:GetChildren(),
        Descendants = #model:GetDescendants()
    }
    
    watcherLog("DETAIL", "📝 Базовая информация:", info)
    
    -- Структура модели
    local structure = {}
    for _, obj in pairs(model:GetDescendants()) do
        structure[obj.ClassName] = (structure[obj.ClassName] or 0) + 1
    end
    
    watcherLog("DETAIL", "📝 Структура модели:", structure)
    
    -- Анализ родителя
    local parent = model.Parent
    if parent then
        watcherLog("DETAIL", "📝 Информация о родителе:", {
            Name = parent.Name,
            ClassName = parent.ClassName,
            Path = parent:GetFullName(),
            Children = #parent:GetChildren()
        })
    end
end

-- 🔍 ПОИСК ПОХОЖИХ ИСТОЧНИКОВ
local function findSimilarSources(targetModel)
    watcherLog("ANALYSIS", "🔍 Поиск похожих источников для: " .. targetModel.Name)
    
    -- Поиск в ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower() == targetModel.Name:lower() then
            watcherLog("SUCCESS", "✅ НАЙДЕН ПОХОЖИЙ ИСТОЧНИК!", {
                Name = obj.Name,
                Path = obj:GetFullName(),
                Children = #obj:GetChildren(),
                TargetChildren = #targetModel:GetChildren(),
                Match = #obj:GetChildren() == #targetModel:GetChildren() and "ТОЧНОЕ" or "ЧАСТИЧНОЕ"
            })
            
            -- Сравнение структуры
            local sourceStructure = {}
            local targetStructure = {}
            
            for _, child in pairs(obj:GetDescendants()) do
                sourceStructure[child.ClassName] = (sourceStructure[child.ClassName] or 0) + 1
            end
            
            for _, child in pairs(targetModel:GetDescendants()) do
                targetStructure[child.ClassName] = (targetStructure[child.ClassName] or 0) + 1
            end
            
            local matches = 0
            local total = 0
            for className, count in pairs(targetStructure) do
                total = total + 1
                if sourceStructure[className] and sourceStructure[className] == count then
                    matches = matches + 1
                end
            end
            
            local similarity = total > 0 and (matches / total * 100) or 0
            
            watcherLog("SUCCESS", string.format("✅ СХОДСТВО СТРУКТУРЫ: %.1f%%", similarity), {
                Matches = matches,
                Total = total,
                Confidence = similarity > 90 and "ОЧЕНЬ ВЫСОКАЯ" or (similarity > 70 and "ВЫСОКАЯ" or "СРЕДНЯЯ")
            })
        end
    end
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ НАБЛЮДЕНИЯ
local function startSimpleWatching()
    watcherLog("WATCHER", "🚀 ЗАПУСК ПРОСТОГО НАБЛЮДЕНИЯ")
    watcherLog("WATCHER", "👁️ Отслеживание появления модели питомца")
    
    WatcherData.isWatching = true
    WatcherData.startTime = tick()
    
    -- Поиск существующих источников
    local sources = findExistingSources()
    
    -- Запуск мониторинга новых объектов
    local workspaceConnection = monitorNewObjects()
    
    watcherLog("WATCHER", "✅ Наблюдение активно!")
    watcherLog("WATCHER", "🥚 ОТКРОЙТЕ ЯЙЦО СЕЙЧАС!")
    
    -- Автоостановка через 2 минуты
    spawn(function()
        wait(120)
        if workspaceConnection then
            workspaceConnection:Disconnect()
        end
        WatcherData.isWatching = false
        watcherLog("WATCHER", "⏰ Наблюдение завершено по таймауту")
        
        -- Итоговая статистика
        watcherLog("INFO", string.format("📊 Всего отслежено объектов: %d", #WatcherData.allNewObjects))
    end)
end

-- Создаем GUI
local function createWatcherGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleCreationWatcherGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(1, -320, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.15)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.3, 0.3, 1)
    title.BorderSizePixel = 0
    title.Text = "👁️ SIMPLE WATCHER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 1)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "👁️ НАЧАТЬ НАБЛЮДЕНИЕ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов к простому наблюдению"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "👁️ Наблюдение активно!"
        status.TextColor3 = Color3.new(0.3, 0.3, 1)
        startBtn.Text = "✅ НАБЛЮДЕНИЕ АКТИВНО"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startSimpleWatching()
    end)
end

-- Запускаем
local consoleTextLabel = createWatcherConsole()
createWatcherGUI()

watcherLog("WATCHER", "✅ SimpleCreationWatcher готов!")
watcherLog("WATCHER", "👁️ Простое наблюдение за созданием модели питомца")
watcherLog("WATCHER", "🎯 БЕЗ сложных хуков - только DescendantAdded")
watcherLog("WATCHER", "🚀 Нажмите 'НАЧАТЬ НАБЛЮДЕНИЕ' и откройте яйцо!")
