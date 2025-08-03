-- 🧠 УМНЫЙ ПРЕВЕНТИВНЫЙ ЛОВЕЦ МАГИЧЕСКОГО IDLE
-- Предотвращает смену анимации ДО того как она произойдет!

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 🔍 ПОИСК ПИТОМЦА (РАБОЧАЯ ВЕРСИЯ)
local function hasPetVisuals(model)
    local meshCount = 0
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            meshCount = meshCount + 1
        end
    end
    return meshCount > 0
end

local function findPet()
    local character = player.Character
    if not character then 
        print("❌ Персонаж игрока не найден!")
        return nil 
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        print("❌ HumanoidRootPart не найден!")
        return nil 
    end
    
    local playerPos = hrp.Position
    
    print("🔍 Поиск питомцев с фигурными скобками...")
    
    local foundPets = {}
    local SEARCH_RADIUS = 100
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= SEARCH_RADIUS then
                    if hasPetVisuals(obj) then
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance
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

-- 🎯 ПРОВЕРКА НА МАГИЧЕСКИЙ МОМЕНТ
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

-- 📊 ЗАПИСЬ МАГИЧЕСКИХ ПОЗ (ОРИГИНАЛЬНАЯ РАБОЧАЯ ВЕРСИЯ)
local function recordMagicalPoses(petModel, duration)
    print("🎬 Записываю магические idle позы...")
    
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
    
    local poses = {}
    local frameCount = 0
    local targetFrames = duration * 60
    
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
    
    print(string.format("✅ Записано %d магических поз!", #poses))
    return poses, motor6Ds
end

-- 🧠 УМНАЯ ПРЕВЕНТИВНАЯ ФИКСАЦИЯ
local function smartPreventiveLock(petModel, magicalPoses, motor6Ds)
    print("🧠 УМНАЯ превентивная фиксация запущена!")
    print("🛡️ Стратегия: предотвращать смену анимации ДО того как она произойдет")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    local originalPosition = rootPart and rootPart.Position or Vector3.new(0, 0, 0)
    
    local currentFrame = 1
    local frameRate = 60
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    -- Превентивные меры - устанавливаем ОДИН РАЗ в начале
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.PlatformStand = true
        humanoid.Sit = false
        humanoid.AutoRotate = false
        print("🛡️ Превентивные блокировки Humanoid установлены")
    end
    
    if rootPart then
        rootPart.Anchored = true
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.AngularVelocity = Vector3.new(0, 0, 0)
        print("🛡️ RootPart заякорен и обнулен")
    end
    
    -- 🧠 УМНАЯ система мониторинга
    local lastKnownAnimations = {}
    local positionDriftCount = 0
    local animationChangeCount = 0
    
    -- Запоминаем текущие idle анимации
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                local name = track.Animation.Name:lower()
                local id = track.Animation.AnimationId:lower()
                
                if name:find("idle") or id:find("1073293904134356") then
                    lastKnownAnimations[track.Animation.AnimationId] = true
                    print("🎭 Запомнил idle анимацию:", track.Animation.Name)
                end
            end
        end
    end
    
    local lockConnection
    lockConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- 🧠 УМНАЯ проверка изменений (не каждый кадр, а с интервалом)
        if now % 0.1 < 0.016 then -- каждые 0.1 секунды
            
            -- 1. Проверяем дрейф позиции (мягко корректируем)
            if rootPart and originalPosition then
                local drift = (rootPart.Position - originalPosition).Magnitude
                if drift > 0.1 then -- более мягкая толерантность
                    positionDriftCount = positionDriftCount + 1
                    
                    -- Мягкая коррекция вместо резкой телепортации
                    local direction = (originalPosition - rootPart.Position).Unit
                    rootPart.Position = rootPart.Position + direction * (drift * 0.5)
                    
                    if positionDriftCount <= 3 then
                        print("🔧 Мягкая коррекция позиции, дрейф:", math.floor(drift * 100) / 100)
                    end
                end
            end
            
            -- 2. УМНАЯ проверка анимаций (только если что-то изменилось)
            local currentAnimations = {}
            local hasChanges = false
            
            for _, obj in pairs(petModel:GetDescendants()) do
                if obj:IsA("Animator") then
                    local tracks = obj:GetPlayingAnimationTracks()
                    for _, track in pairs(tracks) do
                        currentAnimations[track.Animation.AnimationId] = true
                        
                        -- Если появилась новая анимация (не idle)
                        if not lastKnownAnimations[track.Animation.AnimationId] then
                            local name = track.Animation.Name:lower()
                            local id = track.Animation.AnimationId:lower()
                            
                            if not name:find("idle") and not id:find("1073293904134356") then
                                hasChanges = true
                                animationChangeCount = animationChangeCount + 1
                                
                                -- МЯГКО останавливаем (не уничтожаем)
                                track:Stop()
                                
                                if animationChangeCount <= 5 then
                                    print("🛡️ ПРЕДОТВРАЩЕНА смена на:", track.Animation.Name)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Обновляем список известных анимаций только если были изменения
            if hasChanges then
                lastKnownAnimations = currentAnimations
            end
        end
        
        -- 3. Применение магических поз (стабильно, как в оригинале)
        if now - lastFrameTime >= frameInterval then
            lastFrameTime = now
            
            local framePoses = magicalPoses[currentFrame]
            if framePoses then
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
            
            currentFrame = currentFrame + 1
            if currentFrame > #magicalPoses then
                currentFrame = 1
                
                -- Статистика каждый цикл (если были события)
                if positionDriftCount > 0 or animationChangeCount > 0 then
                    print(string.format("🧠 Цикл: коррекций позиции=%d, предотвращено смен анимации=%d", 
                        positionDriftCount, animationChangeCount))
                end
            end
        end
    end)
    
    print("🧠 УМНАЯ превентивная фиксация активна!")
    print("🛡️ Превентивные блокировки установлены")
    print("🔧 Мягкая коррекция позиции включена")
    print("🎭 Мониторинг смены анимаций включен")
    
    return lockConnection
end

-- 🎯 УМНЫЙ АВТОМАТИЧЕСКИЙ ЛОВЕЦ
local function smartAutoMagicalCatcher()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    print("🧠 === УМНЫЙ АВТОМАТИЧЕСКИЙ ЛОВЕЦ ===")
    print("🛡️ Стратегия: превентивная блокировка вместо агрессивной борьбы")
    print("🎯 Поиск магического момента... (макс. 60 секунд)")
    
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    local searchConnection
    searchConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- Проверяем каждые 0.1 секунды (стабильный интервал)
        if now - lastCheckTime >= 0.1 then
            lastCheckTime = now
            
            if isMagicalIdleMoment(petModel) then
                print("🌟 === МАГИЧЕСКИЙ МОМЕНТ ПОЙМАН! ===")
                print("🧠 Запускаю УМНУЮ превентивную фиксацию...")
                searchConnection:Disconnect()
                
                -- Стандартная запись поз (3 секунды как в оригинале)
                local magicalPoses, motor6Ds = recordMagicalPoses(petModel, 3)
                if magicalPoses then
                    local connection = smartPreventiveLock(petModel, magicalPoses, motor6Ds)
                    print("🎉 УСПЕХ! Питомец под УМНОЙ превентивной защитой!")
                    print("🛡️ Смена анимации предотвращается ДО того как происходит")
                    
                    spawn(function()
                        wait(300)
                        connection:Disconnect()
                        print("⏹️ Умная превентивная фиксация остановлена через 5 минут")
                    end)
                end
                return
            end
            
            -- Показываем статус поиска каждые 10 секунд
            if math.floor(now - searchStartTime) % 10 == 0 and (now - searchStartTime) % 10 < 0.1 then
                print(string.format("🔍 Поиск магического момента... %.0f сек", now - searchStartTime))
            end
            
            if now - searchStartTime >= 60 then
                searchConnection:Disconnect()
                print("⏰ Время поиска истекло!")
                print("💡 Попробуй еще раз или дождись когда питомец войдет в idle")
            end
        end
    end)
end

-- 🚀 ЗАПУСК
print("\n🧠 === УМНЫЙ АВТОМАТИЧЕСКИЙ ЛОВЕЦ ===")
print("🛡️ Превентивная стратегия вместо агрессивной борьбы")
print("🔧 Мягкие коррекции вместо резких телепортаций")
print("🎭 Предотвращение смены анимации ДО того как она происходит")
print("🎯 Запуск через 2 секунды...")

spawn(function()
    wait(2)
    smartAutoMagicalCatcher()
end)
