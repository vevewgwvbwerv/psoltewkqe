-- 🧊 ЗАМОРОЗКА IDLE - ПРИНЦИПИАЛЬНО НОВЫЙ ПОДХОД
-- Вместо борьбы с анимациями - ЗАМОРАЖИВАЕМ Motor6D в idle позах!

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

-- 🧊 ЗАМОРОЗКА IDLE ПОЗ (НОВЫЙ ПОДХОД!)
local function captureAndFreezeIdle(petModel)
    print("🧊 === ЗАМОРОЗКА IDLE - НОВЫЙ ПОДХОД ===")
    print("🎯 Стратегия: НЕ бороться с анимациями, а ЗАМОРОЗИТЬ Motor6D!")
    
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    local rootPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Torso")
    local originalPosition = rootPart and rootPart.Position or Vector3.new(0, 0, 0)
    
    -- Находим все Motor6D
    local motor6Ds = {}
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6Ds, obj)
        end
    end
    
    if #motor6Ds == 0 then
        print("❌ Motor6D не найдены!")
        return
    end
    
    print("🔧 Найдено Motor6D:", #motor6Ds)
    
    -- ШАГ 1: ОДИН РАЗ блокируем движение (не каждый кадр!)
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.PlatformStand = true
        humanoid.Sit = false
        humanoid.AutoRotate = false
        print("🛡️ Humanoid заблокирован ОДИН РАЗ")
    end
    
    if rootPart then
        rootPart.Anchored = true
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.AngularVelocity = Vector3.new(0, 0, 0)
        print("🛡️ RootPart заякорен ОДИН РАЗ")
    end
    
    -- ШАГ 2: ОДИН РАЗ уничтожаем walking анимации (не каждый кадр!)
    print("💀 Уничтожаю walking анимации ОДИН РАЗ...")
    local destroyedCount = 0
    
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                local name = track.Animation.Name:lower()
                local id = track.Animation.AnimationId:lower()
                
                if not name:find("idle") and not id:find("1073293904134356") then
                    track:Stop()
                    track:Destroy()
                    destroyedCount = destroyedCount + 1
                    print("💀 Уничтожена:", track.Animation.Name)
                end
            end
        end
    end
    
    print("💀 Уничтожено walking анимаций:", destroyedCount)
    
    -- ШАГ 3: Ждем стабилизации idle
    print("⏳ Ждем стабилизации idle (2 секунды)...")
    wait(2)
    
    -- ШАГ 4: ЗАХВАТЫВАЕМ текущие idle позы
    print("📸 Захватываю текущие idle позы...")
    local frozenPoses = {}
    
    for _, motor in pairs(motor6Ds) do
        frozenPoses[motor.Name] = {
            C0 = motor.C0,
            C1 = motor.C1,
            Transform = motor.Transform
        }
        print("📸 Захвачена поза:", motor.Name)
    end
    
    -- ШАГ 5: ЗАМОРАЖИВАЕМ Motor6D в этих позах (НЕ КАЖДЫЙ КАДР!)
    print("🧊 ЗАМОРАЖИВАЮ Motor6D в idle позах...")
    
    -- Отключаем все анимации НАВСЕГДА
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            obj.Enabled = false
            print("❄️ Animator отключен навсегда")
        end
        if obj:IsA("AnimationController") then
            obj.Enabled = false
            print("❄️ AnimationController отключен навсегда")
        end
    end
    
    -- Замораживаем Motor6D в idle позах
    for _, motor in pairs(motor6Ds) do
        local pose = frozenPoses[motor.Name]
        if pose then
            motor.C0 = pose.C0
            motor.C1 = pose.C1
            motor.Transform = pose.Transform
            
            -- КЛЮЧЕВОЕ: отключаем Motor6D от анимационной системы
            motor.Enabled = false
            print("🧊 Motor6D заморожен:", motor.Name)
        end
    end
    
    print("🧊 === ЗАМОРОЗКА ЗАВЕРШЕНА ===")
    print("❄️ Все Animator/AnimationController отключены")
    print("🧊 Все Motor6D заморожены в idle позах")
    print("🛡️ Движение заблокировано")
    
    -- МИНИМАЛЬНЫЙ мониторинг только позиции (не анимаций!)
    local monitorConnection
    monitorConnection = RunService.Heartbeat:Connect(function()
        -- Только проверяем позицию раз в секунду
        if tick() % 1 < 0.016 then
            if rootPart and originalPosition then
                if (rootPart.Position - originalPosition).Magnitude > 0.1 then
                    rootPart.Position = originalPosition
                    print("🔄 Коррекция позиции")
                end
            end
        end
    end)
    
    print("👁️ Минимальный мониторинг позиции включен")
    
    -- Автоматическая остановка через 5 минут
    spawn(function()
        wait(300)
        monitorConnection:Disconnect()
        
        -- Восстанавливаем анимационную систему
        for _, motor in pairs(motor6Ds) do
            motor.Enabled = true
        end
        
        for _, obj in pairs(petModel:GetDescendants()) do
            if obj:IsA("Animator") then
                obj.Enabled = true
            end
            if obj:IsA("AnimationController") then
                obj.Enabled = true
            end
        end
        
        print("🔓 Заморозка снята через 5 минут")
    end)
    
    return monitorConnection
end

-- 🎯 АВТОМАТИЧЕСКИЙ ЛОВЕЦ С ЗАМОРОЗКОЙ
local function freezeAutoMagicalCatcher()
    local petModel = findPet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    print("🧊 === АВТОМАТИЧЕСКИЙ ЛОВЕЦ С ЗАМОРОЗКОЙ ===")
    print("🎯 Новая стратегия: ЗАМОРОЗИТЬ вместо БОРОТЬСЯ!")
    print("🔍 Поиск магического момента... (макс. 60 секунд)")
    
    local searchStartTime = tick()
    local lastCheckTime = 0
    
    local searchConnection
    searchConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - lastCheckTime >= 0.1 then
            lastCheckTime = now
            
            if isMagicalIdleMoment(petModel) then
                print("🌟 === МАГИЧЕСКИЙ МОМЕНТ ПОЙМАН! ===")
                print("🧊 Запускаю ЗАМОРОЗКУ idle...")
                searchConnection:Disconnect()
                
                local connection = captureAndFreezeIdle(petModel)
                print("🎉 УСПЕХ! Питомец ЗАМОРОЖЕН в idle!")
                print("❄️ Никаких дерганий - анимационная система отключена!")
                
                return
            end
            
            if math.floor(now - searchStartTime) % 10 == 0 and (now - searchStartTime) % 10 < 0.1 then
                print(string.format("🔍 Поиск магического момента... %.0f сек", now - searchStartTime))
            end
            
            if now - searchStartTime >= 60 then
                searchConnection:Disconnect()
                print("⏰ Время поиска истекло!")
            end
        end
    end)
end

-- 🚀 ЗАПУСК
print("\n🧊 === ЗАМОРОЗКА IDLE - ПРИНЦИПИАЛЬНО НОВЫЙ ПОДХОД ===")
print("❄️ Стратегия: ЗАМОРОЗИТЬ Motor6D вместо борьбы с анимациями")
print("🛡️ Отключение Animator/AnimationController навсегда")
print("🧊 Фиксация Motor6D в idle позах")
print("👁️ Минимальный мониторинг только позиции")
print("🎯 Запуск через 2 секунды...")

spawn(function()
    wait(2)
    freezeAutoMagicalCatcher()
end)
