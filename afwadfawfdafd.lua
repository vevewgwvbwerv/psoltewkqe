-- DirectShovelFix_v4_LIVE.lua
-- РАДИКАЛЬНОЕ РЕШЕНИЕ: Прямой перенос ЖИВОГО питомца без копирования

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== DIRECT SHOVEL FIX V4 - LIVE ANIMATIONS ===")

-- Глобальные переменные
local originalPet = nil
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

-- СОХРАНИТЬ оригинального питомца
local function saveLivePet()
    print("\n💾 === СОХРАНЕНИЕ ЖИВОГО ПИТОМЦА ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден живой питомец: " .. pet.Name)
    
    -- Сохраняем ОРИГИНАЛЬНОГО питомца (не копию!)
    originalPet = pet
    
    -- Сохраняем его позицию в руке
    local character = player.Character
    if character then
        local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        local petHandle = pet:FindFirstChild("Handle")
        
        if rightHand and petHandle then
            local petGrip = rightHand:FindFirstChild("RightGrip")
            if petGrip then
                savedPetC0 = petGrip.C0
                savedPetC1 = petGrip.C1
                print("📍 Позиция живого питомца сохранена!")
                print("📐 C0: " .. tostring(savedPetC0))
                print("📐 C1: " .. tostring(savedPetC1))
            end
        end
    end
    
    print("✅ Живой питомец готов к переносу!")
    return true
end

-- ПРЯМОЙ ПЕРЕНОС живого питомца
local function transferLivePet()
    print("\n🔄 === ПЕРЕНОС ЖИВОГО ПИТОМЦА ===")
    
    if not originalPet then
        print("❌ Сначала сохраните живого питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🔄 Переношу ЖИВОГО питомца...")
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return false
    end
    
    -- Шаг 1: Убираем Shovel из рук (НЕ удаляем!)
    shovel.Parent = player.Backpack
    wait(0.1)
    
    -- Шаг 2: Убираем питомца из рук временно
    originalPet.Parent = player.Backpack
    wait(0.1)
    
    -- Шаг 3: КРИТИЧЕСКИ ВАЖНО - Меняем имя питомца на имя Shovel
    local shovelName = shovel.Name
    local petName = originalPet.Name
    
    -- Временно меняем имена для обмана системы
    shovel.Name = "TempShovel_" .. tick()
    originalPet.Name = shovelName  -- Питомец получает имя Shovel!
    
    print("🏷️ Имена поменяны:")
    print("   Shovel -> " .. shovel.Name)
    print("   Pet -> " .. originalPet.Name)
    
    -- Шаг 4: Удаляем Shovel (он больше не нужен)
    shovel:Destroy()
    print("🗑️ Shovel удален")
    
    wait(0.2)
    
    -- Шаг 5: Возвращаем ЖИВОГО питомца в руки под именем Shovel
    originalPet.Parent = character
    
    -- Шаг 6: Восстанавливаем правильную позицию в руке
    if savedPetC0 and savedPetC1 then
        wait(0.3) -- Даем время Tool'у закрепиться
        
        local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        local petHandle = originalPet:FindFirstChild("Handle")
        
        if rightHand and petHandle then
            print("🔧 Восстанавливаю позицию живого питомца...")
            
            local oldGrip = rightHand:FindFirstChild("RightGrip")
            if oldGrip then oldGrip:Destroy() end
            
            local newGrip = Instance.new("Weld")
            newGrip.Name = "RightGrip"
            newGrip.Part0 = rightHand
            newGrip.Part1 = petHandle
            newGrip.C0 = savedPetC0
            newGrip.C1 = savedPetC1
            newGrip.Parent = rightHand
            
            print("✅ Живой питомец закреплен в правильной позиции!")
        end
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ ЖИВОЙ питомец с анимациями в руке!")
    print("🎮 Имя: " .. originalPet.Name)
    print("🎬 Анимации должны работать как у оригинала!")
    
    return true
end

-- Создаем GUI
local function createLiveFixGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LiveShovelFixGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 220)
    frame.Position = UDim2.new(0.5, -160, 0.5, -110)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.6, 0.2, 0.8)
    title.BorderSizePixel = 0
    title.Text = "🎬 LIVE ANIMATION FIX"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "ЖИВЫЕ АНИМАЦИИ:\n1. Питомец в руки → Сохранить\n2. Shovel в руки → Перенести"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -20, 0, 40)
    saveBtn.Position = UDim2.new(0, 10, 0, 120)
    saveBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "💾 Сохранить ЖИВОГО питомца"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка переноса
    local transferBtn = Instance.new("TextButton")
    transferBtn.Size = UDim2.new(1, -20, 0, 40)
    transferBtn.Position = UDim2.new(0, 10, 0, 170)
    transferBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    transferBtn.BorderSizePixel = 0
    transferBtn.Text = "🔄 ПЕРЕНЕСТИ с анимациями"
    transferBtn.TextColor3 = Color3.new(1, 1, 1)
    transferBtn.TextScaled = true
    transferBtn.Font = Enum.Font.SourceSansBold
    transferBtn.Visible = false
    transferBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сохраняю живого питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = saveLivePet()
        
        if success then
            status.Text = "✅ Живой питомец сохранен!\nТеперь возьмите Shovel"
            status.TextColor3 = Color3.new(0, 1, 0)
            transferBtn.Visible = true
        else
            status.Text = "❌ Ошибка!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    transferBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Переношу живого питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = transferLivePet()
        
        if success then
            status.Text = "✅ ГОТОВО!\nЖивой питомец в руке!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка переноса!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createLiveFixGUI()
print("✅ DirectShovelFix V4 LIVE готов!")
print("🎬 ПРЯМОЙ ПЕРЕНОС ЖИВОГО ПИТОМЦА!")
print("🚫 БЕЗ КОПИРОВАНИЯ - ТОЛЬКО ПЕРЕНОС ОРИГИНАЛА!")
