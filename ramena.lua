-- UltraSimpleShovelReplacer.lua
-- УЛЬТРА-ПРОСТОЕ решение: просто меняем содержимое Shovel на содержимое питомца

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== ULTRA SIMPLE SHOVEL REPLACER ===")

-- Глобальные переменные
local savedPetTool = nil
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

-- СОХРАНИТЬ питомца
local function savePet()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    savedPetTool = pet
    print("✅ Питомец сохранен!")
    return true
end

-- УЛЬТРА-ПРОСТАЯ ЗАМЕНА: просто меняем содержимое Shovel
local function ultraSimpleReplace()
    print("\n🔥 === УЛЬТРА-ПРОСТАЯ ЗАМЕНА ===")
    
    if not savedPetTool then
        print("❌ Сначала сохраните питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🔧 Ультра-простая замена содержимого...")
    
    -- ШАГ 1: Сохраняем позицию Shovel
    local shovelHandle = shovel:FindFirstChild("Handle")
    local shovelPosition = nil
    if shovelHandle then
        shovelPosition = shovelHandle.CFrame
        print("📍 Сохранена позиция Shovel")
    end
    
    -- ШАГ 2: Очищаем содержимое Shovel
    print("🧹 Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        if child.Name ~= "Handle" then
            child:Destroy()
        end
    end
    
    -- ШАГ 3: Копируем содержимое питомца в Shovel
    print("📋 Копирую содержимое питомца в Shovel...")
    for _, child in pairs(savedPetTool:GetChildren()) do
        if child.Name ~= "Handle" then
            local copy = child:Clone()
            copy.Parent = shovel
            print("   ✅ Скопирован:", child.Name)
        end
    end
    
    -- ШАГ 4: Меняем имя
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("✅ Имя изменено на:", shovel.Name)
    
    -- ШАГ 5: Восстанавливаем позицию
    if shovelPosition and shovelHandle then
        shovelHandle.CFrame = shovelPosition
        print("📍 Позиция восстановлена")
    end
    
    -- ШАГ 6: Настраиваем Anchored (все части НЕ заякорены для анимации)
    print("🔧 Настраиваю Anchored...")
    for _, obj in pairs(shovel:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Handle" then
            obj.Anchored = false
            print("   🔓 Разъякорен:", obj.Name)
        end
    end
    
    wait(0.5)
    
    -- ШАГ 7: Запускаем простую анимацию
    print("🎬 Запускаю анимацию...")
    startUltraSimpleAnimation(shovel)
    
    print("✅ Ультра-простая замена завершена!")
    print("🎭 Shovel теперь содержит питомца!")
    return true
end

-- УЛЬТРА-ПРОСТАЯ АНИМАЦИЯ
local function startUltraSimpleAnimation(tool)
    if not tool then return end
    
    print("🎬 === ЗАПУСК УЛЬТРА-ПРОСТОЙ АНИМАЦИИ ===")
    
    -- Останавливаем предыдущую анимацию
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
    end
    
    -- Ищем Motor6D для анимации
    local motors = {}
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, {
                motor = obj,
                originalC0 = obj.C0,
                time = math.random() * 10
            })
            print("   🔗 Найден Motor6D: " .. obj.Name)
        end
    end
    
    print(string.format("🎭 Найдено %d Motor6D для анимации", #motors))
    
    if #motors > 0 then
        -- Motor6D анимация (очень легкая)
        animationConnection = RunService.Heartbeat:Connect(function()
            local time = tick()
            
            for _, data in ipairs(motors) do
                if data.motor and data.motor.Parent then
                    -- Очень легкая анимация чтобы не блокировать игрока
                    local offsetY = math.sin(time * 1 + data.time) * 0.01
                    local offsetX = math.cos(time * 0.5 + data.time) * 0.005
                    
                    data.motor.C0 = data.originalC0 * CFrame.new(offsetX, offsetY, 0)
                    data.time = data.time + 0.001
                end
            end
        end)
        
        print("✅ Ультра-легкая Motor6D анимация запущена!")
    else
        print("⚠️ Motor6D не найдены - статичная копия")
    end
end

-- Создаем GUI
local function createUltraGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltraShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 250)
    frame.Position = UDim2.new(0.5, -200, 0.5, -125)
    frame.BackgroundColor3 = Color3.new(0.1, 0.3, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    title.BorderSizePixel = 0
    title.Text = "🚀 ULTRA SIMPLE REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "УЛЬТРА-ПРОСТОЕ РЕШЕНИЕ:\n1. Возьмите питомца → Сохранить\n2. Возьмите Shovel → Ультра-замена"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -20, 0, 50)
    saveBtn.Position = UDim2.new(0, 10, 0, 120)
    saveBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "💾 Сохранить питомца"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка ультра-замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 50)
    replaceBtn.Position = UDim2.new(0, 10, 0, 180)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🚀 УЛЬТРА-ЗАМЕНА"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сохраняю питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = savePet()
        
        if success then
            status.Text = "✅ Питомец сохранен!\nТеперь возьмите Shovel!"
            status.TextColor3 = Color3.new(0, 1, 0)
            replaceBtn.Visible = true
        else
            status.Text = "❌ Ошибка!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🚀 Ультра-замена...\nМеняю содержимое Shovel..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = ultraSimpleReplace()
        
        if success then
            status.Text = "✅ УЛЬТРА-ЗАМЕНА ЗАВЕРШЕНА!\nShovel теперь содержит питомца!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createUltraGUI()
print("✅ UltraSimpleShovelReplacer готов!")
print("🚀 УЛЬТРА-ПРОСТОЕ РЕШЕНИЕ!")
print("💾 1. Сохранить питомца")
print("🚀 2. Ультра-замена")
