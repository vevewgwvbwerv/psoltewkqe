-- DirectShovelFix_v5_HOTBAR.lua
-- ПРАВИЛЬНОЕ РЕШЕНИЕ: Превращаем Shovel В питомца прямо в его слоте

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== DIRECT SHOVEL FIX V5 - HOTBAR PRESERVATION ===")

-- Глобальные переменные для сохранения данных питомца
local petData = {
    name = nil,
    properties = {},
    children = {},
    gripC0 = nil,
    gripC1 = nil,
    animations = {}
}

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

-- ГЛУБОКОЕ сканирование и сохранение ВСЕХ данных питомца
local function deepScanPetData(obj, path)
    local fullPath = path == "" and obj.Name or (path .. "." .. obj.Name)
    
    -- Сохраняем BasePart с полными данными
    if obj:IsA("BasePart") then
        petData.animations[fullPath] = {
            CFrame = obj.CFrame,
            Position = obj.Position,
            Rotation = obj.Rotation,
            Size = obj.Size,
            Material = obj.Material,
            Color = obj.Color,
            Transparency = obj.Transparency,
            CanCollide = obj.CanCollide,
            Anchored = obj.Anchored,
            Name = obj.Name,
            ClassName = obj.ClassName
        }
        print("🎭 " .. fullPath .. " (" .. obj.ClassName .. ") данные сохранены")
    end
    
    -- Сканируем все дочерние объекты
    for _, child in pairs(obj:GetChildren()) do
        deepScanPetData(child, fullPath)
    end
end

-- ПОЛНОЕ сканирование питомца
local function scanCompletePet()
    print("\n💾 === ПОЛНОЕ СКАНИРОВАНИЕ ПИТОМЦА ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Очищаем старые данные
    petData = {
        name = pet.Name,
        properties = {},
        children = {},
        gripC0 = nil,
        gripC1 = nil,
        animations = {}
    }
    
    -- Сохраняем свойства Tool
    petData.properties = {
        RequiresHandle = pet.RequiresHandle,
        CanBeDropped = pet.CanBeDropped,
        ManualActivationOnly = pet.ManualActivationOnly,
        Enabled = pet.Enabled
    }
    
    -- Сохраняем позицию в руке
    local character = player.Character
    if character then
        local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        local petHandle = pet:FindFirstChild("Handle")
        
        if rightHand and petHandle then
            local petGrip = rightHand:FindFirstChild("RightGrip")
            if petGrip then
                petData.gripC0 = petGrip.C0
                petData.gripC1 = petGrip.C1
                print("📍 Позиция в руке сохранена!")
            end
        end
    end
    
    -- ПОЛНОЕ сканирование структуры и анимаций
    print("🎬 === СКАНИРОВАНИЕ СТРУКТУРЫ ===")
    local animCount = 0
    
    local function countAndScan(obj, path)
        if obj:IsA("BasePart") then
            animCount = animCount + 1
        end
        deepScanPetData(obj, path)
    end
    
    countAndScan(pet, "")
    
    -- Сохраняем ПОЛНУЮ копию всех детей для воссоздания
    petData.children = {}
    for _, child in pairs(pet:GetChildren()) do
        table.insert(petData.children, child:Clone())
        print("📦 Сохранен компонент: " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    print("✅ СКАНИРОВАНИЕ ЗАВЕРШЕНО!")
    print("📊 Частей тела: " .. animCount)
    print("📦 Компонентов: " .. #petData.children)
    
    return true
end

-- ПРЕВРАЩЕНИЕ Shovel в питомца (БЕЗ смены слота!)
local function transformShovelToPet()
    print("\n🔄 === ПРЕВРАЩЕНИЕ SHOVEL В ПИТОМЦА ===")
    
    if not petData.name then
        print("❌ Сначала отсканируйте питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    print("🔄 Превращаю Shovel в питомца ПРЯМО В ЕГО СЛОТЕ...")
    
    local character = player.Character
    
    -- Шаг 1: Меняем имя и свойства Tool (Shovel остается в том же слоте!)
    shovel.Name = petData.name
    shovel.RequiresHandle = petData.properties.RequiresHandle
    shovel.CanBeDropped = petData.properties.CanBeDropped
    shovel.ManualActivationOnly = petData.properties.ManualActivationOnly
    shovel.Enabled = petData.properties.Enabled
    print("🏷️ Shovel переименован в: " .. shovel.Name)
    
    -- Шаг 2: Удаляем содержимое Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end
    
    wait(0.2)
    
    -- Шаг 3: Добавляем ВСЕ компоненты питомца
    print("📦 Добавляю компоненты питомца...")
    for _, childCopy in pairs(petData.children) do
        local newChild = childCopy:Clone()
        newChild.Parent = shovel
        print("   ✅ " .. newChild.Name .. " (" .. newChild.ClassName .. ")")
    end
    
    wait(0.3)
    
    -- Шаг 4: Восстанавливаем все анимации
    print("🎬 === ВОССТАНОВЛЕНИЕ АНИМАЦИЙ ===")
    
    local function restoreAnimations(obj, path)
        local fullPath = path == "" and obj.Name or (path .. "." .. obj.Name)
        
        if obj:IsA("BasePart") and petData.animations[fullPath] then
            local saved = petData.animations[fullPath]
            
            -- Восстанавливаем все свойства
            obj.CFrame = saved.CFrame
            obj.Position = saved.Position
            obj.Rotation = saved.Rotation
            obj.Size = saved.Size
            obj.Material = saved.Material
            obj.Color = saved.Color
            obj.Transparency = saved.Transparency
            obj.CanCollide = saved.CanCollide
            obj.Anchored = saved.Anchored
            
            print("🎯 " .. fullPath .. " анимация восстановлена")
        end
        
        -- Рекурсивно для всех детей
        for _, child in pairs(obj:GetChildren()) do
            restoreAnimations(child, fullPath)
        end
    end
    
    if next(petData.animations) then
        restoreAnimations(shovel, "")
        print("✅ Все анимации восстановлены!")
    end
    
    -- Шаг 5: Исправляем позицию в руке
    if petData.gripC0 and petData.gripC1 then
        wait(0.3)
        
        local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        local newHandle = shovel:FindFirstChild("Handle")
        
        if rightHand and newHandle then
            print("🔧 Восстанавливаю позицию в руке...")
            
            local oldGrip = rightHand:FindFirstChild("RightGrip")
            if oldGrip then oldGrip:Destroy() end
            
            local newGrip = Instance.new("Weld")
            newGrip.Name = "RightGrip"
            newGrip.Part0 = rightHand
            newGrip.Part1 = newHandle
            newGrip.C0 = petData.gripC0
            newGrip.C1 = petData.gripC1
            newGrip.Parent = rightHand
            
            print("✅ Позиция в руке восстановлена!")
        end
    end
    
    -- Шаг 6: Активируем анимационные скрипты
    spawn(function()
        wait(0.5)
        
        -- Активируем все скрипты
        for _, obj in pairs(shovel:GetDescendants()) do
            if (obj:IsA("LocalScript") or obj:IsA("Script")) and obj.Disabled then
                obj.Disabled = false
                print("📜 Активирован: " .. obj.Name)
            end
        end
        
        -- Разблокируем анимированные части
        for _, part in pairs(shovel:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Handle" then
                part.Anchored = false
            end
        end
        
        print("🎬 Все анимации активированы!")
    end)
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel превращен в питомца С АНИМАЦИЯМИ!")
    print("🎮 Остался в ТОМ ЖЕ СЛОТЕ hotbar!")
    print("📍 Позиция в руке правильная!")
    
    return true
end

-- Создаем GUI
local function createHotbarFixGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HotbarShovelFixGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0.5, -100)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    title.BorderSizePixel = 0
    title.Text = "🎯 HOTBAR PRESERVATION FIX"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "СОХРАНЕНИЕ СЛОТА:\n1. Питомец → Сканировать\n2. Shovel → Превратить"
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
    scanBtn.Text = "💾 СКАНИРОВАТЬ питомца"
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.TextScaled = true
    scanBtn.Font = Enum.Font.SourceSansBold
    scanBtn.Parent = frame
    
    -- Кнопка превращения
    local transformBtn = Instance.new("TextButton")
    transformBtn.Size = UDim2.new(1, -20, 0, 40)
    transformBtn.Position = UDim2.new(0, 10, 0, 160)
    transformBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.8)
    transformBtn.BorderSizePixel = 0
    transformBtn.Text = "🔄 ПРЕВРАТИТЬ Shovel"
    transformBtn.TextColor3 = Color3.new(1, 1, 1)
    transformBtn.TextScaled = true
    transformBtn.Font = Enum.Font.SourceSansBold
    transformBtn.Visible = false
    transformBtn.Parent = frame
    
    -- События
    scanBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сканирую питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = scanCompletePet()
        
        if success then
            status.Text = "✅ Питомец отсканирован!\nТеперь возьмите Shovel"
            status.TextColor3 = Color3.new(0, 1, 0)
            transformBtn.Visible = true
        else
            status.Text = "❌ Ошибка!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    transformBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Превращаю Shovel..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = transformShovelToPet()
        
        if success then
            status.Text = "✅ ГОТОВО!\nShovel = Питомец в том же слоте!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка!\nВозьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createHotbarFixGUI()
print("✅ DirectShovelFix V5 готов!")
print("🎯 ПРЕВРАЩЕНИЕ SHOVEL БЕЗ СМЕНЫ СЛОТА!")
print("📍 HOTBAR СОХРАНЯЕТСЯ!")
