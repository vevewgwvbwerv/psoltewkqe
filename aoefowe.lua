-- === РАСШИРЕННАЯ ДИАГНОСТИКА CHARACTER И ПИТОМЦЕВ ===
-- Ищем где находится визуальный питомец когда Tool активен

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔬 === ПОЛНАЯ ДИАГНОСТИКА CHARACTER И ПИТОМЦЕВ ===")

-- Функция для поиска всех питомцев в Character
local function findPetsInCharacter(character)
    local pets = {}
    
    -- Ищем во всех детях Character
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Model") then
            -- Проверяем имя на питомца
            if obj.Name:find("Golden") or obj.Name:find("Dog") or obj.Name:find("Bunny") or 
               obj.Name:find("Lab") or obj.Name:find("%{") or obj.Name:find("Cat") or
               obj.Name:find("Dragon") or obj.Name:find("Pet") then
                table.insert(pets, {
                    model = obj,
                    location = "Character",
                    type = obj.Name:find("%{") and "UUID" or "Regular"
                })
            end
        end
    end
    
    -- Ищем в Tool объектах
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, obj in pairs(tool:GetChildren()) do
                if obj:IsA("Model") then
                    table.insert(pets, {
                        model = obj,
                        location = "Tool: " .. tool.Name,
                        type = obj.Name:find("%{") and "UUID" or "Regular"
                    })
                end
            end
        end
    end
    
    return pets
end

-- Функция для анализа соединений (Welds, Motor6D)
local function analyzeConnections(character)
    print("\n🔗 === АНАЛИЗ СОЕДИНЕНИЙ В CHARACTER ===")
    
    local connections = {}
    
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
            table.insert(connections, obj)
        end
    end
    
    print("🔗 Найдено соединений:", #connections)
    
    for i, conn in pairs(connections) do
        if i <= 20 then -- Показываем первые 20
            print("  " .. i .. ". " .. conn.Name .. " (" .. conn.ClassName .. ")")
            
            if conn:IsA("Weld") or conn:IsA("Motor6D") then
                local part0Name = conn.Part0 and conn.Part0.Name or "nil"
                local part1Name = conn.Part1 and conn.Part1.Name or "nil"
                print("    Part0: " .. part0Name .. " → Part1: " .. part1Name)
                
                -- Ищем соединения с Handle
                if part0Name == "Handle" or part1Name == "Handle" then
                    print("    🤏 СОЕДИНЕНИЕ С HANDLE НАЙДЕНО!")
                    
                    -- Анализируем что соединено с Handle
                    local otherPart = conn.Part0 and conn.Part0.Name == "Handle" and conn.Part1 or conn.Part0
                    if otherPart then
                        print("    🐾 Соединенный объект:", otherPart.Name, "(" .. otherPart.ClassName .. ")")
                        print("    📍 Позиция:", otherPart.Position)
                        
                        -- Ищем родительскую модель
                        local parentModel = otherPart.Parent
                        while parentModel and not parentModel:IsA("Model") do
                            parentModel = parentModel.Parent
                        end
                        
                        if parentModel and parentModel ~= character then
                            print("    🏠 Родительская модель:", parentModel.Name)
                            print("    📍 Расположение модели:", parentModel.Parent and parentModel.Parent.Name or "nil")
                        end
                    end
                end
            end
        elseif i == 21 then
            print("  ... и еще " .. (#connections - 20) .. " соединений")
            break
        end
    end
end

-- Функция для поиска питомцев в Workspace рядом с игроком
local function findNearbyWorkspacePets()
    print("\n🌍 === ПОИСК ПИТОМЦЕВ В WORKSPACE ===")
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        print("❌ Character или HumanoidRootPart не найден")
        return {}
    end
    
    local playerPos = character.HumanoidRootPart.Position
    local nearbyPets = {}
    
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent ~= character then
            -- Проверяем на питомца
            if obj.Name:find("Golden") or obj.Name:find("Dog") or obj.Name:find("Bunny") or 
               obj.Name:find("Lab") or obj.Name:find("%{") or obj.Name:find("Cat") or
               obj.Name:find("Dragon") then
                
                local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
                if success then
                    local distance = (modelCFrame.Position - playerPos).Magnitude
                    if distance <= 50 then -- В радиусе 50 studs
                        
                        -- Считаем MeshParts
                        local meshCount = 0
                        for _, desc in pairs(obj:GetDescendants()) do
                            if desc:IsA("MeshPart") then
                                meshCount = meshCount + 1
                            end
                        end
                        
                        table.insert(nearbyPets, {
                            model = obj,
                            distance = distance,
                            meshCount = meshCount,
                            type = obj.Name:find("%{") and "UUID" or "Regular",
                            location = obj.Parent and obj.Parent.Name or "Unknown"
                        })
                    end
                end
            end
        end
    end
    
    -- Сортируем по дистанции
    table.sort(nearbyPets, function(a, b) return a.distance < b.distance end)
    
    print("🐾 Найдено питомцев рядом:", #nearbyPets)
    for i, pet in pairs(nearbyPets) do
        if i <= 10 then
            print("  " .. i .. ". " .. pet.model.Name)
            print("    📏 Дистанция: " .. math.floor(pet.distance))
            print("    🧩 MeshParts: " .. pet.meshCount)
            print("    🏷️ Тип: " .. pet.type)
            print("    📍 Локация: " .. pet.location)
        end
    end
    
    return nearbyPets
end

-- Основной мониторинг
local lastToolState = nil
local frameCount = 0

local diagnosticConnection = RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    
    local character = player.Character
    if not character then return end
    
    -- Ищем активный Tool
    local activeTool = nil
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            activeTool = obj
            break
        end
    end
    
    -- Если Tool появился или изменился
    if activeTool and (not lastToolState or lastToolState.name ~= activeTool.Name) then
        print("\n🚨 === ДЕТАЛЬНЫЙ АНАЛИЗ АКТИВНОГО TOOL ===")
        print("⏰ Время:", os.date("%H:%M:%S"))
        print("📛 Tool:", activeTool.Name)
        
        -- 1. Анализ питомцев в Character
        print("\n🐾 === ПИТОМЦЫ В CHARACTER ===")
        local petsInChar = findPetsInCharacter(character)
        if #petsInChar == 0 then
            print("❌ Питомцев в Character не найдено")
        else
            for i, pet in pairs(petsInChar) do
                print("  " .. i .. ". " .. pet.model.Name .. " (" .. pet.type .. ") в " .. pet.location)
            end
        end
        
        -- 2. Анализ соединений
        analyzeConnections(character)
        
        -- 3. Поиск питомцев в Workspace
        local workspacePets = findNearbyWorkspacePets()
        
        -- 4. Анализ Handle в Tool
        print("\n🤏 === АНАЛИЗ HANDLE В TOOL ===")
        local handle = activeTool:FindFirstChild("Handle")
        if handle then
            print("✅ Handle найден")
            print("📍 Handle позиция:", handle.Position)
            
            -- Ищем что соединено с Handle
            print("\n🔗 Что соединено с Handle:")
            local handleConnections = 0
            for _, obj in pairs(character:GetDescendants()) do
                if (obj:IsA("Weld") or obj:IsA("Motor6D")) and 
                   ((obj.Part0 == handle) or (obj.Part1 == handle)) then
                    handleConnections = handleConnections + 1
                    local otherPart = obj.Part0 == handle and obj.Part1 or obj.Part0
                    print("  🔗 " .. obj.Name .. " соединяет Handle с " .. (otherPart and otherPart.Name or "nil"))
                    
                    -- Ищем модель этой части
                    if otherPart then
                        local parentModel = otherPart.Parent
                        while parentModel and not parentModel:IsA("Model") and parentModel ~= character do
                            parentModel = parentModel.Parent
                        end
                        
                        if parentModel and parentModel ~= character then
                            print("    🏠 Модель: " .. parentModel.Name)
                            print("    📍 Расположение: " .. (parentModel.Parent and parentModel.Parent.Name or "nil"))
                        end
                    end
                end
            end
            
            if handleConnections == 0 then
                print("❌ Соединений с Handle не найдено")
            end
        else
            print("❌ Handle не найден в Tool")
        end
        
        -- 5. Поиск соответствующего UUID питомца
        print("\n🔍 === ПОИСК СООТВЕТСТВУЮЩЕГО UUID ПИТОМЦА ===")
        local toolPetName = activeTool.Name
        print("🎯 Ищу UUID питомца для:", toolPetName)
        
        -- Извлекаем тип питомца из имени Tool
        local petType = nil
        if toolPetName:find("Golden Lab") then
            petType = "Golden Lab"
        elseif toolPetName:find("Dog") then
            petType = "Dog"
        elseif toolPetName:find("Bunny") then
            petType = "Bunny"
        end
        
        if petType then
            print("🏷️ Тип питомца:", petType)
            
            -- Ищем UUID питомца этого типа
            for _, pet in pairs(workspacePets) do
                if pet.type == "UUID" and pet.model.Name:find(petType) then
                    print("🔑 НАЙДЕН СООТВЕТСТВУЮЩИЙ UUID:", pet.model.Name)
                    print("    📏 Дистанция:", math.floor(pet.distance))
                    print("    🧩 MeshParts:", pet.meshCount)
                    break
                end
            end
        end
        
        print("\n" .. string.rep("=", 60))
        
        lastToolState = {name = activeTool.Name, tool = activeTool}
        
    elseif not activeTool and lastToolState then
        print("\n🗑️ === TOOL УДАЛЕН ===")
        print("📛 Был:", lastToolState.name)
        lastToolState = nil
    end
    
    -- Периодическая общая диагностика
    if frameCount % 1800 == 0 then -- Каждые 30 секунд
        print("\n📊 === ПЕРИОДИЧЕСКАЯ ДИАГНОСТИКА ===")
        print("⏰ Время:", os.date("%H:%M:%S"))
        print("🎯 Кадр:", frameCount)
        
        if character then
            print("👤 Character объектов:", #character:GetChildren())
            
            -- Считаем типы объектов
            local objectTypes = {}
            for _, obj in pairs(character:GetChildren()) do
                local className = obj.ClassName
                objectTypes[className] = (objectTypes[className] or 0) + 1
            end
            
            print("📋 Типы объектов:")
            for className, count in pairs(objectTypes) do
                print("  " .. className .. ": " .. count)
            end
        end
    end
end)

print("✅ Расширенная диагностика запущена!")
print("🎯 Возьмите питомца в руку для полного анализа структуры")
print("🛑 Для остановки: diagnosticConnection:Disconnect()")

return diagnosticConnection
