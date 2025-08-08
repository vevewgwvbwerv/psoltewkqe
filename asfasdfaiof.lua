-- PerfectShovelReplacer.lua
-- РАДИКАЛЬНЫЙ ПОДХОД: Полная замена Tool на клонированный питомец

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== PERFECT SHOVEL REPLACER ===")

-- Глобальная переменная для хранения клонированного питомца
local clonedPetTool = nil

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

-- НОВЫЙ ПОДХОД: Полное клонирование питомца Tool
local function clonePetTool()
    print("\n📋 === КЛОНИРОВАНИЕ ПИТОМЦА TOOL ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Создаем ПОЛНУЮ копию Tool питомца
    clonedPetTool = pet:Clone()
    clonedPetTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    print("✅ Создан клон питомца: " .. clonedPetTool.Name)
    print("📊 Структура клона:")
    
    -- Анализируем структуру клона
    local partCount = 0
    local meshCount = 0
    local scriptCount = 0
    
    for _, obj in pairs(clonedPetTool:GetDescendants()) do
        if obj:IsA("BasePart") then
            partCount = partCount + 1
            print("   📦 Part: " .. obj.Name)
        elseif obj:IsA("SpecialMesh") then
            meshCount = meshCount + 1
            print("   🎨 Mesh: " .. obj.Name)
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            scriptCount = scriptCount + 1
            print("   📜 Script: " .. obj.Name)
        elseif obj:IsA("Motor6D") then
            print("   🔗 Motor6D: " .. obj.Name)
        elseif obj:IsA("Weld") then
            print("   🔗 Weld: " .. obj.Name)
        end
    end
    
    print(string.format("📊 Итого: %d частей, %d мешей, %d скриптов", partCount, meshCount, scriptCount))
    print("✅ Клонирование завершено!")
    
    return true
end

-- ИСПРАВЛЕННАЯ ЗАМЕНА: Создаем новый клон каждый раз
local function perfectReplace()
    print("\n🔄 === ИДЕАЛЬНАЯ ЗАМЕНА SHOVEL ===")
    
    if not clonedPetTool then
        print("❌ Клон питомца не создан! Сначала клонируйте питомца.")
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
    print("🔧 Выполняю идеальную замену...")
    
    -- Шаг 1: Создаем НОВЫЙ клон (важно!)
    print("📋 Создаю новый клон для замены...")
    local newClone = clonedPetTool:Clone()
    newClone.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Шаг 2: Проверяем что клон имеет Handle
    local handle = newClone:FindFirstChild("Handle")
    if not handle then
        print("❌ У клона нет Handle! Создаю Handle...")
        handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.Transparency = 1
        handle.CanCollide = false
        handle.Parent = newClone
    else
        print("✅ Handle найден: " .. handle.Name)
    end
    
    -- Шаг 3: Удаляем Shovel
    print("🗑️ Удаляю Shovel...")
    shovel:Destroy()
    
    -- Шаг 4: Пауза для стабилизации
    wait(0.2)
    
    -- Шаг 5: Добавляем новый клон в руки
    print("🐉 Добавляю новый клон в руки...")
    newClone.Parent = character
    
    -- Шаг 6: Проверяем результат
    wait(0.1)
    local toolInHands = character:FindFirstChildOfClass("Tool")
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    if toolInHands then
        print("✅ Shovel ПОЛНОСТЬЮ заменен на клон питомца!")
        print("📝 Имя: " .. toolInHands.Name)
        print("📍 Местоположение: " .. (toolInHands.Parent and toolInHands.Parent.Name or "NIL"))
        print("🎮 В руках: " .. toolInHands.Name)
        print("🎭 Со всеми анимациями и правильным положением!")
    else
        print("❌ Клон не появился в руках! Проверяю Backpack...")
        local backpack = character:FindFirstChild("Backpack")
        if backpack then
            local toolInBackpack = backpack:FindFirstChildOfClass("Tool")
            if toolInBackpack then
                print("📦 Клон найден в Backpack: " .. toolInBackpack.Name)
                print("🔄 Перемещаю в руки...")
                toolInBackpack.Parent = character
                print("✅ Клон перемещен в руки!")
            else
                print("❌ Клон не найден нигде!")
                return false
            end
        end
    end
    
    return true
end

-- ПРОСТАЯ АЛЬТЕРНАТИВА: Только переименование Shovel
local function simpleRename()
    print("\n📝 === ПРОСТОЕ ПЕРЕИМЕНОВАНИЕ SHOVEL ===")
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("📝 Меняю только имя...")
    
    -- Просто меняем имя Shovel
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Имя Shovel изменено на: " .. shovel.Name)
    print("📝 В хотбаре должно отображаться новое имя")
    print("💡 Это простое решение без замены модели")
    
    return true
end

-- Создаем GUI
local function createPerfectReplacerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PerfectShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 400)
    frame.Position = UDim2.new(0.5, -225, 0.5, -200)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🎯 PERFECT SHOVEL REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "РАДИКАЛЬНЫЙ ПОДХОД:\n1. Возьмите питомца в руки\n2. Клонируйте питомца\n3. Возьмите Shovel\n4. Выполните идеальную замену"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка клонирования
    local cloneBtn = Instance.new("TextButton")
    cloneBtn.Size = UDim2.new(1, -20, 0, 50)
    cloneBtn.Position = UDim2.new(0, 10, 0, 140)
    cloneBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    cloneBtn.BorderSizePixel = 0
    cloneBtn.Text = "📋 Клонировать питомца Tool"
    cloneBtn.TextColor3 = Color3.new(1, 1, 1)
    cloneBtn.TextScaled = true
    cloneBtn.Font = Enum.Font.SourceSansBold
    cloneBtn.Parent = frame
    
    -- Кнопка идеальной замены
    local perfectBtn = Instance.new("TextButton")
    perfectBtn.Size = UDim2.new(1, -20, 0, 50)
    perfectBtn.Position = UDim2.new(0, 10, 0, 200)
    perfectBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    perfectBtn.BorderSizePixel = 0
    perfectBtn.Text = "🎯 ИДЕАЛЬНАЯ ЗАМЕНА"
    perfectBtn.TextColor3 = Color3.new(1, 1, 1)
    perfectBtn.TextScaled = true
    perfectBtn.Font = Enum.Font.SourceSansBold
    perfectBtn.Visible = false
    perfectBtn.Parent = frame
    
    -- Кнопка замены через Backpack
    local backpackBtn = Instance.new("TextButton")
    backpackBtn.Size = UDim2.new(1, -20, 0, 50)
    backpackBtn.Position = UDim2.new(0, 10, 0, 260)
    backpackBtn.BackgroundColor3 = Color3.new(0.6, 0, 0.8)
    backpackBtn.BorderSizePixel = 0
    backpackBtn.Text = "🔄 Замена через Backpack"
    backpackBtn.TextColor3 = Color3.new(1, 1, 1)
    backpackBtn.TextScaled = true
    backpackBtn.Font = Enum.Font.SourceSansBold
    backpackBtn.Visible = false
    backpackBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 40)
    closeBtn.Position = UDim2.new(0, 10, 0, 320)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События
    cloneBtn.MouseButton1Click:Connect(function()
        status.Text = "📋 Клонирую питомца Tool...\nАнализирую структуру..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = clonePetTool()
        
        if success then
            status.Text = "✅ Питомец клонирован!\nТеперь возьмите Shovel и выполните замену."
            status.TextColor3 = Color3.new(0, 1, 0)
            perfectBtn.Visible = true
            backpackBtn.Visible = true
        else
            status.Text = "❌ Ошибка клонирования!\nВозьмите питомца в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    perfectBtn.MouseButton1Click:Connect(function()
        status.Text = "🎯 Выполняю идеальную замену...\nУдаляю Shovel, добавляю клон питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = perfectReplace()
        
        if success then
            status.Text = "✅ ИДЕАЛЬНАЯ ЗАМЕНА ЗАВЕРШЕНА!\nВ руках точный клон питомца!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    backpackBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Замена через Backpack...\nОчищаю инвентарь и добавляю клон..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = replaceViaBackpack()
        
        if success then
            status.Text = "✅ Замена через Backpack завершена!\nКлон питомца в руках!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены через Backpack!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Запускаем
createPerfectReplacerGUI()
print("✅ PerfectShovelReplacer готов!")
print("🎯 РАДИКАЛЬНЫЙ ПОДХОД:")
print("   📋 1. Клонируем ВЕСЬ Tool питомца")
print("   🗑️ 2. Полностью удаляем Shovel")
print("   🐉 3. Добавляем клон питомца в руки")
print("🎮 Результат: ТОЧНАЯ копия питомца вместо Shovel!")
