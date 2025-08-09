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

-- АЛЬТЕРНАТИВА: Замена содержимого существующего Tool БЕЗ создания нового
local function alternativeReplace()
    print("\n🔄 === АЛЬТЕРНАТИВНАЯ ЗАМЕНА ===")
    
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
    print("🔧 Замена содержимого существующего Tool...")
    
    -- КАРДИНАЛЬНО НОВЫЙ ПОДХОД: НЕ создаем новый Tool, а меняем содержимое существующего!
    
    -- Шаг 1: Меняем имя Tool (остается в том же слоте)
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("📝 Имя Tool изменено: " .. shovel.Name)
    
    -- Шаг 2: Копируем свойства Tool от питомца
    shovel.RequiresHandle = petTool.RequiresHandle
    shovel.CanBeDropped = petTool.CanBeDropped  
    shovel.ManualActivationOnly = petTool.ManualActivationOnly
    shovel.Enabled = petTool.Enabled
    print("🔧 Свойства Tool обновлены от питомца")
    
    -- Шаг 3: Сохраняем позицию Handle ПЕРЕД очисткой
    local shovelHandle = shovel:FindFirstChild("Handle")
    local savedPosition = nil
    local savedOrientation = nil
    
    if shovelHandle then
        savedPosition = shovelHandle.Position
        savedOrientation = shovelHandle.Orientation
        print("📍 Сохранена позиция Handle: " .. tostring(savedPosition))
    end
    
    -- Шаг 4: ПОЛНАЯ очистка содержимого Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
        print("   🗑️ Удалено: " .. child.Name)
    end
    
    wait(0.05) -- Минимальная пауза для очистки
    
    -- Шаг 5: Копируем ВСЕ содержимое питомца в существующий Tool
    print("📋 Копирую содержимое питомца в существующий Tool...")
    for _, child in pairs(petTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = shovel  -- В существующий Tool!
        
        -- КРИТИЧЕСКИ ВАЖНО: Правильная настройка физики
        if copy:IsA("BasePart") then
            copy.Anchored = false
            copy.CanCollide = false
            
            -- Если это Handle - восстанавливаем позицию
            if copy.Name == "Handle" and savedPosition then
                copy.Position = savedPosition
                copy.Orientation = savedOrientation
                print("   📍 Восстановлена позиция Handle")
            end
            
            print("   ✅ Скопировано: " .. child.Name .. " (BasePart)")
        else
            print("   ✅ Скопировано: " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    -- Шаг 6: Принудительная стабилизация Tool в руках
    spawn(function()
        wait(0.1)
        
        -- Проверяем что Tool все еще в руках
        if shovel.Parent == character then
            local handle = shovel:FindFirstChild("Handle")
            if handle then
                -- Убеждаемся что Handle правильно настроен
                handle.Anchored = false
                handle.CanCollide = false
                
                -- Принудительно "активируем" Tool
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Имитируем повторное взятие Tool
                    shovel.Parent = character.Backpack
                    wait(0.05)
                    shovel.Parent = character
                    print("✅ Tool принудительно активирован")
                end
            end
        end
    end)
    
    print("✅ Замена содержимого завершена!")
    print("🎯 Tool остается в том же слоте с новым содержимым!")
    print("📍 Позиция сохранена, падения быть не должно!")
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
