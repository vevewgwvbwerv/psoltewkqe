-- MinimalShovelReplacer.lua
-- МИНИМАЛЬНОЕ решение: просто меняем содержимое Shovel на питомца

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== MINIMAL SHOVEL REPLACER ===")

-- Глобальные переменные
local savedPetTool = nil

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

-- МИНИМАЛЬНАЯ ЗАМЕНА (БЕЗ анимации - просто меняем содержимое)
local function minimalReplace()
    print("\n🔧 === МИНИМАЛЬНАЯ ЗАМЕНА ===")
    
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
    print("🔧 Минимальная замена содержимого...")
    
    -- ШАГ 1: Очищаем содержимое Shovel (кроме Handle)
    print("🧹 Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        if child.Name ~= "Handle" then
            child:Destroy()
            print("   🗑️ Удален:", child.Name)
        end
    end
    
    wait(0.1)
    
    -- ШАГ 2: Копируем содержимое питомца
    print("📋 Копирую содержимое питомца...")
    for _, child in pairs(savedPetTool:GetChildren()) do
        if child.Name ~= "Handle" then
            local copy = child:Clone()
            copy.Parent = shovel
            print("   ✅ Скопирован:", child.Name)
            
            -- Все части НЕ заякорены
            if copy:IsA("BasePart") then
                copy.Anchored = false
            end
        end
    end
    
    -- ШАГ 3: Меняем имя
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("✅ Имя изменено на:", shovel.Name)
    
    print("✅ Минимальная замена завершена!")
    print("🎯 Shovel теперь содержит питомца (БЕЗ анимации)")
    return true
end

-- Создаем МИНИМАЛЬНУЮ GUI
local function createMinimalGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MinimalShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0.5, -100)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "🔧 MINIMAL REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "1. Питомец в руки → Сохранить\n2. Shovel в руки → Заменить"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 40)
    saveBtn.Position = UDim2.new(0.05, 0, 0, 110)
    saveBtn.BackgroundColor3 = Color3.new(0, 0.6, 0)
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "💾 Сохранить"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(0.45, 0, 0, 40)
    replaceBtn.Position = UDim2.new(0.5, 0, 0, 110)
    replaceBtn.BackgroundColor3 = Color3.new(0.6, 0, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔧 Заменить"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        local success = savePet()
        if success then
            status.Text = "✅ Питомец сохранен!\nТеперь возьмите Shovel"
            status.TextColor3 = Color3.new(0, 1, 0)
            replaceBtn.Visible = true
        else
            status.Text = "❌ Возьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        local success = minimalReplace()
        if success then
            status.Text = "✅ ЗАМЕНА ЗАВЕРШЕНА!\nShovel → Питомец"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Возьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createMinimalGUI()
print("✅ MinimalShovelReplacer готов!")
print("🔧 МИНИМАЛЬНОЕ решение БЕЗ анимации")
print("💾 1. Сохранить питомца")
print("🔧 2. Заменить Shovel")
