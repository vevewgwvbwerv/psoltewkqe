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
    if not playerGui then 
        print("❌ PlayerGui не найден")
        return nil 
    end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then
        print("❌ BackpackGui не найден")
        
        -- Попробуем найти другие GUI с похожими именами
        print("🔍 Ищу альтернативные GUI...")
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (
                gui.Name:lower():find("backpack") or 
                gui.Name:lower():find("inventory") or 
                gui.Name:lower():find("pet")
            ) then
                print("📱 Найден альтернативный GUI:", gui.Name)
                backpackGui = gui
                break
            end
        end
        
        if not backpackGui then
            return nil
        end
    end
    
    print("📱 Сканирую GUI:", backpackGui.Name)
    
    -- Ищем элемент с Dragonfly
    local dragonflyElements = {}
    
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text:lower():find("dragonfly") then
            local element = {
                textLabel = desc,
                text = desc.Text,
                parent = desc.Parent,
                parentName = desc.Parent.Name,
                parentType = desc.Parent.ClassName
            }
            table.insert(dragonflyElements, element)
            print("🐾 Найден Dragonfly элемент:")
            print("   📝 Текст:", desc.Text)
            print("   📦 Родитель:", desc.Parent.Name, "(" .. desc.Parent.ClassName .. ")")
        end
    end
    
    if #dragonflyElements == 0 then
        print("❌ Dragonfly не найден в", backpackGui.Name)
        return nil
    end
    
    -- Возвращаем первый найденный элемент
    local bestElement = dragonflyElements[1]
    print("✅ Выбран Dragonfly элемент:", bestElement.text)
    print("   🎯 Целевой элемент:", bestElement.parentName, "(" .. bestElement.parentType .. ")")
    
    return bestElement.parent
end

-- Функция симуляции клика по элементу GUI
local function simulateClick(guiElement)
    if not guiElement then return false end
    
    print("🔍 Анализирую элемент:", guiElement.Name, "Тип:", guiElement.ClassName)
    
    -- Способ 1: Прямое изменение свойств для активации
    local success1, error1 = pcall(function()
        if guiElement:IsA("GuiButton") or guiElement:IsA("TextButton") or guiElement:IsA("ImageButton") then
            print("🖱️ Пробую активировать кнопку через свойства:", guiElement.Name)
            
            -- Изменяем свойства, которые могут вызвать активацию
            local originalActive = guiElement.Active
            local originalVisible = guiElement.Visible
            
            guiElement.Active = false
            wait(0.1)
            guiElement.Active = true
            wait(0.1)
            guiElement.Active = originalActive
            
            return true
        end
    end)
    
    if success1 then
        print("✅ Активация через свойства успешна")
        return true
    else
        print("⚠️ Ошибка активации через свойства:", error1)
    end
    
    -- Способ 2: Поиск и активация дочерних кнопок
    print("🔍 Ищу кликабельные дочерние элементы в:", guiElement.Name)
    for _, child in pairs(guiElement:GetChildren()) do
        if child:IsA("GuiButton") or child:IsA("TextButton") or child:IsA("ImageButton") then
            print("🖱️ Найдена кнопка в элементе:", child.Name)
            local childResult = simulateClick(child)
            if childResult then
                return true
            end
        end
    end
    
    -- Способ 3: Попробуем найти RemoteEvent или RemoteFunction
    print("🔍 Ищу Remote объекты...")
    for _, desc in pairs(guiElement:GetDescendants()) do
        if desc:IsA("RemoteEvent") then
            print("📡 Найден RemoteEvent:", desc.Name)
            local success3, error3 = pcall(function()
                desc:FireServer()
            end)
            if success3 then
                print("✅ RemoteEvent активирован")
                return true
            else
                print("⚠️ Ошибка активации RemoteEvent:", error3)
            end
        elseif desc:IsA("RemoteFunction") then
            print("📡 Найден RemoteFunction:", desc.Name)
            local success4, error4 = pcall(function()
                desc:InvokeServer()
            end)
            if success4 then
                print("✅ RemoteFunction активирован")
                return true
            else
                print("⚠️ Ошибка активации RemoteFunction:", error4)
            end
        end
    end
    
    -- Способ 4: Информация о найденных скриптах (для диагностики)
    print("🔍 Диагностика скриптов в элементе...")
    for _, desc in pairs(guiElement:GetDescendants()) do
        if desc:IsA("LocalScript") or desc:IsA("Script") then
            print("📜 Найден скрипт:", desc.Name, "в", desc.Parent.Name)
        end
    end
    
    print("❌ Не удалось активировать элемент:", guiElement.Name)
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
