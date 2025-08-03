-- 🌟 ПЛАВНАЯ ФИКСАЦИЯ МАГИЧЕСКОГО IDLE - БЕЗ ЛАГОВ!
-- Устраняет дергания и лаги при фиксации питомца в idle состоянии

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

-- 📊 ЗАПИСЬ МАГИЧЕСКИХ ПОЗ (БЫСТРАЯ ВЕРСИЯ)
local function recordMagicalPoses(petModel, duration)
    print("🎬 Записываю магические idle позы (быстро)...")
    
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

-- 🌟 ПЛАВНАЯ ФИКСАЦИЯ БЕЗ ЛАГОВ
local function smoothMagicalFix(petModel, magicalPoses, motor6Ds)
    print("🌟 Запускаю ПЛАВНУЮ фиксацию без лагов...")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    local originalPosition = rootPart and rootPart.Position or Vector3.new(0, 0, 0)
    
    -- Состояние фиксации
    local fixState = {
        currentFrame = 1,
        frameRate = 60,
        frameInterval = 1 / 60,
        lastFrameTime = tick(),
        
        -- Анти-лаг параметры
        positionTolerance = 0.5,  -- Больше толерантность к движению
        teleportCooldown = 0.5,   -- Кулдаун на телепортацию
        lastTeleportTime = 0,
        
        -- Плавность
        smoothingEnabled = true,
        smoothingFactor = 0.8,    -- Плавность применения поз
        
        -- Статистика
        teleportCount = 0,
        blockedAnimations = 0
    }
    
    local fixConnection
    fixConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        -- МЯГКАЯ блокировка движения (не каждый кадр)
        if now % 0.2 < 0.016 then -- каждые 0.2 секунды
            if humanoid then
                -- Плавное снижение скорости вместо мгновенного обнуления
                if humanoid.WalkSpeed > 0 then
                    humanoid.WalkSpeed = math.max(0, humanoid.WalkSpeed - 5)
                end
                humanoid.JumpPower = 0
                humanoid.PlatformStand = true
            end
        end
        
        -- УМНАЯ телепортация (только при значительном сдвиге и с кулдауном)
        if rootPart and originalPosition then
            local distance = (rootPart.Position - originalPosition).Magnitude
            
            if distance > fixState.positionTolerance and (now - fixState.lastTeleportTime) > fixState.teleportCooldown then
                -- Плавная телепортация вместо мгновенной
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {Position = originalPosition})
                tween:Play()
                
                fixState.lastTeleportTime = now
                fixState.teleportCount = fixState.teleportCount + 1
                
                -- Только важные логи
                if fixState.teleportCount % 5 == 1 then
                    print(string.format("🔄 Плавная коррекция позиции #%d (расстояние: %.2f)", 
                        fixState.teleportCount, distance))
                end
            end
        end
        
        -- СЕЛЕКТИВНОЕ уничтожение анимаций (не каждый кадр)
        if now % 0.3 < 0.016 then -- каждые 0.3 секунды
            for _, obj in pairs(petModel:GetDescendants()) do
                if obj:IsA("Animator") then
                    local tracks = obj:GetPlayingAnimationTracks()
                    for _, track in pairs(tracks) do
                        local name = track.Animation.Name:lower()
                        local id = track.Animation.AnimationId:lower()
                        
                        if not name:find("idle") and not id:find("1073293904134356") then
                            track:Stop()
                            fixState.blockedAnimations = fixState.blockedAnimations + 1
                            
                            -- Только важные логи
                            if fixState.blockedAnimations % 10 == 1 then
                                print(string.format("💀 Заблокировано анимаций: %d", fixState.blockedAnimations))
                            end
                        end
                    end
                end
            end
        end
        
        -- ПЛАВНОЕ применение магических поз
        if now - fixState.lastFrameTime >= fixState.frameInterval then
            fixState.lastFrameTime = now
            
            local framePoses = magicalPoses[fixState.currentFrame]
            if framePoses then
                for _, motor in pairs(motor6Ds) do
                    local pose = framePoses[motor.Name]
                    if pose then
                        pcall(function()
                            if fixState.smoothingEnabled then
                                -- Плавное применение поз для устранения дерганий
                                local currentC0 = motor.C0
                                local targetC0 = pose.C0
                                motor.C0 = currentC0:Lerp(targetC0, fixState.smoothingFactor)
                                
                                local currentC1 = motor.C1
                                local targetC1 = pose.C1
                                motor.C1 = currentC1:Lerp(targetC1, fixState.smoothingFactor)
                                
                                -- Transform применяем напрямую (он менее критичен)
                                motor.Transform = pose.Transform
                            else
                                -- Прямое применение
                                motor.C0 = pose.C0
                                motor.C1 = pose.C1
                                motor.Transform = pose.Transform
                            end
                        end)
                    end
                end
            end
            
            fixState.currentFrame = fixState.currentFrame + 1
            if fixState.currentFrame > #magicalPoses then
                fixState.currentFrame = 1
                
                -- Статистика каждый цикл
                print(string.format("🔄 Цикл завершен | Телепортаций: %d | Заблокировано анимаций: %d", 
                    fixState.teleportCount, fixState.blockedAnimations))
            end
        end
    end)
    
    print("🌟 Плавная фиксация запущена!")
    print("✨ Параметры: толерантность позиции = " .. fixState.positionTolerance)
    print("⏰ Кулдаун телепортации = " .. fixState.teleportCooldown .. " сек")
    print("🎭 Плавность поз = " .. (fixState.smoothingFactor * 100) .. "%")
    
    return fixConnection, fixState
end

-- 🎯 ГЛАВНАЯ ФУНКЦИЯ - ПЛАВНАЯ МГНОВЕННАЯ ФИКСАЦИЯ
local function smoothInstantFix()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    if isMagicalIdleMoment(petModel) then
        print("🌟 Питомец в магическом idle! Запускаю плавную фиксацию...")
        
        -- Быстрая запись поз (2 секунды)
        local magicalPoses, motor6Ds = recordMagicalPoses(petModel, 2)
        if magicalPoses then
            local connection, state = smoothMagicalFix(petModel, magicalPoses, motor6Ds)
            print("🎉 УСПЕХ! Плавная фиксация активна!")
            print("💡 Питомец больше не должен лагать!")
            
            -- Возможность остановки через 5 минут
            spawn(function()
                wait(300)
                connection:Disconnect()
                print("⏹️ Плавная фиксация остановлена через 5 минут")
                print(string.format("📊 Итоговая статистика: телепортаций = %d, заблокировано анимаций = %d", 
                    state.teleportCount, state.blockedAnimations))
            end)
            
            return connection
        end
    else
        print("❌ Питомец НЕ в idle состоянии!")
        print("💡 Дождись когда питомец встанет и попробуй снова")
    end
end

-- 🚀 ЗАПУСК
print("\n🌟 === ПЛАВНАЯ ФИКСАЦИЯ МАГИЧЕСКОГО IDLE ===")
print("✨ Устраняет лаги и дергания при фиксации!")
print("🎯 Запуск через 2 секунды...")

spawn(function()
    wait(2)
    smoothInstantFix()
end)
