-- 🔍 ДИАГНОСТИКА КОПИИ ПИТОМЦА - Анализ Motor6D и анимации
-- Сравнивает оригинал и копию для выявления проблем

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

print("🔍 === ДИАГНОСТИКА КОПИИ ПИТОМЦА ===")
print("=" .. string.rep("=", 50))

-- Функция анализа модели
local function analyzeModel(model, modelType)
    print("\n📊 АНАЛИЗ " .. modelType .. ": " .. model.Name)
    print("-" .. string.rep("-", 40))
    
    -- Анализ BasePart
    local parts = {}
    local anchoredParts = {}
    local freeParts = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
            if obj.Anchored then
                table.insert(anchoredParts, obj.Name)
            else
                table.insert(freeParts, obj.Name)
            end
        end
    end
    
    print("🧩 Всего частей:", #parts)
    print("⚓ Заякоренных частей:", #anchoredParts)
    if #anchoredParts > 0 then
        print("   Заякоренные:", table.concat(anchoredParts, ", "))
    end
    print("🎭 Свободных частей:", #freeParts)
    if #freeParts > 0 and #freeParts <= 10 then
        print("   Свободные:", table.concat(freeParts, ", "))
    elseif #freeParts > 10 then
        print("   Свободные: (слишком много для вывода)")
    end
    
    -- Анализ Motor6D
    local motor6ds = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motor6ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "nil",
                part1 = obj.Part1 and obj.Part1.Name or "nil",
                enabled = obj.Enabled
            })
        end
    end
    
    print("🔧 Motor6D соединений:", #motor6ds)
    for i, motor in ipairs(motor6ds) do
        local status = motor.enabled and "✅" or "❌"
        print(string.format("   %s %s: %s → %s", status, motor.name, motor.part0, motor.part1))
    end
    
    -- Анализ Animator и анимации
    local animator = model:FindFirstChildOfClass("Animator", true)
    if animator then
        print("🎬 Animator найден:", animator.Parent.Name)
        
        -- Проверяем активные анимации
        local animationTracks = animator:GetPlayingAnimationTracks()
        print("🎭 Активных анимаций:", #animationTracks)
        
        for i, track in ipairs(animationTracks) do
            print(string.format("   🎵 %s (ID: %s, Playing: %s, Looped: %s)", 
                track.Name or "Unnamed", 
                track.Animation.AnimationId,
                tostring(track.IsPlaying),
                tostring(track.Looped)
            ))
        end
    else
        print("❌ Animator не найден!")
    end
    
    -- Анализ Humanoid
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        print("👤 Humanoid найден")
        print("   PlatformStand:", humanoid.PlatformStand)
        print("   Sit:", humanoid.Sit)
        print("   Health:", humanoid.Health .. "/" .. humanoid.MaxHealth)
    else
        print("❌ Humanoid не найден")
    end
    
    return {
        parts = #parts,
        anchoredParts = #anchoredParts,
        freeParts = #freeParts,
        motor6ds = #motor6ds,
        hasAnimator = animator ~= nil,
        activeAnimations = animator and #animator:GetPlayingAnimationTracks() or 0
    }
end

-- Функция поиска моделей
local function findModels()
    local originalModels = {}
    local copyModels = {}
    
    -- Ищем все модели в Workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            -- Проверяем UUID формат (36 символов с дефисами)
            if string.match(obj.Name, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                table.insert(originalModels, obj)
            elseif string.find(obj.Name, "_SCALED_COPY") then
                table.insert(copyModels, obj)
            end
        end
    end
    
    return originalModels, copyModels
end

-- Основная функция
local function main()
    local originals, copies = findModels()
    
    print("🔍 Найдено оригинальных моделей:", #originals)
    print("📋 Найдено копий:", #copies)
    
    if #originals == 0 then
        print("❌ Оригинальные модели не найдены!")
        return
    end
    
    if #copies == 0 then
        print("❌ Копии не найдены! Сначала создайте копию с помощью PetScaler")
        return
    end
    
    -- Анализируем первую пару
    local original = originals[1]
    local copy = copies[1]
    
    local originalStats = analyzeModel(original, "ОРИГИНАЛ")
    local copyStats = analyzeModel(copy, "КОПИЯ")
    
    -- Сравнение
    print("\n🔍 === СРАВНЕНИЕ ===")
    print("-" .. string.rep("-", 30))
    
    local function compareField(field, name, unit)
        unit = unit or ""
        if originalStats[field] == copyStats[field] then
            print("✅ " .. name .. ": " .. originalStats[field] .. unit .. " (одинаково)")
        else
            print("⚠️ " .. name .. ": " .. originalStats[field] .. unit .. " → " .. copyStats[field] .. unit .. " (РАЗНЫЕ!)")
        end
    end
    
    compareField("parts", "Частей")
    compareField("anchoredParts", "Заякоренных частей")
    compareField("freeParts", "Свободных частей")
    compareField("motor6ds", "Motor6D соединений")
    compareField("hasAnimator", "Есть Animator")
    compareField("activeAnimations", "Активных анимаций")
    
    -- Рекомендации
    print("\n💡 === РЕКОМЕНДАЦИИ ===")
    print("-" .. string.rep("-", 30))
    
    if copyStats.anchoredParts > 1 then
        print("⚠️ У копии слишком много заякоренных частей (" .. copyStats.anchoredParts .. ")")
        print("   Рекомендация: Только 1 часть должна быть заякорена")
    end
    
    if copyStats.freeParts == 0 then
        print("❌ У копии нет свободных частей для анимации!")
        print("   Рекомендация: Все части кроме основной должны быть Anchored=false")
    end
    
    if copyStats.motor6ds == 0 then
        print("❌ У копии нет Motor6D соединений!")
        print("   Рекомендация: Motor6D должны копироваться вместе с моделью")
    end
    
    if not copyStats.hasAnimator then
        print("❌ У копии нет Animator!")
        print("   Рекомендация: Animator должен копироваться вместе с моделью")
    end
    
    if copyStats.activeAnimations == 0 and originalStats.activeAnimations > 0 then
        print("❌ У копии нет активных анимаций!")
        print("   Рекомендация: Анимации должны автоматически запускаться в копии")
    end
    
    print("\n🎯 === ЗАКЛЮЧЕНИЕ ===")
    if copyStats.freeParts > 0 and copyStats.motor6ds > 0 and copyStats.hasAnimator then
        print("✅ Основные компоненты для анимации присутствуют")
        if copyStats.activeAnimations == 0 then
            print("⚠️ Но анимации не запущены - возможно нужно запустить их вручную")
        else
            print("✅ Анимации активны!")
        end
    else
        print("❌ Отсутствуют критические компоненты для анимации")
    end
end

-- Запуск диагностики
main()
print("=" .. string.rep("=", 50))
