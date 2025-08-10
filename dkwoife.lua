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
            copy:SetPrimaryPartCFrame(newCFrame)
            print("📍 Копия размещена на земле")
        else
            local newCFrame = originalCFrame + offset
            copy:SetPrimaryPartCFrame(newCFrame)
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
    print("\n📏 === МАСШТАБИРОВАНИЕ АНИМИРОВАННОЙ КОПИИ ===")
    wait(0.5)
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
        petCopy:SetPrimaryPartCFrame(CFrame.new(targetPosition))
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
    wait(0.2) -- Короткая пауза
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
    
    if scaleSuccess then
        print("✅ Замещающая копия масштабирована и анимирована!")
        return petCopy
    else
        print("⚠️ Масштабирование не удалось, но копия создана")
        return petCopy
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
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            local distance = (modelCFrame.Position - playerChar.HumanoidRootPart.Position).Magnitude
            if distance > CONFIG.SEARCH_RADIUS then return false end
        end
    end
    
    return true
end

-- Функция автозамены питомцев (ИСПРАВЛЕНО - КАК РУЧНАЯ КОПИЯ)
local function startWorkspaceScanning()
    print("\n🔍 === ЗАПУСК АВТОЗАМЕНЫ ПИТОМЦЕВ (КАК РУЧНАЯ КОПИЯ) ===")
    print("💡 Теперь ищем питомца В ФИГУРНЫХ СКОБКАХ, как при ручном создании!")
    
    local processedModels = {}
    local foundPetModels = {}
    local createdCopiesCount = 0 -- Счетчик созданных копий
    local MAX_COPIES = 3 -- Максимум копий за сессию
    local processedPetNames = {} -- Отслеживание по именам
    local scanStartTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - scanStartTime
        
        -- Ограничиваем время сканирования
        if elapsed > 300 then -- 5 минут максимум
            print("⏰ Сканирование остановлено по таймауту")
            connection:Disconnect()
            return
        end
        
        -- КРИТИЧНО: Проверяем лимит копий
        if createdCopiesCount >= MAX_COPIES then
            print("⚠️ Достигнут лимит копий (" .. MAX_COPIES .. "). Останавливаю сканирование.")
            connection:Disconnect()
            return
        end
        
        -- УБИРАЕМ ИНТЕРВАЛЬНОЕ СКАНИРОВАНИЕ - сканируем каждый кадр для надежности
        -- if elapsed % 0.1 > 0.05 then
        --     return
        -- end
        
        -- ОТЛАДКА: Показываем все модели в workspace для диагностики
        if math.floor(elapsed) % 5 == 0 and elapsed > 1 then -- Каждые 5 секунд
            print("\n🔍 === ОТЛАДКА АВТОЗАМЕНЫ (" .. string.format("%.1f сек", elapsed) .. ") ===")
            
            -- Проверяем ВЕСЬ WORKSPACE (ИЩЕМ ПРОСТЫЕ ИМЕНА!)
            print("📁 Сканируем весь Workspace на наличие питомцев:")
            local petCount = 0
            for _, child in pairs(Workspace:GetDescendants()) do
                if child:IsA("Model") and child ~= player.Character then
                    local childName = child.Name:lower()
                    local isPet = childName == "golden lab" or childName == "bunny" or childName == "dog" or childName == "cat" or childName == "rabbit"
                    if isPet then
                        petCount = petCount + 1
                        print("  🐾 ПИТОМЕЦ:", child.Name, "- Родитель:", child.Parent and child.Parent.Name or "nil")
                    end
                end
            end
            if petCount == 0 then
                print("❌ Питомцы с простыми именами НЕ найдены в Workspace!")
            end
            
            -- Проверяем UUID модели
            local uuidCount = 0
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
                    uuidCount = uuidCount + 1
                    if uuidCount <= 3 then -- Показываем только первые 3
                        print("  🔑 UUID модель:", obj.Name)
                    end
                end
            end
            print("📊 Всего UUID моделей:", uuidCount)
        end
        
        -- УПРОЩЕННАЯ ЛОГИКА: Ищем питомца из яйца (сначала в visuals, потом UUID)
        local foundPet = nil
        local foundVisualsPet = nil
        
        -- Шаг 1: ВОЗВРАЩАЕМ ПОЛНОЕ СКАНИРОВАНИЕ - без ограничений для надежности
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= player.Character and not processedPetNames[obj.Name] then
                
                -- КРИТИЧНО: У визуального питомца ПРОСТОЕ ИМЯ (НЕ UUID!)
                local objName = obj.Name:lower()
                if objName == "golden lab" or objName == "bunny" or objName == "dog" or 
                   objName == "cat" or objName == "rabbit" or objName:find("lab") then
                    foundVisualsPet = obj
                    print("🎭 НАЙДЕН визуальный питомец в Workspace:", obj.Name, "- Родитель:", obj.Parent and obj.Parent.Name or "nil")
                    break
                end
            end
        end
        
        -- Шаг 2: ИЩЕМ UUID ПИТОМЦА ПО РАССТОЯНИЮ (КАК В РУЧНОЙ КОПИИ!)
        if foundVisualsPet then
            print("🔍 Ищем UUID питомца рядом с игроком (как в findAndScalePet)...")
            
            -- ТОЧНО КОПИРУЕМ ЛОГИКУ ИЗ findAndScalePet()!
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
                    local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
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
        
        -- Шаг 3: Если найдены оба питомца, обрабатываем их
        if foundPet and foundVisualsPet then
            -- Отмечаем как обработанных
            processedPetNames[foundPet.Name] = true
            processedPetNames[foundVisualsPet.Name] = true
            
            print("\n🎉 === НАЙДЕНА ПАРА ПИТОМЦЕВ ДЛЯ АВТОЗАМЕНЫ ===")
            print("🔑 UUID питомец:", foundPet.Name)
            print("🎭 Визуальный питомец:", foundVisualsPet.Name)
            
            -- Получаем позицию визуального питомца
            local visualPosition = nil
            local success, visualCFrame = pcall(function() return foundVisualsPet:GetModelCFrame() end)
            if success then
                visualPosition = visualCFrame.Position
            elseif foundVisualsPet.PrimaryPart then
                visualPosition = foundVisualsPet.PrimaryPart.Position
            end
            
            if visualPosition then
                print("📍 Позиция для замены:", visualPosition)
                
                -- МГНОВЕННО СКРЫВАЕМ ВИЗУАЛЬНОГО ПИТОМЦА!
                print("⚡ МГНОВЕННО скрываю визуального питомца:", foundVisualsPet.Name)
                
                -- Метод 1: Мгновенно делаем невидимым
                for _, part in pairs(foundVisualsPet:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                        part.CanCollide = false
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                    end
                end
                
                -- Метод 2: Перемещаем под землю
                if foundVisualsPet.PrimaryPart then
                    foundVisualsPet.PrimaryPart.Position = foundVisualsPet.PrimaryPart.Position - Vector3.new(0, 1000, 0)
                elseif foundVisualsPet:FindFirstChild("RootPart") then
                    foundVisualsPet.RootPart.Position = foundVisualsPet.RootPart.Position - Vector3.new(0, 1000, 0)
                end
                
                -- Создаем копию UUID питомца на месте визуального
                local animatedCopy = createAnimatedCopyAtPosition(foundPet, visualPosition)
                    
                if animatedCopy then
                    -- Увеличиваем счетчик копий
                    createdCopiesCount = createdCopiesCount + 1
                    
                    -- СИНХРОНИЗИРУЕМ ВРЕМЯ ЖИЗНИ КОПИИ С ОРИГИНАЛОМ
                    print("⏰ Настраиваю синхронизацию времени жизни...")
                    
                    -- Отслеживаем удаление визуального питомца и заменяем питомца в handle
                    spawn(function()
                        while foundVisualsPet and foundVisualsPet.Parent do
                            wait(0.2) -- Проверяем каждые 0.2 секунды (оптимизация)
                        end
                        
                        -- Когда визуальный питомец исчез, удаляем копию
                        if animatedCopy and animatedCopy.Parent then
                            print("✨ Оригинал исчез - удаляю копию")
                            animatedCopy:Destroy()
                        end
                        
                        -- НОВОЕ: Заменяем питомца в handle на Dragonfly из инвентаря
                        wait(2) -- Ждем немного после исчезновения анимации
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
                            foundVisualsPet:SetPrimaryPartCFrame(foundVisualsPet.PrimaryPart.CFrame - Vector3.new(0, 1000, 0))
                        end
                        
                        print("✅ Визуальный питомец скрыт!")
                        print("🎉 Автозамена завершена - UUID питомец скопирован на место визуального!")
                        print("📊 Создано копий: " .. createdCopiesCount .. "/" .. MAX_COPIES)
                        
                        -- Добавляем в список найденных
                        table.insert(foundPetModels, {
                            name = foundPet.Name .. " -> " .. foundVisualsPet.Name,
                            foundTime = elapsed,
                            animatedCopy = animatedCopy
                        })
                    else
                        print("❌ Не удалось создать анимированную копию UUID питомца")
                    end
                else
                    print("❌ Не удалось определить позицию визуального питомца")
                end
            else
                print("⚠️ Не найден соответствующий визуальный питомец для замены")
            end
        end
    ) -- Закрывающая скобка для RunService.Heartbeat:Connect(function()
        
    -- Статистика каждые 10 секунд (ВНЕ функции)
    spawn(function()
        while true do
            wait(10)
            if #foundPetModels > 0 then
                print("📊 Статистика сканирования: найдено питомцев:", #foundPetModels)
            end
        end
    end)
    
    print("🔄 Полное сканирование Workspace активно!")
    print("💡 Все новые питомцы будут автоматически заменены на анимированные копии")
    print("🎯 Откройте яйцо для обнаружения питомца!")
    
    return connection
end

-- === МОНИТОРИНГ CHARACTER ДЛЯ ЗАМЕНЫ ПИТОМЦЕВ В РУКЕ ===
local function startCharacterPetMonitoring()
    print("\n🤏 === ЗАПУСК МОНИТОРИНГА CHARACTER ДЛЯ ЗАМЕНЫ ПИТОМЦЕВ В РУКЕ ===")
    print("👁️ Отслеживаю появление pet Models в Character (sibling к Tool)...")
    
    local lastCharacterChildren = {}
    local characterConnection
    local frameCount = 0
    
    characterConnection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        
        local playerChar = player.Character
        if not playerChar then return end
        
        -- Получаем текущих детей Character
        local currentChildren = {}
        for _, obj in pairs(playerChar:GetChildren()) do
            currentChildren[obj.Name] = obj
        end
        
        -- Ищем новые pet Models в Character
        for name, obj in pairs(currentChildren) do
            if not lastCharacterChildren[name] and obj:IsA("Model") then
                -- Проверяем что это питомец из яйца (НЕ UUID!)
                if (name:find("Golden Lab") or name:find("Dog") or name:find("Bunny") or 
                    name:find("Cat") or name:find("Rabbit")) and 
                   not name:find("%{") and not name:find("%}") then
                    
                    print("\n🥚 === ПИТОМЕЦ ИЗ ЯЙЦА ОБНАРУЖЕН В CHARACTER ===")
                    print("📛 Имя питомца:", name)
                    print("⏰ Время:", os.date("%H:%M:%S"))
                    
                    -- Проверяем есть ли соответствующий Tool
                    local correspondingTool = nil
                    for _, tool in pairs(playerChar:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:find("Golden Lab") or tool.Name:find("Dog") or 
                           tool.Name:find("Bunny") or tool.Name:find("Cat") or tool.Name:find("Rabbit") then
                            correspondingTool = tool
                            break
                        end
                    end
                    
                    if correspondingTool then
                        print("🔧 Найден соответствующий Tool:", correspondingTool.Name)
                        
                        -- Ждем 0.5 секунды чтобы соединения установились
                        spawn(function()
                            wait(0.5)
                            
                            print("🔍 Начинаю замену питомца в руке...")
                            
                            -- Проверяем что питомец все еще существует
                            if not obj or not obj.Parent then
                                print("❌ Питомец исчез из Character")
                                return
                            end
                            
                            -- Ищем Handle в Tool
                            local handle = correspondingTool:FindFirstChild("Handle")
                            if not handle then
                                print("❌ Handle не найден в Tool")
                                return
                            end
                            
                            -- Ищем ВСЕ соединения с Handle (расширенный поиск)
                            print("🔍 Ищу соединения с Handle...")
                            local handleWeld = nil
                            local allWelds = {}
                            
                            for _, weld in pairs(playerChar:GetDescendants()) do
                                if weld:IsA("Weld") or weld:IsA("WeldConstraint") or weld:IsA("Motor6D") then
                                    table.insert(allWelds, weld)
                                    
                                    -- Проверяем соединения с Handle
                                    if (weld.Part0 == handle or weld.Part1 == handle) then
                                        print("🔗 Найдено соединение с Handle:", weld.Name)
                                        print("  Part0:", weld.Part0 and weld.Part0.Name or "nil")
                                        print("  Part1:", weld.Part1 and weld.Part1.Name or "nil")
                                        
                                        -- Проверяем связь с питомцем
                                        local otherPart = weld.Part0 == handle and weld.Part1 or weld.Part0
                                        if otherPart and otherPart.Parent == obj then
                                            handleWeld = weld
                                            print("✅ Это соединение с нашим питомцем!")
                                        end
                                    end
                                end
                            end
                            
                            print("📊 Всего соединений найдено:", #allWelds)
                            
                            if not handleWeld then
                                print("❌ Прямое соединение Handle с питомцем не найдено")
                                print("🔍 Пробую найти любое соединение с питомцем...")
                                
                                -- Ищем любое соединение с частями питомца
                                for _, weld in pairs(allWelds) do
                                    local part0Parent = weld.Part0 and weld.Part0.Parent
                                    local part1Parent = weld.Part1 and weld.Part1.Parent
                                    
                                    if part0Parent == obj or part1Parent == obj then
                                        handleWeld = weld
                                        print("✅ Найдено альтернативное соединение:", weld.Name)
                                        break
                                    end
                                end
                            end
                            
                            if not handleWeld then
                                print("❌ Никаких соединений с питомцем не найдено - продолжаю без удаления соединения")
                            end
                            
                            if handleWeld then
                                print("🔗 Найдено соединение:", handleWeld.Name)
                            end
                            
                            -- Сохраняем позицию питомца в руке
                            local petCFrame = nil
                            if obj.PrimaryPart then
                                petCFrame = obj.PrimaryPart.CFrame
                                print("📍 Сохранена позиция через PrimaryPart:", petCFrame.Position)
                            elseif obj:FindFirstChild("RootPart") then
                                petCFrame = obj.RootPart.CFrame
                                print("📍 Сохранена позиция через RootPart:", petCFrame.Position)
                            else
                                print("⚠️ Не удалось найти RootPart для сохранения позиции")
                            end
                            
                            -- Определяем тип питомца для поиска UUID
                            local petType = nil
                            if name:find("Golden Lab") then
                                petType = "Golden Lab"
                            elseif name:find("Dog") then
                                petType = "Dog"
                            elseif name:find("Bunny") then
                                petType = "Bunny"
                            elseif name:find("Cat") then
                                petType = "Cat"
                            elseif name:find("Rabbit") then
                                petType = "Rabbit"
                            end
                            
                            if not petType then
                                print("❌ Не удалось определить тип питомца из имени:", name)
                                return
                            end
                            
                            print("🏷️ Тип питомца:", petType)
                            
                            -- Ищем соответствующий UUID питомец в Workspace (ИСПРАВЛЕННАЯ ЛОГИКА)
                            print("🔍 Ищу UUID питомца типа '" .. petType .. "' в Workspace...")
                            
                            local uuidPet = nil
                            local playerPos = playerChar.HumanoidRootPart.Position
                            local foundUUIDs = {}
                            
                            -- Сначала найдем ВСЕ UUID питомцы рядом
                            for _, wsObj in pairs(Workspace:GetDescendants()) do
                                if wsObj:IsA("Model") and wsObj.Name:find("%{") and wsObj.Name:find("%}") then
                                    local success, modelCFrame = pcall(function() return wsObj:GetModelCFrame() end)
                                    if success then
                                        local distance = (modelCFrame.Position - playerPos).Magnitude
                                        if distance <= CONFIG.SEARCH_RADIUS then
                                            -- Считаем MeshParts
                                            local meshCount = 0
                                            for _, desc in pairs(wsObj:GetDescendants()) do
                                                if desc:IsA("MeshPart") then
                                                    meshCount = meshCount + 1
                                                end
                                            end
                                            
                                            table.insert(foundUUIDs, {
                                                model = wsObj,
                                                distance = distance,
                                                meshCount = meshCount,
                                                name = wsObj.Name
                                            })
                                            
                                            print("🔑 Найден UUID:", wsObj.Name)
                                            print("    📏 Дистанция:", math.floor(distance))
                                            print("    🧩 MeshParts:", meshCount)
                                        end
                                    end
                                end
                            end
                            
                            print("📊 Всего UUID питомцев найдено:", #foundUUIDs)
                            
                            -- Ищем подходящий UUID питомец (сначала с 0 MeshParts, потом любой)
                            for _, uuid in pairs(foundUUIDs) do
                                if uuid.name:find(petType) and uuid.meshCount == 0 then
                                    uuidPet = uuid.model
                                    print("🎯 Выбран UUID с 0 MeshParts:", uuid.name)
                                    break
                                end
                            end
                            
                            -- Если не найден с 0 MeshParts, берем любой подходящий
                            if not uuidPet then
                                for _, uuid in pairs(foundUUIDs) do
                                    if uuid.name:find(petType) then
                                        uuidPet = uuid.model
                                        print("🎯 Выбран UUID (любой):", uuid.name, "MeshParts:", uuid.meshCount)
                                        break
                                    end
                                end
                            end
                            
                            -- Если все еще не найден, берем первый UUID
                            if not uuidPet and #foundUUIDs > 0 then
                                uuidPet = foundUUIDs[1].model
                                print("🎯 Выбран первый доступный UUID:", foundUUIDs[1].name)
                            end
                            
                            if not uuidPet then
                                print("❌ UUID питомец не найден рядом с игроком")
                                print("🔍 Попробуйте подойти ближе к UUID питомцам")
                                return
                            end
                            
                            print("⚡ === НАЧИНАЮ ЗАМЕНУ ПИТОМЦА В РУКЕ ===")
                            
                            -- Удаляем соединение с питомцем из яйца (если найдено)
                            if handleWeld then
                                handleWeld:Destroy()
                                print("🗑️ Старое соединение удалено:", handleWeld.Name)
                            else
                                print("⚠️ Соединение не найдено - продолжаю замену")
                            end
                            
                            -- Удаляем питомца из яйца
                            obj:Destroy()
                            print("🗑️ Питомец из яйца удален из Character:", name)
                            
                            -- Клонируем UUID питомца в Character
                            local uuidClone = uuidPet:Clone()
                            uuidClone.Name = uuidPet.Name -- Сохраняем UUID имя
                            uuidClone.Parent = playerChar
                            print("📋 UUID питомец клонирован в Character:", uuidClone.Name)
                            
                            -- Ждем чтобы клон полностью загрузился
                            wait(0.1)
                            
                            -- Находим RootPart клона
                            local cloneRootPart = nil
                            if uuidClone.PrimaryPart then
                                cloneRootPart = uuidClone.PrimaryPart
                                print("📍 Использую PrimaryPart как RootPart:", cloneRootPart.Name)
                            elseif uuidClone:FindFirstChild("RootPart") then
                                cloneRootPart = uuidClone:FindFirstChild("RootPart")
                                print("📍 Найден RootPart:", cloneRootPart.Name)
                            else
                                -- Ищем любую BasePart как RootPart
                                for _, part in pairs(uuidClone:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        cloneRootPart = part
                                        print("📍 Использую как RootPart:", part.Name)
                                        break
                                    end
                                end
                            end
                            
                            if not cloneRootPart then
                                print("❌ Не найден RootPart у клона UUID питомца")
                                return
                            end
                            
                            -- КРИТИЧНО: Сначала создаем Weld, ПОТОМ устанавливаем позицию
                            local newWeld = Instance.new("Weld")
                            newWeld.Name = "Handle_RootPart_WELD"
                            newWeld.Part0 = handle
                            newWeld.Part1 = cloneRootPart
                            
                            -- Устанавливаем правильные CFrame для Weld
                            if petCFrame then
                                -- Вычисляем относительную позицию
                                local relativeC0 = handle.CFrame:Inverse() * petCFrame
                                newWeld.C0 = CFrame.new() -- Handle остается на месте
                                newWeld.C1 = relativeC0 -- Питомец в нужной позиции относительно Handle
                                print("📍 Установлены CFrame для Weld")
                            end
                            
                            newWeld.Parent = playerChar
                            print("🔗 Новое соединение создано:", newWeld.Name)
                            
                            -- Настраиваем физику питомца для руки
                            cloneRootPart.Anchored = false
                            cloneRootPart.CanCollide = false
                            
                            -- Настраиваем остальные части
                            for _, part in pairs(uuidClone:GetDescendants()) do
                                if part:IsA("BasePart") and part ~= cloneRootPart then
                                    part.Anchored = false
                                    part.CanCollide = false
                                end
                            end
                            
                            print("⚙️ Физика питомца настроена для руки")
                            
                            -- Запускаем живое копирование анимации
                            print("🎭 Запускаю живое копирование анимации...")
                            startLiveMotorCopying(uuidPet, uuidClone)
                            
                            -- КРИТИЧНО: Ждем установки Weld перед принудительным удержанием
                            wait(0.2)
                            
                            -- Проверяем что Weld работает
                            if newWeld and newWeld.Part0 and newWeld.Part1 then
                                print("✅ Weld активен:", newWeld.Part0.Name, "↔", newWeld.Part1.Name)
                            else
                                print("❌ Weld не работает правильно")
                            end
                            
                            -- Принудительное удержание в руке (ИСПРАВЛЕННАЯ ЛОГИКА)
                            print("🔒 Запускаю принудительное удержание UUID питомца в руке...")
                            spawn(function()
                                local holdConnection
                                holdConnection = RunService.Heartbeat:Connect(function()
                                    -- Проверяем что клон существует
                                    if not uuidClone or not uuidClone.Parent then
                                        if holdConnection then
                                            holdConnection:Disconnect()
                                        end
                                        return
                                    end
                                    
                                    -- Проверяем что клон в Character
                                    if uuidClone.Parent ~= playerChar then
                                        print("🔒 Возвращаю UUID питомца в Character")
                                        uuidClone.Parent = playerChar
                                    end
                                    
                                    -- Проверяем и восстанавливаем соединение
                                    if not newWeld or not newWeld.Parent or newWeld.Part0 ~= handle or newWeld.Part1 ~= cloneRootPart then
                                        print("🔧 Восстанавливаю соединение Handle ↔ UUID питомец")
                                        
                                        -- Удаляем старое соединение если есть
                                        if newWeld then
                                            newWeld:Destroy()
                                        end
                                        
                                        -- Создаем новое соединение
                                        newWeld = Instance.new("Weld")
                                        newWeld.Name = "Handle_RootPart_WELD"
                                        newWeld.Part0 = handle
                                        newWeld.Part1 = cloneRootPart
                                        newWeld.Parent = playerChar
                                        
                                        -- Устанавливаем правильную позицию через Weld
                                        if petCFrame then
                                            newWeld.C0 = CFrame.new()
                                            newWeld.C1 = handle.CFrame:Inverse() * petCFrame
                                        end
                                    end
                                    
                                    -- Убеждаемся что RootPart правильно настроен
                                    if cloneRootPart then
                                        cloneRootPart.Anchored = false
                                        cloneRootPart.CanCollide = false
                                        
                                        -- Если Weld не держит позицию, принудительно устанавливаем
                                        if petCFrame and (cloneRootPart.Position - petCFrame.Position).Magnitude > 5 then
                                            print("🔒 Принудительно корректирую позицию питомца")
                                            cloneRootPart.CFrame = petCFrame
                                        end
                                    end
                                end)
                            end)
                            
                            print("✅ === ЗАМЕНА ПИТОМЦА В РУКЕ ЗАВЕРШЕНА ===")
                            print("🔑 UUID питомец с анимацией теперь в руке!")
                        end)
                    else
                        print("❌ Соответствующий Tool не найден")
                    end
                end
            end
        end
        
        -- Обновляем состояние
        lastCharacterChildren = currentChildren
        
        -- Периодическая диагностика
        if frameCount % 1800 == 0 then -- Каждые 30 секунд
            print("\n📊 === МОНИТОРИНГ CHARACTER ===")
            print("⏰ Время:", os.date("%H:%M:%S"))
            print("🎯 Кадр:", frameCount)
            
            local toolCount = 0
            local petCount = 0
            for _, obj in pairs(playerChar:GetChildren()) do
                if obj:IsA("Tool") then
                    toolCount = toolCount + 1
                elseif obj:IsA("Model") and (obj.Name:find("Golden") or obj.Name:find("Dog") or obj.Name:find("Bunny")) then
                    petCount = petCount + 1
                end
            end
            
            print("🔧 Tools в Character:", toolCount)
            print("🐾 Pet Models в Character:", petCount)
        end
    end)
    
    print("✅ Мониторинг Character для замены питомцев в руке запущен!")
    return characterConnection
end

-- Создание GUI (С ЗАЩИТОЙ ОТ ОШИБОК)
local function createGUI()
    local success, errorMsg = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        local oldGui = playerGui:FindFirstChild("PetScalerV2GUI")
        if oldGui then
            oldGui:Destroy()
            wait(0.1) -- Небольшая пауза после удаления
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PetScalerV2GUI"
        screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 120) -- Увеличено для третьей кнопки
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
    
    -- Кнопка мониторинга Character (замена в руке)
    local handButton = Instance.new("TextButton")
    handButton.Name = "HandReplaceButton"
    handButton.Size = UDim2.new(0, 230, 0, 30)
    handButton.Position = UDim2.new(0, 10, 0, 80)
    handButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    handButton.BorderSizePixel = 0
    handButton.Text = "🤏 Замена в руке (ОФФ)"
    handButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    handButton.TextSize = 12
    handButton.Font = Enum.Font.SourceSansBold
    handButton.Parent = frame
    
    -- Переменные для отслеживания состояния
    local autoReplaceActive = false
    local visualsConnection = nil
    local handReplaceActive = false
    local characterConnection = nil
    
    -- Обработчик ручной кнопки
    manualButton.MouseButton1Click:Connect(function()
        manualButton.Text = "⏳ Создаю с анимацией..."
        manualButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            local success, errorMsg = pcall(function()
                main()
            end)
            
            if success then
                wait(3)
                manualButton.Text = "🔥 Ручное создание копии"
                manualButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                print("❌ Ошибка в main():", errorMsg)
                manualButton.Text = "❌ Ошибка! Попробуйте снова"
                manualButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end)
    end)
    
    -- Обработчик кнопки автозамены
    autoButton.MouseButton1Click:Connect(function()
        if not autoReplaceActive then
            -- Включаем автозамену
            autoButton.Text = "⏳ Запускаю мониторинг..."
            autoButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            
            spawn(function()
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
    
    -- Обработчик кнопки мониторинга Character (замена в руке)
    handButton.MouseButton1Click:Connect(function()
        if not handReplaceActive then
            -- Включаем мониторинг Character
            handButton.Text = "⏳ Запускаю мониторинг руки..."
            handButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            
            spawn(function()
                characterConnection = startCharacterPetMonitoring()
                handReplaceActive = true
                
                handButton.Text = "🤏 Замена в руке (ОН)"
                handButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            end)
        else
            -- Отключаем мониторинг Character
            if characterConnection then
                characterConnection:Disconnect()
                characterConnection = nil
            end
            
            handReplaceActive = false
            handButton.Text = "🤏 Замена в руке (ОФФ)"
            handButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
            
            print("❌ Мониторинг Character остановлен")
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
    
    -- Hover эффекты для кнопки мониторинга руки
    handButton.MouseEnter:Connect(function()
        if handButton.BackgroundColor3 == Color3.fromRGB(128, 0, 255) then
            handButton.BackgroundColor3 = Color3.fromRGB(108, 0, 235)
        elseif handButton.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
            handButton.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        end
    end)
    
    handButton.MouseLeave:Connect(function()
        if handButton.BackgroundColor3 == Color3.fromRGB(108, 0, 235) then
            handButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
        elseif handButton.BackgroundColor3 == Color3.fromRGB(0, 220, 0) then
            handButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
    
        print("💻 PetScaler v2.0 GUI с мониторингом руки создан!")
    end)
    
    if not success then
        print("❌ Ошибка при создании GUI:", errorMsg)
        print("📝 Попробуйте перезапустить скрипт")
        return false
    end
    
    return true
end

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
