-- 🔍 ANIMATION STATE ANALYZER - Анализ анимаций в разных состояниях питомца
-- Показывает какие анимации активны когда питомец стоит vs когда копает

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("🔍 === ANIMATION STATE ANALYZER ===")
print("=" .. string.rep("=", 50))

-- Функция поиска питомца (только оригинал)
local function findOriginalPet()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") and not obj.Name:find("_SCALED_COPY") then
            return obj
        end
    end
    return nil
end

-- Функция получения снимка анимаций
local function getAnimationSnapshot(model, stateName)
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
    
    local snapshot = {
        state = stateName,
        timestamp = tick(),
        animations = {}
    }
    
    local activeTracks = animator:GetPlayingAnimationTracks()
    
    for i, track in ipairs(activeTracks) do
        if track.Animation then
            local animInfo = {
                id = track.Animation.AnimationId,
                name = track.Name or "Unknown_" .. i,
                isPlaying = track.IsPlaying,
                speed = track.Speed,
                weight = track.WeightCurrent,
                looped = track.Looped,
                priority = track.Priority.Name,
                timePosition = track.TimePosition,
                length = track.Length
            }
            
            table.insert(snapshot.animations, animInfo)
        end
    end
    
    return snapshot
end

-- Функция вывода снимка
local function printSnapshot(snapshot)
    print("📸 СНИМОК АНИМАЦИЙ: " .. snapshot.state)
    print("⏰ Время: " .. string.format("%.2f", snapshot.timestamp))
    print("🎬 Активных анимаций: " .. #snapshot.animations)
    print()
    
    if #snapshot.animations == 0 then
        print("  ❌ Нет активных анимаций!")
    else
        for i, anim in ipairs(snapshot.animations) do
            print("  [" .. i .. "] " .. anim.name)
            print("    🆔 ID: " .. anim.id)
            print("    ▶️ Playing: " .. tostring(anim.isPlaying))
            print("    ⚡ Speed: " .. anim.speed)
            print("    ⚖️ Weight: " .. string.format("%.2f", anim.weight))
            print("    🔄 Looped: " .. tostring(anim.looped))
            print("    🎯 Priority: " .. anim.priority)
            print("    ⏱️ Position: " .. string.format("%.2f", anim.timePosition) .. "/" .. string.format("%.2f", anim.length))
            print()
        end
    end
    
    print("-" .. string.rep("-", 40))
end

-- Функция сравнения снимков
local function compareSnapshots(snapshot1, snapshot2)
    print("🔄 СРАВНЕНИЕ АНИМАЦИЙ:")
    print("📊 " .. snapshot1.state .. " vs " .. snapshot2.state)
    print()
    
    -- Сравниваем количество
    print("📈 Количество анимаций:")
    print("  " .. snapshot1.state .. ": " .. #snapshot1.animations)
    print("  " .. snapshot2.state .. ": " .. #snapshot2.animations)
    print()
    
    -- Ищем различия
    local differences = {}
    
    -- Анимации только в первом снимке
    for _, anim1 in ipairs(snapshot1.animations) do
        local found = false
        for _, anim2 in ipairs(snapshot2.animations) do
            if anim1.id == anim2.id then
                found = true
                break
            end
        end
        if not found then
            table.insert(differences, {
                type = "only_in_" .. snapshot1.state,
                animation = anim1
            })
        end
    end
    
    -- Анимации только во втором снимке
    for _, anim2 in ipairs(snapshot2.animations) do
        local found = false
        for _, anim1 in ipairs(snapshot1.animations) do
            if anim1.id == anim2.id then
                found = true
                break
            end
        end
        if not found then
            table.insert(differences, {
                type = "only_in_" .. snapshot2.state,
                animation = anim2
            })
        end
    end
    
    -- Общие анимации с разными параметрами
    for _, anim1 in ipairs(snapshot1.animations) do
        for _, anim2 in ipairs(snapshot2.animations) do
            if anim1.id == anim2.id then
                local paramDiffs = {}
                if anim1.speed ~= anim2.speed then
                    table.insert(paramDiffs, "speed: " .. anim1.speed .. " → " .. anim2.speed)
                end
                if math.abs(anim1.weight - anim2.weight) > 0.01 then
                    table.insert(paramDiffs, "weight: " .. string.format("%.2f", anim1.weight) .. " → " .. string.format("%.2f", anim2.weight))
                end
                if anim1.isPlaying ~= anim2.isPlaying then
                    table.insert(paramDiffs, "playing: " .. tostring(anim1.isPlaying) .. " → " .. tostring(anim2.isPlaying))
                end
                
                if #paramDiffs > 0 then
                    table.insert(differences, {
                        type = "parameter_change",
                        animation = anim1,
                        changes = paramDiffs
                    })
                end
                break
            end
        end
    end
    
    -- Выводим различия
    if #differences == 0 then
        print("✅ Анимации идентичны!")
    else
        print("🔍 Найдено различий: " .. #differences)
        print()
        
        for i, diff in ipairs(differences) do
            if diff.type:find("only_in_") then
                print("  [" .. i .. "] 🆕 Только в " .. diff.type:gsub("only_in_", "") .. ":")
                print("    " .. diff.animation.name .. " (" .. diff.animation.id .. ")")
            elseif diff.type == "parameter_change" then
                print("  [" .. i .. "] 🔄 Изменения в " .. diff.animation.name .. ":")
                for _, change in ipairs(diff.changes) do
                    print("    " .. change)
                end
            end
            print()
        end
    end
    
    print("=" .. string.rep("=", 50))
end

-- Основная функция
local function main()
    local pet = findOriginalPet()
    
    if not pet then
        print("❌ Питомец не найден!")
        return
    end
    
    print("🎯 Найден питомец:", pet.Name)
    print()
    print("📋 ИНСТРУКЦИИ:")
    print("1. Сейчас будет сделан снимок текущего состояния")
    print("2. Затем измени состояние питомца (заставь копать или стоять)")
    print("3. Через 5 секунд будет второй снимок")
    print("4. Скрипт покажет различия между состояниями")
    print()
    print("⏳ Делаю первый снимок через 3 секунды...")
    
    wait(3)
    
    -- Первый снимок
    local snapshot1 = getAnimationSnapshot(pet, "СОСТОЯНИЕ_1")
    printSnapshot(snapshot1)
    
    print("🔄 ТЕПЕРЬ ИЗМЕНИ СОСТОЯНИЕ ПИТОМЦА!")
    print("   (заставь копать или стоять)")
    print("⏳ Жду 5 секунд...")
    
    wait(5)
    
    -- Второй снимок
    local snapshot2 = getAnimationSnapshot(pet, "СОСТОЯНИЕ_2")
    printSnapshot(snapshot2)
    
    -- Сравнение
    compareSnapshots(snapshot1, snapshot2)
    
    print("🎉 Анализ завершен!")
    print("💡 Теперь ты знаешь какие анимации нужно копировать для правильного состояния!")
end

-- Запуск
main()
