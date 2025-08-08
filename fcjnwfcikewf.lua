-- DragonflySwitcher.lua
-- Скрипт для автоматического перемещения Dragonfly из BackpackGui в handle

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаем компактный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DragonflySwitcher"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм (компактный)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
mainFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🐉 Dragonfly Switcher"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Кнопка переключения
local switchButton = Instance.new("TextButton")
switchButton.Size = UDim2.new(0.8, 0, 0.4, 0)
switchButton.Position = UDim2.new(0.1, 0, 0.4, 0)
switchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
switchButton.BorderSizePixel = 0
switchButton.Text = "🔄 Переместить Dragonfly в руку"
switchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
switchButton.TextScaled = true
switchButton.Font = Enum.Font.SourceSansBold
switchButton.Parent = mainFrame

-- Статус лейбл
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.3, 0)
statusLabel.Position = UDim2.new(0, 0, 0.7, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Готов к переключению"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = mainFrame

-- Функция поиска Dragonfly в BackpackGui
local function findDragonflyInGui()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then
        print("❌ BackpackGui не найден")
        return nil
    end
    
    -- Ищем элемент с Dragonfly
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text:lower():find("dragonfly") then
            print("✅ Найден Dragonfly в GUI:", desc.Text)
            return desc.Parent -- Возвращаем родительский элемент (кнопку/фрейм)
        end
    end
    
    print("❌ Dragonfly не найден в BackpackGui")
    return nil
end

-- Функция симуляции клика по элементу GUI
local function simulateClick(guiElement)
    if not guiElement then return false end
    
    -- Пробуем разные способы активации
    if guiElement:IsA("GuiButton") then
        -- Если это кнопка, симулируем клик
        print("🖱️ Симулирую клик по кнопке:", guiElement.Name)
        
        -- Способ 1: Прямая активация события
        if guiElement.MouseButton1Click then
            guiElement.MouseButton1Click:Fire()
            return true
        end
        
        -- Способ 2: Симуляция через UserInputService (если доступно)
        local success, error = pcall(function()
            guiElement.MouseButton1Down:Fire()
            wait(0.1)
            guiElement.MouseButton1Up:Fire()
        end)
        
        if success then
            print("✅ Клик симулирован успешно")
            return true
        else
            print("⚠️ Ошибка симуляции клика:", error)
        end
    end
    
    -- Если это Frame с кликабельными детьми
    for _, child in pairs(guiElement:GetChildren()) do
        if child:IsA("GuiButton") then
            print("🖱️ Найдена кнопка в элементе:", child.Name)
            return simulateClick(child)
        end
    end
    
    return false
end

-- Функция удаления текущего питомца из handle
local function removeCurrentPetFromHandle()
    local playerChar = player.Character
    if not playerChar then return false end
    
    local handle = playerChar:FindFirstChild("Handle")
    if not handle then 
        print("❌ Handle не найден")
        return false 
    end
    
    -- Удаляем всех питомцев из handle (кроме Dragonfly)
    local removed = false
    for _, child in pairs(handle:GetChildren()) do
        if child:IsA("Model") and not child.Name:lower():find("dragonfly") then
            print("🗑️ Убираю из handle:", child.Name)
            child:Destroy()
            removed = true
        end
    end
    
    return removed
end

-- Функция проверки появления Dragonfly в handle
local function checkDragonflyInHandle()
    local playerChar = player.Character
    if not playerChar then return false end
    
    local handle = playerChar:FindFirstChild("Handle")
    if not handle then return false end
    
    for _, child in pairs(handle:GetChildren()) do
        if child:IsA("Model") and child.Name:lower():find("dragonfly") then
            print("✅ Dragonfly найден в handle!")
            return true
        end
    end
    
    return false
end

-- Основная функция переключения
local function switchTodragonfly()
    statusLabel.Text = "🔍 Ищу Dragonfly..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    -- Шаг 1: Найти Dragonfly в GUI
    local dragonflyElement = findDragonflyInGui()
    if not dragonflyElement then
        statusLabel.Text = "❌ Dragonfly не найден в GUI"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    -- Шаг 2: Убрать текущего питомца из handle
    statusLabel.Text = "🗑️ Убираю текущего питомца..."
    removeCurrentPetFromHandle()
    wait(0.5)
    
    -- Шаг 3: Симулировать клик по Dragonfly
    statusLabel.Text = "🖱️ Активирую Dragonfly..."
    local clickSuccess = simulateClick(dragonflyElement)
    
    if not clickSuccess then
        statusLabel.Text = "⚠️ Не удалось активировать Dragonfly"
        statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        return
    end
    
    -- Шаг 4: Проверить результат
    wait(1)
    statusLabel.Text = "✅ Проверяю результат..."
    
    if checkDragonflyInHandle() then
        statusLabel.Text = "🎉 Dragonfly успешно в руке!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "❌ Dragonfly не появился в руке"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Обработчик кнопки
switchButton.MouseButton1Click:Connect(function()
    switchButton.Text = "⏳ Переключаю..."
    switchButton.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
    
    spawn(function()
        switchTodragonfly()
        
        wait(2)
        switchButton.Text = "🔄 Переместить Dragonfly в руку"
        switchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
end)

print("✅ DragonflySwitcher загружен! Нажмите кнопку для переключения.")
