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
    hookPetCreation()
end

function hookGameServices()
    logger.log("Установка хуков на игровые сервисы")
    
    -- Хук на ReplicatedStorage для отслеживания доступа к моделям питомцев
    local rs = game:GetService("ReplicatedStorage")
    local old_FindFirstChild = rs.FindFirstChild
    
    rs.FindFirstChild = function(self, name, recursive)
        if name and (string.find(name:lower(), "pet") or string.find(name:lower(), "anim")) then
            logger.log("Поиск модели питомца в ReplicatedStorage", {name = name, recursive = tostring(recursive)})
        end
        return old_FindFirstChild(self, name, recursive)
    end
    
    logger.log("Хуки установлены на ReplicatedStorage")
end

function hookReplication()
    logger.log("Установка хуков на репликацию")
    
    -- Хук на добавление объектов в Workspace
    local ws = game:GetService("Workspace")
    local old_ws_FindFirstChild = ws.FindFirstChild
    
    ws.FindFirstChild = function(self, name, recursive)
        if name and (string.find(name:lower(), "pet") or string.find(name:lower(), "character")) then
            logger.log("Поиск в Workspace", {name = name, recursive = tostring(recursive)})
        end
        return old_ws_FindFirstChild(self, name, recursive)
    end
    
    -- Хук на добавление в Workspace
    ws.ChildAdded:Connect(function(child)
        if child.ClassName == "Model" and (string.find(child.Name:lower(), "pet") or 
           string.find(child.Name:lower(), "creature") or string.find(child.Name:lower(), "npc")) then
            logger.log("Добавлена модель в Workspace", {
                name = child.Name,
                className = child.ClassName,
                childrenCount = #child:GetChildren(),
                parent = tostring(child.Parent)
            })
            
            -- Логируем структуру модели
            logModelStructure(child)
        end
    end)
    
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
    
    -- Хук на создание Humanoid
    local old_Instance_new = Instance.new
    
    Instance.new = function(className, parent)
        if className == "Humanoid" or className == "Animator" or className == "Motor6D" then
            logger.log("Создание системы персонажа", {
                class = className,
                parent = parent and tostring(parent) or "nil"
            })
        end
        return old_Instance_new(className, parent)
    end
    
    -- Хук на AnimationController
    local old_LoadAnimation = nil
    pcall(function()
        local animator = Instance.new("Animator")
        old_LoadAnimation = animator.LoadAnimation
        
        animator.LoadAnimation = function(self, animation)
            logger.log("Загрузка анимации", {
                animationId = animation and animation.AnimationId or "unknown",
                parent = tostring(self)
            })
            return old_LoadAnimation(self, animation)
        end
    end)
    
    logger.log("Хуки на системы персонажей установлены")
end

function hookPetCreation()
    logger.log("Установка специализированных хуков для создания питомцев")
    
    -- Хук на Clone для отслеживания копирования моделей
    local old_Clone = nil
    pcall(function()
        local model = Instance.new("Model")
        old_Clone = model.Clone
        
        model.Clone = function(self)
            if string.find(self.Name:lower(), "pet") or string.find(self.Name:lower(), "creature") then
                logger.log("Клонирование модели питомца", {
                    originalName = self.Name,
                    parent = tostring(self.Parent)
                })
            end
            return old_Clone(self)
        end
    end)
    
    -- Хук на SetProperty для отслеживания изменения свойств
    local mt = getrawmetatable(game)
    if mt then
        local old_NewIndex = mt.__newindex
        
        mt.__newindex = function(t, k, v)
            if typeof(t) == "Instance" and k == "Size" and typeof(v) == "Vector3" then
                if string.find(t.Name:lower(), "body") or string.find(t.Name:lower(), "torso") then
                    logger.log("Изменение размера тела питомца", {
                        object = tostring(t),
                        newSize = tostring(v),
                        oldSize = tostring(t.Size)
                    })
                end
            end
            return old_NewIndex(t, k, v)
        end
    end
end

function logModelStructure(model)
    logger.log("Анализ структуры модели питомца: " .. model.Name)
    
    -- Логируем основные компоненты
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChild("Animator")
    local animationController = model:FindFirstChild("AnimationController")
    
    if humanoid then
        logger.log("Найден Humanoid", {
            health = humanoid.Health,
            maxHealth = humanoid.MaxHealth,
            walkSpeed = humanoid.WalkSpeed
        })
    end
    
    if animator then
        logger.log("Найден Animator")
    end
    
    if animationController then
        logger.log("Найден AnimationController")
    end
    
    -- Логируем части тела
    local bodyParts = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    for _, partName in ipairs(bodyParts) do
        local part = model:FindFirstChild(partName)
        if part then
            logger.log("Найдена часть тела", {
                part = partName,
                size = tostring(part.Size),
                material = tostring(part.Material)
            })
        end
    end
end

function logger.exportLogs()
    logger.log("Экспорт логов")
    
    local logText = "=== Pet Behavior Analyzer Logs ===\n"
    logText = logText .. "Всего записей: " .. #logger.logs .. "\n\n"
    
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

function logger.clearLogs()
    logger.logs = {}
    logger.log("Логи очищены")
end

-- Запуск логгера
logger.start()

-- Команды для управления
getgenv().petLogger = logger

warn("[PET_ANALYZER] Система анализа поведения питомцев запущена!")
warn("[PET_ANALYZER] Используйте petLogger.exportLogs() для экспорта логов")
warn("[PET_ANALYZER] Используйте petLogger.clearLogs() для очистки логов")
warn("[PET_ANALYZER] Используйте petLogger.enabled = false для отключения")
