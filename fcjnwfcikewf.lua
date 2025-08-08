-- ShovelHider.lua
-- Скрывает Shovel из рук и заменяет на копию питомца

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== SHOVEL HIDER ===")

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

-- Функция скрытия Shovel
local function hideShovel()
    print("\n🔄 === СКРЫТИЕ SHOVEL ===")
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    
    -- Метод 1: Делаем невидимым
    print("🔧 Делаю Shovel невидимым...")
    
    local handle = shovel:FindFirstChild("Handle")
    if handle then
        handle.Transparency = 1
        handle.CanCollide = false
        print("✅ Handle скрыт (Transparency = 1)")
    end
    
    -- Скрываем все части
    for _, part in pairs(shovel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        elseif part:IsA("SurfaceGui") then
            part.Enabled = false
        end
    end
    
    print("✅ Все части Shovel скрыты!")
    return true
end

-- Функция замены Shovel на копию питомца
local function replaceShovelWithPet()
    print("\n🔄 === ЗАМЕНА SHOVEL НА ПИТОМЦА ===")
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден! Возьмите питомца в руки.")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Шаг 1: Скрываем Shovel
    hideShovel()
    
    -- Шаг 2: Меняем имя Shovel на имя питомца
    print("🔧 Меняю имя Shovel на имя питомца...")
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("✅ Имя изменено: " .. shovel.Name)
    
    -- Шаг 3: Копируем содержимое питомца в Shovel
    print("🔧 Копирую содержимое питомца в Shovel...")
    
    -- Удаляем старое содержимое Shovel (кроме Handle)
    for _, child in pairs(shovel:GetChildren()) do
        if child.Name ~= "Handle" then
            child:Destroy()
        end
    end
    
    -- Копируем содержимое питомца
    for _, child in pairs(pet:GetChildren()) do
        if child.Name ~= "Handle" then
            local childCopy = child:Clone()
            childCopy.Parent = shovel
            print("   📋 Скопирован: " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    -- Шаг 4: Заменяем Handle
    local shovelHandle = shovel:FindFirstChild("Handle")
    local petHandle = pet:FindFirstChild("Handle")
    
    if shovelHandle and petHandle then
        print("🔧 Заменяю Handle...")
        
        -- Копируем свойства Handle питомца
        local newHandle = petHandle:Clone()
        newHandle.Name = "Handle"
        newHandle.Parent = shovel
        
        -- Удаляем старый Handle
        shovelHandle:Destroy()
        
        print("✅ Handle заменен!")
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel заменен на питомца!")
    print("📝 Новое имя: " .. shovel.Name)
    print("🎮 Теперь в руках должен быть питомец вместо Shovel")
    
    return true
end

-- Функция полного удаления Shovel
local function deleteShovel()
    print("\n🗑️ === УДАЛЕНИЕ SHOVEL ===")
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🗑️ Удаляю Shovel...")
    
    shovel:Destroy()
    
    print("✅ Shovel удален!")
    return true
end

-- Функция создания копии питомца в руках
local function createPetCopyInHands()
    print("\n🔄 === СОЗДАНИЕ КОПИИ ПИТОМЦА В РУКАХ ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Создаем копию питомца
    local petCopy = pet:Clone()
    petCopy.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Удаляем Shovel
    local shovel = findShovelInHands()
    if shovel then
        shovel:Destroy()
        print("🗑️ Shovel удален")
    end
    
    wait(0.1)
    
    -- Добавляем копию питомца в руки
    petCopy.Parent = character
    
    print("✅ Копия питомца создана в руках!")
    print("📝 Имя: " .. petCopy.Name)
    
    return true
end

-- Создаем GUI для управления
local function createShovelHiderGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShovelHiderGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 350)
    frame.Position = UDim2.new(0.5, -200, 0.5, -175)
    frame.BackgroundColor3 = Color3.new(0.2, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "🔧 SHOVEL HIDER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Возьмите питомца в руки и выберите действие."
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка скрытия Shovel
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(1, -20, 0, 40)
    hideBtn.Position = UDim2.new(0, 10, 0, 110)
    hideBtn.BackgroundColor3 = Color3.new(0.6, 0.3, 0)
    hideBtn.BorderSizePixel = 0
    hideBtn.Text = "👻 Скрыть Shovel"
    hideBtn.TextColor3 = Color3.new(1, 1, 1)
    hideBtn.TextScaled = true
    hideBtn.Font = Enum.Font.SourceSansBold
    hideBtn.Parent = frame
    
    -- Кнопка замены Shovel
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 40)
    replaceBtn.Position = UDim2.new(0, 10, 0, 160)
    replaceBtn.BackgroundColor3 = Color3.new(0, 0.6, 0.8)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔄 Заменить Shovel на питомца"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Parent = frame
    
    -- Кнопка удаления Shovel
    local deleteBtn = Instance.new("TextButton")
    deleteBtn.Size = UDim2.new(1, -20, 0, 40)
    deleteBtn.Position = UDim2.new(0, 10, 0, 210)
    deleteBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
    deleteBtn.BorderSizePixel = 0
    deleteBtn.Text = "🗑️ Удалить Shovel"
    deleteBtn.TextColor3 = Color3.new(1, 1, 1)
    deleteBtn.TextScaled = true
    deleteBtn.Font = Enum.Font.SourceSansBold
    deleteBtn.Parent = frame
    
    -- Кнопка создания копии
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, -20, 0, 40)
    copyBtn.Position = UDim2.new(0, 10, 0, 260)
    copyBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = "🐉 Создать копию питомца"
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.TextScaled = true
    copyBtn.Font = Enum.Font.SourceSansBold
    copyBtn.Parent = frame
    
    -- События кнопок
    hideBtn.MouseButton1Click:Connect(function()
        status.Text = "👻 Скрываю Shovel..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = hideShovel()
        
        if success then
            status.Text = "✅ Shovel скрыт!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка скрытия Shovel"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Заменяю Shovel на питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = replaceShovelWithPet()
        
        if success then
            status.Text = "✅ Shovel заменен на питомца!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены Shovel"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    deleteBtn.MouseButton1Click:Connect(function()
        status.Text = "🗑️ Удаляю Shovel..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = deleteShovel()
        
        if success then
            status.Text = "✅ Shovel удален!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка удаления Shovel"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    copyBtn.MouseButton1Click:Connect(function()
        status.Text = "🐉 Создаю копию питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = createPetCopyInHands()
        
        if success then
            status.Text = "✅ Копия питомца создана!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка создания копии"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createShovelHiderGUI()
print("✅ ShovelHider готов!")
print("🎮 Возьмите питомца в руки и попробуйте разные методы")
