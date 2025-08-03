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
    
    -- Шаг 5: Запуск живого копирования Motor6D
    print("\n🎭 === ЗАПУСК АНИМАЦИИ ===")
    
    local connection = startLiveMotorCopying(petModel, petCopy)
    
    -- Шаг 6: КОНТРОЛЬ ОРИГИНАЛЬНОГО ПИТОМЦА - ЗАЦИКЛИВАНИЕ IDLE
    print("\n🎯 === КОНТРОЛЬ ОРИГИНАЛА ===") 
    
    -- Заякориваем оригинал чтобы не ходил
    local originalRoot = petModel:FindFirstChild("RootPart") or 
                        petModel:FindFirstChild("Torso") or 
                        petModel:FindFirstChild("HumanoidRootPart")
    
    if originalRoot then
        originalRoot.Anchored = true
        print("⚓ Оригинал заякорен - не будет ходить")
        
        -- Отключаем AI
        local originalHumanoid = petModel:FindFirstChildOfClass("Humanoid")
        if originalHumanoid then
            originalHumanoid.WalkSpeed = 0
            originalHumanoid.JumpPower = 0
            print("🤖 AI отключен")
        end
        
        -- 🎯 ПРАВИЛЬНЫЙ ПОДХОД: ЗАЦИКЛИВАНИЕ IDLE + УДАЛЕНИЕ ХОДЬБЫ
        print("🎯 ПРАВИЛЬНЫЙ подход - ищем и зацикливаем IDLE анимацию!")
        
        -- Освобождаем части для анимации (НЕ замораживаем!)
        originalRoot.Anchored = false
        print("🔓 Корень освобожден для анимации")
        
        -- Отключаем только движение, но разрешаем анимацию
        if originalHumanoid then
            originalHumanoid.WalkSpeed = 0
            originalHumanoid.JumpPower = 0
            -- НЕ включаем PlatformStand - пусть анимируется!
            print("🤖 AI отключен, но анимация разрешена")
        end
        
        -- ПОИСК И ЗАЦИКЛИВАНИЕ IDLE АНИМАЦИИ
        local originalAnimator = petModel:FindFirstChildOfClass("Animator")
        if not originalAnimator then
            -- Создаем Animator если его нет
            originalAnimator = Instance.new("Animator")
            originalAnimator.Parent = originalHumanoid
            print("🎭 Создал новый Animator")
        end
        
        print("🎭 Нашел/создал Animator")
        
        -- СНАЧАЛА ОСТАНАВЛИВАЕМ ВСЕ АНИМАЦИИ ЧТОБЫ УВИДЕТЬ IDLE
        print("🛑 ОСТАНАВЛИВАЮ все анимации чтобы увидеть idle...")
        local allTracks = originalAnimator:GetPlayingAnimationTracks()
        for _, track in pairs(allTracks) do
            track:Stop()
            print("⏹️ Остановил:", track.Name)
        end
        
        -- ЖДЕМ ЧТОБЫ IDLE АНИМАЦИЯ ПОЯВИЛАСЬ
        print("⏳ Жду появления idle анимации...")
        wait(3) -- Ждем чтобы система переключилась на idle
        
        -- ТЕПЕРЬ ИЩЕМ IDLE АНИМАЦИЮ КОТОРАЯ ДОЛЖНА ИГРАТЬ
        allTracks = originalAnimator:GetPlayingAnimationTracks()
        local idleTrack = nil
        local walkTracks = {}
        
        print("🔍 Анализирую анимации ПОСЛЕ остановки:")
        for _, track in pairs(allTracks) do
            local trackName = track.Name:lower()
            print("  📋", track.Name, "- Играет:", track.IsPlaying)
            
            if trackName:find("idle") or trackName:find("stand") or trackName:find("breath") then
                idleTrack = track
                print("  ✨ Это IDLE анимация!")
            elseif trackName:find("walk") or trackName:find("run") or trackName:find("move") then
                table.insert(walkTracks, track)
                print("  🚫 Это WALKING анимация - будет удалена!")
            else
                -- Если не можем определить по имени, считаем что это idle
                if track.IsPlaying then
                    idleTrack = track
                    print("  🤔 Неизвестная анимация, но играет - считаем IDLE:", track.Name)
                end
            end
        end
        
        -- УДАЛЯЕМ ВСЕ WALKING АНИМАЦИИ НАВСЕГДА
        for _, walkTrack in pairs(walkTracks) do
            walkTrack:Stop()
            walkTrack:Destroy()
            print("🗑️ УДАЛИЛ walking анимацию:", walkTrack.Name)
        end
        
        -- ЗАЦИКЛИВАЕМ IDLE АНИМАЦИЮ КАК БЕСКОНЕЧНУЮ
        if idleTrack then
            idleTrack:Stop() -- Останавливаем
            idleTrack.Looped = true -- Делаем бесконечной
            idleTrack.Priority = Enum.AnimationPriority.Action -- Высокий приоритет
            idleTrack:Play() -- Запускаем бесконечно
            
            print("🔄 ЗАЦИКЛИЛ idle анимацию как БЕСКОНЕЧНУЮ:", idleTrack.Name)
            print("♾️ Теперь idle анимация будет играть ВЕЧНО как ходьба!")
            
            -- УЛЬТРА-АГРЕССИВНЫЙ МОНИТОРИНГ: НИ ММ ДВИЖЕНИЯ!
            spawn(function()
                local originalPosition = originalRoot.Position
                local originalCFrame = originalRoot.CFrame
                
                while idleTrack and idleTrack.Parent and petModel and petModel.Parent do
                    wait(0.05) -- ОЧЕНЬ частая проверка!
                    
                    -- 1. ПРОВЕРЯЕМ ЧТО IDLE ИГРАЕТ
                    if not idleTrack.IsPlaying then
                        idleTrack.Looped = true
                        idleTrack.Priority = Enum.AnimationPriority.Action
                        idleTrack:Play()
                        print("🔄 Перезапустил idle!")
                    end
                    
                    -- 2. УНИЧТОЖАЕМ ЛЮБЫЕ WALKING АНИМАЦИИ
                    for _, track in pairs(originalAnimator:GetPlayingAnimationTracks()) do
                        if track ~= idleTrack then
                            local trackName = track.Name:lower()
                            if trackName:find("walk") or trackName:find("run") or trackName:find("move") then
                                track:Stop()
                                track:Destroy()
                                print("🗑️ УНИЧТОЖИЛ walking:", track.Name)
                            end
                        end
                    end
                    
                    -- 3. ПРИНУДИТЕЛЬНО БЛОКИРУЕМ ЛЮБОЕ ДВИЖЕНИЕ
                    if originalHumanoid then
                        if originalHumanoid.WalkSpeed ~= 0 then
                            originalHumanoid.WalkSpeed = 0
                            print("🚫 Переблокировал WalkSpeed!")
                        end
                        if originalHumanoid.JumpPower ~= 0 then
                            originalHumanoid.JumpPower = 0
                            print("🚫 Переблокировал JumpPower!")
                        end
                    end
                    
                    -- 4. ПРОВЕРЯЕМ ПОЗИЦИЮ - ЕСЛИ СДВИНУЛСЯ, ВОЗВРАЩАЕМ!
                    if originalRoot then
                        local currentPos = originalRoot.Position
                        local distance = (currentPos - originalPosition).Magnitude
                        
                        if distance > 0.5 then -- Если сдвинулся больше 0.5 студов
                            originalRoot.CFrame = originalCFrame
                            originalRoot.Velocity = Vector3.new(0, 0, 0)
                            originalRoot.AngularVelocity = Vector3.new(0, 0, 0)
                            print("🛑 ВЕРНУЛ НА МЕСТО! Расстояние:", distance)
                        end
                        
                        -- Обнуляем скорость если она есть
                        if originalRoot.Velocity.Magnitude > 0.1 then
                            originalRoot.Velocity = Vector3.new(0, 0, 0)
                            originalRoot.AngularVelocity = Vector3.new(0, 0, 0)
                            print("🛑 Обнулил скорость!")
                        end
                    end
                    
                    -- 5. ПРОВЕРЯЕМ ЧТО КОРЕНЬ НЕ ЗАЯКОРЕН (для анимации)
                    if originalRoot and originalRoot.Anchored then
                        originalRoot.Anchored = false
                        print("🔓 Освободил корень для анимации")
                    end
                end
                print("⚠️ Ультра-агрессивный мониторинг остановлен")
            end)
            
        else
            print("❌ IDLE анимация НЕ НАЙДЕНА!")
            print("💡 Попробуем создать искусственную idle анимацию...")
            
            -- Создаем простую idle анимацию (покачивание)
            spawn(function()
                local headPart = petModel:FindFirstChild("Head")
                if headPart then
                    local originalHeadCFrame = headPart.CFrame
                    while petModel and petModel.Parent do
                        wait(2)
                        if headPart and headPart.Parent then
                            -- Легкое покачивание головой
                            headPart.CFrame = originalHeadCFrame * CFrame.Angles(0, math.rad(5), 0)
                            wait(2)
                            headPart.CFrame = originalHeadCFrame * CFrame.Angles(0, math.rad(-5), 0)
                            wait(2)
                            headPart.CFrame = originalHeadCFrame
                        end
                    end
                end
            end)
            print("🔄 Запустил искусственную idle анимацию (покачивание головы)")
        end
        
        print("✅ ПРАВИЛЬНОЕ зацикливание idle настроено!")
        print("♾️ Питомец будет БЕСКОНЕЧНО играть idle анимацию!")
        print("🚫 Все walking анимации УДАЛЕНЫ навсегда!")
    end
    
    if connection then
        print("\n🎉 === ПОЛНЫЙ УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Анимация запущена")
        print("✅ Оригинал остановлен и зациклен на idle")
        print("💡 Копия должна стоять с idle анимацией!")
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
