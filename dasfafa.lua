-- 🔍 UNIVERSAL PET DETECTOR
-- Мониторит ВСЕ новые модели в Workspace для поиска питомцев
-- Показывает подробную информацию о каждой новой модели

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("🔍 === UNIVERSAL PET DETECTOR ===")
print("Мониторит ВСЕ новые модели в Workspace")

-- === ПЕРЕМЕННЫЕ ===
local gui = nil
local consoleText = nil
local scrollingFrame = nil
local logLines = {}
local maxLogLines = 100
local isMonitoring = false
local trackedModels = {}
local connections = {}

-- === ФУНКЦИИ ЛОГИРОВАНИЯ ===

local function addLogLine(message)
    local timestamp = os.date("%H:%M:%S")
    local logMessage = "[" .. timestamp .. "] " .. message
    
    table.insert(logLines, logMessage)
    print(logMessage)
    
    if #logLines > maxLogLines then
        table.remove(logLines, 1)
    end
    
    if consoleText then
        consoleText.Text = table.concat(logLines, "\n")
        if scrollingFrame then
            scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.AbsoluteCanvasSize.Y)
        end
    end
end

local function analyzeModel(model)
    local info = {
        name = model.Name,
        fullName = model:GetFullName(),
        className = model.ClassName,
        parts = {},
        totalParts = 0,
        hasMotor6D = false,
        hasHumanoid = false,
        hasPrimaryPart = model.PrimaryPart ~= nil,
        hasAnimations = false,
        specialObjects = {}
    }
    
    -- Получаем позицию если возможно
    local success, position = pcall(function()
        return model:GetModelCFrame().Position
    end)
    info.position = success and position or "Неизвестно"
    
    -- Анализируем содержимое
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            info.totalParts = info.totalParts + 1
            if info.totalParts <= 5 then -- Записываем только первые 5 частей
                table.insert(info.parts, {
                    name = obj.Name,
                    size = obj.Size,
                    anchored = obj.Anchored,
                    material = obj.Material.Name
                })
            end
        elseif obj:IsA("Motor6D") then
            info.hasMotor6D = true
        elseif obj:IsA("Humanoid") then
            info.hasHumanoid = true
        elseif obj:IsA("Animation") or obj:IsA("AnimationTrack") then
            info.hasAnimations = true
        elseif obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then
            table.insert(info.specialObjects, obj.ClassName .. ":" .. obj.Name)
        end
    end
    
    return info
end

local function logModelInfo(model, action)
    local info = analyzeModel(model)
    
    addLogLine("🆕 " .. action .. " МОДЕЛЬ: " .. info.name)
    addLogLine("  📍 Полное имя: " .. info.fullName)
    addLogLine("  📍 Позиция: " .. tostring(info.position))
    addLogLine("  🧩 Частей: " .. info.totalParts)
    addLogLine("  🔗 Motor6D: " .. (info.hasMotor6D and "✅" or "❌"))
    addLogLine("  🚶 Humanoid: " .. (info.hasHumanoid and "✅" or "❌"))
    addLogLine("  🎯 PrimaryPart: " .. (info.hasPrimaryPart and "✅" or "❌"))
    addLogLine("  🎬 Анимации: " .. (info.hasAnimations and "✅" or "❌"))
    
    -- Показываем части
    if #info.parts > 0 then
        addLogLine("  📦 Части:")
        for _, part in ipairs(info.parts) do
            addLogLine("    • " .. part.name .. ": " .. tostring(part.size) .. 
                      " (" .. part.material .. ", Anchored:" .. tostring(part.anchored) .. ")")
        end
        if info.totalParts > #info.parts then
            addLogLine("    ... и еще " .. (info.totalParts - #info.parts) .. " частей")
        end
    end
    
    -- Показываем специальные объекты
    if #info.specialObjects > 0 then
        addLogLine("  ✨ Специальные объекты: " .. table.concat(info.specialObjects, ", "))
    end
    
    addLogLine("") -- Пустая строка для разделения
    
    return info
end

-- === МОНИТОРИНГ ФУНКЦИИ ===

local function monitorContainer(container, containerName)
    addLogLine("👀 Мониторю: " .. containerName)
    
    local function onChildAdded(child)
        if child:IsA("Model") then
            -- Логируем ВСЕ новые модели
            addLogLine("🎉 НОВАЯ МОДЕЛЬ В " .. containerName .. "!")
            local info = logModelInfo(child, "ДОБАВЛЕНА В " .. containerName)
            
            -- Отслеживаем эту модель
            trackedModels[child] = {
                startTime = tick(),
                container = containerName,
                initialInfo = info,
                sizeHistory = {}
            }
            
            -- Мониторим изменения размера
            spawn(function()
                local model = child
                local trackData = trackedModels[model]
                
                while model.Parent and trackData do
                    wait(0.2) -- Проверяем каждые 0.2 секунды
                    
                    if not model.Parent then break end
                    
                    -- Записываем текущие размеры
                    local currentSizes = {}
                    for _, obj in pairs(model:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            currentSizes[obj.Name] = obj.Size
                        end
                    end
                    
                    table.insert(trackData.sizeHistory, {
                        time = tick() - trackData.startTime,
                        sizes = currentSizes
                    })
                end
            end)
        end
    end
    
    local function onChildRemoved(child)
        if trackedModels[child] then
            local trackData = trackedModels[child]
            local lifeTime = tick() - trackData.startTime
            
            addLogLine("👋 МОДЕЛЬ УДАЛЕНА ИЗ " .. trackData.container .. "!")
            addLogLine("  📛 Имя: " .. child.Name)
            addLogLine("  ⏱️ Время жизни: " .. string.format("%.2f", lifeTime) .. " сек")
            
            -- Анализируем изменения размера
            if #trackData.sizeHistory > 1 then
                local firstSizes = trackData.sizeHistory[1].sizes
                local lastSizes = trackData.sizeHistory[#trackData.sizeHistory].sizes
                
                addLogLine("📊 АНАЛИЗ ИЗМЕНЕНИЙ РАЗМЕРА:")
                local hasChanges = false
                
                for partName, finalSize in pairs(lastSizes) do
                    local initialSize = firstSizes[partName]
                    if initialSize then
                        local scaleX = finalSize.X / initialSize.X
                        local scaleY = finalSize.Y / initialSize.Y
                        local scaleZ = finalSize.Z / initialSize.Z
                        
                        if math.abs(scaleX - 1) > 0.05 or math.abs(scaleY - 1) > 0.05 or math.abs(scaleZ - 1) > 0.05 then
                            hasChanges = true
                            addLogLine("  🔄 " .. partName .. ": " .. 
                                string.format("%.3fx, %.3fx, %.3fx", scaleX, scaleY, scaleZ))
                        end
                    end
                end
                
                if not hasChanges then
                    addLogLine("  ➡️ Размеры не изменились")
                end
            else
                addLogLine("  ⚠️ Недостаточно данных для анализа изменений")
            end
            
            addLogLine("") -- Пустая строка
            trackedModels[child] = nil
        end
    end
    
    -- Подключаем обработчики
    table.insert(connections, container.ChildAdded:Connect(onChildAdded))
    table.insert(connections, container.ChildRemoved:Connect(onChildRemoved))
    
    -- Проверяем уже существующие модели
    for _, child in pairs(container:GetChildren()) do
        if child:IsA("Model") then
            addLogLine("📋 Существующая модель: " .. child.Name .. " в " .. containerName)
        end
    end
end

local function startMonitoring()
    if isMonitoring then
        addLogLine("⚠️ Мониторинг уже запущен!")
        return
    end
    
    isMonitoring = true
    addLogLine("🚀 Запуск универсального мониторинга...")
    
    -- Мониторим основной Workspace
    monitorContainer(Workspace, "Workspace")
    
    -- Мониторим workspace.visuals если есть
    local visuals = Workspace:FindFirstChild("visuals")
    if visuals then
        monitorContainer(visuals, "workspace.visuals")
    else
        addLogLine("⚠️ workspace.visuals не найден")
    end
    
    -- Мониторим другие потенциальные контейнеры
    local commonContainers = {"Pets", "Models", "Effects", "Visuals", "Game"}
    for _, containerName in ipairs(commonContainers) do
        local container = Workspace:FindFirstChild(containerName)
        if container then
            monitorContainer(container, "workspace." .. containerName)
        end
    end
    
    addLogLine("👁️ Мониторинг активен. Открывайте яйца!")
end

local function stopMonitoring()
    if not isMonitoring then
        addLogLine("⚠️ Мониторинг не запущен!")
        return
    end
    
    isMonitoring = false
    
    -- Отключаем все соединения
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    connections = {}
    
    trackedModels = {}
    addLogLine("🛑 Мониторинг остановлен")
end

-- === СОЗДАНИЕ GUI ===

local function createGUI()
    local existingGui = playerGui:FindFirstChild("UniversalPetDetector")
    if existingGui then
        existingGui:Destroy()
    end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "UniversalPetDetector"
    gui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 700, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    mainFrame.Parent = gui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    titleLabel.Text = "🔍 Universal Pet Detector"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.Position = UDim2.new(0, 0, 0, 40)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    buttonFrame.Parent = mainFrame
    
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0, 120, 0, 30)
    startButton.Position = UDim2.new(0, 10, 0, 10)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    startButton.Text = "🚀 Старт"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextScaled = true
    startButton.Font = Enum.Font.Gotham
    startButton.Parent = buttonFrame
    
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0, 120, 0, 30)
    stopButton.Position = UDim2.new(0, 140, 0, 10)
    stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    stopButton.Text = "🛑 Стоп"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextScaled = true
    stopButton.Font = Enum.Font.Gotham
    stopButton.Parent = buttonFrame
    
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0, 120, 0, 30)
    clearButton.Position = UDim2.new(0, 270, 0, 10)
    clearButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    clearButton.Text = "🗑️ Очистить"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.Gotham
    clearButton.Parent = buttonFrame
    
    scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -20, 1, -110)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 100)
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    scrollingFrame.BorderSizePixel = 1
    scrollingFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    scrollingFrame.ScrollBarThickness = 12
    scrollingFrame.Parent = mainFrame
    
    consoleText = Instance.new("TextLabel")
    consoleText.Size = UDim2.new(1, -10, 1, 0)
    consoleText.Position = UDim2.new(0, 5, 0, 0)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = ""
    consoleText.TextColor3 = Color3.fromRGB(255, 200, 0)
    consoleText.TextSize = 11
    consoleText.Font = Enum.Font.Code
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.TextWrapped = true
    consoleText.Parent = scrollingFrame
    
    -- Обработчики кнопок
    startButton.MouseButton1Click:Connect(startMonitoring)
    stopButton.MouseButton1Click:Connect(stopMonitoring)
    clearButton.MouseButton1Click:Connect(function()
        logLines = {}
        if consoleText then
            consoleText.Text = ""
        end
        addLogLine("🗑️ Консоль очищена")
    end)
    
    addLogLine("🔍 Universal Pet Detector готов!")
    addLogLine("📋 Мониторит ВСЕ новые модели в Workspace")
    addLogLine("🎯 Нажмите 'Старт' и откройте яйцо")
    addLogLine("💡 Покажет ЛЮБУЮ новую модель, даже если это не питомец")
end

-- === ЗАПУСК ===

createGUI()

addLogLine("✅ Универсальный детектор готов!")
addLogLine("🔥 Найдет ЛЮБУЮ новую модель в Workspace!")
