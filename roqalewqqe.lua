-- 📹 PET SCALER v2.7 CLEAN - ТОЛЬКО IDLE Анимация
-- Записывает IDLE анимацию когда питомец стоит
-- Создает масштабированную копию с бесконечной IDLE анимацией

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("📹 === PET SCALER v2.7 CLEAN - IDLE АНИМАЦИЯ ===")
print("=" .. string.rep("=", 60))

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 3.0,
    TWEEN_TIME = 3.0,
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out
}

-- Получаем позицию игрока
local playerChar = player.Character
if not playerChar then
    print("❌ Персонаж игрока не найден!")
    return
end

local hrp = playerChar:FindFirstChild("HumanoidRootPart")
if not hrp then
    print("❌ HumanoidRootPart не найден!")
    return
end

local playerPos = hrp.Position
print("📍 Позиция игрока:", playerPos)
print("🎯 Радиус поиска:", CONFIG.SEARCH_RADIUS)
print("📏 Коэффициент увеличения:", CONFIG.SCALE_FACTOR .. "x")
print("⏱️ Время анимации:", CONFIG.TWEEN_TIME .. " сек")
print()

-- === ОСНОВНЫЕ ФУНКЦИИ ===

-- Функция проверки визуальных элементов питомца
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

-- Функция глубокого копирования модели
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- Позиционирование копии
    if copy.PrimaryPart and originalModel.PrimaryPart then
        local originalCFrame = originalModel.PrimaryPart.CFrame
        local offset = Vector3.new(15, 0, 0)
        
        local targetPosition = originalCFrame.Position + offset
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {copy, originalModel}
        
        local rayOrigin = Vector3.new(targetPosition.X, targetPosition.Y + 100, targetPosition.Z)
        local rayDirection = Vector3.new(0, -200, 0)
        
        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if raycastResult then
            local groundY = raycastResult.Position.Y
            local finalPosition = Vector3.new(targetPosition.X, groundY, targetPosition.Z)
            
            local newCFrame = CFrame.new(finalPosition, finalPosition + originalCFrame.LookVector)
            copy:SetPrimaryPartCFrame(newCFrame)
            print("📍 Копия размещена на земле рядом с оригиналом")
        else
            copy:SetPrimaryPartCFrame(originalCFrame + offset)
            print("📍 Копия размещена на уровне оригинала")
        end
    elseif copy:FindFirstChild("RootPart") and originalModel:FindFirstChild("RootPart") then
        local originalPos = originalModel.RootPart.Position
        local offset = Vector3.new(15, 0, 0)
        copy.RootPart.Position = originalPos + offset
        print("📍 Копия размещена через RootPart")
    else
        print("⚠️ Не удалось точно позиционировать копию")
    end
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- Функция получения всех BasePart из модели
local function getAllParts(model)
    local parts = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- Получаем все Motor6D из модели
local function getMotor6Ds(model)
    local motors = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    return motors
end

-- Создаем карту Motor6D по именам
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

-- Функция умного управления Anchored
local function smartAnchoredManagement(copyParts)
    print("🧠 Умное управление Anchored...")
    
    -- Находим "корневую" часть
    local rootPart = nil
    for _, part in ipairs(copyParts) do
        local partName = part.Name:lower()
        if partName:find("torso") or partName:find("humanoidrootpart") or partName:find("rootpart") then
            rootPart = part
            break
        end
    end
    
    if not rootPart then
        rootPart = copyParts[1]
        print("  ⚠️ Корневая часть не найдена, использую первую:", rootPart.Name)
    else
        print("  ✅ Корневая часть найдена:", rootPart.Name)
    end
    
    -- Устанавливаем Anchored
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            part.Anchored = true
            print("  🔒 Закреплена корневая часть:", part.Name)
        else
            part.Anchored = false
        end
    end
    
    print("  ✅ Anchored настроен: корень заякорен, остальные свободны")
    return rootPart
end

-- Функция плавного масштабирования модели
local function scaleModelSmoothly(model, scaleFactor, tweenTime)
    print("🔥 Начинаю плавное масштабирование модели:", model.Name)
    
    local parts = getAllParts(model)
    
    if #parts == 0 then
        print("❌ Части для масштабирования не найдены!")
        return false
    end
    
    print("📊 Найдено частей для масштабирования:", #parts)
    
    -- Сохраняем оригинальные данные
    local originalData = {}
    for _, part in ipairs(parts) do
        originalData[part] = {
            size = part.Size,
            cframe = part.CFrame
        }
    end
    
    -- Создаем TweenInfo
    local tweenInfo = TweenInfo.new(
        tweenTime,
        CONFIG.EASING_STYLE,
        CONFIG.EASING_DIRECTION,
        0, -- Повторений
        false, -- Обратная анимация
        0 -- Задержка
    )
    
    -- Масштабирование через CFrame
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        -- Вычисляем новый размер
        local newSize = originalSize * scaleFactor
        
        -- Вычисляем новую позицию (масштабируем относительно центра модели)
        local newCFrame = originalCFrame
        
        local tween = TweenService:Create(part, tweenInfo, {
            Size = newSize,
            CFrame = newCFrame
        })
        
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("🎉 Все " .. #parts .. " частей успешно увеличены в " .. scaleFactor .. "x")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    print("🚀 Запущено " .. #tweens .. " твинов для плавного масштабирования")
    return true
end

-- Функция поиска и масштабирования
local function findAndScalePet()
    print("🔍 Поиск UUID моделей питомцев...")
    
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
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        return nil
    end
    
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец:", targetPet.model.Name)
    
    return targetPet.model
end

-- Главная функция
local function main()
    print("🚀 PetScaler v2.7 CLEAN запущен!")
    
    -- Шаг 1: Найти питомца
    local petModel = findAndScalePet()
    if not petModel then
        return
    end
    
    -- Шаг 2: Создать копию
    local petCopy = deepCopyModel(petModel)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- Шаг 3: Масштабирование с закрепленными частями
    print("\n📏 === МАСШТАБИРОВАНИЕ ===")
    for _, part in pairs(petCopy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    wait(0.5)
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование не удалось!")
        return
    end
    
    -- Шаг 4: Настройка Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ДЛЯ АНИМАЦИИ ===")
    wait(CONFIG.TWEEN_TIME + 1)
    
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 5: ЗАПИСЬ IDLE АНИМАЦИИ (ТОЛЬКО КОГДА ПИТОМЕЦ СТОИТ)
    print("\n📹 === ЗАПИСЬ IDLE АНИМАЦИИ ===")
    
    local originalRootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    if not originalRootPart then
        print("❌ Нет rootPart у питомца!")
        return
    end
    
    print("⏳ Жду пока питомец не встанет...")
    while originalRootPart.AssemblyLinearVelocity.Magnitude >= 0.5 do
        wait(0.1)
    end
    
    print("✅ Питомец стоит! Начинаю запись idle анимации...")
    
    -- Записываем Motor6D позы пока питомец стоит
    local idleFrames = {}
    local originalMotors = getMotor6Ds(petModel)
    local frameCount = 0
    local maxFrames = 90 -- 3 секунды при 30 FPS
    
    while originalRootPart.AssemblyLinearVelocity.Magnitude < 0.5 and frameCount < maxFrames do
        local frameData = {}
        
        -- Записываем позы всех Motor6D
        for _, motor in ipairs(originalMotors) do
            if motor and motor.Parent then
                frameData[motor.Name] = {
                    C0 = motor.C0,
                    C1 = motor.C1
                }
            end
        end
        
        table.insert(idleFrames, frameData)
        frameCount = frameCount + 1
        wait(1/30) -- 30 FPS
    end
    
    if frameCount == 0 then
        print("❌ Не удалось записать idle анимацию!")
        return
    end
    
    print("✅ Записано " .. frameCount .. " кадров idle анимации!")
    
    -- Шаг 6: ЗАЦИКЛИВАЕМ IDLE НА КОПИИ
    print("\n🎭 === ЗАЦИКЛИВАНИЕ IDLE НА КОПИИ ===")
    
    local copyMotors = getMotor6Ds(petCopy)
    local copyMotorMap = createMotorMap(copyMotors)
    local currentFrame = 1
    
    local idleConnection = RunService.Heartbeat:Connect(function()
        if not petCopy.Parent then return end
        
        local frameData = idleFrames[currentFrame]
        if not frameData then return end
        
        -- Применяем idle позы к копии
        for motorName, poseData in pairs(frameData) do
            for key, copyMotor in pairs(copyMotorMap) do
                if key:find(motorName) and copyMotor.Parent then
                    copyMotor.C0 = poseData.C0
                    copyMotor.C1 = poseData.C1
                    break
                end
            end
        end
        
        -- Переходим к следующему кадру (зацикливаем)
        currentFrame = currentFrame + 1
        if currentFrame > #idleFrames then
            currentFrame = 1
        end
    end)
    
    print("🎉 === УСПЕХ! ===")
    print("✅ Масштабированная копия создана")
    print("✅ Idle анимация записана и зациклена")
    print("💡 Копия будет бесконечно проигрывать ТОЛЬКО IDLE анимацию!")
    print("🚫 Копия НИКОГДА не будет ходить - только стоять в анимации!")
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerV27GUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerV27GUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    button.BorderSizePixel = 0
    button.Text = "📹 PetScaler v2.7 CLEAN - ТОЛЬКО IDLE"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Записываю IDLE..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "📹 PetScaler v2.7 CLEAN - ТОЛЬКО IDLE"
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
            button.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 220, 0) then
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
    
    print("🎮 PetScaler v2.7 CLEAN GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 60))
print("💡 PETSCALER v2.7 CLEAN - ТОЛЬКО IDLE АНИМАЦИЯ:")
print("   1. Создает масштабированную копию")
print("   2. Записывает IDLE анимацию когда питомец стоит")
print("   3. Зацикливает ТОЛЬКО IDLE анимацию на копии бесконечно")
print("   4. Копия НИКОГДА не будет ходить!")
print("🎯 Нажмите зеленую кнопку для запуска!")
print("=" .. string.rep("=", 60))
