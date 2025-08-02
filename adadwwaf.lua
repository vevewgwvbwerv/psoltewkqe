-- 🔄 ANIMATION COPYING TEST - Тест копирования анимации через клонирование
-- Вместо создания новой Animation пытаемся клонировать существующую

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🔄 === ANIMATION COPYING TEST ===")
print("=" .. string.rep("=", 40))

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

-- Функция получения активной анимации оригинала
local function getOriginalAnimation(original)
    print("🔍 Ищу активную анимацию у оригинала...")
    
    local animator = nil
    for _, obj in pairs(original:GetDescendants()) do
        if obj:IsA("Animator") then
            animator = obj
            break
        end
    end
    
    if not animator then
        print("❌ Animator не найден!")
        return nil
    end
    
    local activeTracks = animator:GetPlayingAnimationTracks()
    print("📹 Активных анимаций:", #activeTracks)
    
    if #activeTracks == 0 then
        print("❌ Нет активных анимаций!")
        return nil
    end
    
    -- Берем первую активную анимацию
    local track = activeTracks[1]
    if not track.Animation then
        print("❌ У трека нет Animation объекта!")
        return nil
    end
    
    print("✅ Найдена анимация:")
    print("  Name:", track.Name or "Unknown")
    print("  ID:", track.Animation.AnimationId)
    print("  Playing:", track.IsPlaying)
    print("  Speed:", track.Speed)
    print("  Weight:", track.WeightCurrent)
    print("  Looped:", track.Looped)
    
    return track
end

-- МЕТОД 1: Клонирование Animation объекта
local function method1_CloneAnimation(originalTrack, copyAnimator)
    print("🔄 МЕТОД 1: Клонирование Animation объекта")
    
    local success, result = pcall(function()
        -- Клонируем сам Animation объект
        local clonedAnimation = originalTrack.Animation:Clone()
        print("✅ Animation объект клонирован")
        
        -- Загружаем клонированную анимацию
        local newTrack = copyAnimator:LoadAnimation(clonedAnimation)
        print("✅ Анимация загружена в Animator копии")
        
        -- Копируем все параметры
        newTrack.Looped = originalTrack.Looped
        newTrack.Priority = originalTrack.Priority
        
        -- Запускаем
        newTrack:Play()
        newTrack:AdjustSpeed(originalTrack.Speed)
        newTrack:AdjustWeight(originalTrack.WeightCurrent)
        
        print("✅ Анимация запущена с параметрами оригинала")
        return newTrack
    end)
    
    if success then
        print("🎉 МЕТОД 1 УСПЕШЕН!")
        return result
    else
        print("❌ МЕТОД 1 НЕУДАЧЕН:", result)
        return nil
    end
end

-- МЕТОД 2: Копирование через AnimationId
local function method2_CopyById(originalTrack, copyAnimator)
    print("🆔 МЕТОД 2: Копирование через AnimationId")
    
    local success, result = pcall(function()
        local animation = Instance.new("Animation")
        animation.AnimationId = originalTrack.Animation.AnimationId
        
        local newTrack = copyAnimator:LoadAnimation(animation)
        newTrack.Looped = originalTrack.Looped
        newTrack.Priority = originalTrack.Priority
        
        newTrack:Play()
        newTrack:AdjustSpeed(originalTrack.Speed)
        newTrack:AdjustWeight(originalTrack.WeightCurrent)
        
        return newTrack
    end)
    
    if success then
        print("🎉 МЕТОД 2 УСПЕШЕН!")
        return result
    else
        print("❌ МЕТОД 2 НЕУДАЧЕН:", result)
        return nil
    end
end

-- МЕТОД 3: Попытка найти Animation в оригинальной модели
local function method3_FindInModel(original, copyAnimator)
    print("🔍 МЕТОД 3: Поиск Animation объектов в модели")
    
    local animations = {}
    for _, obj in pairs(original:GetDescendants()) do
        if obj:IsA("Animation") then
            table.insert(animations, obj)
            print("  Найден Animation:", obj.Name, obj.AnimationId)
        end
    end
    
    if #animations == 0 then
        print("❌ Animation объекты не найдены в модели")
        return nil
    end
    
    -- Пробуем первую найденную анимацию
    local success, result = pcall(function()
        local clonedAnim = animations[1]:Clone()
        local newTrack = copyAnimator:LoadAnimation(clonedAnim)
        newTrack.Looped = true
        newTrack:Play()
        return newTrack
    end)
    
    if success then
        print("🎉 МЕТОД 3 УСПЕШЕН!")
        return result
    else
        print("❌ МЕТОД 3 НЕУДАЧЕН:", result)
        return nil
    end
end

-- Функция проверки результата
local function checkResult(copy)
    print("🔍 Проверяю результат...")
    
    local copyAnimator = nil
    for _, obj in pairs(copy:GetDescendants()) do
        if obj:IsA("Animator") then
            copyAnimator = obj
            break
        end
    end
    
    if not copyAnimator then
        print("❌ Animator копии не найден!")
        return false
    end
    
    wait(1) -- Даем время анимации запуститься
    
    local activeTracks = copyAnimator:GetPlayingAnimationTracks()
    print("📹 Активных анимаций у копии:", #activeTracks)
    
    local hasPlayingAnimation = false
    for i, track in ipairs(activeTracks) do
        print("  [" .. i .. "] " .. (track.Name or "Unknown"))
        print("    Playing:", track.IsPlaying)
        if track.IsPlaying then
            hasPlayingAnimation = true
        end
    end
    
    return hasPlayingAnimation
end

-- Основная функция
local function main()
    local original, copy = findModels()
    
    if not original or not copy then
        print("❌ Модели не найдены!")
        return
    end
    
    print("🎯 Найдены модели:")
    print("  Оригинал:", original.Name)
    print("  Копия:", copy.Name)
    print()
    
    -- Получаем анимацию оригинала
    local originalTrack = getOriginalAnimation(original)
    if not originalTrack then
        print("❌ Не удалось получить анимацию оригинала!")
        return
    end
    
    -- Получаем Animator копии
    local copyAnimator = nil
    for _, obj in pairs(copy:GetDescendants()) do
        if obj:IsA("Animator") then
            copyAnimator = obj
            break
        end
    end
    
    if not copyAnimator then
        print("❌ Animator копии не найден!")
        return
    end
    
    -- Останавливаем текущие анимации копии
    local currentTracks = copyAnimator:GetPlayingAnimationTracks()
    for _, track in ipairs(currentTracks) do
        track:Stop()
    end
    print("🛑 Остановлено " .. #currentTracks .. " анимаций копии")
    print()
    
    -- Пробуем разные методы
    local success = false
    
    -- МЕТОД 1: Клонирование
    local result1 = method1_CloneAnimation(originalTrack, copyAnimator)
    if result1 then
        success = checkResult(copy)
        if success then
            print("🎉 УСПЕХ! Метод клонирования работает!")
            return
        end
    end
    
    print()
    
    -- МЕТОД 2: По ID
    local result2 = method2_CopyById(originalTrack, copyAnimator)
    if result2 then
        success = checkResult(copy)
        if success then
            print("🎉 УСПЕХ! Метод по ID работает!")
            return
        end
    end
    
    print()
    
    -- МЕТОД 3: Поиск в модели
    local result3 = method3_FindInModel(original, copyAnimator)
    if result3 then
        success = checkResult(copy)
        if success then
            print("🎉 УСПЕХ! Метод поиска в модели работает!")
            return
        end
    end
    
    print()
    print("❌ ВСЕ МЕТОДЫ НЕУДАЧНЫ!")
    print("💡 Возможно анимации действительно защищены от копирования")
    
    print("=" .. string.rep("=", 40))
end

-- Запуск
main()
