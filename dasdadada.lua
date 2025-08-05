-- 🔍 Tool Structure Analyzer - Полный анализ структуры Tool питомца
-- Находит ВСЕ объекты в Tool и показывает их иерархию

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

print("🔍 === Tool Structure Analyzer ===")
print("📊 Полный анализ структуры Tool питомца в руке")

-- 🔍 Функция поиска питомца в руке
local function findHandHeldPet()
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- 📊 Рекурсивный анализ структуры объекта
local function analyzeStructure(obj, depth, maxDepth)
    if depth > (maxDepth or 10) then return end
    
    local indent = string.rep("  ", depth)
    local objInfo = string.format("%s%s (%s)", indent, obj.Name, obj.ClassName)
    
    -- Добавляем дополнительную информацию для разных типов объектов
    if obj:IsA("BasePart") then
        objInfo = objInfo .. string.format(" | Size=%s | CFrame=%s | Anchored=%s", 
            tostring(obj.Size), tostring(obj.CFrame), tostring(obj.Anchored))
    elseif obj:IsA("Motor6D") then
        objInfo = objInfo .. string.format(" | Part0=%s | Part1=%s", 
            obj.Part0 and obj.Part0.Name or "NIL", obj.Part1 and obj.Part1.Name or "NIL")
    elseif obj:IsA("Attachment") then
        objInfo = objInfo .. string.format(" | CFrame=%s", tostring(obj.CFrame))
    elseif obj:IsA("LocalScript") or obj:IsA("Script") then
        objInfo = objInfo .. string.format(" | Enabled=%s", tostring(obj.Enabled))
    elseif obj:IsA("Model") then
        objInfo = objInfo .. string.format(" | PrimaryPart=%s", obj.PrimaryPart and obj.PrimaryPart.Name or "NIL")
    end
    
    print(objInfo)
    
    -- Рекурсивно анализируем детей
    for _, child in pairs(obj:GetChildren()) do
        analyzeStructure(child, depth + 1, maxDepth)
    end
end

-- 🎯 Поиск всех анимируемых объектов
local function findAnimatableObjects(tool)
    local objects = {
        baseParts = {},
        models = {},
        attachments = {},
        motor6ds = {},
        scripts = {},
        other = {}
    }
    
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(objects.baseParts, obj)
        elseif obj:IsA("Model") then
            table.insert(objects.models, obj)
        elseif obj:IsA("Attachment") then
            table.insert(objects.attachments, obj)
        elseif obj:IsA("Motor6D") then
            table.insert(objects.motor6ds, obj)
        elseif obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("ModuleScript") then
            table.insert(objects.scripts, obj)
        else
            table.insert(objects.other, obj)
        end
    end
    
    return objects
end

-- 🧪 Основная функция анализа
local function startAnalysis()
    print("🚀 Запуск анализа структуры Tool...")
    
    local connection = RunService.Heartbeat:Connect(function()
        local tool = findHandHeldPet()
        
        if tool then
            print("\n🎯 === ПИТОМЕЦ В РУКЕ НАЙДЕН ===")
            print("Tool:", tool.Name)
            print("ClassName:", tool.ClassName)
            
            print("\n📊 === ПОЛНАЯ СТРУКТУРА TOOL ===")
            analyzeStructure(tool, 0, 15)  -- Глубина до 15 уровней
            
            print("\n🔍 === КАТЕГОРИЗАЦИЯ ОБЪЕКТОВ ===")
            local objects = findAnimatableObjects(tool)
            
            print("📦 BaseParts:", #objects.baseParts)
            for i, part in ipairs(objects.baseParts) do
                print(string.format("  %d. %s | Size=%s", i, part.Name, tostring(part.Size)))
            end
            
            print("🏗️ Models:", #objects.models)
            for i, model in ipairs(objects.models) do
                print(string.format("  %d. %s | PrimaryPart=%s", i, model.Name, 
                    model.PrimaryPart and model.PrimaryPart.Name or "NIL"))
            end
            
            print("📎 Attachments:", #objects.attachments)
            for i, att in ipairs(objects.attachments) do
                print(string.format("  %d. %s | Parent=%s", i, att.Name, att.Parent.Name))
            end
            
            print("⚙️ Motor6Ds:", #objects.motor6ds)
            for i, motor in ipairs(objects.motor6ds) do
                print(string.format("  %d. %s | Part0=%s | Part1=%s", i, motor.Name,
                    motor.Part0 and motor.Part0.Name or "NIL",
                    motor.Part1 and motor.Part1.Name or "NIL"))
            end
            
            print("📜 Scripts:", #objects.scripts)
            for i, script in ipairs(objects.scripts) do
                print(string.format("  %d. %s (%s) | Enabled=%s", i, script.Name, 
                    script.ClassName, tostring(script.Enabled)))
            end
            
            print("❓ Other Objects:", #objects.other)
            for i, obj in ipairs(objects.other) do
                if i <= 10 then  -- Показываем первые 10
                    print(string.format("  %d. %s (%s)", i, obj.Name, obj.ClassName))
                end
            end
            
            print("\n✅ === АНАЛИЗ ЗАВЕРШЕН ===")
            print("🛑 Отключаю анализатор...")
            connection:Disconnect()
            
            return
        end
    end)
    
    print("🔍 Ожидание питомца в руке...")
    print("🎒 Возьми питомца в руки для анализа структуры")
    
    return connection
end

-- 🚀 Запуск анализатора
local analyzerConnection = startAnalysis()

return analyzerConnection
