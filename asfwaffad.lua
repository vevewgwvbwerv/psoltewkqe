-- PET CREATION LOGGER ULTIMATE
-- Логирует все обращения к игровым сервисам при создании питомцев
-- Отслеживает: модели, инвентарь, AI, анимации, размеры

local PetLogger = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local originalFunctions = {}
local logBuffer = {}
local isLogging = true

-- Цвета для консоли
local COLORS = {
    MODEL = "\27[32m",      -- Зеленый для моделей
    INVENTORY = "\27[33m",  -- Желтый для инвентаря  
    AI = "\27[35m",         -- Пурпурный для AI
    ANIMATION = "\27[36m",  -- Циан для анимаций
    SIZE = "\27[31m",       -- Красный для размеров
    NETWORK = "\27[34m",    -- Синий для сети
    RESET = "\27[0m"        -- Сброс цвета
}

-- Функция логирования с временной меткой
local function log(category, message, data)
    if not isLogging then return end
    
    local timestamp = os.date("%H:%M:%S")
    local color = COLORS[category] or COLORS.RESET
    local logEntry = string.format("[%s] %s%s: %s%s", 
        timestamp, color, category, message, COLORS.RESET)
    
    print(logEntry)
    
    if data then
        print("  Data:", HttpService:JSONEncode(data))
    end
    
    table.insert(logBuffer, {
        timestamp = timestamp,
        category = category,
        message = message,
        data = data
    })
end

-- Перехват создания Instance
local originalInstanceNew = Instance.new
Instance.new = function(className, parent)
    local instance = originalInstanceNew(className, parent)
    
    -- Логируем создание моделей питомцев
    if className == "Model" or className == "Part" or className == "MeshPart" then
        log("MODEL", "Created " .. className, {
            className = className,
            parent = parent and parent.Name or "nil",
            name = instance.Name
        })
    end
    
    -- Логируем создание анимаций
    if className == "Animation" or className == "AnimationController" or className == "Humanoid" then
        log("ANIMATION", "Created " .. className, {
            className = className,
            parent = parent and parent.Name or "nil"
        })
    end
    
    return instance
end

-- Перехват клонирования
local function hookClone(obj)
    local originalClone = obj.Clone
    obj.Clone = function(self)
        local cloned = originalClone(self)
        log("MODEL", "Cloned object: " .. self.Name, {
            originalName = self.Name,
            clonedName = cloned.Name,
            className = self.ClassName
        })
        return cloned
    end
end

-- Перехват изменений Parent (добавление в инвентарь/workspace)
local function hookParentChange(obj)
    obj:GetPropertyChangedSignal("Parent"):Connect(function()
        local newParent = obj.Parent
        if newParent then
            -- Проверяем добавление в backpack
            if newParent.Name == "Backpack" or newParent:IsA("Backpack") then
                log("INVENTORY", "Added to Backpack: " .. obj.Name, {
                    itemName = obj.Name,
                    itemType = obj.ClassName
                })
            end
            
            -- Проверяем добавление в workspace (питомец поставлен)
            if newParent == Workspace or newParent.Parent == Workspace then
                log("AI", "Pet placed in world: " .. obj.Name, {
                    petName = obj.Name,
                    position = obj:IsA("BasePart") and obj.Position or "N/A"
                })
            end
        end
    end)
end

-- Перехват изменений размера
local function hookSizeChange(obj)
    if obj:IsA("BasePart") then
        obj:GetPropertyChangedSignal("Size"):Connect(function()
            log("SIZE", "Size changed for: " .. obj.Name, {
                objectName = obj.Name,
                newSize = obj.Size,
                volume = obj.Size.X * obj.Size.Y * obj.Size.Z
            })
        end)
    end
end

-- Перехват анимаций
local function hookAnimations(humanoid)
    if humanoid:IsA("Humanoid") then
        humanoid.AnimationPlayed:Connect(function(animationTrack)
            log("ANIMATION", "Animation played", {
                animationId = animationTrack.Animation.AnimationId,
                humanoidParent = humanoid.Parent.Name,
                length = animationTrack.Length,
                priority = animationTrack.Priority.Name
            })
        end)
    end
end

-- Перехват PathfindingService (для AI движения)
local originalCreatePath = PathfindingService.CreatePath
PathfindingService.CreatePath = function(self, ...)
    local path = originalCreatePath(self, ...)
    log("AI", "Pathfinding path created", {
        agentRadius = path.AgentRadius,
        agentHeight = path.AgentHeight
    })
    return path
end

-- Перехват TweenService (для анимации движения)
local originalTweenCreate = TweenService.Create
TweenService.Create = function(self, instance, tweenInfo, propertyTable)
    local tween = originalTweenCreate(self, instance, tweenInfo, propertyTable)
    
    if instance.Parent and (instance.Parent.Name:find("Pet") or instance.Parent.Name:find("pet")) then
        log("AI", "Tween created for pet movement", {
            targetObject = instance.Name,
            parentName = instance.Parent.Name,
            duration = tweenInfo.Time,
            properties = propertyTable
        })
    end
    
    return tween
end

-- Перехват RemoteEvents/RemoteFunctions (сетевые запросы)
local function hookRemotes()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            obj.OnClientEvent:Connect(function(...)
                local args = {...}
                log("NETWORK", "RemoteEvent fired: " .. obj.Name, {
                    eventName = obj.Name,
                    arguments = args
                })
            end)
        elseif obj:IsA("RemoteFunction") then
            local originalInvoke = obj.InvokeServer
            obj.InvokeServer = function(self, ...)
                local args = {...}
                log("NETWORK", "RemoteFunction invoked: " .. obj.Name, {
                    functionName = obj.Name,
                    arguments = args
                })
                return originalInvoke(self, ...)
            end
        end
    end
end

-- Мониторинг добавления новых объектов
local function monitorNewObjects(parent)
    parent.ChildAdded:Connect(function(child)
        -- Проверяем на питомцев
        if child.Name:lower():find("pet") or child.Name:lower():find("egg") then
            log("MODEL", "Potential pet object added: " .. child.Name, {
                objectName = child.Name,
                className = child.ClassName,
                parent = parent.Name
            })
            
            -- Устанавливаем хуки на новый объект
            hookParentChange(child)
            if child:IsA("BasePart") then
                hookSizeChange(child)
            end
            
            -- Ищем Humanoid для анимаций
            child.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Humanoid") then
                    hookAnimations(descendant)
                    log("AI", "Humanoid added to pet", {
                        petName = child.Name,
                        humanoidParent = descendant.Parent.Name
                    })
                end
            end)
        end
        
        -- Рекурсивно мониторим новые контейнеры
        if child:IsA("Folder") or child:IsA("Model") then
            monitorNewObjects(child)
        end
    end)
end

-- Инициализация логгера
function PetLogger.init()
    print(COLORS.MODEL .. "=== PET CREATION LOGGER ULTIMATE STARTED ===" .. COLORS.RESET)
    
    -- Устанавливаем хуки на существующие объекты
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            hookClone(obj)
            hookParentChange(obj)
            if obj:IsA("BasePart") then
                hookSizeChange(obj)
            end
        elseif obj:IsA("Humanoid") then
            hookAnimations(obj)
        end
    end
    
    -- Мониторим новые объекты
    monitorNewObjects(Workspace)
    monitorNewObjects(player.Backpack)
    if player.Character then
        monitorNewObjects(player.Character)
    end
    
    -- Мониторим появление персонажа
    player.CharacterAdded:Connect(function(character)
        monitorNewObjects(character)
    end)
    
    -- Устанавливаем хуки на RemoteEvents
    hookRemotes()
    
    -- Мониторим новые RemoteEvents
    ReplicatedStorage.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            wait(0.1) -- Небольшая задержка для инициализации
            hookRemotes()
        end
    end)
    
    log("MODEL", "Logger initialized successfully", {
        player = player.Name,
        workspace_objects = #Workspace:GetDescendants()
    })
end

-- Функции управления логгером
function PetLogger.start()
    isLogging = true
    log("MODEL", "Logging started", {})
end

function PetLogger.stop()
    isLogging = false
    print(COLORS.MODEL .. "Logging stopped" .. COLORS.RESET)
end

function PetLogger.clear()
    logBuffer = {}
    print(COLORS.MODEL .. "Log buffer cleared" .. COLORS.RESET)
end

function PetLogger.export()
    local exportData = {
        session_info = {
            player = player.Name,
            timestamp = os.date(),
            total_logs = #logBuffer
        },
        logs = logBuffer
    }
    
    local jsonData = HttpService:JSONEncode(exportData)
    print(COLORS.NETWORK .. "=== EXPORTED LOG DATA ===" .. COLORS.RESET)
    print(jsonData)
    return jsonData
end

-- Команды в чате
player.Chatted:Connect(function(message)
    local cmd = message:lower()
    if cmd == "/petlog start" then
        PetLogger.start()
    elseif cmd == "/petlog stop" then
        PetLogger.stop()
    elseif cmd == "/petlog clear" then
        PetLogger.clear()
    elseif cmd == "/petlog export" then
        PetLogger.export()
    elseif cmd == "/petlog help" then
        print(COLORS.MODEL .. "Pet Logger Commands:" .. COLORS.RESET)
        print("  /petlog start  - Start logging")
        print("  /petlog stop   - Stop logging") 
        print("  /petlog clear  - Clear log buffer")
        print("  /petlog export - Export logs as JSON")
    end
end)

-- Автозапуск
PetLogger.init()

return PetLogger
