-- DragonflySwitcherV2.lua
-- Правильный переключатель Dragonfly на основе анализа событий

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Создаем компактный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DragonflySwitcherV2"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм
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
titleLabel.Text = "🐉 Dragonfly Switcher V2"
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
switchButton.Text = "🔄 Переключить на Dragonfly"
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

-- Функция поиска Dragonfly TextButton
local function findDragonflyButton()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return nil end
    
    -- Ищем TextButton с именем "23" (из анализа событий)
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("TextButton") and desc.Name == "23" then
            -- Проверяем, что это действительно Dragonfly
            for _, child in pairs(desc:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text:lower():find("dragonfly") then
                    print("✅ Найден Dragonfly TextButton:", desc.Name)
                    return desc
                end
            end
        end
    end
    
    print("❌ Dragonfly TextButton не найден")
    return nil
end

-- Функция симуляции клика через VirtualInputManager
local function simulateRealClick(button)
    if not button then return false end
    
    print("🖱️ Симулирую реальный клик по кнопке:", button.Name)
    
    -- Получаем абсолютную позицию кнопки на экране
    local absolutePos = button.AbsolutePosition
    local absoluteSize = button.AbsoluteSize
    
    -- Вычисляем центр кнопки
    local centerX = absolutePos.X + absoluteSize.X / 2
    local centerY = absolutePos.Y + absoluteSize.Y / 2
    
    print("📍 Позиция клика:", centerX, centerY)
    
    -- Симулируем реальный клик мыши
    local success, error = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
    end)
    
    if success then
        print("✅ Реальный клик симулирован успешно")
        return true
    else
        print("⚠️ Ошибка симуляции реального клика:", error)
        return false
    end
end

-- Функция программного вызова события
local function triggerClickEvent(button)
    if not button then return false end
    
    print("🎯 Программно вызываю событие MouseButton1Click")
    
    -- Создаем фиктивный InputObject
    local fakeInputObject = {
        UserInputType = Enum.UserInputType.MouseButton1,
        UserInputState = Enum.UserInputState.Begin,
        Position = Vector3.new(0, 0, 0),
        Delta = Vector3.new(0, 0, 0),
        KeyCode = Enum.KeyCode.Unknown
    }
    
    -- Пробуем разные способы активации события
    local methods = {
        function()
            -- Способ 1: Прямой вызов через getconnections (если доступно)
            local connections = getconnections and getconnections(button.MouseButton1Click) or {}
            for _, connection in pairs(connections) do
                if connection.Function then
                    connection.Function()
                    return true
                end
            end
            return false
        end,
        
        function()
            -- Способ 2: Симуляция через GuiService
            local GuiService = game:GetService("GuiService")
            if GuiService.SelectedObject ~= button then
                GuiService.SelectedObject = button
            end
            wait(0.1)
            -- Попробуем активировать выбранный объект
            return true
        end,
        
        function()
            -- Способ 3: Изменение свойств для активации скриптов
            local originalActive = button.Active
            button.Active = false
            wait(0.05)
            button.Active = true
            wait(0.05)
            button.Active = originalActive
            return true
        end
    }
    
    for i, method in pairs(methods) do
        local success, result = pcall(method)
        if success and result then
            print("✅ Метод", i, "сработал успешно")
            return true
        else
            print("⚠️ Метод", i, "не сработал:", result or "неизвестная ошибка")
        end
    end
    
    return false
end

-- Функция удаления текущего питомца из handle
local function removeCurrentPetFromHandle()
    local playerChar = player.Character
    if not playerChar then return false end
    
    local handle = playerChar:FindFirstChild("Handle")
    if not handle then return false end
    
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
local function switchToDragonfly()
    statusLabel.Text = "🔍 Ищу Dragonfly кнопку..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    -- Шаг 1: Найти Dragonfly кнопку
    local dragonflyButton = findDragonflyButton()
    if not dragonflyButton then
        statusLabel.Text = "❌ Dragonfly кнопка не найдена"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    -- Шаг 2: Убрать текущего питомца из handle
    statusLabel.Text = "🗑️ Убираю текущего питомца..."
    removeCurrentPetFromHandle()
    wait(0.5)
    
    -- Шаг 3: Попробовать реальный клик
    statusLabel.Text = "🖱️ Симулирую реальный клик..."
    local realClickSuccess = simulateRealClick(dragonflyButton)
    
    if not realClickSuccess then
        -- Шаг 4: Попробовать программный вызов события
        statusLabel.Text = "🎯 Программно активирую событие..."
        triggerClickEvent(dragonflyButton)
    end
    
    -- Шаг 5: Проверить результат
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
        switchToDragonfly()
        
        wait(2)
        switchButton.Text = "🔄 Переключить на Dragonfly"
        switchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
end)

print("✅ DragonflySwitcherV2 загружен! Использует данные анализа событий.")
