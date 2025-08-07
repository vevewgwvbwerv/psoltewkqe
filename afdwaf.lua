-- 🥚 EGG PET REPLACER - Замена временного питомца из яйца на анимированную копию
-- Основано на PetScaler_v2, но без масштабирования и с заменой позиции

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🥚 === EGG PET REPLACER - ЗАПУЩЕН ===")
print("=" .. string.rep("=", 50))

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    WAIT_TIMEOUT = 30, -- 30 секунд ожидания
    TARGET_PETS = {"BUNNY", "DOG", "GOLDEN LAB"} -- Целевые питомцы из яйца
}

-- Глобальные перемены
local isWaiting = false
local scannedPet = nil
local waitConnection = nil

-- Получаем позицию игрока
local function getPlayerPosition()
    local playerChar = player.Character
    if not playerChar then return nil end
    
    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    return hrp.Position
end

-- === ФУНКЦИИ ИЗ PETSCALER_V2 (БЕЗ МАСШТАБИРОВАНИЯ) ===

-- Функция проверки визуальных элементов питомца (из PetScaler_v2)
local function hasPetVisuals(model)
    local meshCount = 0
    local petMeshes = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") then
            meshCount = meshCount + 1
            local meshData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or ""
            }
            if meshData.meshId ~= "" then
                table.insert(petMeshes, meshData)
            end
        elseif obj:IsA("SpecialMesh") then
            meshCount = meshCount + 1
            local meshData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or "",
                textureId = obj.TextureId or ""
            }
            if meshData.meshId ~= "" or meshData.textureId ~= "" then
                table.insert(petMeshes, meshData)
            end
        end
    end
    
    return meshCount > 0, petMeshes
end

-- Функция получения всех BasePart из модели (из PetScaler_v2)
local function getAllParts(model)
    local parts = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- Функция получения всех Motor6D из модели (из PetScaler_v2)
local function getMotor6Ds(model)
    local motors = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    
    return motors
end

-- Функция создания карты Motor6D (из PetScaler_v2)
local function createMotorMap(motors)
    local map = {}
    
    for _, motor in ipairs(motors) do
        local key = motor.Name
        if motor.Part0 then
            key = key .. "_" .. motor.Part0.Name
        end
        if motor.Part1 then
            key = key .. "_" .. motor.Part1.Name
        end
        
        map[key] = motor
    end
    
    return map
end

-- Функция копирования состояния Motor6D (из PetScaler_v2)
local function copyMotorState(originalMotor, copyMotor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    copyMotor.Transform = originalMotor.Transform
    copyMotor.C0 = originalMotor.C0
    copyMotor.C1 = originalMotor.C1
    
    return true
end

-- Функция умного управления Anchored (из PetScaler_v2)
local function smartAnchoredManagement(copyParts)
    print("🧠 Умное управление Anchored...")
    
    -- Находим "корневую" часть
    local rootPart = nil
    local rootCandidates = {"RootPart", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    
    for _, candidate in ipairs(rootCandidates) do
        for _, part in ipairs(copyParts) do
            if part.Name == candidate then
                rootPart = part
                break
            end
        end
        if rootPart then break end
    end
    
    if not rootPart then
        rootPart = copyParts[1]
        print("  ⚠️ Корневая часть не найдена, использую:", rootPart.Name)
    else
        print("  ✅ Корневая часть:", rootPart.Name)
    end
    
    -- Применяем умный Anchored
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            part.Anchored = true -- Только корень заякорен
        else
            part.Anchored = false -- Остальные могут двигаться
        end
    end
    
    print("  ✅ Anchored настроен: корень заякорен, остальные свободны")
    return rootPart
end

-- === НОВЫЕ ФУНКЦИИ ДЛЯ ЗАМЕНЫ ПИТОМЦА ===

-- Функция поиска питомца рядом с игроком (адаптированная из PetScaler_v2)
local function scanNearbyPet()
    local playerPos = getPlayerPosition()
    if not playerPos then
        print("❌ Не удалось получить позицию игрока!")
        return nil
    end
    
    print("🔍 Сканирую питомцев рядом с игроком...")
    print("📍 Позиция игрока:", playerPos)
    print("🎯 Радиус поиска:", CONFIG.SEARCH_RADIUS)
    
    local foundPets = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= CONFIG.SEARCH_RADIUS then
                    local hasVisuals, meshes = hasPetVisuals(obj)
                    if hasVisuals then
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance,
                            meshes = meshes
                        })
                        print("  ✅ Найден питомец:", obj.Name, "расстояние:", math.floor(distance))
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены в радиусе", CONFIG.SEARCH_RADIUS)
        return nil
    end
    
    -- Берем ближайшего питомца
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец:", targetPet.model.Name, "расстояние:", math.floor(targetPet.distance))
    
    return targetPet.model
end

-- Функция создания копии без масштабирования, но с позиционированием
local function createPetCopy(originalModel, targetPosition)
    print("📋 Создаю копию питомца:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_EGG_COPY"
    copy.Parent = Workspace
    
    -- Устанавливаем точную позицию временного питомца
    if copy.PrimaryPart then
        copy:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        print("📍 Копия размещена через PrimaryPart в позиции:", targetPosition)
    elseif copy:FindFirstChild("RootPart") then
        copy.RootPart.Position = targetPosition
        print("📍 Копия размещена через RootPart в позиции:", targetPosition)
    else
        print("⚠️ Не удалось точно позиционировать копию")
    end
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- Функция запуска живого копирования Motor6D (из PetScaler_v2)
local function startLiveMotorCopying(original, copy)
    print("🔄 Запуск живого копирования Motor6D...")
    
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    print("  Motor6D - Оригинал:", #originalMotors, "Копия:", #copyMotors)
    
    if #originalMotors == 0 or #copyMotors == 0 then
        print("❌ Недостаточно Motor6D для копирования")
        return nil
    end
    
    local originalMap = createMotorMap(originalMotors)
    local copyMap = createMotorMap(copyMotors)
    
    local connection = nil
    local isRunning = true
    local frameCount = 0
    
    connection = RunService.Heartbeat:Connect(function()
        if not isRunning then
            connection:Disconnect()
            return
        end
        
        frameCount = frameCount + 1
        
        -- Проверяем существование моделей
        if not original.Parent or not copy.Parent then
            print("⚠️ Модель удалена, останавливаю копирование")
            isRunning = false
            return
        end
        
        -- Копируем состояния Motor6D
        for key, originalMotor in pairs(originalMap) do
            local copyMotor = copyMap[key]
            if copyMotor and originalMotor.Parent then
                copyMotorState(originalMotor, copyMotor)
            end
        end
        
        -- Статус каждые 3 секунды
        if frameCount % 180 == 0 then
            print("📊 Живое копирование активно (кадр " .. frameCount .. ")")
        end
    end)
    
    print("✅ Живое копирование Motor6D запущено!")
    return connection
end

-- Функция ожидания появления питомца в workspace.visuals
local function waitForVisualsPet()
    print("👁️ Ожидаю появления питомца в workspace.visuals...")
    print("🎯 Ищу питомцев:", table.concat(CONFIG.TARGET_PETS, ", "))
    
    local startTime = tick()
    local found = false
    
    return coroutine.create(function()
        while not found and (tick() - startTime) < CONFIG.WAIT_TIMEOUT do
            -- Проверяем workspace.visuals
            local visuals = Workspace:FindFirstChild("visuals")
            if visuals then
                for _, obj in pairs(visuals:GetChildren()) do
                    if obj:IsA("Model") then
                        for _, targetName in ipairs(CONFIG.TARGET_PETS) do
                            if obj.Name:upper() == targetName:upper() then
                                print("🎉 Найден целевой питомец в visuals:", obj.Name)
                                
                                -- Получаем позицию временного питомца
                                local tempPetPosition
                                local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
                                if success then
                                    tempPetPosition = modelCFrame.Position
                                elseif obj.PrimaryPart then
                                    tempPetPosition = obj.PrimaryPart.Position
                                elseif obj:FindFirstChild("RootPart") then
                                    tempPetPosition = obj.RootPart.Position
                                else
                                    print("❌ Не удалось получить позицию временного питомца")
                                    found = true
                                    return false
                                end
                                
                                print("📍 Позиция временного питомца:", tempPetPosition)
                                
                                -- Удаляем временного питомца
                                print("🗑️ Удаляю временного питомца из visuals")
                                obj:Destroy()
                                
                                found = true
                                return tempPetPosition
                            end
                        end
                    end
                end
            end
            
            wait(0.1) -- Проверяем каждые 0.1 секунды
        end
        
        if not found then
            print("⏰ Время ожидания истекло (", CONFIG.WAIT_TIMEOUT, "сек)")
        end
        
        return false
    end)
end

-- === ГЛАВНАЯ ФУНКЦИЯ ===

local function startEggReplacement()
    if isWaiting then
        print("⚠️ Уже ожидаю появления питомца из яйца!")
        return
    end
    
    print("🚀 === ЗАПУСК ЗАМЕНЫ ПИТОМЦА ИЗ ЯЙЦА ===")
    
    -- Шаг 1: Сканируем питомца рядом
    local targetPet = scanNearbyPet()
    if not targetPet then
        print("❌ Не найден питомец для копирования!")
        return
    end
    
    scannedPet = targetPet
    isWaiting = true
    
    print("✅ Питомец отсканирован:", scannedPet.Name)
    print("⏳ Ожидаю взрыва яйца и появления питомца в visuals...")
    
    -- Шаг 2: Ожидаем появления питомца в visuals
    local waitCoroutine = waitForVisualsPet()
    
    spawn(function()
        local result = coroutine.resume(waitCoroutine)
        local tempPetPosition = select(2, result)
        
        isWaiting = false
        
        if tempPetPosition then
            print("✅ Временный питомец найден и удален!")
            print("📍 Создаю копию в позиции:", tempPetPosition)
            
            -- Шаг 3: Создаем копию в позиции временного питомца
            local petCopy = createPetCopy(scannedPet, tempPetPosition)
            if petCopy then
                -- Шаг 4: Настраиваем Anchored
                local copyParts = getAllParts(petCopy)
                smartAnchoredManagement(copyParts)
                
                -- Шаг 5: Запускаем анимацию
                wait(0.5)
                local connection = startLiveMotorCopying(scannedPet, petCopy)
                
                if connection then
                    print("🎉 === УСПЕХ! ===")
                    print("✅ Питомец из яйца заменен анимированной копией!")
                    print("💡 Копия повторяет движения оригинала")
                else
                    print("⚠️ Копия создана, но анимация не запустилась")
                end
            end
        else
            print("❌ Не удалось найти питомца в visuals или время истекло")
        end
        
        scannedPet = nil
    end)
end

-- === СОЗДАНИЕ GUI ===

local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("EggReplacerGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EggReplacerGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 100)
    frame.Position = UDim2.new(0, 50, 0, 250) -- Ниже других GUI
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 165, 0) -- Оранжевая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ReplaceButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 15)
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    button.BorderSizePixel = 0
    button.Text = "🥚 Заменить питомца из яйца"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0, 260, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 65)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Готов к работе"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        if isWaiting then
            statusLabel.Text = "Уже ожидаю питомца из яйца..."
            return
        end
        
        button.Text = "⏳ Сканирую и ожидаю..."
        button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        statusLabel.Text = "Ожидаю появления питомца в visuals..."
        
        spawn(function()
            startEggReplacement()
            
            wait(2)
            if not isWaiting then
                button.Text = "🥚 Заменить питомца из яйца"
                button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                statusLabel.Text = "Готов к работе"
            end
        end)
    end)
    
    -- Обновление статуса в реальном времени
    spawn(function()
        while true do
            if isWaiting then
                statusLabel.Text = "⏳ Ожидаю питомца в visuals..."
            elseif not isWaiting and statusLabel.Text:find("Ожидаю") then
                statusLabel.Text = "Готов к работе"
            end
            wait(1)
        end
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 165, 0) then
            button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 140, 0) then
            button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    print("🖥️ EggReplacer GUI создан!")
end

-- === ЗАПУСК ===

createGUI()
print("=" .. string.rep("=", 50))
print("💡 EGG PET REPLACER - ГОТОВ К РАБОТЕ:")
print("   1. Нажмите кнопку")
print("   2. Откройте яйцо")
print("   3. Временный питомец будет заменен анимированной копией!")
print("🎯 Целевые питомцы: " .. table.concat(CONFIG.TARGET_PETS, ", "))
print("=" .. string.rep("=", 50))
