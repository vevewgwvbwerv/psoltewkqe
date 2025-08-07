-- 🔬 PET GROWTH DIAGNOSTIC ANALYZER
-- Анализирует как питомцы появляются и растут в workspace.visuals
-- Создает GUI с консолью для логирования данных

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("🔬 === PET GROWTH DIAGNOSTIC ANALYZER ===")
print("Анализирует рост питомцев в workspace.visuals")
print("Ищет: dog, bunny, golden lab и другие модели")

-- === ПЕРЕМЕННЫЕ ===
local gui = nil
local consoleFrame = nil
local consoleText = nil
local scrollingFrame = nil
local logLines = {}
local maxLogLines = 50
local isMonitoring = false
local monitorConnection = nil
local trackedPets = {}

-- === ФУНКЦИИ ЛОГИРОВАНИЯ ===

local function addLogLine(message)
    local timestamp = os.date("%H:%M:%S")
    local logMessage = "[" .. timestamp .. "] " .. message
    
    table.insert(logLines, logMessage)
    print(logMessage) -- Дублируем в обычную консоль
    
    -- Ограничиваем количество строк
    if #logLines > maxLogLines then
        table.remove(logLines, 1)
    end
    
    -- Обновляем GUI консоль
    if consoleText then
        consoleText.Text = table.concat(logLines, "\n")
        
        -- Автоскролл вниз
        if scrollingFrame then
            scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.AbsoluteCanvasSize.Y)
        end
    end
end

local function logPetInfo(pet, action)
    local info = {
        name = pet.Name,
        action = action,
        position = pet:GetModelCFrame().Position,
        parts = {},
        totalParts = 0,
        hasMotor6D = false,
        hasPrimaryPart = pet.PrimaryPart ~= nil
    }
    
    -- Анализируем части
    for _, obj in pairs(pet:GetDescendants()) do
        if obj:IsA("BasePart") then
            info.totalParts = info.totalParts + 1
            table.insert(info.parts, {
                name = obj.Name,
                size = obj.Size,
                anchored = obj.Anchored,
                canCollide = obj.CanCollide
            })
        elseif obj:IsA("Motor6D") then
            info.hasMotor6D = true
        end
    end
    
    -- Логируем основную информацию
    addLogLine("🐾 " .. action .. ": " .. info.name)
    addLogLine("  📍 Позиция: " .. tostring(info.position))
    addLogLine("  🧩 Частей: " .. info.totalParts)
    addLogLine("  🔗 Motor6D: " .. (info.hasMotor6D and "Да" or "Нет"))
    addLogLine("  🎯 PrimaryPart: " .. (info.hasPrimaryPart and "Да" or "Нет"))
    
    -- Логируем размеры ключевых частей
    for i, part in ipairs(info.parts) do
        if i <= 3 then -- Только первые 3 части
            addLogLine("    " .. part.name .. ": " .. tostring(part.size))
        end
    end
    
    if #info.parts > 3 then
        addLogLine("    ... и еще " .. (#info.parts - 3) .. " частей")
    end
    
    return info
end

-- === МОНИТОРИНГ ФУНКЦИИ ===

local function startMonitoring()
    if isMonitoring then
        addLogLine("⚠️ Мониторинг уже запущен!")
        return
    end
    
    isMonitoring = true
    addLogLine("🚀 Запуск мониторинга workspace.visuals...")
    
    -- Проверяем существование workspace.visuals
    local visuals = Workspace:FindFirstChild("visuals")
    if not visuals then
        addLogLine("❌ workspace.visuals не найден!")
        return
    end
    
    addLogLine("✅ Найден workspace.visuals")
    
    -- Мониторим добавление новых моделей
    local function onChildAdded(child)
        if child:IsA("Model") then
            local petNames = {"dog", "bunny", "golden", "lab", "cat", "rabbit", "pet"}
            local isPet = false
            
            -- Проверяем, является ли это питомцем
            for _, petName in ipairs(petNames) do
                if string.lower(child.Name):find(petName) then
                    isPet = true
                    break
                end
            end
            
            if isPet then
                addLogLine("🎉 ОБНАРУЖЕН НОВЫЙ ПИТОМЕЦ!")
                local initialInfo = logPetInfo(child, "ПОЯВИЛСЯ")
                
                -- Отслеживаем этого питомца
                trackedPets[child] = {
                    startTime = tick(),
                    initialInfo = initialInfo,
                    sizeHistory = {}
                }
                
                -- Мониторим изменения размера
                spawn(function()
                    local pet = child
                    local trackData = trackedPets[pet]
                    
                    while pet.Parent and trackData do
                        wait(0.1)
                        
                        if not pet.Parent then break end
                        
                        -- Записываем текущие размеры
                        local currentSizes = {}
                        for _, obj in pairs(pet:GetDescendants()) do
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
    end
    
    -- Мониторим удаление моделей
    local function onChildRemoved(child)
        if trackedPets[child] then
            local trackData = trackedPets[child]
            local lifeTime = tick() - trackData.startTime
            
            addLogLine("👋 ПИТОМЕЦ УДАЛЕН!")
            logPetInfo(child, "УДАЛЕН")
            addLogLine("  ⏱️ Время жизни: " .. string.format("%.1f", lifeTime) .. " сек")
            
            -- Анализируем изменения размера
            if #trackData.sizeHistory > 1 then
                local firstSizes = trackData.sizeHistory[1].sizes
                local lastSizes = trackData.sizeHistory[#trackData.sizeHistory].sizes
                
                addLogLine("📊 АНАЛИЗ РОСТА:")
                for partName, finalSize in pairs(lastSizes) do
                    local initialSize = firstSizes[partName]
                    if initialSize then
                        local scaleX = finalSize.X / initialSize.X
                        local scaleY = finalSize.Y / initialSize.Y
                        local scaleZ = finalSize.Z / initialSize.Z
                        
                        if math.abs(scaleX - 1) > 0.01 then -- Если изменение больше 1%
                            addLogLine("  " .. partName .. ": " .. 
                                string.format("%.2fx, %.2fx, %.2fx", scaleX, scaleY, scaleZ))
                        end
                    end
                end
            end
            
            trackedPets[child] = nil
        end
    end
    
    -- Подключаем обработчики
    visuals.ChildAdded:Connect(onChildAdded)
    visuals.ChildRemoved:Connect(onChildRemoved)
    
    -- Проверяем уже существующие модели
    for _, child in pairs(visuals:GetChildren()) do
        if child:IsA("Model") then
            onChildAdded(child)
        end
    end
    
    addLogLine("👁️ Мониторинг активен. Ожидаю появления питомцев...")
end

local function stopMonitoring()
    if not isMonitoring then
        addLogLine("⚠️ Мониторинг не запущен!")
        return
    end
    
    isMonitoring = false
    if monitorConnection then
        monitorConnection:Disconnect()
        monitorConnection = nil
    end
    
    trackedPets = {}
    addLogLine("🛑 Мониторинг остановлен")
end

-- === СОЗДАНИЕ GUI ===

local function createGUI()
    -- Удаляем старый GUI если есть
    local existingGui = playerGui:FindFirstChild("PetGrowthDiagnostic")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Создаем основной GUI
    gui = Instance.new("ScreenGui")
    gui.Name = "PetGrowthDiagnostic"
    gui.Parent = playerGui
    
    -- Главная рамка
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    mainFrame.Parent = gui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
    titleLabel.Text = "🔬 Pet Growth Diagnostic Analyzer"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Кнопки управления
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.Position = UDim2.new(0, 0, 0, 40)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
    
    -- Консоль
    scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -20, 1, -110)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 100)
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    scrollingFrame.BorderSizePixel = 1
    scrollingFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    scrollingFrame.ScrollBarThickness = 10
    scrollingFrame.Parent = mainFrame
    
    consoleText = Instance.new("TextLabel")
    consoleText.Size = UDim2.new(1, -10, 1, 0)
    consoleText.Position = UDim2.new(0, 5, 0, 0)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = ""
    consoleText.TextColor3 = Color3.fromRGB(0, 255, 0)
    consoleText.TextSize = 12
    consoleText.Font = Enum.Font.Code
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.TextWrapped = true
    consoleText.Parent = scrollingFrame
    
    -- Обработчики кнопок
    startButton.MouseButton1Click:Connect(function()
        startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        wait(0.1)
        startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        startMonitoring()
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        wait(0.1)
        stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        stopMonitoring()
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        clearButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        wait(0.1)
        clearButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        logLines = {}
        if consoleText then
            consoleText.Text = ""
        end
        addLogLine("🗑️ Консоль очищена")
    end)
    
    -- Делаем GUI перетаскиваемым
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleLabel.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleLabel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    addLogLine("🔬 Pet Growth Diagnostic Analyzer запущен!")
    addLogLine("📋 Инструкции:")
    addLogLine("  1. Нажмите '🚀 Старт' для начала мониторинга")
    addLogLine("  2. Откройте яйцо в игре")
    addLogLine("  3. Наблюдайте за логами роста питомца")
    addLogLine("  4. Анализируйте данные для понимания механизма")
    addLogLine("")
    addLogLine("🎯 Цель: Понять как питомец растет из маленького размера")
    addLogLine("📍 Мониторим: workspace.visuals")
    addLogLine("🔍 Ищем: dog, bunny, golden lab и другие модели")
end

-- === ЗАПУСК ===

createGUI()

addLogLine("✅ Диагностический скрипт готов к работе!")
addLogLine("💡 Нажмите 'Старт' и откройте яйцо для анализа!")
