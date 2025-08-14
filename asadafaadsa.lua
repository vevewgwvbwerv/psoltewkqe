-- 🔥 PET SCALER v2.0 - Масштабирование с анимацией + АВТОЗАМЕНА
-- Объединяет оригинальный PetScaler + SmartMotorCopier + EggPetReplacer
-- Создает масштабированную копию И сразу включает анимацию
-- НОВОЕ: Автоматически заменяет питомцев из workspace.visuals на анимированные копии

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v2.0 - С АНИМАЦИЕЙ ===")
print("=" .. string.rep("=", 60))

-- Конфигурация (ОСНОВАНА НА ДИАГНОСТИКЕ ОРИГИНАЛЬНОЙ ИГРЫ)
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 1.184,   -- Точный коэффициент из диагностики!
    TWEEN_TIME = 3.2,       -- Время как в оригинале (3.22 сек)
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out
}

-- Получаем позицию игрока
local playerChar = player.Character
if not playerChar then
    print("❌ Персонаж игрока не найден!")
    return
end

-- Удаляет все связи Handle со старыми объектами, кроме сварки с копией
local function cleanHandleConstraintsExceptCopy(handle, copyPrimaryPart)
    if not handle then return end
    for _, obj in ipairs(handle:GetDescendants()) do
        if obj:IsA("Constraint") or obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
            local p0 = obj.Part0 or obj.Attachment0 and obj.Attachment0.Parent
            local p1 = obj.Part1 or obj.Attachment1 and obj.Attachment1.Parent
            local keep = (copyPrimaryPart and (p0 == copyPrimaryPart or p1 == copyPrimaryPart))
            if not keep then
                obj:Destroy()
            end
        end
    end
end

local hrp = playerChar:FindFirstChild("HumanoidRootPart")
if not hrp then
    print("❌ HumanoidRootPart не найден!")
    return
end

local playerPos = hrp.Position
print("📍 Позиция игрока:", playerPos)
print("🎯 Радиус поиска:", CONFIG.SEARCH_RADIUS)
print("📐 Масштабирование:", CONFIG.SCALE_FACTOR .. "x (как в оригинальной игре)")
print("⏱️ Время анимации:", CONFIG.TWEEN_TIME .. " сек")
print()

-- === ФУНКЦИИ ИЗ ОРИГИНАЛЬНОГО PETSCALER ===

-- Функция проверки визуальных элементов питомца (УЛУЧШЕННАЯ ВЕРСИЯ)
local function hasPetVisuals(model)
    local visualCount = 0
    local petVisuals = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        local visualData = nil
        
        -- Проверяем MeshPart (оригинальная логика)
        if obj:IsA("MeshPart") then
            visualCount = visualCount + 1
            visualData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or "",
                type = "MeshPart"
            }
        
        -- Проверяем SpecialMesh (оригинальная логика)
        elseif obj:IsA("SpecialMesh") then
            visualCount = visualCount + 1
            visualData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or "",
                textureId = obj.TextureId or "",
                type = "SpecialMesh"
            }
        
        -- НОВОЕ: Проверяем обычные Part с текстурами/декалями
        elseif obj:IsA("Part") then
            -- Ищем Decal или Texture на Part
            local hasDecal = obj:FindFirstChildOfClass("Decal")
            local hasTexture = obj:FindFirstChildOfClass("Texture")
            
            if hasDecal or hasTexture or obj.Material ~= Enum.Material.Plastic then
                visualCount = visualCount + 1
                visualData = {
                    name = obj.Name,
                    className = obj.ClassName,
                    material = obj.Material.Name,
                    hasDecal = hasDecal ~= nil,
                    hasTexture = hasTexture ~= nil,
                    type = "Part"
                }
            end
        
        -- НОВОЕ: Проверяем UnionOperation (объединенные части)
        elseif obj:IsA("UnionOperation") then
            visualCount = visualCount + 1
            visualData = {
                name = obj.Name,
                className = obj.ClassName,
                type = "UnionOperation"
            }
        
        -- НОВОЕ: Проверяем Attachment с эффектами
        elseif obj:IsA("Attachment") then
            local hasEffect = #obj:GetChildren() > 0
            if hasEffect then
                visualCount = visualCount + 1
                visualData = {
                    name = obj.Name,
                    className = obj.ClassName,
                    effectCount = #obj:GetChildren(),
                    type = "Attachment"
                }
            end
        end
        
        -- Добавляем найденные визуальные элементы
        if visualData then
            table.insert(petVisuals, visualData)
        end
    end
    
    -- Дополнительная проверка: если модель содержит BasePart'ы, считаем её потенциальным питомцем
    if visualCount == 0 then
        local partCount = 0
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                partCount = partCount + 1
            end
        end
        
        -- Если есть несколько частей, вероятно это питомец
        if partCount >= 2 then
            visualCount = partCount
            table.insert(petVisuals, {
                name = "BaseParts",
                className = "Multiple",
                partCount = partCount,
                type = "BasePart"
            })
            print("  🔍 Найден потенциальный питомец с " .. partCount .. " частями: " .. model.Name)
        end
    end
    
    return visualCount > 0, petVisuals
end

-- Функция глубокого копирования модели (ОРИГИНАЛЬНАЯ ВЕРСИЯ + ЗАЩИТА)
local function deepCopyModel(originalModel)
    -- Проверяем входные параметры
    if not originalModel then
        print("❌ deepCopyModel: Оригинальная модель = nil!")
        return nil
    end
    
    if not originalModel.Parent then
        print("❌ deepCopyModel: Оригинальная модель не в Workspace!")
        return nil
    end
    
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = nil
    local success, errorMsg = pcall(function()
        copy = originalModel:Clone()
    end)
    
    if not success or not copy then
        print("❌ Ошибка при клонировании:", errorMsg or "Неизвестная ошибка")
        return nil
    end
    
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
            local newCFrame = CFrame.new(finalPosition, originalCFrame.LookVector)
            copy:PivotTo(newCFrame)
            print("📍 Копия размещена на земле")
        else
            local newCFrame = originalCFrame + offset
            copy:PivotTo(newCFrame)
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
    
    -- ВАЖНО: НЕ устанавливаем Anchored здесь - это сделает SmartAnchoredManagement
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- === ФУНКЦИИ ИЗ SMARTMOTORCOPIER ===

-- Функция получения всех BasePart из модели
local function getAllParts(model)
    local parts = {}
    
    if not model then
        print("⚠️ getAllParts: модель = nil")
        return parts
    end
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- Функция умного управления Anchored (из SmartMotorCopier)
local function smartAnchoredManagement(copyParts)
    if not copyParts or #copyParts == 0 then
        print("⚠️ smartAnchoredManagement: нет частей")
        return nil
    end
    
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
    
    -- Применяем умный Anchored (КЛЮЧЕВОЕ ИЗМЕНЕНИЕ ДЛЯ ПРЕДОТВРАЩЕНИЯ ПАДЕНИЯ!)
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            part.Anchored = true -- Только корень заякорен - это предотвращает падение!
        else
            part.Anchored = false -- Остальные могут двигаться
        end
    end
    
    print("  ✅ Anchored настроен: корень заякорен, остальные свободны")
    return rootPart
end

-- Функция получения всех Motor6D из модели
local function getMotor6Ds(model)
    local motors = {}
    
    if not model then
        print("⚠️ getMotor6Ds: модель = nil")
        return motors
    end
    
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

-- Функция копирования состояния Motor6D
local function copyMotorState(originalMotor, copyMotor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    copyMotor.Transform = originalMotor.Transform
    copyMotor.C0 = originalMotor.C0
    copyMotor.C1 = originalMotor.C1
    
    return true
end

-- Функция запуска живого копирования Motor6D
local function startLiveMotorCopying(original, copy)
    if not original or not copy then
        print("⚠️ startLiveMotorCopying: одна из моделей = nil")
        return nil
    end
    
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
    print("💡 Копия будет повторять движения оригинала")
    
    return connection
end

-- === ФУНКЦИИ ИЗ SMARTMOTORCOPIER ===

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

-- Функция копирования состояния Motor6D
local function copyMotorState(originalMotor, copyMotor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    copyMotor.Transform = originalMotor.Transform
    copyMotor.C0 = originalMotor.C0
    copyMotor.C1 = originalMotor.C1
    
    return true
end

-- === ФУНКЦИИ МАСШТАБИРОВАНИЯ (ОРИГИНАЛЬНЫЕ) ===

-- Функция плавного масштабирования модели (ИЗ РАБОЧЕГО СКРИПТА)
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
        local success, modelCFrame = pcall(function() return model:GetPivot() end)
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
    
    -- Масштабирование через CFrame (оригинальная логика)
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
                print("🎉 Все", #parts, "частей масштабированы на", scaleFactor .. "x")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    return true
end

-- === ФУНКЦИЯ ЗАПУСКА ЖИВОГО КОПИРОВАНИЯ ===

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
    print("💡 Копия будет повторять движения оригинала")
    
    return connection
end

-- === ОСНОВНЫЕ ФУНКЦИИ ===

-- Функция поиска и масштабирования (из оригинального PetScaler)
local function findAndScalePet()
    print("🔍 Поиск UUID моделей питомцев...")
    
    local foundPets = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetPivot() end)
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

-- Главная функция v2.0 (ОБНОВЛЕННАЯ ЛОГИКА)
local function main()
    print("🚀 PetScaler v2.0 запущен!")
    
    -- Шаг 1: Найти питомца
    local petModel = findAndScalePet()
    if not petModel then
        return
    end
    
    -- Шаг 2: Создать копию (ОБНОВЛЕННАЯ ЛОГИКА)
    print("\n📋 === СОЗДАНИЕ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- Настраиваем умный Anchored (как в рабочем скрипте)
    print("🧠 === НАСТРОЙКА ANCHORED ===")
    local copyParts = getAllParts(petCopy)
    if copyParts and #copyParts > 0 then
        local rootPart = smartAnchoredManagement(copyParts)
        print("✅ Умный Anchored настроен - корень закреплен, остальные свободны")
    else
        print("⚠️ Не удалось получить части копии")
    end
    
    -- Проверяем, что копия существует и находится в Workspace
    if not petCopy or not petCopy.Parent then
        print("❌ Копия недоступна!")
        return
    end
    
    -- Шаг 3: Запуск живого копирования Motor6D СРАЗУ (КЛЮЧЕВОЕ ИЗМЕНЕНИЕ!)
    print("\n🎭 === ЗАПУСК АНИМАЦИИ СРАЗУ ===")
    local animationConnection = startLiveMotorCopying(petModel, petCopy)
    
    if animationConnection then
        print("✅ Живая анимация запущена! Копия уже двигается!")
    else
        print("⚠️ Живая анимация не запустилась, но продолжаем...")
    end
    
    -- Шаг 4: Масштабирование АНИМИРОВАННОЙ копии
    task.wait(0.5)
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование анимированной копии не удалось!")
        return
    end
    
    -- Финальное сообщение
    print("\n🎉 === УСПЕХ! ===")
    print("✅ Анимированная копия создана и масштабирована")
    print("✅ Копия двигается С САМОГО НАЧАЛА")
    print("💡 Никаких статичных копий - только живая анимация!")
end

-- === НОВАЯ ФУНКЦИЯ: АВТОЗАМЕНА ПИТОМЦЕВ ИЗ WORKSPACE.VISUALS ===

-- Функция создания анимированной копии на месте оригинала
local function createAnimatedCopyAtPosition(originalPet, targetPosition)
    print("\n🔄 === СОЗДАНИЕ АНИМИРОВАННОЙ КОПИИ НА МЕСТЕ ОРИГИНАЛА ===")
    print("🎯 Оригинальный питомец:", originalPet.Name)
    print("📍 Целевая позиция:", targetPosition)
    
    -- Шаг 1: Создать копию
    local petCopy = deepCopyModel(originalPet)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return nil
    end
    
    -- Шаг 2: Позиционировать копию точно на месте оригинала
    if petCopy.PrimaryPart then
        petCopy:PivotTo(CFrame.new(targetPosition))
        print("📍 Копия размещена на месте оригинала (PrimaryPart)")
    elseif petCopy:FindFirstChild("RootPart") then
        petCopy.RootPart.Position = targetPosition
        print("📍 Копия размещена на месте оригинала (RootPart)")
    else
        -- Находим первую BasePart и позиционируем её
        local firstPart = petCopy:FindFirstChildOfClass("BasePart")
        if firstPart then
            firstPart.Position = targetPosition
            print("📍 Копия размещена на месте оригинала (первая часть)")
        end
    end
    
    -- Шаг 3: Настроить умный Anchored
    local copyParts = getAllParts(petCopy)
    if copyParts and #copyParts > 0 then
        local rootPart = smartAnchoredManagement(copyParts)
        print("✅ Умный Anchored настроен для замещающей копии")
    end
    
    -- Шаг 4: Запустить анимацию СРАЗУ
    local animationConnection = startLiveMotorCopying(originalPet, petCopy)
    if animationConnection then
        print("✅ Живая анимация запущена для замещающей копии!")
    else
        print("⚠️ Анимация не запустилась, но копия создана")
    end
    
    -- Шаг 5: Масштабировать анимированную копию
    task.wait(0.2)
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
    
    if scaleSuccess then
        print("✅ Замещающая копия масштабирована и анимирована!")
        return petCopy
    else
        print("⚠️ Масштабирование не удалось, но копия создана")
        return petCopy
    end
end

-- Forward declarations for helpers used below (they are defined later in file)
local removePriorCopies
local findModelBoundToHandle
local pickOriginalHandPet
local waitStableRel
local detachModelFromHandle

-- === НОВАЯ ФУНКЦИЯ: ЗАМЕНА ПИТОМЦА В РУКЕ (ТОЧНО КАК PetScaler_v3.226.lua) ===
local function replaceHandPetWithAnimation()
    print("\n✋ === ЗАМЕНА ПИТОМЦА В РУКЕ НА АНИМИРОВАННУЮ КОПИЮ ===")
    print("🔍 Ищу питомца в руке и создаю копию В РУКЕ...")
    
    -- Шаг 1: НАЙТИ TOOL В РУКЕ
    local playerChar = Players.LocalPlayer.Character
    if not playerChar then
        print("❌ Персонаж не найден!")
        return false
    end
    
    local handTool = playerChar:FindFirstChildOfClass("Tool")
    if not handTool then
        print("❌ Tool в руке не найден!")
        return false
    end
    
    print("🎯 Найден Tool в руке:", handTool.Name)
    -- Удаляем предыдущие копии из Tool, чтобы не накапливать weld и массы
    removePriorCopies(handTool)
    
    -- Шаг 2: НАЙТИ UUID ПИТОМЦА НА ЗЕМЛЕ ДЛЯ КОПИРОВАНИЯ АНИМАЦИЙ
    local petModel = findAndScalePet()
    if not petModel then
        print("❌ UUID питомец на земле не найден!")
        return false
    end
    
    print("✅ Найден UUID питомец на земле:", petModel.Name)
    
    -- Шаг 3: СОЗДАТЬ КОПИЮ UUID ПИТОМЦА В РУКЕ (НЕ удаляя оригинала!)
    print("📋 Создаю копию UUID питомца В РУКЕ...")
    
    -- Создаем копию БЕЗ автоматического размещения в Workspace
    local petCopy = petModel:Clone()
    petCopy.Name = petModel.Name .. "_HAND_COPY"
    
    -- РАЗМЕЩАЕМ КОПИЮ В РУКЕ (в Tool) и фиксируем относительный оффсет к Handle
    petCopy.Parent = handTool
    print("✅ Копия размещена В РУКЕ (в Tool)!")
    -- Помечаем копию специальным тегом, чтобы не скрыть её по ошибке
    local copyTag = Instance.new("BoolValue")
    copyTag.Name = "HandPetCopyTag"
    copyTag.Value = true
    copyTag.Parent = petCopy
    
    -- Настройки физики копии (без коллизий, без массы)
    for _, p in ipairs(petCopy:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
            p.Massless = true
        end
    end
    
    -- Ищем Handle
    local handle = handTool:FindFirstChild("Handle")
    -- Оригинал в руке будет сохранён для скрытия позже (объявляем заранее, чтобы не потерять область видимости)
    local originalHandPet = nil
    if not handle or not handle:IsA("BasePart") then
        print("⚠️ Handle не найден или не BasePart — позиционирую по PrimaryPart копии как fallback")
        if petCopy.PrimaryPart then
            petCopy:PivotTo(petCopy.PrimaryPart.CFrame)
        end
    else
        -- Ищем оригинального питомца в Tool, связанного с Handle (надёжно), для точного оффсета
        print("🔍 Ищу оригинального питомца, связанного с Handle...")
        originalHandPet = findModelBoundToHandle(handTool, handle, petCopy)
        if originalHandPet then
            print("✅ Найден оригинальный питомец (связан с Handle):", originalHandPet.Name)
        else
            print("⚠️ Не удалось найти по связям — попробую эвристический выбор модели")
            originalHandPet = pickOriginalHandPet(handTool, petCopy)
            if originalHandPet then
                print("✅ Выбран кандидат оригинала:", originalHandPet.Name)
            end
        end

        -- Убеждаемся, что у копии есть PrimaryPart
        if not petCopy.PrimaryPart then
            local firstPart = petCopy:FindFirstChildOfClass("BasePart")
            if firstPart then
                pcall(function()
                    petCopy.PrimaryPart = firstPart
                end)
            end
        end

        -- Вычисляем устойчивый относительный оффсет rel к Handle
        local DEFAULT_HAND_REL = CFrame.new(0, 0.2, -0.6) * CFrame.Angles(0, math.rad(10), 0)
        local rel = DEFAULT_HAND_REL
        if originalHandPet and originalHandPet.PrimaryPart and petCopy.PrimaryPart then
            local computed = waitStableRel(handle, originalHandPet, 0.6)
            if computed and typeof(computed) == "CFrame" then
                rel = computed
            else
                print("⚠️ Не удалось получить стабильный rel — использую дефолтный оффсет")
            end
        else
            print("⚠️ Нет оригинала/PrimaryPart — использую дефолтный оффсет")
        end

        -- Ставим копию в точную позу в руке и привариваем к Handle
        if petCopy.PrimaryPart then
            petCopy:PivotTo(handle.CFrame * rel)
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handle
            weld.Part1 = petCopy.PrimaryPart
            weld.Parent = petCopy.PrimaryPart
            print("🧲 Копия приварена к Handle по снятому оффсету")

            -- Сброс скоростей у копии, чтобы исключить стартовые импульсы
            for _, p in ipairs(petCopy:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.AssemblyLinearVelocity = Vector3.new()
                    p.AssemblyAngularVelocity = Vector3.new()
                    p.Velocity = Vector3.new()
                    p.RotVelocity = Vector3.new()
                end
            end

            -- Критично: отстыковываем оригинал от Handle и чистим лишние связи у Handle,
            -- чтобы исключить конкурирующие силы и рывки игрока
            if originalHandPet then
                detachModelFromHandle(originalHandPet, handle)
            end
            cleanHandleConstraintsExceptCopy(handle, petCopy.PrimaryPart)
        else
            print("⚠️ Нет PrimaryPart у копии — позиционирование ограничено")
        end
    end
    
    -- ПРОСТОЕ СКРЫТИЕ ОРИГИНАЛЬНОГО ПИТОМЦА (НЕ ТРОГАЯ КОПИЮ!)
    -- Надёжное скрытие всех визуалов оригинала в Tool (если найден originalHandPet — ок; если нет — скрываем всё, кроме копии и Handle)
    print("👻 Скрываю оригинальные визуалы питомца в руке...")
    local function isDescendantOfCopy(inst)
        return inst:IsDescendantOf(petCopy)
    end
    for _, obj in pairs(handTool:GetDescendants()) do
        if isDescendantOfCopy(obj) then
            -- пропускаем нашу копию
        else
            if obj.Name == "Handle" and obj:IsA("BasePart") then
                -- Handle не трогаем
            elseif obj:IsA("BasePart") then
                obj.Transparency = 1
                obj.CanCollide = false
            elseif obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("Beam") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end
    print("✅ Оригинальные визуалы скрыты! Видна только копия!")
    
    -- Шаг 4: ИСПРАВЛЯЕМ ATTACHMENT СВЯЗИ ДЛЯ КОПИИ В РУКЕ
    print("🔧 Исправляю Attachment связи для копии в руке...")
    local attachments = {}
    local fixedCount = 0
    
    for _, obj in pairs(petCopy:GetDescendants()) do
        if obj:IsA("Attachment") then
            table.insert(attachments, obj)
        end
    end
    
    for _, attachment in pairs(attachments) do
        if attachment.Parent and not attachment.Parent:IsA("BasePart") then
            local parent = attachment.Parent
            while parent and not parent:IsA("BasePart") do
                parent = parent.Parent
            end
            
            if parent and parent:IsA("BasePart") then
                attachment.Parent = parent
                fixedCount = fixedCount + 1
            else
                print("⚠️ Удаляю проблемный Attachment:", attachment.Name)
                attachment:Destroy()
            end
        end
    end
    
    print("✅ Исправлено Attachment связей:", fixedCount)
    
    -- Шаг 5: УМНОЕ УПРАВЛЕНИЕ ANCHORED
    -- ВАЖНО: если копия внутри Tool (в руке), пропускаем любую логику Anchored для неё,
    -- чтобы не мешать следованию за Handle через WeldConstraint и избежать физ.конфликтов
    if not petCopy:IsDescendantOf(handTool) then
        print("🧠 Настройка Anchored для копии рядом с игроком...")
        local copyParts = getAllParts(petCopy)
    
    -- Находим корневую часть для якорения (точно как в PetScaler_v3.226.lua)
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
        print("  ⚠️ Корневая часть не найдена, использую:", rootPart and rootPart.Name or "nil")
    else
        print("  ✅ Корневая часть:", rootPart.Name)
    end
    
    -- КРИТИЧНО: Все части свободны для анимации И следования за рукой
        for _, part in ipairs(copyParts) do
            part.Anchored = false
        end
        print("✅ Anchored настроен для копии рядом с игроком")
    else
        print("🧠 Пропускаю Anchored: копия находится в Tool и сварена к Handle")
    end
    
    -- Шаг 6: ПЕРЕДАЧА MOTOR6D АНИМАЦИЙ ОТ ОРИГИНАЛА НА ЗЕМЛЕ К КОПИИ В РУКЕ
    print("\n🎭 === ПЕРЕДАЧА MOTOR6D АНИМАЦИЙ ===")
    print("🔄 Передаю Motor6D анимации от оригинала на земле к копии в руке...")
    
    -- Находим Motor6D в оригинале и копии
    local originalMotors = {}
    local copyMotors = {}
    
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            originalMotors[obj.Name] = obj
        end
    end
    
    for _, obj in pairs(petCopy:GetDescendants()) do
        if obj:IsA("Motor6D") then
            copyMotors[obj.Name] = obj
        end
    end
    
    print("🔧 Motor6D в оригинале:", table.getn and table.getn(originalMotors) or "много")
    print("🔧 Motor6D в копии:", table.getn and table.getn(copyMotors) or "много")
    
    -- ПРЯМОЕ КОПИРОВАНИЕ MOTOR6D TRANSFORM ОТ ОРИГИНАЛА К КОПИИ + СЛЕДОВАНИЕ ЗА РУКОЙ
    if next(originalMotors) and next(copyMotors) then
        local directConnection = RunService.Heartbeat:Connect(function()
            -- 1. ПЕРЕДАЧА MOTOR6D АНИМАЦИЙ
            for motorName, originalMotor in pairs(originalMotors) do
                local copyMotor = copyMotors[motorName]
                if copyMotor and originalMotor.Parent and copyMotor.Parent then
                    -- Прямое копирование Transform от оригинала на земле к копии в руке
                    copyMotor.Transform = originalMotor.Transform
                end
            end
            
            -- 2. ПОСТОЯННОЕ ОБНОВЛЕНИЕ ПОЗИЦИИ КОПИИ ОТНОСИТЕЛЬНО ОРИГИНАЛЬНОГО ПИТОМЦА В РУКЕ
            if originalHandPet and originalHandPet.PrimaryPart and petCopy.PrimaryPart then
                -- Копируем текущую позицию оригинального питомца в руке
                local currentOriginalCFrame = originalHandPet.PrimaryPart.CFrame
                petCopy:PivotTo(currentOriginalCFrame)
            end
        end)
        
        print("✅ Motor6D анимации передаются от оригинала на земле к копии в руке!")
        print("✅ Копия постоянно следует за позицией оригинального питомца в руке!")
        print("🎭 Копия в руке получает живые анимации от оригинала!")
        print("🔥 Два питомца: оригинал на земле + анимированная копия в руке!")
        
        return true
    else
        print("⚠️ Motor6D не найдены для передачи анимаций")
        return false
    end
end

-- Функция строгой проверки модели питомца (ИСПРАВЛЕНО)
local function isPetModel(model)
    -- 1. Должна быть Model
    if not model:IsA("Model") then return false end
    
    -- 2. КРИТИЧНО: Исключаем ВСЕ КОПИИ (с _COPY, _SCALED, UUID, фигурными скобками)
    local modelName = model.Name
    if modelName:find("_COPY") or modelName:find("_SCALED") or modelName:find("SCALED_COPY") or 
       modelName:find("ANIMATED_COPY") or modelName:find("{") or modelName:find("}") or
       modelName:find("-") and #modelName > 10 then -- UUID обычно длинные с тире
        return false
    end
    
    -- 3. КРИТИЧНО: Исключаем игроков (включая меня)
    for _, p in pairs(Players:GetPlayers()) do
        if modelName == p.Name or modelName:find(p.Name) then
            return false
        end
    end
    
    -- 4. Исключаем обычные объекты
    local EXCLUDED_NAMES = {
        "EggExplode", "CraftingTables", "EventCraftingWorkBench", "Fruit", "Tree", 
        "Bush", "Platform", "Stand", "Bench", "Table", "Chair", "Decoration",
        "Egg", "Tool", "Handle", "Part", "Union", "Accessory", "Hat"
    }
    
    for _, excluded in pairs(EXCLUDED_NAMES) do
        if modelName:find(excluded) then return false end
    end
    
    -- 5. Исключаем модели инвентаря игроков
    if modelName:find("%[") and modelName:find("KG") and modelName:find("Age") then
        return false
    end
    
    -- 6. КРИТИЧНО: Проверяем, что это НАСТОЯЩИЙ питомец (только короткие имена)
    if #modelName > 15 then return false end -- Питомцы обычно имеют короткие имена
    
    -- 7. Проверяем наличие мешей
    local meshCount = 0
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            meshCount = meshCount + 1
        end
    end
    
    if meshCount < 1 then return false end
    
    -- 8. Проверяем количество детей
    if #model:GetChildren() < 5 then return false end
    
    -- 9. Проверяем расстояние до игрока
    local playerChar = player.Character
    if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
        local success, modelCFrame = pcall(function() return model:GetPivot() end)
        if success then
            local distance = (modelCFrame.Position - playerChar.HumanoidRootPart.Position).Magnitude
            if distance > CONFIG.SEARCH_RADIUS then return false end
        end
    end
    
    return true
end

-- Функция автозамены питомцев (СОБЫТИЙНАЯ СИСТЕМА - БЕЗ МОНИТОРИНГА!)
local function startWorkspaceScanning()
    print("\n🔍 === ЗАПУСК СОБЫТИЙНОЙ АВТОЗАМЕНЫ ПИТОМЦЕВ ===")
    print("⚡ Используем ChildAdded события вместо постоянного мониторинга!")
    print("💡 Теперь ищем питомца В ФИГУРНЫХ СКОБКАХ, как при ручном создании!")
    
    local processedModels = {}
    local foundPetModels = {}
    local createdCopiesCount = 0 -- Счетчик созданных копий
    local MAX_COPIES = 3 -- Максимум копий за сессию
    local processedPetNames = {} -- Отслеживание по именам
    local scanStartTime = tick()
    
    -- Список всех питомцев из яиц
    local eggPets = {
        -- Anti Bee Egg
        "wasp", "tarantula hawk", "moth", "butterfly", "disco bee (divine)",
        -- Bee Egg  
        "bee", "honey bee", "bear bee", "petal bee", "queen bee",
        -- Bug Egg
        "snail", "giant ant", "caterpillar", "praying mantis", "dragonfly (divine)",
        -- Common Egg
        "dog", "bunny", "golden lab",
        -- Common Summer Egg
        "starfish", "seagull", "crab",
        -- Dinosaur Egg
        "raptor", "triceratops", "stegosaurus", "pterodactyl", "brontosaurus", "t-rex (divine)",
        -- Legendary Egg
        "cow", "silver monkey", "sea otter", "turtle", "polar bear",
        -- Mythical Egg
        "grey mouse", "brown mouse", "squirrel", "red giant ant", "red fox",
        -- Night Egg
        "hedgehog", "mole", "frog", "echo frog", "night owl", "raccoon",
        -- Oasis Egg
        "meerkat", "sand snake", "axolotl", "hyacinth macaw", "fennec fox",
        -- Paradise Egg
        "ostrich", "peacock", "capybara", "scarlet macaw", "mimic octopus",
        -- Primal Egg
        "parasaurolophus", "iguanodon", "pachycephalosaurus", "dilophosaurus", "ankylosaurus", "spinosaurus (divine)",
        -- Rare Egg
        "orange tabby", "spotted deer", "pig", "rooster", "monkey",
        -- Rare Summer Egg
        "flamingo", "toucan", "sea turtle", "orangutan", "seal",
        -- Uncommon Egg
        "black bunny", "chicken", "cat", "deer",
        -- Zen Egg
        "shiba inu", "nihonzaru", "tanuki", "tanchozuru", "kappa", "kitsune"
    }
    
    -- Функция проверки является ли модель питомцем из яйца
    local function isPetFromEgg(model)
        if not model:IsA("Model") then return false end
        local modelName = model.Name:lower()
        
        for _, petName in pairs(eggPets) do
            if modelName == petName then
                return true
            end
        end
        return false
    end
    
    -- Функция обработки нового питомца
    local function processPetFromEgg(newPet)
        -- Проверяем лимит копий
        if createdCopiesCount >= MAX_COPIES then
            print("⚠️ Достигнут лимит копий (" .. MAX_COPIES .. "). Игнорирую питомца:", newPet.Name)
            return
        end
        
        -- Используем уникальный ID вместо имени для отслеживания обработанных питомцев
        local petId = tostring(newPet)  -- Уникальный адрес объекта
        if processedModels[petId] then
            return
        end
        
        print("🎭 СОБЫТИЕ: Новый питомец появился в Visuals:", newPet.Name)
        processedModels[petId] = true
        
        -- Ищем UUID питомца рядом с новым питомцем
        print("🔍 Ищем UUID питомца рядом с новым питомцем:", newPet.Name)
        
        local foundPet = nil
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
                local success, modelCFrame = pcall(function() return obj:GetPivot() end)
                if success then
                    local playerChar = player.Character
                    if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                        local distance = (modelCFrame.Position - playerChar.HumanoidRootPart.Position).Magnitude
                        if distance <= CONFIG.SEARCH_RADIUS then
                            -- Проверяем меши (как в ручной копии)
                            local meshes = 0
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("MeshPart") or part:IsA("SpecialMesh") then
                                    meshes = meshes + 1
                                end
                            end
                            
                            foundPet = obj
                            print("🔑 НАЙДЕН UUID питомец по расстоянию:", obj.Name, "(Расстояние:", math.floor(distance), ", Мешей:", meshes, ")")
                            break
                        end
                    end
                end
            end
        end
        
        -- Шаг 2: ИЩЕМ UUID ПИТОМЦА ПО РАССТОЯНИЮ (КАК В РУЧНОЙ КОПИИ!)
        if foundVisualsPet then
            print("🔍 Ищем UUID питомца рядом с игроком (как в findAndScalePet)...")
            
            -- ТОЧНО КОПИРУЕМ ЛОГИКУ ИЗ findAndScalePet()!
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
                    local success, modelCFrame = pcall(function() return obj:GetPivot() end)
                    if success then
                        local playerChar = player.Character
                        if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                            local distance = (modelCFrame.Position - playerChar.HumanoidRootPart.Position).Magnitude
                            if distance <= CONFIG.SEARCH_RADIUS then
                                -- Проверяем меши (как в ручной копии)
                                local meshes = 0
                                for _, part in pairs(obj:GetDescendants()) do
                                    if part:IsA("MeshPart") or part:IsA("SpecialMesh") then
                                        meshes = meshes + 1
                                    end
                                end
                                
                                foundPet = obj
                                print("🔑 НАЙДЕН UUID питомец по расстоянию:", obj.Name, "(Расстояние:", math.floor(distance), ", Мешей:", meshes, ")")
                                break
                            end
                        end
                    end
                end
            end
        end
        
        -- Если найден UUID питомец, обрабатываем замену
        if foundPet then
            print("\n🎉 === НАЙДЕНА ПАРА ПИТОМЦЕВ ДЛЯ АВТОЗАМЕНЫ ===")
            print("🔑 UUID питомец:", foundPet.Name)
            print("🎭 Визуальный питомец:", newPet.Name)
            
            -- Получаем позицию визуального питомца
            local visualPosition = nil
            local success, visualCFrame = pcall(function() return newPet:GetPivot() end)
            if success then
                visualPosition = visualCFrame.Position
            elseif newPet.PrimaryPart then
                visualPosition = newPet.PrimaryPart.Position
            end
            
            if visualPosition then
                print("📍 Позиция для замены:", visualPosition)
                
                -- Питомец уже скрыт в событии ChildAdded, не нужно скрывать повторно
                print("✅ Питомец уже скрыт, создаю анимированную копию")
                
                -- Создаем копию UUID питомца на месте визуального
                local animatedCopy = createAnimatedCopyAtPosition(foundPet, visualPosition)
                    
                if animatedCopy then
                    -- Увеличиваем счетчик копий
                    createdCopiesCount = createdCopiesCount + 1
                    
                    -- СИНХРОНИЗИРУЕМ ВРЕМЯ ЖИЗНИ КОПИИ С ОРИГИНАЛОМ
                    print("⏰ Настраиваю синхронизацию времени жизни...")
                    
                    -- Отслеживаем удаление визуального питомца и заменяем питомца в handle
                    task.spawn(function()
                        while newPet and newPet.Parent do
                            task.wait(0.2) -- Проверяем каждые 0.2 секунды (оптимизация)
                        end
                        
                        -- Когда визуальный питомец исчез, удаляем копию
                        if animatedCopy and animatedCopy.Parent then
                            print("✨ Оригинал исчез - удаляю копию")
                            animatedCopy:Destroy()
                        end
                        
                        -- НОВОЕ: Заменяем питомца в handle на Dragonfly из инвентаря
                        task.wait(2) -- Ждем немного после исчезновения анимации
                        print("🔄 Ищу питомца в handle для замены...")
                        
                        local playerChar = player.Character
                        if playerChar then
                            local handle = playerChar:FindFirstChild("Handle")
                            if handle then
                                print("📍 Handle найден, содержит:")
                                for _, obj in pairs(handle:GetChildren()) do
                                    print("  - " .. obj.Name .. " (" .. obj.ClassName .. ")")
                                end
                                
                                -- Ищем текущего питомца в handle (НЕ Dragonfly)
                                for _, obj in pairs(handle:GetChildren()) do
                                    if obj:IsA("Model") and obj.Name:lower() ~= "dragonfly" then
                                        print("🗑️ Убираю временного питомца из handle:", obj.Name)
                                        obj:Destroy() -- Удаляем временного питомца
                                        break
                                    end
                                end
                                
                                -- Ищем Dragonfly в WORKSPACE (где обычно хранятся питомцы)
                                print("🔍 Ищу Dragonfly в Workspace...")
                                
                                for _, obj in pairs(Workspace:GetDescendants()) do
                                    if obj:IsA("Model") and obj.Name:lower():find("dragonfly") and obj ~= playerChar then
                                        print("🐉 Найден Dragonfly в Workspace - перемещаю в handle")
                                        
                                        -- Перемещаем (не клонируем) Dragonfly в handle
                                        obj.Parent = handle
                                        
                                        -- Позиционируем в руке
                                        if obj.PrimaryPart then
                                            obj.PrimaryPart.CFrame = handle.CFrame
                                        elseif obj:FindFirstChild("RootPart") then
                                            obj.RootPart.CFrame = handle.CFrame
                                        end
                                        
                                        print("✅ Dragonfly успешно помещен в handle!")
                                        return
                                    end
                                end
                                
                                -- Если не найден в Workspace, ищем в других местах
                                print("🔍 Ищу Dragonfly в других локациях...")
                                local searchLocations = {
                                    player,
                                    playerChar,
                                    game.ReplicatedStorage
                                }
                                
                                for _, location in pairs(searchLocations) do
                                    if location then
                                        for _, item in pairs(location:GetDescendants()) do
                                            if item:IsA("Model") and item.Name:lower():find("dragonfly") then
                                                print("🐉 Найден Dragonfly в", location.Name, "- клонирую в handle")
                                                
                                                local dragonflyClone = item:Clone()
                                                dragonflyClone.Parent = handle
                                                
                                                if dragonflyClone.PrimaryPart then
                                                    dragonflyClone.PrimaryPart.CFrame = handle.CFrame
                                                end
                                                
                                                print("✅ Dragonfly успешно помещен в handle!")
                                                return
                                            end
                                        end
                                    end
                                end
                                
                                print("⚠️ Dragonfly не найден нигде")
                            else
                                print("⚠️ Handle не найден у игрока")
                            end
                        end
                    end)
                        
                        -- Перемещаем визуального питомца под землю
                        if foundVisualsPet.PrimaryPart then
                            foundVisualsPet:PivotTo(foundVisualsPet.PrimaryPart.CFrame - Vector3.new(0, 1000, 0))
                        end
                        
                        print("✅ Визуальный питомец скрыт!")
                        print("🎉 Автозамена завершена - UUID питомец скопирован на место визуального!")
                        print("📊 Создано копий: " .. createdCopiesCount .. "/" .. MAX_COPIES)
                        
                        -- Добавляем в список найденных
                        table.insert(foundPetModels, {
                            name = foundPet.Name .. " -> " .. newPet.Name,
                            foundTime = tick() - scanStartTime,
                            animatedCopy = animatedCopy
                        })
                    else
                        print("❌ Не удалось создать анимированную копию UUID питомца")
                    end
                else
                    print("❌ Не удалось определить позицию визуального питомца")
                end
            else
                print("⚠️ Не найден соответствующий UUID питомец для замены")
            end
    end
    
    -- СОБЫТИЙНАЯ СИСТЕМА: Отслеживаем появление новых питомцев в Workspace.Visuals
    local visualsFolder = Workspace:FindFirstChild("Visuals")
    if visualsFolder then
        print("✅ Найдена папка Visuals - подключаю событийную систему")
        
        local childAddedConnection = visualsFolder.ChildAdded:Connect(function(child)
            if child:IsA("Model") and isPetFromEgg(child) then
                print("⚡ СОБЫТИЕ: Новый питомец появился в Visuals:", child.Name)
                
                -- МГНОВЕННО скрываем питомца ДО обработки!
                print("⚡ МГНОВЕННО скрываю питомца:", child.Name)
                for _, part in pairs(child:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                        part.CanCollide = false
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                    end
                end
                
                -- Используем task.spawn, чтобы не блокировать событие
                task.spawn(function()
                    task.wait(0.05) -- Минимальная задержка для загрузки модели
                    processPetFromEgg(child)
                end)
            end
        end)
        
        -- Также проверяем уже существующих питомцев в Visuals
        for _, child in pairs(visualsFolder:GetChildren()) do
            if child:IsA("Model") and isPetFromEgg(child) then
                local petId = tostring(child)
                if not processedModels[petId] then
                    print("🔍 НАЧАЛЬНАЯ ПРОВЕРКА: Найден питомец в Visuals:", child.Name)
                    processPetFromEgg(child)
                end
            end
        end
        
        print("🔄 Событийная система активна!")
        print("💡 Все новые питомцы в Visuals будут автоматически заменены")
        print("🎯 Откройте яйцо для автоматической замены!")
        
        return childAddedConnection
    else
        print("❌ Папка Workspace.Visuals не найдена!")
        return nil
    end
end

-- Создание GUI (С ЗАЩИТОЙ ОТ ОШИБОК)
local function createGUI()
    local success, errorMsg = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        local oldGui = playerGui:FindFirstChild("PetScalerV2GUI")
        if oldGui then
            oldGui:Destroy()
            task.wait(0.1) -- Небольшая пауза после удаления
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PetScalerV2GUI"
        screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 120) -- Увеличиваем высоту для третьей кнопки
    frame.Position = UDim2.new(0, 50, 0, 150) -- Под оригинальным PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Зеленая рамка
    frame.Parent = screenGui
    
    -- Кнопка ручного создания копии
    local manualButton = Instance.new("TextButton")
    manualButton.Name = "ManualScaleButton"
    manualButton.Size = UDim2.new(0, 230, 0, 30)
    manualButton.Position = UDim2.new(0, 10, 0, 10)
    manualButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    manualButton.BorderSizePixel = 0
    manualButton.Text = "🔥 Ручное создание копии"
    manualButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    manualButton.TextSize = 12
    manualButton.Font = Enum.Font.SourceSansBold
    manualButton.Parent = frame
    
    -- Кнопка автозамены
    local autoButton = Instance.new("TextButton")
    autoButton.Name = "AutoReplaceButton"
    autoButton.Size = UDim2.new(0, 230, 0, 30)
    autoButton.Position = UDim2.new(0, 10, 0, 45)
    autoButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    autoButton.BorderSizePixel = 0
    autoButton.Text = "🥚 Автозамена питомцев (ОФФ)"
    autoButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    autoButton.TextSize = 12
    autoButton.Font = Enum.Font.SourceSansBold
    autoButton.Parent = frame
    
    -- НОВАЯ КНОПКА: Замена питомца в руке (как PetScaler_v3.226.lua)
    local handButton = Instance.new("TextButton")
    handButton.Name = "HandReplaceButton"
    handButton.Size = UDim2.new(0, 230, 0, 30)
    handButton.Position = UDim2.new(0, 10, 0, 80) -- Третья кнопка
    handButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Фиолетовая
    handButton.BorderSizePixel = 0
    handButton.Text = "✋ Заменить питомца в руке"
    handButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    handButton.TextSize = 12
    handButton.Font = Enum.Font.SourceSansBold
    handButton.Parent = frame
    
    -- Переменная для отслеживания состояния автозамены
    local autoReplaceActive = false
    local visualsConnection = nil
    
    -- Обработчик ручной кнопки
    manualButton.MouseButton1Click:Connect(function()
        manualButton.Text = "⏳ Создаю с анимацией..."
        manualButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        task.spawn(function()
            local success, errorMsg = pcall(function()
                main()
            end)
            
            if success then
                task.wait(3)
                manualButton.Text = "🔥 Ручное создание копии"
                manualButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                print("❌ Ошибка в main():", errorMsg)
                manualButton.Text = "❌ Ошибка! Попробуйте снова"
                manualButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end)
    end)
    
    -- Обработчик НОВОЙ кнопки замены в руке
    handButton.MouseButton1Click:Connect(function()
        handButton.Text = "⏳ Заменяю питомца в руке..."
        handButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        
        task.spawn(function()
            local success = replaceHandPetWithAnimation()
            
            if success then
                handButton.Text = "✅ Питомец заменен!"
                handButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                task.wait(2)
                handButton.Text = "✋ Заменить питомца в руке"
                handButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            else
                handButton.Text = "❌ Ошибка замены!"
                handButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                task.wait(2)
                handButton.Text = "✋ Заменить питомца в руке"
                handButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            end
        end)
    end)
    
    -- Обработчик кнопки автозамены
    autoButton.MouseButton1Click:Connect(function()
        if not autoReplaceActive then
            -- Включаем автозамену
            autoButton.Text = "⏳ Запускаю мониторинг..."
            autoButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            
            task.spawn(function()
                visualsConnection = startWorkspaceScanning()
                autoReplaceActive = true
                
                autoButton.Text = "🔄 Автозамена питомцев (ОН)"
                autoButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            end)
        else
            -- Отключаем автозамену
            if visualsConnection then
                visualsConnection:Disconnect()
                visualsConnection = nil
            end
            
            autoReplaceActive = false
            autoButton.Text = "🥚 Автозамена питомцев (ОФФ)"
            autoButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            
            print("❌ Мониторинг workspace.visuals остановлен")
        end
    end)
    
    -- Hover эффекты для ручной кнопки
    manualButton.MouseEnter:Connect(function()
        if manualButton.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
            manualButton.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        end
    end)
    
    manualButton.MouseLeave:Connect(function()
        if manualButton.BackgroundColor3 == Color3.fromRGB(0, 220, 0) then
            manualButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
    
    -- Hover эффекты для кнопки автозамены
    autoButton.MouseEnter:Connect(function()
        if autoButton.BackgroundColor3 == Color3.fromRGB(255, 165, 0) then
            autoButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        elseif autoButton.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
            autoButton.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        end
    end)
    
    autoButton.MouseLeave:Connect(function()
        if autoButton.BackgroundColor3 == Color3.fromRGB(255, 140, 0) then
            autoButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        elseif autoButton.BackgroundColor3 == Color3.fromRGB(0, 220, 0) then
            autoButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
    
        print("💻 PetScaler v2.0 GUI с автозаменой создан!")
    end)
    
    if not success then
        print("❌ Ошибка при создании GUI:", errorMsg)
        print("📝 Попробуйте перезапустить скрипт")
        return false
    end
    
    return true
end

-- Событийная модель автозамены питомца в руке (без постоянного опроса)
local processedTools = {}
local autoConns = {}

-- Проверка готовности питомца в Tool (есть модель с частями и корректный Pivot)
local function isPetReady(tool)
    if not tool or not tool.Parent then return false end
    if not tool:IsA("Tool") then return false end

    local foundModel = nil
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("Model") then
            local hasPart = false
            for _, d in pairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then
                    hasPart = true
                    break
                end
            end
            if hasPart then
                foundModel = obj
                break
            end
        end
    end

    if not foundModel then return false end

    local ok = pcall(function()
        return foundModel:GetPivot()
    end)
    return ok == true
end

-- Находит наиболее вероятную исходную модель питомца внутри Tool (исключая копию)
pickOriginalHandPet = function(handTool, excludeModel)
    if not handTool then return nil end
    local best, bestScore = nil, -math.huge
    local handle = handTool:FindFirstChild("Handle")
    local handlePos = handle and handle:IsA("BasePart") and handle.Position or nil
    for _, obj in pairs(handTool:GetDescendants()) do
        if obj:IsA("Model") and obj ~= excludeModel and not (excludeModel and obj:IsDescendantOf(excludeModel)) then
            local parts = 0
            local firstPart = nil
            for _, d in pairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then
                    parts = parts + 1
                    if not firstPart then firstPart = d end
                end
            end
            if parts > 0 then
                if not obj.PrimaryPart and firstPart then pcall(function() obj.PrimaryPart = firstPart end) end
                local score = parts
                if handlePos and obj.PrimaryPart then
                    local dist = (obj.PrimaryPart.Position - handlePos).Magnitude
                    score = score - dist * 0.1
                end
                if score > bestScore then
                    best, bestScore = obj, score
                end
            end
        end
    end
    return best
end

-- Ждёт стабилизации относительного оффсета между Handle и моделью питомца
waitStableRel = function(handle, model, maxTime)
    if not handle or not model or not model.PrimaryPart then return nil end
    maxTime = maxTime or 0.6
    local t0 = os.clock()
    local prevRel, stableCount = nil, 0
    while os.clock() - t0 < maxTime do
        local ok, rel = pcall(function()
            return handle.CFrame:ToObjectSpace(model.PrimaryPart.CFrame)
        end)
        if not ok then break end
        if prevRel then
            local dp = (rel.Position - prevRel.Position).Magnitude
            local dot = math.clamp(rel.LookVector:Dot(prevRel.LookVector), -1, 1)
            local angle = math.deg(math.acos(dot))
            if dp < 0.003 and angle < 0.6 then
                stableCount = stableCount + 1
                if stableCount >= 3 then
                    return rel
                end
            else
                stableCount = 0
            end
        end
        prevRel = rel
        task.wait(0.05)
    end
    return prevRel
end

-- Находит модель, физически связную с Handle (через Weld/Motor/Constraint)
findModelBoundToHandle = function(handTool, handle, excludeModel)
    if not handTool or not handle then return nil end
    local function getModel(part)
        return part and part:FindFirstAncestorOfClass("Model") or nil
    end
    for _, obj in ipairs(handTool:GetDescendants()) do
        if obj:IsA("Constraint") or obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
            local p0 = obj.Part0 or obj.Attachment0 and obj.Attachment0.Parent
            local p1 = obj.Part1 or obj.Attachment1 and obj.Attachment1.Parent
            if p0 == handle or p1 == handle then
                local other = (p0 == handle) and p1 or p0
                local mdl = getModel(other)
                if mdl and mdl ~= excludeModel and not (excludeModel and mdl:IsDescendantOf(excludeModel)) then
                    return mdl
                end
            end
        end
    end
    return nil
end

-- Полностью отсоединяет модель от Handle и гасит физику, чтобы не дёргала игрока
detachModelFromHandle = function(model, handle)
    if not model then return end
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("Constraint") or obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
            local p0 = obj.Part0 or obj.Attachment0 and obj.Attachment0.Parent
            local p1 = obj.Part1 or obj.Attachment1 and obj.Attachment1.Parent
            if p0 == handle or p1 == handle then
                obj:Destroy()
            end
        end
    end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = true
            p.CanCollide = false
            p.Massless = true
            p.AssemblyLinearVelocity = Vector3.new()
            p.AssemblyAngularVelocity = Vector3.new()
            p.Velocity = Vector3.new()
            p.RotVelocity = Vector3.new()
        elseif p:IsA("Decal") then
            p.Transparency = 1
        elseif p:IsA("Beam") or p:IsA("ParticleEmitter") or p:IsA("Trail") then
            p.Enabled = false
        end
    end
end

-- Удаляет предыдущие копии в Tool, чтобы не было нескольких сварок
removePriorCopies = function(handTool)
    if not handTool then return end
    for _, m in ipairs(handTool:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("HandPetCopyTag") then
            m:Destroy()
        end
    end
end

local function disconnectAll()
    for _, c in ipairs(autoConns) do
        if c and c.Disconnect then c:Disconnect() end
    end
    table.clear(autoConns)
end

local function onEquipped(tool)
    if processedTools[tool] then return end
    task.spawn(function()
        -- Ждем стабилизации (до 2 сек, шаг 0.05)
        local ready = false
        local t0 = os.clock()
        while os.clock() - t0 < 2 do
            if isPetReady(tool) then
                ready = true
                break
            end
            task.wait(0.05)
        end
        if not ready then return end

        print("\n✋ Обнаружен питомец в руке! Запускаю замену по событию...")
        processedTools[tool] = true

        -- Обновление GUI и запуск замены
        local playerGui = player:WaitForChild("PlayerGui")
        local gui = playerGui:FindFirstChild("PetScalerV2GUI")
        local handButton = gui and gui:FindFirstChild("HandButton")
        if handButton then
            handButton.Text = "⏳ Заменяю питомца в руке..."
            handButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        end

        local success = replaceHandPetWithAnimation()

        if handButton then
            if success then
                handButton.Text = "✅ Питомец заменен!"
                handButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                task.wait(2)
                handButton.Text = "✋ Заменить питомца в руке"
                handButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            else
                handButton.Text = "❌ Ошибка замены!"
                handButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                task.wait(2)
                handButton.Text = "✋ Заменить питомца в руке"
                handButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            end
        end

        print("✅ Автоматическая замена завершена (событие)!")
    end)
end

local function hookTool(tool)
    table.insert(autoConns, tool.Equipped:Connect(function()
        onEquipped(tool)
    end))
    table.insert(autoConns, tool.Unequipped:Connect(function()
        processedTools[tool] = nil
    end))
    table.insert(autoConns, tool.Destroying:Connect(function()
        processedTools[tool] = nil
    end))
end

local function bindCharacter(char)
    -- Подхватываем уже надетый Tool
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then hookTool(currentTool) end
    -- Новые инструменты
    table.insert(autoConns, char.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            hookTool(obj)
        end
    end))
end

if player and player.Character then
    bindCharacter(player.Character)
end
table.insert(autoConns, player.CharacterAdded:Connect(function(char)
    disconnectAll()
    bindCharacter(char)
end))

-- Очистка при уничтожении GUI
if screenGui then
    table.insert(autoConns, screenGui.Destroying:Connect(function()
        disconnectAll()
    end))
end

print("✅ Автозамена по событиям инициализирована!")
print("💡 Возьмите питомца в руку — замена произойдет автоматически")

-- Запуск с защитой от ошибок
local initSuccess, initError = pcall(function()
    local guiSuccess = createGUI()
    if not guiSuccess then
        error("Не удалось создать GUI")
    end
end)

if initSuccess then
    print("=" .. string.rep("=", 70))
    print("💡 PETSCALER v2.0 + АВТОЗАМЕНА - ПОЛНОЕ РЕШЕНИЕ:")
    print("   🔥 РУЧНОЕ СОЗДАНИЕ:")
    print("     1. Создает масштабированную копию")
    print("     2. Настраивает правильные Anchored состояния")
    print("     3. Автоматически запускает живое копирование анимации")
    print("")
    print("   🥚 НОВОЕ! АВТОЗАМЕНА ПИТОМЦЕВ:")
    print("     1. Ищет питомца В ФИГУРНЫХ СКОБКАХ (как ручная копия)")
    print("     2. Автоматически скрывает визуального питомца")
    print("     3. Создает анимированные копии на том же месте")
    print("     4. Никаких статичных копий - только живая анимация!")
    print("")
    print("🎯 ИСПОЛЬЗОВАНИЕ:")
    print("   🔥 Зеленая кнопка - Ручное создание копии")
    print("   🥚 Оранжевая кнопка - Вкл/Откл автозамену питомцев")
    print("=" .. string.rep("=", 70))
    print("✅ PetScaler v2.0 успешно запущен!")
    
else
    print("❌ КРИТИЧЕСКАЯ ОШИБКА при запуске PetScaler v2.0:")
    print("📝 Ошибка:", initError)
    print("🔄 Попробуйте перезапустить скрипт")
    print("💡 Если проблема повторяется, проверьте права доступа к GUI")
end
