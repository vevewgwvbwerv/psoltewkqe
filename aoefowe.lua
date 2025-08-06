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

-- Функция получения всех BasePart из модели
local function getAllParts(model)
    local parts = {}
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(parts, descendant)
        end
    end
    return parts
end

-- 🚨 КРИТИЧЕСКАЯ ФУНКЦИЯ: deepCopyModel (была потеряна!)
local function deepCopyModel(originalModel)
    if not originalModel or not originalModel.Parent then
        print("❌ deepCopyModel: Оригинальная модель недействительна")
        return nil
    end
    
    print("🔄 Создаю глубокую копию модели:", originalModel.Name)
    
    -- Клонируем модель
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    print("✅ Копия создана:", copy.Name)
    
    -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Удаляем Handle и серые квадраты
    local removedParts = {}
    for _, part in ipairs(copy:GetDescendants()) do
        if part:IsA("BasePart") then
            local shouldRemove = false
            local reason = ""
            
            -- Проверяем по имени (Handle)
            if part.Name == "Handle" then
                shouldRemove = true
                reason = "Handle"
            -- Проверяем по форме и материалу (серые квадраты) - с проверкой наличия Shape
            elseif part:IsA("Part") and part.Shape == Enum.PartType.Block and part.Material == Enum.Material.Plastic then
                shouldRemove = true
                reason = "серый квадрат (Block+Plastic)"
            -- Проверяем по цвету (любые серые оттенки)
            elseif part.BrickColor.Name:find("[Gg]rey") or part.BrickColor.Name:find("[Gg]ray") then
                shouldRemove = true
                reason = "серый цвет"
            -- Проверяем по размеру (подозрительно большие части)
            elseif part.Size.Magnitude > 50 then
                shouldRemove = true
                reason = "слишком большой размер"
            end
            
            if shouldRemove then
                table.insert(removedParts, {name = part.Name, reason = reason})
                part:Destroy()
            end
        end
    end
    
    -- Логируем удаленные части
    if #removedParts > 0 then
        print("🗑️ Удалено", #removedParts, "нежелательных частей:")
        for _, removed in ipairs(removedParts) do
            print("  -", removed.name, "(", removed.reason, ")")
        end
    end
    
    -- Убеждаемся что у копии есть PrimaryPart
    if not copy.PrimaryPart then
        for _, part in ipairs(copy:GetChildren()) do
            if part:IsA("BasePart") then
                copy.PrimaryPart = part
                print("📍 Установлен PrimaryPart:", part.Name)
                break
            end
        end
    end
    
    -- 🚨 КРИТИЧЕСКОЕ ПОЗИЦИОНИРОВАНИЕ: Размещаем копию рядом с оригиналом
    if originalModel.PrimaryPart and copy.PrimaryPart then
        local originalPos = originalModel.PrimaryPart.Position
        local offset = Vector3.new(10, 5, 0)  -- Рядом с оригиналом, выше земли
        
        -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: ПРОСТОЕ ПОЗИЦИОНИРОВАНИЕ БЕЗ RAYCAST!
        -- Raycast может давать неправильные результаты. Просто размещаем копию рядом с оригиналом!
        
        -- Простое и надёжное позиционирование
        local safeY = math.max(originalPos.Y + 2, 10)  -- Минимум Y=10, никогда не под землёй!
        local finalPosition = Vector3.new(
            originalPos.X + offset.X,  -- Рядом по X
            safeY,                     -- Безопасная высота
            originalPos.Z + offset.Z   -- Рядом по Z
        )
        
        print("🚨 Оригинальная позиция:", originalPos)
        print("📍 Безопасная позиция копии:", finalPosition)
        
        -- Проверяем что Y координата положительная
        if finalPosition.Y < 0 then
            print("❌ КРИТИЧЕСКАЯ ОШИБКА: Отрицательная Y координата!")
            finalPosition = Vector3.new(finalPosition.X, 15, finalPosition.Z)  -- Принудительно выше земли
        end
        
        copy:SetPrimaryPartCFrame(CFrame.new(finalPosition))
    end
    
    -- Настройка Anchored состояния
    for _, part in ipairs(copy:GetDescendants()) do
        if part:IsA("BasePart") then
            if part == copy.PrimaryPart then
                part.Anchored = true  -- Только корневая часть заанкорена
            else
                part.Anchored = false  -- Остальные части свободны для анимации
            end
        end
    end
    
    print("✅ deepCopyModel завершена успешно")
    return copy
end

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

-- Функция глубокого копирования модели (БЕЗ HANDLE И СЕРЫХ КВАДРАТОВ)
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: УДАЛЯЕМ HANDLE И ВСЕ СЕРЫЕ КВАДРАТЫ
    local removedParts = 0
    local partsToRemove = {}
    
    for _, part in pairs(copy:GetDescendants()) do
        if part:IsA("BasePart") then
            local shouldRemove = false
            local reason = ""
            
            -- Проверяем по имени
            if part.Name == "Handle" then
                shouldRemove = true
                reason = "Handle"
            -- Проверяем по форме и материалу (серые квадраты) - с проверкой наличия Shape
            elseif part:IsA("Part") and part.Shape == Enum.PartType.Block and part.Material == Enum.Material.Plastic then
                shouldRemove = true
                reason = "серый квадрат (Block+Plastic)"
            -- Проверяем по цвету (любые серые оттенки)
            elseif part.BrickColor.Name:find("[Gg]rey") or part.BrickColor.Name:find("[Gg]ray") then
                shouldRemove = true
                reason = "серый цвет (" .. part.BrickColor.Name .. ")"
            -- Проверяем по размеру (большие квадраты которые могут быть Handle)
            elseif part.Size.X > 4 and part.Size.Y > 4 and part.Size.Z > 4 and part.Shape == Enum.PartType.Block then
                shouldRemove = true
                reason = "большой квадрат (" .. part.Size.X .. "x" .. part.Size.Y .. "x" .. part.Size.Z .. ")"
            end
            
            if shouldRemove then
                table.insert(partsToRemove, {part = part, reason = reason})
            end
        end
    end
    
    -- Удаляем все найденные нежелательные части
    for _, item in pairs(partsToRemove) do
        print("🚨 Удаляю:", item.part.Name, "(причина:", item.reason, ")")
        item.part:Destroy()
        removedParts = removedParts + 1
    end
    
    if removedParts > 0 then
        print("✅ Удалено серых квадратов:", removedParts)
    else
        print("💬 Серые квадраты не найдены")
    end
    
    -- 🔧 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: УСТАНАВЛИВАЕМ PrimaryPart ПОСЛЕ УДАЛЕНИЯ ЧАСТЕЙ
    if not copy.PrimaryPart then
        -- Ищем подходящую часть для PrimaryPart
        local rootCandidates = {"RootPart", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
        for _, candidateName in ipairs(rootCandidates) do
            local candidate = copy:FindFirstChild(candidateName)
            if candidate and candidate:IsA("BasePart") then
                copy.PrimaryPart = candidate
                print("🔧 Установлен PrimaryPart:", candidate.Name)
                break
            end
        end
        
        -- Если не нашли кандидатов, берем первую доступную часть
        if not copy.PrimaryPart then
            for _, part in pairs(copy:GetDescendants()) do
                if part:IsA("BasePart") then
                    copy.PrimaryPart = part
                    print("🔧 Установлен PrimaryPart (запасной):", part.Name)
                    break
                end
            end
        end
    end
    
    -- 🙈 СКРЫВАЕМ КОПИЮ ВО ВРЕМЯ СОЗДАНИЯ И МАСШТАБИРОВАНИЯ
    for _, part in pairs(copy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1  -- Делаем невидимой
        end
    end
    print("🙈 Копия скрыта во время создания")
    
    -- 📍 УЛУЧШЕННОЕ ПОЗИЦИОНИРОВАНИЕ КОПИИ (РЯДОМ С ОРИГИНАЛОМ)
    if copy.PrimaryPart and originalModel.PrimaryPart then
        local originalCFrame = originalModel.PrimaryPart.CFrame
        local offset = Vector3.new(10, 5, 0)  -- Увеличиваем Y-смещение чтобы копия не падала под карту
        
        local targetPosition = originalCFrame.Position + offset
        print("📍 Целевая позиция копии:", targetPosition)
        print("📍 Оригинал находится в:", originalCFrame.Position)
        
        -- 🔍 УЛУЧШЕННЫЙ RAYCAST ДЛЯ ПОИСКА ЗЕМЛИ
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {copy, originalModel, player.Character}
        
        -- Начинаем raycast с большой высоты чтобы точно найти землю
        local rayOrigin = Vector3.new(targetPosition.X, targetPosition.Y + 200, targetPosition.Z)
        local rayDirection = Vector3.new(0, -400, 0)  -- Увеличиваем дальность raycast
        
        print("🔍 Raycast от:", rayOrigin, "в направлении:", rayDirection)
        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if raycastResult then
            local groundY = raycastResult.Position.Y + 2  -- Поднимаем на 2 стада над землей
            local finalPosition = Vector3.new(targetPosition.X, groundY, targetPosition.Z)
            
            print("✅ Найдена земля на высоте:", raycastResult.Position.Y)
            print("📍 Конечная позиция копии:", finalPosition)
            
            -- Правильная ориентация (стоячее положение)
            local upVector = Vector3.new(0, 1, 0) -- Строго вверх
            local lookVector = originalCFrame.LookVector
            -- Обнуляем Y-компонент чтобы питомец не наклонялся
            lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            local newCFrame = CFrame.lookAt(finalPosition, finalPosition + lookVector, upVector)
            
            copy:SetPrimaryPartCFrame(newCFrame)
            print("✅ Копия успешно размещена на земле рядом с оригиналом!")
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

-- LIVE CFRAME ANIMATION SYSTEM (CLEAN VERSION)
local function startEndlessIdleLoop(originalModel, copyModel)
    print("\n🔄 === LIVE CFRAME ANIMATION SYSTEM ===\n")
    
    -- 🎭 CFrame анимационная система
    local handPetModel = nil
    local handPetParts = {}  -- Анимируемые части из Tool
    local lastHandPetCheck = 0
    local HAND_PET_CHECK_INTERVAL = 1.0  -- Интервал поиска питомца в руке
    
    -- 📍 ФИКСИРОВАННАЯ ПОЗИЦИЯ КОПИИ
    local copyFixedPosition = nil
    local copyPositionSet = false
    
    -- 🔧 Конфигурация CFrame системы
    local INTERPOLATION_SPEED = 0.3
    
    print("📡 ЗАПУСКАЮ LIVE CFRAME АНИМАЦИЮ!")
    print("🎬 Копирование в реальном времени с питомца в руке")
    print("🔄 Копия будет повторять ВСЕ движения!")
    
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
            -- Поиск питомца в руке
            local foundPetModel = nil
            local foundTool = nil
            
            local playerChar = player.Character
            if playerChar then
                for _, tool in pairs(playerChar:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, child in pairs(tool:GetDescendants()) do
                            if child:IsA("Model") and child.Name ~= "Handle" then
                                local parts = {}
                                for _, part in ipairs(child:GetDescendants()) do
                                    if part:IsA("BasePart") and part.Name ~= "Handle" then
                                        table.insert(parts, part)
                                    end
                                end
                                if #parts > 3 then
                                    foundPetModel = child
                                    foundTool = tool
                                    break
                                end
                            end
                        end
                        if foundPetModel then break end
                    end
                end
            end
            
            if foundPetModel ~= handPetModel then
                handPetModel = foundPetModel
                -- Получаем анимируемые части
                handPetParts = {}
                if handPetModel then
                    for _, part in ipairs(handPetModel:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "Handle" then
                            table.insert(handPetParts, part)
                        end
                    end
                end
                
                if handPetModel then
                    print("🎯 НАШЛИ ПИТОМЦА В РУКЕ:", foundTool and foundTool.Name or "Неизвестный")
                    print("📦 Анимируемых частей:", #handPetParts)
                else
                    print("⚠️ Питомец в руке не найден")
                    handPetParts = {}
                end
            end
            
            lastHandPetCheck = currentTime
        end
        
        -- Применяем CFrame анимацию если есть питомец в руке
        if handPetModel and #handPetParts > 0 then
            -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: НЕ ПЕРЕЗАПИСЫВАЕМ ПОЗИЦИЮ!
            -- Позиция копии уже правильно установлена в deepCopyModel!
            -- Только запоминаем позицию для анимации, НО НЕ МЕНЯЕМ ЕЁ!
            if not copyPositionSet and copyModel and copyModel.PrimaryPart then
                copyFixedPosition = copyModel.PrimaryPart.Position  -- Используем ТЕКУЩУЮ позицию копии
                copyPositionSet = true
                print("📍 Запомнил текущую позицию копии для анимации:", copyFixedPosition)
            end
            
            -- Применяем CFrame анимацию ко всем частям
            for _, handPart in ipairs(handPetParts) do
                if handPart and handPart.Parent then
                    -- Находим соответствующую часть в копии
                    local copyPart = nil
                    for _, part in ipairs(copyModel:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name == handPart.Name then
                            copyPart = part
                            break
                        end
                    end
                    
                    if copyPart and copyPart.Parent and not copyPart.Anchored then
                        local handCFrame = handPart.CFrame
                        
                        -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: НЕ ПЕРЕМЕЩАЕМ КОРНЕВЫЕ ЧАСТИ!
                        local isRootPart = (copyPart.Name == "RootPart" or copyPart.Name == "Torso" or copyPart.Name == "HumanoidRootPart")
                        
                        if isRootPart then
                            -- Корневые части ОСТАЮТСЯ НА МЕСТЕ! Только копируем поворот
                            local currentPos = copyPart.Position  -- Сохраняем текущую позицию
                            local rotationOnly = handCFrame - handCFrame.Position  -- Только поворот
                            local newCFrame = CFrame.new(currentPos) * rotationOnly
                            copyPart.CFrame = copyPart.CFrame:Lerp(newCFrame, INTERPOLATION_SPEED)
                        else
                            -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: НЕ ПЕРЕМЕЩАЕМ ОБЫЧНЫЕ ЧАСТИ!
                            -- Обычные части тоже ОСТАЮТСЯ НА МЕСТЕ! Только копируем поворот!
                            local currentPos = copyPart.Position  -- Сохраняем текущую позицию
                            local rotationOnly = handCFrame - handCFrame.Position  -- Только поворот
                            local newCFrame = CFrame.new(currentPos) * rotationOnly
                            copyPart.CFrame = copyPart.CFrame:Lerp(newCFrame, INTERPOLATION_SPEED)
                            
                            -- Логируем что позиция НЕ изменилась
                            if math.abs(copyPart.Position.Y - currentPos.Y) > 0.1 then
                                print("❌ ПРЕДУПРЕЖДЕНИЕ: Часть", copyPart.Name, "изменила Y позицию!")
                                print("  Было:", currentPos.Y, "Стало:", copyPart.Position.Y)
                            end
                        end
                    end
                end
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
                print("📐 LIVE CFrame КОПИРОВАНИЕ: обрабатывается", #handPetParts, "CFrame состояний")
                print(string.format("🔍 СОСТОЯНИЕ КОПИИ: %d/%d частей валидны, %d заякорено", validCopyParts, copyPartsCount, anchoredParts))
                print("🎭 ПИТОМЕЦ В РУКЕ: CFrame анимация активна")
                
                -- 🚨 ПРЕДУПРЕЖДЕНИЕ О ПОТЕРЕ ЧАСТЕЙ
                if validCopyParts < copyPartsCount * 0.8 then
                    print(string.format("🚨 ВНИМАНИЕ: Копия теряет части! %d из %d частей потеряны!", 
                        copyPartsCount - validCopyParts, copyPartsCount))
                end
            end
        else
            -- Питомец в руке не найден - используем стандартную idle позу
            if math.floor(currentTime) % 5 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("⚠️ Питомец в руке не найден - копия в статичной позе")
            end
        end
    end)
    
    return connection
end

-- === ОСНОВНЫЕ ФУНКЦИИ ===

-- КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Проверяем Anchored состояния
local function smartAnchoredManagement(copyParts)
    print("🔍 ПРОВЕРКА ANCHORED СОСТОЯНИЙ КОПИИ:")
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
    print("🔍 Поиск ТОЛЬКО ТВОИХ питомцев (рядом + в руке)...")
    
    local foundPets = {}
    
    -- 🔍 ПОИСК 1: ПИТОМЦЫ РЯДОМ С ИГРОКОМ (в малом радиусе)
    print("📍 Поиск питомцев рядом с тобой...")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= 50 then -- МАЛЫЙ радиус - только рядом с тобой
                    
                    -- 🔒 ФИЛЬТРЫ ДЛЯ ТВОИХ ПИТОМЦЕВ (НЕ ЧУЖИХ!)
                    local isPet = false
                    local reason = ""
                    
                    -- Фильтр 1: Проверяем что это НЕ питомец другого игрока
                    local isNearOtherPlayer = false
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local otherPlayerPos = otherPlayer.Character.HumanoidRootPart.Position
                            local distanceToOtherPlayer = (modelCFrame.Position - otherPlayerPos).Magnitude
                            if distanceToOtherPlayer < 30 then -- Если питомец рядом с другим игроком
                                isNearOtherPlayer = true
                                break
                            end
                        end
                    end
                    
                    if not isNearOtherPlayer then
                        -- Продолжаем только если это НЕ питомец другого игрока
                    
                    -- 🎯 ТОЛЬКО UUID В ИМЕНИ - НИКАКИХ ДРУГИХ КРИТЕРИЕВ!
                    if obj.Name:find("%{") and obj.Name:find("%}") then
                        isPet = true
                        reason = "UUID в имени"
                        print("🔍 Найден питомец с UUID:", obj.Name)
                    else
                        isPet = false
                        reason = "Нет UUID"
                    end
                    
                    if isPet then
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance,
                            reason = reason,
                            source = "workspace"
                        })
                        print("✅ Найден питомец в Workspace:", obj.Name, "(причина:", reason, ")")
                    end
                    
                    end -- Закрываем блок if not isNearOtherPlayer then
                end
            end
        end
    end
    
    -- 🔍 ПОИСК 2: ПИТОМЕЦ В РУКЕ (Tool)
    print("🎒 Поиск питомца в твоей руке...")
    
    if playerChar then
        -- Поиск Tool в руках
        for _, tool in pairs(playerChar:GetChildren()) do
            if tool:IsA("Tool") then
                -- 🎯 ИЩЕМ ЛЮБУЮ МОДЕЛЬ ПИТОМЦА, ИСКЛЮЧАЕМ ТОЛЬКО HANDLE
                for _, child in pairs(tool:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "Handle" then
                        local partCount = 0
                        for _, part in pairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                partCount = partCount + 1
                            end
                        end
                        
                        if partCount >= 3 then -- Минимум 3 части для питомца
                            -- 🎯 КОПИРУЕМ ТОЛЬКО МОДЕЛЬ ПИТОМЦА (БЕЗ HANDLE)
                            table.insert(foundPets, {
                                model = child, -- Только модель питомца (Dog), НЕ весь Tool
                                distance = 0,
                                reason = "Модель питомца из Tool (" .. partCount .. " частей)",
                                source = "tool"
                            })
                            print("✅ Найдена модель питомца в Tool:", child.Name, "(" .. partCount .. " частей)")
                            print("🚫 Handle исключен из копирования!")
                        end
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        return nil
    end
    
    -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: ПРИОРИТЕТ WORKSPACE ПИТОМЦАМ!
    -- Копия должна появляться рядом с оригинальным питомцем в Workspace!
    local targetPet = nil
    
    -- 1. ПРИОРИТЕТ 1: Питомец в Workspace (НЕ в руке!)
    for _, pet in pairs(foundPets) do
        if pet.source == "workspace" and pet.reason:find("UUID") then
            targetPet = pet
            print("🎯 Выбран питомец с UUID в Workspace (приоритет 1):", pet.model.Name)
            break
        end
    end
    
    -- 2. ПРИОРИТЕТ 2: Любой питомец в Workspace (не Egg)
    if not targetPet then
        for _, pet in pairs(foundPets) do
            if pet.source == "workspace" and not pet.model.Name:find("Egg") and not pet.model.Name:find("egg") then
                targetPet = pet
                print("🎯 Выбран обычный питомец в Workspace (приоритет 2):", pet.model.Name)
                break
            end
        end
    end
    
    -- 3. ПРИОРИТЕТ 3: Питомец в руке (ТОЛЬКО ЕСЛИ НЕТ В Workspace!)
    if not targetPet then
        for _, pet in pairs(foundPets) do
            if pet.source == "tool" then
                targetPet = pet
                print("⚠️ Выбран питомец в руке (приоритет 3 - крайний случай):", pet.model.Name)
                print("🚨 ПРЕДУПРЕЖДЕНИЕ: Копия может появиться в руке!")
                break
            end
        end
    end
    
    -- 3. Приоритет 3: Любой остальной питомец (не Egg)
    if not targetPet then
        for _, pet in pairs(foundPets) do
            if not pet.model.Name:find("Egg") and not pet.model.Name:find("egg") then
                targetPet = pet
                print("🎯 Выбран обычный питомец (приоритет 3):", pet.model.Name)
                break
            end
        end
    end
    
    -- 4. Крайний случай: Любой объект
    if not targetPet then
        targetPet = foundPets[1]
        print("🎯 Выбран по умолчанию (приоритет 4):", targetPet.model.Name)
    end
    
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
    
    -- 👁️ ПОКАЗЫВАЕМ КОПИЮ ПЕРЕД ЗАПУСКОМ АНИМАЦИИ
    print("👁️ Показываем готовую копию...")
    for _, part in pairs(petCopy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0  -- Делаем видимой
        end
    end
    
    -- Шаг 5: ЗАПУСК БЕСКОНЕЧНОЙ IDLE АНИМАЦИИ
    print("\n🎭 === ЗАПУСК БЕСКОНЕЧНОЙ IDLE АНИМАЦИИ ===")
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
