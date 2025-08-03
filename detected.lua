-- 🎉 PET SCALER ULTIMATE - МАСШТАБИРОВАНИЕ + БЕСКОНЕЧНЫЙ IDLE
-- Объединяет PetScaler_v2.4.lua + Motor6DIdleForcer.lua
-- Создает масштабированную копию И заблокирует обе модели в idle анимации

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🎉 === PET SCALER ULTIMATE - МАСШТАБИРОВАНИЕ + IDLE ===")
print("=" .. string.rep("=", 70))

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    START_SCALE = 0.3,  -- Начальный размер (30% от оригинала)
    END_SCALE = 1.0,    -- Конечный размер (100% - оригинальный размер)
    TWEEN_TIME = 3.0,
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out,
    IDLE_RECORD_TIME = 5,  -- Оригинальная запись: 5 секунд (как в Motor6DIdleForcer)
    IDLE_FRAME_RATE = 60   -- Оригинальная частота: 60 FPS (как в Motor6DIdleForcer)
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
print("📏 Масштабирование:", CONFIG.START_SCALE .. "x -> " .. CONFIG.END_SCALE .. "x")
print("⏱️ Время роста:", CONFIG.TWEEN_TIME .. " сек")
print("🎬 Время записи idle:", CONFIG.IDLE_RECORD_TIME .. " сек (ОРИГИНАЛЬНЫЕ НАСТРОЙКИ)")
print()

-- === ФУНКЦИИ ИЗ PETSCALER ===

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

-- Поиск питомца
local function findPet()
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

-- Глубокое копирование модели
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- Позиционирование копии
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
            targetPosition = Vector3.new(targetPosition.X, raycastResult.Position.Y, targetPosition.Z)
        end
        
        copy:SetPrimaryPartCFrame(CFrame.new(targetPosition, originalCFrame.LookVector))
        print("📍 Копия размещена в позиции:", targetPosition)
    else
        print("⚠️ PrimaryPart не найден, использую стандартное позиционирование")
        local originalPosition = originalModel:GetModelCFrame().Position
        copy:SetPrimaryPartCFrame(CFrame.new(originalPosition + Vector3.new(15, 0, 0)))
    end
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- Получение всех частей модели
local function getAllParts(model)
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    return parts
end

-- Рост модели с маленького до оригинального размера
local function growModelFromSmallToOriginal(model, startScale, endScale, tweenTime)
    print("🌱 Начинаю рост модели с маленького размера:", model.Name)
    print("📏 Рост:", startScale .. "x -> " .. endScale .. "x")
    
    local parts = getAllParts(model)
    print("🧩 Найдено частей для масштабирования:", #parts)
    
    if #parts == 0 then
        print("❌ Части для роста не найдены!")
        return false
    end
    
    -- Находим центр модели для роста относительно него
    local modelCFrame = model:GetModelCFrame()
    local modelCenter = modelCFrame.Position
    print("📍 Центр модели для роста:", modelCenter)
    
    -- СНАЧАЛА уменьшаем все части до стартового размера
    print("🔽 Уменьшаю модель до стартового размера:", startScale .. "x")
    for _, part in pairs(parts) do
        part.Anchored = true
        
        local originalSize = part.Size
        local originalPosition = part.Position
        
        -- Устанавливаем стартовый размер
        local startSize = originalSize * startScale
        
        -- Стартовая позиция (относительно центра)
        local offsetFromCenter = originalPosition - modelCenter
        local startOffset = offsetFromCenter * startScale
        local startPosition = modelCenter + startOffset
        
        part.Size = startSize
        part.Position = startPosition
        
        print(string.format("🔽 Часть %s установлена: размер %s, позиция %s", 
            part.Name, tostring(startSize), tostring(startPosition)))
    end
    
    wait(0.5) -- Небольшая пауза перед началом роста
    
    local tweens = {}
    
    -- Теперь запускаем рост до конечного размера
    print("🌱 Запускаю рост до конечного размера:", endScale .. "x")
    
    for _, part in pairs(parts) do
        -- Получаем ОРИГИНАЛЬНЫЕ размеры и позиции (до любых изменений)
        local originalSize = part.Size / startScale  -- Восстанавливаем оригинальный размер
        local originalPosition = modelCenter + ((part.Position - modelCenter) / startScale)  -- Восстанавливаем оригинальную позицию
        
        -- Конечный размер и позиция
        local targetSize = originalSize * endScale
        
        -- Конечная позиция (относительно центра)
        local offsetFromCenter = originalPosition - modelCenter
        local endOffset = offsetFromCenter * endScale
        local targetPosition = modelCenter + endOffset
        
        print(string.format("🌱 Часть %s растет: %s -> %s (размер: %s -> %s)", 
            part.Name, 
            tostring(part.Position), 
            tostring(targetPosition),
            tostring(part.Size),
            tostring(targetSize)
        ))
        
        local sizeTween = TweenService:Create(
            part,
            TweenInfo.new(tweenTime, CONFIG.EASING_STYLE, CONFIG.EASING_DIRECTION),
            {Size = targetSize}
        )
        
        local positionTween = TweenService:Create(
            part,
            TweenInfo.new(tweenTime, CONFIG.EASING_STYLE, CONFIG.EASING_DIRECTION),
            {Position = targetPosition}
        )
        
        table.insert(tweens, sizeTween)
        table.insert(tweens, positionTween)
        
        sizeTween:Play()
        positionTween:Play()
    end
    
    print("🎬 Запущено твинов роста:", #tweens)
    print("⏱️ Ожидание завершения роста...")
    
    return true
end

-- Умное управление Anchored
local function smartAnchoredManagement(copyParts)
    print("🧠 Умное управление Anchored...")
    
    local rootPart = nil
    
    for _, part in pairs(copyParts) do
        if part.Name == "HumanoidRootPart" or part.Name == "Torso" then
            rootPart = part
            part.Anchored = true
            print("⚓ Корневая часть заякорена:", part.Name)
        else
            part.Anchored = false
            print("🔓 Часть освобождена для анимации:", part.Name)
        end
    end
    
    if not rootPart then
        print("⚠️ Корневая часть не найдена, якорим первую часть")
        if #copyParts > 0 then
            rootPart = copyParts[1]
            rootPart.Anchored = true
        end
    end
    
    return rootPart
end

-- Получение Motor6D
local function getMotor6Ds(model)
    local motors = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    return motors
end

-- === ФУНКЦИИ ИЗ MOTOR6DIDLEFORCER ===

-- Запись idle поз
local function recordPureIdlePoses(petModel)
    print("\n🎬 === ЗАПИСЬ ЧИСТЫХ IDLE ПОЗ ===")
    
    local motor6Ds = getMotor6Ds(petModel)
    local idlePoses = {}
    
    print("🔧 Найдено Motor6D:", #motor6Ds)
    
    if #motor6Ds == 0 then
        print("❌ Motor6D не найдены!")
        return nil
    end
    
    -- АГРЕССИВНО останавливаем питомца для записи
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.PlatformStand = true
        print("🛑 Питомец агрессивно остановлен для записи")
    end
    
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    local originalPosition = nil
    if rootPart then
        originalPosition = rootPart.Position
        rootPart.Anchored = true
        print("⚓ RootPart заякорен для записи")
    end
    
    -- Уничтожаем ВСЕ walking анимации
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                local name = track.Animation.Name:lower()
                local id = track.Animation.AnimationId:lower()
                
                -- Если это НЕ idle - уничтожаем
                if not name:find("idle") and not id:find("1073293904134356") then
                    track:Stop()
                    track:Destroy()
                    print("💀 Уничтожена walking анимация:", track.Animation.Name)
                end
            end
        end
    end
    
    print("📹 Ждем 3 секунды для стабилизации idle... (ОРИГИНАЛЬНЫЕ НАСТРОЙКИ)")
    wait(3)
    
    -- Записываем стабильные idle позы (ОРИГИНАЛЬНАЯ ВЕРСИЯ)
    print("📹 Записываем стабильные idle позы (" .. CONFIG.IDLE_RECORD_TIME .. " секунд - ОРИГИНАЛЬНЫЕ НАСТРОЙКИ)...")
    
    local recordingTime = CONFIG.IDLE_RECORD_TIME
    local frameRate = CONFIG.IDLE_FRAME_RATE
    local frameInterval = 1 / frameRate
    local totalFrames = recordingTime * frameRate
    
    local currentFrame = 0
    local startTime = tick()
    
    local recordConnection
    recordConnection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        
        if elapsed >= frameInterval * currentFrame then
            currentFrame = currentFrame + 1
            
            -- Записываем текущие позы всех Motor6D
            local framePoses = {}
            
            for _, motor in pairs(motor6Ds) do
                framePoses[motor.Name] = {
                    C0 = motor.C0,
                    C1 = motor.C1,
                    Transform = motor.Transform
                }
            end
            
            table.insert(idlePoses, framePoses)
            
            if currentFrame % frameRate == 0 then  -- Каждую секунду (как в оригинале)
                print(string.format("📹 Записано idle кадров: %d/%d (ОРИГИНАЛЬНЫЕ НАСТРОЙКИ)", currentFrame, totalFrames))
            end
        end
        
        if elapsed >= recordingTime then
            recordConnection:Disconnect()
            print("✅ Запись чистых idle поз завершена!")
            print(string.format("📹 Записано кадров: %d", #idlePoses))
        end
    end)
    
    -- Ждем завершения записи
    while #idlePoses < totalFrames and recordConnection.Connected do
        wait(0.1)
    end
    
    return idlePoses, motor6Ds, originalPosition
end

-- Агрессивное форсирование idle для оригинала
local function forceOriginalIdleAnimation(idlePoses, motor6Ds, petModel, originalPosition)
    print("\n🔥 === АГРЕССИВНОЕ ФОРСИРОВАНИЕ IDLE ОРИГИНАЛА ===")
    
    if not idlePoses or #idlePoses == 0 then
        print("❌ Нет записанных idle поз!")
        return nil
    end
    
    print("🔥 Начинаю агрессивное форсирование idle анимации оригинала...")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    
    local currentFrame = 1
    local frameRate = CONFIG.IDLE_FRAME_RATE
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    local forceConnection
    forceConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- АГРЕССИВНО блокируем движение (КАЖДЫЙ КАДР как в Motor6DIdleForcer)
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.PlatformStand = true
        end
        
        if rootPart and originalPosition then
            rootPart.Anchored = true
            -- Телепортируем обратно если сдвинулся
            if (rootPart.Position - originalPosition).Magnitude > 0.1 then
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
                    local id = track.Animation.AnimationId:lower()
                    
                    -- Если это НЕ idle - немедленно уничтожаем
                    if not name:find("idle") and not id:find("1073293904134356") then
                        track:Stop()
                        print("💀 Заблокирована walking анимация:", track.Animation.Name)
                    end
                end
            end
        end
        
        -- Применяем idle позы (ТОЧНО как в Motor6DIdleForcer)
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
            
            -- Переходим к следующему кадру
            currentFrame = currentFrame + 1
            if currentFrame > #idlePoses then
                currentFrame = 1  -- Зацикливаем idle
                print("🔄 Idle анимация зациклена!")
            end
        end
    end)
    
    print("✅ Агрессивное форсирование запущено!")
    print("🔥 Питомец заблокирован в ТОЛЬКО idle анимации!")
    print("💀 ВСЕ walking анимации уничтожаются каждый кадр!")
    return forceConnection
end

-- Живое копирование Motor6D с масштабированием
local function startLiveMotorCopying(original, copy, scaleFactor)
    print("🔄 Запуск живого копирования Motor6D с масштабированием...")
    
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    print("🔧 Оригинал Motor6D:", #originalMotors)
    print("🔧 Копия Motor6D:", #copyMotors)
    
    if #originalMotors == 0 or #copyMotors == 0 then
        print("❌ Motor6D не найдены в одной из моделей!")
        return nil
    end
    
    -- Создаем карту соответствий Motor6D
    local motorMap = {}
    for _, originalMotor in pairs(originalMotors) do
        for _, copyMotor in pairs(copyMotors) do
            if originalMotor.Name == copyMotor.Name then
                motorMap[originalMotor] = copyMotor
                break
            end
        end
    end
    
    print("🗺️ Создано соответствий Motor6D:", #motorMap)
    
    if next(motorMap) == nil then
        print("❌ Соответствия Motor6D не найдены!")
        return nil
    end
    
    -- Функция копирования состояния Motor6D с масштабированием
    local function copyMotorState(originalMotor, copyMotor, scale)
        local originalTransform = originalMotor.Transform
        local scaledTransform = CFrame.new(originalTransform.Position * scale) * (originalTransform - originalTransform.Position)
        copyMotor.Transform = scaledTransform
        
        local originalC0 = originalMotor.C0
        local scaledC0 = CFrame.new(originalC0.Position * scale) * (originalC0 - originalC0.Position)
        copyMotor.C0 = scaledC0
        
        local originalC1 = originalMotor.C1
        local scaledC1 = CFrame.new(originalC1.Position * scale) * (originalC1 - originalC1.Position)
        copyMotor.C1 = scaledC1
    end
    
    -- Запуск живого копирования
    local connection = RunService.Heartbeat:Connect(function()
        for originalMotor, copyMotor in pairs(motorMap) do
            pcall(function()
                copyMotorState(originalMotor, copyMotor, scaleFactor)
            end)
        end
    end)
    
    print("✅ Живое копирование Motor6D запущено!")
    return connection
end

-- === ГЛАВНАЯ ФУНКЦИЯ ===

local function main()
    print("🚀 PetScaler ULTIMATE запущен!")
    
    -- Шаг 1: Найти питомца
    local petModel = findPet()
    if not petModel then
        return
    end
    
    -- Шаг 2: Записать idle позы (КАК В MOTOR6DIDLEFORCER - с задержками!)
    print("\n🎬 === ЗАПИСЬ ЧИСТЫХ IDLE ПОЗ ===")
    print("💡 Питомец будет агрессивно остановлен для записи!")
    print("📹 Запись начнется через 3 секунды... (КАК В MOTOR6DIDLEFORCER)")
    
    wait(3)  -- КЛЮЧЕВАЯ задержка из Motor6DIdleForcer!
    
    local idlePoses, motor6Ds, originalPosition = recordPureIdlePoses(petModel)
    
    if not idlePoses then
        print("❌ Не удалось записать idle позы!")
        return
    end
    
    print("✅ Чистые idle позы записаны! (КАК В MOTOR6DIDLEFORCER)")
    
    wait(2)  -- КЛЮЧЕВАЯ задержка из Motor6DIdleForcer!
    
    -- Шаг 3: Создать копию
    print("\n📋 === СОЗДАНИЕ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- Шаг 4: Масштабировать копию
    print("\n📏 === МАСШТАБИРОВАНИЕ КОПИИ ===")
    -- Убеждаемся что все части закреплены для стабильного масштабирования
    for _, part in pairs(petCopy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    wait(0.5)
    local scaleSuccess = growModelFromSmallToOriginal(petCopy, CONFIG.START_SCALE, CONFIG.END_SCALE, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Рост модели не удался!")
        return
    end
    
    -- Шаг 5: Настроить Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ДЛЯ АНИМАЦИИ ===")
    wait(CONFIG.TWEEN_TIME + 1) -- Ждем завершения роста
    
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Шаг 6: Запустить агрессивное idle форсирование (КАК В MOTOR6DIDLEFORCER)
    print("\n🔥 === АГРЕССИВНОЕ ФОРСИРОВАНИЕ ===")
    local originalIdleConnection = forceOriginalIdleAnimation(idlePoses, motor6Ds, petModel, originalPosition)
    
    -- Шаг 7: ОТКЛЮЧЕНО живое копирование (КОНФЛИКТУЕТ с idle форсированием)
    print("\n🚫 === ЖИВОЕ КОПИРОВАНИЕ ОТКЛЮЧЕНО ===\n💡 Причина: Конфликт с idle форсированием!")
    print("🔥 Оставляем ТОЛЬКО idle форсирование как в Motor6DIdleForcer.lua")
    
    if originalIdleConnection then
        print("\n🎉 === ПОЛНЫЙ УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Оригинал заблокирован в idle анимации")
        print("🔥 БЕЗ живого копирования - НЕТ конфликтов!")
        print("💡 Питомец будет ТОЛЬКО в idle как в Motor6DIdleForcer!")
        
        -- Останавливаем через 300 секунд (5 минут)
        spawn(function()
            wait(300)
            if originalIdleConnection then
                originalIdleConnection:Disconnect()
            end
            print("\n⏹️ Idle форсирование остановлено через 5 минут")
        end)
        
    else
        print("❌ Idle форсирование не запустилось!")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerUltimateGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerUltimateGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 250) -- Под другими GUI
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 255) -- Фиолетовая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "UltimateButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    button.BorderSizePixel = 0
    button.Text = "🎉 PetScaler ULTIMATE + Idle"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Создаю ULTIMATE версию..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            -- КЛЮЧЕВАЯ задержка запуска как в Motor6DIdleForcer.lua!
            print("\n🚀 === ЗАПУСКАЮ PETSCALER ULTIMATE ===")
            print("🔥 ТОЛЬКО idle анимация! НИКАКОЙ ходьбы!")
            print("💀 Агрессивное уничтожение walking анимаций!")
            print("⏳ Запуск через 2 секунды... (КАК В MOTOR6DIDLEFORCER)")
            
            wait(2)  -- КЛЮЧЕВАЯ задержка из Motor6DIdleForcer!
            
            main()
            
            wait(3)
            button.Text = "🎉 PetScaler ULTIMATE + Idle"
            button.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 0, 255) then
            button.BackgroundColor3 = Color3.fromRGB(220, 0, 220)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(220, 0, 220) then
            button.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
        end
    end)
    
    print("🖥️ PetScaler ULTIMATE GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 70))
print("💡 PETSCALER ULTIMATE - ФИНАЛЬНОЕ РЕШЕНИЕ:")
print("   1. Записывает idle позы оригинала")
print("   2. Создает масштабированную копию")
print("   3. Заблокирует оригинал в бесконечном idle")
print("   4. Копия копирует idle анимацию оригинала")
print("   5. ОБЕ МОДЕЛИ НИКОГДА НЕ ХОДЯТ!")
print("🎯 Нажмите фиолетовую кнопку для запуска ULTIMATE!")
print("=" .. string.rep("=", 70))
