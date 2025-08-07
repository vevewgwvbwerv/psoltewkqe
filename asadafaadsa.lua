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

-- Конфигурация ПЛАВНОГО УВЕЛИЧЕНИЯ ДО ОРИГИНАЛЬНОГО РАЗМЕРА
local CONFIG = {
    SEARCH_RADIUS = 100,
    START_SCALE = 0.3,      -- Начальный размер копии (30% от оригинала)
    TARGET_SCALE = 1.0,     -- Целевой размер (как оригинал)
    SCALE_FACTOR = 1.0,     -- Для совместимости с Motor6D логикой
    TWEEN_TIME = 3.0,       -- Время плавного увеличения
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

-- Функция плавного увеличения с маленького до оригинального размера
local function scaleModelSmoothly(model, scaleFactor, tweenTime)
    print("🔥 Начинаю плавное увеличение с маленького до оригинального размера:", model.Name)
    print("📍 Начальный размер:", CONFIG.START_SCALE .. "x (маленький)")
    print("🎯 Целевой размер:", CONFIG.TARGET_SCALE .. "x (как оригинал)")
    
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
    
    -- НОВАЯ ЛОГИКА: СНАЧАЛА УМЕНЬШАЕМ КОПИЮ, ПОТОМ УВЕЛИЧИВАЕМ
    
    -- Шаг 1: Сохраняем оригинальные размеры (это будет целевой размер)
    local originalData = {}
    for _, part in ipairs(parts) do
        originalData[part] = {
            size = part.Size,  -- Оригинальный размер (целевой)
            cframe = part.CFrame
        }
    end
    
    -- Шаг 2: СНАЧАЛА уменьшаем копию до START_SCALE (МГНОВЕННО)
    print("🔍 Шаг 1: Уменьшаю копию до маленького размера (" .. CONFIG.START_SCALE .. "x)")
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        -- Уменьшаем размер до START_SCALE
        local startSize = originalSize * CONFIG.START_SCALE
        
        -- Уменьшаем позицию относительно центра
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local scaledRelativeCFrame = CFrame.new(relativeCFrame.Position * CONFIG.START_SCALE) * (relativeCFrame - relativeCFrame.Position)
        local startCFrame = centerCFrame * scaledRelativeCFrame
        
        -- МГНОВЕННО устанавливаем маленький размер
        part.Size = startSize
        part.CFrame = startCFrame
    end
    
    print("✅ Копия уменьшена до маленького размера!")
    
    -- Небольшая пауза чтобы увидеть маленькую копию
    wait(0.5)
    
    -- Шаг 3: Теперь ПЛАВНО увеличиваем до оригинального размера
    print("🚀 Шаг 2: Плавно увеличиваю до оригинального размера (" .. CONFIG.TARGET_SCALE .. "x)")
    
    -- Создаем TweenInfo
    local tweenInfo = TweenInfo.new(
        tweenTime,
        CONFIG.EASING_STYLE,
        CONFIG.EASING_DIRECTION,
        0, -- Повторений
        false, -- Обратная анимация
        0 -- Задержка
    )
    
    -- ПЛАВНОЕ УВЕЛИЧЕНИЕ ДО ОРИГИНАЛЬНОГО РАЗМЕРА
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local targetSize = originalData[part].size * CONFIG.TARGET_SCALE  -- Оригинальный размер
        local targetCFrame = originalData[part].cframe  -- Оригинальная позиция
        
        -- Создаем твин для плавного увеличения до оригинального размера
        -- 🚨 УБИРАЕМ CFrame ИЗ ТВИНА - ПУСТЬ АНИМАЦИЯ УПРАВЛЯЕТ ПОЗИЦИЕЙ!
        local tween = TweenService:Create(part, tweenInfo, {
            Size = targetSize
            -- CFrame = targetCFrame  -- ОТКЛЮЧЕНО! Конфликтует с анимацией
        })
        
        -- Обработчик завершения твина
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ Плавное увеличение завершено!")
                print("🎉 Копия теперь точно такого же размера как оригинал!")
                
                -- КРИТИЧЕСКИ ВАЖНО: ПРИНУДИТЕЛЬНО СТАВИМ КОПИЮ В ВЕРТИКАЛЬНОЕ ПОЛОЖЕНИЕ
                print("🔧 ПРИНУДИТЕЛЬНО ставлю копию в вертикальное положение (не лежачее)...")
                
                if model.PrimaryPart then
                    local currentPosition = model.PrimaryPart.Position
                    
                    -- ПРИНУДИТЕЛЬНО создаем вертикальный CFrame
                    -- Y-ось направлена вверх (0, 1, 0)
                    -- Z-ось направлена вперед (0, 0, -1) - стандартное направление
                    local uprightCFrame = CFrame.new(
                        currentPosition,  -- Позиция
                        currentPosition + Vector3.new(0, 0, -1)  -- Направление вперед
                    )
                    
                    -- Применяем вертикальную ориентацию
                    model:SetPrimaryPartCFrame(uprightCFrame)
                    
                    print("✅ Копия принудительно поставлена в вертикальное положение!")
                    
                    -- Дополнительная коррекция: проверяем все части модели
                    print("🔍 Проверяю и корректирую ориентацию всех частей...")
                    
                    local correctedParts = 0
                    for _, part in pairs(model:GetDescendants()) do
                        if part:IsA("BasePart") and part ~= model.PrimaryPart then
                            -- Проверяем нет ли странных поворотов
                            local partCFrame = part.CFrame
                            local upVector = partCFrame.UpVector
                            
                            -- Если часть повернута неправильно (не вверх)
                            if math.abs(upVector.Y) < 0.7 then -- Y-компонент должен быть близок к 1
                                -- Корректируем ориентацию части
                                local correctedPartCFrame = CFrame.new(
                                    partCFrame.Position,
                                    partCFrame.Position + Vector3.new(0, 0, -1)
                                )
                                part.CFrame = correctedPartCFrame
                                correctedParts = correctedParts + 1
                            end
                        end
                    end
                    
                    print("✅ Коррекция завершена! Исправлено частей:", correctedParts)
                    print("🚀 Копия теперь должна стоять правильно!")
                else
                    print("⚠️ Нет PrimaryPart для коррекции ориентации")
                end
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

-- БЕСКОНЕЧНАЯ IDLE АНИМАЦИЯ (НИКОГДА НЕ ОСТАНАВЛИВАЕТСЯ)
local function startEndlessIdleLoop(originalModel, copyModel)
    print("\n🔄 === БЕСКОНЕЧНАЯ IDLE АНИМАЦИЯ ===\n")
    
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
    
    print("🔧 Motor6D найдено - Оригинал:", #originalMotors, "Копия:", #copyMotors)
    
    if #originalMotors == 0 or #copyMotors == 0 then
        print("❌ Недостаточно Motor6D!")
        return nil
    end
    
    -- УЛУЧШЕННЫЙ ПОИСК HUMANOID И АЛЬТЕРНАТИВНЫЕ МЕТОДЫ
    local originalHumanoid = originalModel:FindFirstChild("Humanoid")
    local originalRootPart = originalModel:FindFirstChild("RootPart") or originalModel:FindFirstChild("HumanoidRootPart") or originalModel:FindFirstChild("Torso")
    
    print("🔍 Поиск компонентов для детекции idle:")
    print("  - Humanoid:", originalHumanoid and "✅ Найден" or "❌ Не найден")
    print("  - RootPart:", originalRootPart and ("✅ Найден (" .. originalRootPart.Name .. ")") or "❌ Не найден")
    
    -- Если нет Humanoid, используем альтернативную детекцию через позицию
    local usePositionDetection = false
    if not originalHumanoid then
        if originalRootPart then
            print("⚠️ Humanoid не найден, но есть RootPart - используем детекцию по позиции")
            usePositionDetection = true
        else
            print("❌ Ни Humanoid, ни RootPart не найдены! Не можем детектировать idle")
            return nil
        end
    else
        print("✅ Humanoid найден:", originalHumanoid.Name)
    end
    
    -- === 📡 СИСТЕМА LIVE ПОТОКОВОЙ IDLE АНИМАЦИИ ===
    -- 🎬 РЕАЛЬНОЕ ВРЕМЯ: КОПИРОВАНИЕ Motor6D С ПИТОМЦА В РУКЕ
    
    -- 🔍 ПОИСК ПИТОМЦА В РУКЕ (ТОЧНАЯ КОПИЯ QuickDataExporter)
    local function findHandHeldPet()
        local player = Players.LocalPlayer
        if not player then 
            print("❌ Player не найден")
            return nil, nil 
        end
        
        print("🔍 Поиск питомца в руке...")
        
        -- ТОЧНО КАК В QuickDataExporter - поиск Tool в character
        local character = player.Character
        if not character then
            print("❌ Character не найден!")
            return nil, nil
        end
        
        print("👤 Проверяем character...")
        
        -- Поиск любого Tool в руках (как в QuickDataExporter)
        local handTool = character:FindFirstChildOfClass("Tool")
        if not handTool then
            print("❌ Tool в руке не найден!")
            return nil, nil
        end
        
        print("🎯 Найден Tool:", handTool.Name)
        
        -- 🔥 НОВАЯ ЛОГИКА: ЛЮБОЙ TOOL С АНИМИРУЕМЫМИ ЧАСТЯМИ - ЭТО ПИТОМЕЦ!
        -- Проверяем что Tool содержит анимируемые части (не только Handle)
        local hasAnimatableParts = false
        for _, obj in pairs(handTool:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Handle" then
                hasAnimatableParts = true
                break
            end
        end
        
        if not hasAnimatableParts then
            print("⚠️ Tool не содержит анимируемых частей (только Handle)")
            return nil, nil
        end
        
        print("✅ Питомец найден в руках:", handTool.Name)
        
        -- ТОЧНО КАК В QuickDataExporter - возвращаем Tool как модель
        return handTool, handTool
    end
    
    -- 📦 Функция получения анимируемых частей из Tool (включая подмодели)
    local function getAnimatedPartsFromTool(tool)
        local parts = {}
        
        if not tool then return parts end
        
        -- Ищем все BasePart в Tool, включая подмодели (исключая Handle)
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Handle" then
                table.insert(parts, obj)
            end
        end
        
        return parts
    end
    
    -- 🎯 Поиск соответствующей части в копии по имени
    local function findCorrespondingPart(copyModel, partName)
        for _, obj in pairs(copyModel:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == partName then
                return obj
            end
        end
        return nil
    end
    
    -- 📐 Масштабирование CFrame с сохранением поворота
    local function scaleCFrame(originalCFrame, scaleFactor)
        local originalPosition = originalCFrame.Position
        local scaledPosition = originalPosition * scaleFactor
        
        -- Сохраняем поворот, но масштабируем позицию
        return CFrame.new(scaledPosition) * (originalCFrame - originalCFrame.Position)
    end
    
    -- 🎭 Глобальные переменные для CFrame анимационной системы
    local handPetModel = nil
    local handPetParts = {}  -- Анимируемые части из Tool
    local lastHandPetCheck = 0
    local HAND_PET_CHECK_INTERVAL = 1.0  -- Интервал поиска питомца в руке
    
    -- 📊 ОТСЛЕЖИВАНИЕ ИЗМЕНЕНИЙ CFrame В ПИТОМЦЕ В РУКЕ
    local previousCFrameStates = {}
    local cframeChangeCount = 0
    local lastChangeTime = 0
    
    -- 🔧 Конфигурация CFrame системы
    local INTERPOLATION_SPEED = 0.3  -- Уменьшаем скорость для стабильности
    local POSITION_THRESHOLD = 0.001  -- Минимальное изменение позиции
    local ROTATION_THRESHOLD = 0.001  -- Минимальное изменение поворота
    local MAX_DISTANCE_FROM_ROOT = 50  -- Максимальное расстояние от корня
    
    -- Переменные для позиционной детекции
    local lastPosition = usePositionDetection and originalRootPart and originalRootPart.Position or Vector3.new(0, 0, 0)
    
    if usePositionDetection then
        print("💡 Использую позиционную детекцию idle через", originalRootPart.Name)
    else
        print("💡 Использую Humanoid.MoveDirection для детекции idle")
    end
    
    print("📡 ЗАПУСКАЮ LIVE ПОТОКОВУЮ СИСТЕМУ IDLE АНИМАЦИИ!")
    print("🎬 Копирование в реальном времени с питомца в руке")
    print("🔄 Копия будет повторять ВСЕ движения оригинала!")
    
    local connection = RunService.Heartbeat:Connect(function()
        -- Проверяем существование моделей
        if not originalModel.Parent or not copyModel.Parent then
            print("⚠️ Модель удалена, останавливаю систему")
            connection:Disconnect()
            return
        end
        
        local currentTime = tick()
        
        -- === 🔍 ПОИСК ПИТОМЦА В РУКЕ ===
        if currentTime - lastHandPetCheck >= HAND_PET_CHECK_INTERVAL then
            local foundPetModel, foundTool = findHandHeldPet()
            
            if foundPetModel ~= handPetModel then
                handPetModel = foundPetModel
                handPetParts = getAnimatedPartsFromTool(handPetModel)
                
                if handPetModel then
                    print("🎯 НАШЛИ ПИТОМЦА В РУКЕ:", foundTool and foundTool.Name or "Неизвестный")
                    print("📦 Анимируемых частей:", #handPetParts)
                    
                    -- Инициализируем отслеживание CFrame
                    previousCFrameStates = {}
                    for _, part in ipairs(handPetParts) do
                        if part and part.Parent then
                            previousCFrameStates[part.Name] = part.CFrame
                        end
                    end
                    
                    cframeChangeCount = 0
                    lastChangeTime = currentTime
                else
                    print("⚠️ Питомец в руке не найден")
                    handPetParts = {}
                end
            end
            
            lastHandPetCheck = currentTime
        end
        
        -- === 📐 LIVE КОПИРОВАНИЕ CFrame СОСТОЯНИЙ ===
        if handPetModel and #handPetParts > 0 then
            local appliedCount = 0
            local changesDetected = 0
            local debugInfo = {}
            
            -- 🔍 ПРОВЕРКА ANCHORED СОСТОЯНИЙ КОПИИ (раз в 10 секунд)
            if math.floor(currentTime) % 10 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                local anchoredParts = 0
                local totalParts = 0
                for _, part in pairs(copyModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        totalParts = totalParts + 1
                        if part.Anchored then
                            anchoredParts = anchoredParts + 1
                        end
                    end
                end
                print(string.format("⚓ ANCHORED ДИАГНОСТИКА: %d/%d частей заякорено", anchoredParts, totalParts))
            end
            
            -- 📊 ОТСЛЕЖИВАНИЕ И КОПИРОВАНИЕ CFrame ИЗМЕНЕНИЙ
            for _, handPart in ipairs(handPetParts) do
                if handPart and handPart.Parent then
                    local partName = handPart.Name
                    local currentCFrame = handPart.CFrame
                    
                    -- Проверяем изменилось ли CFrame состояние
                    local hasChanged = false
                    if previousCFrameStates[partName] then
                        local prevCFrame = previousCFrameStates[partName]
                        local positionDiff = (currentCFrame.Position - prevCFrame.Position).Magnitude
                        local rotationDiff = math.abs(currentCFrame.LookVector:Dot(prevCFrame.LookVector) - 1)
                        
                        if positionDiff > POSITION_THRESHOLD or rotationDiff > ROTATION_THRESHOLD then
                            hasChanged = true
                            changesDetected = changesDetected + 1
                        end
                    end
                    
                    -- Обновляем предыдущее состояние
                    previousCFrameStates[partName] = currentCFrame
                    
                    -- Находим соответствующую часть в копии и применяем CFrame
                    local copyPart = findCorrespondingPart(copyModel, partName)
                    if copyPart then
                        local success, errorMsg = pcall(function()
                            -- 📐 МАСШТАБИРОВАНИЕ И ПРИМЕНЕНИЕ CFrame
                            local scaledCFrame = scaleCFrame(currentCFrame, CONFIG.SCALE_FACTOR)
                            
                            -- 🔒 ПРОВЕРКА БЕЗОПАСНОСТИ CFrame
                            local copyRootPart = copyModel.PrimaryPart or copyModel:FindFirstChild("RootPart") or copyModel:FindFirstChild("Torso")
                            if copyRootPart then
                                local distanceFromRoot = (scaledCFrame.Position - copyRootPart.Position).Magnitude
                                if distanceFromRoot > MAX_DISTANCE_FROM_ROOT then
                                    -- Ограничиваем расстояние от корня
                                    local direction = (scaledCFrame.Position - copyRootPart.Position).Unit
                                    local limitedPosition = copyRootPart.Position + direction * MAX_DISTANCE_FROM_ROOT
                                    scaledCFrame = CFrame.new(limitedPosition) * (scaledCFrame - scaledCFrame.Position)
                                end
                            end
                            
                            -- Проверяем что CFrame не является NaN или бесконечностью
                            if scaledCFrame.Position.X ~= scaledCFrame.Position.X or 
                               math.abs(scaledCFrame.Position.X) == math.huge or
                               math.abs(scaledCFrame.Position.Y) == math.huge or
                               math.abs(scaledCFrame.Position.Z) == math.huge then
                                return -- Пропускаем некорректные значения
                            end
                            
                            -- 🔥 ПРИМЕНЯЕМ CFrame К ВСЕМ ЧАСТЯМ (И ЗАЯКОРЕННЫМ ТОЖЕ!)
                            -- Проблема была в том что CFrame применялся только к незаякоренным!
                            if copyPart.Parent then
                                -- Применяем к ЛЮБЫМ частям - заякоренным и незаякоренным
                                copyPart.CFrame = copyPart.CFrame:Lerp(scaledCFrame, INTERPOLATION_SPEED)
                            end
                            
                            -- Диагностическая информация
                            table.insert(debugInfo, {
                                name = partName,
                                changed = hasChanged,
                                anchored = copyPart.Anchored,
                                applied = true  -- 🔥 Теперь применяем ко всем частям!
                            })
                        end)
                        
                        if success then
                            appliedCount = appliedCount + 1
                        else
                            print("❌ Ошибка при применении CFrame", partName, ":", errorMsg)
                        end
                    end
                end
            end
            
            -- Обновляем счетчики изменений
            if changesDetected > 0 then
                cframeChangeCount = cframeChangeCount + changesDetected
                lastChangeTime = currentTime
            end
            
            -- 🔍 МОНИТОРИНГ СОСТОЯНИЯ КОПИИ
            local copyPartsCount = 0
            local validCopyParts = 0
            local anchoredParts = 0
            
            for _, part in ipairs(copyModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    copyPartsCount = copyPartsCount + 1
                    if part.Parent then
                        validCopyParts = validCopyParts + 1
                        if part.Anchored then
                            anchoredParts = anchoredParts + 1
                        end
                    end
                end
            end
            
            -- 📊 ДЕТАЛЬНАЯ ДИАГНОСТИКА каждые 3 секунды
            if math.floor(currentTime) % 3 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("📐 LIVE CFrame КОПИРОВАНИЕ: применено", appliedCount, "/", #handPetParts, "CFrame состояний")
                print(string.format("🔍 СОСТОЯНИЕ КОПИИ: %d/%d частей валидны, %d заякорено", validCopyParts, copyPartsCount, anchoredParts))
                
                -- 🎯 ОТЧЕТ ОБ ИЗМЕНЕНИЯХ В ПИТОМЦЕ В РУКЕ
                local timeSinceLastChange = currentTime - lastChangeTime
                print(string.format("🎭 ПИТОМЕЦ В РУКЕ: %d изменений CFrame, последнее %.1f сек назад", 
                    cframeChangeCount, timeSinceLastChange))
                
                if changesDetected > 0 then
                    print(string.format("✅ CFrame АНИМАЦИЯ КОПИРУЕТСЯ: %d частей изменились!", changesDetected))
                else
                    print("⚠️ ПИТОМЕЦ СТАТИЧЕН: CFrame не изменяются")
                end
                
                -- 🚨 ПРЕДУПРЕЖДЕНИЕ О ПОТЕРЕ ЧАСТЕЙ
                if validCopyParts < copyPartsCount * 0.8 then
                    print(string.format("🚨 ВНИМАНИЕ: Копия теряет части! %d из %d частей потеряны!", 
                        copyPartsCount - validCopyParts, copyPartsCount))
                end
                
                -- Показываем первые 3 части для диагностики
                for i = 1, math.min(3, #debugInfo) do
                    local info = debugInfo[i]
                    print(string.format("📐 %s: Changed=%s Anchored=%s Applied=%s", 
                        info.name, tostring(info.changed), tostring(info.anchored), tostring(info.applied)))
                end
            end
        else
            -- Питомец в руке не найден - используем стандартную idle позу
            if math.floor(currentTime) % 5 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("⚠️ Питомец в руке не найден - копия в статичной позе")
            end
        end
    end)
    
    -- КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Проверяем Anchored состояния
    print("🔍 ПРОВЕРКА ANCHORED СОСТОЯНИЙ КОПИИ:")
    local copyParts = getAllParts(copyModel)
    local anchoredCount = 0
    local rootPart = nil
    
    -- Находим корневую часть
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
    
    -- Правильно настраиваем Anchored
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            part.Anchored = true -- Только корень заякорен
        else
            part.Anchored = false -- Остальные свободны для анимации
        end
        if part.Anchored then
            anchoredCount = anchoredCount + 1
        end
    end
    
    print("⚙️ Корневая часть:", rootPart and rootPart.Name or "Не найдена")
    print("⚓ Anchored частей:", anchoredCount, "/", #copyParts)
    
    print("✅ ПРИНУДИТЕЛЬНАЯ IDLE СИСТЕМА ЗАПУЩЕНА!")
    print("📍 Копия будет ВСЕГДА играть только idle анимацию!")
    print("🔥 Никакой статичности при ходьбе!")
    
    return connection
end

-- === ОСНОВНЫЕ ФУНКЦИИ ===

-- 🔥 ФУНКЦИЯ ПОИСКА ПИТОМЦЕВ С ПОДРОБНОЙ ДИАГНОСТИКОЙ (ДЛЯ DOG И DRAGONFLY)
local function findAndScalePet()
    print("🔍 Поиск UUID моделей питомцев (Dog и Dragonfly)...")
    print("📍 Позиция игрока:", playerPos)
    print("🎯 Радиус поиска:", CONFIG.SEARCH_RADIUS, "стадов")
    
    local foundPets = {}
    local totalModels = 0
    local uuidModels = 0
    local modelsInRange = 0
    local modelsWithVisuals = 0
    
    -- 🔍 ПОДРОБНОЕ СКАНИРОВАНИЕ ВСЕХ МОДЕЛЕЙ
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            totalModels = totalModels + 1
            
            -- 🔍 ПРОВЕРКА UUID ФОРМАТА
            if obj.Name:find("%{") and obj.Name:find("%}") then
                uuidModels = uuidModels + 1
                
                -- 🐉 ОПРЕДЕЛЯЕМ ТИП ПИТОМЦА ПО ИМЕНИ (ДЛЯ ДИАГНОСТИКИ)
                local petType = "Unknown"
                if obj.Name:find("Dog") or obj.Name:find("KG") then
                    petType = "Dog"
                elseif obj.Name:find("Dragonfly") then
                    petType = "Dragonfly"
                elseif obj.Name:find("Age") then
                    petType = "Possible Pet (Age)"
                end
                
                print(string.format("🔍 UUID модель найдена: %s [%s]", obj.Name, petType))
                
                local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
                if success then
                    local distance = (modelCFrame.Position - playerPos).Magnitude
                    print(string.format("  📏 Расстояние: %.1f стадов (лимит: %d)", distance, CONFIG.SEARCH_RADIUS))
                    
                    if distance <= CONFIG.SEARCH_RADIUS then
                        modelsInRange = modelsInRange + 1
                        print("  ✅ В радиусе поиска!")
                        
                        local hasVisuals, meshes = hasPetVisuals(obj)
                        print(string.format("  👀 Визуальные элементы: %s (%d meshes)", hasVisuals and "✅ Есть" or "❌ Нет", meshes and #meshes or 0))
                        
                        -- 🔥 НОВАЯ ЛОГИКА: UUID МОДЕЛИ - ЭТО ПИТОМЦЫ ДАЖЕ БЕЗ MESHES!
                        local isValidPet = hasVisuals or true  -- UUID модели всегда питомцы!
                        
                        if isValidPet then
                            modelsWithVisuals = modelsWithVisuals + 1
                            if hasVisuals then
                                print(string.format("  🎉 ✅ ПИТОМЕЦ НАЙДЕН: %s [%s] (расстояние: %.1f) - с визуалами", obj.Name, petType, distance))
                            else
                                print(string.format("  🎉 ✅ ПИТОМЕЦ НАЙДЕН: %s [%s] (расстояние: %.1f) - UUID без визуалов", obj.Name, petType, distance))
                            end
                            table.insert(foundPets, {
                                model = obj,
                                distance = distance,
                                meshes = meshes,
                                petType = petType
                            })
                        else
                            print("  ❌ Нет визуальных элементов - не питомец")
                        end
                    else
                        print(string.format("  ❌ Слишком далеко (%.1f > %d стадов)", distance, CONFIG.SEARCH_RADIUS))
                    end
                else
                    print("  ❌ Ошибка получения позиции модели")
                end
                print() -- Пустая строка для разделения
            end
        end
    end
    
    -- 📊 ИТОГОВАЯ СТАТИСТИКА
    print("📊 === СТАТИСТИКА ПОИСКА ===")
    print(string.format("📦 Всего моделей просканировано: %d", totalModels))
    print(string.format("🔑 UUID моделей найдено: %d", uuidModels))
    print(string.format("📏 Моделей в радиусе поиска: %d", modelsInRange))
    print(string.format("👀 Моделей с визуалами: %d", modelsWithVisuals))
    print(string.format("🎯 ПИТОМЦЕВ НАЙДЕНО: %d", #foundPets))
    print()
    
    if #foundPets == 0 then
        print("❌ ПИТОМЦЫ НЕ НАЙДЕНЫ!")
        if uuidModels == 0 then
            print("💡 Совет: Убедитесь что питомец рядом с вами (в радиусе 100 стадов)")
            print("💡 Имя питомца должно содержать UUID в фигурных скобках {....}")
        elseif modelsInRange == 0 then
            print("💡 UUID модели найдены, но все слишком далеко!")
            print("💡 Подойдите ближе к питомцу (в радиус 100 стадов)")
        elseif modelsWithVisuals == 0 then
            print("💡 Модели в радиусе найдены, но у них нет визуальных элементов")
            print("💡 Возможно это не питомцы или у них нет MeshPart/SpecialMesh")
        end
        return nil
    end
    
    -- Сортируем по расстоянию (ближайший первый)
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    
    local targetPet = foundPets[1]
    print(string.format("🎯 ✅ ВЫБРАН ПИТОМЕЦ: %s [%s] (расстояние: %.1f стадов)", 
        targetPet.model.Name, targetPet.petType or "Unknown", targetPet.distance))
    print()
    
    return targetPet.model
end

-- 🎯 ФУНКЦИЯ СТАЦИОНАРНОЙ CFrame АНИМАЦИИ (КОПИРУЕМ ИЗ РУКИ!)
local function startStationaryCFrameAnimation(originalModel, copyModel)
    print("🎯 Запускаю стационарную CFrame анимацию...")
    print("🔍 КЛЮЧЕВОЕ ОТЛИЧИЕ: копирую анимацию ИЗ ПИТОМЦА В РУКЕ, а не из оригинала!")
    
    -- 🔍 ПОИСК ПИТОМЦА В РУКЕ ИГРОКА
    local function findHandHeldPet()
        if not player.Character then
            print("❌ Персонаж игрока не найден!")
            return nil
        end
        
        print("🔍 Ищу питомца в руке игрока...")
        
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                print(string.format("🔹 Найден Tool: %s", tool.Name))
                
                -- Поиск модели питомца внутри Tool
                for _, child in pairs(tool:GetChildren()) do
                    if child:IsA("Model") then
                        print(string.format("✅ Найдена модель питомца в руке: %s", child.Name))
                        return child
                    end
                end
            end
        end
        
        print("⚠️ Питомец в руке не найден!")
        return nil
    end
    
    -- 🔍 НАХОДИМ ПИТОМЦА В РУКЕ
    local handPetModel = findHandHeldPet()
    if not handPetModel then
        print("❌ Не могу найти питомца в руке - использую оригинал")
        handPetModel = originalModel
    else
        print("✅ Найден питомец в руке - буду копировать его анимацию!")
    end
    
    -- Настройки анимации
    local INTERPOLATION_SPEED = 0.3
    
    -- 🔍 УЛУЧШЕННАЯ ЛОГИКА ПОИСКА АНИМИРУЕМЫХ ЧАСТЕЙ
    local function getAnimatableParts(model)
        local parts = {}
        local partCount = 0
        
        print("🔍 Анализирую структуру модели:", model.Name)
        
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Handle" then
                partCount = partCount + 1
    
    -- Получаем все части модели питомца В РУКЕ (источник анимации)
    local sourceParts = {}
    for _, part in pairs(handPetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            local partName = part.Name
            
            -- 🐉 ОСОБОЕ ВНИМАНИЕ К DRAGONFLY ЧАСТЯМ
            local isDragonflyPart = string.find(partName:lower(), "wing") or 
                                  string.find(partName:lower(), "tail") or 
                                  string.find(partName:lower(), "leg") or 
                                  string.find(partName:lower(), "body") or 
                                  string.find(partName:lower(), "head") or 
                                  string.find(partName:lower(), "bug")
            
            if isDragonflyPart then
                print(string.format("  ✅ Найдена важная часть В РУКЕ: %s (тип: %s)", partName, part.ClassName))
            end
            
            sourceParts[partName] = part
        end
    end
    
    -- Получаем все части копии
    local copyParts = {}
    for _, part in pairs(copyModel:GetDescendants()) do
        if part:IsA("BasePart") then
            copyParts[part.Name] = part
        end
    end
    
    -- 📍 СОХРАНЯЕМ НАЧАЛЬНЫЕ ПОЗИЦИИ КОПИИ (чтобы она НЕ двигалась)
    local initialPositions = {}
    for partName, copyPart in pairs(copyParts) do
        if sourceParts[partName] then
            initialPositions[partName] = copyPart.CFrame.Position
        end
    end
    
    print("📍 Сохранил начальные позиции копии - она НЕ будет двигаться!")
    
    -- 🎯 ОСНОВНОЙ ЦИКЛ АНИМАЦИИ (КОПИРУЕМ ИЗ ПИТОМЦА В РУКЕ!)
    local animationConnection
    animationConnection = RunService.Heartbeat:Connect(function()
        for partName, copyPart in pairs(copyParts) do
            local sourcePart = sourceParts[partName]  -- 🔥 ИСТОЧНИК - ПИТОМЕЦ В РУКЕ!
            local initialPos = initialPositions[partName]
            
            if sourcePart and initialPos then
                local sourceCFrame = sourcePart.CFrame
                
                -- 🎯 КЛЮЧЕВОЕ ОТЛИЧИЕ: КОПИРУЕМ ТОЛЬКО ВРАЩЕНИЕ ИЗ РУКИ, НО ОСТАВЛЯЕМ ПОЗИЦИЮ НА МЕСТЕ
                local newCFrame = CFrame.new(initialPos, initialPos + sourceCFrame.LookVector) * 
                                 (sourceCFrame - sourceCFrame.Position)
                
                -- Применяем с интерполяцией
                copyPart.CFrame = copyPart.CFrame:Lerp(newCFrame, INTERPOLATION_SPEED)
            end
        end
    end)
    
    print("✅ Стационарная CFrame анимация запущена!")
    print("🎯 Копия будет анимироваться НА МЕСТЕ, не следуя за оригиналом!")
    return animationConnection
end

-- 🔥 ФУНКЦИЯ CFrame АНИМАЦИИ ДЛЯ HAND-PET КОПИИ (УСТАРЕЛА)
local function startCFrameAnimation(originalModel, copyModel)
    print("🎨 Запускаю CFrame анимацию для hand-pet копии...")
    
    -- Настройки анимации
    local INTERPOLATION_SPEED = 0.3
    local UPDATE_RATE = 60 -- FPS
    
    -- 🔍 УЛУЧШЕННАЯ ЛОГИКА ПОИСКА АНИМИРУЕМЫХ ЧАСТЕЙ
    local function getAnimatableParts(model)
        local parts = {}
        local partCount = 0
        
        print("🔍 Анализирую структуру модели:", model.Name)
        
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Handle" then
                partCount = partCount + 1
                
                -- 🐉 ОСОБОЕ ВНИМАНИЕ К DRAGONFLY ЧАСТЯМ
                local isDragonflyPart = obj.Name:find("Wing") or obj.Name:find("Tail") or 
                                       obj.Name:find("Leg") or obj.Name:find("Body") or
                                       obj.Name:find("Head") or obj.Name:find("Bug")
                
                if isDragonflyPart then
                    print(string.format("  ✅ Найдена важная часть: %s (тип: %s)", obj.Name, obj.ClassName))
                end
                
                -- Сохраняем ВСЕ BasePart для анимации
                parts[obj.Name] = obj
                
                -- Логируем первые 10 частей для диагностики
                if partCount <= 10 then
                    print(string.format("  🔹 Часть #%d: %s (тип: %s)", partCount, obj.Name, obj.ClassName))
                elseif partCount == 11 then
                    print("  ... (и еще части)")
                end
            end
        end
        
        print(string.format("📊 Итого найдено частей: %d", partCount))
        return parts
    end
    
    local originalParts = getAnimatableParts(originalModel)
    local copyParts = getAnimatableParts(copyModel)
    
    print(string.format("🎨 Найдено частей: оригинал=%d, копия=%d", 
        table.getn(originalParts), table.getn(copyParts)))
    
    -- Запускаем анимационный цикл
    local connection = RunService.Heartbeat:Connect(function()
        local appliedCount = 0
        local changesDetected = 0
        
        for partName, originalPart in pairs(originalParts) do
            local copyPart = copyParts[partName]
            
            if copyPart and originalPart.Parent and copyPart.Parent then
                local success, errorMsg = pcall(function()
                    local originalCFrame = originalPart.CFrame
                    local hasChanged = copyPart.CFrame ~= originalCFrame
                    
                    if hasChanged then
                        changesDetected = changesDetected + 1
                    end
                    
                    -- Проверяем что CFrame не является NaN или бесконечностью
                    if originalCFrame.Position.X ~= originalCFrame.Position.X or 
                       math.abs(originalCFrame.Position.X) == math.huge or
                       math.abs(originalCFrame.Position.Y) == math.huge or
                       math.abs(originalCFrame.Position.Z) == math.huge then
                        return -- Пропускаем некорректные значения
                    end
                    
                    -- 🔥 ПРИМЕНЯЕМ CFrame К ВСЕМ ЧАСТЯМ (И ЗАЯКОРЕННЫМ ТОЖЕ!)
                    if copyPart.Parent then
                        -- Применяем к ЛЮБЫМ частям - заякоренным и незаякоренным
                        copyPart.CFrame = copyPart.CFrame:Lerp(originalCFrame, INTERPOLATION_SPEED)
                        appliedCount = appliedCount + 1
                    end
                end)
                
                if not success then
                    print("❌ Ошибка при применении CFrame", partName, ":", errorMsg)
                end
            end
        end
        
        -- Логирование каждые 60 кадров (каждую секунду)
        if tick() % 1 < 0.02 then -- Примерно каждую секунду
            print(string.format("🎨 CFrame анимация: применено=%d, изменений=%d", 
                appliedCount, changesDetected))
        end
    end)
    
    print("✅ CFrame анимация запущена для hand-pet копии!")
    return connection
end

-- 🔥 ФУНКЦИЯ СОЗДАНИЯ HAND-PET КОПИИ В РУКЕ
local function createHandPetCopy(originalModel)
    print("🔥 Создаю hand-pet копию в руке...")
    
    -- Создаем копию модели
    local petCopy = originalModel:Clone()
    petCopy.Name = originalModel.Name .. "_HAND_COPY"
    
    -- Создаем Tool для руки
    local tool = Instance.new("Tool")
    tool.Name = "PetCopy_" .. originalModel.Name
    tool.RequiresHandle = true
    
    -- Создаем Handle для Tool
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.1, 0.1, 0.1)
    handle.Transparency = 1
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = tool
    
    -- Помещаем копию питомца в Tool
    petCopy.Parent = tool
    
    -- Заякориваем все части копии для стабильности
    for _, part in pairs(petCopy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    -- Помещаем Tool в руку игрока
    tool.Parent = player.Character
    
    print("✅ Hand-pet копия создана как Tool в руке!")
    
    -- Запускаем CFrame анимацию для hand-pet копии
    spawn(function()
        startCFrameAnimation(originalModel, petCopy)
    end)
    
    return tool
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
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.TARGET_SCALE, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование не удалось!")
        return
    end
    
    -- 🔥 Шаг 2: СОЗДАНИЕ HAND-PET КОПИИ С CFrame АНИМАЦИЕЙ
    print("\n🔥 === СОЗДАНИЕ HAND-PET КОПИИ ===")
    print("🎯 Начинаю создание копии в руке с CFrame анимацией!")
    
    -- 🔥 УБРАЛ ВСЮ ЛОГИКУ "ОГРЫЗКА" (масштабирование, позиционирование)
    -- ОСТАЛАСЬ ТОЛЬКО HAND-PET КОПИЯ!
    
    -- 🔥 СОЗДАНИЕ HAND-PET КОПИИ В РУКЕ
    print("🔥 Начинаю создание hand-pet копии...")
    
    -- 🎯 СОЗДАНИЕ СТАЦИОНАРНОЙ КОПИИ С АНИМАЦИЕЙ РЯДОМ С ОРИГИНАЛОМ
    print("🎯 Создаю стационарную копию с анимацией...")
    
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- 🎯 Шаг 5: Запуск СТАЦИОНАРНОЙ CFrame анимации
    print("\n🎯 === СТАЦИОНАРНАЯ CFrame АНИМАЦИЯ ===")
    print("🔄 Копия будет играть анимацию оригинала, но НЕ следовать за ним!")
    
    -- 🎯 ЗАПУСКАЕМ СТАЦИОНАРНУЮ АНИМАЦИЮ (ТОЛЬКО ВРАЩЕНИЯ, БЕЗ ПОЗИЦИИ)
    local stationaryConnection = startStationaryCFrameAnimation(petModel, petCopy)
    
    if stationaryConnection then
        print("🎉 === УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Стационарная CFrame анимация запущена")
        print("🎯 Копия играет анимацию оригинала НА МЕСТЕ")
        print("🚀 Крылья, хвост, ноги анимируются как у оригинала!")
        print("📍 Копия НЕ следует за оригиналом - стоит на своем месте!")
    else
        print("⚠️ Масштабирование успешно, но CFrame анимация не запустилась")
        print("💡 Возможно проблема с поиском частей или CFrame логикой")
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
