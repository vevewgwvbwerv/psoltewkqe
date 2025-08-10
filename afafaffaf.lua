-- === ДИАГНОСТИЧЕСКИЙ СКРИПТ ДЛЯ АНАЛИЗА РУКИ/TOOL/HANDLE ===
-- Этот скрипт отслеживает появление Tool/Handle в Character игрока
-- и выводит полную диагностическую информацию о структуре

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === ДИАГНОСТИКА РУКИ/TOOL/HANDLE ЗАПУЩЕНА ===")
print("👤 Игрок:", player.Name)

-- Хранилище для отслеживания изменений
local lastCharacterChildren = {}
local lastToolContents = {}
local frameCount = 0

-- Функция для глубокого анализа объекта
local function analyzeObject(obj, depth, maxDepth)
    if depth > (maxDepth or 3) then
        return "  " .. string.rep("  ", depth) .. "... (слишком глубоко)"
    end
    
    local result = ""
    local indent = string.rep("  ", depth)
    
    result = result .. indent .. "📦 " .. obj.Name .. " (" .. obj.ClassName .. ")\n"
    
    -- Специальная информация для разных типов объектов
    if obj:IsA("Tool") then
        result = result .. indent .. "  🔧 Tool свойства:\n"
        result = result .. indent .. "    - RequiresHandle: " .. tostring(obj.RequiresHandle) .. "\n"
        result = result .. indent .. "    - CanBeDropped: " .. tostring(obj.CanBeDropped) .. "\n"
        result = result .. indent .. "    - ManualActivationOnly: " .. tostring(obj.ManualActivationOnly) .. "\n"
    elseif obj:IsA("Model") then
        result = result .. indent .. "  🐾 Model свойства:\n"
        result = result .. indent .. "    - PrimaryPart: " .. (obj.PrimaryPart and obj.PrimaryPart.Name or "nil") .. "\n"
        
        -- Считаем MeshPart
        local meshCount = 0
        local motorCount = 0
        for _, desc in pairs(obj:GetDescendants()) do
            if desc:IsA("MeshPart") then
                meshCount = meshCount + 1
            elseif desc:IsA("Motor6D") then
                motorCount = motorCount + 1
            end
        end
        result = result .. indent .. "    - MeshParts: " .. meshCount .. "\n"
        result = result .. indent .. "    - Motor6Ds: " .. motorCount .. "\n"
        
        -- Проверяем UUID формат
        if obj.Name:find("%{") and obj.Name:find("%}") then
            result = result .. indent .. "    - 🔑 UUID ФОРМАТ ОБНАРУЖЕН!\n"
        end
        
    elseif obj:IsA("BasePart") then
        result = result .. indent .. "  🧱 Part свойства:\n"
        result = result .. indent .. "    - Position: " .. tostring(obj.Position) .. "\n"
        result = result .. indent .. "    - Size: " .. tostring(obj.Size) .. "\n"
        result = result .. indent .. "    - Anchored: " .. tostring(obj.Anchored) .. "\n"
        result = result .. indent .. "    - CanCollide: " .. tostring(obj.CanCollide) .. "\n"
        result = result .. indent .. "    - Material: " .. tostring(obj.Material) .. "\n"
    elseif obj:IsA("Motor6D") then
        result = result .. indent .. "  🎭 Motor6D свойства:\n"
        result = result .. indent .. "    - Part0: " .. (obj.Part0 and obj.Part0.Name or "nil") .. "\n"
        result = result .. indent .. "    - Part1: " .. (obj.Part1 and obj.Part1.Name or "nil") .. "\n"
        result = result .. indent .. "    - C0: " .. tostring(obj.C0) .. "\n"
        result = result .. indent .. "    - C1: " .. tostring(obj.C1) .. "\n"
    end
    
    -- Рекурсивно анализируем детей
    local children = obj:GetChildren()
    if #children > 0 then
        result = result .. indent .. "  📁 Дети (" .. #children .. "):\n"
        for i, child in pairs(children) do
            if i <= 10 then -- Ограничиваем количество для читаемости
                result = result .. analyzeObject(child, depth + 2, maxDepth)
            elseif i == 11 then
                result = result .. indent .. "    ... и еще " .. (#children - 10) .. " объектов\n"
                break
            end
        end
    end
    
    return result
end

-- Основной мониторинг
local diagnosticConnection = RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    
    local playerChar = player.Character
    if not playerChar then return end
    
    -- Получаем текущие дети Character
    local currentChildren = {}
    for _, obj in pairs(playerChar:GetChildren()) do
        currentChildren[obj.Name] = obj
    end
    
    -- Ищем новые объекты в Character
    for name, obj in pairs(currentChildren) do
        if not lastCharacterChildren[name] then
            -- Если это Tool - ПОЛНАЯ ДИАГНОСТИКА!
            if obj:IsA("Tool") then
                print("\n🚨 === НОВЫЙ TOOL В CHARACTER! ===")
                print("⏰ Время:", os.date("%H:%M:%S"))
                print("🎯 Кадр:", frameCount)
                print("\n" .. analyzeObject(obj, 0, 4))
                
                -- Дополнительная информация о Tool
                print("\n🔍 === ДОПОЛНИТЕЛЬНАЯ TOOL ИНФОРМАЦИЯ ===")
                
                -- Ищем Handle внутри Tool
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    print("🤏 Handle найден в Tool!")
                    print("   Класс Handle:", handle.ClassName)
                    if handle:IsA("BasePart") then
                        print("   Handle позиция:", handle.Position)
                        print("   Handle размер:", handle.Size)
                    end
                else
                    print("❌ Handle НЕ найден в Tool")
                end
                
                -- Ищем питомцев в Tool
                local petsInTool = {}
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("Model") then
                        table.insert(petsInTool, child)
                    end
                end
                
                print("🐾 Питомцев в Tool:", #petsInTool)
                for i, pet in pairs(petsInTool) do
                    print("  " .. i .. ". " .. pet.Name)
                    
                    -- Проверяем тип питомца
                    if pet.Name:find("Golden") or pet.Name:find("Dog") or pet.Name:find("Bunny") or pet.Name:find("Lab") then
                        print("    🥚 ТИП: Питомец из яйца (обычное имя)")
                    elseif pet.Name:find("%{") and pet.Name:find("%}") then
                        print("    🔑 ТИП: UUID питомец!")
                    else
                        print("    ❓ ТИП: Неизвестный")
                    end
                end
                
                print("\n" .. string.rep("=", 50))
                
            -- Если это обычный объект, краткая информация
            elseif obj.ClassName ~= "Humanoid" and obj.ClassName ~= "HumanoidRootPart" and 
                   not obj.Name:find("Body") and not obj.Name:find("Mesh") then
                print("➕ Новый объект в Character:", name, "(" .. obj.ClassName .. ")")
            end
        end
    end
    
    -- Отслеживаем исчезновение Tool
    for name, obj in pairs(lastCharacterChildren) do
        if not currentChildren[name] and obj:IsA("Tool") then
            print("\n🗑️ === TOOL УДАЛЕН ИЗ CHARACTER ===")
            print("📛 Имя:", name)
            print("⏰ Время:", os.date("%H:%M:%S"))
            print("🎯 Кадр:", frameCount)
        end
    end
    
    -- Обновляем состояние
    lastCharacterChildren = currentChildren
    
    -- Каждые 10 секунд показываем общую информацию
    if frameCount % 600 == 0 then
        print("\n📊 === ОБЩАЯ ДИАГНОСТИКА (кадр " .. frameCount .. ") ===")
        print("👤 Character:", playerChar.Name)
        print("🔢 Объектов в Character:", #playerChar:GetChildren())
        
        local toolCount = 0
        for _, obj in pairs(playerChar:GetChildren()) do
            if obj:IsA("Tool") then
                toolCount = toolCount + 1
            end
        end
        print("🔧 Tool объектов:", toolCount)
        
        if toolCount > 0 then
            print("🔧 Активные Tools:")
            for _, obj in pairs(playerChar:GetChildren()) do
                if obj:IsA("Tool") then
                    print("  - " .. obj.Name)
                end
            end
        end
    end
end)

print("✅ Диагностика запущена! Откройте яйцо и возьмите питомца в руку.")
print("📋 Скрипт будет отслеживать все изменения в Character и Tool объектах.")
print("🛑 Для остановки диагностики выполните: diagnosticConnection:Disconnect()")

-- Возвращаем connection для возможности остановки
return diagnosticConnection
