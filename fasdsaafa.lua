-- 🔥 PET SCALER v2.9 RECORD IDLE - ЗАПИСАТЬ idle и ЗАЦИКЛИТЬ через живое копирование
-- 1. ЗАПИСАТЬ idle кадры когда питомец стоит
-- 2. ОСТАНОВИТЬ запись когда питомец движется
-- 3. ЗАЦИКЛИТЬ записанные кадры через ЖИВОЕ КОПИРОВАНИЕ (не timeline replay!)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v2.9 RECORD IDLE - ЗАПИСАТЬ И ЗАЦИКЛИТЬ IDLE ===")
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

-- Функция копирования состояния Motor6D с масштабированием
local function copyMotorState(originalMotor, copyMotor, scaleFactor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    local originalC0 = originalMotor.C0
    local originalC1 = originalMotor.C1
    
    -- Масштабируем позиционные компоненты
    local scaledC0 = CFrame.new(originalC0.Position * scaleFactor) * (originalC0 - originalC0.Position)
    local scaledC1 = CFrame.new(originalC1.Position * scaleFactor) * (originalC1 - originalC1.Position)
    
    copyMotor.C0 = scaledC0
    copyMotor.C1 = scaledC1
    
    return true
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
        0,
        false,
        0
    )
    
    -- Масштабирование через CFrame
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        local newSize = originalSize * scaleFactor
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

-- === КЛЮЧЕВАЯ ФУНКЦИЯ: ЗАПИСАТЬ IDLE И ЗАЦИКЛИТЬ ЧЕРЕЗ ЖИВОЕ КОПИРОВАНИЕ ===

local function startIdleRecordingAndLiveLooping(original, copy)
    print("🔄 Запуск записи idle и живого зацикливания...")
    
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
    
    -- ПЕРЕМЕННЫЕ ДЛЯ ЗАПИСИ IDLE
    local idleFrames = {}  -- Записанные idle кадры
    local isRecording = false
    local isLooping = false
    local recordingFrameCount = 0
    local maxRecordingFrames = 90  -- 3 секунды при 30 FPS
    local loopFrameIndex = 1
    
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
            -- НАЧИНАЕМ ЗАПИСЬ IDLE
            print("🎬 Начинаю запись idle анимации...")
            isRecording = true
            recordingFrameCount = 0
            idleFrames = {}
            
        elseif isRecording then
            if isIdle and recordingFrameCount < maxRecordingFrames then
                -- ЗАПИСЫВАЕМ КАДР IDLE
                recordingFrameCount = recordingFrameCount + 1
                local frame = {}
                
                -- ЗАПИСЫВАЕМ ТЕКУЩИЕ ПОЗИЦИИ Motor6D
                for key, originalMotor in pairs(originalMap) do
                    if originalMotor.Parent then
                        frame[key] = {
                            C0 = originalMotor.C0,
                            C1 = originalMotor.C1
                        }
                    end
                end
                
                table.insert(idleFrames, frame)
                
                if recordingFrameCount >= maxRecordingFrames then
                    print("✅ Запись idle завершена! Записано кадров: " .. #idleFrames)
                    print("🔄 Начинаю живое зацикливание записанной idle анимации...")
                    isRecording = false
                    isLooping = true
                    loopFrameIndex = 1
                end
                
            elseif not isIdle then
                -- Питомец начал двигаться - прерываем запись
                print("⚠️ Запись прервана - питомец начал двигаться")
                isRecording = false
                idleFrames = {}
            end
            
        elseif isLooping and #idleFrames > 0 then
            -- ЖИВОЕ ЗАЦИКЛИВАНИЕ ЗАПИСАННЫХ IDLE КАДРОВ
            local currentFrame = idleFrames[loopFrameIndex]
            
            -- ПРИМЕНЯЕМ КАДР К КОПИИ ЧЕРЕЗ ЖИВОЕ КОПИРОВАНИЕ (КАК В v2.9!)
            for key, motorData in pairs(currentFrame) do
                local copyMotor = copyMap[key]
                if copyMotor and copyMotor.Parent then
                    -- Масштабируем и применяем
                    local originalC0 = motorData.C0
                    local originalC1 = motorData.C1
                    
                    local scaledC0 = CFrame.new(originalC0.Position * CONFIG.SCALE_FACTOR) * (originalC0 - originalC0.Position)
                    local scaledC1 = CFrame.new(originalC1.Position * CONFIG.SCALE_FACTOR) * (originalC1 - originalC1.Position)
                    
                    copyMotor.C0 = scaledC0
                    copyMotor.C1 = scaledC1
                end
            end
            
            -- Переходим к следующему кадру
            loopFrameIndex = loopFrameIndex + 1
            if loopFrameIndex > #idleFrames then
                loopFrameIndex = 1  -- Зацикливаем
            end
        end
        
        -- Статус каждые 3 секунды
        if frameCount % 180 == 0 then
            if isRecording then
                print("📊 Запись idle: кадр " .. recordingFrameCount .. "/" .. maxRecordingFrames)
            elseif isLooping then
                print("📊 Живое зацикливание idle: кадр " .. loopFrameIndex .. "/" .. #idleFrames)
            else
                print("📊 Ожидание idle для записи...")
            end
        end
    end)
    
    print("✅ Система записи idle и живого зацикливания запущена!")
    print("💡 Ожидаю когда питомец встанет для записи idle анимации...")
    
    return connection
end

-- Функция поиска питомца
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
    print("🚀 PetScaler v2.9 RECORD IDLE запущен!")
    
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
    
    -- Шаг 3: Масштабирование
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
    
    -- Шаг 5: Запуск записи idle и живого зацикливания
    print("\n🎭 === ЗАПУСК ЗАПИСИ IDLE И ЖИВОГО ЗАЦИКЛИВАНИЯ ===")
    
    local connection = startIdleRecordingAndLiveLooping(petModel, petCopy)
    
    if connection then
        print("🎉 === УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Система записи idle и живого зацикливания запущена")
        print("💡 Копия будет записывать idle анимацию и зацикливать её!")
    else
        print("⚠️ Масштабирование успешно, но система записи не запустилась")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerRecordIdleGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerRecordIdleGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 350)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Голубая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 280, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    button.BorderSizePixel = 0
    button.Text = "🔥 PetScaler RECORD IDLE"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Записываю IDLE..."
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🔥 PetScaler RECORD IDLE"
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 255, 255) then
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 200, 200) then
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        end
    end)
    
    print("🖥️ PetScaler RECORD IDLE GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 60))
print("💡 PETSCALER RECORD IDLE:")
print("   1. ЗАПИСЫВАЕТ idle анимацию когда питомец стоит")
print("   2. ОСТАНАВЛИВАЕТ запись когда питомец движется")
print("   3. ЗАЦИКЛИВАЕТ записанную idle через ЖИВОЕ КОПИРОВАНИЕ")
print("🎯 Нажмите ГОЛУБУЮ кнопку для запуска!")
print("=" .. string.rep("=", 60))
