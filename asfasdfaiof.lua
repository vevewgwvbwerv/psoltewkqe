-- === ДИАГНОСТИКА СОЕДИНЕНИЙ И ПРИКРЕПЛЕНИЯ ПИТОМЦЕВ ===
-- Отслеживает все Weld/Motor6D соединения в реальном времени

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔗 === ДИАГНОСТИКА СОЕДИНЕНИЙ ЗАПУЩЕНА ===")

-- Функция для детального анализа соединения
local function analyzeConnection(connection)
    local info = {
        name = connection.Name,
        type = connection.ClassName,
        part0 = connection.Part0 and connection.Part0.Name or "nil",
        part1 = connection.Part1 and connection.Part1.Name or "nil",
        part0Parent = nil,
        part1Parent = nil,
        part0Model = nil,
        part1Model = nil
    }
    
    -- Анализируем Part0
    if connection.Part0 then
        info.part0Parent = connection.Part0.Parent and connection.Part0.Parent.Name or "nil"
        
        -- Ищем родительскую модель для Part0
        local model = connection.Part0.Parent
        while model and not model:IsA("Model") and model ~= game.Workspace do
            model = model.Parent
        end
        if model and model:IsA("Model") then
            info.part0Model = model.Name
        end
    end
    
    -- Анализируем Part1
    if connection.Part1 then
        info.part1Parent = connection.Part1.Parent and connection.Part1.Parent.Name or "nil"
        
        -- Ищем родительскую модель для Part1
        local model = connection.Part1.Parent
        while model and not model:IsA("Model") and model ~= game.Workspace do
            model = model.Parent
        end
        if model and model:IsA("Model") then
            info.part1Model = model.Name
        end
    end
    
    return info
end

-- Отслеживание соединений
local lastConnections = {}
local frameCount = 0

local connectionTracker = RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    
    local character = player.Character
    if not character then return end
    
    -- Получаем все текущие соединения
    local currentConnections = {}
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
            currentConnections[obj] = true
        end
    end
    
    -- Ищем новые соединения
    for connection, _ in pairs(currentConnections) do
        if not lastConnections[connection] then
            local info = analyzeConnection(connection)
            
            -- Проверяем если это соединение связано с Handle или питомцем
            local isHandleConnection = (info.part0 == "Handle" or info.part1 == "Handle")
            local isPetConnection = (info.part0Model and (info.part0Model:find("Golden") or info.part0Model:find("Dog") or info.part0Model:find("Bunny") or info.part0Model:find("%{"))) or
                                   (info.part1Model and (info.part1Model:find("Golden") or info.part1Model:find("Dog") or info.part1Model:find("Bunny") or info.part1Model:find("%{")))
            
            if isHandleConnection or isPetConnection then
                print("\n🔗 === НОВОЕ ВАЖНОЕ СОЕДИНЕНИЕ ===")
                print("⏰ Время:", os.date("%H:%M:%S"))
                print("📛 Имя:", info.name)
                print("🔧 Тип:", info.type)
                print("🔗 " .. info.part0 .. " ↔ " .. info.part1)
                print("📍 Родители: " .. info.part0Parent .. " ↔ " .. info.part1Parent)
                
                if info.part0Model or info.part1Model then
                    print("🏠 Модели: " .. (info.part0Model or "nil") .. " ↔ " .. (info.part1Model or "nil"))
                end
                
                if isHandleConnection then
                    print("🤏 *** ЭТО СОЕДИНЕНИЕ С HANDLE! ***")
                    
                    -- Находим питомца соединенного с Handle
                    local petPart = info.part0 == "Handle" and connection.Part1 or connection.Part0
                    if petPart then
                        print("🐾 Питомец соединен с Handle через:", petPart.Name)
                        
                        -- Ищем модель питомца
                        local petModel = petPart.Parent
                        while petModel and not petModel:IsA("Model") and petModel ~= character do
                            petModel = petModel.Parent
                        end
                        
                        if petModel and petModel:IsA("Model") then
                            print("🏠 МОДЕЛЬ ПИТОМЦА В РУКЕ:", petModel.Name)
                            print("📍 Расположение модели:", petModel.Parent and petModel.Parent.Name or "nil")
                            
                            -- Полный анализ этой модели
                            print("\n🔍 === ПОЛНЫЙ АНАЛИЗ ПИТОМЦА В РУКЕ ===")
                            print("📦 Имя модели:", petModel.Name)
                            print("🔢 Дети модели:", #petModel:GetChildren())
                            
                            -- Считаем компоненты
                            local meshCount = 0
                            local motorCount = 0
                            local partCount = 0
                            
                            for _, desc in pairs(petModel:GetDescendants()) do
                                if desc:IsA("MeshPart") then
                                    meshCount = meshCount + 1
                                elseif desc:IsA("Motor6D") then
                                    motorCount = motorCount + 1
                                elseif desc:IsA("BasePart") then
                                    partCount = partCount + 1
                                end
                            end
                            
                            print("🧩 MeshParts:", meshCount)
                            print("🎭 Motor6Ds:", motorCount)
                            print("🧱 BaseParts:", partCount)
                            
                            -- Проверяем тип питомца
                            if petModel.Name:find("%{") and petModel.Name:find("%}") then
                                print("🔑 *** ЭТО УЖЕ UUID ПИТОМЕЦ! ***")
                            else
                                print("🥚 *** ЭТО ПИТОМЕЦ ИЗ ЯЙЦА - НУЖНА ЗАМЕНА! ***")
                            end
                        end
                    end
                end
                
                print(string.rep("=", 50))
            end
        end
    end
    
    -- Отслеживаем исчезновение соединений
    for connection, _ in pairs(lastConnections) do
        if not currentConnections[connection] then
            local info = analyzeConnection(connection)
            if info.part0 == "Handle" or info.part1 == "Handle" then
                print("\n🗑️ === СОЕДИНЕНИЕ С HANDLE УДАЛЕНО ===")
                print("📛 Было:", info.name, "(" .. info.type .. ")")
                print("🔗 Соединяло:", info.part0, "↔", info.part1)
            end
        end
    end
    
    -- Обновляем состояние
    lastConnections = currentConnections
    if activeTool then
        lastToolState = {name = activeTool.Name, tool = activeTool}
    else
        lastToolState = nil
    end
end)

print("✅ Диагностика соединений активна!")
print("🎯 Возьмите питомца в руку для анализа соединений")

return connectionTracker
