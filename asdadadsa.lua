-- 🔥 PET SCALER v2.5 - НЕЗАВИСИМАЯ КОПИЯ С ТОЛЬКО IDLE
-- Создает независимую копию с собственной idle анимацией
-- НЕ копирует движения оригинала - только idle!

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v2.5 - НЕЗАВИСИМАЯ КОПИЯ С IDLE ===")
print("=" .. string.rep("=", 70))

-- Конфигурация для независимой копии
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 1.0,  -- Оригинальный размер (как ты хотел)
    TWEEN_TIME = 3.0,
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out,
    IDLE_RECORD_TIME = 3,  -- Время записи idle поз
    IDLE_FRAME_RATE = 60   -- Частота записи idle
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

-- === ФУНКЦИИ НЕЗАВИСИМОЙ IDLE АНИМАЦИИ ===

-- Поиск питомца с фигурными скобками (рабочая версия)
local function findPetWithBraces()
    print("🔍 Поиск питомцев с фигурными скобками...")
    
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
                        print("🐾 Найден питомец:", obj.Name, "на расстоянии:", math.floor(distance))
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        return nil
    end
    
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец:", targetPet.model.Name)
    
    return targetPet.model
end

-- Проверка на магический idle момент
local function isMagicalIdleMoment(petModel)
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    
    -- Условие 1: Нет движения
    local noMovement = true
    if humanoid then
        noMovement = humanoid.MoveDirection.Magnitude < 0.01
    end
    
    -- Условие 2: Есть только idle анимации
    local hasOnlyIdleAnimation = false
    local animationCount = 0
    
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            animationCount = #tracks
            
            if animationCount > 0 then
                hasOnlyIdleAnimation = true
                for _, track in pairs(tracks) do
                    local name = track.Animation.Name:lower()
                    local id = track.Animation.AnimationId:lower()
                    
                    if not name:find("idle") and not id:find("1073293904134356") then
                        hasOnlyIdleAnimation = false
                        break
                    end
                end
            end
            break
        end
    end
    
    return noMovement and hasOnlyIdleAnimation and animationCount > 0
end

-- Запись idle поз с оригинала
local function recordIdlePoses(petModel)
    print("🎬 Записываю idle позы оригинала...")
    
    local motor6Ds = {}
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6Ds, obj)
        end
    end
    
    if #motor6Ds == 0 then
        print("❌ Motor6D не найдены!")
        return nil
    end
    
    print("🔧 Найдено Motor6D:", #motor6Ds)
    
    local poses = {}
    local frameCount = 0
    local targetFrames = CONFIG.IDLE_RECORD_TIME * CONFIG.IDLE_FRAME_RATE
    
    local recordConnection
    recordConnection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        
        local framePoses = {}
        for _, motor in pairs(motor6Ds) do
            framePoses[motor.Name] = {
                C0 = motor.C0,
                C1 = motor.C1,
                Transform = motor.Transform
            }
        end
        
        table.insert(poses, framePoses)
        
        if frameCount >= targetFrames then
            recordConnection:Disconnect()
        end
    end)
    
    while frameCount < targetFrames and recordConnection.Connected do
        wait(0.1)
    end
    
    print(string.format("✅ Записано %d idle поз!", #poses))
    return poses, motor6Ds
end

-- Создание независимой idle анимации для копии
local function createIndependentIdleAnimation(copyModel, idlePoses, originalMotors)
    print("🎭 Создаю независимую idle анимацию для копии...")
    
    -- Находим Motor6D в копии
    local copyMotors = {}
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            copyMotors[obj.Name] = obj
        end
    end
    
    if #idlePoses == 0 or getTableSize(copyMotors) == 0 then
        print("❌ Нет idle поз или Motor6D в копии!")
        return nil
    end
    
    print("🔧 Найдено Motor6D в копии:", #copyMotors)
    
    -- КРИТИЧНО: Отключаем все анимационные системы копии
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Humanoid") then
            obj:Destroy()  -- Удаляем Humanoid - никакой AI!
            print("💀 Humanoid удален из копии - никакой AI!")
        end
        if obj:IsA("Animator") then
            obj.Enabled = false
            print("❄️ Animator отключен в копии")
        end
        if obj:IsA("AnimationController") then
            obj.Enabled = false
            print("❄️ AnimationController отключен в копии")
        end
    end
    
    -- Запускаем независимую idle анимацию
    local currentFrame = 1
    local frameRate = CONFIG.IDLE_FRAME_RATE
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    local idleConnection
    idleConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - lastFrameTime >= frameInterval then
            lastFrameTime = now
            
            local framePoses = idlePoses[currentFrame]
            if framePoses then
                for _, motor in pairs(copyMotors) do
                    local pose = framePoses[motor.Name]
                    if pose then
                        pcall(function()
                            -- Применяем idle позы с масштабированием
                            motor.C0 = pose.C0 * CONFIG.SCALE_FACTOR
                            motor.C1 = pose.C1 * CONFIG.SCALE_FACTOR
                            motor.Transform = pose.Transform
                        end)
                    end
                end
            end
            
            currentFrame = currentFrame + 1
            if currentFrame > #idlePoses then
                currentFrame = 1  -- Зацикливаем idle анимацию
            end
        end
    end)
    
    print("✅ Независимая idle анимация запущена!")
    print("🔄 Копия будет ТОЛЬКО в idle - никакой ходьбы!")
    print("🚫 Humanoid удален - копия полностью независима!")
    
    return idleConnection
end

-- Автоматический поиск и запись idle момента
local function autoFindAndRecordIdle(petModel)
    print("🔍 Автоматический поиск idle момента...")
    print("⏰ Максимальное время: 60 секунд")
    
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    return new Promise(function(resolve, reject)
        local searchConnection
        searchConnection = RunService.Heartbeat:Connect(function()
            local now = tick()
            
            if now - lastCheckTime >= 0.1 then
                lastCheckTime = now
                
                if isMagicalIdleMoment(petModel) then
                    print("🌟 МАГИЧЕСКИЙ IDLE МОМЕНТ НАЙДЕН!")
                    searchConnection:Disconnect()
                    
                    local idlePoses, motors = recordIdlePoses(petModel)
                    if idlePoses then
                        resolve({poses = idlePoses, motors = motors})
                    else
                        reject("Не удалось записать idle позы")
                    end
                    return
                end
                
                if now - searchStartTime >= 60 then
                    searchConnection:Disconnect()
                    reject("Время поиска idle момента истекло")
                end
            end
        end)
    end)
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
        
        -- Копируем состояния Motor6D с масштабированием
        for key, originalMotor in pairs(originalMap) do
            local copyMotor = copyMap[key]
            if copyMotor and originalMotor.Parent then
                copyMotorState(originalMotor, copyMotor, CONFIG.SCALE_FACTOR)
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

-- Функция поиска питомца с фигурными скобками
local function findPetWithBraces()
    print("🔍 Поиск питомца с фигурными скобками...")
    
    local foundPets = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            table.insert(foundPets, obj)
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        return nil
    end
    
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец:", targetPet.Name)
    
    return targetPet
end

-- Главная функция с независимой idle анимацией
local function main()
    print("\n🚀 === ЗАПУСК PETSCALER v2.5 - НЕЗАВИСИМАЯ КОПИЯ ===")
    
    -- Шаг 1: Поиск питомца с фигурными скобками
    print("\n🔍 === ПОИСК ПИТОМЦА ===")
    
    local petModel = findPetWithBraces()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    -- Шаг 2: Автоматический поиск idle момента
    print("\n🌟 === ПОИСК IDLE МОМЕНТА ===")
    print("💡 Дождись когда питомец встанет в idle позу...")
    
    -- Используем простой подход без Promise
    local idleData = nil
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    local searchConnection
    searchConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - lastCheckTime >= 0.1 then
            lastCheckTime = now
            
            if isMagicalIdleMoment(petModel) then
                print("🌟 МАГИЧЕСКИЙ IDLE МОМЕНТ НАЙДЕН!")
                searchConnection:Disconnect()
                
                local idlePoses, motors = recordIdlePoses(petModel)
                if idlePoses then
                    idleData = {poses = idlePoses, motors = motors}
                end
                return
            end
            
            -- Показываем прогресс каждые 10 секунд
            if math.floor(now - searchStartTime) % 10 == 0 and (now - searchStartTime) % 10 < 0.1 then
                print(string.format("🔍 Поиск idle момента... %.0f сек", now - searchStartTime))
            end
            
            if now - searchStartTime >= 60 then
                searchConnection:Disconnect()
                print("⏰ Время поиска idle момента истекло!")
                return
            end
        end
    end)
    
    -- Ждем результат поиска
    while not idleData and searchConnection.Connected do
        wait(0.1)
    end
    
    if not idleData then
        print("❌ Не удалось найти idle момент!")
        print("💡 Попробуй еще раз когда питомец будет стоять спокойно")
        return
    end
    
    -- Шаг 3: Создание независимой копии
    print("\n📋 === СОЗДАНИЕ НЕЗАВИСИМОЙ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- Шаг 4: Масштабирование (если нужно)
    if CONFIG.SCALE_FACTOR ~= 1.0 then
        print("\n🔥 === МАСШТАБИРОВАНИЕ ===")
        
        -- Временно делаем все части Anchored для стабильности
        for _, part in pairs(getAllParts(petCopy)) do
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
        
        wait(CONFIG.TWEEN_TIME + 1) -- Ждем завершения масштабирования
    end
    
    -- Шаг 5: Настройка Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ДЛЯ АНИМАЦИИ ===")
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 6: Запуск независимой idle анимации
    print("\n🎭 === ЗАПУСК НЕЗАВИСИМОЙ IDLE АНИМАЦИИ ===")
    
    local idleConnection = createIndependentIdleAnimation(petCopy, idleData.poses, idleData.motors)
    
    if idleConnection then
        print("🎉 === УСПЕХ! ===")
        print("✅ Независимая копия создана")
        print("✅ Только idle анимация запущена")
        print("🚫 Копия НЕ копирует движения оригинала")
        print("💀 Humanoid удален - копия полностью независима")
        print("🔄 Копия будет ТОЛЬКО в idle - никакой ходьбы!")
        
        -- Автоматическая остановка через 5 минут
        spawn(function()
            wait(300)
            idleConnection:Disconnect()
            print("⏹️ Независимая idle анимация остановлена через 5 минут")
        end)
    else
        print("⚠️ Копия создана, но idle анимация не запустилась")
        print("💡 Возможно проблема с Motor6D или idle позами")
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
    screenGui.Name = "PetScalerV25GUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 150) -- Под оригинальным PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Циановая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "IndependentIdleButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    button.BorderSizePixel = 0
    button.Text = "🎭 PetScaler v2.5 - Независимая IDLE"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 13
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Ищу idle момент..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🎭 PetScaler v2.5 - Независимая IDLE"
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 255, 255) then
            button.BackgroundColor3 = Color3.fromRGB(0, 220, 220)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 220, 220) then
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        end
    end)
    
    print("🖥️ PetScaler v2.5 GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 70))
print("💡 PETSCALER v2.5 - НЕЗАВИСИМАЯ КОПИЯ С IDLE:")
print("   1. Автоматически ищет idle момент оригинала")
print("   2. Записывает только idle позы Motor6D")
print("   3. Создает независимую копию (без Humanoid)")
print("   4. Копия ТОЛЬКО в idle - никакой ходьбы!")
print("   5. НЕ копирует движения оригинала")
print("🎯 Нажмите циановую кнопку для запуска!")
print("=" .. string.rep("=", 70))
