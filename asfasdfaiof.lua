-- DirectShovelFix.lua
-- ПРЯМОЕ РЕШЕНИЕ: Меняем содержимое Shovel на содержимое питомца

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== DIRECT SHOVEL FIX ===")

-- Глобальные переменные
local petTool = nil
local savedPetC0 = nil
local savedPetC1 = nil

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
    
    -- КРИТИЧЕСКИ ВАЖНО: Сохраняем позицию питомца СЕЙЧАС, пока он в руках!
    local character = player.Character
    if character then
        local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        local petHandle = pet:FindFirstChild("Handle")
        
        if rightHand and petHandle then
            local petGrip = rightHand:FindFirstChild("RightGrip")
            if petGrip then
                savedPetC0 = petGrip.C0
                savedPetC1 = petGrip.C1
                print("📍 ПОЗИЦИЯ ПИТОМЦА СОХРАНЕНА!")
                print("📐 C0: " .. tostring(savedPetC0))
                print("📐 C1: " .. tostring(savedPetC1))
            else
                print("⚠️ RightGrip не найден, используем стандартную позицию")
            end
        end
    end
    
    print("✅ Питомец и его позиция сохранены!")
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

-- АЛЬТЕРНАТИВА: Замена содержимого существующего Tool БЕЗ создания нового
local function alternativeReplace()
    print("\n🔄 === АЛЬТЕРНАТИВНАЯ ЗАМЕНА (FIX) ===")
    
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

    -- === 1. Сохраняем C0/C1 от оригинала ===
    local petHandle = petTool:FindFirstChild("Handle")
    local petRightHand = petTool.Parent:FindFirstChild("Right Arm") or petTool.Parent:FindFirstChild("RightHand")
    local savedC0, savedC1 = nil, nil

    if petHandle and petRightHand then
        local petGrip = petRightHand:FindFirstChild("RightGrip")
        if petGrip then
            savedC0 = petGrip.C0
            savedC1 = petGrip.C1
            print("📍 Скопированы C0/C1 от оригинала питомца")
        end
    end

    -- === 2. Копируем свойства Tool ===
    shovel.Name = petTool.Name
    shovel.RequiresHandle = petTool.RequiresHandle
    shovel.CanBeDropped = petTool.CanBeDropped  
    shovel.ManualActivationOnly = petTool.ManualActivationOnly
    shovel.Enabled = petTool.Enabled

    -- === 3. Удаляем старое содержимое ===
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end

    -- === 4. Копируем содержимое питомца ===
    for _, child in pairs(petTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = shovel

        -- Если это Handle — временно закрепим
        if copy.Name == "Handle" and copy:IsA("BasePart") then
            copy.Anchored = true
            copy.CanCollide = false
            copy.CanTouch = false
        end
    end

    -- === 5. Создаём Weld сразу, пока физика не сработала ===
    local newHandle = shovel:FindFirstChild("Handle")
    local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")

    if newHandle and rightHand then
        local oldGrip = rightHand:FindFirstChild("RightGrip")
        if oldGrip then oldGrip:Destroy() end

        local newGrip = Instance.new("Weld")
        newGrip.Name = "RightGrip"
        newGrip.Part0 = rightHand
        newGrip.Part1 = newHandle
        newGrip.C0 = savedC0 or CFrame.new(0, -1, -0.5)
        newGrip.C1 = savedC1 or CFrame.new()
        newGrip.Parent = rightHand

        print("✅ Новый Weld установлен с сохранёнными C0/C1")
    else
        print("❌ Handle или RightHand не найдены!")
    end

    -- === 6. Включаем физику обратно ===
    if newHandle then
        newHandle.Anchored = false
    end

    -- === 7. Принудительно активируем Tool ===
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        shovel.Parent = character.Backpack
        wait()
        shovel.Parent = character
    end

    print("🎯 Альтернативная замена завершена — позиция сохранена!")
    return true
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
    
    -- Кнопка альтернативы
    local altBtn = Instance.new("TextButton")
    altBtn.Size = UDim2.new(1, -20, 0, 50)
    altBtn.Position = UDim2.new(0, 10, 0, 260)
    altBtn.BackgroundColor3 = Color3.new(0.6, 0, 0.8)
    altBtn.BorderSizePixel = 0
    altBtn.Text = "🔄 АЛЬТЕРНАТИВА"
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
        status.Text = "🔄 Альтернативная замена..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = alternativeReplace()
        
        if success then
            status.Text = "✅ АЛЬТЕРНАТИВА ЗАВЕРШЕНА!\nНовый Tool создан!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка альтернативы!"
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
