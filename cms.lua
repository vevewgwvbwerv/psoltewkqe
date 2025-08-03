-- 🔄 ХИРУРГИЧЕСКАЯ ЗАМЕНА ANIMATION ID - ЗАМЕНЯЕМ ХОДЬБУ НА IDLE
-- Находим анимацию ходьбы и заменяем ее ID на idle ID

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔄 === ХИРУРГИЧЕСКАЯ ЗАМЕНА ANIMATION ID ===")
print("🎯 Цель: Заменить ID ходьбы на ID idle анимации")
print("💡 Гениальная идея пользователя!")

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

-- ID анимаций
local IDLE_ID = "rbxassetid://1073293904134356"  -- Найденная idle анимация
local WALK_KEYWORDS = {"walk", "run", "move", "step", "locomotion"}  -- Ключевые слова для поиска ходьбы

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

-- 🔍 ПОИСК ВСЕХ АНИМАЦИЙ В МОДЕЛИ
local function findAllAnimations(petModel)
    print("\n🔍 === ПОИСК ВСЕХ АНИМАЦИЙ ===")
    
    local animations = {}
    
    -- Ищем все Animation объекты
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animation") then
            table.insert(animations, {
                object = obj,
                type = "Animation",
                id = obj.AnimationId,
                name = obj.Name,
                parent = obj.Parent
            })
        end
    end
    
    -- Ищем все AnimationTrack через Animator
    for _, obj in pairs(petModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                table.insert(animations, {
                    object = track,
                    type = "AnimationTrack",
                    id = track.Animation.AnimationId,
                    name = track.Animation.Name,
                    parent = obj,
                    track = track
                })
            end
        end
    end
    
    print("📽️ Найдено анимаций:", #animations)
    
    for i, anim in pairs(animations) do
        print(string.format("  %d. %s (%s)", i, anim.name, anim.type))
        print(string.format("     🆔 ID: %s", anim.id))
        print(string.format("     👨‍👩‍👧‍👦 Parent: %s", anim.parent.Name))
    end
    
    return animations
end

-- 🔄 ЗАМЕНА ID АНИМАЦИЙ
local function replaceAnimationIDs(animations)
    print("\n🔄 === ЗАМЕНА ANIMATION ID ===")
    
    local replacedCount = 0
    
    for i, anim in pairs(animations) do
        local isWalkAnimation = false
        
        -- Проверяем является ли это анимацией ходьбы
        local name = anim.name:lower()
        local id = anim.id:lower()
        
        for _, keyword in pairs(WALK_KEYWORDS) do
            if name:find(keyword) or id:find(keyword) then
                isWalkAnimation = true
                break
            end
        end
        
        -- Также проверяем если это НЕ idle анимация
        if not name:find("idle") and not id:find("1073293904134356") then
            -- Если это не idle - считаем это ходьбой
            isWalkAnimation = true
        end
        
        if isWalkAnimation then
            print(string.format("🎯 Найдена анимация ходьбы: %s", anim.name))
            print(string.format("   Старый ID: %s", anim.id))
            
            -- Попытка замены ID
            local success = pcall(function()
                if anim.type == "Animation" then
                    anim.object.AnimationId = IDLE_ID
                    print("✅ Animation ID заменен на idle")
                elseif anim.type == "AnimationTrack" then
                    anim.object.Animation.AnimationId = IDLE_ID
                    print("✅ AnimationTrack ID заменен на idle")
                end
            end)
            
            if success then
                replacedCount = replacedCount + 1
                print("✅ Замена успешна!")
            else
                print("❌ Замена не удалась")
                
                -- Попытка создать новую анимацию с idle ID
                local success2 = pcall(function()
                    local newAnimation = Instance.new("Animation")
                    newAnimation.AnimationId = IDLE_ID
                    newAnimation.Name = anim.name .. "_IDLE_REPLACED"
                    newAnimation.Parent = anim.parent
                    
                    -- Если это AnimationTrack - перезагружаем
                    if anim.type == "AnimationTrack" and anim.parent:IsA("Animator") then
                        local newTrack = anim.parent:LoadAnimation(newAnimation)
                        newTrack.Looped = true
                        newTrack.Priority = Enum.AnimationPriority.Action
                        newTrack:Play()
                        
                        -- Останавливаем старый трек
                        anim.track:Stop()
                    end
                    
                    print("✅ Создана новая idle анимация взамен старой")
                end)
                
                if success2 then
                    replacedCount = replacedCount + 1
                end
            end
        else
            print(string.format("⏭️ Пропускаем: %s (уже idle или не ходьба)", anim.name))
        end
    end
    
    print(string.format("\n🎉 Заменено анимаций: %d", replacedCount))
    return replacedCount
end

-- 🔄 МОНИТОРИНГ И ПОСТОЯННАЯ ЗАМЕНА
local function startContinuousReplacement(petModel)
    print("\n🔄 === ЗАПУСК ПОСТОЯННОЙ ЗАМЕНЫ ===")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        
        -- Каждые 2 секунды проверяем и заменяем анимации
        if tick() % 2 < 0.02 then
            local animations = findAllAnimations(petModel)
            
            -- Ищем новые анимации ходьбы и заменяем их
            for _, anim in pairs(animations) do
                local name = anim.name:lower()
                local id = anim.id:lower()
                
                -- Если это не idle анимация - заменяем
                if not name:find("idle") and not id:find("1073293904134356") then
                    pcall(function()
                        if anim.type == "Animation" then
                            anim.object.AnimationId = IDLE_ID
                        elseif anim.type == "AnimationTrack" then
                            anim.object.Animation.AnimationId = IDLE_ID
                            anim.track.Looped = true
                        end
                    end)
                end
            end
        end
    end)
    
    print("✅ Постоянная замена запущена!")
    
    -- Останавливаем через 300 секунд (5 минут)
    spawn(function()
        wait(300)
        connection:Disconnect()
        print("\n⏹️ Постоянная замена остановлена через 5 минут")
    end)
    
    return connection
end

-- Главная функция
local function main()
    local petModel = findPet()
    if not petModel then
        return
    end
    
    print("\n🔍 === ПОИСК АНИМАЦИЙ ===")
    local animations = findAllAnimations(petModel)
    
    if #animations == 0 then
        print("❌ Анимации не найдены!")
        return
    end
    
    print("\n🔄 === ЗАМЕНА ID ===")
    local replacedCount = replaceAnimationIDs(animations)
    
    if replacedCount > 0 then
        print("🎉 ЗАМЕНА УСПЕШНА!")
        print("💡 Все анимации ходьбы заменены на idle!")
        
        -- Запускаем постоянную замену
        local connection = startContinuousReplacement(petModel)
        
        print("🔄 Постоянная замена активна!")
    else
        print("❌ Замена не удалась")
    end
end

-- 🚀 ПРЯМОЙ ЗАПУСК
print("\n🚀 === ЗАПУСКАЮ ХИРУРГИЧЕСКУЮ ЗАМЕНУ ===")
print("🎯 Гениальная идея: заменить ID ходьбы на ID idle!")
print("🔄 Анализ будет идти 5 минут...")

spawn(function()
    wait(2)
    main()
end)

print("\n💡 === СТРАТЕГИЯ ЗАМЕНЫ ===")
print("🔍 1. Найти все Animation и AnimationTrack объекты")
print("🎯 2. Определить какие из них относятся к ходьбе")
print("🔄 3. Заменить их ID на rbxassetid://1073293904134356 (idle)")
print("🔄 4. Постоянно мониторить и заменять новые анимации ходьбы")
print("✅ 5. Результат: питомец будет играть idle вместо ходьбы!")
print("\n🚀 ЗАМЕНА ЗАПУЩЕНА!")
