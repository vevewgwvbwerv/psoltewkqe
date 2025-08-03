-- 🔬 ГЛУБОКИЙ АНАЛИЗ RBXASSETID АНИМАЦИИ - ВСКРЫВАЕМ ВСЕ!
-- Детальное изучение rbxassetid://1073293904134356 и попытки хакинга

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

print("🔬 === ГЛУБОКИЙ АНАЛИЗ RBXASSETID АНИМАЦИИ ===")
print("🎯 Цель: ВСКРЫТЬ rbxassetid://1073293904134356 и ЗАХАКАТЬ его!")
print("💡 Grow a Garden - ВСЕ ВОЗМОЖНО!")

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

-- 🔬 ГЛУБОКИЙ АНАЛИЗ RBXASSETID
local function deepAnalyzeAnimation(animationId)
    print("\n🔬 === ГЛУБОКИЙ АНАЛИЗ RBXASSETID ===")
    print("🆔 ID:", animationId)
    
    -- Попытка 1: Анализ через MarketplaceService
    print("\n💰 === АНАЛИЗ ЧЕРЕЗ MARKETPLACESERVICE ===")
    local success1, info1 = pcall(function()
        return MarketplaceService:GetProductInfo(1073293904134356)
    end)
    
    if success1 then
        print("✅ Информация получена:")
        for key, value in pairs(info1) do
            print("  " .. key .. ":", value)
        end
    else
        print("❌ MarketplaceService не сработал:", info1)
    end
    
    -- Попытка 2: Создание Animation объекта
    print("\n🎭 === СОЗДАНИЕ ANIMATION ОБЪЕКТА ===")
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    
    print("✅ Animation объект создан:")
    print("  Name:", animation.Name)
    print("  AnimationId:", animation.AnimationId)
    print("  ClassName:", animation.ClassName)
    print("  Parent:", animation.Parent)
    
    -- Попытка 3: Анализ всех свойств Animation
    print("\n📋 === ВСЕ СВОЙСТВА ANIMATION ===")
    local properties = {
        "AnimationId", "Name", "ClassName", "Parent", "Archivable"
    }
    
    for _, prop in pairs(properties) do
        local success, value = pcall(function()
            return animation[prop]
        end)
        if success then
            print("  " .. prop .. ":", value)
        else
            print("  " .. prop .. ": ❌ Недоступно")
        end
    end
    
    -- Попытка 4: Получение всех методов
    print("\n🔧 === ВСЕ МЕТОДЫ ANIMATION ===")
    local methods = {
        "Clone", "Destroy", "FindFirstChild", "GetChildren", "GetDescendants",
        "IsA", "GetFullName", "WaitForChild"
    }
    
    for _, method in pairs(methods) do
        local success = pcall(function()
            return animation[method]
        end)
        if success then
            print("  ✅ " .. method .. " - доступен")
        else
            print("  ❌ " .. method .. " - недоступен")
        end
    end
    
    return animation
end

-- 🎭 ЭКСТРЕМАЛЬНЫЕ ПОПЫТКИ ХАКИНГА АНИМАЦИИ
local function extremeAnimationHacking(petModel, animation)
    print("\n🔥 === ЭКСТРЕМАЛЬНЫЕ ПОПЫТКИ ХАКИНГА ===")
    
    -- Находим AnimationController и Animator
    local animationController = nil
    local animator = nil
    
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("AnimationController") then
            animationController = obj
            animator = obj:FindFirstChildOfClass("Animator")
            break
        end
    end
    
    if not animationController or not animator then
        print("❌ AnimationController или Animator не найден!")
        return
    end
    
    print("✅ Найден AnimationController и Animator")
    
    -- ХАКИНГ 1: Клонирование анимации
    print("\n🔥 ХАКИНГ 1: Клонирование анимации...")
    local success1, clonedAnimation = pcall(function()
        local clone = animation:Clone()
        clone.Name = "HACKED_IDLE"
        clone.Parent = animator
        return clone
    end)
    
    if success1 then
        print("✅ Анимация склонирована:", clonedAnimation.Name)
    else
        print("❌ Клонирование не удалось:", clonedAnimation)
    end
    
    -- ХАКИНГ 2: Создание множественных треков
    print("\n🔥 ХАКИНГ 2: Создание множественных треков...")
    local tracks = {}
    for i = 1, 5 do
        local success, track = pcall(function()
            local newAnimation = Instance.new("Animation")
            newAnimation.AnimationId = animation.AnimationId
            newAnimation.Name = "IDLE_HACK_" .. i
            
            local animTrack = animator:LoadAnimation(newAnimation)
            animTrack.Looped = true
            animTrack.Priority = Enum.AnimationPriority.Action4
            
            return animTrack
        end)
        
        if success then
            table.insert(tracks, track)
            print("✅ Трек", i, "создан")
        else
            print("❌ Трек", i, "не создан:", track)
        end
    end
    
    -- ХАКИНГ 3: Принудительное переопределение всех анимаций
    print("\n🔥 ХАКИНГ 3: Переопределение всех анимаций...")
    local success3 = pcall(function()
        -- Останавливаем ВСЕ анимации
        local allTracks = animator:GetPlayingAnimationTracks()
        for _, track in pairs(allTracks) do
            track:Stop()
        end
        
        -- Запускаем наши хакнутые треки
        for _, track in pairs(tracks) do
            track:Play()
        end
        
        print("✅ Все анимации переопределены")
    end)
    
    if not success3 then
        print("❌ Переопределение не удалось")
    end
    
    -- ХАКИНГ 4: Блокировка загрузки новых анимаций
    print("\n🔥 ХАКИНГ 4: Блокировка загрузки новых анимаций...")
    local originalLoadAnimation = animator.LoadAnimation
    
    local success4 = pcall(function()
        animator.LoadAnimation = function(self, anim)
            -- Если это не наша idle анимация - блокируем
            if not anim.AnimationId:find("1073293904134356") then
                print("🚫 ЗАБЛОКИРОВАНА анимация:", anim.AnimationId)
                return nil
            end
            
            -- Если это idle - разрешаем но с нашими параметрами
            local track = originalLoadAnimation(self, anim)
            if track then
                track.Looped = true
                track.Priority = Enum.AnimationPriority.Action4
                print("✅ РАЗРЕШЕНА idle анимация с хакнутыми параметрами")
            end
            
            return track
        end
        
        print("✅ LoadAnimation перехвачен!")
    end)
    
    if not success4 then
        print("❌ Перехват LoadAnimation не удался")
    end
    
    -- ХАКИНГ 5: Постоянный мониторинг и восстановление
    print("\n🔥 ХАКИНГ 5: Постоянный мониторинг...")
    
    local hackConnection
    hackConnection = RunService.Heartbeat:Connect(function()
        
        -- Проверяем что наши треки все еще играют
        local ourTracksPlaying = 0
        for _, track in pairs(tracks) do
            if track and track.IsPlaying then
                ourTracksPlaying = ourTracksPlaying + 1
            end
        end
        
        -- Если наши треки не играют - перезапускаем
        if ourTracksPlaying == 0 then
            for _, track in pairs(tracks) do
                if track then
                    pcall(function()
                        track:Play()
                    end)
                end
            end
        end
        
        -- Останавливаем любые другие анимации
        local allTracks = animator:GetPlayingAnimationTracks()
        for _, track in pairs(allTracks) do
            if not track.Animation.AnimationId:find("1073293904134356") then
                pcall(function()
                    track:Stop()
                end)
            end
        end
    end)
    
    print("✅ Постоянный мониторинг запущен!")
    
    return tracks, hackConnection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    print("\n🔬 === НАЧИНАЕМ ГЛУБОКИЙ АНАЛИЗ ===")
    
    local animationId = "rbxassetid://1073293904134356"
    local animation = deepAnalyzeAnimation(animationId)
    
    print("\n🔥 === НАЧИНАЕМ ЭКСТРЕМАЛЬНЫЙ ХАКИНГ ===")
    local tracks, connection = extremeAnimationHacking(petModel, animation)
    
    if tracks and #tracks > 0 then
        print("🎉 ХАКИНГ УСПЕШЕН! Создано треков:", #tracks)
        print("🔄 Постоянный мониторинг активен!")
        print("💡 Питомец должен быть заблокирован в idle анимации!")
    else
        print("❌ Хакинг не удался")
    end
    
    -- Останавливаем через 300 секунд (5 минут)
    spawn(function()
        wait(300)
        if connection then
            connection:Disconnect()
        end
        print("\n⏹️ Хакинг остановлен через 5 минут")
    end)
end

-- 🚀 ПРЯМОЙ ЗАПУСК
print("\n🚀 === ЗАПУСКАЮ ГЛУБОКИЙ АНАЛИЗ И ХАКИНГ ===")
print("🔥 Grow a Garden - ВСЕ ВОЗМОЖНО!")
print("🎯 Цель: ЗАХАКАТЬ idle анимацию любой ценой!")

spawn(function()
    wait(2)
    main()
end)

print("\n💡 === МЕТОДЫ ХАКИНГА ===")
print("🔥 1. Клонирование анимации")
print("🔥 2. Создание множественных треков")
print("🔥 3. Переопределение всех анимаций")
print("🔥 4. Блокировка загрузки новых анимаций")
print("🔥 5. Постоянный мониторинг и восстановление")
print("\n🚀 ХАКИНГ ЗАПУЩЕН!")
