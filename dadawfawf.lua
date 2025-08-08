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

-- Главный фрейм (компактный для мобильного)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.9, 0, 0.7, 0) -- Относительные размеры для мобильного
mainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
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

-- Функция анализа handle и инвентаря игрока
local function analyzePlayerInventory()
    addLog("🔍 === АНАЛИЗ HANDLE И ИНВЕНТАРЯ ИГРОКА ===")
    
    local playerChar = player.Character
    if not playerChar then
        addLog("❌ Персонаж игрока не найден!")
        return
    end
    
    -- Анализируем handle
    local handle = playerChar:FindFirstChild("Handle")
    if handle then
        addLog("👋 === СОДЕРЖИМОЕ HANDLE ===")
        local handlePets = 0
        
        for _, child in pairs(handle:GetChildren()) do
            if child:IsA("Model") then
                handlePets = handlePets + 1
                
                -- Ищем KG и AGE
                local kg = "Нет"
                local age = "Нет"
                
                for _, desc in pairs(child:GetDescendants()) do
                    if desc:IsA("StringValue") or desc:IsA("NumberValue") or desc:IsA("IntValue") then
                        if desc.Name:lower():find("kg") then
                            kg = tostring(desc.Value)
                        elseif desc.Name:lower():find("age") then
                            age = tostring(desc.Value)
                        end
                    end
                end
                
                addLog("🐾 " .. child.Name .. " | KG: " .. kg .. " | AGE: " .. age)
            end
        end
        
        if handlePets == 0 then
            addLog("📭 Handle пустой - питомцев в руке нет")
        else
            addLog("📊 Всего питомцев в handle: " .. handlePets)
        end
    else
        addLog("❌ Handle не найден у персонажа!")
    end
    
    -- Ищем инвентарь игрока (GUI с питомцами)
    addLog("\n🎒 === ПОИСК ИНВЕНТАРЯ ПИТОМЦЕВ ===")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        -- Ищем GUI элементы, которые могут содержать инвентарь
        local inventoryGuis = {}
        
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                -- Ищем фреймы с питомцами
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
                        local petCount = 0
                        for _, child in pairs(frame:GetChildren()) do
                            -- Ищем элементы, похожие на питомцев
                            if child:IsA("Frame") or child:IsA("ImageButton") then
                                for _, desc in pairs(child:GetDescendants()) do
                                    if desc:IsA("TextLabel") and (
                                        desc.Text:lower():find("dragonfly") or
                                        desc.Text:lower():find("kg") or
                                        desc.Text:lower():find("age") or
                                        desc.Text:lower():find("golden") or
                                        desc.Text:lower():find("bunny") or
                                        desc.Text:lower():find("dog")
                                    ) then
                                        petCount = petCount + 1
                                        addLog("🐾 Найден в GUI: " .. desc.Text .. " в " .. gui.Name)
                                        break
                                    end
                                end
                            end
                        end
                        
                        if petCount > 0 then
                            table.insert(inventoryGuis, {name = gui.Name, frame = frame.Name, pets = petCount})
                        end
                    end
                end
            end
        end
        
        if #inventoryGuis > 0 then
            addLog("📋 Найдены GUI с питомцами:")
            for _, inv in pairs(inventoryGuis) do
                addLog("   📱 " .. inv.name .. " (" .. inv.pets .. " питомцев)")
            end
        else
            addLog("❌ GUI инвентарь с питомцами не найден")
        end
    end
    
    -- Ищем Dragonfly конкретно
    addLog("\n🐉 === ПОИСК DRAGONFLY ===")
    local dragonflyFound = false
    
    -- В handle
    if handle then
        for _, child in pairs(handle:GetChildren()) do
            if child:IsA("Model") and child.Name:lower():find("dragonfly") then
                addLog("✅ Dragonfly найден в handle: " .. child.Name)
                dragonflyFound = true
            end
        end
    end
    
    -- В GUI
    if playerGui then
        for _, desc in pairs(playerGui:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text:lower():find("dragonfly") then
                addLog("✅ Dragonfly найден в GUI: " .. desc.Text .. " в " .. desc.Parent.Name)
                dragonflyFound = true
            end
        end
    end
    
    if not dragonflyFound then
        addLog("❌ Dragonfly не найден ни в handle, ни в GUI")
    end
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
                -- Ищем KG и AGE для каждого питомца
                local kg = "Нет"
                local age = "Нет"
                
                for _, desc in pairs(child:GetDescendants()) do
                    if desc:IsA("StringValue") or desc:IsA("NumberValue") or desc:IsA("IntValue") then
                        if desc.Name:lower():find("kg") then
                            kg = tostring(desc.Value)
                        elseif desc.Name:lower():find("age") then
                            age = tostring(desc.Value)
                        end
                    end
                end
                
                table.insert(currentContents, {
                    name = child.Name,
                    kg = kg,
                    age = age,
                    fullName = child:GetFullName()
                })
            end
        end
        
        -- Проверяем изменения (сравниваем по именам)
        local currentNames = {}
        local lastNames = {}
        
        for _, content in pairs(currentContents) do
            currentNames[content.name] = content
        end
        
        for _, content in pairs(lastHandleContents) do
            lastNames[content.name] = content
        end
        
        -- Ищем новых питомцев
        for name, content in pairs(currentNames) do
            if not lastNames[name] then
                addLog("➕ НОВЫЙ ПИТОМЕЦ В HANDLE:")
                addLog("   🐾 " .. content.name .. " | KG: " .. content.kg .. " | AGE: " .. content.age)
                
                -- Особое внимание к Dragonfly
                if content.name:lower():find("dragonfly") then
                    addLog("🐉 *** DRAGONFLY ПОЯВИЛСЯ В HANDLE! ***")
                end
            end
        end
        
        -- Ищем исчезнувших питомцев
        for name, content in pairs(lastNames) do
            if not currentNames[name] then
                addLog("➖ ПИТОМЕЦ ИСЧЕЗ ИЗ HANDLE:")
                addLog("   🗑️ " .. content.name .. " | KG: " .. content.kg .. " | AGE: " .. content.age)
            end
        end
        
        lastHandleContents = currentContents
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
    analyzePlayerInventory()
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
