-- DirectShovelFix.lua
-- ПРЯМОЕ РЕШЕНИЕ: Меняем содержимое Shovel на содержимое питомца

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== DIRECT SHOVEL FIX ===")

-- Глобальные переменные
local petTool = nil

-- Поиск питомца в руках
local function findPetInHands()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- Поиск Shovel в руках
local function findShovelInHands()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name, "Shovel") or string.find(tool.Name, "Destroy")) then
            return tool
        end
    end
    return nil
end

-- СОХРАНИТЬ питомца
local function savePet()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Сохраняем ссылку на питомца
    petTool = pet
    
    print("✅ Питомец сохранен!")
    return true
end

-- ПРЯМАЯ ЗАМЕНА содержимого
local function directReplace()
    print("\n🔄 === ПРЯМАЯ ЗАМЕНА СОДЕРЖИМОГО ===")
    
    if not petTool then
        print("❌ Сначала сохраните питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🔧 Меняю содержимое Shovel на содержимое питомца...")
    
    -- Шаг 1: Меняем имя
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("📝 Имя изменено: " .. shovel.Name)
    
    -- Шаг 2: Копируем свойства Tool
    shovel.RequiresHandle = petTool.RequiresHandle
    shovel.CanBeDropped = petTool.CanBeDropped
    shovel.ManualActivationOnly = petTool.ManualActivationOnly
    print("🔧 Свойства Tool скопированы")
    
    -- Шаг 3: Удаляем все содержимое Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end
    
    wait(0.1)
    
    -- Шаг 4: Копируем все содержимое питомца
    print("📋 Копирую содержимое питомца...")
    for _, child in pairs(petTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = shovel
        print("   ✅ Скопировано: " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel ПОЛНОСТЬЮ заменен содержимым питомца!")
    print("📝 Новое имя: " .. shovel.Name)
    print("🎮 В руках должен быть питомец с именем Dragonfly!")
    
    return true
end

-- АЛЬТЕРНАТИВА С CFRAME АНИМАЦИЕЙ: Создание с анимацией питомца
local function alternativeReplace()
    print("\n🔄 === АЛЬТЕРНАТИВНАЯ ЗАМЕНА С АНИМАЦИЕЙ ===")
    
    if not petTool then
        print("❌ Сначала сохраните питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🎬 Альтернативная замена с CFrame анимацией...")
    
    -- Создаем новый Tool на основе питомца (БЕЗ изменения CFrame)
    local newTool = Instance.new("Tool")
    newTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    newTool.RequiresHandle = true
    newTool.CanBeDropped = true
    newTool.ManualActivationOnly = false
    
    print("🔧 Копирую содержимое питомца...")
    
    -- Копируем содержимое питомца
    for _, child in pairs(petTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = newTool
        print("   ✅ Скопировано: " .. child.Name)
    end
    
    -- Удаляем Shovel
    print("🗑️ Удаляю Shovel...")
    shovel:Destroy()
    
    wait(0.2)
    
    -- Добавляем новый Tool в Backpack сначала
    print("📦 Добавляю в Backpack...")
    local backpack = character:FindFirstChild("Backpack")
    if not backpack then
        backpack = Instance.new("Backpack")
        backpack.Parent = character
    end
    
    newTool.Parent = backpack
    
    wait(0.1)
    
    -- Затем перемещаем в руки
    print("🎮 Перемещаю в руки...")
    newTool.Parent = character
    
    wait(0.3)
    
    -- Добавляем CFrame анимацию питомца
    print("🎬 Запускаю CFrame анимацию питомца...")
    startPetAnimation(newTool)
    
    print("✅ Альтернативная замена с анимацией завершена!")
    print("🎭 Копия должна анимироваться как питомец!")
    return true
end

-- ФУНКЦИЯ CFRAME АНИМАЦИИ питомца
local animationConnection = nil

local function startPetAnimation(tool)
    if not tool then return end
    
    print("🎬 === ЗАПУСК CFRAME АНИМАЦИИ ===")
    
    -- Останавливаем предыдущую анимацию
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
        print("⏹️ Остановлена предыдущая анимация")
    end
    
    -- Находим все части питомца
    local petParts = {}
    local partCount = 0
    for _, child in pairs(tool:GetDescendants()) do
        if child:IsA("BasePart") and child.Name ~= "Handle" then
            petParts[child.Name] = {
                part = child,
                originalCFrame = child.CFrame,
                time = math.random() * 10 -- Случайное начальное время для разнообразия
            }
            partCount = partCount + 1
        end
    end
    
    print(string.format("🎭 Найдено %d частей для анимации", partCount))
    
    -- Запускаем анимацию
    local RunService = game:GetService("RunService")
    animationConnection = RunService.Heartbeat:Connect(function()
        local time = tick()
        
        for partName, data in pairs(petParts) do
            if data.part and data.part.Parent then
                -- Проверяем что часть все еще существует
                local success, err = pcall(function()
                    -- Простая idle анимация (покачивание)
                    local offsetY = math.sin(time * 2 + data.time) * 0.1
                    local offsetX = math.cos(time * 1.5 + data.time) * 0.05
                    
                    -- Применяем анимацию без нарушения физики
                    local newCFrame = data.originalCFrame * CFrame.new(offsetX, offsetY, 0)
                    data.part.CFrame = newCFrame
                end)
                
                if not success then
                    print("⚠️ Ошибка анимации части " .. partName .. ": " .. tostring(err))
                end
                
                -- Обновляем базовое положение периодически
                data.time = data.time + 0.01
            end
        end
    end)
    
    print("✅ CFrame анимация запущена!")
    print("🎭 Питомец должен покачиваться (idle анимация)")
end

-- ФУНКЦИЯ ОСТАНОВКИ АНИМАЦИИ
local function stopPetAnimation()
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
        print("⏹️ CFrame анимация остановлена")
        return true
    end
    return false
end

-- Создаем GUI
local function createDirectFixGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 350)
    frame.Position = UDim2.new(0.5, -200, 0.5, -175)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🎯 DIRECT SHOVEL FIX"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "ПРОСТОЕ РЕШЕНИЕ:\n1. Возьмите питомца → Сохранить\n2. Возьмите Shovel → Заменить\nБЕЗ СЛОЖНОСТЕЙ!"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -20, 0, 50)
    saveBtn.Position = UDim2.new(0, 10, 0, 140)
    saveBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "💾 Сохранить питомца"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка прямой замены
    local directBtn = Instance.new("TextButton")
    directBtn.Size = UDim2.new(1, -20, 0, 50)
    directBtn.Position = UDim2.new(0, 10, 0, 200)
    directBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    directBtn.BorderSizePixel = 0
    directBtn.Text = "🔄 ПРЯМАЯ ЗАМЕНА"
    directBtn.TextColor3 = Color3.new(1, 1, 1)
    directBtn.TextScaled = true
    directBtn.Font = Enum.Font.SourceSansBold
    directBtn.Visible = false
    directBtn.Parent = frame
    
    -- Кнопка альтернативы с анимацией
    local altBtn = Instance.new("TextButton")
    altBtn.Size = UDim2.new(1, -20, 0, 50)
    altBtn.Position = UDim2.new(0, 10, 0, 260)
    altBtn.BackgroundColor3 = Color3.new(0.6, 0, 0.8)
    altBtn.BorderSizePixel = 0
    altBtn.Text = "🎬 АЛЬТЕРНАТИВА + АНИМАЦИЯ"
    altBtn.TextColor3 = Color3.new(1, 1, 1)
    altBtn.TextScaled = true
    altBtn.Font = Enum.Font.SourceSansBold
    altBtn.Visible = false
    altBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 30)
    closeBtn.Position = UDim2.new(0, 10, 0, 310)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сохраняю питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = savePet()
        
        if success then
            status.Text = "✅ Питомец сохранен!\nТеперь возьмите Shovel и замените!"
            status.TextColor3 = Color3.new(0, 1, 0)
            directBtn.Visible = true
            altBtn.Visible = true
        else
            status.Text = "❌ Ошибка!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    directBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Прямая замена содержимого..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = directReplace()
        
        if success then
            status.Text = "✅ ЗАМЕНА ЗАВЕРШЕНА!\nShovel = Питомец!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    altBtn.MouseButton1Click:Connect(function()
        status.Text = "🎬 Альтернативная замена + анимация...\nСоздаю копию с CFrame анимацией..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = alternativeReplace()
        
        if success then
            status.Text = "✅ АЛЬТЕРНАТИВА + АНИМАЦИЯ ЗАВЕРШЕНА!\nКопия анимируется как питомец!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка альтернативы с анимацией!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Запускаем
createDirectFixGUI()
print("✅ DirectShovelFix готов!")
print("🎯 ПРОСТОЕ РЕШЕНИЕ БЕЗ СЛОЖНОСТЕЙ!")
print("💾 1. Сохранить питомца")
print("🔄 2. Заменить Shovel")
