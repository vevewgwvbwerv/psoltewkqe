-- 🔍 SIMPLE IDLE ANALYZER - Простой анализ стоячей модели питомца
-- Только анализ, никаких изменений

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

print("🔍 === SIMPLE IDLE ANALYZER ===")
print("=" .. string.rep("=", 40))

-- Функция поиска оригинального питомца (без копии)
local function findOriginalPet()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") and not obj.Name:find("_SCALED_COPY") then
            return obj
        end
    end
    return nil
end

-- Функция анализа структуры модели
local function analyzeModelStructure(model)
    print("📊 СТРУКТУРА МОДЕЛИ: " .. model.Name)
    print()
    
    -- Основная информация
    print("🎯 Основная информация:")
    print("  Имя: " .. model.Name)
    print("  Класс: " .. model.ClassName)
    print("  Родитель: " .. (model.Parent and model.Parent.Name or "nil"))
    if model.PrimaryPart then
        print("  PrimaryPart: " .. model.PrimaryPart.Name)
    else
        print("  PrimaryPart: не установлен")
    end
    print()
    
    -- Все дети модели
    local children = model:GetChildren()
    print("👶 Дети модели (" .. #children .. "):")
    for i, child in ipairs(children) do
        print("  [" .. i .. "] " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    print()
    
    -- Все BasePart
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    print("🧩 BasePart компоненты (" .. #parts .. "):")
    for i, part in ipairs(parts) do
        print("  [" .. i .. "] " .. part.Name .. " (" .. part.ClassName .. ")")
        print("    Size: " .. tostring(part.Size))
        print("    Position: " .. tostring(part.Position))
        print("    Anchored: " .. tostring(part.Anchored))
        print("    CanCollide: " .. tostring(part.CanCollide))
        print("    Transparency: " .. part.Transparency)
        print()
    end
    
    return parts
end

-- Функция анализа Motor6D соединений
local function analyzeMotor6D(model)
    print("⚙️ MOTOR6D СОЕДИНЕНИЯ:")
    
    local motors = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    
    print("  Найдено Motor6D: " .. #motors)
    print()
    
    if #motors == 0 then
        print("  ❌ Motor6D не найдены!")
        return {}
    end
    
    for i, motor in ipairs(motors) do
        print("  [" .. i .. "] " .. motor.Name)
        print("    Part0: " .. (motor.Part0 and motor.Part0.Name or "nil"))
        print("    Part1: " .. (motor.Part1 and motor.Part1.Name or "nil"))
        print("    Transform: " .. tostring(motor.Transform))
        print("    C0: " .. tostring(motor.C0))
        print("    C1: " .. tostring(motor.C1))
        print()
    end
    
    return motors
end

-- Функция анализа анимационных компонентов
local function analyzeAnimationComponents(model)
    print("🎬 АНИМАЦИОННЫЕ КОМПОНЕНТЫ:")
    
    local animationController = nil
    local animator = nil
    local humanoid = nil
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("AnimationController") then
            animationController = obj
        elseif obj:IsA("Animator") then
            animator = obj
        elseif obj:IsA("Humanoid") then
            humanoid = obj
        end
    end
    
    -- AnimationController
    if animationController then
        print("  ✅ AnimationController найден: " .. animationController.Name)
        print("    Родитель: " .. (animationController.Parent and animationController.Parent.Name or "nil"))
    else
        print("  ❌ AnimationController не найден")
    end
    
    -- Animator
    if animator then
        print("  ✅ Animator найден: " .. animator.Name)
        print("    Родитель: " .. (animator.Parent and animator.Parent.Name or "nil"))
        
        -- Активные анимации
        local activeTracks = animator:GetPlayingAnimationTracks()
        print("    Активных анимаций: " .. #activeTracks)
        
        for i, track in ipairs(activeTracks) do
            if track.Animation then
                print("      [" .. i .. "] " .. (track.Name or "Unknown"))
                print("        ID: " .. track.Animation.AnimationId)
                print("        Playing: " .. tostring(track.IsPlaying))
                print("        Speed: " .. track.Speed)
                print("        Weight: " .. track.WeightCurrent)
                print("        Looped: " .. tostring(track.Looped))
                print("        Priority: " .. track.Priority.Name)
            end
        end
    else
        print("  ❌ Animator не найден")
    end
    
    -- Humanoid
    if humanoid then
        print("  ✅ Humanoid найден: " .. humanoid.Name)
        print("    Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
        print("    WalkSpeed: " .. humanoid.WalkSpeed)
        print("    JumpPower: " .. humanoid.JumpPower)
    else
        print("  ❌ Humanoid не найден")
    end
    
    print()
    
    return {
        animationController = animationController,
        animator = animator,
        humanoid = humanoid
    }
end

-- Функция анализа других компонентов
local function analyzeOtherComponents(model)
    print("🔧 ДРУГИЕ КОМПОНЕНТЫ:")
    
    local attachments = {}
    local welds = {}
    local scripts = {}
    local other = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Attachment") then
            table.insert(attachments, obj)
        elseif obj:IsA("Weld") or obj:IsA("WeldConstraint") then
            table.insert(welds, obj)
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            table.insert(scripts, obj)
        elseif not obj:IsA("BasePart") and not obj:IsA("Motor6D") and not obj:IsA("AnimationController") and not obj:IsA("Animator") and not obj:IsA("Humanoid") then
            table.insert(other, obj)
        end
    end
    
    print("  📎 Attachments: " .. #attachments)
    for _, att in ipairs(attachments) do
        print("    " .. att.Name .. " (в " .. (att.Parent and att.Parent.Name or "nil") .. ")")
    end
    
    print("  🔗 Welds: " .. #welds)
    for _, weld in ipairs(welds) do
        print("    " .. weld.Name .. " (" .. weld.ClassName .. ")")
    end
    
    print("  📜 Scripts: " .. #scripts)
    for _, script in ipairs(scripts) do
        print("    " .. script.Name .. " (" .. script.ClassName .. ")")
    end
    
    print("  ❓ Другие: " .. #other)
    for _, obj in ipairs(other) do
        print("    " .. obj.Name .. " (" .. obj.ClassName .. ")")
    end
    
    print()
end

-- Основная функция
local function main()
    local pet = findOriginalPet()
    
    if not pet then
        print("❌ Оригинальный питомец не найден!")
        print("💡 Убедись что питомец находится в Workspace")
        return
    end
    
    print("🎯 Найден питомец: " .. pet.Name)
    print("📍 Позиция: " .. tostring(pet:GetModelCFrame().Position))
    print()
    print("⏰ ВАЖНО: Убедись что питомец СТОИТ НА МЕСТЕ для правильного анализа!")
    print()
    
    -- Полный анализ модели
    local parts = analyzeModelStructure(pet)
    local motors = analyzeMotor6D(pet)
    local animComponents = analyzeAnimationComponents(pet)
    analyzeOtherComponents(pet)
    
    -- Итоговая сводка
    print("📋 ИТОГОВАЯ СВОДКА:")
    print("  BasePart: " .. #parts)
    print("  Motor6D: " .. #motors)
    print("  AnimationController: " .. (animComponents.animationController and "✅" or "❌"))
    print("  Animator: " .. (animComponents.animator and "✅" or "❌"))
    print("  Humanoid: " .. (animComponents.humanoid and "✅" or "❌"))
    
    if animComponents.animator then
        local activeTracks = animComponents.animator:GetPlayingAnimationTracks()
        print("  Активных анимаций: " .. #activeTracks)
    end
    
    print()
    print("🎉 Анализ завершен!")
    print("💡 Теперь мы знаем полную структуру стоячего питомца")
    
    print("=" .. string.rep("=", 40))
end

-- Запуск
main()
