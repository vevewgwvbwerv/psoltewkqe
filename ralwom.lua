-- InventorySystemAnalyzer.lua
-- Анализатор системы инвентарей: основной (10 слотов) и расширенный (все питомцы)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаем компактный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventorySystemAnalyzer"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "📦 Анализатор Системы Инвентарей"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Скролл фрейм для логов
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0.7, 0)
scrollFrame.Position = UDim2.new(0, 10, 0.1, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

-- Текст для логов
local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -10, 1, 0)
logText.Position = UDim2.new(0, 5, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = "Нажмите кнопки для анализа инвентарей..."
logText.TextColor3 = Color3.fromRGB(255, 255, 255)
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Font = Enum.Font.SourceSans
logText.TextSize = 12
logText.Parent = scrollFrame

-- Кнопки
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, 0, 0.2, 0)
buttonFrame.Position = UDim2.new(0, 0, 0.8, 0)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Кнопка анализа основного инвентаря
local mainInvButton = Instance.new("TextButton")
mainInvButton.Size = UDim2.new(0.3, -5, 0.4, 0)
mainInvButton.Position = UDim2.new(0, 5, 0.1, 0)
mainInvButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
mainInvButton.BorderSizePixel = 0
mainInvButton.Text = "📋 Основной Инвентарь"
mainInvButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainInvButton.TextScaled = true
mainInvButton.Font = Enum.Font.SourceSansBold
mainInvButton.Parent = buttonFrame

-- Кнопка анализа расширенного инвентаря
local extInvButton = Instance.new("TextButton")
extInvButton.Size = UDim2.new(0.3, -5, 0.4, 0)
extInvButton.Position = UDim2.new(0.33, 5, 0.1, 0)
extInvButton.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
extInvButton.BorderSizePixel = 0
extInvButton.Text = "🗂️ Расширенный Инвентарь"
extInvButton.TextColor3 = Color3.fromRGB(255, 255, 255)
extInvButton.TextScaled = true
extInvButton.Font = Enum.Font.SourceSansBold
extInvButton.Parent = buttonFrame

-- Кнопка поиска кнопки открытия
local findOpenButton = Instance.new("TextButton")
findOpenButton.Size = UDim2.new(0.3, -5, 0.4, 0)
findOpenButton.Position = UDim2.new(0.66, 5, 0.1, 0)
findOpenButton.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
findOpenButton.BorderSizePixel = 0
findOpenButton.Text = "🔍 Найти Кнопку Открытия"
findOpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
findOpenButton.TextScaled = true
findOpenButton.Font = Enum.Font.SourceSansBold
findOpenButton.Parent = buttonFrame

-- Кнопка очистки
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.3, -5, 0.4, 0)
clearButton.Position = UDim2.new(0.35, 0, 0.55, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
clearButton.BorderSizePixel = 0
clearButton.Text = "🗑️ Очистить"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextScaled = true
clearButton.Font = Enum.Font.SourceSansBold
clearButton.Parent = buttonFrame

-- Переменные
local logs = {}

-- Функция добавления лога
local function addLog(message)
    table.insert(logs, os.date("[%H:%M:%S] ") .. message)
    if #logs > 200 then
        table.remove(logs, 1)
    end
    
    logText.Text = table.concat(logs, "\n")
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, logText.TextBounds.Y + 20)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

-- Функция анализа основного инвентаря (10 слотов)
local function analyzeMainInventory()
    addLog("📋 === АНАЛИЗ ОСНОВНОГО ИНВЕНТАРЯ (10 СЛОТОВ) ===")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        addLog("❌ PlayerGui не найден")
        return
    end
    
    -- Ищем GUI основного инвентаря
    local mainInventoryGuis = {}
    
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- Ищем элементы, которые могут быть основным инвентарем
            for _, frame in pairs(gui:GetDescendants()) do
                if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
                    local slotCount = 0
                    local petCount = 0
                    
                    -- Считаем слоты и питомцев
                    for _, child in pairs(frame:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("ImageButton") then
                            -- Проверяем, похоже ли на слот инвентаря
                            if child.Size.X.Scale > 0.05 and child.Size.Y.Scale > 0.05 then
                                slotCount = slotCount + 1
                                
                                -- Проверяем наличие питомца в слоте
                                for _, desc in pairs(child:GetDescendants()) do
                                    if desc:IsA("TextLabel") and (
                                        desc.Text:lower():find("kg") or 
                                        desc.Text:lower():find("age") or
                                        desc.Text:lower():find("dog") or
                                        desc.Text:lower():find("bunny") or
                                        desc.Text:lower():find("golden")
                                    ) then
                                        petCount = petCount + 1
                                        addLog("🐾 Слот " .. slotCount .. ": " .. desc.Text)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Если найдено около 10 слотов, это может быть основной инвентарь
                    if slotCount >= 8 and slotCount <= 12 then
                        table.insert(mainInventoryGuis, {
                            gui = gui.Name,
                            frame = frame.Name,
                            slots = slotCount,
                            pets = petCount
                        })
                        
                        addLog("📦 Возможный основной инвентарь:")
                        addLog("   📱 GUI: " .. gui.Name)
                        addLog("   📋 Фрейм: " .. frame.Name)
                        addLog("   🎯 Слотов: " .. slotCount)
                        addLog("   🐾 Питомцев: " .. petCount)
                    end
                end
            end
        end
    end
    
    if #mainInventoryGuis == 0 then
        addLog("❌ Основной инвентарь не найден")
    else
        addLog("📊 Найдено возможных основных инвентарей: " .. #mainInventoryGuis)
    end
end

-- Функция анализа расширенного инвентаря
local function analyzeExtendedInventory()
    addLog("🗂️ === АНАЛИЗ РАСШИРЕННОГО ИНВЕНТАРЯ (ВСЕ ПИТОМЦЫ) ===")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        addLog("❌ PlayerGui не найден")
        return
    end
    
    -- Ищем BackpackGui (где мы нашли Dragonfly)
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if backpackGui then
        addLog("📱 Найден BackpackGui - анализирую структуру...")
        
        local totalPets = 0
        local dragonflyFound = false
        
        for _, desc in pairs(backpackGui:GetDescendants()) do
            if desc:IsA("TextLabel") and (
                desc.Text:lower():find("kg") or 
                desc.Text:lower():find("age")
            ) then
                totalPets = totalPets + 1
                
                if desc.Text:lower():find("dragonfly") then
                    dragonflyFound = true
                    addLog("🐉 DRAGONFLY найден: " .. desc.Text)
                    addLog("   📦 Родитель: " .. desc.Parent.Name .. " (" .. desc.Parent.ClassName .. ")")
                    
                    -- Анализируем структуру элемента Dragonfly
                    local parent = desc.Parent
                    addLog("   🔍 Дочерние элементы:")
                    for _, child in pairs(parent:GetChildren()) do
                        addLog("     - " .. child.Name .. " (" .. child.ClassName .. ")")
                    end
                end
            end
        end
        
        addLog("📊 Всего питомцев в расширенном инвентаре: " .. totalPets)
        addLog("🐉 Dragonfly найден: " .. (dragonflyFound and "ДА" or "НЕТ"))
    else
        addLog("❌ BackpackGui не найден")
    end
end

-- Функция поиска кнопки открытия расширенного инвентаря
local function findOpenButton()
    addLog("🔍 === ПОИСК КНОПКИ ОТКРЫТИЯ РАСШИРЕННОГО ИНВЕНТАРЯ ===")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        addLog("❌ PlayerGui не найден")
        return
    end
    
    -- Ищем кнопки, которые могут открывать инвентарь
    local possibleButtons = {}
    
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, desc in pairs(gui:GetDescendants()) do
                if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                    -- Ищем кнопки с текстом, связанным с инвентарем
                    local buttonText = ""
                    for _, textLabel in pairs(desc:GetDescendants()) do
                        if textLabel:IsA("TextLabel") then
                            buttonText = buttonText .. textLabel.Text:lower() .. " "
                        end
                    end
                    
                    if buttonText:find("inventory") or 
                       buttonText:find("backpack") or 
                       buttonText:find("pets") or 
                       buttonText:find("bag") or
                       desc.Name:lower():find("inventory") or
                       desc.Name:lower():find("backpack") or
                       desc.Name:lower():find("pets") then
                        
                        table.insert(possibleButtons, {
                            button = desc,
                            gui = gui.Name,
                            name = desc.Name,
                            text = buttonText:sub(1, 50)
                        })
                        
                        addLog("🔘 Возможная кнопка открытия:")
                        addLog("   📱 GUI: " .. gui.Name)
                        addLog("   🔘 Кнопка: " .. desc.Name)
                        addLog("   📝 Текст: " .. buttonText:sub(1, 50))
                        addLog("   📍 Позиция: " .. desc.AbsolutePosition.X .. ", " .. desc.AbsolutePosition.Y)
                    end
                end
            end
        end
    end
    
    if #possibleButtons == 0 then
        addLog("❌ Кнопки открытия инвентаря не найдены")
        addLog("💡 Попробуйте открыть расширенный инвентарь вручную, затем повторите анализ")
    else
        addLog("📊 Найдено возможных кнопок: " .. #possibleButtons)
    end
end

-- Обработчики кнопок
mainInvButton.MouseButton1Click:Connect(function()
    analyzeMainInventory()
end)

extInvButton.MouseButton1Click:Connect(function()
    analyzeExtendedInventory()
end)

findOpenButton.MouseButton1Click:Connect(function()
    findOpenButton()
end)

clearButton.MouseButton1Click:Connect(function()
    logs = {}
    logText.Text = "Логи очищены..."
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Начальное сообщение
addLog("🚀 Анализатор системы инвентарей запущен!")
addLog("📋 Нажмите 'Основной Инвентарь' для анализа 10-слотового инвентаря")
addLog("🗂️ Нажмите 'Расширенный Инвентарь' для анализа BackpackGui")
addLog("🔍 Нажмите 'Найти Кнопку Открытия' для поиска кнопки расширенного инвентаря")

print("✅ InventorySystemAnalyzer загружен! Анализируйте структуру инвентарей.")
