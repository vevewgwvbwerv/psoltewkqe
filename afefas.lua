-- 🔬 ГЛУБОКИЙ АНАЛИЗ СТРУКТУРЫ ПИТОМЦА
-- Максимально детальное сканирование всех компонентов питомца

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === ГЛУБОКИЙ АНАЛИЗ СТРУКТУРЫ ПИТОМЦА ===")
print("=" .. string.rep("=", 70))

-- Получаем позицию игрока
local playerChar = player.Character
if not playerChar then
    print("❌ Персонаж игрока не найден!")
    return
end

local hrp = playerChar:FindFirstChild("HumanoidRootPart")
if not hrp then
    print("❌ HumanoidRootPart не найден!")
    return
end

local playerPos = hrp.Position
local SEARCH_RADIUS = 50

print("📍 Позиция игрока:", playerPos)
print("🎯 Радиус поиска:", SEARCH_RADIUS)
print()

-- Функция для детального анализа объекта
local function analyzeObject(obj, depth)
    local indent = string.rep("  ", depth)
    local info = {
        name = obj.Name,
        className = obj.ClassName,
        parent = obj.Parent and obj.Parent.Name or "NIL"
    }
    
    print(indent .. "📦 " .. info.className .. ": " .. info.name .. " (Parent: " .. info.parent .. ")")
    
    -- Анализ BasePart
    if obj:IsA("BasePart") then
        print(indent .. "  📏 Size: " .. tostring(obj.Size))
        print(indent .. "  📍 Position: " .. tostring(obj.Position))
        print(indent .. "  🔄 CFrame: " .. tostring(obj.CFrame))
        print(indent .. "  👻 Transparency: " .. obj.Transparency)
        print(indent .. "  🎨 Material: " .. tostring(obj.Material))
        print(indent .. "  🌈 Color: " .. tostring(obj.Color))
        print(indent .. "  ⚓ Anchored: " .. tostring(obj.Anchored))
        print(indent .. "  🏷️ CanCollide: " .. tostring(obj.CanCollide))
        if obj.Shape then
            print(indent .. "  🔺 Shape: " .. tostring(obj.Shape))
        end
    end
    
    -- Анализ Model
    if obj:IsA("Model") then
        print(indent .. "  🎯 PrimaryPart: " .. (obj.PrimaryPart and obj.PrimaryPart.Name or "NIL"))
        local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
        if success then
            print(indent .. "  📍 ModelCFrame: " .. tostring(modelCFrame))
        end
        local success2, modelSize = pcall(function() return obj:GetExtentsSize() end)
        if success2 then
            print(indent .. "  📏 ModelSize: " .. tostring(modelSize))
        end
    end
    
    -- Анализ Motor6D
    if obj:IsA("Motor6D") then
        print(indent .. "  🔗 Part0: " .. (obj.Part0 and obj.Part0.Name or "NIL"))
        print(indent .. "  🔗 Part1: " .. (obj.Part1 and obj.Part1.Name or "NIL"))
        print(indent .. "  📐 C0: " .. tostring(obj.C0))
        print(indent .. "  📐 C1: " .. tostring(obj.C1))
        print(indent .. "  🎯 CurrentAngle: " .. obj.CurrentAngle)
        print(indent .. "  🎯 DesiredAngle: " .. obj.DesiredAngle)
        print(indent .. "  ⚡ MaxVelocity: " .. obj.MaxVelocity)
    end
    
    -- Анализ Weld
    if obj:IsA("Weld") or obj:IsA("WeldConstraint") then
        print(indent .. "  🔗 Part0: " .. (obj.Part0 and obj.Part0.Name or "NIL"))
        print(indent .. "  🔗 Part1: " .. (obj.Part1 and obj.Part1.Name or "NIL"))
        if obj:IsA("Weld") then
            print(indent .. "  📐 C0: " .. tostring(obj.C0))
            print(indent .. "  📐 C1: " .. tostring(obj.C1))
        end
    end
    
    -- Анализ Attachment
    if obj:IsA("Attachment") then
        print(indent .. "  📍 Position: " .. tostring(obj.Position))
        print(indent .. "  🔄 Orientation: " .. tostring(obj.Orientation))
        print(indent .. "  📐 CFrame: " .. tostring(obj.CFrame))
        print(indent .. "  👁️ Visible: " .. tostring(obj.Visible))
    end
    
    -- Анализ Humanoid
    if obj:IsA("Humanoid") then
        print(indent .. "  ❤️ Health: " .. obj.Health .. "/" .. obj.MaxHealth)
        print(indent .. "  🏃 WalkSpeed: " .. obj.WalkSpeed)
        print(indent .. "  🦘 JumpPower: " .. obj.JumpPower)
        print(indent .. "  🎭 DisplayDistanceType: " .. tostring(obj.DisplayDistanceType))
        print(indent .. "  📊 RigType: " .. tostring(obj.RigType))
        
        -- Анализ активных анимаций
        local animator = obj:FindFirstChild("Animator")
        if animator then
            print(indent .. "  🎬 Animator найден!")
            local animTracks = animator:GetPlayingAnimationTracks()
            print(indent .. "  🎭 Активных анимаций: " .. #animTracks)
            for i, track in ipairs(animTracks) do
                print(indent .. "    🎞️ Анимация #" .. i .. ":")
                print(indent .. "      📝 Name: " .. (track.Name or "Unnamed"))
                print(indent .. "      🆔 AnimationId: " .. (track.Animation and track.Animation.AnimationId or "NIL"))
                print(indent .. "      ⏱️ Length: " .. track.Length)
                print(indent .. "      ⏯️ IsPlaying: " .. tostring(track.IsPlaying))
                print(indent .. "      🔁 Looped: " .. tostring(track.Looped))
                print(indent .. "      📊 Priority: " .. tostring(track.Priority))
                print(indent .. "      🔊 Weight: " .. track.WeightCurrent)
                print(indent .. "      ⏰ TimePosition: " .. track.TimePosition)
                print(indent .. "      🏃 Speed: " .. track.Speed)
            end
        end
    end
    
    -- Анализ AnimationController
    if obj:IsA("AnimationController") then
        print(indent .. "  🎮 AnimationController найден!")
        local animator = obj:FindFirstChild("Animator")
        if animator then
            print(indent .. "  🎬 Animator найден!")
            local animTracks = animator:GetPlayingAnimationTracks()
            print(indent .. "  🎭 Активных анимаций: " .. #animTracks)
            for i, track in ipairs(animTracks) do
                print(indent .. "    🎞️ Анимация #" .. i .. ":")
                print(indent .. "      📝 Name: " .. (track.Name or "Unnamed"))
                print(indent .. "      🆔 AnimationId: " .. (track.Animation and track.Animation.AnimationId or "NIL"))
                print(indent .. "      ⏱️ Length: " .. track.Length)
                print(indent .. "      ⏯️ IsPlaying: " .. tostring(track.IsPlaying))
                print(indent .. "      🔁 Looped: " .. tostring(track.Looped))
                print(indent .. "      📊 Priority: " .. tostring(track.Priority))
                print(indent .. "      🔊 Weight: " .. track.WeightCurrent)
                print(indent .. "      ⏰ TimePosition: " .. track.TimePosition)
                print(indent .. "      🏃 Speed: " .. track.Speed)
            end
        end
    end
    
    -- Анализ Animation объектов
    if obj:IsA("Animation") then
        print(indent .. "  🎞️ AnimationId: " .. obj.AnimationId)
    end
    
    -- Анализ скриптов
    if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        print(indent .. "  📜 Скрипт: " .. obj.ClassName)
        print(indent .. "  ✅ Enabled: " .. tostring(obj.Enabled or "N/A"))
    end
    
    -- Анализ SpecialMesh
    if obj:IsA("SpecialMesh") then
        print(indent .. "  🎭 MeshType: " .. tostring(obj.MeshType))
        print(indent .. "  📏 Scale: " .. tostring(obj.Scale))
        print(indent .. "  📍 Offset: " .. tostring(obj.Offset))
        if obj.MeshId ~= "" then
            print(indent .. "  🆔 MeshId: " .. obj.MeshId)
        end
        if obj.TextureId ~= "" then
            print(indent .. "  🖼️ TextureId: " .. obj.TextureId)
        end
    end
    
    -- Анализ других важных свойств
    if obj:IsA("GuiObject") then
        print(indent .. "  👁️ Visible: " .. tostring(obj.Visible))
    end
    
    return info
end

-- Функция для рекурсивного анализа всех детей
local function analyzeChildren(obj, depth, maxDepth)
    if depth > maxDepth then
        return
    end
    
    analyzeObject(obj, depth)
    
    local children = obj:GetChildren()
    if #children > 0 then
        for _, child in ipairs(children) do
            analyzeChildren(child, depth + 1, maxDepth)
        end
    end
end

-- Поиск питомцев с UUID именами
print("🔍 ПОИСК ПИТОМЦЕВ С UUID ИМЕНАМИ...")
print("-" .. string.rep("-", 50))

local foundPets = {}

for _, obj in ipairs(Workspace:GetChildren()) do
    if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
        local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
        if success then
            local distance = (modelCFrame.Position - playerPos).Magnitude
            if distance <= SEARCH_RADIUS then
                table.insert(foundPets, {
                    model = obj,
                    distance = distance
                })
            end
        end
    end
end

print("📊 Найдено питомцев рядом: " .. #foundPets)
print()

if #foundPets == 0 then
    print("❌ Питомцы не найдены в радиусе " .. SEARCH_RADIUS .. " единиц!")
    print("💡 Подойдите ближе к питомцу и запустите скрипт снова")
    return
end

-- Анализируем первого найденного питомца
local targetPet = foundPets[1].model
print("🎯 АНАЛИЗИРУЕМ ПИТОМЦА: " .. targetPet.Name)
print("📍 Расстояние: " .. math.floor(foundPets[1].distance) .. " единиц")
print("=" .. string.rep("=", 70))
print()

-- ГЛУБОКИЙ АНАЛИЗ СТРУКТУРЫ
print("🔬 ПОЛНАЯ СТРУКТУРА ПИТОМЦА:")
print("-" .. string.rep("-", 50))

analyzeChildren(targetPet, 0, 10) -- Максимум 10 уровней вглубь

print()
print("📊 ДОПОЛНИТЕЛЬНАЯ СТАТИСТИКА:")
print("-" .. string.rep("-", 30))

-- Подсчет различных типов объектов
local stats = {}
for _, obj in ipairs(targetPet:GetDescendants()) do
    local className = obj.ClassName
    stats[className] = (stats[className] or 0) + 1
end

for className, count in pairs(stats) do
    print("  " .. className .. ": " .. count)
end

print()
print("🎯 АНАЛИЗ ЗАВЕРШЕН")
print("=" .. string.rep("=", 70))
