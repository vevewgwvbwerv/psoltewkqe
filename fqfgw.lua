-- AssemblyLocationDetector.lua
-- ДЕТЕКТОР МЕСТА СБОРКИ: Мониторит ВСЕ возможные места появления моделей питомца
-- Находит точное место, где происходит сборка полной модели ДО появления в Visuals
-- Оптимизирован для приватного режима (без помех от других игроков)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

print("🔍 === ASSEMBLY LOCATION DETECTOR ===")
print("🎯 Цель: Найти ТОЧНОЕ место сборки полной модели питомца")
print("🏠 Режим: Приватная сессия (без помех)")
print("=" .. string.rep("=", 70))

-- 📊 ДАННЫЕ ДЕТЕКТОРА МЕСТА СБОРКИ
local DetectorData = {
    monitoredServices = {},
    detectedModels = {},
    assemblyLocations = {},
    petSequence = {},
    isActive = false,
    startTime = 0,
    connections = {},
    scanDepth = 0
}

-- 🖥️ КОНСОЛЬ ДЕТЕКТОРА
local DetectorConsole = nil
local ConsoleLines = {}
local MaxLines = 200

-- Создание консоли
local function createDetectorConsole()
    if DetectorConsole then DetectorConsole:Destroy() end
    
    DetectorConsole = Instance.new("ScreenGui")
    DetectorConsole.Name = "AssemblyLocationDetectorConsole"
    DetectorConsole.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 1000, 0, 800)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.05, 0.02, 0.1)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0.5, 0.1, 1)
    frame.Parent = DetectorConsole
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.new(0.5, 0.1, 1)
    title.BorderSizePixel = 0
    title.Text = "🔍 ASSEMBLY LOCATION DETECTOR"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.02, 0.01, 0.05)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🔍 Детектор места сборки готов к работе..."
    textLabel.TextColor3 = Color3.new(0.9, 0.8, 1)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = scrollFrame
    
    return textLabel
end

-- Функция логирования детектора
local function detectorLog(category, message, data)
    local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", (tick() % 1) * 1000)
    local relativeTime = DetectorData.startTime > 0 and string.format("(+%.3f)", tick() - DetectorData.startTime) or ""
    
    local prefixes = {
        DETECTOR = "🔍", LOCATION = "📍", MODEL = "🎯", ASSEMBLY = "🔧",
        MONITOR = "👁️", FOUND = "✅", CRITICAL = "🔥", SUCCESS = "💎", 
        ERROR = "❌", INFO = "ℹ️", DETAIL = "📝", SEQUENCE = "🔄",
        SERVICE = "🏢", CONTAINER = "📦", CREATION = "⚡", MOVEMENT = "🚚"
    }
    
    local logLine = string.format("[%s] %s %s %s", timestamp, relativeTime, prefixes[category] or "ℹ️", message)
    
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
    if DetectorConsole then
        local textLabel = DetectorConsole:FindFirstChild("Frame"):FindFirstChild("ScrollingFrame"):FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = table.concat(ConsoleLines, "\n")
            local scrollFrame = textLabel.Parent
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 10)
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        end
    end
    
    print(logLine)
end

-- 📊 АНАЛИЗ МОДЕЛИ НА ПРЕДМЕТ ПИТОМЦА
local function isPetModel(model)
    if not model:IsA("Model") then return false end
    
    local name = model.Name:lower()
    local petNames = {
        "dog", "bunny", "golden lab", "goldenlab", "cat", "rabbit", 
        "puppy", "kitten", "lab", "retriever", "beagle", "poodle",
        "hamster", "guinea pig", "bird", "parrot", "fish", "turtle"
    }
    
    -- Проверка по имени
    for _, petName in ipairs(petNames) do
        if name == petName or name:find(petName) then
            return true, petName
        end
    end
    
    -- Проверка по структуре (наличие характерных частей питомца)
    local hasBodyParts = false
    local bodyParts = {"head", "torso", "body", "tail", "leg", "arm", "paw"}
    
    for _, child in pairs(model:GetChildren()) do
        local childName = child.Name:lower()
        for _, bodyPart in ipairs(bodyParts) do
            if childName:find(bodyPart) then
                hasBodyParts = true
                break
            end
        end
        if hasBodyParts then break end
    end
    
    -- Проверка по количеству Motor6D (питомцы обычно имеют много соединений)
    local motor6dCount = 0
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            motor6dCount = motor6dCount + 1
        end
    end
    
    if hasBodyParts and motor6dCount >= 5 then
        return true, "structure_based"
    end
    
    return false, nil
end

-- 📊 ДЕТАЛЬНЫЙ АНАЛИЗ СТРУКТУРЫ МОДЕЛИ
local function analyzeModelStructure(model, location)
    local structure = {
        name = model.Name,
        location = location,
        path = model:GetFullName(),
        children = #model:GetChildren(),
        descendants = #model:GetDescendants(),
        timestamp = tick(),
        relativeTime = tick() - DetectorData.startTime,
        components = {}
    }
    
    -- Подсчет компонентов
    local componentCounts = {}
    for _, obj in pairs(model:GetDescendants()) do
        local className = obj.ClassName
        componentCounts[className] = (componentCounts[className] or 0) + 1
    end
    
    structure.components = componentCounts
    
    -- Определение типа модели по структуре
    local motor6ds = componentCounts["Motor6D"] or 0
    local baseParts = componentCounts["BasePart"] or 0
    
    if structure.children == 3 and structure.descendants == 3 then
        structure.modelType = "BASE"
    elseif structure.children >= 15 and motor6ds >= 10 then
        structure.modelType = "FULL"
    elseif structure.children >= 5 and motor6ds >= 3 then
        structure.modelType = "PARTIAL"
    else
        structure.modelType = "UNKNOWN"
    end
    
    return structure
end

-- 🔍 МОНИТОРИНГ КОНТЕЙНЕРА НА ПОЯВЛЕНИЕ МОДЕЛЕЙ
local function monitorContainer(container, containerName, serviceName)
    detectorLog("MONITOR", string.format("👁️ Мониторинг контейнера: %s.%s", serviceName, containerName))
    
    local connection = container.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local isPet, petType = isPetModel(obj)
            if isPet then
                local structure = analyzeModelStructure(obj, serviceName .. "." .. containerName)
                
                detectorLog("FOUND", string.format("✅ МОДЕЛЬ ПИТОМЦА НАЙДЕНА: %s", obj.Name), {
                    Location = serviceName .. "." .. containerName,
                    Path = obj:GetFullName(),
                    Type = structure.modelType,
                    Children = structure.children,
                    Descendants = structure.descendants,
                    Motor6Ds = structure.components["Motor6D"] or 0,
                    PetType = petType,
                    RelativeTime = string.format("%.3f сек", structure.relativeTime)
                })
                
                -- Сохраняем в последовательность
                table.insert(DetectorData.petSequence, structure)
                
                -- Если это полная модель, это может быть место сборки!
                if structure.modelType == "FULL" then
                    detectorLog("CRITICAL", string.format("🔥 ПОЛНАЯ МОДЕЛЬ ОБНАРУЖЕНА В: %s", serviceName .. "." .. containerName), {
                        Model = obj.Name,
                        Children = structure.children,
                        Motor6Ds = structure.components["Motor6D"] or 0,
                        Location = "ВОЗМОЖНОЕ МЕСТО СБОРКИ!"
                    })
                    
                    DetectorData.assemblyLocations[serviceName .. "." .. containerName] = structure
                end
                
                -- Мониторим дальнейшие изменения этой модели
                local modelConnection = obj.DescendantAdded:Connect(function(descendant)
                    detectorLog("DETAIL", string.format("📝 Добавлен объект в %s: %s (%s)", 
                        obj.Name, descendant.Name, descendant.ClassName))
                end)
                
                table.insert(DetectorData.connections, modelConnection)
            end
        end
    end)
    
    table.insert(DetectorData.connections, connection)
    return connection
end

-- 🏢 ГЛУБОКОЕ СКАНИРОВАНИЕ СЕРВИСА
local function deepScanService(service, serviceName)
    detectorLog("SERVICE", string.format("🏢 ГЛУБОКОЕ СКАНИРОВАНИЕ: %s", serviceName))
    
    local scannedCount = 0
    local foundCount = 0
    
    -- Мониторим корневой уровень сервиса
    monitorContainer(service, "ROOT", serviceName)
    
    -- Рекурсивное сканирование всех контейнеров
    local function scanRecursive(container, path, depth)
        if depth > 5 then return end -- Ограничиваем глубину
        
        for _, obj in pairs(container:GetChildren()) do
            scannedCount = scannedCount + 1
            
            -- Если это модель, проверяем на питомца
            if obj:IsA("Model") then
                local isPet, petType = isPetModel(obj)
                if isPet then
                    local structure = analyzeModelStructure(obj, path)
                    foundCount = foundCount + 1
                    
                    detectorLog("MODEL", string.format("🎯 Существующая модель: %s", obj.Name), {
                        Location = path,
                        Type = structure.modelType,
                        Children = structure.children,
                        Motor6Ds = structure.components["Motor6D"] or 0
                    })
                end
            end
            
            -- Если это контейнер, мониторим его и сканируем глубже
            if obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("Configuration") then
                local newPath = path .. "." .. obj.Name
                monitorContainer(obj, obj.Name, serviceName)
                scanRecursive(obj, newPath, depth + 1)
            end
        end
    end
    
    scanRecursive(service, serviceName, 0)
    
    detectorLog("SERVICE", string.format("📊 Сканирование %s завершено", serviceName), {
        ScannedObjects = scannedCount,
        FoundPets = foundCount
    })
end

-- 🚀 ЗАПУСК ПОЛНОГО МОНИТОРИНГА
local function startFullMonitoring()
    detectorLog("DETECTOR", "🚀 ЗАПУСК ПОЛНОГО МОНИТОРИНГА ВСЕХ СЕРВИСОВ")
    detectorLog("DETECTOR", "🏠 Режим: Приватная сессия")
    
    DetectorData.isActive = true
    DetectorData.startTime = tick()
    
    -- Список всех доступных сервисов для мониторинга
    local services = {
        {name = "Workspace", service = Workspace},
        {name = "ReplicatedStorage", service = ReplicatedStorage},
        {name = "ReplicatedFirst", service = ReplicatedFirst},
        {name = "StarterGui", service = StarterGui},
        {name = "StarterPack", service = StarterPack},
        {name = "StarterPlayer", service = StarterPlayer}
    }
    
    -- Попытка добавить ServerStorage
    local success, serverStorage = pcall(function() return game:GetService("ServerStorage") end)
    if success and serverStorage then
        table.insert(services, {name = "ServerStorage", service = serverStorage})
    end
    
    -- Добавляем Character игрока
    if player.Character then
        table.insert(services, {name = "PlayerCharacter", service = player.Character})
    end
    
    -- Мониторим появление Character
    player.CharacterAdded:Connect(function(character)
        detectorLog("MONITOR", "👁️ Новый Character игрока появился")
        monitorContainer(character, "Character", "Player")
    end)
    
    -- Запускаем глубокое сканирование каждого сервиса
    for _, serviceData in ipairs(services) do
        local success, result = pcall(function()
            deepScanService(serviceData.service, serviceData.name)
        end)
        
        if not success then
            detectorLog("ERROR", string.format("❌ Ошибка сканирования %s: %s", serviceData.name, tostring(result)))
        end
    end
    
    detectorLog("DETECTOR", string.format("✅ Мониторинг активен! Отслеживается %d подключений", #DetectorData.connections))
    detectorLog("DETECTOR", "🥚 ОТКРОЙТЕ ЯЙЦО ДЛЯ ДЕТЕКЦИИ МЕСТА СБОРКИ!")
end

-- 📋 ГЕНЕРАЦИЯ ОТЧЕТА О МЕСТАХ СБОРКИ
local function generateAssemblyReport()
    detectorLog("CRITICAL", "📋 === ОТЧЕТ О МЕСТАХ СБОРКИ ===")
    
    detectorLog("INFO", string.format("🔍 Всего обнаружено моделей: %d", #DetectorData.petSequence))
    detectorLog("INFO", string.format("🔧 Потенциальных мест сборки: %d", #DetectorData.assemblyLocations))
    
    if #DetectorData.petSequence > 0 then
        detectorLog("CRITICAL", "🔄 ПОСЛЕДОВАТЕЛЬНОСТЬ ПОЯВЛЕНИЯ МОДЕЛЕЙ:")
        
        for i, model in ipairs(DetectorData.petSequence) do
            detectorLog("SEQUENCE", string.format("🔄 %d. %s (%s)", i, model.name, model.modelType), {
                Location = model.location,
                Time = string.format("%.3f сек", model.relativeTime),
                Children = model.children,
                Motor6Ds = model.components["Motor6D"] or 0
            })
        end
    end
    
    if next(DetectorData.assemblyLocations) then
        detectorLog("CRITICAL", "🔥 ОБНАРУЖЕННЫЕ МЕСТА СБОРКИ:")
        
        for location, model in pairs(DetectorData.assemblyLocations) do
            detectorLog("ASSEMBLY", string.format("🔧 МЕСТО СБОРКИ: %s", location), {
                Model = model.name,
                Type = model.modelType,
                Children = model.children,
                Motor6Ds = model.components["Motor6D"] or 0,
                Time = string.format("%.3f сек", model.relativeTime)
            })
        end
    else
        detectorLog("INFO", "ℹ️ Места сборки пока не обнаружены")
    end
    
    detectorLog("CRITICAL", "🔍 ДЕТЕКЦИЯ ЗАВЕРШЕНА!")
end

-- 🛑 ОСТАНОВКА МОНИТОРИНГА
local function stopMonitoring()
    detectorLog("DETECTOR", "🛑 ОСТАНОВКА МОНИТОРИНГА")
    
    for _, connection in ipairs(DetectorData.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    DetectorData.connections = {}
    DetectorData.isActive = false
    
    detectorLog("DETECTOR", "✅ Мониторинг остановлен")
end

-- Создаем GUI
local function createDetectorGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AssemblyLocationDetectorGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 180)
    frame.Position = UDim2.new(1, -420, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.05, 0.02, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.new(0.5, 0.1, 1)
    title.BorderSizePixel = 0
    title.Text = "🔍 ASSEMBLY LOCATION DETECTOR"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(1, -20, 0, 40)
    startBtn.Position = UDim2.new(0, 10, 0, 40)
    startBtn.BackgroundColor3 = Color3.new(0.5, 0.1, 1)
    startBtn.BorderSizePixel = 0
    startBtn.Text = "🔍 ЗАПУСК ДЕТЕКЦИИ"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.Parent = frame
    
    local reportBtn = Instance.new("TextButton")
    reportBtn.Size = UDim2.new(0.48, 0, 0, 30)
    reportBtn.Position = UDim2.new(0, 10, 0, 90)
    reportBtn.BackgroundColor3 = Color3.new(0.3, 0.1, 0.6)
    reportBtn.BorderSizePixel = 0
    reportBtn.Text = "📋 ОТЧЕТ"
    reportBtn.TextColor3 = Color3.new(1, 1, 1)
    reportBtn.TextScaled = true
    reportBtn.Font = Enum.Font.SourceSans
    reportBtn.Parent = frame
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.48, 0, 0, 30)
    stopBtn.Position = UDim2.new(0.52, 0, 0, 90)
    stopBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "🛑 СТОП"
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.TextScaled = true
    stopBtn.Font = Enum.Font.SourceSans
    stopBtn.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 130)
    status.BackgroundTransparency = 1
    status.Text = "Готов к детекции места сборки\nПриватный режим рекомендуется"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "🔍 Детекция активна!\nМониторинг всех сервисов..."
        status.TextColor3 = Color3.new(0.5, 0.1, 1)
        startBtn.Text = "✅ ДЕТЕКЦИЯ АКТИВНА"
        startBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        startBtn.Active = false
        
        startFullMonitoring()
    end)
    
    reportBtn.MouseButton1Click:Connect(function()
        generateAssemblyReport()
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        stopMonitoring()
        status.Text = "🛑 Мониторинг остановлен"
        status.TextColor3 = Color3.new(1, 0.5, 0.5)
        startBtn.Text = "🔍 ЗАПУСК ДЕТЕКЦИИ"
        startBtn.BackgroundColor3 = Color3.new(0.5, 0.1, 1)
        startBtn.Active = true
    end)
end

-- Запускаем
local consoleTextLabel = createDetectorConsole()
createDetectorGUI()

detectorLog("DETECTOR", "✅ AssemblyLocationDetector готов!")
detectorLog("DETECTOR", "🔍 Детектор места сборки модели питомца")
detectorLog("DETECTOR", "🏠 Оптимизирован для приватного режима")
detectorLog("DETECTOR", "🎯 Мониторинг ВСЕХ сервисов и контейнеров")
detectorLog("DETECTOR", "🚀 Нажмите 'ЗАПУСК ДЕТЕКЦИИ' для начала!")
