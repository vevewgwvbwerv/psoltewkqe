-- ShovelReplacer.lua
-- Заменяет Shovel НА ЕГО МЕСТЕ на отсканированную копию питомца

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== SHOVEL REPLACER ===")

-- Глобальная переменная для хранения отсканированного питомца
local scannedPetData = nil

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

-- Функция сканирования питомца
local function scanPet()
    print("\n🔍 === СКАНИРОВАНИЕ ПИТОМЦА ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Сохраняем данные питомца
    scannedPetData = {
        name = pet.Name,
        className = pet.ClassName,
        properties = {},
        children = {}
    }
    
    -- Копируем свойства
    for property, value in pairs(getfenv(1)) do
        pcall(function()
            if pet[property] ~= nil then
                scannedPetData.properties[property] = pet[property]
            end
        end)
    end
    
    -- Копируем детей
    for _, child in pairs(pet:GetChildren()) do
        local childData = {
            name = child.Name,
            className = child.ClassName,
            object = child:Clone()
        }
        table.insert(scannedPetData.children, childData)
    end
    
    print("✅ Питомец отсканирован!")
    print("📊 Найдено детей: " .. #scannedPetData.children)
    
    return true
end

-- Функция замены Shovel на отсканированного питомца НА ЕГО МЕСТЕ
local function replaceShovelInPlace()
    print("\n🔄 === ЗАМЕНА SHOVEL НА ЕГО МЕСТЕ ===")
    
    if not scannedPetData then
        print("❌ Питомец не отсканирован! Сначала отсканируйте питомца.")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🔧 Заменяю Shovel на отсканированного питомца...")
    
    -- Шаг 1: Меняем имя Shovel
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("✅ Имя изменено: " .. shovel.Name)
    
    -- Шаг 2: Удаляем всё содержимое Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end
    
    -- Шаг 3: Добавляем содержимое отсканированного питомца
    print("📋 Добавляю содержимое питомца...")
    for _, childData in pairs(scannedPetData.children) do
        local newChild = childData.object:Clone()
        newChild.Parent = shovel
        print("   ✅ Добавлен: " .. newChild.Name .. " (" .. newChild.ClassName .. ")")
    end
    
    -- Шаг 4: Копируем свойства питомца в Shovel
    print("⚙️ Копирую свойства питомца...")
    for property, value in pairs(scannedPetData.properties) do
        pcall(function()
            if property ~= "Name" and property ~= "Parent" then
                shovel[property] = value
            end
        end)
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel заменен НА ЕГО МЕСТЕ!")
    print("📝 Новое имя: " .. shovel.Name)
    print("📍 Местоположение: " .. (shovel.Parent and shovel.Parent.Name or "NIL"))
    print("🎮 Shovel теперь является копией питомца!")
    
    return true
end

-- Функция удаления Shovel и создания питомца НА ТОМ ЖЕ МЕСТЕ
local function replaceWithNewPet()
    print("\n🔄 === СОЗДАНИЕ ПИТОМЦА НА МЕСТЕ SHOVEL ===")
    
    if not scannedPetData then
        print("❌ Питомец не отсканирован!")
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
    
    -- Шаг 1: Запоминаем родителя Shovel
    local shovelParent = shovel.Parent
    
    -- Шаг 2: Удаляем Shovel
    print("🗑️ Удаляю Shovel...")
    shovel:Destroy()
    
    wait(0.1)
    
    -- Шаг 3: Создаем новый Tool питомца
    print("🔧 Создаю Tool питомца...")
    local newPetTool = Instance.new("Tool")
    newPetTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Шаг 4: Добавляем содержимое отсканированного питомца
    print("📋 Добавляю содержимое питомца...")
    for _, childData in pairs(scannedPetData.children) do
        local newChild = childData.object:Clone()
        newChild.Parent = newPetTool
        print("   ✅ Добавлен: " .. newChild.Name .. " (" .. newChild.ClassName .. ")")
    end
    
    -- Шаг 5: Копируем свойства
    for property, value in pairs(scannedPetData.properties) do
        pcall(function()
            if property ~= "Name" and property ~= "Parent" then
                newPetTool[property] = value
            end
        end)
    end
    
    -- Шаг 6: Помещаем НА ТО ЖЕ МЕСТО где был Shovel
    newPetTool.Parent = shovelParent
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Питомец создан НА МЕСТЕ Shovel!")
    print("📝 Имя: " .. newPetTool.Name)
    print("📍 Местоположение: " .. (newPetTool.Parent and newPetTool.Parent.Name or "NIL"))
    
    return true
end

-- Создаем GUI
local function createReplacerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.new(0.1, 0.3, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    title.BorderSizePixel = 0
    title.Text = "🔄 SHOVEL REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "1. Возьмите питомца в руки\n2. Отсканируйте питомца\n3. Замените Shovel"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сканирования
    local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(1, -20, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 110)
    scanBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    scanBtn.BorderSizePixel = 0
    scanBtn.Text = "🔍 Отсканировать питомца"
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.TextScaled = true
    scanBtn.Font = Enum.Font.SourceSansBold
    scanBtn.Parent = frame
    
    -- Кнопка замены на месте
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 40)
    replaceBtn.Position = UDim2.new(0, 10, 0, 160)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔄 Заменить Shovel НА МЕСТЕ"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- Кнопка создания нового
    local newBtn = Instance.new("TextButton")
    newBtn.Size = UDim2.new(1, -20, 0, 40)
    newBtn.Position = UDim2.new(0, 10, 0, 210)
    newBtn.BackgroundColor3 = Color3.new(0.8, 0, 0.8)
    newBtn.BorderSizePixel = 0
    newBtn.Text = "🆕 Создать питомца НА МЕСТЕ"
    newBtn.TextColor3 = Color3.new(1, 1, 1)
    newBtn.TextScaled = true
    newBtn.Font = Enum.Font.SourceSansBold
    newBtn.Visible = false
    newBtn.Parent = frame
    
    -- События
    scanBtn.MouseButton1Click:Connect(function()
        status.Text = "🔍 Сканирую питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = scanPet()
        
        if success then
            status.Text = "✅ Питомец отсканирован!\nТеперь можно заменить Shovel."
            status.TextColor3 = Color3.new(0, 1, 0)
            replaceBtn.Visible = true
            newBtn.Visible = true
        else
            status.Text = "❌ Ошибка сканирования!\nВозьмите питомца в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Заменяю Shovel на месте..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = replaceShovelInPlace()
        
        if success then
            status.Text = "✅ Shovel заменен НА МЕСТЕ!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    newBtn.MouseButton1Click:Connect(function()
        status.Text = "🆕 Создаю питомца на месте..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = replaceWithNewPet()
        
        if success then
            status.Text = "✅ Питомец создан НА МЕСТЕ!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка создания!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createReplacerGUI()
print("✅ ShovelReplacer готов!")
print("🔍 1. Возьмите питомца в руки")
print("🔍 2. Нажмите 'Отсканировать питомца'")
print("🔄 3. Нажмите 'Заменить Shovel НА МЕСТЕ'")
