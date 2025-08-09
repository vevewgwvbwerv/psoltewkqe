-- VisualsOnlyWatcher.lua
-- ФОКУС НА VISUALS: Отслеживает ТОЛЬКО появление питомца в workspace.Visuals
-- Игнорирует весь мусор (EggExplode и др.), фокус ТОЛЬКО на Visuals

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("👀 === VISUALS ONLY WATCHER ===")
print("🎯 Цель: Отследить ТОЛЬКО питомца в workspace.Visuals")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ НАБЛЮДАТЕЛЯ
local VisualsData = {
    visualsFolder = nil,
    petModel = nil,
    sources = {},
    startTime = nil,
    isWatching = false
}

-- 🖥️ КОНСОЛЬ
local VisualsConsole = nil
local ConsoleLines = {}
local MaxLines = 100

-- Создание консоли
local function createVisualsConsole()
    if VisualsConsole then VisualsConsole:Destroy() end
    
    VisualsConsole = Instance.new("ScreenGui")
    VisualsConsole.Name = "VisualsOnlyWatcherConsole"
    VisualsConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 750, 0, 550)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.02, 0.1)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(1, 0.2, 1)
    frame.Parent = VisualsConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(1, 0.2, 1)
    title.BorderSizePixel = 0
    title.Text = "👀 VISUALS ONLY WATCHER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.05, 0.01, 0.05)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "👀 Наблюдатель Visuals готов..."
    textLabel.TextColor3 = Color3.new(1, 0.9, 1)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования
local function visualsLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local relativeTime = VisualsData.startTime and string.format("+%.3f", tick() - VisualsData.startTime) or "0.000"
    
    local prefixes = {
        VISUALS = "👀", PET = "🐕", SOURCE = "📦", ANALYSIS = "📊",
        FOUND = "🎯", CRITICAL = "🔥", SUCCESS = "✅", ERROR = "❌", 
        INFO = "ℹ️", MATCH = "🎯"
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
    if VisualsConsole then
        local textLabel = VisualsConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 🔍 ПОИСК VISUALS ПАПКИ
local function findVisualsFolder()
    visualsLog("VISUALS", "🔍 Поиск папки Visuals...")
    
    local visuals = Workspace:FindFirstChild("Visuals")
    if visuals then
        VisualsData.visualsFolder = visuals
        visualsLog("SUCCESS", "✅ ПАПКА VISUALS НАЙДЕНА!", {
            Path = visuals:GetFullName(),
            Children = #visuals:GetChildren(),
            ClassName = visuals.ClassName
        })
        
        -- Показываем текущее содержимое Visuals
        if #visuals:GetChildren() > 0 then
            visualsLog("INFO", "ℹ️ Текущее содержимое Visuals:")
            for _, child in pairs(visuals:GetChildren()) do
                visualsLog("INFO", string.format("  • %s (%s)", child.Name, child.ClassName))
            end
        else
            visualsLog("INFO", "ℹ️ Папка Visuals пуста")
        end
        
        return visuals
    else
        visualsLog("ERROR", "❌ ПАПКА VISUALS НЕ НАЙДЕНА!")
        return nil
    end
end

-- 📦 ПОИСК ИСТОЧНИКОВ В REPLICATEDSTORAGE
local function findPetSources()
    visualsLog("SOURCE", "📦 Поиск источников питомцев в ReplicatedStorage...")
    
    local sources = {}
    local found = 0
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" or
               name == "goldenlab" or name:find("lab") then
                
                sources[obj.Name] = {
                    object = obj,
                    path = obj:GetFullName(),
                    children = #obj:GetChildren(),
                    descendants = #obj:GetDescendants()
                }
                
                found = found + 1
                visualsLog("FOUND", "🎯 ИСТОЧНИК НАЙДЕН: " .. obj.Name, {
                    Path = obj:GetFullName(),
                    Children = #obj:GetChildren(),
                    Descendants = #obj:GetDescendants()
                })
            end
        end
    end
    
    VisualsData.sources = sources
    visualsLog("SOURCE", string.format("📦 Всего найдено источников: %d", found))
    return sources
end

-- 🐕 МОНИТОРИНГ ТОЛЬКО VISUALS
local function monitorVisualsOnly()
    local visuals = VisualsData.visualsFolder
    if not visuals then
        visualsLog("ERROR", "❌ Нет папки Visuals для мониторинга!")
        return nil
    end
    
    visualsLog("VISUALS", "👀 МОНИТОРИНГ ТОЛЬКО VISUALS...")
    
    local visualsConnection = visuals.ChildAdded:Connect(function(obj)
        local relativeTime = VisualsData.startTime and (tick() - VisualsData.startTime) or 0
        
        visualsLog("PET", "🐕 НОВЫЙ ОБЪЕКТ В VISUALS: " .. obj.Name, {
            ClassName = obj.ClassName,
            RelativeTime = string.format("%.3f сек", relativeTime)
        })
        
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" or
               name == "goldenlab" or name:find("lab") then
                
                VisualsData.petModel = obj
                
                visualsLog("CRITICAL", "🔥 ПИТОМЕЦ В VISUALS ОБНАРУЖЕН: " .. obj.Name, {
                    ClassName = obj.ClassName,
                    RelativeTime = string.format("%.3f сек", relativeTime),
                    Children = #obj:GetChildren(),
                    Descendants = #obj:GetDescendants()
                })
                
                -- Анализ питомца
                analyzePetInVisuals(obj)
                
                -- Поиск источника
                findMatchingSource(obj)
                
                -- Отключаем мониторинг после находки
                visualsConnection:Disconnect()
                visualsLog("VISUALS", "✅ ПИТОМЕЦ НАЙДЕН - МОНИТОРИНГ ЗАВЕРШЕН!")
            end
        end
    end)
    
    return visualsConnection
end

-- 📊 АНАЛИЗ ПИТОМЦА В VISUALS
local function analyzePetInVisuals(pet)
    visualsLog("ANALYSIS", "📊 АНАЛИЗ ПИТОМЦА В VISUALS: " .. pet.Name)
    
    -- Базовая информация
    local info = {
        Name = pet.Name,
        ClassName = pet.ClassName,
        Parent = "Visuals",
        Children = #pet:GetChildren(),
        Descendants = #pet:GetDescendants(),
        PrimaryPart = pet.PrimaryPart and pet.PrimaryPart.Name or "NIL"
    }
    
    visualsLog("ANALYSIS", "📊 Базовая информация:", info)
    
    -- Структура
    local structure = {}
    for _, obj in pairs(pet:GetDescendants()) do
        structure[obj.ClassName] = (structure[obj.ClassName] or 0) + 1
    end
    
    visualsLog("ANALYSIS", "📊 Структура питомца:", structure)
    
    -- Позиция
    if pet.PrimaryPart then
        visualsLog("ANALYSIS", "📊 Позиция питомца:", {
            Position = tostring(pet.PrimaryPart.Position),
            Size = tostring(pet.PrimaryPart.Size)
        })
    end
end

-- 🎯 ПОИСК СООТВЕТСТВУЮЩЕГО ИСТОЧНИКА
local function findMatchingSource(pet)
    visualsLog("MATCH", "🎯 Поиск соответствующего источника для: " .. pet.Name)
    
    local bestMatch = nil
    local bestScore = 0
    
    for sourceName, sourceData in pairs(VisualsData.sources) do
        local score = 0
        local reasons = {}
        
        -- Точное совпадение имени
        if sourceName:lower() == pet.Name:lower() then
            score = score + 1000
            table.insert(reasons, "Точное имя")
        elseif sourceName:lower():find(pet.Name:lower()) or pet.Name:lower():find(sourceName:lower()) then
            score = score + 500
            table.insert(reasons, "Частичное имя")
        end
        
        -- Совпадение количества детей
        if sourceData.children == #pet:GetChildren() then
            score = score + 200
            table.insert(reasons, "Точные дети")
        elseif math.abs(sourceData.children - #pet:GetChildren()) <= 2 then
            score = score + 100
            table.insert(reasons, "Близкие дети")
        end
        
        -- Совпадение количества потомков
        if sourceData.descendants == #pet:GetDescendants() then
            score = score + 150
            table.insert(reasons, "Точные потомки")
        elseif math.abs(sourceData.descendants - #pet:GetDescendants()) <= 5 then
            score = score + 50
            table.insert(reasons, "Близкие потомки")
        end
        
        if score > bestScore then
            bestScore = score
            bestMatch = {
                source = sourceData,
                score = score,
                reasons = reasons
            }
        end
        
        if score > 0 then
            visualsLog("MATCH", string.format("🎯 Кандидат: %s (Score: %d)", sourceName, score), {
                Path = sourceData.path,
                Reasons = table.concat(reasons, ", "),
                Confidence = score > 1000 and "ОЧЕНЬ ВЫСОКАЯ" or (score > 500 and "ВЫСОКАЯ" or "СРЕДНЯЯ")
            })
        end
    end
    
    if bestMatch then
        visualsLog("SUCCESS", "✅ ЛУЧШИЙ ИСТОЧНИК НАЙДЕН!", {
            Source = bestMatch.source.object.Name,
            Path = bestMatch.source.path,
            Score = bestMatch.score,
            Confidence = bestMatch.score > 1000 and "ОЧЕНЬ ВЫСОКАЯ" or (bestMatch.score > 500 and "ВЫСОКАЯ" or "СРЕДНЯЯ"),
            Reasons = table.concat(bestMatch.reasons, ", ")
        })
        
        visualsLog("CRITICAL", "🔥 ВЫВОД: Питомец клонируется из " .. bestMatch.source.path)
    else
        visualsLog("ERROR", "❌ НЕ НАЙДЕН ПОДХОДЯЩИЙ ИСТОЧНИК")
    end
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ
local function startVisualsWatching()
    visualsLog("VISUALS", "🚀 ЗАПУСК НАБЛЮДЕНИЯ ЗА VISUALS")
    visualsLog("VISUALS", "👀 Фокус ТОЛЬКО на workspace.Visuals")
    
    VisualsData.isWatching = true
    VisualsData.startTime = tick()
    
    -- Поиск папки Visuals
    local visuals = findVisualsFolder()
    if not visuals then
        visualsLog("ERROR", "❌ Не удалось найти папку Visuals!")
        return
    end
    
    -- Поиск источников
    local sources = findPetSources()
    
    -- Мониторинг только Visuals
    local visualsConnection = monitorVisualsOnly()
    
    visualsLog("VISUALS", "✅ Наблюдение за Visuals активно!")
    visualsLog("VISUALS", "🥚 ОТКРОЙТЕ ЯЙЦО СЕЙЧАС!")
    
    -- Автоостановка через 2 минуты
    spawn(function()
        wait(120)
        if visualsConnection then
            visualsConnection:Disconnect()
        end
        VisualsData.isWatching = false
        visualsLog("VISUALS", "⏰ Наблюдение завершено по таймауту")
    end)
end

-- Создаем GUI
local function createVisualsGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VisualsOnlyWatcherGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(1, -320, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.02, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(1, 0.2, 1)
    title.BorderSizePixel = 0
    title.Text = "👀 VISUALS WATCHER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(1, 0.2, 1)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "👀 НАБЛЮДАТЬ VISUALS"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов к наблюдению Visuals"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "👀 Наблюдение активно!"
        status.TextColor3 = Color3.new(1, 0.2, 1)
        startBtn.Text = "✅ НАБЛЮДЕНИЕ АКТИВНО"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startVisualsWatching()
    end)
end

-- Запускаем
local consoleTextLabel = createVisualsConsole()
createVisualsGUI()

visualsLog("VISUALS", "✅ VisualsOnlyWatcher готов!")
visualsLog("VISUALS", "👀 Наблюдение ТОЛЬКО за workspace.Visuals")
visualsLog("VISUALS", "🎯 Игнорирует весь мусор (EggExplode и др.)")
visualsLog("VISUALS", "🚀 Нажмите 'НАБЛЮДАТЬ VISUALS' и откройте яйцо!")
