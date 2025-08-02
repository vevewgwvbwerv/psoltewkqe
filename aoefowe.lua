-- 🎭 PET ANIMATION RESTORER - Восстановление анимации на копии питомца
-- Анализирует оригинал и восстанавливает анимацию на увеличенной копии

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🎭 === PET ANIMATION RESTORER ===")
print("=" .. string.rep("=", 50))

-- Функция восстановления анимации на копии
local function restoreAnimationOnCopy(originalModel, copyModel)
    print("🔄 Восстанавливаю анимацию на копии...")
    print("  Оригинал:", originalModel.Name)
    print("  Копия:", copyModel.Name)
    
    -- 1. Находим анимационные компоненты в оригинале
    local originalAnimator = nil
    local originalAnimController = nil
    local activeAnimations = {}
    
    for _, obj in pairs(originalModel:GetDescendants()) do
        if obj:IsA("Animator") then
            originalAnimator = obj
            -- Получаем активные анимации
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in ipairs(tracks) do
                if track.IsPlaying then
                    table.insert(activeAnimations, {
                        animationId = track.Animation.AnimationId,
                        speed = track.Speed,
                        weight = track.WeightCurrent,
                        looped = track.Looped,
                        priority = track.Priority
                    })
                    print("  📹 Найдена активная анимация:", track.Animation.AnimationId)
                end
            end
        elseif obj:IsA("AnimationController") then
            originalAnimController = obj
        end
    end
    
    -- 2. Находим анимационные компоненты в копии
    local copyAnimator = nil
    local copyAnimController = nil
    
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Animator") then
            copyAnimator = obj
        elseif obj:IsA("AnimationController") then
            copyAnimController = obj
        end
    end
    
    if not copyAnimator or not copyAnimController then
        print("❌ Анимационные компоненты не найдены в копии!")
        return false
    end
    
    -- 3. КРИТИЧНО: Снимаем Anchored с ВСЕХ частей копии чтобы Motor6D работали
    print("🔓 Снимаю Anchored со всех частей копии...")
    local unanchoredCount = 0
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Anchored = false
            unanchoredCount = unanchoredCount + 1
        end
    end
    print("  ✅ Снят Anchored с", unanchoredCount, "частей")
    
    -- 4. Запускаем анимации на копии
    print("🎬 Запускаю анимации на копии...")
    for i, animData in ipairs(activeAnimations) do
        -- Создаем Animation объект
        local animation = Instance.new("Animation")
        animation.AnimationId = animData.animationId
        
        -- Загружаем анимацию через Animator копии
        local animTrack = copyAnimator:LoadAnimation(animation)
        
        -- Настраиваем параметры как у оригинала
        animTrack.Looped = animData.looped
        animTrack.Priority = animData.priority
        
        -- Запускаем анимацию
        animTrack:Play()
        animTrack:AdjustSpeed(animData.speed)
        animTrack:AdjustWeight(animData.weight)
        
        print("  ✅ [" .. i .. "] Запущена анимация:", animData.animationId)
        print("    Speed:", animData.speed)
        print("    Weight:", animData.weight)
        print("    Looped:", animData.looped)
    end
    
    -- 5. Проверяем что Motor6D работают
    print("🔧 Проверяю Motor6D в копии...")
    local motor6DCount = 0
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Motor6D") then
            motor6DCount = motor6DCount + 1
            if obj.Part0 and obj.Part1 then
                print("  ✅ Motor6D:", obj.Name, "(" .. obj.Part0.Name .. " -> " .. obj.Part1.Name .. ")")
            end
        end
    end
    print("  📊 Всего Motor6D:", motor6DCount)
    
    print("🎉 Анимация восстановлена на копии!")
    return true
end

-- Функция поиска оригинала и копии
local function findOriginalAndCopy()
    local original = nil
    local copy = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            if obj.Name:find("_SCALED_COPY") then
                copy = obj
                print("🎯 Найдена копия:", obj.Name)
            else
                original = obj
                print("🎯 Найден оригинал:", obj.Name)
            end
        end
    end
    
    return original, copy
end

-- Основная функция
local function main()
    local original, copy = findOriginalAndCopy()
    
    if not original then
        print("❌ Оригинальный питомец не найден!")
        return
    end
    
    if not copy then
        print("❌ Копия питомца не найдена!")
        print("💡 Сначала создайте копию через PetScaler")
        return
    end
    
    -- Восстанавливаем анимацию
    local success = restoreAnimationOnCopy(original, copy)
    
    if success then
        print("✅ АНИМАЦИЯ УСПЕШНО ВОССТАНОВЛЕНА!")
        print("🎭 Копия питомца теперь должна анимироваться!")
    else
        print("❌ Не удалось восстановить анимацию")
    end
    
    print("=" .. string.rep("=", 50))
end

-- Запуск
main()
