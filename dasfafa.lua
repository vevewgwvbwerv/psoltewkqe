-- ToolCloneDiagnostic.lua
-- Диагностика проблем с клонированием и добавлением Tool в руки

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== TOOL CLONE DIAGNOSTIC ===")

-- Глобальные переменные
local scannedTool = nil
local diagnosticConnection = nil

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

-- ГЛУБОКОЕ СКАНИРОВАНИЕ питомца
local function deepScanPet()
    print("\n🔍 === ГЛУБОКОЕ СКАНИРОВАНИЕ ПИТОМЦА ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    print("📊 Анализирую структуру...")
    
    -- Анализируем структуру питомца
    local structure = {
        name = pet.Name,
        className = pet.ClassName,
        parent = pet.Parent and pet.Parent.Name or "NIL",
        children = {},
        properties = {}
    }
    
    -- Сохраняем важные свойства
    if pet:IsA("Tool") then
        structure.properties.RequiresHandle = pet.RequiresHandle
        structure.properties.CanBeDropped = pet.CanBeDropped
        structure.properties.ManualActivationOnly = pet.ManualActivationOnly
        print("🔧 Tool свойства:")
        print("   RequiresHandle: " .. tostring(pet.RequiresHandle))
        print("   CanBeDropped: " .. tostring(pet.CanBeDropped))
        print("   ManualActivationOnly: " .. tostring(pet.ManualActivationOnly))
    end
    
    -- Анализируем детей
    print("📦 Дети питомца:")
    for _, child in pairs(pet:GetChildren()) do
        local childData = {
            name = child.Name,
            className = child.ClassName,
            parent = child.Parent.Name
        }
        
        if child:IsA("BasePart") then
            childData.size = child.Size
            childData.cframe = child.CFrame
            childData.canCollide = child.CanCollide
            print(string.format("   📦 Part: %s (Size: %.2f,%.2f,%.2f)", 
                child.Name, child.Size.X, child.Size.Y, child.Size.Z))
        elseif child:IsA("SpecialMesh") then
            childData.meshType = child.MeshType
            childData.scale = child.Scale
            print(string.format("   🎨 Mesh: %s (Scale: %.2f,%.2f,%.2f)", 
                child.Name, child.Scale.X, child.Scale.Y, child.Scale.Z))
        elseif child:IsA("Motor6D") then
            childData.part0 = child.Part0 and child.Part0.Name or "NIL"
            childData.part1 = child.Part1 and child.Part1.Name or "NIL"
            print(string.format("   🔗 Motor6D: %s (%s -> %s)", 
                child.Name, childData.part0, childData.part1))
        elseif child:IsA("Script") or child:IsA("LocalScript") then
            childData.enabled = child.Enabled
            print(string.format("   📜 Script: %s (Enabled: %s)", 
                child.Name, tostring(child.Enabled)))
        else
            print(string.format("   ❓ Other: %s (%s)", child.Name, child.ClassName))
        end
        
        table.insert(structure.children, childData)
    end
    
    -- Сохраняем структуру
    scannedTool = structure
    
    print("✅ Сканирование завершено!")
    print(string.format("📊 Итого: %d детей", #structure.children))
    
    return true
end

-- СОЗДАНИЕ ТОЧНОГО КЛОНА
local function createPerfectClone()
    print("\n🎭 === СОЗДАНИЕ ТОЧНОГО КЛОНА ===")
    
    if not scannedTool then
        print("❌ Сначала отсканируйте питомца!")
        return nil
    end
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return nil
    end
    
    print("🔧 Создаю точный клон...")
    
    -- Создаем клон
    local clone = pet:Clone()
    clone.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    print("✅ Клон создан: " .. clone.Name)
    print("📊 Проверяю структуру клона...")
    
    -- Проверяем структуру клона
    local cloneChildCount = #clone:GetChildren()
    local originalChildCount = #pet:GetChildren()
    
    print(string.format("📊 Дети: Оригинал=%d, Клон=%d", originalChildCount, cloneChildCount))
    
    if cloneChildCount ~= originalChildCount then
        print("⚠️ ВНИМАНИЕ: Количество детей не совпадает!")
    end
    
    -- Проверяем Handle
    local handle = clone:FindFirstChild("Handle")
    if handle then
        print("✅ Handle найден: " .. handle.Name)
        print(string.format("   Size: %.2f,%.2f,%.2f", handle.Size.X, handle.Size.Y, handle.Size.Z))
        print("   CanCollide: " .. tostring(handle.CanCollide))
    else
        print("❌ Handle НЕ найден! Создаю...")
        handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.Transparency = 1
        handle.CanCollide = false
        handle.Parent = clone
        print("✅ Handle создан")
    end
    
    return clone
end

-- ДИАГНОСТИЧЕСКАЯ ЗАМЕНА с подробным логированием
local function diagnosticReplace()
    print("\n🔬 === ДИАГНОСТИЧЕСКАЯ ЗАМЕНА ===")
    
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
    print("📍 Character: " .. character.Name)
    
    -- Создаем клон
    local clone = createPerfectClone()
    if not clone then
        print("❌ Не удалось создать клон!")
        return false
    end
    
    print("🔧 Начинаю замену...")
    
    -- Шаг 1: Логируем состояние ДО замены
    print("📊 СОСТОЯНИЕ ДО ЗАМЕНЫ:")
    local toolsInCharacterBefore = {}
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(toolsInCharacterBefore, obj.Name)
        end
    end
    print("   Tools в Character: " .. table.concat(toolsInCharacterBefore, ", "))
    
    -- Шаг 2: Удаляем Shovel
    print("🗑️ Удаляю Shovel...")
    shovel:Destroy()
    
    -- Шаг 3: Пауза
    wait(0.3)
    
    -- Шаг 4: Логируем состояние ПОСЛЕ удаления
    print("📊 СОСТОЯНИЕ ПОСЛЕ УДАЛЕНИЯ:")
    local toolsInCharacterAfterDelete = {}
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(toolsInCharacterAfterDelete, obj.Name)
        end
    end
    print("   Tools в Character: " .. (table.concat(toolsInCharacterAfterDelete, ", ") ~= "" and table.concat(toolsInCharacterAfterDelete, ", ") or "ПУСТО"))
    
    -- Шаг 5: Добавляем клон
    print("🐉 Добавляю клон в Character...")
    clone.Parent = character
    
    -- Шаг 6: Пауза
    wait(0.2)
    
    -- Шаг 7: Логируем состояние ПОСЛЕ добавления
    print("📊 СОСТОЯНИЕ ПОСЛЕ ДОБАВЛЕНИЯ:")
    local toolsInCharacterAfterAdd = {}
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(toolsInCharacterAfterAdd, obj.Name)
            print("   🎮 Tool в руках: " .. obj.Name)
            print("      Parent: " .. (obj.Parent and obj.Parent.Name or "NIL"))
            print("      ClassName: " .. obj.ClassName)
        end
    end
    
    -- Шаг 8: Проверяем Backpack
    local backpack = character:FindFirstChild("Backpack")
    if backpack then
        print("📦 ПРОВЕРКА BACKPACK:")
        local toolsInBackpack = {}
        for _, obj in pairs(backpack:GetChildren()) do
            if obj:IsA("Tool") then
                table.insert(toolsInBackpack, obj.Name)
                print("   📦 Tool в Backpack: " .. obj.Name)
            end
        end
        if #toolsInBackpack == 0 then
            print("   📦 Backpack пуст")
        end
    else
        print("❌ Backpack не найден!")
    end
    
    print("🎯 === ИТОГ ДИАГНОСТИКИ ===")
    if #toolsInCharacterAfterAdd > 0 then
        print("✅ УСПЕХ: Клон добавлен в руки!")
        print("📝 Имя: " .. toolsInCharacterAfterAdd[1])
    else
        print("❌ ПРОВАЛ: Клон НЕ появился в руках!")
        print("🔍 Возможные причины:")
        print("   1. Клон был удален системой")
        print("   2. Клон попал в Backpack")
        print("   3. Проблема с Handle")
        print("   4. Проблема с Tool свойствами")
    end
    
    return #toolsInCharacterAfterAdd > 0
end

-- Создаем GUI
local function createDiagnosticGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ToolCloneDiagnosticGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 450)
    frame.Position = UDim2.new(0.5, -250, 0.5, -225)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🔬 TOOL CLONE DIAGNOSTIC"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 100)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "ДИАГНОСТИКА ПРОБЛЕМ С КЛОНИРОВАНИЕМ:\n1. Возьмите питомца в руки\n2. Глубоко отсканируйте структуру\n3. Возьмите Shovel\n4. Выполните диагностическую замену"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сканирования
    local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(1, -20, 0, 50)
    scanBtn.Position = UDim2.new(0, 10, 0, 160)
    scanBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    scanBtn.BorderSizePixel = 0
    scanBtn.Text = "🔍 Глубокое сканирование"
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.TextScaled = true
    scanBtn.Font = Enum.Font.SourceSansBold
    scanBtn.Parent = frame
    
    -- Кнопка создания клона
    local cloneBtn = Instance.new("TextButton")
    cloneBtn.Size = UDim2.new(1, -20, 0, 50)
    cloneBtn.Position = UDim2.new(0, 10, 0, 220)
    cloneBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    cloneBtn.BorderSizePixel = 0
    cloneBtn.Text = "🎭 Создать точный клон"
    cloneBtn.TextColor3 = Color3.new(1, 1, 1)
    cloneBtn.TextScaled = true
    cloneBtn.Font = Enum.Font.SourceSansBold
    cloneBtn.Visible = false
    cloneBtn.Parent = frame
    
    -- Кнопка диагностической замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 50)
    replaceBtn.Position = UDim2.new(0, 10, 0, 280)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0, 0.4)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔬 ДИАГНОСТИЧЕСКАЯ ЗАМЕНА"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 40)
    closeBtn.Position = UDim2.new(0, 10, 0, 340)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События
    scanBtn.MouseButton1Click:Connect(function()
        status.Text = "🔍 Сканирую питомца...\nАнализирую структуру и свойства..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = deepScanPet()
        
        if success then
            status.Text = "✅ Сканирование завершено!\nСтруктура питомца сохранена.\nТеперь возьмите Shovel."
            status.TextColor3 = Color3.new(0, 1, 0)
            cloneBtn.Visible = true
            replaceBtn.Visible = true
        else
            status.Text = "❌ Ошибка сканирования!\nВозьмите питомца в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    cloneBtn.MouseButton1Click:Connect(function()
        status.Text = "🎭 Создаю точный клон...\nПроверяю структуру..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local clone = createPerfectClone()
        
        if clone then
            status.Text = "✅ Точный клон создан!\nПроверьте консоль для деталей."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка создания клона!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🔬 Диагностическая замена...\nПодробное логирование..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = diagnosticReplace()
        
        if success then
            status.Text = "✅ ДИАГНОСТИКА ЗАВЕРШЕНА!\nКлон в руках! Проверьте консоль."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ ДИАГНОСТИКА: Клон НЕ появился!\nПроверьте консоль для деталей."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Запускаем
createDiagnosticGUI()
print("✅ ToolCloneDiagnostic готов!")
print("🔬 ЦЕЛЬ: Выяснить, почему клон питомца не появляется в руках")
print("📊 Будет подробное логирование каждого шага")
