-- 🎬 ПРЯМОЕ УПРАВЛЕНИЕ MOTOR6D - ЗАПИСЫВАЕМ И ВОСПРОИЗВОДИМ IDLE ПОЗЫ
-- Создаем собственную idle анимацию через Motor6D

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

print("🎬 === ПРЯМОЕ УПРАВЛЕНИЕ MOTOR6D ===")
print("🎯 Цель: Записать idle позы и воспроизводить их в цикле")
print("💡 Обходим систему анимаций полностью!")

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

-- 🐾 РАБОЧАЯ ФУНКЦИЯ ПОИСКА ПИТОМЦА
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

local function findPet()
    print("🔍 Поиск UUID моделей питомцев...")
    
    local foundPets = {}
    local SEARCH_RADIUS = 100
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= SEARCH_RADIUS then
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

-- 🎬 ЗАПИСЬ IDLE ПОЗ
local function recordIdlePoses(petModel)
    print("\n🎬 === ЗАПИСЬ IDLE ПОЗ ===")
    
    local motor6Ds = {}
    local recordedPoses = {}
    
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
    
    -- Записываем позы в течение 10 секунд
    print("📹 Начинаю запись idle поз на 10 секунд...")
    print("💡 Убедитесь что питомец стоит и анимирует idle!")
    
    local recordingTime = 10
    local frameRate = 30  -- 30 кадров в секунду
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
            
            table.insert(recordedPoses, framePoses)
            
            if currentFrame % 30 == 0 then  -- Каждую секунду
                print(string.format("📹 Записано кадров: %d/%d", currentFrame, totalFrames))
            end
        end
        
        if elapsed >= recordingTime then
            recordConnection:Disconnect()
            print("✅ Запись завершена!")
            print(string.format("📹 Записано кадров: %d", #recordedPoses))
        end
    end)
    
    -- Ждем завершения записи
    while #recordedPoses < totalFrames and recordConnection.Connected do
        wait(0.1)
    end
    
    return recordedPoses, motor6Ds
end

-- 🎭 ВОСПРОИЗВЕДЕНИЕ IDLE АНИМАЦИИ
local function playIdleAnimation(recordedPoses, motor6Ds, petModel)
    print("\n🎭 === ВОСПРОИЗВЕДЕНИЕ IDLE АНИМАЦИИ ===")
    
    if not recordedPoses or #recordedPoses == 0 then
        print("❌ Нет записанных поз!")
        return
    end
    
    print("🎬 Начинаю воспроизведение idle анимации...")
    print("🔄 Анимация будет циклически повторяться!")
    
    -- Останавливаем питомца
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.PlatformStand = true
        print("🛑 Питомец остановлен")
    end
    
    -- Якорим RootPart
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    if rootPart then
        rootPart.Anchored = true
        print("⚓ RootPart заякорен")
    end
    
    local currentFrame = 1
    local frameRate = 30
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    local playConnection
    playConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - lastFrameTime >= frameInterval then
            lastFrameTime = now
            
            -- Получаем текущий кадр
            local framePoses = recordedPoses[currentFrame]
            
            if framePoses then
                -- Применяем позы ко всем Motor6D
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
            if currentFrame > #recordedPoses then
                currentFrame = 1  -- Зацикливаем
                print("🔄 Анимация зациклена!")
            end
        end
    end)
    
    print("✅ Воспроизведение запущено!")
    print("🔄 Idle анимация играет в цикле!")
    
    -- Останавливаем через 300 секунд (5 минут)
    spawn(function()
        wait(300)
        playConnection:Disconnect()
        print("\n⏹️ Воспроизведение остановлено через 5 минут")
    end)
    
    return playConnection
end

-- 🎯 УЛУЧШЕННАЯ ВЕРСИЯ С ИНТЕРПОЛЯЦИЕЙ
local function playIdleAnimationSmooth(recordedPoses, motor6Ds, petModel)
    print("\n🎭 === ПЛАВНОЕ ВОСПРОИЗВЕДЕНИЕ IDLE АНИМАЦИИ ===")
    
    if not recordedPoses or #recordedPoses == 0 then
        print("❌ Нет записанных поз!")
        return
    end
    
    print("🎬 Начинаю плавное воспроизведение idle анимации...")
    
    -- Останавливаем питомца
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.PlatformStand = true
    end
    
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    if rootPart then
        rootPart.Anchored = true
    end
    
    local currentFrame = 1
    local frameRate = 30
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    local playConnection
    playConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - lastFrameTime >= frameInterval then
            lastFrameTime = now
            
            -- Получаем текущий и следующий кадры для интерполяции
            local currentPoses = recordedPoses[currentFrame]
            local nextFrame = currentFrame + 1
            if nextFrame > #recordedPoses then
                nextFrame = 1
            end
            local nextPoses = recordedPoses[nextFrame]
            
            if currentPoses and nextPoses then
                -- Интерполируем между кадрами для плавности
                local alpha = 0.5  -- Можно настроить для большей/меньшей плавности
                
                for _, motor in pairs(motor6Ds) do
                    local currentPose = currentPoses[motor.Name]
                    local nextPose = nextPoses[motor.Name]
                    
                    if currentPose and nextPose then
                        pcall(function()
                            -- Интерполяция C0
                            motor.C0 = currentPose.C0:lerp(nextPose.C0, alpha)
                            -- Интерполяция C1
                            motor.C1 = currentPose.C1:lerp(nextPose.C1, alpha)
                            -- Transform сложнее интерполировать, используем текущий
                            motor.Transform = currentPose.Transform
                        end)
                    end
                end
            end
            
            currentFrame = currentFrame + 1
            if currentFrame > #recordedPoses then
                currentFrame = 1
                print("🔄 Плавная анимация зациклена!")
            end
        end
    end)
    
    print("✅ Плавное воспроизведение запущено!")
    
    -- Останавливаем через 300 секунд
    spawn(function()
        wait(300)
        playConnection:Disconnect()
        print("\n⏹️ Плавное воспроизведение остановлено через 5 минут")
    end)
    
    return playConnection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    print("\n🎬 === ЗАПИСЬ IDLE ПОЗ ===")
    print("💡 Убедитесь что питомец стоит и анимирует idle!")
    print("📹 Запись начнется через 5 секунд...")
    
    wait(5)
    
    local recordedPoses, motor6Ds = recordIdlePoses(petModel)
    
    if recordedPoses and #recordedPoses > 0 then
        print("✅ Позы записаны успешно!")
        
        wait(2)
        
        print("\n🎭 === ВОСПРОИЗВЕДЕНИЕ ===")
        local connection = playIdleAnimationSmooth(recordedPoses, motor6Ds, petModel)
        
        if connection then
            print("🎉 УСПЕХ! Питомец теперь играет записанную idle анимацию!")
            print("🔄 Анимация зациклена и будет играть 5 минут!")
        end
    else
        print("❌ Запись не удалась")
    end
end

-- 🚀 ПРЯМОЙ ЗАПУСК
print("\n🚀 === ЗАПУСКАЮ ЗАПИСЬ И ВОСПРОИЗВЕДЕНИЕ MOTOR6D ===")
print("🎯 Обходим всю систему анимаций Roblox!")
print("📹 Записываем настоящие idle позы и воспроизводим их!")

spawn(function()
    wait(2)
    main()
end)

print("\n💡 === СТРАТЕГИЯ MOTOR6D ===")
print("🎬 1. Записываем Motor6D позы во время idle (10 секунд)")
print("🎭 2. Останавливаем питомца (WalkSpeed=0, PlatformStand=true)")
print("⚓ 3. Якорим RootPart для предотвращения движения")
print("🔄 4. Воспроизводим записанные позы в цикле")
print("✨ 5. Используем интерполяцию для плавности")
print("🎉 Результат: Настоящая idle анимация без системы Roblox!")
print("\n🚀 ЗАПИСЬ ЗАПУЩЕНА!")
