-- 🔍 COPY DIAGNOSTICS - Диагностика проблем с копией питомца
-- Анализирует что происходит с копией после создания и попытки восстановления анимации

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🔍 === COPY DIAGNOSTICS ===")
print("=" .. string.rep("=", 40))

-- ИСПРАВЛЕНО: Правильный поиск оригинала и копии
local function findModels()
    local original = nil
    local copy = nil
    local copyUUID = nil
    
    -- Сначала ищем копию чтобы получить UUID
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") and obj.Name:find("_SCALED_COPY") then
            copy = obj
            -- Извлекаем UUID из имени копии
            copyUUID = obj.Name:gsub("_SCALED_COPY", "")
            print("🔍 Найдена копия:", obj.Name)
            print("🎯 Ищу оригинал с UUID:", copyUUID)
            break
        end
    end
    
    if not copy then
        print("⚠️ Копия не найдена, ищу любой UUID питомец...")
        -- Если копии нет, берем первого найденного
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
                original = obj
                break
            end
        end
        return original, copy
    end
    
    -- Теперь ищем оригинал с таким же UUID
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == copyUUID then
            original = obj
            print("✅ Найден оригинал:", obj.Name)
            break
        end
    end
    
    if not original then
        print("❌ Оригинал с UUID", copyUUID, "не найден!")
    end
    
    return original, copy
end

-- Функция диагностики модели
local function diagnoseModel(model, modelType)
    print("🔍 ДИАГНОСТИКА " .. modelType .. ":", model.Name)
    print("-" .. string.rep("-", 30))
    
    local parts = {}
    local motor6Ds = {}
    local animations = {}
    
    -- Собираем информацию о частях
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, {
                name = obj.Name,
                anchored = obj.Anchored,
                position = obj.Position,
                size = obj.Size,
                parent = obj.Parent.Name,
                visible = obj.Transparency < 1
            })
        elseif obj:IsA("Motor6D") then
            table.insert(motor6Ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "NIL",
                part1 = obj.Part1 and obj.Part1.Name or "NIL",
                currentAngle = obj.CurrentAngle,
                enabled = obj.Enabled
            })
        elseif obj:IsA("Animator") then
            local tracks = obj:GetPlayingAnimationTracks()
            for _, track in ipairs(tracks) do
                table.insert(animations, {
                    name = track.Name,
                    id = track.Animation and track.Animation.AnimationId or "N/A",
                    playing = track.IsPlaying,
                    speed = track.Speed
                })
            end
        end
    end
    
    -- Выводим статистику
    print("📊 СТАТИСТИКА:")
    print("  BaseParts:", #parts)
    print("  Motor6D:", #motor6Ds)
    print("  Активных анимаций:", #animations)
    print()
    
    -- Анализируем части
    print("🧩 ЧАСТИ:")
    local anchoredCount = 0
    local visibleCount = 0
    for i, part in ipairs(parts) do
        local status = ""
        if part.anchored then 
            status = status .. "[ANCHORED] "
            anchoredCount = anchoredCount + 1
        end
        if not part.visible then 
            status = status .. "[INVISIBLE] "
        else
            visibleCount = visibleCount + 1
        end
        
        print("  [" .. i .. "] " .. part.name .. " " .. status)
        print("    Pos: " .. tostring(part.position))
        print("    Size: " .. tostring(part.size))
    end
    print("  Закреплено:", anchoredCount .. "/" .. #parts)
    print("  Видимых:", visibleCount .. "/" .. #parts)
    print()
    
    -- Анализируем Motor6D
    print("🔧 MOTOR6D СОЕДИНЕНИЯ:")
    local workingMotors = 0
    for i, motor in ipairs(motor6Ds) do
        local status = ""
        if motor.part0 == "NIL" or motor.part1 == "NIL" then
            status = "[BROKEN] "
        else
            workingMotors = workingMotors + 1
            status = "[OK] "
        end
        
        if not motor.enabled then
            status = status .. "[DISABLED] "
        end
        
        print("  [" .. i .. "] " .. motor.name .. " " .. status)
        print("    " .. motor.part0 .. " -> " .. motor.part1)
        print("    Angle: " .. motor.currentAngle)
    end
    print("  Рабочих моторов:", workingMotors .. "/" .. #motor6Ds)
    print()
    
    -- Анализируем анимации
    print("🎬 АНИМАЦИИ:")
    if #animations == 0 then
        print("  ❌ Нет активных анимаций")
    else
        for i, anim in ipairs(animations) do
            print("  [" .. i .. "] " .. anim.name)
            print("    ID: " .. anim.id)
            print("    Playing: " .. tostring(anim.playing))
            print("    Speed: " .. anim.speed)
        end
    end
    print()
    
    return {
        parts = parts,
        motor6Ds = motor6Ds,
        animations = animations,
        stats = {
            totalParts = #parts,
            anchoredParts = anchoredCount,
            visibleParts = visibleCount,
            workingMotors = workingMotors,
            activeAnimations = #animations
        }
    }
end

-- Функция сравнения моделей
local function compareModels(originalData, copyData)
    print("⚖️ СРАВНЕНИЕ ОРИГИНАЛА И КОПИИ:")
    print("-" .. string.rep("-", 30))
    
    print("📊 Статистика:")
    print("  Части - Оригинал:", originalData.stats.totalParts, "| Копия:", copyData.stats.totalParts)
    print("  Видимые части - Оригинал:", originalData.stats.visibleParts, "| Копия:", copyData.stats.visibleParts)
    print("  Закрепленные - Оригинал:", originalData.stats.anchoredParts, "| Копия:", copyData.stats.anchoredParts)
    print("  Рабочие моторы - Оригинал:", originalData.stats.workingMotors, "| Копия:", copyData.stats.workingMotors)
    print("  Анимации - Оригинал:", originalData.stats.activeAnimations, "| Копия:", copyData.stats.activeAnimations)
    print()
    
    -- Ищем пропавшие части
    print("🔍 АНАЛИЗ ПРОПАВШИХ ЧАСТЕЙ:")
    for _, originalPart in ipairs(originalData.parts) do
        local found = false
        for _, copyPart in ipairs(copyData.parts) do
            if copyPart.name == originalPart.name then
                found = true
                if not copyPart.visible and originalPart.visible then
                    print("  ⚠️ Часть стала невидимой:", copyPart.name)
                end
                break
            end
        end
        if not found then
            print("  ❌ Часть пропала:", originalPart.name)
        end
    end
    print()
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
    
    -- Диагностируем оба
    local originalData = diagnoseModel(original, "ОРИГИНАЛ")
    local copyData = diagnoseModel(copy, "КОПИЯ")
    
    -- Сравниваем
    compareModels(originalData, copyData)
    
    print("🔍 ДИАГНОСТИКА ЗАВЕРШЕНА!")
    print("=" .. string.rep("=", 40))
end

-- Запуск
main()
