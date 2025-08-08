-- RealTimeCreationTracker.lua
-- ТРЕКЕР РЕАЛЬНОГО СОЗДАНИЯ: Отслеживает ИМЕННО момент создания модели питомца
-- Использует debug hooks и мониторинг Instance.new/Clone в реальном времени

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("⚡ === REAL TIME CREATION TRACKER ===")
print("🎯 Цель: Отследить РЕАЛЬНЫЙ момент создания модели питомца")
print("=" .. string.rep("=", 60))

-- 📊 ДАННЫЕ ТРЕКЕРА
local TrackerData = {
    targetModel = nil,
    creationEvents = {},
    scriptCalls = {},
    instanceCreations = {},
    isTracking = false,
    startTime = nil
}

-- 🖥️ БОЛЬШАЯ КОНСОЛЬ
local TrackerConsole = nil
local ConsoleLines = {}
local MaxLines = 200

-- Создание большой консоли
local function createTrackerConsole()
    if TrackerConsole then TrackerConsole:Destroy() end
    
    TrackerConsole = Instance.new("ScreenGui")
    TrackerConsole.Name = "RealTimeCreationTrackerConsole"
    TrackerConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 900, 0, 700)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.02, 0.1, 0.02)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.2, 1, 0.2)
    frame.Parent = TrackerConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.2, 1, 0.2)
    title.BorderSizePixel = 0
    title.Text = "⚡ REAL TIME CREATION TRACKER"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.01, 0.05, 0.01)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "⚡ Трекер реального создания готов..."
    textLabel.TextColor3 = Color3.new(0.9, 1, 0.9)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования
local function realtimeLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local relativeTime = TrackerData.startTime and string.format("+%.3f", tick() - TrackerData.startTime) or "0.000"
    
    local prefixes = {
        TRACKER = "⚡", CREATION = "🏗️", SCRIPT = "📜", INSTANCE = "🔧",
        FOUND = "🎯", CRITICAL = "🔥", SUCCESS = "✅", ERROR = "❌", 
        DEBUG = "🐛", CALL = "📞", CLONE = "👥"
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

-- 🔍 МОНИТОРИНГ СОЗДАНИЯ INSTANCE
local function monitorInstanceCreation()
    realtimeLog("TRACKER", "🔍 Мониторинг создания Instance...")
    
    -- Перехватываем создание новых объектов
    local originalInstance = Instance
    local instanceMetatable = getmetatable(Instance)
    
    if instanceMetatable then
        local originalNew = instanceMetatable.__call or Instance.new
        
        instanceMetatable.__call = function(self, className, parent)
            local obj = originalNew(self, className, parent)
            
            if className == "Model" then
                realtimeLog("INSTANCE", "🔧 СОЗДАН НОВЫЙ MODEL!", {
                    ClassName = className,
                    Parent = parent and parent.Name or "NIL",
                    Name = obj.Name or "UNNAMED"
                })
                
                TrackerData.instanceCreations[obj] = {
                    time = tick(),
                    className = className,
                    parent = parent,
                    stackTrace = debug.traceback()
                }
            end
            
            return obj
        end
    end
end

-- 👥 МОНИТОРИНГ КЛОНИРОВАНИЯ
local function monitorCloning()
    realtimeLog("TRACKER", "👥 Мониторинг клонирования...")
    
    -- Отслеживаем все объекты, которые могут быть клонированы
    local function hookClone(obj)
        if obj and obj.Clone then
            local originalClone = obj.Clone
            obj.Clone = function(self)
                local clone = originalClone(self)
                
                if self:IsA("Model") then
                    realtimeLog("CLONE", "👥 МОДЕЛЬ КЛОНИРОВАНА!", {
                        Original = self.Name,
                        Clone = clone.Name,
                        OriginalParent = self.Parent and self.Parent.Name or "NIL",
                        CloneParent = clone.Parent and clone.Parent.Name or "NIL"
                    })
                    
                    TrackerData.instanceCreations[clone] = {
                        time = tick(),
                        method = "Clone",
                        original = self,
                        stackTrace = debug.traceback()
                    }
                end
                
                return clone
            end
        end
    end
    
    -- Применяем hook ко всем существующим объектам
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Model") then
            hookClone(obj)
        end
    end
    
    -- Применяем hook к новым объектам
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            hookClone(obj)
        end
    end)
end

-- 📜 МОНИТОРИНГ СКРИПТОВ
local function monitorScriptActivity()
    realtimeLog("SCRIPT", "📜 Мониторинг активности скриптов...")
    
    -- Отслеживаем все скрипты в workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            realtimeLog("SCRIPT", "📜 Найден скрипт: " .. obj.Name, {
                Path = obj:GetFullName(),
                Parent = obj.Parent and obj.Parent.Name or "NIL"
            })
        end
    end
end

-- 🎯 ТОЧНОЕ ОТСЛЕЖИВАНИЕ ПИТОМЦА
local function trackPetCreation()
    realtimeLog("FOUND", "🎯 Отслеживание создания питомца...")
    
    local petConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name == "dog" or name == "bunny" or name == "golden lab" or 
               name == "cat" or name == "rabbit" or name == "puppy" then
                
                TrackerData.targetModel = obj
                
                realtimeLog("CRITICAL", "🔥 ПИТОМЕЦ СОЗДАН В РЕАЛЬНОМ ВРЕМЕНИ!", {
                    Name = obj.Name,
                    Parent = obj.Parent and obj.Parent.Name or "NIL",
                    Time = string.format("%.3f", tick()),
                    RelativeTime = TrackerData.startTime and string.format("%.3f сек", tick() - TrackerData.startTime) or "0"
                })
                
                -- Проверяем, есть ли информация о создании этого объекта
                if TrackerData.instanceCreations[obj] then
                    local creationInfo = TrackerData.instanceCreations[obj]
                    realtimeLog("SUCCESS", "✅ НАЙДЕНА ИНФОРМАЦИЯ О СОЗДАНИИ!", {
                        Method = creationInfo.method or "Instance.new",
                        CreationTime = string.format("%.3f", creationInfo.time),
                        OriginalObject = creationInfo.original and creationInfo.original.Name or "NIL"
                    })
                    
                    if creationInfo.stackTrace then
                        realtimeLog("DEBUG", "🐛 STACK TRACE СОЗДАНИЯ:")
                        local lines = string.split(creationInfo.stackTrace, "\n")
                        for i, line in ipairs(lines) do
                            if i <= 10 then -- Показываем только первые 10 строк
                                realtimeLog("DEBUG", "  " .. line)
                            end
                        end
                    end
                else
                    realtimeLog("ERROR", "❌ НЕТ ИНФОРМАЦИИ О СОЗДАНИИ ЭТОГО ОБЪЕКТА")
                end
                
                -- Анализируем родителя
                local parent = obj.Parent
                if parent then
                    realtimeLog("FOUND", "🎯 АНАЛИЗ РОДИТЕЛЯ: " .. parent.Name, {
                        ClassName = parent.ClassName,
                        Path = parent:GetFullName(),
                        Children = #parent:GetChildren()
                    })
                end
                
                -- Отключаем отслеживание
                petConnection:Disconnect()
                realtimeLog("TRACKER", "⚡ ОТСЛЕЖИВАНИЕ ЗАВЕРШЕНО!")
            end
        end
    end)
    
    return petConnection
end

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ ТРЕКИНГА
local function startRealTimeTracking()
    realtimeLog("TRACKER", "🚀 ЗАПУСК ТРЕКИНГА РЕАЛЬНОГО ВРЕМЕНИ")
    realtimeLog("TRACKER", "⚡ Отслеживание РЕАЛЬНОГО создания модели питомца")
    
    TrackerData.isTracking = true
    TrackerData.startTime = tick()
    
    -- Запускаем все мониторы
    monitorInstanceCreation()
    monitorCloning()
    monitorScriptActivity()
    local petConnection = trackPetCreation()
    
    realtimeLog("TRACKER", "✅ Все мониторы активны!")
    realtimeLog("TRACKER", "🥚 ОТКРОЙТЕ ЯЙЦО ПРЯМО СЕЙЧАС!")
    
    -- Автоостановка через 2 минуты
    spawn(function()
        wait(120)
        if petConnection then
            petConnection:Disconnect()
        end
        TrackerData.isTracking = false
        realtimeLog("TRACKER", "⏰ Трекинг завершен по таймауту")
    end)
end

-- Создаем GUI
local function createTrackerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RealTimeCreationTrackerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 120)
    frame.Position = UDim2.new(1, -370, 0, 400)
    frame.BackgroundColor3 = Color3.new(0.02, 0.1, 0.02)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.2, 1, 0.2)
    title.BorderSizePixel = 0
    title.Text = "⚡ REALTIME TRACKER"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(0.2, 1, 0.2)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "⚡ РЕАЛЬНЫЙ ТРЕКИНГ"
    startBtn.TextColor3 = Color3.new(0, 0, 0)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.Text = "Готов к реальному трекингу"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "⚡ Трекинг активен!"
        status.TextColor3 = Color3.new(0.2, 1, 0.2)
        startBtn.Text = "✅ ТРЕКИНГ АКТИВЕН"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        startBtn.Active = false
        
        startRealTimeTracking()
    end)
end

-- Запускаем
local consoleTextLabel = createTrackerConsole()
createTrackerGUI()

realtimeLog("TRACKER", "✅ RealTimeCreationTracker готов!")
realtimeLog("TRACKER", "⚡ Трекинг реального создания модели питомца")
realtimeLog("TRACKER", "🎯 Перехватывает Instance.new, Clone и stack trace")
realtimeLog("TRACKER", "🚀 Нажмите 'РЕАЛЬНЫЙ ТРЕКИНГ' и откройте яйцо!")
