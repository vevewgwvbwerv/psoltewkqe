-- InventoryPetAnalyzer.lua
-- Диагностический скрипт для изучения инвентаря и механизма появления питомца в руке

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryPetAnalyzer"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 500)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🎒 Анализатор Инвентаря Питомцев"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Скролл фрейм для логов
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -120)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

-- Текст для логов
local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -10, 1, 0)
logText.Position = UDim2.new(0, 5, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = "Нажмите кнопки для анализа..."
logText.TextColor3 = Color3.fromRGB(255, 255, 255)
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Font = Enum.Font.SourceSans
logText.TextSize = 14
logText.Parent = scrollFrame

-- Кнопки
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, 0, 0, 60)
buttonFrame.Position = UDim2.new(0, 0, 1, -60)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Кнопка анализа инвентаря
local analyzeButton = Instance.new("TextButton")
analyzeButton.Size = UDim2.new(0.3, -5, 0.8, 0)
analyzeButton.Position = UDim2.new(0, 5, 0.1, 0)
analyzeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
analyzeButton.BorderSizePixel = 0
analyzeButton.Text = "📋 Анализ Инвентаря"
analyzeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
analyzeButton.TextScaled = true
analyzeButton.Font = Enum.Font.SourceSansBold
analyzeButton.Parent = buttonFrame

-- Кнопка мониторинга handle
local monitorButton = Instance.new("TextButton")
monitorButton.Size = UDim2.new(0.3, -5, 0.8, 0)
monitorButton.Position = UDim2.new(0.33, 5, 0.1, 0)
monitorButton.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
monitorButton.BorderSizePixel = 0
monitorButton.Text = "👁️ Мониторинг Handle"
monitorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
monitorButton.TextScaled = true
monitorButton.Font = Enum.Font.SourceSansBold
monitorButton.Parent = buttonFrame

-- Кнопка очистки
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.3, -5, 0.8, 0)
clearButton.Position = UDim2.new(0.66, 5, 0.1, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
clearButton.BorderSizePixel = 0
clearButton.Text = "🗑️ Очистить"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextScaled = true
monitorButton.Font = Enum.Font.SourceSansBold
clearButton.Parent = buttonFrame

-- Переменные
local logs = {}
local isMonitoring = false
local monitorConnection = nil

-- Функция добавления лога
local function addLog(message)
    table.insert(logs, os.date("[%H:%M:%S] ") .. message)
    if #logs > 100 then
        table.remove(logs, 1)
    end
    
    logText.Text = table.concat(logs, "\n")
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, logText.TextBounds.Y + 20)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

-- Функция поиска всех питомцев в инвентаре
local function findAllPetsInInventory()
    addLog("🔍 === ПОИСК ПИТОМЦЕВ В ИНВЕНТАРЕ ===")
    
    local foundPets = {}
    local searchLocations = {
        {name = "Player", obj = player},
        {name = "Character", obj = player.Character},
        {name = "Backpack", obj = player:FindFirstChild("Backpack")},
        {name = "PlayerGui", obj = player:FindFirstChild("PlayerGui")},
        {name = "ReplicatedStorage", obj = game.ReplicatedStorage},
        {name = "Workspace", obj = game.Workspace}
    }
    
    for _, location in pairs(searchLocations) do
        if location.obj then
            addLog("📁 Сканирую " .. location.name .. "...")
            
            for _, item in pairs(location.obj:GetDescendants()) do
                if item:IsA("Model") then
                    -- Проверяем, похоже ли на питомца
                    local meshCount = 0
                    for _, part in pairs(item:GetDescendants()) do
                        if part:IsA("MeshPart") or part:IsA("SpecialMesh") then
                            meshCount = meshCount + 1
                        end
                    end
                    
                    -- Если есть меши, вероятно это питомец
                    if meshCount > 0 then
                        local petInfo = {
                            name = item.Name,
                            location = location.name,
                            path = item:GetFullName(),
                            meshCount = meshCount,
                            parent = item.Parent and item.Parent.Name or "nil"
                        }
                        table.insert(foundPets, petInfo)
                        
                        addLog("🐾 ПИТОМЕЦ: " .. item.Name .. " в " .. location.name .. " (Мешей: " .. meshCount .. ")")
                    end
                end
            end
        end
    end
    
    addLog("📊 Всего найдено питомцев: " .. #foundPets)
    
    -- Группируем по именам
    local petGroups = {}
    for _, pet in pairs(foundPets) do
        if not petGroups[pet.name] then
            petGroups[pet.name] = {}
        end
        table.insert(petGroups[pet.name], pet)
    end
    
    addLog("📋 === СВОДКА ПО ПИТОМЦАМ ===")
    for petName, pets in pairs(petGroups) do
        addLog("🏷️ " .. petName .. " (" .. #pets .. " экземпляров):")
        for _, pet in pairs(pets) do
            addLog("   📍 " .. pet.location .. " - " .. pet.parent .. " (Мешей: " .. pet.meshCount .. ")")
        end
    end
    
    return foundPets
end

-- Функция мониторинга handle
local function startHandleMonitoring()
    if isMonitoring then
        addLog("⚠️ Мониторинг уже запущен!")
        return
    end
    
    isMonitoring = true
    monitorButton.Text = "⏹️ Остановить"
    monitorButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    
    addLog("👁️ === ЗАПУСК МОНИТОРИНГА HANDLE ===")
    
    local lastHandleContents = {}
    
    monitorConnection = RunService.Heartbeat:Connect(function()
        local playerChar = player.Character
        if not playerChar then return end
        
        local handle = playerChar:FindFirstChild("Handle")
        if not handle then return end
        
        local currentContents = {}
        for _, child in pairs(handle:GetChildren()) do
            if child:IsA("Model") then
                table.insert(currentContents, {
                    name = child.Name,
                    className = child.ClassName,
                    fullName = child:GetFullName()
                })
            end
        end
        
        -- Проверяем изменения
        if #currentContents ~= #lastHandleContents then
            addLog("🔄 ИЗМЕНЕНИЕ В HANDLE:")
            addLog("   Было: " .. #lastHandleContents .. " питомцев")
            addLog("   Стало: " .. #currentContents .. " питомцев")
            
            for _, content in pairs(currentContents) do
                addLog("   ➕ " .. content.name .. " (" .. content.className .. ")")
            end
            
            lastHandleContents = currentContents
        end
    end)
    
    addLog("✅ Мониторинг handle запущен!")
end

-- Функция остановки мониторинга
local function stopHandleMonitoring()
    if not isMonitoring then return end
    
    isMonitoring = false
    monitorButton.Text = "👁️ Мониторинг Handle"
    monitorButton.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
    
    if monitorConnection then
        monitorConnection:Disconnect()
        monitorConnection = nil
    end
    
    addLog("⏹️ Мониторинг handle остановлен")
end

-- Обработчики кнопок
analyzeButton.MouseButton1Click:Connect(function()
    findAllPetsInInventory()
end)

monitorButton.MouseButton1Click:Connect(function()
    if isMonitoring then
        stopHandleMonitoring()
    else
        startHandleMonitoring()
    end
end)

clearButton.MouseButton1Click:Connect(function()
    logs = {}
    logText.Text = "Логи очищены..."
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Начальный анализ
addLog("🚀 Анализатор инвентаря питомцев запущен!")
addLog("📋 Нажмите 'Анализ Инвентаря' для поиска всех питомцев")
addLog("👁️ Нажмите 'Мониторинг Handle' для отслеживания изменений в руке")

print("✅ InventoryPetAnalyzer загружен! Откройте GUI для анализа.")
