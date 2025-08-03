-- 🎭 КОНТРОЛЛЕР IDLE АНИМАЦИИ - УПРАВЛЕНИЕ НАЙДЕННОЙ АНИМАЦИЕЙ
-- Попытка программного управления idle анимацией через AnimationTrack

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🎭 === КОНТРОЛЛЕР IDLE АНИМАЦИИ ===")
print("🎯 Цель: УПРАВЛЯТЬ найденной idle анимацией rbxassetid://1073293904134356")

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

-- 🐾 РАБОЧАЯ ФУНКЦИЯ ПОИСКА ПИТОМЦА (из PetScaler_v2.2)

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

-- Функция поиска питомца
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

-- 🎭 ПОИСК И УПРАВЛЕНИЕ IDLE АНИМАЦИЕЙ
local function findAndControlIdleAnimation(petModel)
    print("\n🎭 === ПОИСК IDLE АНИМАЦИИ ===")
    
    -- Поиск AnimationController
    local animationController = nil
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("AnimationController") then
            animationController = obj
            break
        end
    end
    
    if not animationController then
        print("❌ AnimationController не найден!")
        return nil
    end
    
    print("✅ AnimationController найден:", animationController:GetFullName())
    
    -- Поиск Animator внутри AnimationController
    local animator = animationController:FindFirstChildOfClass("Animator")
    if not animator then
        print("❌ Animator не найден в AnimationController!")
        return nil
    end
    
    print("✅ Animator найден:", animator:GetFullName())
    
    -- Поиск idle анимации
    local idleTrack = nil
    local tracks = animator:GetPlayingAnimationTracks()
    
    print("📽️ Всего играющих анимаций:", #tracks)
    
    for i, track in pairs(tracks) do
        print(string.format("🎬 Анимация %d:", i))
        print("  📛 Название:", track.Animation.Name)
        print("  🆔 ID:", track.Animation.AnimationId)
        print("  ▶️ Playing:", track.IsPlaying)
        print("  🔄 Looped:", track.Looped)
        print("  ⚡ Priority:", track.Priority.Name)
        print("  ⏱️ Time:", track.TimePosition, "/", track.Length or 0)
        print("  🔊 Weight:", track.WeightCurrent)
        print("  📈 Speed:", track.Speed)
        
        -- Ищем idle анимацию
        if track.Animation.Name:lower():find("idle") or 
           track.Animation.AnimationId:find("1073293904134356") then
            idleTrack = track
            print("🎯 НАЙДЕНА IDLE АНИМАЦИЯ!")
        end
    end
    
    return idleTrack, animator
end

-- 🔄 ПОПЫТКИ УПРАВЛЕНИЯ IDLE АНИМАЦИЕЙ
local function attemptIdleControl(idleTrack, animator)
    if not idleTrack then
        print("❌ Idle анимация не найдена для управления!")
        return
    end
    
    print("\n🎭 === ПОПЫТКИ УПРАВЛЕНИЯ IDLE АНИМАЦИЕЙ ===")
    
    -- Метод 1: Принудительное зацикливание
    print("🔄 Метод 1: Принудительное зацикливание...")
    local success1 = pcall(function()
        idleTrack.Looped = true
        print("✅ Установлен Looped = true")
    end)
    if not success1 then
        print("❌ Не удалось установить Looped = true")
    end
    
    -- Метод 2: Изменение приоритета
    print("⚡ Метод 2: Повышение приоритета...")
    local success2 = pcall(function()
        idleTrack.Priority = Enum.AnimationPriority.Action
        print("✅ Установлен приоритет Action")
    end)
    if not success2 then
        print("❌ Не удалось изменить приоритет")
    end
    
    -- Метод 3: Изменение скорости
    print("📈 Метод 3: Изменение скорости...")
    local success3 = pcall(function()
        idleTrack:AdjustSpeed(1.0)
        print("✅ Установлена скорость 1.0")
    end)
    if not success3 then
        print("❌ Не удалось изменить скорость")
    end
    
    -- Метод 4: Принудительный перезапуск
    print("🔄 Метод 4: Принудительный перезапуск...")
    local success4 = pcall(function()
        idleTrack:Stop()
        wait(0.1)
        idleTrack:Play()
        print("✅ Анимация перезапущена")
    end)
    if not success4 then
        print("❌ Не удалось перезапустить анимацию")
    end
    
    -- Метод 5: Создание собственного idle трека
    print("🎭 Метод 5: Создание собственного idle трека...")
    local success5 = pcall(function()
        local idleAnimation = Instance.new("Animation")
        idleAnimation.AnimationId = "rbxassetid://1073293904134356"
        
        local newIdleTrack = animator:LoadAnimation(idleAnimation)
        newIdleTrack.Looped = true
        newIdleTrack.Priority = Enum.AnimationPriority.Action
        newIdleTrack:Play()
        
        print("✅ Создан собственный idle трек")
        return newIdleTrack
    end)
    if not success5 then
        print("❌ Не удалось создать собственный idle трек")
    end
    
    return success1 or success2 or success3 or success4 or success5
end

-- 🔄 МОНИТОРИНГ И ПОДДЕРЖАНИЕ IDLE
local function startIdleMaintenance(petModel)
    print("\n🔄 === ЗАПУСК ПОДДЕРЖАНИЯ IDLE ===")
    
    local rootPart = petModel:FindFirstChild("RootPart") or petModel:FindFirstChild("Torso") or petModel:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        print("❌ RootPart не найден!")
        return
    end
    
    local lastPosition = rootPart.Position
    local isMoving = false
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        
        -- Проверяем движение
        local currentPos = rootPart.Position
        local distance = (currentPos - lastPosition).Magnitude
        
        if distance > 0.1 then
            if not isMoving then
                print("\n🏃 === ПИТОМЕЦ НАЧАЛ ДВИГАТЬСЯ ===")
                isMoving = true
            end
        else
            if isMoving then
                print("\n🛑 === ПИТОМЕЦ ОСТАНОВИЛСЯ ===")
                isMoving = false
                
                -- Когда питомец остановился - пытаемся контролировать idle
                spawn(function()
                    wait(1) -- Ждем секунду для стабилизации
                    print("🎭 Попытка контроля idle после остановки...")
                    
                    local idleTrack, animator = findAndControlIdleAnimation(petModel)
                    if idleTrack then
                        attemptIdleControl(idleTrack, animator)
                    end
                end)
            end
        end
        
        lastPosition = currentPos
        
        -- Периодическая проверка каждые 5 секунд
        if tick() % 5 < 0.02 and not isMoving then
            print("\n🔄 === ПЕРИОДИЧЕСКАЯ ПРОВЕРКА IDLE ===")
            local idleTrack, animator = findAndControlIdleAnimation(petModel)
            if idleTrack then
                print("🎭 Idle анимация найдена, состояние:")
                print("  ▶️ Playing:", idleTrack.IsPlaying)
                print("  🔄 Looped:", idleTrack.Looped)
                print("  ⏱️ Time:", idleTrack.TimePosition, "/", idleTrack.Length or 0)
                
                -- Если анимация не зациклена - пытаемся зациклить
                if not idleTrack.Looped then
                    print("⚠️ Анимация не зациклена! Пытаемся исправить...")
                    attemptIdleControl(idleTrack, animator)
                end
            end
        end
    end)
    
    print("✅ Мониторинг idle запущен!")
    
    -- Останавливаем через 120 секунд
    spawn(function()
        wait(120)
        connection:Disconnect()
        print("\n⏹️ Мониторинг idle остановлен")
    end)
    
    return connection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    print("\n🎭 === НАЧАЛЬНЫЙ АНАЛИЗ IDLE АНИМАЦИИ ===")
    local idleTrack, animator = findAndControlIdleAnimation(petModel)
    
    if idleTrack then
        print("\n🎯 === ПОПЫТКА УПРАВЛЕНИЯ ===")
        local controlSuccess = attemptIdleControl(idleTrack, animator)
        
        if controlSuccess then
            print("✅ Некоторые методы управления сработали!")
        else
            print("❌ Все методы управления не сработали")
        end
    else
        print("❌ Idle анимация не найдена")
    end
    
    print("\n🔄 === ЗАПУСК МОНИТОРИНГА ===")
    local connection = startIdleMaintenance(petModel)
end

-- 🚀 ПРЯМОЙ ЗАПУСК
print("\n🚀 === ЗАПУСКАЮ КОНТРОЛЛЕР IDLE АНИМАЦИИ ===")
print("🎭 Попытка управления rbxassetid://1073293904134356")
print("🔬 Анализ будет идти 120 секунд...")

spawn(function()
    wait(2)
    main()
end)

print("\n💡 === МЕТОДЫ УПРАВЛЕНИЯ ===")
print("🔄 1. Принудительное зацикливание (Looped = true)")
print("⚡ 2. Повышение приоритета анимации")
print("📈 3. Изменение скорости анимации")
print("🔄 4. Принудительный перезапуск")
print("🎭 5. Создание собственного idle трека")
print("\n🚀 КОНТРОЛЛЕР ЗАПУЩЕН!")
