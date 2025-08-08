-- SimpleShovelReplacer.lua
-- Упрощенный подход: просто скрываем Shovel и создаем копию питомца рядом

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== SIMPLE SHOVEL REPLACER ===")

-- Функция поиска Shovel в руках
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

-- Функция поиска питомца в руках
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

-- ПРОСТОЙ ПОДХОД: Скрыть Shovel + создать копию питомца
local function simpleReplace()
    print("\n🔄 === ПРОСТАЯ ЗАМЕНА SHOVEL ===")
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец не найден! Сначала возьмите питомца в руки для копирования.")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Шаг 1: Просто меняем имя Shovel
    print("📝 Меняю имя Shovel...")
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Шаг 2: Скрываем все части Shovel
    print("👻 Скрываю Shovel...")
    for _, obj in pairs(shovel:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("SurfaceGui") then
            obj.Enabled = false
        end
    end
    
    -- Шаг 3: Создаем копию питомца и прикрепляем к Shovel Handle
    print("🐉 Создаю копию питомца...")
    
    local shovelHandle = shovel:FindFirstChild("Handle")
    if not shovelHandle then
        print("❌ Handle Shovel не найден!")
        return false
    end
    
    -- Копируем все части питомца
    for _, child in pairs(pet:GetDescendants()) do
        if child:IsA("BasePart") and child.Name ~= "Handle" then
            local partCopy = child:Clone()
            partCopy.Name = child.Name .. "_Copy"
            partCopy.Parent = shovel
            
            -- Создаем Weld к Handle Shovel
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = shovelHandle
            weld.Part1 = partCopy
            weld.Parent = shovel
            
            print("   ✅ Скопирована часть: " .. child.Name)
        end
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel скрыт и заменен на питомца!")
    print("📝 Новое имя: " .. shovel.Name)
    print("👻 Оригинальный Shovel невидим")
    print("🐉 Копия питомца прикреплена к Handle")
    
    return true
end

-- АЛЬТЕРНАТИВНЫЙ ПОДХОД: Полная замена Tool
local function fullReplace()
    print("\n🔄 === ПОЛНАЯ ЗАМЕНА TOOL ===")
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец не найден!")
        return false
    end
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Шаг 1: Создаем полную копию питомца
    print("🐉 Создаю полную копию питомца...")
    local petCopy = pet:Clone()
    petCopy.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Шаг 2: Удаляем Shovel
    print("🗑️ Удаляю Shovel...")
    shovel:Destroy()
    
    wait(0.2)
    
    -- Шаг 3: Добавляем копию питомца в руки
    print("🔄 Добавляю копию питомца в руки...")
    petCopy.Parent = character
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel полностью заменен на копию питомца!")
    print("📝 Имя: " .. petCopy.Name)
    print("🐉 Копия питомца в руках")
    
    return true
end

-- ТРЕТИЙ ПОДХОД: Только изменение имени
local function nameOnlyReplace()
    print("\n🔄 === ЗАМЕНА ТОЛЬКО ИМЕНИ ===")
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    
    -- Просто меняем имя
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Имя Shovel изменено на: " .. shovel.Name)
    print("📝 В хотбаре должно отображаться новое имя")
    
    return true
end

-- Создаем простой GUI
local function createSimpleGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 350)
    frame.Position = UDim2.new(0.5, -200, 0.5, -175)
    frame.BackgroundColor3 = Color3.new(0.2, 0.3, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.3, 0.5, 0.3)
    title.BorderSizePixel = 0
    title.Text = "🔧 SIMPLE SHOVEL REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Возьмите питомца в руки, затем Shovel.\nВыберите метод замены."
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка простой замены
    local simpleBtn = Instance.new("TextButton")
    simpleBtn.Size = UDim2.new(1, -20, 0, 40)
    simpleBtn.Position = UDim2.new(0, 10, 0, 120)
    simpleBtn.BackgroundColor3 = Color3.new(0, 0.7, 0)
    simpleBtn.BorderSizePixel = 0
    simpleBtn.Text = "👻 Скрыть Shovel + копия питомца"
    simpleBtn.TextColor3 = Color3.new(1, 1, 1)
    simpleBtn.TextScaled = true
    simpleBtn.Font = Enum.Font.SourceSansBold
    simpleBtn.Parent = frame
    
    -- Кнопка полной замены
    local fullBtn = Instance.new("TextButton")
    fullBtn.Size = UDim2.new(1, -20, 0, 40)
    fullBtn.Position = UDim2.new(0, 10, 0, 170)
    fullBtn.BackgroundColor3 = Color3.new(0.7, 0.4, 0)
    fullBtn.BorderSizePixel = 0
    fullBtn.Text = "🔄 Полная замена Tool"
    fullBtn.TextColor3 = Color3.new(1, 1, 1)
    fullBtn.TextScaled = true
    fullBtn.Font = Enum.Font.SourceSansBold
    fullBtn.Parent = frame
    
    -- Кнопка замены имени
    local nameBtn = Instance.new("TextButton")
    nameBtn.Size = UDim2.new(1, -20, 0, 40)
    nameBtn.Position = UDim2.new(0, 10, 0, 220)
    nameBtn.BackgroundColor3 = Color3.new(0, 0.4, 0.7)
    nameBtn.BorderSizePixel = 0
    nameBtn.Text = "📝 Только изменить имя"
    nameBtn.TextColor3 = Color3.new(1, 1, 1)
    nameBtn.TextScaled = true
    nameBtn.Font = Enum.Font.SourceSansBold
    nameBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 40)
    closeBtn.Position = UDim2.new(0, 10, 0, 270)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События
    simpleBtn.MouseButton1Click:Connect(function()
        status.Text = "👻 Скрываю Shovel и создаю копию питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = simpleReplace()
        
        if success then
            status.Text = "✅ Простая замена выполнена!\nShovel скрыт, копия питомца создана."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка простой замены!\nВозьмите питомца и Shovel в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    fullBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Выполняю полную замену Tool..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = fullReplace()
        
        if success then
            status.Text = "✅ Полная замена выполнена!\nShovel заменен на копию питомца."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка полной замены!\nВозьмите питомца и Shovel в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    nameBtn.MouseButton1Click:Connect(function()
        status.Text = "📝 Меняю только имя Shovel..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = nameOnlyReplace()
        
        if success then
            status.Text = "✅ Имя изменено!\nВ хотбаре должно показать Dragonfly."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка изменения имени!\nВозьмите Shovel в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Запускаем
createSimpleGUI()
print("✅ SimpleShovelReplacer готов!")
print("🔧 Три простых подхода:")
print("   👻 Скрыть Shovel + копия питомца")
print("   🔄 Полная замена Tool")
print("   📝 Только изменить имя")
print("🎯 Выберите подход который работает лучше всего!")
