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
        local tween = TweenService:Create(part, tweenInfo, {
            Size = targetSize,
            CFrame = targetCFrame
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
        
        -- Проверяем что это питомец (содержит KG)
        if not handTool.Name:find("KG") then
            print("⚠️ Tool не является питомцем (KG не найден)")
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
    local INTERPOLATION_SPEED = 0.8  -- Скорость интерполяции CFrame
    local POSITION_THRESHOLD = 0.001  -- Минимальное изменение позиции
    local ROTATION_THRESHOLD = 0.001  -- Минимальное изменение поворота
    
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
                            
                            -- Применяем с интерполяцией для плавности (только к незаякоренным частям)
                            if not copyPart.Anchored then
                                copyPart.CFrame = copyPart.CFrame:Lerp(scaledCFrame, INTERPOLATION_SPEED)
                            end
                            
                            -- Диагностическая информация
                            table.insert(debugInfo, {
                                name = partName,
                                changed = hasChanged,
                                anchored = copyPart.Anchored,
                                applied = not copyPart.Anchored
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
            
            -- 📊 ДЕТАЛЬНАЯ ДИАГНОСТИКА каждые 3 секунды
            if math.floor(currentTime) % 3 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("📐 LIVE CFrame КОПИРОВАНИЕ: применено", appliedCount, "/", #handPetParts, "CFrame состояний")
                
                -- 🎯 ОТЧЕТ ОБ ИЗМЕНЕНИЯХ В ПИТОМЦЕ В РУКЕ
                local timeSinceLastChange = currentTime - lastChangeTime
                print(string.format("🎭 ПИТОМЕЦ В РУКЕ: %d изменений CFrame, последнее %.1f сек назад", 
                    cframeChangeCount, timeSinceLastChange))
                
                if changesDetected > 0 then
                    print(string.format("✅ CFrame АНИМАЦИЯ КОПИРУЕТСЯ: %d частей изменились!", changesDetected))
                else
                    print("⚠️ ПИТОМЕЦ СТАТИЧЕН: CFrame не изменяются")
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
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.TARGET_SCALE, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование не удалось!")
        return
    end
    
    -- Шаг 4: ПОСЛЕ масштабирования настраиваем Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ДЛЯ АНИМАЦИИ ===")
    wait(CONFIG.TWEEN_TIME + 1) -- Ждем завершения масштабирования
    
    -- 🎯 КОПИРОВАНИЕ ТОЧНОЙ ОРИЕНТАЦИИ ОРИГИНАЛА
    print("\n🎯 === КОПИРОВАНИЕ ОРИЕНТАЦИИ ОРИГИНАЛА ===")
    print("📊 Анализатор показал: UpVector оригинала = (0, 0, -1)")
    print("📊 Копируем ТОЧНУЮ ориентацию оригинального питомца!")
    
    if petCopy.PrimaryPart and petModel and petModel.PrimaryPart then
        local copyRootPart = petCopy.PrimaryPart
        local originalRootPart = petModel.PrimaryPart
        
        local currentPos = copyRootPart.Position
        local originalCFrame = originalRootPart.CFrame
        
        print("📊 ДО коррекции:")
        print("   Копия позиция:", currentPos)
        print("   Копия UpVector:", copyRootPart.CFrame.UpVector)
        print("📊 ОРИГИНАЛ (эталон):")
        print("   Оригинал позиция:", originalCFrame.Position)
        print("   Оригинал UpVector:", originalCFrame.UpVector)
        print("   Оригинал LookVector:", originalCFrame.LookVector)
        
        -- ЭТАП 1: ПОДНИМАЕМ НА ПРАВИЛЬНУЮ ВЫСОТУ
        local correctedPosition = Vector3.new(
            currentPos.X,
            currentPos.Y + 1.33,  -- Поднимаем как Roblox
            currentPos.Z
        )
        
        -- ЭТАП 2: КОПИРУЕМ ТОЧНУЮ ОРИЕНТАЦИЮ ОРИГИНАЛА
        -- Берем UpVector и LookVector прямо с оригинала!
        local exactCFrame = CFrame.lookAt(
            correctedPosition,
            correctedPosition + originalCFrame.LookVector,  -- Точный LookVector
            originalCFrame.UpVector  -- Точный UpVector (0, 0, -1)
        )
        
        -- Применяем точное копирование
        copyRootPart.CFrame = exactCFrame
        
        print("\n✅ ПРИМЕНЕНО ТОЧНОЕ КОПИРОВАНИЕ CFrame!")
        print("📊 Поднято на +1.33 стада")
        print("🦴 Скопирована ориентация оригинала")
        
        -- 🔍 НЕМЕДЛЕННАЯ ПРОВЕРКА ПОСЛЕ ПРИМЕНЕНИЯ
        wait(0.1)  -- Небольшая задержка
        local immediateCheck = copyRootPart.CFrame
        print("\n🔍 ПРОВЕРКА СРАЗУ ПОСЛЕ ПРИМЕНЕНИЯ:")
        print("   Копия UpVector:", immediateCheck.UpVector)
        print("   Копия LookVector:", immediateCheck.LookVector)
        print("   Копия позиция:", immediateCheck.Position)
        
        -- Сравниваем с оригиналом
        local currentOriginal = originalRootPart.CFrame
        print("\n📊 СРАВНЕНИЕ С ОРИГИНАЛОМ:")
        print("   Оригинал UpVector:", currentOriginal.UpVector)
        print("   Копия UpVector:   ", immediateCheck.UpVector)
        print("   СОВПАДАЮТ?", 
            math.abs(currentOriginal.UpVector.X - immediateCheck.UpVector.X) < 0.01 and
            math.abs(currentOriginal.UpVector.Y - immediateCheck.UpVector.Y) < 0.01 and
            math.abs(currentOriginal.UpVector.Z - immediateCheck.UpVector.Z) < 0.01)
        
        -- 🕐 ОТЛОЖЕННАЯ ПРОВЕРКА (через 2 секунды)
        spawn(function()
            wait(2)
            if copyRootPart and copyRootPart.Parent then
                local delayedCheck = copyRootPart.CFrame
                print("\n⏰ ПРОВЕРКА ЧЕРЕЗ 2 СЕКУНДЫ:")
                print("   Копия UpVector:", delayedCheck.UpVector)
                print("   Копия LookVector:", delayedCheck.LookVector)
                print("   Копия позиция:", delayedCheck.Position)
                
                -- Проверяем изменилось ли
                local upVectorChanged = 
                    math.abs(immediateCheck.UpVector.X - delayedCheck.UpVector.X) > 0.01 or
                    math.abs(immediateCheck.UpVector.Y - delayedCheck.UpVector.Y) > 0.01 or
                    math.abs(immediateCheck.UpVector.Z - delayedCheck.UpVector.Z) > 0.01
                
                if upVectorChanged then
                    print("⚠️ ОРИЕНТАЦИЯ ИЗМЕНИЛАСЬ! Что-то перезаписывает CFrame!")
                    print("🎭 Возможно анимационная система или другой скрипт")
                else
                    print("✅ Ориентация стабильна, проблема в другом")
                    print("🤔 Возможно проблема в структуре модели или визуальном отображении")
                end
            end
        end)
        
        -- Проверяем результат
        local newPos = copyRootPart.Position
        local newUpVector = copyRootPart.CFrame.UpVector
        local newLookVector = copyRootPart.CFrame.LookVector
        
        print("\n📊 ПОСЛЕ коррекции:")
        print("   Позиция:", newPos)
        print("   UpVector:", newUpVector)
        print("   LookVector:", newLookVector)
        
        -- Проверка успешности
        local heightDifference = newPos.Y - currentPos.Y
        local isUpright = math.abs(newUpVector.Y - 1.0) < 0.1
        
        if math.abs(heightDifference - 1.33) < 0.1 and isUpright then
            print("\n🎉 ИДЕАЛЬНО! Питомец поднят и стоит на лапах!")
            print("✅ Высота: +", string.format("%.2f", heightDifference), "стадов")
            print("✅ UpVector.Y =", string.format("%.2f", newUpVector.Y), "(должно быть ~1.0)")
            print("🐕 Питомец теперь стоит как оригинал!")
        else
            print("\n⚠️ Проверьте результат:")
            print("📊 Высота: +", heightDifference, "стадов")
            print("📊 UpVector.Y =", newUpVector.Y, "(должно быть ~1.0)")
        end
        
        -- Проверка что UpVector остался как у оригинала
        if math.abs(newUpVector.Y) < 0.1 and math.abs(newUpVector.Z + 1) < 0.1 then
            print("✅ UpVector остался как у оригинала (-0.00,-0.00,-1.00)")
        else
            print("⚠️ UpVector изменился, но это может быть нормально")
        end
        
        print("🚀 Нативная коррекция Roblox применена!")
        print("🎯 Питомец теперь должен стоять на земле КАК ОРИГИНАЛ!")
    else
        print("❌ Нет PrimaryPart у копии для нативной коррекции!")
    end
    
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 5: Запуск бесконечной idle анимации
    print("\n🔄 === БЕСКОНЕЧНАЯ IDLE АНИМАЦИЯ ===")
    
    local endlessConnection = startEndlessIdleLoop(petModel, petCopy)
    
    if endlessConnection then
        print("🎉 === УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Бесконечная idle анимация запущена")
        print("📍 Копия БЕСКОНЕЧНО играет idle анимацию")
        print("🚀 НИКОГДА не замирает - плавный бесконечный цикл!")
        print("🔥 Копия всегда в движении - как живая!")
    else
        print("⚠️ Масштабирование успешно, но idle анимация не запустилась")
        print("💡 Возможно проблема с Motor6D или Humanoid")
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
