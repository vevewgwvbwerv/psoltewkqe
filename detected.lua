-- 🔍 АНАЛИЗАТОР ОРИГИНАЛЬНОГО ПИТОМЦА
-- Логирует ТОЧНУЮ ориентацию оригинала для 1:1 копирования

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 📊 КОНФИГУРАЦИЯ
local CONFIG = {
    SEARCH_RADIUS = 100,
    LOG_INTERVAL = 1,  -- Логируем каждую секунду
    MOVEMENT_THRESHOLD = 0.1  -- Минимальное движение для детекции
}

-- 🎯 ТОЧНАЯ ЛОГИКА ПОИСКА ПИТОМЦА (из PetScaler_v3.221.lua)
local function hasPetVisuals(model)
    local hasVisuals = false
    
    for _, child in pairs(model:GetChildren()) do
        if child:IsA("MeshPart") then
            local mesh = child:FindFirstChildOfClass("SpecialMesh")
            if mesh and (mesh.MeshId ~= "" or mesh.TextureId ~= "") then
                hasVisuals = true
                break
            end
        elseif child:IsA("Part") then
            local mesh = child:FindFirstChildOfClass("SpecialMesh")
            if mesh and (mesh.MeshId ~= "" or mesh.TextureId ~= "") then
                hasVisuals = true
                break
            end
        end
    end
    
    return hasVisuals
end

local function findOriginalPet()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPos = character.HumanoidRootPart.Position
    
    -- Ищем модели с UUID-именами (содержат { и })
    for _, model in pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:find("{") and model.Name:find("}") then
            if model.PrimaryPart then
                local distance = (model.PrimaryPart.Position - playerPos).Magnitude
                
                if distance <= CONFIG.SEARCH_RADIUS then
                    if hasPetVisuals(model) then
                        print("🔍 Найден оригинальный питомец:", model.Name)
                        print("📊 Расстояние:", string.format("%.2f", distance), "стадов")
                        return model
                    end
                end
            end
        end
    end
    
    return nil
end

-- 📊 АНАЛИЗАТОР ОРИЕНТАЦИИ
local function analyzePetOrientation(pet, label)
    if not pet or not pet.PrimaryPart then
        return
    end
    
    local rootPart = pet.PrimaryPart
    local pos = rootPart.Position
    local cframe = rootPart.CFrame
    
    print("\n" .. label)
    print("=" .. string.rep("=", string.len(label)))
    print("📊 Позиция:", string.format("%.3f, %.3f, %.3f", pos.X, pos.Y, pos.Z))
    print("📊 UpVector:", string.format("%.3f, %.3f, %.3f", cframe.UpVector.X, cframe.UpVector.Y, cframe.UpVector.Z))
    print("📊 LookVector:", string.format("%.3f, %.3f, %.3f", cframe.LookVector.X, cframe.LookVector.Y, cframe.LookVector.Z))
    print("📊 RightVector:", string.format("%.3f, %.3f, %.3f", cframe.RightVector.X, cframe.RightVector.Y, cframe.RightVector.Z))
    
    -- Углы Эйлера
    local x, y, z = cframe:ToEulerAnglesXYZ()
    print("📊 Углы (XYZ):", string.format("%.3f, %.3f, %.3f", math.deg(x), math.deg(y), math.deg(z)))
    
    -- Проверка вертикальности
    local upDotY = math.abs(cframe.UpVector:Dot(Vector3.new(0, 1, 0)))
    print("📊 Вертикальность:", string.format("%.3f", upDotY), "(1.0 = идеально вертикально)")
    
    -- Полный CFrame для копирования
    print("📊 Полный CFrame:")
    print("   Position:", string.format("Vector3.new(%.3f, %.3f, %.3f)", pos.X, pos.Y, pos.Z))
    print("   CFrame:", string.format("CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f)", 
        cframe.X, cframe.Y, cframe.Z,
        cframe.RightVector.X, cframe.UpVector.X, -cframe.LookVector.X,
        cframe.RightVector.Y, cframe.UpVector.Y, -cframe.LookVector.Y,
        cframe.RightVector.Z, cframe.UpVector.Z, -cframe.LookVector.Z))
end

-- 🎯 ГЛАВНАЯ ЛОГИКА
local function startAnalysis()
    print("🔍 === АНАЛИЗАТОР ОРИГИНАЛЬНОГО ПИТОМЦА ===")
    print("📊 Ищем питомца в радиусе", CONFIG.SEARCH_RADIUS, "стадов...")
    
    local originalPet = findOriginalPet()
    if not originalPet then
        print("❌ Питомец не найден! Подойдите ближе к питомцу.")
        return
    end
    
    local lastPosition = originalPet.PrimaryPart.Position
    local hasMovedOnce = false
    local logTimer = 0
    
    -- Анализируем сразу после обнаружения
    analyzePetOrientation(originalPet, "🐕 ОРИГИНАЛ СРАЗУ ПОСЛЕ ОБНАРУЖЕНИЯ")
    
    -- Мониторинг движения и периодический анализ
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not originalPet or not originalPet.Parent or not originalPet.PrimaryPart then
            print("❌ Питомец исчез!")
            connection:Disconnect()
            return
        end
        
        local currentPos = originalPet.PrimaryPart.Position
        local movement = (currentPos - lastPosition).Magnitude
        
        -- Детекция первого движения
        if not hasMovedOnce and movement > CONFIG.MOVEMENT_THRESHOLD then
            hasMovedOnce = true
            print("\n🚶 ПИТОМЕЦ НАЧАЛ ДВИГАТЬСЯ!")
            analyzePetOrientation(originalPet, "🐕 ОРИГИНАЛ ПОСЛЕ ПЕРВОГО ДВИЖЕНИЯ")
        end
        
        -- Периодический анализ
        logTimer = logTimer + deltaTime
        if logTimer >= CONFIG.LOG_INTERVAL then
            logTimer = 0
            
            if hasMovedOnce then
                analyzePetOrientation(originalPet, "🐕 ОРИГИНАЛ ТЕКУЩЕЕ СОСТОЯНИЕ (ДВИЖЕТСЯ)")
            else
                analyzePetOrientation(originalPet, "🐕 ОРИГИНАЛ ТЕКУЩЕЕ СОСТОЯНИЕ (СТОИТ)")
            end
        end
        
        lastPosition = currentPos
    end)
    
    print("\n✅ Анализ запущен! Данные будут обновляться каждую секунду.")
    print("🎯 Подождите пока питомец начнет двигаться для полного анализа.")
    
    -- Автоматическая остановка через 60 секунд
    game:GetService("Debris"):AddItem({
        Destroy = function()
            connection:Disconnect()
            print("\n⏰ Анализ завершен автоматически через 60 секунд.")
        end
    }, 60)
end

-- 🚀 ЗАПУСК
startAnalysis()
