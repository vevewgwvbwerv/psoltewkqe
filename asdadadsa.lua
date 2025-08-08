-- FocusedEggToHandTracker.lua
-- ФОКУСИРОВАННЫЙ ТРЕКЕР: Отслеживает ТОЛЬКО нужные события
-- 1. EggExplode - взрыв яйца
-- 2. Временная модель питомца (dog/bunny/golden lab) в workspace
-- 3. Tool питомца в руке игрока

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🎯 === FOCUSED EGG TO HAND TRACKER ===")
print("🥚 Отслеживает: EggExplode → Временная модель → Tool в руке")
print("=" .. string.rep("=", 60))

-- 📊 ТРЕКИНГ ДАННЫХ
local TrackingData = {
    eggExplodeTime = nil,
    tempModelTime = nil,
    toolInHandTime = nil,
    tempModelName = nil,
    toolName = nil,
    isTracking = false
}

-- 🖥️ КОНСОЛЬ
local TrackerConsole = nil
local ConsoleLines = {}
local MaxLines = 50

-- Создание консоли
local function createTrackerConsole()
    if TrackerConsole then TrackerConsole:Destroy() end
    
    TrackerConsole = Instance.new("ScreenGui")
    TrackerConsole.Name = "FocusedEggToHandTrackerConsole"
    TrackerConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 400)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.02, 0.1)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.2, 0.8, 0.2)
    frame.Parent = TrackerConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.1, 0.8, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🎯 FOCUSED EGG TO HAND TRACKER"
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
    textLabel.Text = "🎯 Фокусированный трекер готов..."
    textLabel.TextColor3 = Color3.new(1, 0.9, 0.9)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования
local function trackerLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local prefixes = {
        TRACKER = "🎯", EGG = "🥚", MODEL = "🐕", TOOL = "🎮", 
        SUCCESS = "✅", ERROR = "❌", INFO = "ℹ️", CRITICAL = "🔥"
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
    if TrackerConsole then
        local textLabel = TrackerConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 🥚 МОНИТОРИНГ EGGEXPLODE
local function monitorEggExplode()
    trackerLog("EGG", "🥚 Мониторинг EggExplode...")
    
    local eggConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj.Name == "EggExplode" then
            TrackingData.eggExplodeTime = tick()
            trackerLog("EGG", "🥚 EGGEXPLODE ОБНАРУЖЕН!", {
                Time = string.format("%.3f", TrackingData.eggExplodeTime),
                Position = obj.Parent and tostring(obj.Parent.Position) or "NIL",
                Parent = obj.Parent and obj.Parent.Name or "NIL"
            })
        end
    end)
    
    return eggConnection
end

-- 🐕 МОНИТОРИНГ ВРЕМЕННОЙ МОДЕЛИ ПИТОМЦА
local function monitorTempPetModel()
    trackerLog("MODEL", "🐕 Мониторинг временной модели питомца...")
    
    local modelConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            -- Проверяем точные имена питомцев
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" then
                
                TrackingData.tempModelTime = tick()
                TrackingData.tempModelName = obj.Name
                
                local timeSinceEgg = TrackingData.eggExplodeTime and 
                    (TrackingData.tempModelTime - TrackingData.eggExplodeTime) or 0
                
                trackerLog("MODEL", "🐕 ВРЕМЕННАЯ МОДЕЛЬ ПИТОМЦА ОБНАРУЖЕНА!", {
                    Name = obj.Name,
                    Time = string.format("%.3f", TrackingData.tempModelTime),
                    TimeSinceEgg = string.format("%.3f сек", timeSinceEgg),
                    Parent = obj.Parent and obj.Parent.Name or "NIL",
                    Position = obj.PrimaryPart and tostring(obj.PrimaryPart.Position) or "NIL",
                    Children = #obj:GetChildren()
                })
                
                -- Анализ структуры модели
                local structure = {
                    BaseParts = 0,
                    MeshParts = 0,
                    Motor6Ds = 0,
                    Scripts = 0
                }
                
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("BasePart") then
                        structure.BaseParts = structure.BaseParts + 1
                    elseif child:IsA("MeshPart") then
                        structure.MeshParts = structure.MeshParts + 1
                    elseif child:IsA("Motor6D") then
                        structure.Motor6Ds = structure.Motor6Ds + 1
                    elseif child:IsA("Script") or child:IsA("LocalScript") then
                        structure.Scripts = structure.Scripts + 1
                    end
                end
                
                trackerLog("MODEL", "📊 Структура временной модели:", structure)
            end
        end
    end)
    
    return modelConnection
end

-- 🎮 МОНИТОРИНГ TOOL В РУКЕ
local function monitorToolInHand()
    trackerLog("TOOL", "🎮 Мониторинг Tool в руке...")
    
    local character = player.Character
    if not character then
        trackerLog("ERROR", "❌ Character не найден")
        return nil
    end
    
    local toolConnection = character.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            local name = obj.Name:lower()
            -- Проверяем, содержит ли имя Tool название питомца
            if name:find("dog") or name:find("bunny") or name:find("lab") or 
               name:find("cat") or name:find("rabbit") or name:find("puppy") then
                
                TrackingData.toolInHandTime = tick()
                TrackingData.toolName = obj.Name
                
                local timeSinceEgg = TrackingData.eggExplodeTime and 
                    (TrackingData.toolInHandTime - TrackingData.eggExplodeTime) or 0
                local timeSinceModel = TrackingData.tempModelTime and 
                    (TrackingData.toolInHandTime - TrackingData.tempModelTime) or 0
                
                trackerLog("TOOL", "🎮 TOOL ПИТОМЦА В РУКЕ ОБНАРУЖЕН!", {
                    Name = obj.Name,
                    Time = string.format("%.3f", TrackingData.toolInHandTime),
                    TimeSinceEgg = string.format("%.3f сек", timeSinceEgg),
                    TimeSinceModel = string.format("%.3f сек", timeSinceModel),
                    Children = #obj:GetChildren()
                })
                
                -- Анализ содержимого Tool
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    trackerLog("TOOL", "🎮 Handle найден!", {
                        Position = tostring(handle.Position),
                        Size = tostring(handle.Size),
                        Material = tostring(handle.Material)
                    })
                end
                
                for _, child in pairs(obj:GetChildren()) do
                    trackerLog("TOOL", string.format("📦 Содержимое Tool: %s (%s)", child.Name, child.ClassName))
                end
                
                -- Генерируем итоговый отчет
                generateFinalReport()
            end
        end
    end)
    
    return toolConnection
end

-- 📊 ГЕНЕРАЦИЯ ИТОГОВОГО ОТЧЕТА
local function generateFinalReport()
    trackerLog("CRITICAL", "📊 === ИТОГОВЫЙ ОТЧЕТ ТРЕКИНГА ===")
    
    if TrackingData.eggExplodeTime then
        trackerLog("SUCCESS", string.format("✅ ФАЗА 1: EggExplode (%.3f сек)", TrackingData.eggExplodeTime))
    else
        trackerLog("ERROR", "❌ ФАЗА 1: EggExplode НЕ ОБНАРУЖЕН")
    end
    
    if TrackingData.tempModelTime and TrackingData.tempModelName then
        local delay1 = TrackingData.eggExplodeTime and 
            (TrackingData.tempModelTime - TrackingData.eggExplodeTime) or 0
        trackerLog("SUCCESS", string.format("✅ ФАЗА 2: Временная модель '%s' (+%.3f сек)", 
            TrackingData.tempModelName, delay1))
    else
        trackerLog("ERROR", "❌ ФАЗА 2: Временная модель НЕ ОБНАРУЖЕНА")
    end
    
    if TrackingData.toolInHandTime and TrackingData.toolName then
        local delay2 = TrackingData.tempModelTime and 
            (TrackingData.toolInHandTime - TrackingData.tempModelTime) or 0
        trackerLog("SUCCESS", string.format("✅ ФАЗА 3: Tool в руке '%s' (+%.3f сек)", 
            TrackingData.toolName, delay2))
    else
        trackerLog("ERROR", "❌ ФАЗА 3: Tool в руке НЕ ОБНАРУЖЕН")
    end
    
    local totalTime = (TrackingData.toolInHandTime and TrackingData.eggExplodeTime) and 
        (TrackingData.toolInHandTime - TrackingData.eggExplodeTime) or 0
    
    if totalTime > 0 then
        trackerLog("CRITICAL", string.format("⏱️ ОБЩЕЕ ВРЕМЯ: %.3f секунд", totalTime))
        trackerLog("CRITICAL", "🎯 ВСЕ ФАЗЫ УСПЕШНО ОТСЛЕЖЕНЫ!")
    else
        trackerLog("ERROR", "❌ НЕ ВСЕ ФАЗЫ БЫЛИ ОБНАРУЖЕНЫ")
    end
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ ТРЕКИНГА
local function startFocusedTracking()
    trackerLog("TRACKER", "🚀 ЗАПУСК ФОКУСИРОВАННОГО ТРЕКИНГА")
    trackerLog("TRACKER", "🎯 Отслеживаем: EggExplode → Модель → Tool")
    
    TrackingData.isTracking = true
    
    -- Запускаем все мониторы
    local eggConnection = monitorEggExplode()
    local modelConnection = monitorTempPetModel()
    local toolConnection = monitorToolInHand()
    
    trackerLog("TRACKER", "✅ Все мониторы активны!")
    trackerLog("TRACKER", "🥚 ОТКРОЙТЕ ЯЙЦО СЕЙЧАС!")
    
    -- Автоостановка через 2 минуты
    wait(120)
    
    if eggConnection then eggConnection:Disconnect() end
    if modelConnection then modelConnection:Disconnect() end
    if toolConnection then toolConnection:Disconnect() end
    
    trackerLog("TRACKER", "⏰ Трекинг завершен по таймауту")
    generateFinalReport()
end

-- Создаем GUI
local function createTrackerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FocusedEggToHandTrackerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(1, -320, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.05, 0.1, 0.05)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.1, 0.8, 0.1)
    title.BorderSizePixel = 0
    title.Text = "🎯 FOCUSED TRACKER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🚀 НАЧАТЬ ТРЕКИНГ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов отслеживать яйцо"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🎯 Трекинг активен!"
        status.TextColor3 = Color3.new(0.2, 1, 0.2)
        startBtn.Text = "✅ ТРЕКИНГ АКТИВЕН"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startFocusedTracking()
    end)
end

-- Запускаем
local consoleTextLabel = createTrackerConsole()
createTrackerGUI()

trackerLog("TRACKER", "✅ FocusedEggToHandTracker готов!")
trackerLog("TRACKER", "🎯 Фокусированное отслеживание яйца → модель → Tool")
trackerLog("TRACKER", "🚀 Нажмите 'НАЧАТЬ ТРЕКИНГ' и откройте яйцо!")
