-- 🔥 УСИЛЕННЫЙ MOTOR6D КОНТРОЛЛЕР - ТОЛЬКО IDLE АНИМАЦИЯ!
-- Агрессивно блокируем ВСЕ walking анимации и форсируем только idle

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === УСИЛЕННЫЙ MOTOR6D КОНТРОЛЛЕР ===")
print("🎯 Цель: ТОЛЬКО idle анимация, НИКАКОЙ ходьбы!")
print("💪 Агрессивная блокировка walking анимаций!")

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

-- 🎬 ЗАПИСЬ ТОЛЬКО IDLE ПОЗ (УЛУЧШЕННАЯ)
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
    
    print("📹 Ждем 3 секунды для стабилизации idle...")
    wait(3)
    
    -- Записываем стабильные idle позы
    print("📹 Записываем стабильные idle позы (5 секунд)...")
    
    local recordingTime = 5
    local frameRate = 60  -- Увеличиваем частоту для плавности
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
            
            if currentFrame % 60 == 0 then  -- Каждую секунду
                print(string.format("📹 Записано idle кадров: %d/%d", currentFrame, totalFrames))
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

-- 🔥 АГРЕССИВНОЕ ФОРСИРОВАНИЕ ТОЛЬКО IDLE
local function forceOnlyIdleAnimation(idlePoses, motor6Ds, petModel, originalPosition)
    print("\n🔥 === АГРЕССИВНОЕ ФОРСИРОВАНИЕ ТОЛЬКО IDLE ===")
    
    if not idlePoses or #idlePoses == 0 then
        print("❌ Нет записанных idle поз!")
        return
    end
    
    print("🔥 Начинаю агрессивное форсирование только idle анимации...")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    
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
    
    -- Останавливаем через 300 секунд (5 минут)
    spawn(function()
        wait(300)
        forceConnection:Disconnect()
        print("\n⏹️ Агрессивное форсирование остановлено через 5 минут")
    end)
    
    return forceConnection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    print("\n🎬 === ЗАПИСЬ ЧИСТЫХ IDLE ПОЗ ===")
    print("💡 Питомец будет агрессивно остановлен для записи!")
    print("📹 Запись начнется через 3 секунды...")
    
    wait(3)
    
    local idlePoses, motor6Ds, originalPosition = recordPureIdlePoses(petModel)
    
    if idlePoses and #idlePoses > 0 then
        print("✅ Чистые idle позы записаны!")
        
        wait(2)
        
        print("\n🔥 === АГРЕССИВНОЕ ФОРСИРОВАНИЕ ===")
        local connection = forceOnlyIdleAnimation(idlePoses, motor6Ds, petModel, originalPosition)
        
        if connection then
            print("🎉 УСПЕХ! Питомец теперь ЗАБЛОКИРОВАН в idle анимации!")
            print("🔥 ВСЕ walking анимации уничтожаются!")
            print("🔄 Только idle анимация играет в цикле!")
        end
    else
        print("❌ Запись не удалась")
    end
end

-- 🚀 ПРЯМОЙ ЗАПУСК
print("\n🚀 === ЗАПУСКАЮ АГРЕССИВНЫЙ IDLE ФОРСЕР ===")
print("🔥 ТОЛЬКО idle анимация! НИКАКОЙ ходьбы!")
print("💀 Агрессивное уничтожение walking анимаций!")

spawn(function()
    wait(2)
    main()
end)

print("\n💡 === АГРЕССИВНАЯ СТРАТЕГИЯ ===")
print("🛑 1. Агрессивно останавливаем питомца")
print("💀 2. Уничтожаем ВСЕ walking анимации")
print("📹 3. Записываем ТОЛЬКО чистые idle позы")
print("🔥 4. Форсируем idle позы каждый кадр")
print("💀 5. Блокируем walking анимации каждый кадр")
print("⚓ 6. Телепортируем обратно при движении")
print("🎉 Результат: ТОЛЬКО idle анимация, НИКОГДА ходьба!")
print("\n🚀 АГРЕССИВНЫЙ КОНТРОЛЬ ЗАПУЩЕН!")
