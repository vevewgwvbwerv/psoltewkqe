-- 🔬 РАСШИРЕННАЯ ДИАГНОСТИКА - ОТСЛЕЖИВАНИЕ ЖИЗНЕННОГО ЦИКЛА КОМПОНЕНТОВ
-- Фокус на том КАК и КОГДА исчезают/появляются Humanoid и Animator

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === РАСШИРЕННАЯ ДИАГНОСТИКА ПИТОМЦА ===")
print("🎯 Цель: ОТСЛЕДИТЬ когда исчезают/появляются Humanoid и Animator")

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

-- 🔬 РАСШИРЕННЫЙ МОНИТОРИНГ КОМПОНЕНТОВ
local function startEnhancedMonitoring(petModel)
    print("\n📊 === РАСШИРЕННЫЙ МОНИТОРИНГ КОМПОНЕНТОВ ===")
    
    local rootPart = petModel:FindFirstChild("RootPart") or petModel:FindFirstChild("Torso") or petModel:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        print("❌ RootPart не найден!")
        return
    end
    
    -- Состояние компонентов
    local componentState = {
        humanoid = nil,
        animator = nil,
        humanoidExists = false,
        animatorExists = false,
        lastPosition = rootPart.Position,
        isMoving = false,
        standingTime = 0,
        movingTime = 0
    }
    
    -- 🔍 ОТСЛЕЖИВАНИЕ ПОЯВЛЕНИЯ/ИСЧЕЗНОВЕНИЯ КОМПОНЕНТОВ
    local function trackComponents()
        local currentHumanoid = petModel:FindFirstChildOfClass("Humanoid")
        local currentAnimator = petModel:FindFirstChildOfClass("Animator")
        
        -- Проверяем изменения Humanoid
        if currentHumanoid ~= componentState.humanoid then
            if currentHumanoid and not componentState.humanoidExists then
                print("🟢 HUMANOID ПОЯВИЛСЯ!")
                componentState.humanoidExists = true
            elseif not currentHumanoid and componentState.humanoidExists then
                print("🔴 HUMANOID ИСЧЕЗ!")
                componentState.humanoidExists = false
            end
            componentState.humanoid = currentHumanoid
        end
        
        -- Проверяем изменения Animator
        if currentAnimator ~= componentState.animator then
            if currentAnimator and not componentState.animatorExists then
                print("🟢 ANIMATOR ПОЯВИЛСЯ!")
                componentState.animatorExists = true
            elseif not currentAnimator and componentState.animatorExists then
                print("🔴 ANIMATOR ИСЧЕЗ!")
                componentState.animatorExists = false
            end
            componentState.animator = currentAnimator
        end
        
        return currentHumanoid, currentAnimator
    end
    
    -- 📊 ДЕТАЛЬНЫЙ АНАЛИЗ СОСТОЯНИЙ
    local function analyzeState(humanoid, animator, isMoving)
        print(string.format("\n⏰ === АНАЛИЗ (%.1f сек) ===", tick()))
        print("🏃 Движется:", isMoving and "ДА" or "НЕТ")
        print("⏱️ Стоит:", componentState.standingTime, "кадров")
        print("🏃 Движется:", componentState.movingTime, "кадров")
        
        -- Анализ Humanoid
        if humanoid and humanoid.Parent then
            print("🤖 === HUMANOID АКТИВЕН ===")
            print("  🏃 WalkSpeed:", humanoid.WalkSpeed)
            print("  🦘 JumpPower:", humanoid.JumpPower or "nil")
            print("  🦘 JumpHeight:", humanoid.JumpHeight or "nil")
            print("  🛑 PlatformStand:", humanoid.PlatformStand or "nil")
            print("  💺 Sit:", humanoid.Sit or "nil")
            print("  🎯 State:", humanoid:GetState().Name)
            print("  ❤️ Health:", humanoid.Health)
        else
            print("❌ HUMANOID ОТСУТСТВУЕТ")
        end
        
        -- Анализ Animator
        if animator and animator.Parent then
            print("🎭 === ANIMATOR АКТИВЕН ===")
            local tracks = animator:GetPlayingAnimationTracks()
            print("  📽️ Играющих анимаций:", #tracks)
            
            for i, track in pairs(tracks) do
                print(string.format("    %d. %s", i, track.Animation.Name))
                print(string.format("       🆔 ID: %s", track.Animation.AnimationId))
                print(string.format("       ▶️ Playing: %s", track.IsPlaying))
                print(string.format("       🔄 Looped: %s", track.Looped))
                print(string.format("       ⚡ Priority: %s", track.Priority.Name))
                print(string.format("       ⏱️ Time: %.2f/%.2f", track.TimePosition, track.Length or 0))
            end
        else
            print("❌ ANIMATOR ОТСУТСТВУЕТ")
        end
        
        -- Анализ позиции
        print("📍 === ПОЗИЦИЯ ===")
        print("  📍 Position:", rootPart.Position)
        print("  ⚡ Velocity:", rootPart.Velocity)
        print("  🌀 AngularVelocity:", rootPart.AngularVelocity)
        
        -- Анализ всех детей модели
        print("👥 === ВСЕ ДЕТИ МОДЕЛИ ===")
        local children = petModel:GetChildren()
        for i, child in pairs(children) do
            print(string.format("  %d. %s (%s)", i, child.Name, child.ClassName))
        end
    end
    
    -- 🔄 ОСНОВНОЙ ЦИКЛ МОНИТОРИНГА
    local connection
    connection = RunService.Heartbeat:Connect(function()
        
        -- Отслеживаем компоненты
        local humanoid, animator = trackComponents()
        
        -- Проверяем движение
        local currentPos = rootPart.Position
        local distance = (currentPos - componentState.lastPosition).Magnitude
        
        if distance > 0.1 then
            if not componentState.isMoving then
                print("\n🏃 === ПИТОМЕЦ НАЧАЛ ДВИГАТЬСЯ ===")
                componentState.isMoving = true
                componentState.standingTime = 0
            end
            componentState.movingTime = componentState.movingTime + 1
        else
            if componentState.isMoving then
                print("\n🛑 === ПИТОМЕЦ ОСТАНОВИЛСЯ ===")
                componentState.isMoving = false
                componentState.movingTime = 0
            end
            componentState.standingTime = componentState.standingTime + 1
        end
        
        componentState.lastPosition = currentPos
        
        -- Детальный анализ каждые 30 кадров (0.5 сек)
        if tick() % 0.5 < 0.02 then
            analyzeState(humanoid, animator, componentState.isMoving)
        end
        
        -- ОСОБЫЙ АНАЛИЗ когда питомец долго стоит
        if not componentState.isMoving and componentState.standingTime > 60 then
            print("\n🎯 === ПИТОМЕЦ ДОЛГО СТОИТ - ОСОБЫЙ АНАЛИЗ ===")
            
            -- Проверяем ВСЕ возможные места где могут быть компоненты
            print("🔍 === ПОИСК СКРЫТЫХ КОМПОНЕНТОВ ===")
            for _, obj in pairs(petModel:GetDescendants()) do
                if obj:IsA("Humanoid") then
                    print("🤖 Найден Humanoid в:", obj.Parent.Name, "->", obj.Name)
                elseif obj:IsA("Animator") then
                    print("🎭 Найден Animator в:", obj.Parent.Name, "->", obj.Name)
                end
            end
        end
    end)
    
    print("✅ Расширенный мониторинг запущен!")
    print("🔍 Отслеживаем появление/исчезновение компонентов...")
    
    -- Останавливаем через 120 секунд
    spawn(function()
        wait(120)
        connection:Disconnect()
        print("\n⏹️ Расширенный мониторинг остановлен через 120 секунд")
    end)
    
    return connection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    print("\n🎮 === НАЧИНАЕМ РАСШИРЕННЫЙ МОНИТОРИНГ ===")
    print("💡 Подойдите к питомцу и наблюдайте за компонентами")
    print("🔍 Особое внимание на моменты появления/исчезновения Humanoid и Animator")
    
    local connection = startEnhancedMonitoring(petModel)
end

-- 🚀 ПРЯМОЙ ЗАПУСК
print("\n🚀 === ЗАПУСКАЮ РАСШИРЕННУЮ ДИАГНОСТИКУ ===")
print("💡 Подойдите к питомцу и смотрите консоль!")
print("🔬 Анализ будет идти 120 секунд...")

spawn(function()
    wait(2)
    main()
end)

print("\n💡 === ЦЕЛЬ ДИАГНОСТИКИ ===")
print("🔍 1. ОТСЛЕДИТЬ когда исчезают Humanoid и Animator")
print("🔍 2. ПОНЯТЬ что вызывает их исчезновение")
print("🔍 3. НАЙТИ способ их восстановления или предотвращения исчезновения")
print("🔍 4. ВЫЯСНИТЬ связь между компонентами и idle анимацией")
print("\n🚀 ДИАГНОСТИКА ЗАПУЩЕНА!")
