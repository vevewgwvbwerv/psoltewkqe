-- DragonflyTransfer.lua
-- Автоматический перенос Dragonfly из расширенного инвентаря в основной

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Создаем компактный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DragonflyTransfer"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.8, 0, 0.4, 0)
mainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🐉 Dragonfly Transfer System"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Кнопка переноса
local transferButton = Instance.new("TextButton")
transferButton.Size = UDim2.new(0.8, 0, 0.3, 0)
transferButton.Position = UDim2.new(0.1, 0, 0.3, 0)
transferButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
transferButton.BorderSizePixel = 0
transferButton.Text = "🔄 Перенести Dragonfly в основной инвентарь"
transferButton.TextColor3 = Color3.fromRGB(255, 255, 255)
transferButton.TextScaled = true
transferButton.Font = Enum.Font.SourceSansBold
transferButton.Parent = mainFrame

-- Статус лейбл
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Готов к переносу Dragonfly\nИз расширенного инвентаря в основной (слот 1 или 2)"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Функция поиска основного инвентаря (Hotbar)
local function findMainInventory()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        print("❌ PlayerGui не найден")
        return nil 
    end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then 
        print("❌ BackpackGui не найден")
        return nil 
    end
    
    print("📱 BackpackGui найден, ищу Hotbar...")
    
    -- Ищем Hotbar в BackpackGui (точный путь из анализа)
    local hotbar = backpackGui:FindFirstChild("Hotbar")
    if hotbar then
        print("✅ Найден основной инвентарь (Hotbar) с 10 слотами")
        return hotbar
    end
    
    print("❌ Hotbar не найден в BackpackGui")
    return nil
end

-- Функция поиска расширенного инвентаря с Dragonfly
local function findDragonflyInExtended()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        print("❌ PlayerGui не найден для поиска Dragonfly")
        return nil 
    end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then 
        print("❌ BackpackGui не найден для поиска Dragonfly")
        return nil 
    end
    
    -- Ищем CategoryFrame в расширенном инвентаре (точный путь из анализа)
    local inventory = backpackGui:FindFirstChild("Inventory")
    if not inventory then
        print("❌ Inventory не найден в BackpackGui")
        return nil
    end
    
    local categoryFrame = inventory:FindFirstChild("CategoryFrame")
    if not categoryFrame then
        print("❌ CategoryFrame не найден в Inventory")
        return nil
    end
    
    print("🔍 Ищу Dragonfly в CategoryFrame...")
    
    -- Ищем кнопку с Dragonfly в CategoryFrame
    for _, child in pairs(categoryFrame:GetChildren()) do
        if child:IsA("TextButton") then
            -- Проверяем содержимое кнопки
            for _, desc in pairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text:lower():find("dragonfly") then
                    print("✅ Найден Dragonfly в расширенном инвентаре:", desc.Text)
                    print("   📍 Кнопка:", child.Name, "в CategoryFrame")
                    return child
                end
            end
        end
    end
    
    print("❌ Dragonfly не найден в CategoryFrame")
    return nil
end

-- Функция поиска пустого слота в основном инвентаре
local function findEmptySlotInMain(hotbar)
    if not hotbar then 
        print("❌ Hotbar не передан")
        return nil 
    end
    
    print("🔍 Ищу слоты для замены в Hotbar...")
    
    -- Ищем слоты 1 и 2 (обычно содержат предметы, не питомцев)
    for _, child in pairs(hotbar:GetChildren()) do
        if child:IsA("TextButton") and (child.Name == "1" or child.Name == "2") then
            -- Проверяем содержимое слота
            local itemText = ""
            local hasPet = false
            
            for _, desc in pairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text ~= "" then
                    itemText = desc.Text
                    -- Проверяем, это питомец или предмет
                    if desc.Text:lower():find("kg") and desc.Text:lower():find("age") then
                        hasPet = true
                    end
                    break
                end
            end
            
            if not hasPet and itemText ~= "" then
                print("✅ Найден слот с предметом для замены:", child.Name, "(" .. itemText .. ")")
                return child
            end
        end
    end
    
    print("❌ Подходящие слоты (1 или 2) не найдены")
    return nil
end

-- Функция симуляции drag-and-drop
local function simulateDragAndDrop(source, target)
    if not source or not target then return false end
    
    print("🖱️ Симулирую drag-and-drop:")
    print("   📤 Источник:", source.Name, "в", source.Parent.Name)
    print("   📥 Цель:", target.Name, "в", target.Parent.Name)
    
    -- Получаем позиции элементов
    local sourcePos = source.AbsolutePosition
    local sourceSize = source.AbsoluteSize
    local targetPos = target.AbsolutePosition
    local targetSize = target.AbsoluteSize
    
    -- Вычисляем центры элементов
    local sourceCenterX = sourcePos.X + sourceSize.X / 2
    local sourceCenterY = sourcePos.Y + sourceSize.Y / 2
    local targetCenterX = targetPos.X + targetSize.X / 2
    local targetCenterY = targetPos.Y + targetSize.Y / 2
    
    print("   📍 Источник центр:", sourceCenterX, sourceCenterY)
    print("   📍 Цель центр:", targetCenterX, targetCenterY)
    
    -- Симулируем drag-and-drop
    local success, error = pcall(function()
        -- Начинаем перетаскивание
        VirtualInputManager:SendMouseButtonEvent(sourceCenterX, sourceCenterY, 0, true, game, 1)
        wait(0.1)
        
        -- Перемещаем к цели
        VirtualInputManager:SendMouseMoveEvent(targetCenterX, targetCenterY, game)
        wait(0.2)
        
        -- Отпускаем
        VirtualInputManager:SendMouseButtonEvent(targetCenterX, targetCenterY, 0, false, game, 1)
        wait(0.1)
    end)
    
    if success then
        print("✅ Drag-and-drop симулирован успешно")
        return true
    else
        print("⚠️ Ошибка симуляции drag-and-drop:", error)
        return false
    end
end

-- Функция альтернативного метода через клики
local function alternativeTransferMethod(dragonflyButton, targetSlot)
    print("🎯 Пробую альтернативный метод через клики...")
    
    -- Метод 1: Двойной клик по Dragonfly
    local success1, error1 = pcall(function()
        local pos = dragonflyButton.AbsolutePosition
        local size = dragonflyButton.AbsoluteSize
        local centerX = pos.X + size.X / 2
        local centerY = pos.Y + size.Y / 2
        
        -- Двойной клик
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
    end)
    
    if success1 then
        print("✅ Двойной клик по Dragonfly выполнен")
        return true
    end
    
    -- Метод 2: Правый клик + левый клик на цель
    local success2, error2 = pcall(function()
        local sourcePos = dragonflyButton.AbsolutePosition
        local sourceSize = dragonflyButton.AbsoluteSize
        local sourceCenterX = sourcePos.X + sourceSize.X / 2
        local sourceCenterY = sourcePos.Y + sourceSize.Y / 2
        
        -- Правый клик на источник
        VirtualInputManager:SendMouseButtonEvent(sourceCenterX, sourceCenterY, 1, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(sourceCenterX, sourceCenterY, 1, false, game, 1)
        wait(0.2)
        
        -- Левый клик на цель
        local targetPos = targetSlot.AbsolutePosition
        local targetSize = targetSlot.AbsoluteSize
        local targetCenterX = targetPos.X + targetSize.X / 2
        local targetCenterY = targetPos.Y + targetSize.Y / 2
        
        VirtualInputManager:SendMouseButtonEvent(targetCenterX, targetCenterY, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(targetCenterX, targetCenterY, 0, false, game, 1)
    end)
    
    if success2 then
        print("✅ Правый клик + левый клик выполнен")
        return true
    end
    
    return false
end

-- Функция проверки успешности переноса
local function checkTransferSuccess()
    wait(1)
    
    local hotbar = findMainInventory()
    if not hotbar then return false end
    
    -- Проверяем слоты 1 и 2 на наличие Dragonfly
    for _, child in pairs(hotbar:GetChildren()) do
        if child:IsA("TextButton") and (child.Name == "1" or child.Name == "2") then
            for _, desc in pairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text:lower():find("dragonfly") then
                    print("🎉 Dragonfly успешно перенесен в слот:", child.Name)
                    return true
                end
            end
        end
    end
    
    return false
end

-- Основная функция переноса
local function transferDragonfly()
    statusLabel.Text = "🔍 Поиск инвентарей..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    -- Шаг 1: Найти основной инвентарь
    local hotbar = findMainInventory()
    if not hotbar then
        statusLabel.Text = "❌ Основной инвентарь не найден"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    -- Шаг 2: Найти Dragonfly в расширенном инвентаре
    statusLabel.Text = "🐉 Поиск Dragonfly..."
    local dragonflyButton = findDragonflyInExtended()
    if not dragonflyButton then
        statusLabel.Text = "❌ Dragonfly не найден в расширенном инвентаре"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    -- Шаг 3: Найти пустой слот в основном инвентаре
    statusLabel.Text = "📦 Поиск пустого слота..."
    local emptySlot = findEmptySlotInMain(hotbar)
    if not emptySlot then
        statusLabel.Text = "❌ Пустые слоты не найдены"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    -- Шаг 4: Выполнить перенос
    statusLabel.Text = "🔄 Переношу Dragonfly..."
    
    -- Пробуем drag-and-drop
    local dragSuccess = simulateDragAndDrop(dragonflyButton, emptySlot)
    
    if not dragSuccess then
        -- Пробуем альтернативные методы
        statusLabel.Text = "🎯 Пробую альтернативные методы..."
        alternativeTransferMethod(dragonflyButton, emptySlot)
    end
    
    -- Шаг 5: Проверить результат
    statusLabel.Text = "✅ Проверяю результат..."
    
    if checkTransferSuccess() then
        statusLabel.Text = "🎉 Dragonfly успешно перенесен в основной инвентарь!\nТеперь его можно выбрать в руку."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "❌ Перенос не удался\nПопробуйте перенести Dragonfly вручную"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Обработчик кнопки
transferButton.MouseButton1Click:Connect(function()
    transferButton.Text = "⏳ Переношу..."
    transferButton.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
    
    spawn(function()
        transferDragonfly()
        
        wait(2)
        transferButton.Text = "🔄 Перенести Dragonfly в основной инвентарь"
        transferButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
end)

print("✅ DragonflyTransfer загружен! Перенесет Dragonfly в основной инвентарь.")
