-- 🧪 SIMPLE ANIMATION TEST - Простой тест анимации без изменения Anchored
-- Просто пытается запустить анимацию на копии без всяких сложностей

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🧪 === SIMPLE ANIMATION TEST ===")
print("=" .. string.rep("=", 40))

-- Функция поиска моделей
local function findModels()
    local original = nil
    local copy = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            if obj.Name:find("_SCALED_COPY") then
                copy = obj
            else
                original = obj
            end
        end
    end
    
    return original, copy
end

-- Простая функция запуска анимации
local function simpleAnimationStart(originalModel, copyModel)
    print("🎬 Простой запуск анимации...")
    
    -- Находим аниматоры
    local originalAnimator = nil
    local copyAnimator = nil
    
    for _, obj in pairs(originalModel:GetDescendants()) do
        if obj:IsA("Animator") then
            originalAnimator = obj
            break
        end
    end
    
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("Animator") then
            copyAnimator = obj
            break
        end
    end
    
    if not originalAnimator then
        print("❌ Animator не найден в оригинале!")
        return false
    end
    
    if not copyAnimator then
        print("❌ Animator не найден в копии!")
        return false
    end
    
    print("✅ Найдены аниматоры:")
    print("  Оригинал:", originalAnimator:GetFullName())
    print("  Копия:", copyAnimator:GetFullName())
    
    -- Получаем активные анимации оригинала
    local originalTracks = originalAnimator:GetPlayingAnimationTracks()
    print("📹 Активных анимаций в оригинале:", #originalTracks)
    
    if #originalTracks == 0 then
        print("❌ Нет активных анимаций для копирования!")
        return false
    end
    
    -- Копируем первую анимацию
    local firstTrack = originalTracks[1]
    if not firstTrack.Animation then
        print("❌ У анимации нет Animation объекта!")
        return false
    end
    
    print("🎯 Копирую анимацию:", firstTrack.Animation.AnimationId)
    print("  Скорость:", firstTrack.Speed)
    print("  Зацикленность:", firstTrack.Looped)
    print("  Играет:", firstTrack.IsPlaying)
    
    -- Создаем новую анимацию для копии
    local newAnimation = Instance.new("Animation")
    newAnimation.AnimationId = firstTrack.Animation.AnimationId
    
    -- Загружаем и запускаем
    local success, result = pcall(function()
        local newTrack = copyAnimator:LoadAnimation(newAnimation)
        newTrack.Looped = firstTrack.Looped
        newTrack:Play()
        newTrack:AdjustSpeed(firstTrack.Speed)
        return newTrack
    end)
    
    if success then
        print("✅ Анимация успешно запущена на копии!")
        
        -- Проверяем через секунду
        wait(1)
        local copyTracks = copyAnimator:GetPlayingAnimationTracks()
        print("📊 Проверка: активных анимаций на копии:", #copyTracks)
        
        for i, track in ipairs(copyTracks) do
            print("  [" .. i .. "] Играет:", track.IsPlaying, "| ID:", track.Animation.AnimationId)
        end
        
        return #copyTracks > 0
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
    
    -- Проверяем состояние копии ДО попытки анимации
    print("🔍 Состояние копии ДО анимации:")
    local partsBefore = 0
    for _, obj in pairs(copy:GetDescendants()) do
        if obj:IsA("BasePart") then
            partsBefore = partsBefore + 1
        end
    end
    print("  Частей:", partsBefore)
    
    -- Пытаемся запустить анимацию
    local success = simpleAnimationStart(original, copy)
    
    -- Проверяем состояние копии ПОСЛЕ попытки анимации
    print("🔍 Состояние копии ПОСЛЕ анимации:")
    local partsAfter = 0
    for _, obj in pairs(copy:GetDescendants()) do
        if obj:IsA("BasePart") then
            partsAfter = partsAfter + 1
        end
    end
    print("  Частей:", partsAfter)
    
    if partsBefore ~= partsAfter then
        print("⚠️ ВНИМАНИЕ: Количество частей изменилось! (" .. partsBefore .. " -> " .. partsAfter .. ")")
    end
    
    if success then
        print("🎉 ТЕСТ ПРОЙДЕН: Анимация работает!")
    else
        print("❌ ТЕСТ НЕ ПРОЙДЕН: Анимация не работает")
    end
    
    print("=" .. string.rep("=", 40))
end

-- Запуск
main()
