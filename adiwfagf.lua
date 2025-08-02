-- 🎯 PRECISE IDLE RESTORER - Точное восстановление Idle анимации на копии
-- На основе анализа: копируем именно Idle анимацию (rbxassetid://1073293904134556)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🎯 === PRECISE IDLE RESTORER ===")
print("=" .. string.rep("=", 40))

-- Точный ID Idle анимации (из анализа)
local IDLE_ANIMATION_ID = "rbxassetid://1073293904134556"

-- Функция поиска моделей
local function findModels()
    local original = nil
    local copy = nil
    local copyUUID = nil
    
    -- Сначала ищем копию
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") and obj.Name:find("_SCALED_COPY") then
            copy = obj
            copyUUID = obj.Name:gsub("_SCALED_COPY", "")
            print("🎯 Найдена копия:", obj.Name)
            break
        end
    end
    
    if not copy then
        print("❌ Копия не найдена!")
        return nil, nil
    end
    
    -- Ищем оригинал с тем же UUID
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == copyUUID then
            original = obj
            print("✅ Найден оригинал:", obj.Name)
            break
        end
    end
    
    return original, copy
end

-- Функция проверки что у оригинала есть Idle анимация
local function verifyOriginalHasIdle(original)
    print("🔍 Проверяю наличие Idle анимации у оригинала...")
    
    local animator = nil
    for _, obj in pairs(original:GetDescendants()) do
        if obj:IsA("Animator") then
            animator = obj
            break
        end
    end
    
    if not animator then
        print("❌ Animator не найден у оригинала!")
        return false
    end
    
    local activeTracks = animator:GetPlayingAnimationTracks()
    print("📹 Активных анимаций у оригинала:", #activeTracks)
    
    local hasIdle = false
    for _, track in ipairs(activeTracks) do
        if track.Animation and track.Animation.AnimationId == IDLE_ANIMATION_ID then
            hasIdle = true
            print("✅ Idle анимация найдена у оригинала!")
            print("  Playing:", track.IsPlaying)
            print("  Speed:", track.Speed)
            print("  Weight:", track.WeightCurrent)
            break
        end
    end
    
    if not hasIdle then
        print("⚠️ Idle анимация НЕ активна у оригинала!")
        print("💡 Попробуй когда питомец стоит на месте")
        
        -- Показываем что активно
        for i, track in ipairs(activeTracks) do
            if track.Animation then
                print("  [" .. i .. "] " .. (track.Name or "Unknown") .. " - " .. track.Animation.AnimationId)
            end
        end
    end
    
    return hasIdle
end

-- Функция запуска Idle анимации на копии
local function startIdleOnCopy(copy)
    print("🎬 Запускаю Idle анимацию на копии...")
    
    local copyAnimator = nil
    for _, obj in pairs(copy:GetDescendants()) do
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
    print("🛑 Останавливаю " .. #currentTracks .. " текущих анимаций на копии")
    
    for _, track in ipairs(currentTracks) do
        track:Stop()
    end
    
    -- Создаем и запускаем Idle анимацию
    local success, result = pcall(function()
        local animation = Instance.new("Animation")
        animation.AnimationId = IDLE_ANIMATION_ID
        
        local idleTrack = copyAnimator:LoadAnimation(animation)
        idleTrack.Looped = true
        idleTrack.Priority = Enum.AnimationPriority.Action
        
        idleTrack:Play()
        idleTrack:AdjustSpeed(1)
        idleTrack:AdjustWeight(1)
        
        print("✅ Idle анимация запущена на копии!")
        print("  ID:", IDLE_ANIMATION_ID)
        print("  Looped: true")
        print("  Speed: 1")
        print("  Weight: 1")
        
        return idleTrack
    end)
    
    if success then
        -- Проверяем что анимация действительно играет
        wait(0.5)
        local newTracks = copyAnimator:GetPlayingAnimationTracks()
        local isPlaying = false
        
        for _, track in ipairs(newTracks) do
            if track.Animation and track.Animation.AnimationId == IDLE_ANIMATION_ID and track.IsPlaying then
                isPlaying = true
                break
            end
        end
        
        if isPlaying then
            print("🎉 УСПЕХ! Idle анимация активна на копии!")
            return true
        else
            print("❌ Анимация создана, но не играет")
            return false
        end
    else
        print("❌ Ошибка создания анимации:", result)
        return false
    end
end

-- Функция проверки результата
local function verifyResult(copy)
    print("🔍 Проверяю результат...")
    
    local copyAnimator = nil
    for _, obj in pairs(copy:GetDescendants()) do
        if obj:IsA("Animator") then
            copyAnimator = obj
            break
        end
    end
    
    if not copyAnimator then
        return false
    end
    
    local activeTracks = copyAnimator:GetPlayingAnimationTracks()
    print("📹 Активных анимаций у копии:", #activeTracks)
    
    for i, track in ipairs(activeTracks) do
        if track.Animation then
            print("  [" .. i .. "] " .. (track.Name or "Unknown"))
            print("    ID: " .. track.Animation.AnimationId)
            print("    Playing: " .. tostring(track.IsPlaying))
            print("    Speed: " .. track.Speed)
            
            if track.Animation.AnimationId == IDLE_ANIMATION_ID and track.IsPlaying then
                print("✅ Idle анимация работает правильно!")
                return true
            end
        end
    end
    
    print("❌ Idle анимация не найдена или не играет")
    return false
end

-- Основная функция
local function main()
    local original, copy = findModels()
    
    if not original or not copy then
        print("❌ Не найдены нужные модели!")
        print("💡 Убедись что есть оригинал и копия с _SCALED_COPY")
        return
    end
    
    print("🎯 Модели найдены:")
    print("  Оригинал:", original.Name)
    print("  Копия:", copy.Name)
    print()
    
    -- Проверяем что у оригинала есть Idle (опционально)
    print("📋 Проверка оригинала (для справки):")
    verifyOriginalHasIdle(original)
    print()
    
    -- Запускаем Idle на копии
    print("🎬 Запуск Idle анимации на копии:")
    local success = startIdleOnCopy(copy)
    
    if success then
        print()
        print("🔍 Финальная проверка:")
        local verified = verifyResult(copy)
        
        if verified then
            print("🎉 ВСЕ ГОТОВО! Копия должна правильно анимироваться!")
            print("🎭 Копия теперь в состоянии Idle (стоит на месте)")
        else
            print("❌ Что-то пошло не так при проверке")
        end
    else
        print("❌ Не удалось запустить Idle анимацию")
    end
    
    print("=" .. string.rep("=", 40))
end

-- Запуск
main()
