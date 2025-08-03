-- 🔥 PET SCALER v2.9 IDLE - Масштабирование с ТОЛЬКО IDLE анимацией
-- Объединяет оригинальный PetScaler + SmartMotorCopier
-- Создает масштабированную копию И копирует ТОЛЬКО idle анимацию

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v2.9 IDLE - ТОЛЬКО IDLE АНИМАЦИЯ ===")
print("=" .. string.rep("=", 60))

-- Конфигурация (как в оригинальном PetScaler)
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

-- === ФУНКЦИИ ИЗ ОРИГИНАЛЬНОГО PETSCALER ===

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

-- Функция глубокого копирования модели (ОРИГИНАЛЬНАЯ ВЕРСИЯ)
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- Позиционирование копии (оригинальная логика)
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
            print("📍 Копия размещена на уровне оригинала в стоячем положении")
        end
    elseif copy:FindFirstChild("RootPart") and originalModel:FindFirstChild("RootPart") then
        local originalPos = originalModel.RootPart.Position
        local offset = Vector3.new(15, 0, 0)
        copy.RootPart.Position = originalPos + offset
        print("📍 Копия размещена через RootPart")
    else
        print("⚠️ Не удалось точно позиционировать копию")
    end
    
    -- ВАЖНО: НЕ устанавливаем Anchored здесь - это сделает SmartAnchoredManagement
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- === ФУНКЦИИ ИЗ SMARTMOTORCOPIER ===

-- Функция получения всех BasePart из модели (ОРИГИНАЛЬНАЯ ЛОГИКА PETSCALER)
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

-- Функция умного управления Anchored (из SmartMotorCopier)
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

-- Функция копирования состояния Motor6D с масштабированием
local function copyMotorState(originalMotor, copyMotor, scaleFactor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    -- ИСПРАВЛЕНО: Масштабируем позиционные компоненты Motor6D
    local originalC0 = originalMotor.C0
    local originalC1 = originalMotor.C1
    
    -- Масштабируем позиционные компоненты (Position), но НЕ вращательные (Rotation)
    local scaledC0 = CFrame.new(originalC0.Position * scaleFactor) * (originalC0 - originalC0.Position)
    local scaledC1 = CFrame.new(originalC1.Position * scaleFactor) * (originalC1 - originalC1.Position)
    
    copyMotor.C0 = scaledC0
    copyMotor.C1 = scaledC1
    
    return true
end

-- === ФУНКЦИИ МАСШТАБИРОВАНИЯ (ОРИГИНАЛЬНЫЕ) ===

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
    
    -- Масштабирование через CFrame (ОРИГИНАЛЬНАЯ ЛОГИКА)
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

-- === ФУНКЦИЯ ЗАПИСИ И ЗАЦИКЛИВАНИЯ IDLE АНИМАЦИИ ===

local function startIdleRecordingAndLooping(original, copy)
    print("🔄 Запуск записи и зацикливания IDLE анимации...")
    
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    print("  Motor6D - Оригинал:", #originalMotors, "Копия:", #copyMotors)
    
    if #originalMotors == 0 or #copyMotors == 0 then
        print("❌ Недостаточно Motor6D для копирования")
        return nil
    end
    
    local originalMap = createMotorMap(originalMotors)
    local copyMap = createMotorMap(copyMotors)
    
    -- Находим rootPart оригинала для проверки velocity
    local originalRootPart = original:FindFirstChild("HumanoidRootPart") or original:FindFirstChild("Torso")
    if not originalRootPart then
        print("❌ Не найден rootPart у оригинала!")
        return nil
    end
    
    -- Переменные для записи idle анимации
    local idleTimeline = {}
    local isRecording = false
    local isLooping = false
    local recordingFrames = 0
    local maxRecordingFrames = 90 -- 3 секунды при 30 FPS
    local loopFrame = 0
    
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
        
        local velocity = originalRootPart.AssemblyLinearVelocity.Magnitude
        local isIdle = velocity < 0.5
        
        if isIdle and not isRecording and not isLooping then
            -- Начинаем запись idle анимации
            print("🎬 Начинаю запись idle анимации...")
            isRecording = true
            recordingFrames = 0
            idleTimeline = {}
            
        elseif isRecording then
            if isIdle and recordingFrames < maxRecordingFrames then
                -- Записываем кадр idle анимации
                recordingFrames = recordingFrames + 1
                local frame = {}
                
                for key, originalMotor in pairs(originalMap) do
                    if originalMotor.Parent then
                        frame[key] = {
                            C0 = originalMotor.C0,
                            C1 = originalMotor.C1
                        }
                    end
                end
                
                table.insert(idleTimeline, frame)
                
                if recordingFrames >= maxRecordingFrames then
                    print("✅ Запись idle анимации завершена! Записано кадров: " .. #idleTimeline)
                    isRecording = false
                    isLooping = true
                    loopFrame = 0
                end
                
            elseif not isIdle then
                -- Питомец начал двигаться во время записи - прерываем запись
                print("⚠️ Запись прервана - питомец начал двигаться")
                isRecording = false
                idleTimeline = {}
            end
            
        elseif isLooping and #idleTimeline > 0 then
            -- Зацикливаем записанную idle анимацию
            loopFrame = (loopFrame % #idleTimeline) + 1
            local frame = idleTimeline[loopFrame]
            
            for key, motorData in pairs(frame) do
                local copyMotor = copyMap[key]
                if copyMotor and copyMotor.Parent then
                    -- Масштабируем позиционные компоненты
                    local originalC0 = motorData.C0
                    local originalC1 = motorData.C1
                    
                    local scaledC0 = CFrame.new(originalC0.Position * CONFIG.SCALE_FACTOR) * (originalC0 - originalC0.Position)
                    local scaledC1 = CFrame.new(originalC1.Position * CONFIG.SCALE_FACTOR) * (originalC1 - originalC1.Position)
                    
                    copyMotor.C0 = scaledC0
                    copyMotor.C1 = scaledC1
                end
            end
        end
        
        -- Статус каждые 3 секунды
        if frameCount % 180 == 0 then
            if isRecording then
                print("📊 Запись idle: кадр " .. recordingFrames .. "/" .. maxRecordingFrames)
            elseif isLooping then
                print("📊 Зацикливание idle: кадр " .. loopFrame .. "/" .. #idleTimeline)
            else
                print("📊 Ожидание idle для записи...")
            end
        end
    end)
    
    print("✅ Система записи и зацикливания idle анимации запущена!")
    print("💡 Ожидаю когда питомец встанет для записи idle анимации...")
    
    return connection
end

-- Функция поиска и масштабирования (из оригинального PetScaler)
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

-- Главная функция v2.0
local function main()
    print("🚀 PetScaler v2.9 IDLE запущен!")
    
    -- Шаг 1: Найти питомца
    local petModel = findAndScalePet()
    if not petModel then
        return
    end
    
    -- Шаг 2: Создать копию (оригинальная логика)
    local petCopy = deepCopyModel(petModel)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- Шаг 3: СНАЧАЛА масштабируем с закрепленными частями (как в оригинале)
    print("\n📏 === МАСШТАБИРОВАНИЕ ===")
    -- Убеждаемся что все части закреплены для стабильного масштабирования
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
    
    -- Шаг 4: ПОСЛЕ масштабирования настраиваем Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ДЛЯ АНИМАЦИИ ===")
    wait(CONFIG.TWEEN_TIME + 1) -- Ждем завершения масштабирования
    
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 5: Запуск записи и зацикливания IDLE анимации
    print("\n🎭 === ЗАПУСК ЗАПИСИ И ЗАЦИКЛИВАНИЯ IDLE АНИМАЦИИ ===")
    
    local connection = startIdleRecordingAndLooping(petModel, petCopy)
    
    if connection then
        print("🎉 === УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ IDLE-ONLY анимация запущена")
        print("💡 Копия будет анимироваться ТОЛЬКО когда оригинал стоит!")
        print("🚫 Когда оригинал движется, копия остается в idle позе!")
    else
        print("⚠️ Масштабирование успешно, но IDLE-ONLY анимация не запустилась")
        print("💡 Возможно проблема с Motor6D соединениями")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerV29IdleGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerV29IdleGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 150) -- Под оригинальным PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 165, 0) -- Оранжевая рамка для отличия
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    button.BorderSizePixel = 0
    button.Text = "🔥 PetScaler v2.9 IDLE-ONLY"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Создаю IDLE-ONLY..."
        button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🔥 PetScaler v2.9 IDLE-ONLY"
            button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        end)
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
    
    print("🖥️ PetScaler v2.9 IDLE GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 60))
print("💡 PETSCALER v2.9 IDLE-ONLY:")
print("   1. Создает масштабированную копию")
print("   2. Настраивает правильные Anchored состояния")
print("   3. Копирует Motor6D ТОЛЬКО когда оригинал стоит (idle)")
print("   4. Когда оригинал движется, копия остается в idle позе")
print("🎯 Нажмите оранжевую кнопку для запуска!")
print("=" .. string.rep("=", 60))
