-- 🎭 PET ANIMATION ANALYZER - Анализ анимации питомца
-- Анализирует структуру анимации оригинального питомца для восстановления на копии

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerChar = player.Character
local hrp = playerChar:FindFirstChild("HumanoidRootPart")
local playerPos = hrp.Position

print("🎭 === PET ANIMATION ANALYZER ===")
print("=" .. string.rep("=", 50))

-- Функция поиска UUID питомца
local function findUUIDPet()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= 100 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Функция анализа анимационных компонентов
local function analyzeAnimationComponents(model)
    print("🔍 Анализ анимационных компонентов модели:", model.Name)
    print("-" .. string.rep("-", 40))
    
    local animationData = {
        humanoid = nil,
        animationController = nil,
        animator = nil,
        activeAnimations = {},
        motor6Ds = {},
        attachments = {},
        parts = {}
    }
    
    -- Поиск Humanoid и AnimationController
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Humanoid") then
            animationData.humanoid = obj
            print("✅ Найден Humanoid:", obj:GetFullName())
            print("  PlatformStand:", obj.PlatformStand)
            print("  Sit:", obj.Sit)
            print("  Health:", obj.Health)
            
        elseif obj:IsA("AnimationController") then
            animationData.animationController = obj
            print("✅ Найден AnimationController:", obj:GetFullName())
            
        elseif obj:IsA("Animator") then
            animationData.animator = obj
            print("✅ Найден Animator:", obj:GetFullName())
            
            -- Анализ активных анимаций
            local animTracks = obj:GetPlayingAnimationTracks()
            print("🎬 Активных анимаций:", #animTracks)
            
            for i, track in ipairs(animTracks) do
                local animInfo = {
                    name = track.Name,
                    animationId = track.Animation and track.Animation.AnimationId or "N/A",
                    isPlaying = track.IsPlaying,
                    looped = track.Looped,
                    priority = track.Priority.Name,
                    speed = track.Speed,
                    timePosition = track.TimePosition,
                    length = track.Length,
                    weight = track.WeightCurrent
                }
                
                table.insert(animationData.activeAnimations, animInfo)
                
                print("  [" .. i .. "] " .. animInfo.name)
                print("    ID:", animInfo.animationId)
                print("    Playing:", animInfo.isPlaying)
                print("    Looped:", animInfo.looped)
                print("    Priority:", animInfo.priority)
                print("    Speed:", animInfo.speed)
                print("    Weight:", animInfo.weight)
                print()
            end
            
        elseif obj:IsA("Motor6D") then
            local motorInfo = {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "nil",
                part1 = obj.Part1 and obj.Part1.Name or "nil",
                c0 = obj.C0,
                c1 = obj.C1,
                currentAngle = obj.CurrentAngle,
                desiredAngle = obj.DesiredAngle
            }
            
            table.insert(animationData.motor6Ds, motorInfo)
            
        elseif obj:IsA("Attachment") then
            local attachInfo = {
                name = obj.Name,
                parent = obj.Parent.Name,
                cframe = obj.CFrame,
                worldCFrame = obj.WorldCFrame
            }
            
            table.insert(animationData.attachments, attachInfo)
            
        elseif obj:IsA("BasePart") then
            local partInfo = {
                name = obj.Name,
                className = obj.ClassName,
                anchored = obj.Anchored,
                canCollide = obj.CanCollide,
                cframe = obj.CFrame,
                size = obj.Size
            }
            
            table.insert(animationData.parts, partInfo)
        end
    end
    
    print("📊 СВОДКА АНИМАЦИОННЫХ КОМПОНЕНТОВ:")
    print("  Humanoid:", animationData.humanoid and "✅" or "❌")
    print("  AnimationController:", animationData.animationController and "✅" or "❌")
    print("  Animator:", animationData.animator and "✅" or "❌")
    print("  Активных анимаций:", #animationData.activeAnimations)
    print("  Motor6D соединений:", #animationData.motor6Ds)
    print("  Attachments:", #animationData.attachments)
    print("  BaseParts:", #animationData.parts)
    print()
    
    return animationData
end

-- Функция детального анализа Motor6D
local function analyzeMotor6Ds(animationData)
    if #animationData.motor6Ds == 0 then
        print("❌ Motor6D соединения не найдены!")
        return
    end
    
    print("🔧 ДЕТАЛЬНЫЙ АНАЛИЗ MOTOR6D:")
    print("-" .. string.rep("-", 40))
    
    for i, motor in ipairs(animationData.motor6Ds) do
        print("[" .. i .. "] " .. motor.name)
        print("  Part0:", motor.part0)
        print("  Part1:", motor.part1)
        print("  C0:", motor.c0)
        print("  C1:", motor.c1)
        print("  CurrentAngle:", motor.currentAngle)
        print("  DesiredAngle:", motor.desiredAngle)
        print()
    end
end

-- Функция анализа структуры модели
local function analyzeModelStructure(model)
    print("🏗️ СТРУКТУРА МОДЕЛИ:")
    print("-" .. string.rep("-", 40))
    
    local function printHierarchy(obj, indent)
        local indentStr = string.rep("  ", indent)
        local info = obj.Name .. " (" .. obj.ClassName .. ")"
        
        if obj:IsA("BasePart") then
            info = info .. " [Anchored: " .. tostring(obj.Anchored) .. "]"
        elseif obj:IsA("Motor6D") then
            info = info .. " [" .. (obj.Part0 and obj.Part0.Name or "nil") .. " -> " .. (obj.Part1 and obj.Part1.Name or "nil") .. "]"
        end
        
        print(indentStr .. info)
        
        for _, child in pairs(obj:GetChildren()) do
            printHierarchy(child, indent + 1)
        end
    end
    
    printHierarchy(model, 0)
    print()
end

-- Основная функция
local function main()
    local pet = findUUIDPet()
    if not pet then
        print("❌ UUID питомец не найден!")
        return
    end
    
    print("🎯 Найден питомец:", pet.Name)
    print("📍 Позиция:", pet:GetModelCFrame().Position)
    print()
    
    -- Анализируем структуру модели
    analyzeModelStructure(pet)
    
    -- Анализируем анимационные компоненты
    local animData = analyzeAnimationComponents(pet)
    
    -- Детальный анализ Motor6D
    analyzeMotor6Ds(animData)
    
    print("🎭 АНАЛИЗ ЗАВЕРШЕН!")
    print("=" .. string.rep("=", 50))
end

-- Запуск анализа
main()
