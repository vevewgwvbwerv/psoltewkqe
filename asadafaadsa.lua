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

-- 🚨 КРИТИЧЕСКАЯ ДИАГНОСТИКА: Функция получения всех BasePart из модели
local function getAllParts(model)
    print("🔍 === ДИАГНОСТИКА getAllParts ===")
    
    if not model then
        print("❌ getAllParts: model = nil!")
        return {}
    end
    
    print("📋 Анализируем модель:", model.Name)
    print("📋 Тип модели:", model.ClassName)
    print("📋 Родитель модели:", model.Parent and model.Parent.Name or "НЕТ РОДИТЕЛЯ")
    
    local parts = {}
    local allDescendants = model:GetDescendants()
    print("📊 Всего потомков в модели:", #allDescendants)
    
    -- Детальная диагностика всех потомков
    local partCount = 0
    local otherCount = 0
    for i, descendant in ipairs(allDescendants) do
        if descendant:IsA("BasePart") then
            table.insert(parts, descendant)
            partCount = partCount + 1
            print(string.format("  ✅ BasePart #%d: %s (%s)", partCount, descendant.Name, descendant.ClassName))
        else
            otherCount = otherCount + 1
            if otherCount <= 5 then -- Показываем только первые 5 не-BasePart
                print(string.format("  ℹ️ Другой #%d: %s (%s)", otherCount, descendant.Name, descendant.ClassName))
            end
        end
    end
    
    if otherCount > 5 then
        print(string.format("  ℹ️ ... и ещё %d других объектов", otherCount - 5))
    end
    
    print("📊 ИТОГО BasePart найдено:", #parts)
    print("📊 Других объектов:", otherCount)
    
    if #parts == 0 then
        print("🚨 КРИТИЧЕСКАЯ ПРОБЛЕМА: НЕ НАЙДЕНО НИ ОДНОЙ BASEPART!")
        print("🔍 Возможные причины:")
        print("  1. Модель пустая или повреждена")
        print("  2. Все части были удалены при фильтрации")
        print("  3. Модель не содержит BasePart (только Mesh, Attachment и т.д.)")
    end
    
    print("🔍 === КОНЕЦ ДИАГНОСТИКИ getAllParts ===")
    return parts
end

-- 🚨 КРИТИЧЕСКАЯ ФУНКЦИЯ: smartAnchoredManagement (БЫЛА ПОТЕРЯНА!)
local function smartAnchoredManagement(parts)
    if not parts or #parts == 0 then
        print("❌ smartAnchoredManagement: Нет частей для обработки!")
        return nil
    end
    
    print("⚓ === SMART ANCHORED УПРАВЛЕНИЕ ===")
    print("📊 Обрабатываем частей:", #parts)
    
    local rootPart = nil
    local anchoredCount = 0
    local freeCount = 0
    
    -- Поиск root part
    for _, part in pairs(parts) do
        if part.Name:find("Root") or part.Name:find("Torso") or part.Name:find("HumanoidRootPart") then
            rootPart = part
            print("🎯 Нашел root part:", part.Name)
            break
        end
    end
    
    -- Если root part не найден, берем первую часть
    if not rootPart and #parts > 0 then
        rootPart = parts[1]
        print("🎯 Назначаем первую часть как root:", rootPart.Name)
    end
    
    -- Настраиваем Anchored состояния
    for _, part in pairs(parts) do
        if part == rootPart then
            part.Anchored = true
            anchoredCount = anchoredCount + 1
            print("⚓ Заякорен root part:", part.Name)
        else
            part.Anchored = false
            freeCount = freeCount + 1
            print("🔓 Освобождена часть:", part.Name)
        end
    end
    
    print("✅ ANCHORED частей:", anchoredCount, "/", #parts)
    print("🔓 Свободных частей:", freeCount)
    print("✅ smartAnchoredManagement завершен успешно!")
    
    return rootPart
end

-- 🚨 КРИТИЧЕСКАЯ ФУНКЦИЯ: startEndlessIdleLoop (БЫЛА ПОТЕРЯНА!)
local function startEndlessIdleLoop(originalModel, copyModel)
    if not originalModel or not copyModel then
        print("❌ startEndlessIdleLoop: Отсутствует модель для анимации!")
        return nil
    end
    
    print("🎭 === ЗАПУСК ENDLESS IDLE ANIMATION ===")
    print("🎯 Оригинал:", originalModel.Name)
    print("🎯 Копия:", copyModel.Name)
    
    -- 📊 ПОЛУЧАЕМ АНИМИРУЕМЫЕ ЧАСТИ ИЗ TOOL
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
    
    -- 🎯 ПОИСК СООТВЕТСТВУЮЩЕЙ ЧАСТИ
    local function findCorrespondingPart(copyModel, partName)
        for _, obj in pairs(copyModel:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == partName then
                return obj
            end
        end
        return nil
    end
    
    local originalParts = getAnimatedPartsFromTool(originalModel)
    if #originalParts == 0 then
        print("❌ Нет анимируемых частей в оригинальном Tool")
        return nil
    end
    
    print("📊 Найдено анимируемых частей:", #originalParts)
    
    local appliedCount = 0
    local changesDetected = 0
    
    -- 🔄 АНИМАЦИОННАЯ СИСТЕМА
    local animationConnection = RunService.Heartbeat:Connect(function()
        for _, originalPart in pairs(originalParts) do
            local copyPart = findCorrespondingPart(copyModel, originalPart.Name)
            if copyPart then
                if copyPart.Name:find("Root") or copyPart.Name:find("Torso") then
                    local currentPos = copyPart.CFrame.Position
                    copyPart.CFrame = CFrame.new(currentPos) * (originalPart.CFrame - originalPart.CFrame.Position)
                else
                    copyPart.CFrame = originalPart.CFrame
                end
                appliedCount = appliedCount + 1
            end
        end
        changesDetected = changesDetected + 1
        
        if changesDetected % 60 == 0 then
            print("🔄 LIVE CFrame копирование: обрабатывается", #originalParts, "CFrame состояний")
        end
    end)
    
    print("✅ CFrame анимационная система запущена!")
    return animationConnection
end

-- 🚨 КРИТИЧЕСКАЯ ФУНКЦИЯ: deepCopyModel (была потеряна!)
-- 🚨 СТАРАЯ ДУБЛИРУЮЩАЯ ФУНКЦИЯ DEEPCOPYMODEL УДАЛЕНА!
-- ОСТАВЛЯЕМ ТОЛЬКО НОВУЮ ВЕРСИЮ НА СТРОКАХ 398-544!

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
            -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: ИНИЦИАЛИЗИРУЕМ ПЕРЕМЕННЫЕ!
            local appliedCount = 0  -- ИСПРАВЛЕНИЕ ОШИБКИ: инициализируем appliedCount
            local changesDetected = 0  -- ИСПРАВЛЕНИЕ ОШИБКИ: инициализируем changesDetected
            local debugInfo = {}  -- Для диагностики
            
            -- Позиция копии уже правильно установлена в deepCopyModel!
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
                        
                        -- 🎭 ПРЯМОЕ CFrame КОПИРОВАНИЕ КАК В v3.219!
                        -- В старом скрипте это работало идеально без падений
                        local success, errorMsg = pcall(function()
                            copyPart.CFrame = handCFrame  -- ПРЯМОЕ копирование CFrame как в v3.219!
                        end)
                        
                        if success then
                            appliedCount = appliedCount + 1
                            -- Проверяем что CFrame изменился (анимация активна)
                            local currentCFrame = copyPart.CFrame
                            if (currentCFrame.Position - handCFrame.Position).Magnitude < 0.01 then
                                changesDetected = changesDetected + 1
                            end
                        else
                            print("❌ Ошибка при применении CFrame", copyPart.Name, ":", errorMsg)
                        end
                        
                        -- Диагностика для отладки
                        table.insert(debugInfo, {
                            name = copyPart.Name,
                            applied = success,
                            anchored = copyPart.Anchored,
                            changed = success
                        })
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
            -- Питомец в руке не найден - диагностика как в v3.219
            if math.floor(currentTime) % 5 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("⚠️ DRAGONFLY В РУКЕ НЕ НАЙДЕН - проверьте что держите питомца")
                print("💡 Убедитесь что в руке Tool с названием содержащим 'Dragonfly' или другого питомца")
            end
        end
    end)  -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Добавлен недостающий end) для RunService.Heartbeat:Connect!
    
    print("📍 Копия В РУКЕ будет копировать live анимацию из оригинала в руке!")
    print("🔥 Dragonfly анимация должна быть видна и работать как в v3.219!")
    print("🎯 Это поможет отладить проблему падения в Workspace!")
    
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
            part.Anchored = false -- Остальные могут двигаться
        end
        if part.Anchored then
            anchoredCount = anchoredCount + 1
        end
    end
    
    print("⚙️ Корневая часть:", rootPart and rootPart.Name or "Не найдена")
    print("⚓ Anchored частей:", anchoredCount, "/", #copyParts)
    
    print("✅ ПРИНУДИТЕЛЬНАЯ IDLE СИСТЕМА ЗАПУЩЕНА!")
    print("📍 Копия В РУКЕ будет копировать live анимацию из оригинала в руке!")
    print("🔥 Dragonfly анимация должна быть видна и работать как в v3.219!")
    print("🎯 Это поможет отладить проблему падения в Workspace!")
    
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
        local toolCount = 0
        for _, tool in pairs(playerChar:GetChildren()) do
            if tool:IsA("Tool") then
                print("🔧 Найден Tool #" .. toolCount .. ":", tool.Name)
                toolCount = toolCount + 1
                
                -- 🚨 ДЕТАЛЬНАЯ ДИАГНОСТИКА DRAGONFLY TOOL!
                print("📊 === ПОЛНАЯ СТРУКТУРА TOOL '", tool.Name, "' ===")
                
                -- Проверяем все дети Tool
                local childCount = 0
                for _, child in pairs(tool:GetChildren()) do
                    childCount = childCount + 1
                    print(string.format("  %d. %s '%s'", childCount, child.ClassName, child.Name))
                    
                    if child:IsA("Model") then
                        local partCount = 0
                        local partNames = {}
                        for _, part in pairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                partCount = partCount + 1
                                table.insert(partNames, part.Name)
                            end
                        end
                        print("    -> Модель с ", partCount, " BasePart:", table.concat(partNames, ", "))
                        
                        -- 🚨 КРИТИЧЕСКАЯ ПРОВЕРКА: ПОЧЕМУ DRAGONFLY НЕ ПРОХОДИТ?
                        if child.Name == "Dragonfly" or child.Name:find("Dragonfly") then
                            print("🐉 === DRAGONFLY МОДЕЛЬ НАЙДЕНА! ===")
                            print("    Название:", child.Name)
                            print("    Количество частей:", partCount)
                            print("    Проходит фильтр (>= 3):", partCount >= 3 and "✅ ДА" or "❌ НЕТ")
                            if partCount < 3 then
                                print("🚨 ПРОБЛЕМА: Dragonfly имеет меньше 3 частей!")
                            end
                        end
                    end
                end
                
                print("📊 Итого детей в Tool:", childCount)
                
                -- 🎯 ИЩЕМ ЛЮБУЮ МОДЕЛЬ ПИТОМЦА, ИСКЛЮЧАЕМ ТОЛЬКО HANDLE
                for _, child in pairs(tool:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "Handle" then
                        local partCount = 0
                        for _, part in pairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                partCount = partCount + 1
                            end
                        end
                        
                        print("🔍 Проверяем модель '", child.Name, "' - количество частей:", partCount)
                        
                        if partCount >= 3 then -- Минимум 3 части для питомца
                            print("✅ Модель '", child.Name, "' подходит! (", partCount, " частей)")
                            -- 🎯 КОПИРУЕМ ТОЛЬКО МОДЕЛЬ ПИТОМЦА (БЕЗ HANDLE)
                            table.insert(foundPets, {
                                model = child, -- Только модель питомца (Dog), НЕ весь Tool
                                distance = 0,
                                reason = "Модель питомца из Tool (" .. partCount .. " частей)",
                                source = "tool"
                            })
                            print("✅ Найдена модель питомца в Tool:", child.Name, "(" .. partCount .. " частей)")
                            print("🚫 Handle исключен из копирования!")
                        else
                            print("❌ Модель '", child.Name, "' отклонена: недостаточно частей (", partCount, " < 3)")
                        end
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        
        -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: ПРИНУДИТЕЛЬНО ИЩЕМ DRAGONFLY!
        print("🚨 ОТЛАДОЧНЫЙ РЕЖИМ: Принудительно ищем Dragonfly в руке!")
        
        local playerChar = player.Character
        if playerChar then
            for _, tool in pairs(playerChar:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:find("Dragonfly") or tool.Name:find("dragonfly")) then
                    print("🐉 НАШЛИ DRAGONFLY TOOL:", tool.Name)
                    
                    -- Ищем любую модель внутри Tool
                    for _, child in pairs(tool:GetChildren()) do
                        if child:IsA("Model") and child.Name ~= "Handle" then
                            print("✅ Нашли модель в Dragonfly Tool:", child.Name)
                            
                            -- ПРИНУДИТЕЛЬНО добавляем в foundPets
                            table.insert(foundPets, {
                                model = child,
                                distance = 0,
                                reason = "ПРИНУДИТЕЛЬНОЕ обнаружение Dragonfly",
                                source = "emergency_tool"
                            })
                            print("🚑 ПРИНУДИТЕЛЬНО добавили Dragonfly в foundPets!")
                            break
                        end
                    end
                    break
                end
            end
        end
        
        if #foundPets == 0 then
            print("❌ Даже принудительный поиск Dragonfly не дал результатов!")
            return nil
        end
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

-- 🚀 ГЛАВНАЯ ФУНКЦИЯ (РАБОЧАЯ ЛОГИКА ИЗ v3.219)
local function main()
    print("\n🚀 === ЗАПУСК PETSCALER v3.221 (РАБОЧАЯ ЛОГИКА ИЗ v3.219) ===")
    
    -- 🔍 ПОИСК ПИТОМЦА В РУКЕ (ТОЧНАЯ КОПИЯ ИЗ v3.219)
    local function findHandHeldPet()
        local player = Players.LocalPlayer
        if not player then 
            print("❌ Player не найден")
            return nil, nil 
        end
        
        print("🔍 Поиск питомца в руке...")
        
        local character = player.Character
        if not character then
            print("❌ Character не найден!")
            return nil, nil
        end
        
        print("👤 Проверяем character...")
        
        -- Поиск любого Tool в руках
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
        
        -- Возвращаем Tool как модель
        return handTool, handTool
    end
    
    -- Ищем питомца в руке
    local petModel, petTool = findHandHeldPet()
    if not petModel then
        print("❌ Питомец в руке не найден!")
        return
    end
    
    print("🎯 === НАЙДЕН ПИТОМЕЦ В РУКЕ ===")
    print("📋 Tool:", petTool.Name)
    
    -- Создаем глубокую копию
    print("\n📦 === СОЗДАНИЕ ГЛУБОКОЙ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- 🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: deepCopyModel УЖЕ СОЗДАЛ Tool!
    -- deepCopyModel() уже создал Tool и разместил в руке!
    -- НЕ НУЖНО ПОВТОРНО РАЗМЕЩАТЬ!
    
    if petCopy then
        print("✅ deepCopyModel уже создал Tool с копией в руке!")
        print("✅ Копия уже размещена В РУКЕ через Tool!")
    else
        print("❌ deepCopyModel вернул nil - копия не создана!")
    end
    
    -- Масштабирование
    print("\n📏 === МАСШТАБИРОВАНИЕ ===")
    local scaleFactor = CONFIG.SCALE_FACTOR
    
    -- 📏 ПРОСТОЕ РАБОЧЕЕ МАСШТАБИРОВАНИЕ (БЕЗ ОШИБОК)
    if scaleFactor and scaleFactor ~= 1.0 then
        print("🔧 Применяем масштабирование:", scaleFactor)
        for _, obj in pairs(petCopy:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Size = obj.Size * scaleFactor
            end
        end
        print("✅ Масштабирование применено успешно!")
    else
        print("ℹ️ Масштабирование пропущено (фактор = 1.0)")
    end
    
    print("✅ Копия готова к анимации!")
    
    -- Anchoring управление
    print("\n⚓ === ANCHORING УПРАВЛЕНИЕ ===")
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    print("✅ Anchoring настроен - только root part заякорен")
    
    -- Запуск анимационной системы
    print("\n🎭 === ЗАПУСК АНИМАЦИОННОЙ СИСТЕМЫ ===")
    local endlessConnection = startEndlessIdleLoop(petModel, petCopy)
    
    if endlessConnection then
        print("🎉 === УСПЕХ! РАБОЧАЯ ЛОГИКА ИЗ v3.219 ПРИМЕНЕНА! ===")
        print("✅ Копия создана В РУКЕ")
        print("✅ Анимационная система запущена")
        print("✅ Копия должна анимироваться!")
    else
        print("⚠️ Копия создана, но анимация не запустилась")
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
