-- 🔍 ANIMATOR DIAGNOSTIC - Анализ компонентов анимации питомца
-- Исследует возможность клонирования Animator и AI

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

print("🔍 === ANIMATOR DIAGNOSTIC ===")
print("Ищем питомца и анализируем его анимационные компоненты...")

-- Функция поиска питомца (из PetScaler)
local function findPet()
    local playerChar = player.Character
    if not playerChar then return nil end
    
    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local playerPos = hrp.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") then
            if obj.PrimaryPart then
                local distance = (obj.PrimaryPart.Position - playerPos).Magnitude
                if distance <= 100 then
                    return obj
                end
            end
        end
    end
    
    return nil
end

-- Функция анализа компонентов анимации
local function analyzeAnimationComponents(model)
    print("\n📋 === АНАЛИЗ МОДЕЛИ: " .. model.Name .. " ===")
    
    -- 1. HUMANOID
    local humanoid = model:FindFirstChild("Humanoid")
    if humanoid then
        print("✅ HUMANOID найден:")
        print("  - WalkSpeed:", humanoid.WalkSpeed)
        print("  - JumpPower:", humanoid.JumpPower)
        print("  - Health:", humanoid.Health)
        print("  - MaxHealth:", humanoid.MaxHealth)
        print("  - PlatformStand:", humanoid.PlatformStand)
    else
        print("❌ HUMANOID не найден")
    end
    
    -- 2. ANIMATOR
    local animator = model:FindFirstChildOfClass("Animator")
    if not animator and humanoid then
        animator = humanoid:FindFirstChildOfClass("Animator")
    end
    
    if animator then
        print("✅ ANIMATOR найден в:", animator.Parent.Name)
        
        -- Анализ активных анимаций
        local tracks = animator:GetPlayingAnimationTracks()
        print("  - Активных треков:", #tracks)
        
        for i, track in ipairs(tracks) do
            print("  - Трек " .. i .. ":")
            print("    - Animation ID:", track.Animation.AnimationId)
            print("    - IsPlaying:", track.IsPlaying)
            print("    - Length:", track.Length)
            print("    - Speed:", track.Speed)
            print("    - Priority:", track.Priority.Name)
        end
    else
        print("❌ ANIMATOR не найден")
    end
    
    -- 3. ANIMATION CONTROLLER (ГЛУБОКАЯ ДИАГНОСТИКА)
    local animController = model:FindFirstChildOfClass("AnimationController")
    if animController then
        print("✅ ANIMATION CONTROLLER найден")
        local controllerAnimator = animController:FindFirstChildOfClass("Animator")
        if controllerAnimator then
            print("  - Содержит Animator")
            local controllerTracks = controllerAnimator:GetPlayingAnimationTracks()
            print("  - Активных треков в контроллере:", #controllerTracks)
            
            -- ГЛУБОКАЯ АНАЛИЗ КАЖДОГО ТРЕКА
            for i, track in ipairs(controllerTracks) do
                print("\n  🎵 === ТРЕК " .. i .. " (КОНТРОЛЛЕР) ===")
                print("    - Animation ID: " .. (track.Animation and track.Animation.AnimationId or "N/A"))
                print("    - IsPlaying: " .. tostring(track.IsPlaying))
                print("    - Length: " .. tostring(track.Length))
                print("    - Speed: " .. tostring(track.Speed))
                print("    - Priority: " .. tostring(track.Priority))
                print("    - TimePosition: " .. tostring(track.TimePosition))
                print("    - IsLoaded: " .. tostring(track.IsLoaded))
                
                -- ПОЛНАЯ ИНФОРМАЦИЯ ОБ ANIMATION ОБЪЕКТЕ
                if track.Animation then
                    print("    - Animation Name: " .. track.Animation.Name)
                    print("    - Animation Parent: " .. (track.Animation.Parent and track.Animation.Parent.Name or "N/A"))
                    print("    - Animation ClassName: " .. track.Animation.ClassName)
                end
            end
        end
    else
        print("❌ ANIMATION CONTROLLER не найден")
    end
    
    -- 4. ANIMATION ОБЪЕКТЫ (РАСШИРЕННЫЙ ПОИСК)
    print("\n🎭 === ПОИСК ANIMATION ОБЪЕКТОВ ===")
    local animations = {}
    
    -- ПОИСК ВО ВСЕХ ПОТОМКАХ БЕЗ ОГРАНИЧЕНИЯ ГЛУБИНЫ
    local function findAnimations(parent, path)
        path = path or parent.Name
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Animation") then
                table.insert(animations, {
                    object = child,
                    path = path .. "." .. child.Name,
                    id = child.AnimationId,
                    name = child.Name
                })
            end
            -- Рекурсивный поиск во всех потомках
            findAnimations(child, path .. "." .. child.Name)
        end
    end
    
    findAnimations(model)
    
    -- ДОПОЛНИТЕЛЬНЫЙ ПОИСК В WORKSPACE
    print("🔍 Дополнительный поиск Animation объектов в Workspace...")
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Animation") and obj.AnimationId ~= "" then
            -- Проверяем, связан ли с нашей моделью
            local parent = obj.Parent
            local isRelated = false
            while parent do
                if parent == model then
                    isRelated = true
                    break
                end
                parent = parent.Parent
            end
            
            if isRelated then
                table.insert(animations, {
                    object = obj,
                    path = "Workspace." .. obj:GetFullName(),
                    id = obj.AnimationId,
                    name = obj.Name
                })
            end
        end
    end
    
    if #animations > 0 then
        print("✅ Найдено Animation объектов:", #animations)
        for i, anim in ipairs(animations) do
            print("  - " .. i .. ". " .. anim.name)
            print("    - Путь: " .. anim.path)
            print("    - ID: " .. anim.id)
        end
    else
        print("❌ Animation объекты не найдены")
        print("🔍 Попробуем найти Animation объекты по активным трекам...")
        
        -- ПОИСК ПО АКТИВНЫМ ТРЕКАМ
        if animController then
            local controllerAnimator = animController:FindFirstChildOfClass("Animator")
            if controllerAnimator then
                local tracks = controllerAnimator:GetPlayingAnimationTracks()
                for i, track in ipairs(tracks) do
                    if track.Animation then
                        table.insert(animations, {
                            object = track.Animation,
                            path = "ActiveTrack." .. track.Animation.Name,
                            id = track.Animation.AnimationId,
                            name = track.Animation.Name
                        })
                        print("  ✅ Найден через активный трек: " .. track.Animation.AnimationId)
                    end
                end
            end
        end
    end
    
    -- 5. SCRIPTS И AI
    print("\n🤖 === ПОИСК AI СКРИПТОВ ===")
    local scripts = {}
    
    local function findScripts(parent, depth)
        depth = depth or 0
        if depth > 5 then return end
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                table.insert(scripts, {
                    object = child,
                    type = child.ClassName,
                    path = parent.Name .. "." .. child.Name
                })
            end
            findScripts(child, depth + 1)
        end
    end
    
    findScripts(model)
    
    if #scripts > 0 then
        print("✅ Найдено скриптов:", #scripts)
        for i, script in ipairs(scripts) do
            print("  - " .. i .. ". " .. script.path .. " (" .. script.type .. ")")
        end
    else
        print("❌ Скрипты не найдены")
    end
    
    return {
        humanoid = humanoid,
        animator = animator,
        animController = animController,
        animations = animations,
        scripts = scripts
    }
end

-- Основная функция
local function main()
    local pet = findPet()
    
    if not pet then
        print("❌ Питомец не найден в радиусе 100 блоков")
        return
    end
    
    print("✅ Питомец найден:", pet.Name)
    
    local components = analyzeAnimationComponents(pet)
    
    -- ВЫВОД ЗАКЛЮЧЕНИЯ
    print("\n🎯 === ЗАКЛЮЧЕНИЕ ===")
    
    if components.humanoid and components.animator then
        print("✅ КЛОНИРОВАНИЕ ВОЗМОЖНО!")
        print("  - Humanoid: ✅")
        print("  - Animator: ✅")
        print("  - Анимации: " .. (#components.animations > 0 and "✅" or "❌"))
        print("  - AI Скрипты: " .. (#components.scripts > 0 and "✅" or "❌"))
        
        print("\n💡 ПЛАН КЛОНИРОВАНИЯ:")
        print("1. Клонировать Humanoid со всеми настройками")
        print("2. Клонировать Animator")
        if #components.animations > 0 then
            print("3. Клонировать все " .. #components.animations .. " Animation объектов")
        end
        if #components.scripts > 0 then
            print("4. Клонировать " .. #components.scripts .. " AI скриптов")
        end
        print("5. Подключить к масштабированной копии")
        print("6. Запустить независимую анимацию")
        
    else
        print("❌ КЛОНИРОВАНИЕ НЕВОЗМОЖНО")
        print("  - Отсутствуют критические компоненты")
    end
end

-- Запуск
main()
