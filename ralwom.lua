-- ProperShovelReplacer.lua
-- ПРАВИЛЬНАЯ замена Shovel на питомца с корректным CFrame
-- Основано на логике из PetScaler_v3.226

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== PROPER SHOVEL REPLACER ===")

-- Глобальные переменные
local savedPetTool = nil
local savedPetCFrame = nil
local animationConnection = nil

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

-- СОХРАНИТЬ питомца с правильным CFrame
local function savePetWithCFrame()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА С CFRAME ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Сохраняем ссылку на питомца
    savedPetTool = pet
    
    -- Сохраняем CFrame PrimaryPart питомца (КЛЮЧЕВОЕ!)
    if pet.PrimaryPart then
        savedPetCFrame = pet.PrimaryPart.CFrame
        print("💾 Сохранен CFrame PrimaryPart:")
        print("   Position:", savedPetCFrame.Position)
        print("   UpVector:", savedPetCFrame.UpVector)
        print("   LookVector:", savedPetCFrame.LookVector)
    else
        -- Если нет PrimaryPart, ищем Handle
        local handle = pet:FindFirstChild("Handle")
        if handle then
            savedPetCFrame = handle.CFrame
            print("💾 Сохранен CFrame Handle:")
            print("   Position:", savedPetCFrame.Position)
            print("   UpVector:", savedPetCFrame.UpVector)
        else
            print("❌ Не найден ни PrimaryPart, ни Handle!")
            return false
        end
    end
    
    print("✅ Питомец и его CFrame сохранены!")
    return true
end

-- ПРАВИЛЬНАЯ ЗАМЕНА с копированием CFrame из PetScaler_v3.226
local function properReplace()
    print("\n🔄 === ПРАВИЛЬНАЯ ЗАМЕНА С CFRAME ===")
    
    if not savedPetTool or not savedPetCFrame then
        print("❌ Сначала сохраните питомца с CFrame!")
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
    print("🔧 Правильная замена с копированием CFrame...")
    
    -- Создаем новый Tool на основе питомца
    local newTool = Instance.new("Tool")
    newTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    newTool.RequiresHandle = true
    newTool.CanBeDropped = true
    newTool.ManualActivationOnly = false
    
    print("🔧 Копирую содержимое питомца...")
    
    -- Копируем содержимое питомца
    for _, child in pairs(savedPetTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = newTool
        print("   ✅ Скопировано: " .. child.Name)
    end
    
    -- КЛЮЧЕВАЯ ЧАСТЬ: Устанавливаем правильный CFrame
    print("🎯 Устанавливаю правильный CFrame...")
    
    -- Находим PrimaryPart или Handle в новом Tool
    local targetPart = newTool.PrimaryPart or newTool:FindFirstChild("Handle")
    if targetPart then
        print("📍 Найдена целевая часть: " .. targetPart.Name)
        
        -- ИСПОЛЬЗУЕМ ЛОГИКУ ИЗ PetScaler_v3.226
        local currentPos = targetPart.Position
        
        -- ЭТАП 1: ПОДНИМАЕМ НА ПРАВИЛЬНУЮ ВЫСОТУ (как в PetScaler)
        local correctedPosition = Vector3.new(
            currentPos.X,
            currentPos.Y + 1.33,  -- Поднимаем как Roblox
            currentPos.Z
        )
        
        -- ЭТАП 2: КОПИРУЕМ ТОЧНУЮ ОРИЕНТАЦИЮ СОХРАНЕННОГО ПИТОМЦА
        local exactCFrame = CFrame.lookAt(
            correctedPosition,
            correctedPosition + savedPetCFrame.LookVector,  -- Точный LookVector
            savedPetCFrame.UpVector  -- Точный UpVector
        )
        
        -- Применяем точное копирование
        targetPart.CFrame = exactCFrame
        
        print("✅ ПРИМЕНЕНО ТОЧНОЕ КОПИРОВАНИЕ CFrame!")
        print("📊 Поднято на +1.33 стада")
        print("🦴 Скопирована ориентация сохраненного питомца")
        
        -- Проверка после применения
        wait(0.1)
        local immediateCheck = targetPart.CFrame
        print("\n🔍 ПРОВЕРКА ПОСЛЕ ПРИМЕНЕНИЯ:")
        print("   Копия UpVector:", immediateCheck.UpVector)
        print("   Оригинал UpVector:", savedPetCFrame.UpVector)
        print("   Копия позиция:", immediateCheck.Position)
    else
        print("❌ Не найдена целевая часть для установки CFrame!")
    end
    
    -- Удаляем Shovel
    print("🗑️ Удаляю Shovel...")
    shovel:Destroy()
    
    wait(0.2)
    
    -- Добавляем новый Tool
    print("🎮 Добавляю новый Tool в руки...")
    newTool.Parent = character
    
    wait(0.3)
    
    -- Запускаем правильную анимацию (БЕЗ изменения CFrame!)
    print("🎬 Запускаю правильную анимацию...")
    startProperAnimation(newTool)
    
    print("✅ Правильная замена завершена!")
    print("🎭 Копия должна быть в правильной позе и анимироваться!")
    return true
end

-- ПРАВИЛЬНАЯ АНИМАЦИЯ (основана на логике из PetScaler_v3.226)
local function startProperAnimation(tool)
    if not tool then return end
    
    print("🎬 === ЗАПУСК ПРАВИЛЬНОЙ АНИМАЦИИ ===")
    
    -- Останавливаем предыдущую анимацию
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
    end
    
    -- Находим все Motor6D в Tool
    local motors = {}
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("Motor6D") then
            motors[obj.Name] = {
                motor = obj,
                originalC0 = obj.C0,
                originalC1 = obj.C1,
                time = math.random() * 10
            }
            print("   🔗 Найден Motor6D: " .. obj.Name)
        end
    end
    
    print(string.format("🎭 Найдено %d Motor6D для анимации", #motors))
    
    if #motors == 0 then
        print("⚠️ Motor6D не найдены - анимация недоступна")
        return
    end
    
    -- Запускаем анимацию Motor6D (НЕ CFrame!)
    animationConnection = RunService.Heartbeat:Connect(function()
        local time = tick()
        
        for motorName, data in pairs(motors) do
            if data.motor and data.motor.Parent then
                -- Простая idle анимация через Motor6D
                local offsetY = math.sin(time * 2 + data.time) * 0.02
                local offsetX = math.cos(time * 1.5 + data.time) * 0.01
                
                -- Применяем анимацию к C0 (безопасно)
                data.motor.C0 = data.originalC0 * CFrame.new(offsetX, offsetY, 0)
                
                data.time = data.time + 0.01
            end
        end
    end)
    
    print("✅ Правильная анимация запущена!")
    print("🎭 Питомец анимируется через Motor6D (безопасно)")
end

-- Создаем GUI
local function createProperGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProperShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 300)
    frame.Position = UDim2.new(0.5, -225, 0.5, -150)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🎯 PROPER SHOVEL REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "ПРАВИЛЬНОЕ РЕШЕНИЕ:\n1. Возьмите питомца → Сохранить с CFrame\n2. Возьмите Shovel → Правильная замена\nОснована на PetScaler_v3.226!"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сохранения с CFrame
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -20, 0, 50)
    saveBtn.Position = UDim2.new(0, 10, 0, 140)
    saveBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "💾 Сохранить с CFrame"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка правильной замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 50)
    replaceBtn.Position = UDim2.new(0, 10, 0, 200)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🎯 ПРАВИЛЬНАЯ ЗАМЕНА"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 30)
    closeBtn.Position = UDim2.new(0, 10, 0, 260)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сохраняю питомца с CFrame...\nАнализирую позицию и ориентацию..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = savePetWithCFrame()
        
        if success then
            status.Text = "✅ Питомец с CFrame сохранен!\nТеперь возьмите Shovel!"
            status.TextColor3 = Color3.new(0, 1, 0)
            replaceBtn.Visible = true
        else
            status.Text = "❌ Ошибка сохранения!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🎯 Правильная замена...\nКопирую CFrame из PetScaler_v3.226..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = properReplace()
        
        if success then
            status.Text = "✅ ПРАВИЛЬНАЯ ЗАМЕНА ЗАВЕРШЕНА!\nПитомец в правильной позе!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        if animationConnection then
            animationConnection:Disconnect()
        end
        screenGui:Destroy()
    end)
end

-- Запускаем
createProperGUI()
print("✅ ProperShovelReplacer готов!")
print("🎯 ОСНОВАН НА ЛОГИКЕ PetScaler_v3.226!")
print("💾 1. Сохранить питомца с CFrame")
print("🔄 2. Правильная замена с копированием ориентации")
