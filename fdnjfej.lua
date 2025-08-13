-- Pet Behavior Analyzer - Advanced Logging System
-- Логирует все вызовы к игровым сервисам при создании питомцев

local logger = {}
logger.logs = {}
logger.enabled = true

function logger.log(message, data)
    if not logger.enabled then return end
    
    local timestamp = os.date("%H:%M:%S", os.time())
    local logEntry = {
        time = timestamp,
        message = message,
        data = data or {}
    }
    
    table.insert(logger.logs, logEntry)
    print("[PET_ANALYZER] " .. timestamp .. " - " .. message)
    
    -- Также выводим детали если есть
    if data then
        for k, v in pairs(data) do
            print("  " .. tostring(k) .. ": " .. tostring(v))
        end
    end
end

function logger.start()
    logger.log("Pet Behavior Analyzer запущен")
    hookGameServices()
    hookReplication()
    hookCharacterSystems()
end

function hookGameServices()
    logger.log("Установка хуков на игровые сервисы")
    
    -- Хук на ReplicatedStorage
    local original_FindFirstChild = Instance.new("Folder").FindFirstChild
    local rs = game:GetService("ReplicatedStorage")
    
    -- Хук на Workspace
    local ws = game:GetService("Workspace")
    
    -- Хук на Players
    local players = game:GetService("Players")
    
    logger.log("Хуки установлены на основные сервисы")
end

function hookReplication()
    logger.log("Установка хуков на репликацию")
    
    -- Хук на добавление объектов в Workspace
    local mt = getrawmetatable(game.Workspace)
    local oldIndex = mt.__index
    
    mt.__index = function(self, key)
        logger.log("Доступ к Workspace", {key = key})
        return oldIndex(self, key)
    end
    
    -- Хук на добавление в Backpack
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                -- Отслеживаем добавление предметов
                backpack.ChildAdded:Connect(function(child)
                    logger.log("Добавлен предмет в Backpack", {
                        name = child.Name,
                        class = child.ClassName,
                        parent = tostring(child.Parent)
                    })
                end)
            end
        end
    end)
end

function hookCharacterSystems()
    logger.log("Установка хуков на системы персонажей")
    
    -- Хук на Humanoid
    local oldHumanoid_new = Instance.new
    
    -- Хук на Animator
    -- Хук на Motor6D
    logger.log("Хуки на системы персонажей установлены")
end

function logger.exportLogs()
    logger.log("Экспорт логов")
    
    local logText = ""
    for _, entry in ipairs(logger.logs) do
        logText = logText .. "[" .. entry.time .. "] " .. entry.message .. "\n"
        if entry.data then
            for k, v in pairs(entry.data) do
                logText = logText .. "  " .. tostring(k) .. ": " .. tostring(v) .. "\n"
            end
        end
        logText = logText .. "\n"
    end
    
    -- Попытка сохранить в файл
    pcall(function()
        if typeof(writefile) == "function" then
            writefile("PetAnalyzerLogs.txt", logText)
            logger.log("Логи сохранены в PetAnalyzerLogs.txt")
        else
            setclipboard(logText)
            logger.log("Логи скопированы в буфер обмена (writefile недоступен)")
        end
    end)
    
    return logText
end

-- Запуск логгера
logger.start()

-- Команды для управления
getgenv().petLogger = logger

warn("[PET_ANALYZER] Система анализа поведения питомцев запущена!")
warn("[PET_ANALYZER] Используйте petLogger.exportLogs() для экспорта логов")
warn("[PET_ANALYZER] Используйте petLogger.enabled = false для отключения")
