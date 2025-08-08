-- AdvancedTextReplacer.lua
-- Замена текста + анализ и замена полной структуры Tool в руке

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

print("=== ADVANCED TEXT REPLACER ===")

-- Глобальные переменные
local currentHandTool = nil
local analyzedToolData = nil
local diagnosticConnection = nil

-- Данные для анализа
local animationData = {
    animators = {},
    animationTracks = {},
    scripts = {},
    motor6ds = {},
    cframes = {},
    lastUpdate = 0
}

-- Функция поиска питомца в руке
local function findHandPetTool()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- Функция поиска и замены текста в Hotbar
local function replaceTextInHotbar(slotNumber, newText)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return false end
    
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local hotbar = backpack:FindFirstChild("Hotbar")
    if not hotbar then return false end
    
    local targetSlot = hotbar:FindFirstChild(tostring(slotNumber))
    if not targetSlot then return false end
    
    -- Ищем TextLabel в слоте
    for _, desc in pairs(targetSlot:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text ~= "" then
            local oldText = desc.Text
            desc.Text = newText
            print("✅ Текст заменен: " .. oldText .. " → " .. newText)
            return true
        end
    end
    
    return false
end

-- Функция глубокого копирования Tool
local function deepCopyTool(originalTool)
    if not originalTool then return nil end
    
    print("🔄 Создаю глубокую копию Tool: " .. originalTool.Name)
    
    local function copyInstance(instance)
        local copy = Instance.new(instance.ClassName)
        
        -- Копируем основные свойства
        local basicProperties = {"Name", "Archivable"}
        for _, property in pairs(basicProperties) do
            local success, value = pcall(function()
                return instance[property]
            end)
            if success then
                pcall(function()
                    copy[property] = value
                end)
            end
        end
        
        -- Специальные свойства для Tool
        if instance:IsA("Tool") then
            pcall(function() copy.RequiresHandle = instance.RequiresHandle end)
            pcall(function() copy.ManualActivationOnly = instance.ManualActivationOnly end)
            pcall(function() copy.CanBeDropped = instance.CanBeDropped end)
            pcall(function() copy.Enabled = instance.Enabled end)
            pcall(function() copy.ToolTip = instance.ToolTip end)
            print("🔧 Tool свойства скопированы")
            
        -- Специальные свойства для BasePart
        elseif instance:IsA("BasePart") then
            pcall(function() copy.Size = instance.Size end)
            pcall(function() copy.CFrame = instance.CFrame end)
            pcall(function() copy.Material = instance.Material end)
            pcall(function() copy.BrickColor = instance.BrickColor end)
            pcall(function() copy.Color = instance.Color end)
            pcall(function() copy.Transparency = instance.Transparency end)
            pcall(function() copy.Reflectance = instance.Reflectance end)
            pcall(function() copy.CanCollide = instance.CanCollide end)
            pcall(function() copy.Anchored = instance.Anchored end)
            pcall(function() copy.Shape = instance.Shape end)
            pcall(function() copy.TopSurface = instance.TopSurface end)
            pcall(function() copy.BottomSurface = instance.BottomSurface end)
            print("🧱 Part свойства скопированы: " .. instance.Name)
            
        -- Специальные свойства для SpecialMesh
        elseif instance:IsA("SpecialMesh") then
            pcall(function() copy.MeshType = instance.MeshType end)
            pcall(function() copy.MeshId = instance.MeshId end)
            pcall(function() copy.TextureId = instance.TextureId end)
            pcall(function() copy.Scale = instance.Scale end)
            pcall(function() copy.Offset = instance.Offset end)
            pcall(function() copy.VertexColor = instance.VertexColor end)
            print("🎨 Mesh свойства скопированы")
            
        -- Специальные свойства для Motor6D
        elseif instance:IsA("Motor6D") then
            pcall(function() copy.C0 = instance.C0 end)
            pcall(function() copy.C1 = instance.C1 end)
            -- Part0 и Part1 установим после создания всех частей
            print("⚙️ Motor6D свойства скопированы: " .. instance.Name)
            
        -- Специальные свойства для Weld
        elseif instance:IsA("Weld") then
            pcall(function() copy.C0 = instance.C0 end)
            pcall(function() copy.C1 = instance.C1 end)
            print("🔗 Weld свойства скопированы: " .. instance.Name)
            
        -- Специальные свойства для LocalScript/Script
        elseif instance:IsA("LocalScript") or instance:IsA("Script") then
            pcall(function() copy.Enabled = instance.Enabled end)
            pcall(function() copy.Source = instance.Source end)
            print("📜 Script свойства скопированы: " .. instance.Name)
        end
        
        return copy
    end
    
    -- Создаем копию с детьми
    local toolCopy = copyInstance(originalTool)
    
    -- Рекурсивно копируем всех детей
    local function copyChildren(original, copy)
        for _, child in pairs(original:GetChildren()) do
            local childCopy = copyInstance(child)
            childCopy.Parent = copy
            copyChildren(child, childCopy) -- Рекурсивно копируем детей детей
        end
    end
    
    copyChildren(originalTool, toolCopy)
    
    -- Восстанавливаем связи Motor6D и Weld
    local function restoreConnections(original, copy)
        for _, originalChild in pairs(original:GetDescendants()) do
            if originalChild:IsA("Motor6D") or originalChild:IsA("Weld") then
                -- Находим соответствующую копию
                local copyChild = copy:FindFirstChild(originalChild.Name, true)
                if copyChild and (copyChild:IsA("Motor6D") or copyChild:IsA("Weld")) then
                    -- Восстанавливаем Part0 и Part1 только для BasePart
                    if originalChild.Part0 and originalChild.Part0:IsA("BasePart") then
                        local part0Copy = copy:FindFirstChild(originalChild.Part0.Name, true)
                        if part0Copy and part0Copy:IsA("BasePart") then
                            pcall(function()
                                copyChild.Part0 = part0Copy
                                print("🔗 Part0 восстановлен: " .. originalChild.Name .. " -> " .. part0Copy.Name)
                            end)
                        else
                            print("⚠️ Part0 не найден или не BasePart: " .. originalChild.Name)
                        end
                    end
                    if originalChild.Part1 and originalChild.Part1:IsA("BasePart") then
                        local part1Copy = copy:FindFirstChild(originalChild.Part1.Name, true)
                        if part1Copy and part1Copy:IsA("BasePart") then
                            pcall(function()
                                copyChild.Part1 = part1Copy
                                print("🔗 Part1 восстановлен: " .. originalChild.Name .. " -> " .. part1Copy.Name)
                            end)
                        else
                            print("⚠️ Part1 не найден или не BasePart: " .. originalChild.Name)
                        end
                    end
                else
                    print("⚠️ Копия Motor6D/Weld не найдена: " .. originalChild.Name)
                end
            end
        end
    end
    
    restoreConnections(originalTool, toolCopy)
    
    print("✅ Глубокая копия Tool создана успешно!")
    return toolCopy
end

-- Функция анализа Tool
local function analyzeTool(tool)
    if not tool then return nil end
    
    print("\n🔍 === АНАЛИЗ TOOL: " .. tool.Name .. " ===")
    
    local toolData = {
        name = tool.Name,
        className = tool.ClassName,
        parts = {},
        motor6ds = {},
        welds = {},
        meshes = {},
        scripts = {},
        animators = {},
        totalChildren = 0
    }
    
    -- Анализируем все компоненты
    for _, obj in pairs(tool:GetDescendants()) do
        toolData.totalChildren = toolData.totalChildren + 1
        
        if obj:IsA("BasePart") then
            table.insert(toolData.parts, {
                name = obj.Name,
                size = obj.Size,
                cframe = obj.CFrame,
                material = obj.Material.Name,
                transparency = obj.Transparency
            })
            print("🧱 Part: " .. obj.Name .. " | Size: " .. tostring(obj.Size))
            
        elseif obj:IsA("Motor6D") then
            table.insert(toolData.motor6ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "NIL",
                part1 = obj.Part1 and obj.Part1.Name or "NIL",
                c0 = obj.C0,
                c1 = obj.C1
            })
            print("⚙️ Motor6D: " .. obj.Name .. " | " .. (obj.Part0 and obj.Part0.Name or "NIL") .. " → " .. (obj.Part1 and obj.Part1.Name or "NIL"))
            
        elseif obj:IsA("Weld") then
            table.insert(toolData.welds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "NIL",
                part1 = obj.Part1 and obj.Part1.Name or "NIL",
                c0 = obj.C0,
                c1 = obj.C1
            })
            print("🔗 Weld: " .. obj.Name)
            
        elseif obj:IsA("SpecialMesh") then
            table.insert(toolData.meshes, {
                name = obj.Name,
                meshType = obj.MeshType.Name,
                meshId = obj.MeshId,
                textureId = obj.TextureId,
                scale = obj.Scale
            })
            print("🎨 Mesh: " .. obj.Name .. " | Type: " .. obj.MeshType.Name)
            
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            table.insert(toolData.scripts, {
                name = obj.Name,
                className = obj.ClassName,
                enabled = obj.Enabled
            })
            print("📜 Script: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            
        elseif obj:IsA("Animator") then
            table.insert(toolData.animators, {
                name = obj.Name,
                parent = obj.Parent.Name
            })
            print("🎭 Animator: " .. obj.Name .. " в " .. obj.Parent.Name)
        end
    end
    
    print("📊 Анализ завершен:")
    print("   🧱 Частей: " .. #toolData.parts)
    print("   ⚙️ Motor6D: " .. #toolData.motor6ds)
    print("   🔗 Weld: " .. #toolData.welds)
    print("   🎨 Мешей: " .. #toolData.meshes)
    print("   📜 Скриптов: " .. #toolData.scripts)
    print("   🎭 Аниматоров: " .. #toolData.animators)
    print("   📦 Всего объектов: " .. toolData.totalChildren)
    
    return toolData
end

-- Функция замены Shovel на копию проанализированного питомца
local function replaceToolInHand(analyzedToolData)
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден")
        return false
    end
    
    -- Находим проанализированный питомец в руке
    local sourceTool = findHandPetTool()
    if not sourceTool then
        print("❌ Проанализированный питомец в руке не найден")
        return false
    end
    
    print("🔄 Заменяю Shovel в слоте 1 на копию питомца: " .. sourceTool.Name)
    
    -- НОВЫЙ ПОДХОД: Заменяем Tool, который сейчас в руке (если это Shovel)
    local currentToolInHand = nil
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            currentToolInHand = tool
            break
        end
    end
    
    if currentToolInHand and not (string.find(currentToolInHand.Name, "KG%]") and string.find(currentToolInHand.Name, "%[")) then
        -- Это не питомец (вероятно Shovel), заменяем его
        print("🎯 Заменяю Tool в руке: " .. currentToolInHand.Name)
        
        -- Создаем копию питомца
        local petCopy = sourceTool:Clone()
        petCopy.Name = "Dragonfly [6.36 KG] [Age 35]"
        
        -- Удаляем Tool из руки и заменяем на копию
        currentToolInHand:Destroy()
        wait(0.1)
        petCopy.Parent = character
        
        -- Заменяем текст в слоте 1
        replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
        
        print("✅ Tool в руке заменен на Dragonfly!")
        print("✅ Текст в слоте 1 заменен!")
        return true
    end
    
    -- Новый подход: ищем Tool, который соответствует слоту 1 в Hotbar
    local function findToolInSlot1()
        -- Сначала проверяем, что в слоте 1 (может быть в руке)
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                print("🔍 Tool в руке: " .. tool.Name)
                -- Если это не питомец, то это наш кандидат
                if not (string.find(tool.Name, "KG%]") and string.find(tool.Name, "%[")) then
                    return tool
                end
            end
        end
        
        -- Ищем в Backpack
        local backpack = character:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    print("🔍 Tool в Backpack: " .. tool.Name)
                    -- Если это не питомец, то это наш кандидат
                    if not (string.find(tool.Name, "KG%]") and string.find(tool.Name, "%[")) then
                        return tool
                    end
                end
            end
        end
        
        return nil
    end
    
    local shovelTool = findToolInSlot1()
    
    if shovelTool then
        print("✅ Найден Tool для замены: " .. shovelTool.Name)
    else
        print("🔍 Не найден подходящий Tool, создаем новый...")
        -- Если нет подходящего Tool, создаем простой Tool для замены
        shovelTool = Instance.new("Tool")
        shovelTool.Name = "Shovel [Destroy Plants]"
        shovelTool.RequiresHandle = true
        
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.Material = Enum.Material.Wood
        handle.BrickColor = BrickColor.new("Brown")
        handle.CanCollide = false
        handle.Parent = shovelTool
        
        shovelTool.Parent = character:FindFirstChild("Backpack") or character
        print("✅ Создан временный Tool для замены")
    end
    
    if not shovelTool then
        print("❌ Shovel не найден в инвентаре")
        return false
    end
    
    print("✅ Найден Shovel: " .. shovelTool.Name)
    print("🔄 Создаю копию питомца для замены Shovel...")
    
    -- Создаем простую копию питомца без сложных связей
    print("🔄 Создаю упрощенную копию питомца...")
    local petCopy = sourceTool:Clone()
    if not petCopy then
        print("❌ Не удалось создать копию питомца")
        return false
    end
    print("✅ Упрощенная копия создана успешно!")
    
    -- Меняем имя копии на Dragonfly
    petCopy.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Сохраняем информацию о Shovel
    local shovelParent = shovelTool.Parent
    local shovelName = shovelTool.Name
    
    print("🔄 Удаляю старый Tool: " .. shovelName)
    print("🔄 Родитель Tool: " .. (shovelParent and shovelParent.Name or "NIL"))
    
    -- Удаляем Shovel
    shovelTool:Destroy()
    wait(0.2) -- Увеличиваем задержку для надежности
    
    -- Помещаем копию питомца на место Shovel
    print("🔄 Размещаю копию питомца в: " .. (shovelParent and shovelParent.Name or "Character"))
    petCopy.Parent = shovelParent or character
    
    -- Дополнительная проверка размещения
    wait(0.1)
    if petCopy.Parent then
        print("✅ Копия успешно размещена в: " .. petCopy.Parent.Name)
    else
        print("❌ Ошибка размещения копии!")
        petCopy.Parent = character -- Fallback в персонажа
    end
    
    print("📝 Структура замененного Tool:")
    print("   🧱 Частей: " .. #analyzedToolData.parts)
    print("   ⚙️ Motor6D: " .. #analyzedToolData.motor6ds)
    print("   🔗 Weld: " .. #analyzedToolData.welds)
    print("   🎨 Мешей: " .. #analyzedToolData.meshes)
    print("   📜 Скриптов: " .. #analyzedToolData.scripts)
    
    print("✅ Shovel успешно заменен на копию питомца Dragonfly!")
    print("✅ Теперь у вас есть Dragonfly вместо Shovel!")
    return true
end

-- НОВЫЙ ПОДХОД: Создаем Tool прямо в слоте 1 через замену текста + создание Tool
local function replaceToolStructure(analyzedToolData)
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден")
        return false
    end
    
    -- Находим проанализированный питомец в руке
    local sourceTool = findHandPetTool()
    if not sourceTool then
        print("❌ Проанализированный питомец в руке не найден")
        return false
    end
    
    print("🔄 === НОВЫЙ ПОДХОД: ПРЯМАЯ ЗАМЕНА СЛОТА 1 ===")
    
    -- Шаг 1: Заменяем текст в слоте 1
    print("📝 Шаг 1: Заменяю текст в слоте 1...")
    local textSuccess = replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
    if textSuccess then
        print("✅ Текст в слоте 1 заменен!")
    else
        print("⚠️ Не удалось заменить текст в слоте 1")
    end
    
    -- Шаг 2: Создаем новый Tool с именем Dragonfly
    print("🔧 Шаг 2: Создаю новый Tool Dragonfly...")
    local newTool = sourceTool:Clone()
    newTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    -- Шаг 3: Удаляем все существующие Tool (кроме питомца в руке)
    print("🗑️ Шаг 3: Очищаю инвентарь от старых Tool...")
    local backpack = character:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                print("   🗑️ Удаляю: " .. tool.Name)
                tool:Destroy()
            end
        end
    end
    
    -- Удаляем Tool из рук (кроме питомца)
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and not (string.find(tool.Name, "KG%]") and string.find(tool.Name, "%[")) then
            print("   🗑️ Удаляю из рук: " .. tool.Name)
            tool:Destroy()
        end
    end
    
    wait(0.2)
    
    -- Шаг 4: Добавляем новый Tool в Backpack
    print("📦 Шаг 4: Добавляю Dragonfly в Backpack...")
    if not backpack then
        backpack = Instance.new("Backpack")
        backpack.Parent = character
        print("✅ Создан новый Backpack")
    end
    
    newTool.Parent = backpack
    print("✅ Dragonfly добавлен в Backpack!")
    
    -- Шаг 5: Принудительно обновляем слот 1
    print("🔄 Шаг 5: Принудительно обновляю слот 1...")
    
    -- Симулируем выбор слота 1 для обновления
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local backpackGui = playerGui:FindFirstChild("BackpackGui")
        if backpackGui then
            local backpackFrame = backpackGui:FindFirstChild("Backpack")
            if backpackFrame then
                local hotbar = backpackFrame:FindFirstChild("Hotbar")
                if hotbar then
                    local slot1 = hotbar:FindFirstChild("1")
                    if slot1 then
                        -- Принудительно активируем слот 1
                        print("🎯 Активирую слот 1...")
                        
                        -- Если есть кнопка в слоте, симулируем клик
                        for _, child in pairs(slot1:GetDescendants()) do
                            if child:IsA("GuiButton") or child:IsA("TextButton") or child:IsA("ImageButton") then
                                -- Симулируем клик по слоту
                                pcall(function()
                                    child.MouseButton1Click:Fire()
                                    print("✅ Клик по слоту 1 выполнен!")
                                end)
                                break
                            end
                        end
                        
                        -- Дополнительно: пытаемся активировать Tool напрямую
                        wait(0.1)
                        if newTool.Parent == backpack then
                            pcall(function()
                                newTool.Parent = character
                                print("✅ Tool принудительно перемещен в руки!")
                            end)
                        end
                    end
                end
            end
        end
    end
    
    print("🎯 === РЕЗУЛЬТАТ ===")
    print("📝 Текст в слоте 1: Dragonfly [6.36 KG] [Age 35]")
    print("🔧 Tool в Backpack: " .. newTool.Name)
    print("📊 Структура: " .. analyzedToolData.totalChildren .. " объектов")
    print("🔄 Слот 1 принудительно обновлен!")
    
    return true
end

-- СТАРЫЙ ПОДХОД (оставляем как резерв)
local function replaceToolStructureOLD(analyzedToolData)
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден")
        return false
    end
    
    -- Находим проанализированный питомец в руке
    local sourceTool = findHandPetTool()
    if not sourceTool then
        print("❌ Проанализированный питомец в руке не найден")
        return false
    end
    
    print("🔄 Ищу Shovel для замены структуры...")
    
    -- Ищем Shovel в руке или в Backpack
    local targetTool = nil
    
    -- Сначала проверяем руки
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name, "Shovel") or string.find(tool.Name, "Destroy")) then
            targetTool = tool
            print("✅ Найден Shovel в руке: " .. tool.Name)
            break
        end
    end
    
    -- Если не в руке, ищем в Backpack
    if not targetTool then
        local backpack = character:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name, "Shovel") or string.find(tool.Name, "Destroy")) then
                    targetTool = tool
                    print("✅ Найден Shovel в Backpack: " .. tool.Name)
                    break
                end
            end
        end
    end
    
    if not targetTool then
        print("❌ Shovel не найден для замены!")
        
        -- ДИАГНОСТИКА: Показываем что есть в инвентаре
        print("🔍 === ДИАГНОСТИКА ИНВЕНТАРЯ ===")
        print("📦 Содержимое Character:")
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                print("   🔧 В руке: " .. tool.Name)
            end
        end
        
        local backpack = character:FindFirstChild("Backpack")
        if backpack then
            print("📦 Содержимое Backpack:")
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    print("   🔧 В Backpack: " .. tool.Name)
                end
            end
            
            if #backpack:GetChildren() == 0 then
                print("   ⚠️ Backpack пуст!")
            end
        else
            print("❌ Backpack не найден!")
        end
        
        -- Попробуем найти любой не-питомец Tool
        print("🔍 Ищу любой не-питомец Tool...")
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and not (string.find(tool.Name, "KG%]") and string.find(tool.Name, "%[")) then
                print("   🎯 Найден кандидат в руке: " .. tool.Name)
                targetTool = tool
                break
            end
        end
        
        if not targetTool and backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and not (string.find(tool.Name, "KG%]") and string.find(tool.Name, "%[")) then
                    print("   🎯 Найден кандидат в Backpack: " .. tool.Name)
                    targetTool = tool
                    break
                end
            end
        end
        
        if not targetTool then
            print("❌ Никаких подходящих Tool не найдено!")
            return false
        else
            print("✅ Используем Tool: " .. targetTool.Name)
        end
    end
    
    print("🔄 Заменяю структуру: " .. targetTool.Name .. " → " .. sourceTool.Name)
    
    -- Удаляем все содержимое Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(targetTool:GetChildren()) do
        child:Destroy()
        print("   🗑️ Удален: " .. child.Name)
    end
    
    wait(0.1)
    
    -- Копируем все содержимое питомца в Shovel
    print("📋 Копирую содержимое питомца в Shovel...")
    for _, child in pairs(sourceTool:GetChildren()) do
        local childCopy = child:Clone()
        childCopy.Parent = targetTool
        print("   ✅ Скопирован: " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    -- Меняем имя Tool на Dragonfly
    local oldName = targetTool.Name
    targetTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    print("✅ Структура заменена успешно!")
    print("📝 " .. oldName .. " → " .. targetTool.Name)
    print("📊 Скопировано объектов: " .. analyzedToolData.totalChildren)
    
    return true
end

-- Функция создания GUI
local function createControlGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedTextReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Главное окно
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🔧 Продвинутая замена Tool"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Статус
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 60)
    statusLabel.Position = UDim2.new(0, 10, 0, 50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Готов к работе. Возьмите питомца в руки для анализа."
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    -- Кнопка замены текста
    local replaceTextButton = Instance.new("TextButton")
    replaceTextButton.Size = UDim2.new(1, -20, 0, 40)
    replaceTextButton.Position = UDim2.new(0, 10, 0, 120)
    replaceTextButton.BackgroundColor3 = Color3.new(0, 0.6, 0)
    replaceTextButton.BorderSizePixel = 0
    replaceTextButton.Text = "📝 Заменить текст слота 1"
    replaceTextButton.TextColor3 = Color3.new(1, 1, 1)
    replaceTextButton.TextScaled = true
    replaceTextButton.Font = Enum.Font.SourceSansBold
    replaceTextButton.Parent = mainFrame
    
    -- Кнопка анализа Tool
    local analyzeButton = Instance.new("TextButton")
    analyzeButton.Size = UDim2.new(1, -20, 0, 40)
    analyzeButton.Position = UDim2.new(0, 10, 0, 170)
    analyzeButton.BackgroundColor3 = Color3.new(0, 0.4, 0.8)
    analyzeButton.BorderSizePixel = 0
    analyzeButton.Text = "🔍 Анализировать питомца в руке"
    analyzeButton.TextColor3 = Color3.new(1, 1, 1)
    analyzeButton.TextScaled = true
    analyzeButton.Font = Enum.Font.SourceSansBold
    analyzeButton.Parent = mainFrame
    
    -- Кнопка замены Tool
    local replaceToolButton = Instance.new("TextButton")
    replaceToolButton.Size = UDim2.new(1, -20, 0, 40)
    replaceToolButton.Position = UDim2.new(0, 10, 0, 220)
    replaceToolButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    replaceToolButton.BorderSizePixel = 0
    replaceToolButton.Text = "🔧 Заменить Tool + текст"
    replaceToolButton.TextColor3 = Color3.new(1, 1, 1)
    replaceToolButton.TextScaled = true
    replaceToolButton.Font = Enum.Font.SourceSansBold
    replaceToolButton.Visible = false
    replaceToolButton.Parent = mainFrame
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -20, 0, 40)
    closeButton.Position = UDim2.new(0, 10, 0, 320)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "❌ Закрыть"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    replaceToolButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    -- Подключаем события
    replaceTextButton.MouseButton1Click:Connect(function()
        local success = replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
        if success then
            statusLabel.Text = "✅ Текст в слоте 1 заменен на Dragonfly!"
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
        else
            statusLabel.Text = "❌ Не удалось заменить текст"
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    analyzeButton.MouseButton1Click:Connect(function()
        local tool = findHandPetTool()
        if tool then
            statusLabel.Text = "🔍 Анализирую Tool: " .. tool.Name
            statusLabel.TextColor3 = Color3.new(0, 1, 1)
            
            analyzedToolData = analyzeTool(tool)
            
            -- НЕ заменяем текст при анализе, только при замене!
            
            statusLabel.Text = "✅ Анализ завершен! Tool готов к замене."
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
            replaceToolButton.Visible = true
        else
            statusLabel.Text = "❌ Питомец в руке не найден!"
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceToolButton.MouseButton1Click:Connect(function()
        if analyzedToolData then
            statusLabel.Text = "🔄 Выполняю замену структуры..."
            statusLabel.TextColor3 = Color3.new(1, 1, 0)
            
            -- НОВЫЙ ПОДХОД: Заменяем структуру существующего Tool
            local success = replaceToolStructure(analyzedToolData)
            if success then
                -- Также заменяем текст
                replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
                statusLabel.Text = "✅ Структура Tool заменена на питомца!"
                statusLabel.TextColor3 = Color3.new(0, 1, 0)
            else
                statusLabel.Text = "❌ Не удалось заменить структуру Tool"
                statusLabel.TextColor3 = Color3.new(1, 0, 0)
            end
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        if diagnosticConnection then
            diagnosticConnection:Disconnect()
        end
        screenGui:Destroy()
    end)
end

-- Создаем GUI
createControlGUI()

print("✅ AdvancedTextReplacer готов!")
print("🎮 Используйте GUI для замены текста и анализа Tool")
