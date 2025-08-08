-- AdvancedShovelReplacer.lua
-- Основан на методах из CFrameAnimationDiagnostic и ComprehensiveEggPetAnimationAnalyzer
-- Правильно сканирует CFrame анимацию питомца в руке

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== ADVANCED SHOVEL REPLACER ===")

-- Глобальная переменная для хранения отсканированного питомца с анимацией
local scannedPetData = nil
local animationConnection = nil

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

-- Функция поиска питомца в руках (из CFrameAnimationDiagnostic)
local function findHandHeldPet()
    local character = player.Character
    if not character then return nil end
    
    local handTool = character:FindFirstChildOfClass("Tool")
    if not handTool then return nil end
    
    -- Проверяем что это питомец (содержит KG и Age)
    if string.find(handTool.Name, "%[") and string.find(handTool.Name, "KG%]") then
        print("🎯 Найден питомец в руке:", handTool.Name)
        return handTool
    end
    
    return nil
end

-- Функция получения всех анимируемых частей из Tool (из CFrameAnimationDiagnostic)
local function getAnimatedPartsFromTool(tool)
    local parts = {}
    
    if not tool then return parts end
    
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Handle" then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- Функция глубокого анализа частей модели (из CFrameAnimationDiagnostic)
local function analyzeParts(model, modelName)
    print(string.format("\n📊 === АНАЛИЗ ЧАСТЕЙ: %s ===", modelName))
    
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    print(string.format("📦 Всего BasePart: %d", #parts))
    
    -- Группируем части по типам
    local partsByName = {}
    for _, part in ipairs(parts) do
        local name = part.Name
        if not partsByName[name] then
            partsByName[name] = 0
        end
        partsByName[name] = partsByName[name] + 1
    end
    
    print("📋 Части по именам:")
    for name, count in pairs(partsByName) do
        print(string.format("  - %s: %d шт", name, count))
    end
    
    return parts, partsByName
end

-- НОВАЯ ФУНКЦИЯ: Сканирование питомца с отслеживанием CFrame анимации
local function scanPetWithAnimation()
    print("\n🔍 === СКАНИРОВАНИЕ ПИТОМЦА С АНИМАЦИЕЙ ===")
    
    local pet = findHandHeldPet()
    if not pet then
        print("❌ Питомец в руках не найден!")
        return false
    end
    
    print("✅ Найден питомец: " .. pet.Name)
    
    -- Получаем все анимируемые части
    local animatedParts = getAnimatedPartsFromTool(pet)
    print(string.format("📦 Анимируемых частей: %d", #animatedParts))
    
    -- Анализируем структуру
    local allParts, partsByName = analyzeParts(pet, "ПИТОМЕЦ В РУКЕ")
    
    -- Инициализируем данные питомца
    scannedPetData = {
        name = pet.Name,
        className = pet.ClassName,
        properties = {},
        children = {},
        animatedParts = {},
        staticCFrames = {},
        motor6ds = {},
        welds = {},
        animations = {},
        partsByName = partsByName
    }
    
    -- Копируем основные свойства Tool
    local importantProps = {"RequiresHandle", "CanBeDropped", "Enabled", "ManualActivationOnly"}
    for _, prop in pairs(importantProps) do
        pcall(function()
            scannedPetData.properties[prop] = pet[prop]
        end)
    end
    
    -- Глубокое копирование детей с сохранением связей
    for _, child in pairs(pet:GetChildren()) do
        local childData = {
            name = child.Name,
            className = child.ClassName,
            object = child:Clone()
        }
        
        -- Сохраняем статические CFrame для BasePart
        if child:IsA("BasePart") then
            scannedPetData.staticCFrames[child.Name] = child.CFrame
            print("   📐 Сохранен статический CFrame: " .. child.Name)
        end
        
        -- Сохраняем Motor6D соединения
        if child:IsA("Motor6D") then
            local motor6dData = {
                name = child.Name,
                part0Name = child.Part0 and child.Part0.Name or nil,
                part1Name = child.Part1 and child.Part1.Name or nil,
                c0 = child.C0,
                c1 = child.C1,
                currentAngle = child.CurrentAngle,
                desiredAngle = child.DesiredAngle
            }
            scannedPetData.motor6ds[child.Name] = motor6dData
            print("   🔗 Сохранен Motor6D: " .. child.Name)
        end
        
        -- Сохраняем Weld соединения
        if child:IsA("Weld") then
            local weldData = {
                name = child.Name,
                part0Name = child.Part0 and child.Part0.Name or nil,
                part1Name = child.Part1 and child.Part1.Name or nil,
                c0 = child.C0,
                c1 = child.C1
            }
            scannedPetData.welds[child.Name] = weldData
            print("   🔗 Сохранен Weld: " .. child.Name)
        end
        
        table.insert(scannedPetData.children, childData)
    end
    
    -- КЛЮЧЕВАЯ ЧАСТЬ: Отслеживание CFrame анимации в реальном времени
    print("\n🎬 === ОТСЛЕЖИВАНИЕ CFrame АНИМАЦИИ ===")
    print("Записываю анимацию в течение 5 секунд...")
    
    local previousStates = {}
    local animationFrames = {}
    local frameCount = 0
    
    -- Инициализируем начальные состояния
    for _, part in ipairs(animatedParts) do
        if part and part.Parent then
            previousStates[part.Name] = part.CFrame
            animationFrames[part.Name] = {}
        end
    end
    
    local startTime = tick()
    
    -- Останавливаем предыдущее отслеживание если есть
    if animationConnection and animationConnection.Connected then
        animationConnection:Disconnect()
        animationConnection = nil
    end
    
    animationConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local elapsed = currentTime - startTime
        
        -- Записываем кадры каждые 0.05 секунды
        if elapsed % 0.05 < 0.016 then
            frameCount = frameCount + 1
            
            for _, part in ipairs(animatedParts) do
                if part and part.Parent then
                    local partName = part.Name
                    local currentCFrame = part.CFrame
                    
                    -- Сохраняем кадр анимации
                    if not animationFrames[partName] then
                        animationFrames[partName] = {}
                    end
                    
                    table.insert(animationFrames[partName], {
                        time = elapsed,
                        cframe = currentCFrame
                    })
                    
                    -- Проверяем изменения
                    if previousStates[partName] then
                        local prevCFrame = previousStates[partName]
                        local positionDiff = (currentCFrame.Position - prevCFrame.Position).Magnitude
                        local rotationDiff = math.abs(currentCFrame.LookVector:Dot(prevCFrame.LookVector) - 1)
                        
                        if positionDiff > 0.001 or rotationDiff > 0.001 then
                            print(string.format("🔄 Анимация: %s (pos: %.3f, rot: %.3f)", partName, positionDiff, rotationDiff))
                        end
                    end
                    
                    previousStates[partName] = currentCFrame
                end
            end
        end
        
        -- Останавливаем через 5 секунд
        if elapsed > 5 then
            animationConnection:Disconnect()
            animationConnection = nil
            
            -- Сохраняем записанную анимацию
            scannedPetData.animationFrames = animationFrames
            scannedPetData.totalFrames = frameCount
            
            print(string.format("\n📊 АНИМАЦИЯ ЗАПИСАНА:"))
            print(string.format("🎬 Всего кадров: %d", frameCount))
            print(string.format("⏱️ Длительность: %.1f сек", elapsed))
            
            local animatedPartsCount = 0
            for partName, frames in pairs(animationFrames) do
                if #frames > 0 then
                    animatedPartsCount = animatedPartsCount + 1
                    print(string.format("  - %s: %d кадров", partName, #frames))
                end
            end
            
            print(string.format("🎭 Анимированных частей: %d", animatedPartsCount))
            print("✅ Питомец отсканирован с записью анимации!")
        end
    end)
    
    return true
end

-- Функция замены Shovel с воспроизведением анимации
local function replaceShovelWithAnimation()
    print("\n🔄 === ЗАМЕНА SHOVEL С ВОСПРОИЗВЕДЕНИЕМ АНИМАЦИИ ===")
    
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
    print("🔧 Заменяю Shovel на питомца с анимацией...")
    
    -- Шаг 1: Меняем имя Shovel
    shovel.Name = "Dragonfly [6.36 KG] [Age 35]"
    print("✅ Имя изменено: " .. shovel.Name)
    
    -- Шаг 2: Удаляем всё содержимое Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovel:GetChildren()) do
        child:Destroy()
    end
    
    wait(0.1)
    
    -- Шаг 3: Добавляем содержимое питомца
    print("📋 Добавляю содержимое питомца...")
    local addedParts = {}
    
    for _, childData in pairs(scannedPetData.children) do
        local newChild = childData.object:Clone()
        newChild.Parent = shovel
        
        if newChild:IsA("BasePart") then
            addedParts[newChild.Name] = newChild
            -- Устанавливаем начальный CFrame
            if scannedPetData.staticCFrames[newChild.Name] then
                newChild.CFrame = scannedPetData.staticCFrames[newChild.Name]
            end
        end
        
        print("   ✅ Добавлен: " .. newChild.Name .. " (" .. newChild.ClassName .. ")")
    end
    
    -- Шаг 4: Восстанавливаем Motor6D и Weld соединения
    print("🔗 Восстанавливаю соединения...")
    
    -- Motor6D
    for motorName, motorData in pairs(scannedPetData.motor6ds) do
        local motor = shovel:FindFirstChild(motorName)
        if motor and motor:IsA("Motor6D") then
            if motorData.part0Name then
                motor.Part0 = addedParts[motorData.part0Name]
            end
            if motorData.part1Name then
                motor.Part1 = addedParts[motorData.part1Name]
            end
            motor.C0 = motorData.c0
            motor.C1 = motorData.c1
            motor.CurrentAngle = motorData.currentAngle
            motor.DesiredAngle = motorData.desiredAngle
            print("   🔗 Восстановлен Motor6D: " .. motorName)
        end
    end
    
    -- Weld
    for weldName, weldData in pairs(scannedPetData.welds) do
        local weld = shovel:FindFirstChild(weldName)
        if weld and weld:IsA("Weld") then
            if weldData.part0Name then
                weld.Part0 = addedParts[weldData.part0Name]
            end
            if weldData.part1Name then
                weld.Part1 = addedParts[weldData.part1Name]
            end
            weld.C0 = weldData.c0
            weld.C1 = weldData.c1
            print("   🔗 Восстановлен Weld: " .. weldName)
        end
    end
    
    -- Шаг 5: Копируем свойства
    for property, value in pairs(scannedPetData.properties) do
        pcall(function()
            if property ~= "Name" and property ~= "Parent" then
                shovel[property] = value
            end
        end)
    end
    
    -- Шаг 6: ВОСПРОИЗВОДИМ АНИМАЦИЮ
    if scannedPetData.animationFrames and next(scannedPetData.animationFrames) then
        print("🎬 Запускаю воспроизведение анимации...")
        
        local animStartTime = tick()
        local animConnection
        
        animConnection = RunService.Heartbeat:Connect(function()
            local elapsed = tick() - animStartTime
            
            -- Циклически воспроизводим анимацию (5 секунд цикл)
            local cycleTime = elapsed % 5
            
            for partName, frames in pairs(scannedPetData.animationFrames) do
                local part = addedParts[partName]
                if part and #frames > 0 then
                    -- Находим ближайший кадр по времени
                    local bestFrame = frames[1]
                    local bestTimeDiff = math.abs(cycleTime - bestFrame.time)
                    
                    for _, frame in ipairs(frames) do
                        local timeDiff = math.abs(cycleTime - frame.time)
                        if timeDiff < bestTimeDiff then
                            bestTimeDiff = timeDiff
                            bestFrame = frame
                        end
                    end
                    
                    -- Применяем CFrame из кадра
                    part.CFrame = bestFrame.cframe
                end
            end
        end)
        
        print("✅ Анимация запущена в цикле!")
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("✅ Shovel заменен на питомца с анимацией!")
    print("📝 Новое имя: " .. shovel.Name)
    print("🎬 Анимация воспроизводится циклически")
    print("🎮 Питомец должен двигаться как оригинал!")
    
    return true
end

-- Создаем GUI
local function createAdvancedReplacerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedShovelReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 350)
    frame.Position = UDim2.new(0.5, -225, 0.5, -175)
    frame.BackgroundColor3 = Color3.new(0.1, 0.2, 0.3)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.4, 0.6)
    title.BorderSizePixel = 0
    title.Text = "🎬 ADVANCED SHOVEL REPLACER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "1. Возьмите питомца в руки\n2. Отсканируйте с записью анимации (5 сек)\n3. Возьмите Shovel\n4. Замените с воспроизведением анимации"
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка сканирования с анимацией
    local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(1, -20, 0, 50)
    scanBtn.Position = UDim2.new(0, 10, 0, 140)
    scanBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    scanBtn.BorderSizePixel = 0
    scanBtn.Text = "🎬 Сканировать с записью анимации"
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.TextScaled = true
    scanBtn.Font = Enum.Font.SourceSansBold
    scanBtn.Parent = frame
    
    -- Кнопка замены с анимацией
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 50)
    replaceBtn.Position = UDim2.new(0, 10, 0, 200)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔄 Заменить с воспроизведением анимации"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Visible = false
    replaceBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 40)
    closeBtn.Position = UDim2.new(0, 10, 0, 260)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События
    scanBtn.MouseButton1Click:Connect(function()
        status.Text = "🎬 Сканирую питомца с записью анимации...\nДержите питомца в руках 5 секунд!"
        status.TextColor3 = Color3.new(1, 1, 0)
        scanBtn.Enabled = false
        
        local success = scanPetWithAnimation()
        
        wait(6) -- Ждем завершения записи
        
        if success and scannedPetData then
            status.Text = "✅ Питомец отсканирован с анимацией!\nТеперь возьмите Shovel и замените."
            status.TextColor3 = Color3.new(0, 1, 0)
            replaceBtn.Visible = true
        else
            status.Text = "❌ Ошибка сканирования!\nВозьмите питомца в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
        
        scanBtn.Enabled = true
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Заменяю Shovel с воспроизведением анимации..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local success = replaceShovelWithAnimation()
        
        if success then
            status.Text = "✅ Shovel заменен с анимацией!\nПитомец должен двигаться!"
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Ошибка замены!\nВозьмите Shovel в руки."
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        if animationConnection and animationConnection.Connected then
            animationConnection:Disconnect()
            animationConnection = nil
        end
        screenGui:Destroy()
    end)
end

-- Запускаем
createAdvancedReplacerGUI()
print("✅ AdvancedShovelReplacer готов!")
print("🎬 Основан на методах из CFrameAnimationDiagnostic")
print("🔍 1. Возьмите питомца в руки")
print("🎬 2. Нажмите 'Сканировать с записью анимации'")
print("🔄 3. Возьмите Shovel и нажмите 'Заменить с воспроизведением анимации'")
