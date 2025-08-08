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

-- Функция полного сканирования Workspace (ИСПРАВЛЕНО)
local function startWorkspaceScanning()
    print("\n🔍 === ЗАПУСК ПОЛНОГО СКАНИРОВАНИЯ WORKSPACE (С ЗАЩИТОЙ) ===")
    print("💡 Используется метод из ComprehensiveEggPetAnimationAnalyzer + строгая фильтрация")
    
    local processedModels = {}
    local foundPetModels = {}
    local createdCopiesCount = 0 -- Счетчик созданных копий
    local MAX_COPIES = 3 -- Максимум копий за сессию
    local processedPetNames = {} -- Отслеживание по именам
    local scanStartTime = tick()
    
    -- Ключевые слова питомцев
    local PET_KEYWORDS = {
        "dog", "bunny", "golden lab", "cat", "rabbit", "pet", "animal", "golden", "lab"
    }
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - scanStartTime
        
        -- Ограничиваем время сканирования
        if elapsed > 300 then -- 5 минут максимум
            print("⏰ Сканирование остановлено по таймауту")
            connection:Disconnect()
            return
        end
        
        -- Сканируем все модели в Workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= player.Character and not processedModels[obj] then
                processedModels[obj] = true
                
                if isPetModel(obj) then
                    -- КРИТИЧНО: Проверяем лимит копий
                    if createdCopiesCount >= MAX_COPIES then
                        print("⚠️ Достигнут лимит копий (" .. MAX_COPIES .. "). Останавливаю сканирование.")
                        connection:Disconnect()
                        return
                    end
                    
                    -- КРИТИЧНО: Проверяем, не обрабатывали ли уже питомца с таким именем
                    if processedPetNames[obj.Name] then
                        return -- Пропускаем, уже обработали
                    end
                    
                    -- Проверяем на ключевые слова питомцев
                    local isPotentialPet = false
                    local objNameLower = obj.Name:lower()
                    for _, keyword in pairs(PET_KEYWORDS) do
                        if objNameLower:find(keyword) then
                            isPotentialPet = true
                            break
                        end
                    end
                    
                    -- Дополнительная проверка: исключаем только EggExplode
                    if obj.Name == "EggExplode" then
                        isPotentialPet = false
                    end
                    
                    if isPotentialPet then
                        -- Отмечаем как обработанного
                        processedPetNames[obj.Name] = true
                        print("\n🥚 === ОБНАРУЖЕН НОВЫЙ ПИТОМЕЦ ===")
                        print("🐾 Имя питомца:", obj.Name)
                        print("📍 Время обнаружения:", string.format("%.1f сек", elapsed))
                        
                        -- Получаем позицию оригинального питомца
                        local originalPosition
                        if obj.PrimaryPart then
                            originalPosition = obj.PrimaryPart.Position
                        elseif obj:FindFirstChild("RootPart") then
                            originalPosition = obj.RootPart.Position
                        else
                            local firstPart = obj:FindFirstChildOfClass("BasePart")
                            if firstPart then
                                originalPosition = firstPart.Position
                            end
                        end
                        
                        if originalPosition then
                            print("📍 Позиция оригинального питомца:", originalPosition)
                            
                            -- Создаем анимированную копию на том же месте
                            local animatedCopy = createAnimatedCopyAtPosition(obj, originalPosition)
                            
                            if animatedCopy then
                                -- Увеличиваем счетчик копий
                                createdCopiesCount = createdCopiesCount + 1
                                
                                -- Скрываем/удаляем оригинальный питомец
                                print("🙈 Скрываю оригинального питомца...")
                                
                                -- Вариант 1: Делаем невидимым
                                for _, part in pairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.Transparency = 1
                                    elseif part:IsA("Decal") or part:IsA("Texture") then
                                        part.Transparency = 1
                                    end
                                end
                                
                                -- Вариант 2: Перемещаем под землю
                                if obj.PrimaryPart then
                                    obj:SetPrimaryPartCFrame(obj.PrimaryPart.CFrame - Vector3.new(0, 1000, 0))
                                end
                                
                                print("✅ Оригинальный питомец скрыт!")
                                print("🎉 Замена завершена - теперь показывается анимированная копия!")
                                print("📊 Создано копий: " .. createdCopiesCount .. "/" .. MAX_COPIES)
                                
                                -- Добавляем в список найденных
                                table.insert(foundPetModels, {
                                    name = obj.Name,
                                    foundTime = elapsed,
                                    animatedCopy = animatedCopy
                                })
                            else
                                print("❌ Не удалось создать анимированную копию")
                            end
                        else
                            print("❌ Не удалось определить позицию оригинального питомца")
                        end
                    end
                end
            end
        end
        
        -- Статистика каждые 10 секунд
        if math.floor(elapsed) % 10 == 0 and math.floor(elapsed) > 0 then
            print("📊 Статистика сканирования:", string.format("%.1f сек", elapsed), "- найдено питомцев:", #foundPetModels)
        end
    end)
    
    print("🔄 Полное сканирование Workspace активно!")
    print("💡 Все новые питомцы будут автоматически заменены на анимированные копии")
    print("🎯 Откройте яйцо для обнаружения питомца!")
    
    return connection
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
    frame.Size = UDim2.new(0, 250, 0, 85)
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
    
    -- Переменная для отслеживания состояния автозамены
    local autoReplaceActive = false
    local visualsConnection = nil
    
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
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 70))
print("💡 PETSCALER v2.0 + АВТОЗАМЕНА - ПОЛНОЕ РЕШЕНИЕ:")
print("   🔥 РУЧНОЕ СОЗДАНИЕ:")
print("     1. Создает масштабированную копию")
print("     2. Настраивает правильные Anchored состояния")
print("     3. Автоматически запускает живое копирование анимации")
print("")
print("   🥚 НОВОЕ! АВТОЗАМЕНА ПИТОМЦЕВ:")
print("     1. Мониторит workspace.visuals")
print("     2. Автоматически скрывает оригинальных питомцев")
print("     3. Создает анимированные копии на том же месте")
print("     4. Никаких статичных копий - только живая анимация!")
print("")
print("🎯 ИСПОЛЬЗОВАНИЕ:")
print("   🔥 Зеленая кнопка - Ручное создание копии")
print("   🥚 Оранжевая кнопка - Вкл/Откл автозамену питомцев")
print("=" .. string.rep("=", 70))
