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

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    START_SCALE = 0.3,   -- Начальный размер (маленький)
    FINAL_SCALE = 1.0,   -- Конечный размер (нормальный)
    TWEEN_TIME = 3.0,    -- Время анимации роста (секунды)
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

-- Умный контроллер поведения: 10-15 сек idle, потом короткая ходьба
local function createSmartBehaviorController(petModel)
    print("🧠 Умный контроллер поведения: 10-15 сек idle, потом короткая ходьба")
    
    local rootPart = petModel:FindFirstChild("RootPart") or 
                     petModel:FindFirstChild("Torso") or 
                     petModel:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        print("  ⚠️ Корневая часть не найдена")
        return nil
    end
    
    -- Конфигурация циклов
    local IDLE_TIME_MIN = 10 -- Минимальное время idle (сек)
    local IDLE_TIME_MAX = 15 -- Максимальное время idle (сек)
    local WALK_TIME_MAX = 2  -- Максимальное время ходьбы (сек)
    
    -- Состояние контроллера
    local currentState = "IDLE" -- "IDLE" или "WALK"
    local stateStartTime = tick()
    local nextStateChangeTime = tick() + math.random(IDLE_TIME_MIN, IDLE_TIME_MAX)
    
    -- Сохраняем базовую позицию
    local basePosition = rootPart.Position
    
    print("  📍 Базовая позиция:", basePosition)
    print("  ⏰ Начинаю с IDLE режима на", math.floor(nextStateChangeTime - tick()), "сек")
    
    -- Находим Humanoid для управления поведением
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    
    -- Функция переключения в IDLE режим
    local function switchToIdle()
        currentState = "IDLE"
        stateStartTime = tick()
        nextStateChangeTime = tick() + math.random(IDLE_TIME_MIN, IDLE_TIME_MAX)
        
        print("  😴 Переключаю в IDLE на", math.floor(nextStateChangeTime - tick()), "сек")
        
        -- Заякориваем только корень для анимации
        rootPart.Anchored = true
        
        -- Останавливаем движение через Humanoid
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid:MoveTo(basePosition)
        end
        
        -- Возвращаем к базовой позиции
        rootPart.CFrame = CFrame.new(basePosition, basePosition + Vector3.new(0, 0, 1))
    end
    
    -- Функция переключения в WALK режим
    local function switchToWalk()
        currentState = "WALK"
        stateStartTime = tick()
        nextStateChangeTime = tick() + math.random(1, WALK_TIME_MAX)
        
        print("  🚶 Разрешаю ходьбу на", math.floor(nextStateChangeTime - tick()), "сек")
        
        -- Освобождаем корень для движения
        rootPart.Anchored = false
        
        -- Разрешаем медленное движение
        if humanoid then
            humanoid.WalkSpeed = 4 -- Медленная ходьба
        end
    end
    
    -- Начинаем с IDLE
    switchToIdle()
    
    -- Основной цикл контроллера
    local connection = RunService.Heartbeat:Connect(function()
        if not petModel.Parent or not rootPart.Parent then
            connection:Disconnect()
            return
        end
        
        local currentTime = tick()
        
        -- Проверяем нужно ли переключить состояние
        if currentTime >= nextStateChangeTime then
            if currentState == "IDLE" then
                switchToWalk()
            else
                switchToIdle()
            end
        end
        
        -- В IDLE режиме принудительно удерживаем позицию
        if currentState == "IDLE" then
            local distanceFromBase = (rootPart.Position - basePosition).Magnitude
            if distanceFromBase > 3 then -- Если ушел далеко от базы
                rootPart.CFrame = CFrame.new(basePosition, basePosition + Vector3.new(0, 0, 1))
                if humanoid then
                    humanoid:MoveTo(basePosition)
                end
            end
        end
        
        -- В WALK режиме ограничиваем радиус ходьбы
        if currentState == "WALK" then
            local distanceFromBase = (rootPart.Position - basePosition).Magnitude
            if distanceFromBase > 8 then -- Максимальный радиус ходьбы
                if humanoid then
                    humanoid:MoveTo(basePosition) -- Возвращаем к базе
                end
            end
        end
    end)
    
    print("  ✅ Умный контроллер активен - циклы IDLE/WALK запущены")
    return connection
end

-- Функция копирования состояния Motor6D с масштабированием И фильтрацией анимаций
local function copyMotorStateFiltered(originalMotor, copyMotor, scaleFactor, originalModel, copyModel)
    if not originalMotor or not copyMotor then
        return false
    end
    
    -- ФИЛЬТР АНИМАЦИЙ: Проверяем движется ли оригинальный питомец
    local originalRoot = originalModel:FindFirstChild("RootPart") or 
                        originalModel:FindFirstChild("Torso") or 
                        originalModel:FindFirstChild("HumanoidRootPart")
    
    local copyRoot = copyModel:FindFirstChild("RootPart") or 
                    copyModel:FindFirstChild("Torso") or 
                    copyModel:FindFirstChild("HumanoidRootPart")
    
    if originalRoot and copyRoot then
        -- Проверяем скорость движения оригинала
        local originalVelocity = originalRoot.Velocity.Magnitude
        
        -- Если оригинал быстро движется (ходит) - НЕ копируем движение
        if originalVelocity > 2 then
            -- print("🚫 Блокирую копирование walking анимации (скорость:", math.floor(originalVelocity), ")")
            return false -- НЕ копируем walking движения
        end
    end
    
    -- КОПИРУЕМ только если это idle анимация (медленное движение)
    -- ИСПРАВЛЕНО: Масштабируем позиционные компоненты Motor6D
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

-- Функция РОСТА модели (от маленького до нормального размера)
local function growModelFromSmall(model, startScale, finalScale, tweenTime)
    print("🌱 Начинаю РОСТ модели:", model.Name)
    print("📈 От", startScale .. "x", "до", finalScale .. "x", "за", tweenTime, "сек")
    
    local parts = getAllParts(model)
    print("🧩 Найдено частей для роста:", #parts)
    
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
    
    -- НОВАЯ ЛОГИКА РОСТА: сначала уменьшаем мгновенно, потом плавно увеличиваем
    print("🔄 Шаг 1: Мгновенно уменьшаю все части до " .. startScale .. "x")
    
    -- Сначала МГНОВЕННО уменьшаем все части до маленького размера
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        -- Уменьшаем до стартового размера МГНОВЕННО
        local smallSize = originalSize * startScale
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local smallRelativeCFrame = CFrame.new(relativeCFrame.Position * startScale) * (relativeCFrame - relativeCFrame.Position)
        local smallCFrame = centerCFrame * smallRelativeCFrame
        
        -- Устанавливаем маленький размер сразу
        part.Size = smallSize
        part.CFrame = smallCFrame
    end
    
    print("✅ Все части уменьшены до " .. startScale .. "x")
    print("🔄 Шаг 2: Плавно увеличиваю до " .. finalScale .. "x за " .. tweenTime .. " сек")
    
    -- Теперь ПЛАВНО увеличиваем до финального размера
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        -- Вычисляем финальный размер
        local finalSize = originalSize * finalScale
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local finalRelativeCFrame = CFrame.new(relativeCFrame.Position * finalScale) * (relativeCFrame - relativeCFrame.Position)
        local finalCFrame = centerCFrame * finalRelativeCFrame
        
        -- Создаем твин для роста от маленького до финального размера
        local tween = TweenService:Create(part, tweenInfo, {
            Size = finalSize,
            CFrame = finalCFrame
        })
        
        -- Обработчик завершения твина
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ РОСТ завершен!")
                print("🎉 Питомец вырос от " .. startScale .. "x до " .. finalScale .. "x!")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    print("🚀 Запущено " .. #tweens .. " твинов для плавного роста")
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
        
        -- Копируем состояния Motor6D с масштабированием И фильтрацией
        for key, originalMotor in pairs(originalMap) do
            local copyMotor = copyMap[key]
            if copyMotor and originalMotor.Parent then
                copyMotorStateFiltered(originalMotor, copyMotor, CONFIG.FINAL_SCALE, original, copy)
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
    local scaleSuccess = growModelFromSmall(petCopy, CONFIG.START_SCALE, CONFIG.FINAL_SCALE, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование не удалось!")
        return
    end
    
    -- Шаг 4: ПОСЛЕ масштабирования настраиваем Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ДЛЯ АНИМАЦИИ ===")
    wait(CONFIG.TWEEN_TIME + 1) -- Ждем завершения масштабирования
    
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 5: Запуск живого копирования Motor6D
    print("\n🎭 === ЗАПУСК АНИМАЦИИ ===")
    
    local connection = startLiveMotorCopying(petModel, petCopy)
    
    -- Шаг 6: НОВЫЙ ПОДХОД - контролируем ОРИГИНАЛЬНОГО питомца!
    print("\n🎯 === НОВЫЙ ПОДХОД: КОНТРОЛЬ ОРИГИНАЛА ===")
    print("💡 Идея: заставляем оригинального питомца стоять, тогда копия будет копировать только idle!")
    wait(0.5)
    
    -- Находим оригинального питомца
    local originalRoot = petModel:FindFirstChild("RootPart") or 
                        petModel:FindFirstChild("Torso") or 
                        petModel:FindFirstChild("HumanoidRootPart")
    
    local originalHumanoid = petModel:FindFirstChildOfClass("Humanoid")
    
    if originalRoot then
        print("  🐕 Нашел оригинального питомца:", petModel.Name)
        
        -- Сохраняем исходную позицию оригинала
        local originalPosition = originalRoot.Position
        
        -- Заякориваем оригинального питомца
        originalRoot.Anchored = true
        
        -- Отключаем его AI
        if originalHumanoid then
            originalHumanoid.WalkSpeed = 0
            originalHumanoid.JumpPower = 0
            originalHumanoid.PlatformStand = true
            print("  🤖 Отключил AI оригинального питомца")
        end
        
        print("  ✅ Оригинальный питомец зафиксирован - теперь копия будет копировать только idle!")
    else
        print("  ⚠️ Не нашел корень оригинального питомца")
    end
    
    -- Копию оставляем с обычным Anchored управлением (только корень)
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    print("  💭 Теперь оригинал не ходит → копия копирует только idle анимации!")
    
    if connection then
        print("🎉 === ПОЛНЫЙ УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Анимация запущена")
        print("✅ Движение заблокировано")
        print("💡 Питомец стоит на месте с анимацией стояния!")
    else
        print("⚠️ Масштабирование успешно, но анимация не запустилась")
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
