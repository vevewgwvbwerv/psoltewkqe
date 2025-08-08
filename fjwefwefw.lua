-- InventoryEventAnalyzer.lua
-- Анализ системных событий для перемещения питомцев

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

print("=== АНАЛИЗ СОБЫТИЙ ИНВЕНТАРЯ ===")

-- Функция поиска RemoteEvent'ов
local function findRemoteEvents()
    print("🔍 Ищу RemoteEvent'ы...")
    
    local events = {}
    
    -- Ищем в ReplicatedStorage
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("RemoteEvent") then
            table.insert(events, {
                name = desc.Name,
                path = desc:GetFullName(),
                element = desc
            })
            print("📡 RemoteEvent: " .. desc.Name .. " (" .. desc:GetFullName() .. ")")
        end
    end
    
    return events
end

-- Функция поиска RemoteFunction'ов
local function findRemoteFunctions()
    print("🔍 Ищу RemoteFunction'ы...")
    
    local functions = {}
    
    -- Ищем в ReplicatedStorage
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("RemoteFunction") then
            table.insert(functions, {
                name = desc.Name,
                path = desc:GetFullName(),
                element = desc
            })
            print("⚡ RemoteFunction: " .. desc.Name .. " (" .. desc:GetFullName() .. ")")
        end
    end
    
    return functions
end

-- Функция поиска скриптов в GUI
local function findGuiScripts()
    print("🔍 Ищу скрипты в GUI...")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return {} end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return {} end
    
    local scripts = {}
    
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("LocalScript") or desc:IsA("Script") then
            table.insert(scripts, {
                name = desc.Name,
                path = desc:GetFullName(),
                element = desc
            })
            print("📜 Скрипт: " .. desc.Name .. " (" .. desc:GetFullName() .. ")")
        end
    end
    
    return scripts
end

-- Функция анализа подключений к кнопкам
local function analyzeButtonConnections()
    print("🔍 Анализирую подключения к кнопкам инвентаря...")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return end
    
    -- Ищем все TextButton'ы
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("TextButton") then
            -- Проверяем, есть ли подключения
            local connections = getconnections and getconnections(desc.MouseButton1Click) or {}
            
            if #connections > 0 then
                print("🔗 Кнопка " .. desc.Name .. " имеет " .. #connections .. " подключений")
                
                -- Пытаемся получить информацию о функциях
                for i, connection in pairs(connections) do
                    if connection.Function then
                        print("   📋 Подключение " .. i .. ": функция найдена")
                        
                        -- Пытаемся вызвать функцию (осторожно!)
                        local success, result = pcall(function()
                            return tostring(connection.Function)
                        end)
                        
                        if success then
                            print("   📝 Функция: " .. result)
                        end
                    end
                end
            end
        end
    end
end

-- Функция мониторинга событий
local function monitorEvents(events)
    print("🔍 Мониторю события (нажмите любую кнопку инвентаря)...")
    
    local connections = {}
    
    for _, eventInfo in pairs(events) do
        local connection = eventInfo.element.OnClientEvent:Connect(function(...)
            local args = {...}
            print("📡 Событие " .. eventInfo.name .. " вызвано с аргументами:")
            for i, arg in pairs(args) do
                print("   Аргумент " .. i .. ": " .. tostring(arg))
            end
        end)
        
        table.insert(connections, connection)
    end
    
    -- Отключаем мониторинг через 30 секунд
    spawn(function()
        wait(30)
        print("⏰ Мониторинг событий завершен")
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
    end)
end

-- Выполняем анализ
print("")
local remoteEvents = findRemoteEvents()

print("")
local remoteFunctions = findRemoteFunctions()

print("")
local guiScripts = findGuiScripts()

print("")
analyzeButtonConnections()

print("")
print("🎯 РЕЗУЛЬТАТЫ АНАЛИЗА:")
print("Найдено RemoteEvent'ов: " .. #remoteEvents)
print("Найдено RemoteFunction'ов: " .. #remoteFunctions)
print("Найдено скриптов в GUI: " .. #guiScripts)

-- Ищем события, связанные с инвентарем
print("")
print("🔍 События, связанные с инвентарем:")
for _, eventInfo in pairs(remoteEvents) do
    local name = eventInfo.name:lower()
    if name:find("inventory") or name:find("pet") or name:find("equip") or name:find("move") or name:find("swap") then
        print("⭐ ВОЗМОЖНОЕ СОБЫТИЕ: " .. eventInfo.name .. " (" .. eventInfo.path .. ")")
    end
end

for _, funcInfo in pairs(remoteFunctions) do
    local name = funcInfo.name:lower()
    if name:find("inventory") or name:find("pet") or name:find("equip") or name:find("move") or name:find("swap") then
        print("⭐ ВОЗМОЖНАЯ ФУНКЦИЯ: " .. funcInfo.name .. " (" .. funcInfo.path .. ")")
    end
end

-- Запускаем мониторинг
if #remoteEvents > 0 then
    print("")
    print("🎯 Запускаю мониторинг событий на 30 секунд...")
    print("💡 Попробуйте переместить питомца вручную для анализа!")
    monitorEvents(remoteEvents)
end

print("=== АНАЛИЗ ЗАВЕРШЕН ===")
