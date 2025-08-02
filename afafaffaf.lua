-- 🧠 SMART ANIMATION SELECTOR - Умный выбор правильной анимации для копии
-- Находит и запускает idle/walk анимацию вместо текущей активной (копание/др.)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🧠 === SMART ANIMATION SELECTOR ===")
print("=" .. string.rep("=", 50))

-- Список предпочтительных анимаций (в порядке приоритета)
local PREFERRED_ANIMATIONS = {
    "idle", "walk", "stand", "standing", "default"
}

-- Функция поиска моделей
local function findModels()
    local original = nil
    local copy = nil
    local copyUUID = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") and obj.Name:find("_SCALED_COPY") then
            copy = obj
            copyUUID = obj.Name:gsub("_SCALED_COPY", "")
            break
        end
    end
    
    if copy then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == copyUUID then
                original = obj
                break
            end
        end
    end
    
    return original, copy
end

-- Функция анализа всех доступных анимаций
local function analyzeAllAnimations(model)
    print("🔍 Анализирую ВСЕ анимации модели:", model.Name)
    
    local animator = nil
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Animator") then
            animator = obj
            break
        end
    end
    
    if not animator then
        print("❌ Animator не найден!")
        return {}
    end
    
    -- Получаем все анимации (активные и неактивные)
    local allAnimations = {}
    local activeTracks = animator:GetPlayingAnimationTracks()
    
    print("📹 Активных анимаций:", #activeTracks)
    
    for i, track in ipairs(activeTracks) do
        if track.Animation then
            local animInfo = {
                id = track.Animation.AnimationId,
                name = track.Name or "Unknown",
                isPlaying = track.IsPlaying,
                speed = track.Speed,
                weight = track.WeightCurrent,
                looped = track.Looped,
                priority = track.Priority,
                track = track
            }
            
            table.insert(allAnimations, animInfo)
            
            print("  [" .. i .. "] " .. animInfo.name)
            print("    ID: " .. animInfo.id)
            print("    Playing: " .. tostring(animInfo.isPlaying))
            print("    Speed: " .. animInfo.speed)
            print("    Priority: " .. animInfo.priority.Name)
            print()
        end
    end
    
    return allAnimations
end

-- Функция выбора лучшей анимации для копии
local function selectBestAnimation(animations)
    print("🎯 Выбираю лучшую анимацию для копии...")
    
    if #animations == 0 then
        print("❌ Нет доступных анимаций!")
        return nil
    end
    
    -- Сначала ищем предпочтительные анимации
    for _, preferred in ipairs(PREFERRED_ANIMATIONS) do
        for _, anim in ipairs(animations) do
            if string.lower(anim.name):find(preferred) or string.lower(anim.id):find(preferred) then
                print("✅ Найдена предпочтительная анимация:", anim.name, "(" .. preferred .. ")")
                return anim
            end
        end
    end
    
    -- Если предпочтительных нет, берем первую зацикленную
    for _, anim in ipairs(animations) do
        if anim.looped and anim.isPlaying then
            print("✅ Выбрана зацикленная анимация:", anim.name)
            return anim
        end
    end
    
    -- В крайнем случае берем первую активную
    for _, anim in ipairs(animations) do
        if anim.isPlaying then
            print("⚠️ Выбрана первая активная анимация:", anim.name)
            return anim
        end
    end
    
    print("❌ Не удалось выбрать подходящую анимацию!")
    return nil
end

-- Функция запуска выбранной анимации на копии
local function startAnimationOnCopy(copyModel, selectedAnimation)
    print("🎬 Запускаю выбранную анимацию на копии...")
    
    local copyAnimator = nil
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Animator") then
            copyAnimator = obj
            break
        end
    end
    
    if not copyAnimator then
        print("❌ Animator не найден в копии!")
        return false
    end
    
    -- Останавливаем все текущие анимации на копии
    local currentTracks = copyAnimator:GetPlayingAnimationTracks()
    for _, track in ipairs(currentTracks) do
        track:Stop()
    end
    print("🛑 Остановлено " .. #currentTracks .. " текущих анимаций на копии")
    
    -- Создаем и запускаем новую анимацию
    local success, result = pcall(function()
        local animation = Instance.new("Animation")
        animation.AnimationId = selectedAnimation.id
        
        local newTrack = copyAnimator:LoadAnimation(animation)
        newTrack.Looped = selectedAnimation.looped
        newTrack.Priority = selectedAnimation.priority
        
        newTrack:Play()
        newTrack:AdjustSpeed(selectedAnimation.speed)
        newTrack:AdjustWeight(selectedAnimation.weight)
        
        return newTrack
    end)
    
    if success then
        print("✅ Анимация успешно запущена на копии!")
        print("  ID:", selectedAnimation.id)
        print("  Имя:", selectedAnimation.name)
        return true
    else
        print("❌ Ошибка запуска анимации:", result)
        return false
    end
end

-- Основная функция
local function main()
    local original, copy = findModels()
    
    if not original then
        print("❌ Оригинальный питомец не найден!")
        return
    end
    
    if not copy then
        print("❌ Копия питомца не найдена!")
        print("💡 Сначала создайте копию через PetScaler")
        return
    end
    
    print("🎯 Найдены модели:")
    print("  Оригинал:", original.Name)
    print("  Копия:", copy.Name)
    print()
    
    -- Анализируем все анимации оригинала
    local animations = analyzeAllAnimations(original)
    
    if #animations == 0 then
        print("❌ У оригинала нет анимаций для копирования!")
        return
    end
    
    -- Выбираем лучшую анимацию
    local bestAnimation = selectBestAnimation(animations)
    
    if not bestAnimation then
        print("❌ Не удалось выбрать подходящую анимацию!")
        return
    end
    
    -- Запускаем на копии
    local success = startAnimationOnCopy(copy, bestAnimation)
    
    if success then
        print("🎉 УСПЕХ! Правильная анимация запущена на копии!")
        print("🎭 Копия должна теперь правильно анимироваться")
    else
        print("❌ Не удалось запустить анимацию на копии")
    end
    
    print("=" .. string.rep("=", 50))
end

-- Запуск
main()
