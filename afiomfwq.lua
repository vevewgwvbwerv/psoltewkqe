-- DirectShovelFix_v3.lua
-- УЛУЧШЕННАЯ ВЕРСИЯ: Полное копирование анимаций и позиций

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== DIRECT SHOVEL FIX V3 ===")

-- Глобальные переменные
local petTool = nil
local savedPetC0 = nil
local savedPetC1 = nil
local savedAnimations = {} -- Все CFrame анимации

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

-- ГЛУБОКОЕ сканирование всех частей питомца
local function deepScanAllParts(obj, fullPath)
    -- Если это BasePart - сохраняем его полное состояние
    if obj:IsA("BasePart") then
        savedAnimations[fullPath] = {
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
        print("🎭 " .. fullPath .. " (" .. obj.ClassName .. ") сохранен")
    end
    
    -- ВАЖНО: Сохраняем также Motor6D для анимаций
    if obj:IsA("Motor6D") then
        savedAnimations[fullPath .. "_Motor6D"] = {
            C0 = obj.C0,
            C1 = obj.C1,
            Part0 = obj.Part0,
            Part1 = obj.Part1,
            Name = obj.Name,
            ClassName = obj.ClassName
        }
        print("⚙️ " .. fullPath .. " Motor6D сохранен")
    end
    
    -- Рекурсивно сканируем ВСЕ дочерние объекты
    for _, child in pairs(obj:GetChildren()) do
        local childPath = fullPath == "" and child.Name or (fullPath .. "." .. child.Name)
        deepScanAllParts(child, childPath)
    end
end

-- ВОССТАНОВЛЕНИЕ всех анимаций на копии
local function restoreAllAnimations(obj, fullPath)
    -- Если это BasePart и у нас есть сохраненные данные - восстанавливаем
    if obj:IsA("BasePart") and savedAnimations[fullPath] then
        local saved = savedAnimations[fullPath]
        
        -- Восстанавливаем только СТАТИЧНЫЕ свойства (НЕ CFrame - он может анимироваться!)
        obj.Size = saved.Size
        obj.Material = saved.Material
        obj.Color = saved.Color
        obj.Transparency = saved.Transparency
        obj.CanCollide = saved.CanCollide
        
        -- CFrame восстанавливаем ТОЛЬКО если часть не анимируется
        local hasMotor6D = obj:FindFirstChildOfClass("Motor6D") or obj.Parent:FindFirstChild(obj.Name .. "_Motor6D")
        if not hasMotor6D then
            obj.CFrame = saved.CFrame
            obj.Position = saved.Position
            obj.Rotation = saved.Rotation
            obj.Anchored = saved.Anchored
            print("🎯 " .. fullPath .. " (статичная часть) восстановлен")
        else
            print("🎭 " .. fullPath .. " (анимированная часть) - CFrame оставлен для анимации")
        end
    end
    
    -- КРИТИЧЕСКИ ВАЖНО: Восстанавливаем Motor6D для живой анимации
    if obj:IsA("Motor6D") and savedAnimations[fullPath .. "_Motor6D"] then
        local savedMotor = savedAnimations[fullPath .. "_Motor6D"]
        
        -- Восстанавливаем соединения Motor6D
        obj.C0 = savedMotor.C0
        obj.C1 = savedMotor.C1
        
        print("⚙️ " .. fullPath .. " Motor6D восстановлен для анимации")
    end
    
    -- Рекурсивно восстанавливаем для всех дочерних объектов
    for _, child in pairs(obj:GetChildren()) do
        local childPath = fullPath == "" and child.Name or (fullPath .. "." .. child.Name)
        restoreAllAnimations(child, childPath)
    end
end

-- СОХРАНИТЬ питомца И его анимации
local function savePet()
    print("\n💾 === СОХРАНЕНИЕ ПИТОМЦА И АНИМАЦИЙ ===")
    
    local pet = findPetInHands()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Сохраняем ссылку на питомца
    petTool = pet
    
    -- Сохраняем позицию в руке
    local character = player.Character
    if character then
        local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        local petHandle = pet:FindFirstChild("Handle")
        
        if rightHand and petHandle then
            local petGrip = rightHand:FindFirstChild("RightGrip")
            if petGrip then
                savedPetC0 = petGrip.C0
                savedPetC1 = petGrip.C1
                print("📍 Позиция в руке сохранена!")
            end
        end
    end
    
    -- ГЛАВНОЕ: Сканируем ВСЕ анимации питомца
    print("🎬 === ГЛУБОКОЕ СКАНИРОВАНИЕ АНИМАЦИЙ ===")
    savedAnimations = {}
    local partCount = 0
    
    local function countAndScan(obj, path)
        if obj:IsA("BasePart") then
            partCount = partCount + 1
        end
        deepScanAllParts(obj, path)
    end
    
    countAndScan(pet, "")
    
    print("✅ СКАНИРОВАНИЕ ЗАВЕРШЕНО!")
    print("📊 Найдено частей: " .. partCount)
    print("💾 Анимаций сохранено: " .. tostring(#savedAnimations))
    
    return true
end

-- ПРЯМАЯ ЗАМЕНА с восстановлением анимаций
local function directReplace()
    print("\n🔄 === ПРЯМАЯ ЗАМЕНА С АНИМАЦИЯМИ ===")
    
    if not petTool then
        print("❌ Сначала сохраните питомца!")
        return false
    end
    
    local shovel = findShovelInHands()
    if not shovel then
        print("❌ Shovel в руках не найден!")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovel.Name)
    
    -- Шаг 1: Копируем свойства Tool
    shovel.Name = petTool.Name
    shovel.RequiresHandle = petTool.RequiresHandle
    shovel.CanBeDropped = petTool.CanBeDropped
    shovel.ManualActivationOnly = petTool.ManualActivationOnly
    print("🔧 Свойства Tool скопированы")
    
    -- Шаг 2: Удаляем содержимое Shovel
    print("🗑️ Очищаю Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end
    
    wait(0.2)
    
    -- Шаг 3: Копируем содержимое питомца
    print("📋 Копирую содержимое питомца...")
    for _, child in pairs(petTool:GetChildren()) do
        local copy = child:Clone()
        copy.Parent = shovel
        print("   ✅ " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    wait(0.3)
    
    -- Шаг 4: ВОССТАНАВЛИВАЕМ ВСЕ АНИМАЦИИ
    print("🎬 === ВОССТАНОВЛЕНИЕ АНИМАЦИЙ ===")
    if next(savedAnimations) then
        print("🔄 Применяю сохраненные анимации...")
        restoreAllAnimations(shovel, "")
        print("✅ Все анимации восстановлены!")
    else
        print("⚠️ Анимации не найдены")
    end
    
    wait(0.2)
    
    -- Шаг 4.5: КРИТИЧЕСКИ ВАЖНО - Копируем ЖИВОЙ анимационный механизм
    print("🎬 === КОПИРОВАНИЕ ЖИВЫХ АНИМАЦИЙ ===")
    
    -- Ищем Animator в оригинальном питомце
    local petAnimator = petTool:FindFirstChildOfClass("Animator")
    if petAnimator then
        -- Копируем Animator в новый питомец
        local newAnimator = petAnimator:Clone()
        newAnimator.Parent = shovel
        print("🎭 Animator скопирован - анимации будут живыми!")
    else
        print("⚠️ Animator не найден в оригинальном питомце")
    end
    
    -- Ищем и копируем анимационные скрипты
    for _, child in pairs(petTool:GetChildren()) do
        if child:IsA("LocalScript") or child:IsA("Script") then
            local scriptCopy = child:Clone()
            scriptCopy.Parent = shovel
            print("📜 Скрипт анимации скопирован: " .. child.Name)
        end
    end
    
    -- Принудительно запускаем анимации
    spawn(function()
        wait(0.5)
        local newAnimator = shovel:FindFirstChildOfClass("Animator")
        if newAnimator then
            print("🎬 Animator найден - анимации активируются!")
            
            -- Принудительно активируем все анимационные скрипты
            for _, child in pairs(shovel:GetDescendants()) do
                if (child:IsA("LocalScript") or child:IsA("Script")) and child.Disabled then
                    child.Disabled = false
                    print("📜 Активирован скрипт: " .. child.Name)
                end
            end
            
            -- Убираем Anchored с анимированных частей для свободного движения
            for _, part in pairs(shovel:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "Handle" then
                    part.Anchored = false
                    print("🔓 " .. part.Name .. " разблокирован для анимации")
                end
            end
            
            print("✅ ВСЕ АНИМАЦИИ АКТИВИРОВАНЫ!")
        else
            print("❌ Animator не найден - анимации могут не работать")
        end
    end)
    
    -- Шаг 5: Исправляем позицию в руке
    local character = player.Character
    if character and savedPetC0 and savedPetC1 then
        local rightHand = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        local newHandle = shovel:FindFirstChild("Handle")
        
        if rightHand and newHandle then
            print("🔧 Применяю сохраненную позицию...")
            
            local oldGrip = rightHand:FindFirstChild("RightGrip")
            if oldGrip then oldGrip:Destroy() end
            
            local newGrip = Instance.new("Weld")
            newGrip.Name = "RightGrip"
            newGrip.Part0 = rightHand
            newGrip.Part1 = newHandle
            newGrip.C0 = savedPetC0
            newGrip.C1 = savedPetC1
            newGrip.Parent = rightHand
            
            print("✅ Позиция Handle восстановлена!")
        end
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel превращен в питомца с анимациями!")
    print("🎮 Питомец должен быть в правильной позиции!")
    
    return true
end

-- Создаем GUI
local function createDirectFixGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DirectShovelFixGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 250)
    frame.Position = UDim2.new(0.5, -150, 0.5, -125)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🎯 DIRECT SHOVEL FIX V3"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "С АНИМАЦИЯМИ:\n1. Питомец в руки → Сохранить\n2. Shovel в руки → Заменить"
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
    saveBtn.Text = "💾 Сохранить питомца + анимации"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 50)
    replaceBtn.Position = UDim2.new(0, 10, 0, 180)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔄 ЗАМЕНИТЬ с анимациями"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сканирую питомца и анимации..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = savePet()
        
        if success then
            status.Text = "✅ Питомец и анимации сохранены!\nТеперь возьмите Shovel"
            status.TextColor3 = Color3.new(0, 1, 0)
            replaceBtn.Visible = true
        else
            status.Text = "❌ Ошибка!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Замена с анимациями..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = directReplace()
        
        if success then
            status.Text = "✅ ГОТОВО!\nПитомец с анимациями в руке!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createDirectFixGUI()
print("✅ DirectShovelFix V3 готов!")
print("🎬 ТЕПЕРЬ С ПОЛНОЙ ПОДДЕРЖКОЙ АНИМАЦИЙ!")
