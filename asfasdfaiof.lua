-- 🔥 DirectShovelFix v6 - ПРИНУДИТЕЛЬНАЯ АКТИВАЦИЯ LOCALSCRIPT
-- Основано на результатах анализа: PetToolLocal управляет анимацией!
-- Решение: принудительно перезапускаем PetToolLocal на копии

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔥 === DirectShovelFix v6 - LOCALSCRIPT ACTIVATION ===")

-- Глобальные переменные
local petTool = nil
local savedPetData = {}

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

-- Поиск Shovel в руках (гибкий поиск)
local function findShovelInHands()
    local character = player.Character
    if not character then return nil end
    
    print("🔍 Поиск Shovel в руках...")
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            print("   Найден инструмент: " .. tool.Name)
            -- Гибкий поиск: ищем "Shovel" в названии или любой инструмент без скобок [KG]
            if string.find(tool.Name:lower(), "shovel") or 
               (not string.find(tool.Name, "%[") and not string.find(tool.Name, "KG%]")) then
                print("✅ Найден Shovel: " .. tool.Name)
                return tool
            end
        end
    end
    print("❌ Shovel не найден в руках")
    return nil
end

-- Сохранение данных питомца
local function savePetData()
    print("\n💾 === СОХРАНЕНИЕ ДАННЫХ ПИТОМЦА ===")
    
    petTool = findPetInHands()
    if not petTool then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. petTool.Name)
    
    -- Сохраняем базовые свойства
    savedPetData = {
        name = petTool.Name,
        requiresHandle = petTool.RequiresHandle,
        canBeDropped = petTool.CanBeDropped,
        manualActivationOnly = petTool.ManualActivationOnly,
        children = {},
        localScripts = {}
    }
    
    -- Сохраняем все дочерние объекты
    for _, child in pairs(petTool:GetChildren()) do
        table.insert(savedPetData.children, child)
        
        -- Особое внимание к LocalScript
        if child:IsA("LocalScript") and child.Name == "PetToolLocal" then
            print("🎯 Найден PetToolLocal - ключ к анимации!")
            table.insert(savedPetData.localScripts, child)
        end
    end
    
    print("📊 Сохранено объектов: " .. #savedPetData.children)
    print("📜 Найдено LocalScript: " .. #savedPetData.localScripts)
    
    return true
end

-- Принудительная активация LocalScript
local function forceActivateLocalScript(tool)
    print("\n🔄 === ПРИНУДИТЕЛЬНАЯ АКТИВАЦИЯ LOCALSCRIPT ===")
    
    -- Ищем PetToolLocal в новом инструменте
    local petToolLocal = tool:FindFirstChild("PetToolLocal")
    if not petToolLocal then
        print("❌ PetToolLocal не найден в копии!")
        return false
    end
    
    print("✅ Найден PetToolLocal в копии")
    
    -- Метод 1: Перезапуск через Enabled
    print("🔄 Метод 1: Перезапуск через Enabled...")
    petToolLocal.Enabled = false
    wait(0.1)
    petToolLocal.Enabled = true
    print("✅ LocalScript перезапущен")
    
    -- Метод 2: Клонирование и замена
    print("🔄 Метод 2: Клонирование и замена...")
    local newLocalScript = petToolLocal:Clone()
    petToolLocal:Destroy()
    wait(0.1)
    newLocalScript.Parent = tool
    newLocalScript.Enabled = true
    print("✅ LocalScript заменен новой копией")
    
    -- Метод 3: Принудительное событие Tool.Equipped
    print("🔄 Метод 3: Симуляция события Equipped...")
    if tool.Parent == player.Character then
        -- Инструмент уже экипирован, симулируем переэкипировку
        tool.Parent = player.Backpack
        wait(0.1)
        tool.Parent = player.Character
        print("✅ Инструмент переэкипирован")
    end
    
    return true
end

-- Основная функция замены
local function directReplaceWithLocalScript()
    print("\n🔄 === ЗАМЕНА С АКТИВАЦИЕЙ LOCALSCRIPT ===")
    
    if not petTool or #savedPetData.children == 0 then
        print("❌ Сначала сохраните данные питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    
    -- Шаг 1: Меняем свойства
    shovel.Name = savedPetData.name
    shovel.RequiresHandle = savedPetData.requiresHandle
    shovel.CanBeDropped = savedPetData.canBeDropped
    shovel.ManualActivationOnly = savedPetData.manualActivationOnly
    print("📝 Свойства обновлены")
    
    -- Шаг 2: Очищаем содержимое
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end
    wait(0.1)
    print("🗑️ Содержимое очищено")
    
    -- Шаг 3: Копируем все содержимое
    for _, child in pairs(savedPetData.children) do
        if child and child.Parent then -- Проверяем, что объект еще существует
            local copy = child:Clone()
            copy.Parent = shovel
            print("📋 Скопировано: " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    wait(0.2) -- Даем время на инициализацию
    
    -- Шаг 4: КРИТИЧЕСКИЙ - Активация LocalScript
    print("\n🎯 === КРИТИЧЕСКИЙ ЭТАП: АКТИВАЦИЯ АНИМАЦИИ ===")
    local success = forceActivateLocalScript(shovel)
    
    if success then
        print("✅ УСПЕХ! LocalScript активирован!")
        print("🎮 Питомец должен быть анимированным!")
    else
        print("⚠️ Проблемы с активацией LocalScript")
    end
    
    print("\n🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel заменен на: " .. shovel.Name)
    print("📜 LocalScript статус: " .. (shovel:FindFirstChild("PetToolLocal") and "Найден" or "Отсутствует"))
    
    return true
end

-- Создание GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixV6"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 200)
    frame.Position = UDim2.new(0.5, -225, 0.5, -100)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🔥 DirectShovelFix v6 - LocalScript"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Кнопка сохранения
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 50)
    saveBtn.Position = UDim2.new(0.025, 0, 0, 50)
    saveBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    saveBtn.Text = "💾 СОХРАНИТЬ\nПИТОМЦА"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.Parent = frame
    
    -- Кнопка замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(0.45, 0, 0, 50)
    replaceBtn.Position = UDim2.new(0.525, 0, 0, 50)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    replaceBtn.Text = "🔄 ЗАМЕНИТЬ\n+ АКТИВАЦИЯ"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.Gotham
    replaceBtn.Parent = frame
    
    -- Информационная панель
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.95, 0, 0, 60)
    infoLabel.Position = UDim2.new(0.025, 0, 0, 110)
    infoLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    infoLabel.Text = "1. Возьмите питомца в руки\n2. Нажмите СОХРАНИТЬ\n3. Возьмите Shovel в руки\n4. Нажмите ЗАМЕНИТЬ"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.95, 0, 0, 20)
    closeBtn.Position = UDim2.new(0.025, 0, 0, 175)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    closeBtn.Text = "❌ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    
    -- Обработчики событий
    saveBtn.MouseButton1Click:Connect(savePetData)
    replaceBtn.MouseButton1Click:Connect(directReplaceWithLocalScript)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("🎮 GUI создан! Следуйте инструкциям для замены с активацией анимации.")
end

-- Запуск
createGUI()
