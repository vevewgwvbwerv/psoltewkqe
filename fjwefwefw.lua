-- 🎮 ДИАГНОСТИКА ANIMATIONCONTROLLER - ФОКУС НА УПРАВЛЕНИИ АНИМАЦИЕЙ
-- Детальный анализ AnimationController и его Animator

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🎮 === ДИАГНОСТИКА ANIMATIONCONTROLLER ===")
print("🎯 Цель: ИЗУЧИТЬ AnimationController и его управление анимацией")

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

-- 🎮 ФОКУС НА ANIMATIONCONTROLLER
local function analyzeAnimationController(petModel)
    print("\n🎮 === АНАЛИЗ ANIMATIONCONTROLLER ===")
    
    -- Поиск всех AnimationController в модели
    local controllers = {}
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("AnimationController") then
            table.insert(controllers, obj)
        end
    end
    
    print("🎮 Найдено AnimationController:", #controllers)
    
    for i, controller in pairs(controllers) do
        print(string.format("\n🎮 === CONTROLLER %d ===", i))
        print("📍 Путь:", controller:GetFullName())
        print("👨‍👩‍👧‍👦 Родитель:", controller.Parent.Name)
        
        -- Анализ детей AnimationController
        local children = controller:GetChildren()
        print("👥 Детей:", #children)
        
        for j, child in pairs(children) do
            print(string.format("  %d. %s (%s)", j, child.Name, child.ClassName))
            
            -- Если это Animator - детальный анализ
            if child:IsA("Animator") then
                print("    🎭 === ДЕТАЛЬНЫЙ АНАЛИЗ ANIMATOR ===")
                
                local tracks = child:GetPlayingAnimationTracks()
                print("    📽️ Играющих анимаций:", #tracks)
                
                for k, track in pairs(tracks) do
                    print(string.format("      %d. %s", k, track.Animation.Name))
                    print(string.format("         🆔 ID: %s", track.Animation.AnimationId))
                    print(string.format("         ▶️ Playing: %s", track.IsPlaying))
                    print(string.format("         🔄 Looped: %s", track.Looped))
                    print(string.format("         ⚡ Priority: %s", track.Priority.Name))
                    print(string.format("         ⏱️ Time: %.2f/%.2f", track.TimePosition, track.Length or 0))
                    print(string.format("         🔊 Weight: %.2f", track.WeightCurrent))
                    print(string.format("         📈 Speed: %.2f", track.Speed))
                end
                
                -- Попытка получить все анимации (не только играющие)
                print("    🔍 === ПОИСК ВСЕХ АНИМАЦИЙ ===")
                local allTracks = child:GetChildren()
                for l, item in pairs(allTracks) do
                    if item:IsA("AnimationTrack") then
                        print(string.format("      Трек %d: %s", l, item.Animation.Name))
                    end
                end
            end
        end
    end
    
    return controllers
end

-- 🔄 МОНИТОРИНГ ANIMATIONCONTROLLER В РЕАЛЬНОМ ВРЕМЕНИ
local function startControllerMonitoring(petModel)
    print("\n📊 === МОНИТОРИНГ ANIMATIONCONTROLLER ===")
    
    local rootPart = petModel:FindFirstChild("RootPart") or petModel:FindFirstChild("Torso") or petModel:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        print("❌ RootPart не найден!")
        return
    end
    
    local lastPosition = rootPart.Position
    local isMoving = false
    local standingTime = 0
    local movingTime = 0
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        
        -- Проверяем движение
        local currentPos = rootPart.Position
        local distance = (currentPos - lastPosition).Magnitude
        
        if distance > 0.1 then
            if not isMoving then
                print("\n🏃 === ПИТОМЕЦ НАЧАЛ ДВИГАТЬСЯ ===")
                isMoving = true
                standingTime = 0
                
                -- Анализируем AnimationController при начале движения
                print("🎮 === ANIMATIONCONTROLLER ПРИ ДВИЖЕНИИ ===")
                analyzeAnimationController(petModel)
            end
            movingTime = movingTime + 1
        else
            if isMoving then
                print("\n🛑 === ПИТОМЕЦ ОСТАНОВИЛСЯ ===")
                isMoving = false
                movingTime = 0
                
                -- Анализируем AnimationController при остановке
                print("🎮 === ANIMATIONCONTROLLER ПРИ ОСТАНОВКЕ ===")
                analyzeAnimationController(petModel)
            end
            standingTime = standingTime + 1
        end
        
        lastPosition = currentPos
        
        -- Периодический анализ каждые 2 секунды
        if tick() % 2 < 0.02 then
            print(string.format("\n⏰ === ПЕРИОДИЧЕСКИЙ АНАЛИЗ (%.1f сек) ===", tick()))
            print("🏃 Движется:", isMoving and "ДА" or "НЕТ")
            print("⏱️ Стоит:", standingTime, "кадров")
            print("🏃 Движется:", movingTime, "кадров")
            
            -- Быстрый анализ AnimationController
            local controllers = {}
            for _, obj in pairs(petModel:GetDescendants()) do
                if obj:IsA("AnimationController") then
                    table.insert(controllers, obj)
                end
            end
            
            print("🎮 AnimationController найдено:", #controllers)
            
            for i, controller in pairs(controllers) do
                local animators = {}
                for _, child in pairs(controller:GetChildren()) do
                    if child:IsA("Animator") then
                        table.insert(animators, child)
                    end
                end
                
                print(string.format("  Controller %d: %d Animator(s)", i, #animators))
                
                for j, animator in pairs(animators) do
                    local tracks = animator:GetPlayingAnimationTracks()
                    print(string.format("    Animator %d: %d активных анимаций", j, #tracks))
                    
                    for k, track in pairs(tracks) do
                        print(string.format("      %d. %s (Looped: %s, Playing: %s)", 
                            k, track.Animation.Name, track.Looped, track.IsPlaying))
                    end
                end
            end
        end
        
        -- ОСОБЫЙ АНАЛИЗ когда долго стоит
        if not isMoving and standingTime > 120 then -- 2 секунды стояния
            print("\n🎯 === ДОЛГОЕ СТОЯНИЕ - ДЕТАЛЬНЫЙ АНАЛИЗ CONTROLLER ===")
            analyzeAnimationController(petModel)
            standingTime = 0 -- Сбрасываем чтобы не спамить
        end
    end)
    
    print("✅ Мониторинг AnimationController запущен!")
    
    -- Останавливаем через 120 секунд
    spawn(function()
        wait(120)
        connection:Disconnect()
        print("\n⏹️ Мониторинг AnimationController остановлен")
    end)
    
    return connection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    print("\n🎮 === НАЧАЛЬНЫЙ АНАЛИЗ ANIMATIONCONTROLLER ===")
    analyzeAnimationController(petModel)
    
    print("\n🎮 === ЗАПУСК МОНИТОРИНГА ===")
    print("💡 Подойдите к питомцу и наблюдайте за AnimationController")
    print("🔍 Особое внимание на анимации в момент стояния и движения")
    
    local connection = startControllerMonitoring(petModel)
end

-- 🚀 ПРЯМОЙ ЗАПУСК
print("\n🚀 === ЗАПУСКАЮ ДИАГНОСТИКУ ANIMATIONCONTROLLER ===")
print("💡 Фокус на AnimationController и его Animator!")
print("🔬 Анализ будет идти 120 секунд...")

spawn(function()
    wait(2)
    main()
end)

print("\n💡 === ЦЕЛЬ ДИАГНОСТИКИ ===")
print("🎮 1. ИЗУЧИТЬ структуру AnimationController")
print("🎭 2. НАЙТИ все Animator внутри AnimationController")
print("📽️ 3. ОТСЛЕДИТЬ какие анимации играют в idle и walking")
print("🔄 4. ПОНЯТЬ как зациклить idle анимацию через AnimationController")
print("🎯 5. НАЙТИ способ принудительного управления анимацией")
print("\n🚀 ДИАГНОСТИКА ЗАПУЩЕНА!")
