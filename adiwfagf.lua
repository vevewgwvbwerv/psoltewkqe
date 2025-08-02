--[[
    PET ANIMATION PLAYER
    Воспроизводит точную анимацию роста на питомце из руки
    Основано на записанных данных: рост в 1.88 раз для всех частей
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local isActive = true

print("🎬 Pet Animation Player загружен!")
print("📊 Данные анимации: рост в 1.88 раз, все части синхронно")

-- Функция получения питомца из руки
local function getHandPet()
    if not player.Character then return nil end
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local model = tool:FindFirstChildWhichIsA("Model")
            if model then
                return model
            end
        end
    end
    return nil
end

-- Функция клонирования питомца
local function clonePet(originalModel)
    local clone = originalModel:Clone()
    
    -- Убираем скрипты из клона
    for _, script in pairs(clone:GetDescendants()) do
        if script:IsA("BaseScript") or script:IsA("LocalScript") then
            script:Destroy()
        end
    end
    
    return clone
end

-- Функция воспроизведения анимации роста
local function playGrowthAnimation(model, targetPosition)
    print("🎬 Начинаю анимацию роста для: " .. model.Name)
    
    -- Позиционируем модель
    if model.PrimaryPart then
        model:SetPrimaryPartCFrame(targetPosition)
    else
        model:MoveTo(targetPosition.Position)
    end
    
    model.Parent = Workspace
    
    -- Список всех частей которые должны расти (из записанных данных)
    local growingParts = {
        "LeftEar", "FrontLegL", "RightEar", "LeftLegL", "Torso", 
        "FrontLegR", "Jaw", "BackLegL", "BackLegR", "Tail", 
        "Mouth", "RightEye", "LeftEye", "Head"
    }
    
    -- Сохраняем оригинальные размеры и устанавливаем начальные
    local originalSizes = {}
    local tweens = {}
    
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            originalSizes[part] = part.Size
            
            -- Начинаем с маленького размера (1/1.88 от оригинала)
            local startSize = part.Size / 1.88
            part.Size = startSize
            part.Transparency = 0.8  -- Начинаем полупрозрачными
            part.Anchored = true     -- Фиксируем чтобы не падали
            
            -- Создаем анимацию роста
            local growTween = TweenService:Create(part, 
                TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {
                    Size = originalSizes[part],
                    Transparency = 0
                }
            )
            
            table.insert(tweens, growTween)
        end
    end
    
    -- Запускаем все анимации одновременно
    print("📈 Запускаю рост всех частей в 1.88 раз...")
    for _, tween in pairs(tweens) do
        tween:Play()
    end
    
    -- Через 4 секунды удаляем модель (как в оригинале)
    wait(4)
    
    print("💥 Анимация завершена, удаляю модель")
    
    -- Анимация исчезновения
    local fadeTweens = {}
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local fadeTween = TweenService:Create(part,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                { Transparency = 1 }
            )
            table.insert(fadeTweens, fadeTween)
        end
    end
    
    for _, tween in pairs(fadeTweens) do
        tween:Play()
    end
    
    wait(0.5)
    model:Destroy()
end

-- Функция замены питомца из яйца
local function replacePetWithAnimation(eggPetModel)
    if not isActive then return end
    
    print("🎯 Обнаружен питомец из яйца: " .. eggPetModel.Name)
    
    -- Получаем питомца из руки
    local handPet = getHandPet()
    if not handPet then
        print("❌ Питомец в руке не найден!")
        return
    end
    
    print("✅ Питомец в руке найден: " .. handPet.Name)
    
    -- Получаем позицию яичного питомца
    local targetPosition = eggPetModel:GetModelCFrame()
    
    -- Скрываем оригинального питомца из яйца
    for _, part in pairs(eggPetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
    
    print("🫥 Скрыл оригинального питомца из яйца")
    
    -- Клонируем питомца из руки
    local clonedPet = clonePet(handPet)
    
    -- Запускаем анимацию роста на клоне
    spawn(function()
        playGrowthAnimation(clonedPet, targetPosition)
    end)
    
    print("🚀 Запустил анимацию роста на клоне!")
end

-- Отслеживаем появление питомцев в Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    print("✅ Найдена папка Visuals")
    
    visuals.ChildAdded:Connect(function(child)
        if child:IsA("Model") and isActive then
            local name = child.Name or "Unknown"
            
            -- Проверяем что это питомец (не эффект)
            if not name:find("Egg") and not name:find("Explode") and not name:find("Poof") then
                wait(0.1) -- Небольшая задержка для загрузки модели
                replacePetWithAnimation(child)
            end
        end
    end)
else
    print("❌ Папка Visuals не найдена!")
end

print("🎯 Pet Animation Player готов!")
print("📋 Возьми питомца в руку и открой яйцо")
print("🎬 Твой питомец появится с точной анимацией роста!")
