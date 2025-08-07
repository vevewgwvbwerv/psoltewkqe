-- 🔍 PET MODEL ORIGIN TRACKER
-- Отслеживает ОТКУДА берется модель питомца (dog, bunny, golden lab) для яйца
-- Отдельная консоль с минимальным спамом, только важная информация

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 📊 КОНФИГУРАЦИЯ
local CONFIG = {
    SEARCH_RADIUS = 200,
    MONITOR_DURATION = 30,
    PET_NAMES = {"dog", "bunny", "golden lab", "cat", "rabbit", "golden", "lab"}
}

-- 🖥️ СИСТЕМА ОТДЕЛЬНОЙ КОНСОЛИ
local ConsoleGUI = nil
local ConsoleFrame = nil
local ConsoleScrollFrame = nil
local ConsoleTextLabel = nil
local ConsoleLines = {}
local MaxConsoleLines = 50

-- Функция создания отдельной консоли
local function createConsole()
    if ConsoleGUI then
        ConsoleGUI:Destroy()
    end
    
    ConsoleGUI = Instance.new("ScreenGui")
    ConsoleGUI.Name = "PetOriginTrackerConsole"
    ConsoleGUI.Parent = player:WaitForChild("PlayerGui")
    
    -- Основной фрейм консоли
    ConsoleFrame = Instance.new("Frame")
    ConsoleFrame.Size = UDim2.new(0, 600, 0, 400)
    ConsoleFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    ConsoleFrame.BorderSizePixel = 2
    ConsoleFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
    ConsoleFrame.Parent = ConsoleGUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = ConsoleFrame
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔍 PET MODEL ORIGIN TRACKER - КОНСОЛЬ"
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = ConsoleFrame
    
    -- Кнопка запуска
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0, 150, 0, 30)
    startButton.Position = UDim2.new(0, 10, 0, 45)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    startButton.Text = "🚀 ЗАПУСТИТЬ"
    startButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    startButton.TextScaled = true
    startButton.Font = Enum.Font.SourceSansBold
    startButton.Parent = ConsoleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = startButton
    
    -- Кнопка очистки
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0, 100, 0, 30)
    clearButton.Position = UDim2.new(0, 170, 0, 45)
    clearButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    clearButton.Text = "🗑️ ОЧИСТИТЬ"
    clearButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.Parent = ConsoleFrame
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 5)
    clearCorner.Parent = clearButton
    
    -- Скролл фрейм для консоли
    ConsoleScrollFrame = Instance.new("ScrollingFrame")
    ConsoleScrollFrame.Size = UDim2.new(1, -20, 1, -90)
    ConsoleScrollFrame.Position = UDim2.new(0, 10, 0, 80)
    ConsoleScrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    ConsoleScrollFrame.BorderSizePixel = 1
    ConsoleScrollFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    ConsoleScrollFrame.ScrollBarThickness = 10
    ConsoleScrollFrame.Parent = ConsoleFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 5)
    scrollCorner.Parent = ConsoleScrollFrame
    
    -- Текстовая метка для консоли
    ConsoleTextLabel = Instance.new("TextLabel")
    ConsoleTextLabel.Size = UDim2.new(1, -10, 1, 0)
    ConsoleTextLabel.Position = UDim2.new(0, 5, 0, 0)
    ConsoleTextLabel.BackgroundTransparency = 1
    ConsoleTextLabel.Text = "Консоль готова. Нажмите ЗАПУСТИТЬ для начала отслеживания."
    ConsoleTextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ConsoleTextLabel.TextSize = 12
    ConsoleTextLabel.Font = Enum.Font.SourceSans
    ConsoleTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    ConsoleTextLabel.TextYAlignment = Enum.TextYAlignment.Top
    ConsoleTextLabel.TextWrapped = true
    ConsoleTextLabel.Parent = ConsoleScrollFrame
    
    return startButton, clearButton
end

-- Функция добавления строки в консоль
local function addConsoleLog(level, message, data)
    local timestamp = os.date("%H:%M:%S")
    local prefixes = {
        ORIGIN = "🔍", PET = "🐾", CREATION = "⚡", PARENT = "📁",
        SUCCESS = "✅", WARNING = "⚠️", ERROR = "❌", INFO = "ℹ️"
    }
    
    local logLine = string.format("[%s] %s %s", timestamp, prefixes[level] or "ℹ️", message)
    
    if data and next(data) then
        for key, value in pairs(data) do
            logLine = logLine .. string.format("\n    %s: %s", key, tostring(value))
        end
    end
    
    table.insert(ConsoleLines, logLine)
    
    -- Ограничиваем количество строк
    if #ConsoleLines > MaxConsoleLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Обновляем текст консоли
    if ConsoleTextLabel then
        ConsoleTextLabel.Text = table.concat(ConsoleLines, "\n")
        
        -- Автоскролл вниз
        spawn(function()
            wait(0.1)
            ConsoleScrollFrame.CanvasPosition = Vector2.new(0, ConsoleTextLabel.TextBounds.Y)
        end)
    end
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

-- 🐾 ФУНКЦИЯ ПРОВЕРКИ МОДЕЛИ ПИТОМЦА
local function isPetModel(model)
    if not model:IsA("Model") then return false end
    if model.Name == "EggExplode" then return false end
    if model.Name:find("%[") and model.Name:find("KG") and model.Name:find("Age") then return false end
    
    -- Проверяем на ключевые слова питомцев
    local modelNameLower = model.Name:lower()
    for _, petName in pairs(CONFIG.PET_NAMES) do
        if modelNameLower:find(petName) then
            return true
        end
    end
    
    return false
end

-- 📁 ФУНКЦИЯ АНАЛИЗА ПРОИСХОЖДЕНИЯ МОДЕЛИ
local function analyzeModelOrigin(model)
    local originData = {
        name = model.Name,
        className = model.ClassName,
        parent = model.Parent and model.Parent.Name or "nil",
        parentClass = model.Parent and model.Parent.ClassName or "nil"
    }
    
    -- Анализируем цепочку родителей
    local parentChain = {}
    local currentParent = model.Parent
    local depth = 0
    
    while currentParent and depth < 10 do
        table.insert(parentChain, currentParent.Name .. " (" .. currentParent.ClassName .. ")")
        currentParent = currentParent.Parent
        depth = depth + 1
    end
    
    originData.parentChain = table.concat(parentChain, " → ")
    
    -- Проверяем, есть ли скрипты в модели или родителях
    local scripts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            table.insert(scripts, obj.Name .. " (" .. obj.ClassName .. ")")
        end
    end
    
    if model.Parent then
        for _, obj in pairs(model.Parent:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                table.insert(scripts, "[Parent] " .. obj.Name .. " (" .. obj.ClassName .. ")")
            end
        end
    end
    
    originData.scripts = #scripts > 0 and table.concat(scripts, ", ") or "Нет скриптов"
    
    return originData
end

-- 🚀 ОСНОВНАЯ ФУНКЦИЯ ОТСЛЕЖИВАНИЯ
local function startOriginTracking()
    addConsoleLog("INFO", "🚀 ЗАПУСК ОТСЛЕЖИВАНИЯ ПРОИСХОЖДЕНИЯ МОДЕЛЕЙ ПИТОМЦЕВ")
    addConsoleLog("INFO", "🎯 Цель: dog, bunny, golden lab и их источники создания")
    
    local eggExplodeDetected = false
    local trackingStartTime = 0
    local processedModels = {}
    local foundOrigins = {}
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        -- Фаза 1: Поиск EggExplode
        if not eggExplodeDetected then
            local found, eggObj, location = checkForEggExplode()
            if found then
                eggExplodeDetected = true
                trackingStartTime = tick()
                
                addConsoleLog("SUCCESS", "✅ EggExplode обнаружен в " .. location)
                addConsoleLog("ORIGIN", "🔍 Начинаем отслеживание происхождения питомцев...")
            end
        else
            -- Фаза 2: Поиск моделей питомцев и анализ их происхождения
            local elapsed = tick() - trackingStartTime
            
            if elapsed > CONFIG.MONITOR_DURATION then
                addConsoleLog("INFO", "⏰ Отслеживание завершено по таймауту")
                connection:Disconnect()
                
                if #foundOrigins > 0 then
                    addConsoleLog("SUCCESS", "✅ НАЙДЕННЫЕ ИСТОЧНИКИ ПИТОМЦЕВ:")
                    for i, origin in pairs(foundOrigins) do
                        addConsoleLog("PET", string.format("🐾 Питомец %d: %s", i, origin.name), origin)
                    end
                else
                    addConsoleLog("WARNING", "⚠️ Источники питомцев не найдены")
                end
                return
            end
            
            -- Сканируем модели питомцев
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= player.Character and not processedModels[obj] then
                    processedModels[obj] = true
                    
                    if isPetModel(obj) then
                        addConsoleLog("PET", "🐾 НАЙДЕН ПИТОМЕЦ: " .. obj.Name)
                        
                        -- Анализируем происхождение
                        local originData = analyzeModelOrigin(obj)
                        table.insert(foundOrigins, originData)
                        
                        addConsoleLog("ORIGIN", "🔍 АНАЛИЗ ПРОИСХОЖДЕНИЯ:", originData)
                        
                        -- Отслеживаем время жизни
                        spawn(function()
                            local startTime = tick()
                            local petName = obj.Name
                            
                            while obj and obj.Parent do
                                wait(0.5)
                            end
                            
                            local lifetime = tick() - startTime
                            addConsoleLog("INFO", string.format("⏱️ %s исчез через %.2f сек", petName, lifetime))
                        end)
                    end
                end
            end
        end
    end)
    
    addConsoleLog("INFO", "🔍 Мониторинг активен. Откройте яйцо для анализа!")
end

-- 🖥️ СОЗДАНИЕ GUI И ЗАПУСК
local function initializeTracker()
    local startButton, clearButton = createConsole()
    
    startButton.MouseButton1Click:Connect(function()
        startButton.Text = "⏳ АКТИВЕН..."
        startButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        startOriginTracking()
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        ConsoleLines = {}
        if ConsoleTextLabel then
            ConsoleTextLabel.Text = "Консоль очищена. Готов к новому отслеживанию."
        end
    end)
    
    addConsoleLog("SUCCESS", "✅ PET MODEL ORIGIN TRACKER ГОТОВ!")
    addConsoleLog("INFO", "📋 Отслеживает ОТКУДА берется модель питомца для яйца")
    addConsoleLog("INFO", "🎯 Нажмите ЗАПУСТИТЬ для начала работы")
end

-- 🚀 ЗАПУСК
initializeTracker()
