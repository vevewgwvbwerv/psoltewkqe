-- FinalShovelReplacer.lua
-- ФИНАЛЬНОЕ РЕШЕНИЕ: Основано на РАБОЧЕЙ логике из PetScaler_v3.221

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== FINAL SHOVEL REPLACER ===")

-- Глобальные переменные
local savedPetTool = nil
local animationConnection = nil

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

-- КРИТИЧЕСКАЯ ФУНКЦИЯ из PetScaler_v3.221: smartAnchoredManagement
local function smartAnchoredManagement(copyParts)
    print("🧠 Умное управление Anchored...")
    
    -- Находим "корневую" часть
    local rootPart = nil
    local rootCandidates = {"Handle", "HumanoidRootPart", "Torso", "UpperTorso", "Body"}
    
    for _, candidateName in ipairs(rootCandidates) do
        for _, part in ipairs(copyParts) do
            if part.Name == candidateName then
                rootPart = part
                print("🎯 Найдена корневая часть:", rootPart.Name)
                break
            end
        end
        if rootPart then break end
    end
    
    -- Если корневая часть не найдена, берем первую
    if not rootPart and #copyParts > 0 then
        rootPart = copyParts[1]
        print("🎯 Используем первую часть как корневую:", rootPart.Name)
    end
    
    if not rootPart then
        print("❌ Корневая часть не найдена!")
        return
    end
    
    -- Устанавливаем Anchored состояния
    local anchoredCount = 0
    local unanchoredCount = 0
    
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            -- Корневая часть НЕ заякорена (может двигаться)
            part.Anchored = false
            unanchoredCount = unanchoredCount + 1
            print("  🔓 Корневая часть разъякорена:", part.Name)
        else
            -- Остальные части заякорены (стабильность)
            part.Anchored = true
            anchoredCount = anchoredCount + 1
        end
    end
    
    print(string.format("✅ Anchored управление: %d заякорено, %d разъякорено", anchoredCount, unanchoredCount))
end

-- Функция получения всех BasePart (из PetScaler_v3.221)
local function getAllParts(model)
    if not model then return {} end
    
    local parts = {}
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(parts, descendant)
        end
    end
    
    return parts
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

-- ФИНАЛЬНАЯ ЗАМЕНА с правильной логикой из PetScaler
local function finalReplace()
    print("\n🔥 === ФИНАЛЬНАЯ ЗАМЕНА ===")
    
    if not savedPetTool then
        print("❌ Сначала сохраните питомца!")
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
    print("🔧 Финальная замена с логикой PetScaler...")
    
    -- Создаем новый Tool как ТОЧНУЮ копию питомца
    local newTool = savedPetTool:Clone()
    newTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    print("📋 Создана точная копия питомца")
    
    -- КРИТИЧЕСКОЕ: Применяем smartAnchoredManagement
    local copyParts = getAllParts(newTool)
    print(string.format("📦 Найдено %d частей в копии", #copyParts))
    
    if #copyParts > 0 then
        smartAnchoredManagement(copyParts)
    else
        print("⚠️ Части не найдены - пропускаю Anchored управление")
    end
    
    -- Устанавливаем правильную позицию (из PetScaler)
    if newTool.PrimaryPart then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local offset = Vector3.new(5, 3, 0)  -- Смещение от игрока
            newTool.PrimaryPart.CFrame = hrp.CFrame + offset
            print("📍 Установлена позиция копии рядом с игроком")
        end
    end
    
    -- Удаляем Shovel
    print("🗑️ Удаляю Shovel...")
    shovel:Destroy()
    
    wait(0.3)
    
    -- КРИТИЧЕСКОЕ: Добавляем в Workspace сначала (как в PetScaler)
    print("🌍 Добавляю в Workspace...")
    newTool.Parent = game.Workspace
    
    wait(0.2)
    
    -- Затем в Backpack
    print("📦 Перемещаю в Backpack...")
    local backpack = character:FindFirstChild("Backpack")
    if not backpack then
        backpack = Instance.new("Backpack")
        backpack.Parent = character
    end
    newTool.Parent = backpack
    
    wait(0.1)
    
    -- Наконец в руки
    print("🎮 Перемещаю в руки...")
    newTool.Parent = character
    
    wait(0.5)
    
    -- Запускаем анимацию
    print("🎬 Запускаю анимацию...")
    startFinalAnimation(newTool)
    
    print("✅ Финальная замена завершена!")
    return true
end

-- ФИНАЛЬНАЯ АНИМАЦИЯ (простая и надежная)
local function startFinalAnimation(tool)
    if not tool then return end
    
    print("🎬 === ЗАПУСК ФИНАЛЬНОЙ АНИМАЦИИ ===")
    
    -- Останавливаем предыдущую анимацию
    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
    end
    
    -- Ищем Motor6D для анимации
    local motors = {}
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, {
                motor = obj,
                originalC0 = obj.C0,
                time = math.random() * 10
            })
            print("   🔗 Найден Motor6D: " .. obj.Name)
        end
    end
    
    print(string.format("🎭 Найдено %d Motor6D для анимации", #motors))
    
    if #motors > 0 then
        -- Motor6D анимация
        animationConnection = RunService.Heartbeat:Connect(function()
            local time = tick()
            
            for _, data in ipairs(motors) do
                if data.motor and data.motor.Parent then
                    local offsetY = math.sin(time * 2 + data.time) * 0.03
                    local offsetX = math.cos(time * 1.5 + data.time) * 0.02
                    
                    data.motor.C0 = data.originalC0 * CFrame.new(offsetX, offsetY, 0)
                    data.time = data.time + 0.01
                end
            end
        end)
        
        print("✅ Motor6D анимация запущена!")
    else
        print("⚠️ Motor6D не найдены - статичная копия")
    end
end

-- Создаем GUI
local function createFinalGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FinalShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 250)
    frame.Position = UDim2.new(0.5, -200, 0.5, -125)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🔥 FINAL SHOVEL REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "ФИНАЛЬНОЕ РЕШЕНИЕ:\n1. Возьмите питомца → Сохранить\n2. Возьмите Shovel → Финальная замена"
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
    saveBtn.Text = "💾 Сохранить питомца"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.TextScaled = true
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = frame
    
    -- Кнопка финальной замены
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 50)
    replaceBtn.Position = UDim2.new(0, 10, 0, 180)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔥 ФИНАЛЬНАЯ ЗАМЕНА"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- События
    saveBtn.MouseButton1Click:Connect(function()
        status.Text = "💾 Сохраняю питомца..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = savePet()
        
        if success then
            status.Text = "✅ Питомец сохранен!\nТеперь возьмите Shovel!"
            status.TextColor3 = Color3.new(0, 1, 0)
            replaceBtn.Visible = true
        else
            status.Text = "❌ Ошибка!\nВозьмите питомца в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🔥 Финальная замена...\nИспользую логику PetScaler..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = finalReplace()
        
        if success then
            status.Text = "✅ ФИНАЛЬНАЯ ЗАМЕНА ЗАВЕРШЕНА!\nПитомец заменил Shovel!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

-- Запускаем
createFinalGUI()
print("✅ FinalShovelReplacer готов!")
print("🔥 ОСНОВАН НА РАБОЧЕЙ ЛОГИКЕ PetScaler_v3.221!")
print("💾 1. Сохранить питомца")
print("🔥 2. Финальная замена")
