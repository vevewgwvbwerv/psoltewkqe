-- 🔥 PET SCALER v2.0 - Масштабирование с анимацией
-- Объединяет оригинальный PetScaler + SmartMotorCopier
-- Создает масштабированную копию И сразу включает анимацию

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v2.0 - С АНИМАЦИЕЙ ===")
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

-- Функция исправления Attachment связей после клонирования
local function fixAttachmentParenting(model)
    print("🔧 Исправляю Attachment связи...")
    
    local attachments = {}
    local fixedCount = 0
    
    -- Собираем все Attachments
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Attachment") then
            table.insert(attachments, obj)
        end
    end
    
    -- Исправляем родительские связи
    for _, attachment in pairs(attachments) do
        if attachment.Parent and not attachment.Parent:IsA("BasePart") then
            -- Ищем ближайший BasePart в иерархии
            local parent = attachment.Parent
            while parent and not parent:IsA("BasePart") do
                parent = parent.Parent
            end
            
            if parent and parent:IsA("BasePart") then
                attachment.Parent = parent
                fixedCount = fixedCount + 1
            else
                -- Если не нашли BasePart, удаляем проблемный Attachment
                print("⚠️ Удаляю проблемный Attachment:", attachment.Name)
                attachment:Destroy()
            end
        end
    end
    
    print("✅ Исправлено Attachment связей:", fixedCount)
end

-- Функция глубокого копирования модели (ИСПРАВЛЕННАЯ ВЕРСИЯ)
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- ИСПРАВЛЯЕМ ATTACHMENT СВЯЗИ СРАЗУ ПОСЛЕ КЛОНИРОВАНИЯ
    fixAttachmentParenting(copy)
    
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
            -- ИСПРАВЛЕНО: Сохраняем правильную ориентацию (стоячее положение)
            local upVector = Vector3.new(0, 1, 0) -- Вверх
            local lookVector = originalCFrame.LookVector
            -- Обнуляем Y-компонент чтобы питомец не наклонялся
            lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            local newCFrame = CFrame.lookAt(finalPosition, finalPosition + lookVector, upVector)
            copy:SetPrimaryPartCFrame(newCFrame)
            print("📍 Копия размещена на земле в стоячем положении")
        else
            -- ИСПРАВЛЕНО: Правильная ориентация без земли
            local newPosition = originalCFrame.Position + offset
            local upVector = Vector3.new(0, 1, 0)
            local lookVector = Vector3.new(originalCFrame.LookVector.X, 0, originalCFrame.LookVector.Z).Unit
            local newCFrame = CFrame.lookAt(newPosition, newPosition + lookVector, upVector)
            copy:SetPrimaryPartCFrame(newCFrame)
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

-- Функция получения всех Motor6D из модели
local function getMotor6Ds(model)
    local motors = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    
    return motors
end

-- Функция создания карты Motor6D
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

-- Функция копирования состояния Motor6D с масштабированием
local function copyMotorState(originalMotor, copyMotor, scaleFactor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    -- ИСПРАВЛЕНО: Масштабируем позиционные компоненты Motor6D
    -- Transform содержит текущее смещение - масштабируем его
    local originalTransform = originalMotor.Transform
    local scaledTransform = CFrame.new(originalTransform.Position * scaleFactor) * (originalTransform - originalTransform.Position)
    copyMotor.Transform = scaledTransform
    
    -- C0 и C1 - базовые смещения соединения - тоже масштабируем
    local originalC0 = originalMotor.C0
    local scaledC0 = CFrame.new(originalC0.Position * scaleFactor) * (originalC0 - originalC0.Position)
    copyMotor.C0 = scaledC0
    
    local originalC1 = originalMotor.C1
    local scaledC1 = CFrame.new(originalC1.Position * scaleFactor) * (originalC1 - originalC1.Position)
    copyMotor.C1 = scaledC1
    
    return true
end

-- === ФУНКЦИИ МАСШТАБИРОВАНИЯ (ОРИГИНАЛЬНЫЕ) ===

-- Функция плавного масштабирования модели
local function scaleModelSmoothly(model, scaleFactor, tweenTime)
    print("🔥 Начинаю плавное масштабирование модели:", model.Name)
    
    local parts = getAllParts(model)
    print("🧩 Найдено частей для масштабирования:", #parts)
    
    if #parts == 0 then
        print("❌ Нет частей для масштабирования!")
        return false
    end
    
    -- Определяем центр масштабирования
    local centerCFrame
    if model.PrimaryPart then
        centerCFrame = model.PrimaryPart.CFrame
        print("🎯 Центр масштабирования: PrimaryPart (" .. model.PrimaryPart.Name .. ")")
    else
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            centerCFrame = modelCFrame
            print("🎯 Центр масштабирования: Центр модели")
        else
            print("❌ Не удалось определить центр масштабирования!")
            return false
        end
    end
    
    -- Сохраняем исходные данные всех частей
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
        
        -- Вычисляем новый CFrame относительно центра
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local scaledRelativeCFrame = CFrame.new(relativeCFrame.Position * scaleFactor) * (relativeCFrame - relativeCFrame.Position)
        local newCFrame = centerCFrame * scaledRelativeCFrame
        
        -- Создаем твин для размера и CFrame
        local tween = TweenService:Create(part, tweenInfo, {
            Size = newSize,
            CFrame = newCFrame
        })
        
        -- Обработчик завершения твина
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ Масштабирование завершено!")
                print("🎉 Все " .. #parts .. " частей успешно увеличены в " .. scaleFactor .. "x")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    print("🚀 Запущено " .. #tweens .. " твинов для плавного масштабирования")
    return true
end

-- === АГРЕССИВНОЕ ФОРСИРОВАНИЕ IDLE АНИМАЦИИ ===
-- Интегрированная логика из Motor6DIdleForcer.lua

-- Функция записи чистых idle поз
local function recordPureIdlePoses(petModel)
    print("\n🎬 === ЗАПИСЬ ЧИСТЫХ IDLE ПОЗ ===")
    
    local motor6Ds = {}
    local idlePoses = {}
    
    -- Находим все Motor6D
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6Ds, obj)
        end
    end
    
    print("🔧 Найдено Motor6D:", #motor6Ds)
    
    if #motor6Ds == 0 then
        print("❌ Motor6D не найдены!")
        return nil
    end
    
    -- Находим RootPart и якорим для записи
    local rootPart = petModel:FindFirstChild("RootPart") or petModel:FindFirstChild("HumanoidRootPart")
    local originalPosition = nil
    
    if rootPart then
        originalPosition = rootPart.Position
        rootPart.Anchored = true
        print("⚓ RootPart заякорен для записи")
    end
    
    -- АГРЕССИВНО уничтожаем ВСЕ walking анимации
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                local name = track.Animation.Name:lower()
                if name:find("walk") or name:find("run") or name:find("move") then
                    track:Stop()
                    print("💀 Остановлена walking анимация:", track.Animation.Name)
                end
            end
        end
    end
    
    -- ОЖИДАНИЕ ПОЛНОГО ПЕРЕХОДА К IDLE
    print("⏳ Ожидаю 3 секунды для полного перехода к idle...")
    wait(3) -- Даем время питомцу полностью перейти в idle состояние
    
    -- Настройки записи (УВЕЛИЧЕНО ДЛЯ ПОЛНОЙ IDLE АНИМАЦИИ)
    local recordingTime = 8 -- 8 секунд записи для полного idle цикла
    local frameRate = 60
    local frameInterval = 1 / frameRate
    local totalFrames = recordingTime * frameRate
    
    print("📹 Записываю ПОЛНУЮ idle анимацию:", recordingTime, "секунд (", totalFrames, "кадров)")
    
    local currentFrame = 0
    local startTime = tick()
    
    local recordConnection
    recordConnection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        
        if elapsed >= frameInterval * currentFrame then
            currentFrame = currentFrame + 1
            
            -- Записываем текущие позы Motor6D
            local framePoses = {}
            for _, motor in pairs(motor6Ds) do
                framePoses[motor.Name] = {
                    C0 = motor.C0,
                    C1 = motor.C1,
                    Transform = motor.Transform
                }
            end
            
            table.insert(idlePoses, framePoses)
            
            if currentFrame >= totalFrames then
                recordConnection:Disconnect()
                print("📹 Запись завершена! Записано кадров:", #idlePoses)
            end
        end
    end)
    
    -- Ждем завершения записи
    while #idlePoses < totalFrames and recordConnection.Connected do
        wait(0.1)
    end
    
    return idlePoses, motor6Ds, originalPosition
end

-- Функция агрессивного форсирования только idle
local function forceOnlyIdleAnimation(idlePoses, motor6Ds, petModel, originalPosition)
    print("\n🔥 === АГРЕССИВНОЕ ФОРСИРОВАНИЕ ТОЛЬКО IDLE ===")
    
    if not idlePoses or #idlePoses == 0 then
        print("❌ Нет записанных idle поз!")
        return nil
    end
    
    local humanoid = petModel:FindFirstChild("Humanoid")
    local rootPart = petModel:FindFirstChild("RootPart") or petModel:FindFirstChild("HumanoidRootPart")
    
    local currentFrame = 1
    local frameRate = 60
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    local forceConnection
    forceConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- АГРЕССИВНО блокируем движение
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.PlatformStand = true
        end
        
        -- АГРЕССИВНО телепортируем обратно при движении
        if rootPart and originalPosition then
            if rootPart.Position ~= originalPosition then
                rootPart.Position = originalPosition
                print("🔄 Питомец телепортирован обратно")
            end
        end
        
        -- АГРЕССИВНО уничтожаем walking анимации каждый кадр
        for _, obj in pairs(petModel:GetDescendants()) do
            if obj:IsA("Animator") then
                local tracks = obj:GetPlayingAnimationTracks()
                for _, track in pairs(tracks) do
                    local name = track.Animation.Name:lower()
                    if name:find("walk") or name:find("run") or name:find("move") then
                        track:Stop()
                        print("💀 Заблокирована walking анимация:", track.Animation.Name)
                    end
                end
            end
        end
        
        -- Применяем idle позы
        if now - lastFrameTime >= frameInterval then
            lastFrameTime = now
            
            local framePoses = idlePoses[currentFrame]
            
            if framePoses then
                -- Применяем idle позы ко всем Motor6D
                for _, motor in pairs(motor6Ds) do
                    local pose = framePoses[motor.Name]
                    if pose then
                        pcall(function()
                            motor.C0 = pose.C0
                            motor.C1 = pose.C1
                            motor.Transform = pose.Transform
                        end)
                    end
                end
            end
            
            -- Переходим к следующему кадру с ПЛАВНЫМ зацикливанием
            currentFrame = currentFrame + 1
            if currentFrame > #idlePoses then
                currentFrame = 1  -- Зацикливаем idle
                print("🔄 Полный idle цикл завершен, начинаю заново естественно")
            end
        end
    end)
    
    print("✅ Агрессивное форсирование запущено!")
    print("🔥 Питомец заблокирован в ТОЛЬКО idle анимации!")
    print("💀 ВСЕ walking анимации уничтожаются каждый кадр!")
    
    return forceConnection
end

-- Функция ПРИНУДИТЕЛЬНОЙ IDLE СИСТЕМЫ (ИСПРАВЛЕННАЯ)
local function startForceIdleSystem(originalModel, copyModel)
    print("\n🔥 === ПРИНУДИТЕЛЬНАЯ IDLE СИСТЕМА ===")  
    
    -- Находим Motor6D в обеих моделях
    local originalMotors = {}
    local copyMotors = {}
    
    for _, obj in pairs(originalModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(originalMotors, obj)
        end
    end
    
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(copyMotors, obj)
        end
    end
    
    print("🔧 Motor6D - Оригинал:", #originalMotors, "Копия:", #copyMotors)
    
    if #originalMotors == 0 or #copyMotors == 0 then
        print("❌ Недостаточно Motor6D!")
        return nil
    end
    
    -- Создаем карты для быстрого поиска
    local originalMap = createMotorMap(originalMotors)
    local copyMap = createMotorMap(copyMotors)
    
    -- Найдем rootPart для детекции idle
    local originalRootPart = originalModel:FindFirstChild("RootPart") or originalModel:FindFirstChild("HumanoidRootPart") or originalModel:FindFirstChild("Torso")
    
    if not originalRootPart then
        print("❌ rootPart не найден в оригинале!")
        return nil
    end
    
    print("✅ Найден rootPart для детекции:", originalRootPart.Name)
    
    -- Переменные для записи idle
    local idleFrames = {}
    local isRecording = false
    local isLooping = false
    local recordingStartTime = 0
    local lastPosition = originalRootPart.Position
    local idleFrameCount = 0
    local requiredIdleFrames = 30 -- 1 секунда неподвижности
    local recordingTime = 3.0 -- 3 секунды записи
    
    print("💡 Жду когда питомец встанет на 1 секунду для записи idle...")
    
    local connection = RunService.Heartbeat:Connect(function()
        -- Проверяем существование моделей
        if not originalModel.Parent or not copyModel.Parent or not originalRootPart.Parent then
            print("⚠️ Модель удалена, останавливаю систему")
            connection:Disconnect()
            return
        end
        
        -- === ЭТАП 1: ЗАПИСЬ IDLE АНИМАЦИИ ===
        if not isLooping then
            -- Детектируем idle состояние по позиции
            local currentPosition = originalRootPart.Position
            local positionChange = (currentPosition - lastPosition).Magnitude
            
            if positionChange < 0.05 then -- Очень строгий порог
                idleFrameCount = idleFrameCount + 1
            else
                idleFrameCount = 0
                if isRecording then
                    print("⚠️ Запись прервана - питомец начал двигаться")
                    isRecording = false
                    idleFrames = {}
                    recordingStartTime = 0
                end
            end
            
            lastPosition = currentPosition
            
            -- Начинаем запись когда питомец стоит достаточно долго
            if not isRecording and idleFrameCount >= requiredIdleFrames then
                print("🎬 НАЧИНАЮ ЗАПИСЬ IDLE АНИМАЦИИ!")
                isRecording = true
                idleFrames = {}
                recordingStartTime = tick()
            end
            
            -- Записываем кадры idle анимации
            if isRecording and idleFrameCount >= requiredIdleFrames then
                local frame = {}
                
                for key, originalMotor in pairs(originalMap) do
                    if originalMotor.Parent then
                        frame[key] = {
                            C0 = originalMotor.C0,
                            C1 = originalMotor.C1
                        }
                    end
                end
                
                table.insert(idleFrames, frame)
                
                -- Проверяем время записи
                if tick() - recordingStartTime >= recordingTime then
                    print("✅ ЗАПИСЬ ЗАВЕРШЕНА! Записано:", #idleFrames, "кадров idle")
                    print("🔄 НАЧИНАЮ ПРИНУДИТЕЛЬНОЕ ЗАЦИКЛИВАНИЕ!")
                    isRecording = false
                    isLooping = true
                end
            end
        end
        
        -- === ЭТАП 2: ПРИНУДИТЕЛЬНОЕ ЗАЦИКЛИВАНИЕ IDLE НА КОПИИ ===
        if isLooping and #idleFrames > 0 then
            -- Вычисляем текущий кадр для зацикливания
            local frameIndex = (tick() * 30) % #idleFrames -- 30 FPS
            frameIndex = math.floor(frameIndex) + 1
            
            local currentFrame = idleFrames[frameIndex]
            
            -- ПРИНУДИТЕЛЬНО применяем idle анимацию ТОЛЬКО к копии
            for key, motorData in pairs(currentFrame) do
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
    end)
    
    print("✅ ПРИНУДИТЕЛЬНАЯ IDLE СИСТЕМА ЗАПУЩЕНА!")
    print("📍 Копия будет ВСЕГДА играть только idle анимацию!")
    print("🔥 Никакой статичности при ходьбе!")
    
    return connection
end

-- === ОСНОВНЫЕ ФУНКЦИИ ===

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
    print("🚀 PetScaler v2.0 запущен!")
    
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
    
    -- Шаг 5: Запуск принудительной idle системы
    print("\n🔥 === ПРИНУДИТЕЛЬНАЯ IDLE СИСТЕМА ===")
    
    local idleConnection = startForceIdleSystem(petModel, petCopy)
    
    if idleConnection then
        print("🎉 === УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Принудительная idle система запущена")
        print("📍 Копия ВСЕГДА играет только idle анимацию")
        print("🚀 Никакой статичности при ходьбе оригинала!")
        print("🔥 Копия НИКОГДА не будет ходить!")
    else
        print("⚠️ Масштабирование успешно, но idle система не запустилась")
        print("💡 Возможно проблема с Motor6D соединениями")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerV2GUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerV2GUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 150) -- Под оригинальным PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Зеленая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 230, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    button.BorderSizePixel = 0
    button.Text = "🔥 PetScaler v2.0 + Анимация"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Создаю с анимацией..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🔥 PetScaler v2.0 + Анимация"
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
    
    print("🖥️ PetScaler v2.0 GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 60))
print("💡 PETSCALER v2.0 - ВСЕ В ОДНОМ:")
print("   1. Создает масштабированную копию")
print("   2. Настраивает правильные Anchored состояния")
print("   3. Автоматически запускает живое копирование анимации")
print("🎯 Нажмите зеленую кнопку для запуска!")
print("=" .. string.rep("=", 60))
