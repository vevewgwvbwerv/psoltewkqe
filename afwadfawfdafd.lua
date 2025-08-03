-- 🔥 УЛЬТРА-УСИЛЕННЫЙ АВТОМАТИЧЕСКИЙ ЛОВЕЦ МАГИЧЕСКОГО IDLE
-- Максимально быстро и агрессивно отменяет любые попытки движения!

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

-- 📊 БЫСТРАЯ ЗАПИСЬ МАГИЧЕСКИХ ПОЗ
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

-- 🔥 УЛЬТРА-АГРЕССИВНАЯ ФИКСАЦИЯ В МАГИЧЕСКОМ СОСТОЯНИИ
local function ultraAggressiveLock(petModel, magicalPoses, motor6Ds)
    print("🔥 УЛЬТРА-АГРЕССИВНАЯ фиксация запущена!")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    local originalPosition = rootPart and rootPart.Position or Vector3.new(0, 0, 0)
    
    local currentFrame = 1
    local frameRate = 60
    local frameInterval = 1 / frameRate
    local lastFrameTime = tick()
    
    -- Статистика блокировок
    local stats = {
        blockedWalkingAnimations = 0,
        teleportations = 0,
        humanoidResets = 0
    }
    
    local lockConnection
    lockConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- 🔥 МГНОВЕННАЯ И ТОТАЛЬНАЯ БЛОКИРОВКА ДВИЖЕНИЯ (КАЖДЫЙ КАДР!)
        if humanoid then
            -- Мгновенное обнуление всех параметров движения
            if humanoid.WalkSpeed ~= 0 then
                humanoid.WalkSpeed = 0
                stats.humanoidResets = stats.humanoidResets + 1
            end
            if humanoid.JumpPower ~= 0 then
                humanoid.JumpPower = 0
            end
            if not humanoid.PlatformStand then
                humanoid.PlatformStand = true
            end
            
            -- ДОПОЛНИТЕЛЬНАЯ блокировка
            humanoid.Sit = false
            humanoid.AutoRotate = false
            
            -- Если есть хоть намек на движение - мгновенно останавливаем
            if humanoid.MoveDirection.Magnitude > 0 then
                humanoid:MoveTo(originalPosition)
                stats.humanoidResets = stats.humanoidResets + 1
            end
        end
        
        -- 🔥 МГНОВЕННАЯ КОРРЕКЦИЯ ПОЗИЦИИ (КАЖДЫЙ КАДР!)
        if rootPart and originalPosition then
            -- Очень жесткая толерантность - даже микро-сдвиги недопустимы
            if (rootPart.Position - originalPosition).Magnitude > 0.01 then
                rootPart.Position = originalPosition
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.AngularVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                stats.teleportations = stats.teleportations + 1
            end
            
            -- Принудительное закрепление
            if not rootPart.Anchored then
                rootPart.Anchored = true
            end
        end
        
        -- 🔥 МГНОВЕННОЕ УНИЧТОЖЕНИЕ WALKING АНИМАЦИЙ (КАЖДЫЙ КАДР!)
        for _, obj in pairs(petModel:GetDescendants()) do
            if obj:IsA("Animator") then
                local tracks = obj:GetPlayingAnimationTracks()
                for _, track in pairs(tracks) do
                    local name = track.Animation.Name:lower()
                    local id = track.Animation.AnimationId:lower()
                    
                    -- Если это НЕ idle - МГНОВЕННО уничтожаем без пощады
                    if not name:find("idle") and not id:find("1073293904134356") then
                        track:Stop()
                        track:Destroy()
                        stats.blockedWalkingAnimations = stats.blockedWalkingAnimations + 1
                        
                        -- Логируем только первые несколько блокировок
                        if stats.blockedWalkingAnimations <= 5 then
                            print("💀 МГНОВЕННО УНИЧТОЖЕНА walking анимация:", track.Animation.Name)
                        end
                    end
                end
            end
        end
        
        -- Применяем магические idle позы (прямое применение без задержек)
        if now - lastFrameTime >= frameInterval then
            lastFrameTime = now
            
            local framePoses = magicalPoses[currentFrame]
            if framePoses then
                for _, motor in pairs(motor6Ds) do
                    local pose = framePoses[motor.Name]
                    if pose then
                        pcall(function()
                            -- Прямое применение без интерполяции для максимальной скорости
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
                if stats.blockedWalkingAnimations > 0 or stats.teleportations > 0 or stats.humanoidResets > 0 then
                    print(string.format("🔥 Цикл: заблокировано анимаций=%d, телепортаций=%d, сбросов Humanoid=%d", 
                        stats.blockedWalkingAnimations, stats.teleportations, stats.humanoidResets))
                end
            end
        end
    end)
    
    print("🔥 УЛЬТРА-АГРЕССИВНАЯ фиксация активна!")
    print("💀 ВСЕ попытки движения уничтожаются МГНОВЕННО!")
    print("⚡ Блокировка работает КАЖДЫЙ КАДР без исключений!")
    
    return lockConnection
end

-- 🎯 УЛЬТРА-УСИЛЕННЫЙ АВТОМАТИЧЕСКИЙ ЛОВЕЦ
local function ultraAutoMagicalCatcher()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    print("🔥 === УЛЬТРА-УСИЛЕННЫЙ АВТОМАТИЧЕСКИЙ ЛОВЕЦ ===")
    print("⚡ Максимально быстрая и агрессивная блокировка движения!")
    print("🎯 Поиск магического момента... (макс. 60 секунд)")
    
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    local searchConnection
    searchConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- Проверяем каждые 0.05 секунды (в 2 раза чаще чем обычно)
        if now - lastCheckTime >= 0.05 then
            lastCheckTime = now
            
            if isMagicalIdleMoment(petModel) then
                print("🌟 === МАГИЧЕСКИЙ МОМЕНТ ПОЙМАН! ===")
                print("🔥 Запускаю УЛЬТРА-АГРЕССИВНУЮ фиксацию...")
                searchConnection:Disconnect()
                
                -- Быстрая запись поз (2 секунды вместо 3)
                local magicalPoses, motor6Ds = recordMagicalPoses(petModel, 2)
                if magicalPoses then
                    local connection = ultraAggressiveLock(petModel, magicalPoses, motor6Ds)
                    print("🎉 УСПЕХ! Питомец заблокирован в УЛЬТРА-АГРЕССИВНОМ режиме!")
                    print("💀 Любые попытки движения уничтожаются МГНОВЕННО!")
                    
                    spawn(function()
                        wait(300)
                        connection:Disconnect()
                        print("⏹️ Ультра-агрессивная фиксация остановлена через 5 минут")
                    end)
                end
                return
            end
            
            -- Показываем статус поиска каждые 10 секунд
            if math.floor(now - searchStartTime) % 10 == 0 and (now - searchStartTime) % 10 < 0.05 then
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
print("\n🔥 === УЛЬТРА-УСИЛЕННЫЙ АВТОМАТИЧЕСКИЙ ЛОВЕЦ ===")
print("⚡ Максимально быстрая и агрессивная блокировка!")
print("💀 МГНОВЕННОЕ уничтожение любых попыток движения!")
print("🎯 Запуск через 2 секунды...")

spawn(function()
    wait(2)
    ultraAutoMagicalCatcher()
end)
