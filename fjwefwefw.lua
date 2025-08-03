-- 🎯 ТОЧНАЯ КОПИЯ РАБОЧЕГО АВТОМАТИЧЕСКОГО ЛОВЦА
-- Берем ИМЕННО ту логику которая работала, БЕЗ ИЗМЕНЕНИЙ!

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

-- 🎯 ПРОВЕРКА НА МАГИЧЕСКИЙ МОМЕНТ (ТОЧНАЯ КОПИЯ)
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

-- 📊 ЗАПИСЬ МАГИЧЕСКИХ ПОЗ (ТОЧНАЯ КОПИЯ)
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

-- 🔒 ФИКСАЦИЯ В МАГИЧЕСКОМ СОСТОЯНИИ (ТОЧНАЯ КОПИЯ РАБОЧЕЙ ВЕРСИИ!)
local function lockInMagicalIdle(petModel, magicalPoses, motor6Ds)
    print("🔒 Фиксирую питомца в МАГИЧЕСКОМ idle состоянии...")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    local originalPosition = rootPart and rootPart.Position or Vector3.new(0, 0, 0)
    
    local currentFrame = 1
    local frameRate = 60
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    -- Статистика для отладки
    local destroyedAnimations = 0
    local teleportations = 0
    
    local lockConnection
    lockConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- БЛОКИРОВКА ДВИЖЕНИЯ (ТОЧНАЯ КОПИЯ!)
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.PlatformStand = true
        end
        
        if rootPart then
            rootPart.Anchored = true
            if (rootPart.Position - originalPosition).Magnitude > 0.05 then
                rootPart.Position = originalPosition
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.AngularVelocity = Vector3.new(0, 0, 0)
                teleportations = teleportations + 1
            end
        end
        
        -- УНИЧТОЖЕНИЕ НЕ-IDLE АНИМАЦИЙ (ТОЧНАЯ КОПИЯ!)
        for _, obj in pairs(petModel:GetDescendants()) do
            if obj:IsA("Animator") then
                local tracks = obj:GetPlayingAnimationTracks()
                for _, track in pairs(tracks) do
                    local name = track.Animation.Name:lower()
                    local id = track.Animation.AnimationId:lower()
                    
                    -- КЛЮЧЕВАЯ ЛОГИКА: Stop() И Destroy()!
                    if not name:find("idle") and not id:find("1073293904134356") then
                        track:Stop()
                        track:Destroy()  -- ЭТО КЛЮЧЕВОЕ ОТЛИЧИЕ!
                        destroyedAnimations = destroyedAnimations + 1
                        
                        if destroyedAnimations <= 5 then
                            print("💀 УНИЧТОЖЕНА walking анимация:", track.Animation.Name)
                        end
                    end
                end
            end
        end
        
        -- ПРИМЕНЕНИЕ МАГИЧЕСКИХ ПОЗ (ТОЧНАЯ КОПИЯ!)
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
                
                -- Статистика каждый цикл
                if destroyedAnimations > 0 or teleportations > 0 then
                    print(string.format("🔄 Цикл: уничтожено анимаций=%d, телепортаций=%d", 
                        destroyedAnimations, teleportations))
                end
            end
        end
    end)
    
    print("🔒 ТОЧНАЯ КОПИЯ рабочей фиксации активна!")
    print("💀 Walking анимации УНИЧТОЖАЮТСЯ (Stop + Destroy)")
    print("📍 Позиция корректируется при дрейфе > 0.05")
    
    return lockConnection
end

-- 🔍 АВТОМАТИЧЕСКИЙ ЛОВЕЦ (ТОЧНАЯ КОПИЯ РАБОЧЕЙ ВЕРСИИ!)
local function exactWorkingCatcher()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    print("🔍 === ТОЧНАЯ КОПИЯ РАБОЧЕГО АВТОМАТИЧЕСКОГО ЛОВЦА ===")
    print("🎯 Поиск магического момента... (макс. 60 секунд)")
    
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    local searchConnection
    searchConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- Проверяем каждые 0.1 секунды (КАК В ОРИГИНАЛЕ!)
        if now - lastCheckTime >= 0.1 then
            lastCheckTime = now
            
            if isMagicalIdleMoment(petModel) then
                print("🌟 === МАГИЧЕСКИЙ МОМЕНТ ПОЙМАН! ===")
                searchConnection:Disconnect()
                
                -- Запись поз (3 секунды как в оригинале)
                local magicalPoses, motor6Ds = recordMagicalPoses(petModel, 3)
                if magicalPoses then
                    local connection = lockInMagicalIdle(petModel, magicalPoses, motor6Ds)
                    print("🎉 УСПЕХ! Питомец зафиксирован ТОЧНО как в рабочей версии!")
                    print("💀 Walking анимации будут УНИЧТОЖАТЬСЯ!")
                    
                    spawn(function()
                        wait(300)
                        connection:Disconnect()
                        print("⏹️ Фиксация остановлена через 5 минут")
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
print("\n🎯 === ТОЧНАЯ КОПИЯ РАБОЧЕГО АВТОМАТИЧЕСКОГО ЛОВЦА ===")
print("🔒 Используется ИМЕННО та логика которая работала!")
print("💀 Walking анимации: Stop() + Destroy() (КЛЮЧЕВОЕ ОТЛИЧИЕ!)")
print("📍 Толерантность позиции: 0.05 (как в оригинале)")
print("⏰ Интервал проверки: 0.1 сек (как в оригинале)")
print("🎯 Запуск через 2 секунды...")

spawn(function()
    wait(2)
    exactWorkingCatcher()
end)
