--[[
    EXPLOIT PET REPLACER
    Простая визуальная замена питомца из яйца на питомца из руки
    Работает только для клиента (визуально для тебя)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isEnabled = true

-- GUI для управления
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExploitPetReplacer"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔥 EXPLOIT PET REPLACER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0, 40)
toggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
toggleButton.Text = "✅ ENABLED"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.Gotham
toggleButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 90)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

local replacementCount = Instance.new("TextLabel")
replacementCount.Size = UDim2.new(1, 0, 0, 30)
replacementCount.Position = UDim2.new(0, 0, 0, 120)
replacementCount.BackgroundTransparency = 1
replacementCount.Text = "Replacements: 0"
replacementCount.TextColor3 = Color3.new(1, 1, 1)
replacementCount.TextScaled = true
replacementCount.Font = Enum.Font.Gotham
replacementCount.Parent = frame

local replaceCount = 0

-- Функция переключения
toggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        toggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
        toggleButton.Text = "✅ ENABLED"
        statusLabel.Text = "Status: Ready"
    else
        toggleButton.BackgroundColor3 = Color3.new(1, 0, 0)
        toggleButton.Text = "❌ DISABLED"
        statusLabel.Text = "Status: Disabled"
    end
end)

-- Функция получения питомца из руки
local function getHandPetModel()
    if not player.Character then return nil end
    
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local model = tool:FindFirstChildWhichIsA("Model")
            if model then
                local clone = model:Clone()
                -- Убираем скрипты из клона
                for _, script in ipairs(clone:GetDescendants()) do
                    if script:IsA("BaseScript") or script:IsA("LocalScript") then
                        script:Destroy()
                    end
                end
                return clone
            end
        end
    end
    return nil
end

-- Функция создания эффекта роста
local function createGrowthEffect(model, targetPosition)
    if not model or not model.PrimaryPart then return end
    
    -- Устанавливаем позицию
    model:SetPrimaryPartCFrame(targetPosition)
    
    -- Сохраняем оригинальные размеры
    local originalSizes = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            originalSizes[part] = part.Size
            part.Size = part.Size * 0.1 -- Начинаем с маленького размера
            part.Transparency = 0.8
        end
    end
    
    -- Анимация роста
    local growthTime = 1.5
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / growthTime, 1)
        
        -- Плавное увеличение размера и уменьшение прозрачности
        local scale = 0.1 + (0.9 * progress)
        local transparency = 0.8 - (0.8 * progress)
        
        for part, originalSize in pairs(originalSizes) do
            if part.Parent then
                part.Size = originalSize * scale
                part.Transparency = transparency
            end
        end
        
        if progress >= 1 then
            connection:Disconnect()
            
            -- Держим питомца видимым 3 секунды, затем удаляем
            wait(3)
            if model and model.Parent then
                -- Анимация исчезновения
                local fadeTime = 0.5
                local fadeStart = tick()
                
                local fadeConnection
                fadeConnection = RunService.Heartbeat:Connect(function()
                    local fadeElapsed = tick() - fadeStart
                    local fadeProgress = math.min(fadeElapsed / fadeTime, 1)
                    
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = fadeProgress
                        end
                    end
                    
                    if fadeProgress >= 1 then
                        fadeConnection:Disconnect()
                        model:Destroy()
                    end
                end)
            end
        end
    end)
end

-- Основная функция замены
local function replacePet(eggPetModel)
    if not isEnabled then return end
    
    statusLabel.Text = "Status: Replacing..."
    
    -- Получаем питомца из руки
    local handPet = getHandPetModel()
    if not handPet then
        statusLabel.Text = "Status: No pet in hand!"
        return
    end
    
    -- Получаем позицию яичного питомца
    local targetPosition = eggPetModel:GetModelCFrame()
    
    -- Скрываем оригинального питомца из яйца
    for _, part in ipairs(eggPetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
    
    -- Добавляем нашего питомца в мир
    handPet.Parent = Workspace
    
    -- Создаем эффект роста
    createGrowthEffect(handPet, targetPosition)
    
    -- Обновляем счетчик
    replaceCount = replaceCount + 1
    replacementCount.Text = "Replacements: " .. replaceCount
    statusLabel.Text = "Status: Replaced!"
    
    -- Через 2 секунды возвращаем статус в Ready
    wait(2)
    if isEnabled then
        statusLabel.Text = "Status: Ready"
    end
end

-- Отслеживаем появление новых моделей в Workspace.Visuals
if Workspace:FindFirstChild("Visuals") then
    Workspace.Visuals.ChildAdded:Connect(function(child)
        if child:IsA("Model") and isEnabled then
            -- Небольшая задержка, чтобы модель полностью загрузилась
            wait(0.1)
            replacePet(child)
        end
    end)
else
    statusLabel.Text = "Status: Visuals folder not found!"
end

print("🔥 Exploit Pet Replacer loaded! Toggle with GUI.")
