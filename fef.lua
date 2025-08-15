-- === PET ANALYZER WITH WINDUI ===
-- Made by Assistant | Styled after DONCALDERONE

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- === КОНФИГУРАЦИЯ ===

local CONFIG = {
    SEARCH_RADIUS = 100,
    MAX_ANALYZED_PETS = 10
}

-- === СЕРВИСЫ ===

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerPos = player.Character and player.Character.HumanoidRootPart and player.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)

-- === ПЕРЕМЕННЫЕ ===

local analyzedPets = {}
local currentAnalysis = nil
local currentHandAnalysis = nil

-- === ФУНКЦИИ ПОИСКА UUID ПИТОМЦЕВ ===

-- Функция проверки визуальных элементов питомца
local function hasPetVisuals(model)
    local visualCount = 0
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            visualCount = visualCount + 1
        elseif obj:IsA("Part") then
            local hasDecal = obj:FindFirstChildOfClass("Decal")
            local hasTexture = obj:FindFirstChildOfClass("Texture")
            if hasDecal or hasTexture or obj.Material ~= Enum.Material.Plastic then
                visualCount = visualCount + 1
            end
        elseif obj:IsA("UnionOperation") then
            visualCount = visualCount + 1
        end
    end
    
    if visualCount == 0 then
        local partCount = 0
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                partCount = partCount + 1
            end
        end
        if partCount >= 2 then
            visualCount = partCount
        end
    end
    
    return visualCount > 0
end

-- Функция проверки UUID формата
local function isUUIDFormat(name)
    return string.match(name, "%{[%w%-]+%}") ~= nil
end

-- Функция поиска ближайшего UUID питомца (СКОПИРОВАНО ИЗ ОРИГИНАЛА)
local function findClosestUUIDPet()
    print("🔍 Поиск UUID моделей питомцев...")
    
    local playerChar = player.Character
    if not playerChar then
        return nil
    end

    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil
    end

    local playerPos = hrp.Position
    local foundPets = {}
    
    -- ТОЧНАЯ КОПИЯ ЛОГИКИ ИЗ ОРИГИНАЛЬНОГО PetAnalyzer.lua
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= CONFIG.SEARCH_RADIUS then
                    if hasPetVisuals(obj) then
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance
                        })
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ UUID питомцы не найдены в радиусе", CONFIG.SEARCH_RADIUS, "стадов")
        return nil
    end
    
    -- Сортируем по расстоянию и берем ближайшего
    table.sort(foundPets, function(a, b) return a.distance < b.distance end)
    local closestPet = foundPets[1]
    
    print("🎯 Найден ближайший UUID питомец:", closestPet.model.Name, "на расстоянии", math.floor(closestPet.distance), "стадов")
    
    return closestPet.model
end

-- === ФУНКЦИИ АНАЛИЗА TOOL В РУКЕ ===

-- Функция поиска tool в руке игрока
local function findHandTool()
    local playerChar = player.Character
    if not playerChar then
        return nil
    end
    
    -- Проверяем tool в руке
    local tool = playerChar:FindFirstChildOfClass("Tool")
    if tool then
        print("🔧 Найден tool в руке:", tool.Name)
        return tool
    end
    
    print("❌ Tool в руке не найден")
    return nil
end

-- Функция глубокого анализа tool
local function analyzeHandTool(tool)
    print("🔬 Анализирую tool:", tool.Name)
    
    local analysis = {
        toolName = tool.Name,
        toolType = tool.ClassName,
        enabled = tool.Enabled,
        canBeDropped = tool.CanBeDropped,
        requiresHandle = tool.RequiresHandle,
        manualActivationOnly = tool.ManualActivationOnly,
        
        -- Счетчики
        meshCount = 0,
        motor6dCount = 0,
        humanoidCount = 0,
        partCount = 0,
        attachmentCount = 0,
        scriptCount = 0,
        animationCount = 0,
        soundCount = 0,
        guiCount = 0,
        effectCount = 0,
        lightCount = 0,
        
        -- Детальные массивы
        meshes = {},
        motor6ds = {},
        humanoids = {},
        parts = {},
        attachments = {},
        scripts = {},
        animations = {},
        sounds = {},
        guis = {},
        effects = {},
        lights = {},
        
        -- Handle информация
        handle = nil,
        handleSize = nil,
        handlePosition = nil,
        handleCFrame = nil
    }
    
    -- Анализ Handle
    local handle = tool:FindFirstChild("Handle")
    if handle then
        analysis.handle = {
            name = handle.Name,
            type = handle.ClassName,
            size = handle.Size,
            position = handle.Position,
            cframe = handle.CFrame,
            material = handle.Material.Name,
            color = handle.Color,
            transparency = handle.Transparency,
            canCollide = handle.CanCollide,
            brickColor = handle.BrickColor.Name,
            reflectance = handle.Reflectance
        }
        analysis.handleSize = handle.Size
        analysis.handlePosition = handle.Position
        analysis.handleCFrame = handle.CFrame
    end
    
    -- Анализ всех потомков tool
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            analysis.meshCount = analysis.meshCount + 1
            local meshInfo = {
                name = obj.Name,
                type = obj.ClassName,
                parent = obj.Parent.Name
            }
            if obj:IsA("MeshPart") then
                meshInfo.meshId = obj.MeshId
                meshInfo.textureId = obj.TextureID
            elseif obj:IsA("SpecialMesh") then
                meshInfo.meshId = obj.MeshId
                meshInfo.textureId = obj.TextureId
                meshInfo.meshType = obj.MeshType.Name
                meshInfo.scale = obj.Scale
            end
            table.insert(analysis.meshes, meshInfo)
            
        -- Добавляем анализ Motor6D с анимационными данными
        elseif obj:IsA("Motor6D") then
            analysis.motor6dCount = analysis.motor6dCount + 1
            print("🔧 Found Motor6D:", obj.Name, "C0:", obj.C0, "C1:", obj.C1, "Transform:", obj.Transform)
            table.insert(analysis.motor6ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "None",
                part1 = obj.Part1 and obj.Part1.Name or "None",
                c0 = obj.C0,
                c1 = obj.C1,
                transform = obj.Transform,
                currentAngle = obj.CurrentAngle or 0,
                desiredAngle = obj.DesiredAngle or 0,
                maxVelocity = obj.MaxVelocity or 0
            })
            
        elseif obj:IsA("Humanoid") then
            analysis.humanoidCount = analysis.humanoidCount + 1
            table.insert(analysis.humanoids, {
                name = obj.Name,
                health = obj.Health,
                maxHealth = obj.MaxHealth,
                walkSpeed = obj.WalkSpeed,
                jumpPower = obj.JumpPower,
                displayName = obj.DisplayName
            })
            
        elseif obj:IsA("BasePart") then
            analysis.partCount = analysis.partCount + 1
            -- Вычисляем относительный CFrame относительно PrimaryPart или Handle
            local relativeCFrame = obj.CFrame
            if tool.Handle and tool.Handle ~= obj then
                relativeCFrame = tool.Handle.CFrame:Inverse() * obj.CFrame
            end
            
            table.insert(analysis.parts, {
                name = obj.Name,
                type = obj.ClassName,
                size = obj.Size,
                material = obj.Material.Name,
                color = obj.Color,
                brickColor = obj.BrickColor.Name,
                transparency = obj.Transparency,
                canCollide = obj.CanCollide,
                position = obj.Position,
                rotation = obj.Rotation,
                cframe = obj.CFrame,
                relativeCFrame = relativeCFrame,
                reflectance = obj.Reflectance,
                shape = obj.Shape and obj.Shape.Name or "Block"
            })
            
        elseif obj:IsA("Attachment") then
            analysis.attachmentCount = analysis.attachmentCount + 1
            table.insert(analysis.attachments, {
                name = obj.Name,
                parent = obj.Parent.Name,
                position = obj.Position,
                cframe = obj.CFrame,
                worldPosition = obj.WorldPosition,
                worldCFrame = obj.WorldCFrame
            })
            
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            analysis.scriptCount = analysis.scriptCount + 1
            table.insert(analysis.scripts, {
                name = obj.Name,
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled,
                source = obj.Source and string.len(obj.Source) or 0
            })
            
        elseif obj:IsA("Animation") then
            analysis.animationCount = analysis.animationCount + 1
            table.insert(analysis.animations, {
                name = obj.Name,
                animationId = obj.AnimationId,
                parent = obj.Parent.Name
            })
            
        elseif obj:IsA("Sound") then
            analysis.soundCount = analysis.soundCount + 1
            table.insert(analysis.sounds, {
                name = obj.Name,
                soundId = obj.SoundId,
                volume = obj.Volume,
                pitch = obj.Pitch,
                isLooped = obj.Looped,
                isPlaying = obj.IsPlaying,
                parent = obj.Parent.Name
            })
            
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("ScreenGui") then
            analysis.guiCount = analysis.guiCount + 1
            table.insert(analysis.guis, {
                name = obj.Name,
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled
            })
            
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            analysis.effectCount = analysis.effectCount + 1
            table.insert(analysis.effects, {
                name = obj.Name,
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled
            })
            
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            analysis.lightCount = analysis.lightCount + 1
            table.insert(analysis.lights, {
                name = obj.Name,
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled,
                brightness = obj.Brightness,
                color = obj.Color,
                range = obj.Range
            })
        end
    end
    
    return analysis
end

-- Функция генерации детального текста для tool
local function generateHandToolDetailText(analysis)
    local text = string.format([[%s_TOOL = {
    ["ToolName"] = "%s",
    ["ToolType"] = "%s",
    ["Enabled"] = %s,
    ["CanBeDropped"] = %s,
    ["RequiresHandle"] = %s,
    ["ManualActivationOnly"] = %s,
    
    ["TotalParts"] = %d,
    ["TotalMeshes"] = %d,
    ["TotalMotor6D"] = %d,
    ["TotalHumanoids"] = %d,
    ["TotalAttachments"] = %d,
    ["TotalScripts"] = %d,
    ["TotalAnimations"] = %d,
    ["TotalSounds"] = %d,
    ["TotalGUIs"] = %d,
    ["TotalEffects"] = %d,
    ["TotalLights"] = %d,]], 
        analysis.toolName,
        analysis.toolName,
        analysis.toolType,
        tostring(analysis.enabled),
        tostring(analysis.canBeDropped),
        tostring(analysis.requiresHandle),
        tostring(analysis.manualActivationOnly),
        analysis.partCount,
        analysis.meshCount,
        analysis.motor6dCount,
        analysis.humanoidCount,
        analysis.attachmentCount,
        analysis.scriptCount,
        analysis.animationCount,
        analysis.soundCount,
        analysis.guiCount,
        analysis.effectCount,
        analysis.lightCount
    )
    
    -- Handle информация
    if analysis.handle then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = analysis.handle.cframe:GetComponents()
        text = text .. string.format([[
    
    ["Handle"] = {
        name = "%s",
        type = "%s",
        size = Vector3.new(%.2f, %.2f, %.2f),
        position = Vector3.new(%.2f, %.2f, %.2f),
        cframe = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
        material = "%s",
        color = Color3.new(%.3f, %.3f, %.3f),
        brickColor = "%s",
        transparency = %.2f,
        canCollide = %s,
        reflectance = %.2f
    },]], 
            analysis.handle.name,
            analysis.handle.type,
            analysis.handle.size.X, analysis.handle.size.Y, analysis.handle.size.Z,
            analysis.handle.position.X, analysis.handle.position.Y, analysis.handle.position.Z,
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22,
            analysis.handle.material,
            analysis.handle.color.R, analysis.handle.color.G, analysis.handle.color.B,
            analysis.handle.brickColor,
            analysis.handle.transparency,
            tostring(analysis.handle.canCollide),
            analysis.handle.reflectance)
    end
    
    -- Добавление мешей
    if #analysis.meshes > 0 then
        text = text .. '\n\n    ["Meshes"] = {'
        for i, mesh in ipairs(analysis.meshes) do
            text = text .. string.format([[
        [%d] = {name = "%s", type = "%s", parent = "%s", meshId = "%s", textureId = "%s"}]], 
                i, mesh.name, mesh.type, mesh.parent, mesh.meshId or "", mesh.textureId or "")
            if i < #analysis.meshes then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    -- Добавление Motor6D с анимационными данными
    if #analysis.motor6ds > 0 then
        text = text .. '\n\n    ["Motor6D"] = {'
        for i, motor in ipairs(analysis.motor6ds) do
            print("🔧 Processing Motor6D in text generation:", motor.name, "has C0:", motor.c0 ~= nil, "has C1:", motor.c1 ~= nil, "has Transform:", motor.transform ~= nil)
            
            -- Безопасное получение компонентов CFrame
            local c0x, c0y, c0z, c0r00, c0r01, c0r02, c0r10, c0r11, c0r12, c0r20, c0r21, c0r22 = 0,0,0,1,0,0,0,1,0,0,0,1
            local c1x, c1y, c1z, c1r00, c1r01, c1r02, c1r10, c1r11, c1r12, c1r20, c1r21, c1r22 = 0,0,0,1,0,0,0,1,0,0,0,1
            local tx, ty, tz, tr00, tr01, tr02, tr10, tr11, tr12, tr20, tr21, tr22 = 0,0,0,1,0,0,0,1,0,0,0,1
            
            if motor.c0 then
                c0x, c0y, c0z, c0r00, c0r01, c0r02, c0r10, c0r11, c0r12, c0r20, c0r21, c0r22 = motor.c0:GetComponents()
            end
            if motor.c1 then
                c1x, c1y, c1z, c1r00, c1r01, c1r02, c1r10, c1r11, c1r12, c1r20, c1r21, c1r22 = motor.c1:GetComponents()
            end
            if motor.transform then
                tx, ty, tz, tr00, tr01, tr02, tr10, tr11, tr12, tr20, tr21, tr22 = motor.transform:GetComponents()
            end
            
            text = text .. string.format([[
        [%d] = {
            name = "%s", 
            part0 = "%s", 
            part1 = "%s",
            c0 = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            c1 = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            transform = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            currentAngle = %.3f,
            desiredAngle = %.3f,
            maxVelocity = %.3f
        }]], 
                i, motor.name, motor.part0, motor.part1,
                c0x, c0y, c0z, c0r00, c0r01, c0r02, c0r10, c0r11, c0r12, c0r20, c0r21, c0r22,
                c1x, c1y, c1z, c1r00, c1r01, c1r02, c1r10, c1r11, c1r12, c1r20, c1r21, c1r22,
                tx, ty, tz, tr00, tr01, tr02, tr10, tr11, tr12, tr20, tr21, tr22,
                motor.currentAngle, motor.desiredAngle, motor.maxVelocity)
            if i < #analysis.motor6ds then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    -- Добавление частей с полной CFrame информацией
    if #analysis.parts > 0 then
        text = text .. '\n\n    ["Parts"] = {'
        for i, part in ipairs(analysis.parts) do
            local px, py, pz, pr00, pr01, pr02, pr10, pr11, pr12, pr20, pr21, pr22 = part.cframe:GetComponents()
            local rx, ry, rz, rr00, rr01, rr02, rr10, rr11, rr12, rr20, rr21, rr22 = part.relativeCFrame:GetComponents()
            text = text .. string.format([[
        [%d] = {
            name = "%s", 
            type = "%s", 
            size = Vector3.new(%.2f, %.2f, %.2f), 
            material = "%s",
            color = Color3.new(%.3f, %.3f, %.3f),
            brickColor = "%s",
            transparency = %.2f,
            canCollide = %s,
            position = Vector3.new(%.2f, %.2f, %.2f),
            rotation = Vector3.new(%.2f, %.2f, %.2f),
            cframe = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            relativeCFrame = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            reflectance = %.2f,
            shape = "%s"
        }]], 
                i, part.name, part.type, 
                part.size.X, part.size.Y, part.size.Z, 
                part.material,
                part.color.R, part.color.G, part.color.B,
                part.brickColor,
                part.transparency,
                tostring(part.canCollide),
                part.position.X, part.position.Y, part.position.Z,
                part.rotation.X, part.rotation.Y, part.rotation.Z,
                px, py, pz, pr00, pr01, pr02, pr10, pr11, pr12, pr20, pr21, pr22,
                rx, ry, rz, rr00, rr01, rr02, rr10, rr11, rr12, rr20, rr21, rr22,
                part.reflectance,
                part.shape)
            if i < #analysis.parts then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    -- Добавление анимаций
    if #analysis.animations > 0 then
        text = text .. '\n\n    ["Animations"] = {'
        for i, anim in ipairs(analysis.animations) do
            text = text .. string.format([[
        [%d] = {name = "%s", animationId = "%s", parent = "%s"}]], 
                i, anim.name, anim.animationId, anim.parent)
            if i < #analysis.animations then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    -- Добавление звуков
    if #analysis.sounds > 0 then
        text = text .. '\n\n    ["Sounds"] = {'
        for i, sound in ipairs(analysis.sounds) do
            text = text .. string.format([[
        [%d] = {name = "%s", soundId = "%s", volume = %.2f, pitch = %.2f, looped = %s, playing = %s, parent = "%s"}]], 
                i, sound.name, sound.soundId, sound.volume, sound.pitch, tostring(sound.isLooped), tostring(sound.isPlaying), sound.parent)
            if i < #analysis.sounds then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    -- Добавление остальных элементов (только если есть)
    if #analysis.attachments > 0 then
        text = text .. '\n\n    ["Attachments"] = {'
        for i, attachment in ipairs(analysis.attachments) do
            text = text .. string.format([[
        [%d] = {name = "%s", parent = "%s", position = Vector3.new(%.2f, %.2f, %.2f), worldPosition = Vector3.new(%.2f, %.2f, %.2f)}]], 
                i, attachment.name, attachment.parent, 
                attachment.position.X, attachment.position.Y, attachment.position.Z,
                attachment.worldPosition.X, attachment.worldPosition.Y, attachment.worldPosition.Z)
            if i < #analysis.attachments then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    if #analysis.scripts > 0 then
        text = text .. '\n\n    ["Scripts"] = {'
        for i, script in ipairs(analysis.scripts) do
            text = text .. string.format([[
        [%d] = {name = "%s", type = "%s", parent = "%s", enabled = %s, sourceLength = %d}]], 
                i, script.name, script.type, script.parent, tostring(script.enabled), script.source)
            if i < #analysis.scripts then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    if #analysis.guis > 0 then
        text = text .. '\n\n    ["GUIs"] = {'
        for i, gui in ipairs(analysis.guis) do
            text = text .. string.format([[
        [%d] = {name = "%s", type = "%s", parent = "%s", enabled = %s}]], 
                i, gui.name, gui.type, gui.parent, tostring(gui.enabled))
            if i < #analysis.guis then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    if #analysis.effects > 0 then
        text = text .. '\n\n    ["Effects"] = {'
        for i, effect in ipairs(analysis.effects) do
            text = text .. string.format([[
        [%d] = {name = "%s", type = "%s", parent = "%s", enabled = %s}]], 
                i, effect.name, effect.type, effect.parent, tostring(effect.enabled))
            if i < #analysis.effects then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    if #analysis.lights > 0 then
        text = text .. '\n\n    ["Lights"] = {'
        for i, light in ipairs(analysis.lights) do
            text = text .. string.format([[
        [%d] = {name = "%s", type = "%s", parent = "%s", enabled = %s, brightness = %.2f, color = Color3.new(%.3f, %.3f, %.3f), range = %.2f}]], 
                i, light.name, light.type, light.parent, tostring(light.enabled), light.brightness, light.color.R, light.color.G, light.color.B, light.range)
            if i < #analysis.lights then text = text .. "," end
        end
        text = text .. "\n    },"
    end
    
    text = text .. "\n}"
    
    -- Проверяем длину текста и предупреждаем о возможном обрезании
    if #text > 200000 then
        print("⚠️ Warning: Generated text is", #text, "characters long - may be truncated by clipboard")
    end
    
    return text
end

-- === ФУНКЦИИ АНАЛИЗА ПИТОМЦЕВ ===

-- Функция глубокого анализа модели питомца
local function analyzePetModel(model)
    local analysis = {
        uuid = model.Name,
        meshCount = 0,
        motor6dCount = 0,
        humanoidCount = 0,
        partCount = 0,
        attachmentCount = 0,
        scriptCount = 0,
        meshes = {},
        motor6ds = {},
        humanoids = {},
        parts = {},
        attachments = {},
        scripts = {},
        primaryPart = model.PrimaryPart and model.PrimaryPart.Name or "None",
        modelSize = nil,
        modelPosition = nil
    }
    
    -- Получение размера и позиции модели
    local cf, size = model:GetBoundingBox()
    analysis.modelSize = size
    analysis.modelPosition = cf.Position
    
    -- Анализ всех потомков
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            analysis.meshCount = analysis.meshCount + 1
            local meshInfo = {
                name = obj.Name,
                type = obj.ClassName,
                parent = obj.Parent.Name
            }
            if obj:IsA("MeshPart") then
                meshInfo.meshId = obj.MeshId
            elseif obj:IsA("SpecialMesh") then
                meshInfo.meshId = obj.MeshId
                meshInfo.meshType = obj.MeshType.Name
            end
            table.insert(analysis.meshes, meshInfo)
            
        elseif obj:IsA("Motor6D") then
            analysis.motor6dCount = analysis.motor6dCount + 1
            table.insert(analysis.motor6ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "None",
                part1 = obj.Part1 and obj.Part1.Name or "None",
                c0 = obj.C0,
                c1 = obj.C1,
                transform = obj.Transform,
                currentAngle = obj.CurrentAngle or 0,
                desiredAngle = obj.DesiredAngle or 0,
                maxVelocity = obj.MaxVelocity or 0
            })
            
        elseif obj:IsA("Humanoid") then
            analysis.humanoidCount = analysis.humanoidCount + 1
            table.insert(analysis.humanoids, {
                name = obj.Name,
                health = obj.Health,
                maxHealth = obj.MaxHealth,
                walkSpeed = obj.WalkSpeed
            })
            
        elseif obj:IsA("BasePart") then
            analysis.partCount = analysis.partCount + 1
            -- Вычисляем относительный CFrame относительно PrimaryPart
            local relativeCFrame = obj.CFrame
            if model.PrimaryPart and model.PrimaryPart ~= obj then
                relativeCFrame = model.PrimaryPart.CFrame:Inverse() * obj.CFrame
            end
            
            table.insert(analysis.parts, {
                name = obj.Name,
                type = obj.ClassName,
                size = obj.Size,
                material = obj.Material.Name,
                color = obj.Color,
                transparency = obj.Transparency,
                canCollide = obj.CanCollide,
                position = obj.Position,
                rotation = obj.Rotation,
                cframe = obj.CFrame,
                relativeCFrame = relativeCFrame,
                brickColor = obj.BrickColor.Name,
                reflectance = obj.Reflectance
            })
            
        elseif obj:IsA("Attachment") then
            analysis.attachmentCount = analysis.attachmentCount + 1
            table.insert(analysis.attachments, {
                name = obj.Name,
                parent = obj.Parent.Name,
                position = obj.Position
            })
            
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            analysis.scriptCount = analysis.scriptCount + 1
            table.insert(analysis.scripts, {
                name = obj.Name,
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled
            })
            
        -- Добавляем анализ декалей и текстур
        elseif obj:IsA("Decal") then
            table.insert(analysis.parts, {
                name = obj.Name .. " (Decal)",
                type = "Decal",
                parent = obj.Parent.Name,
                texture = obj.Texture,
                face = obj.Face.Name,
                transparency = obj.Transparency
            })
            
        elseif obj:IsA("Texture") then
            table.insert(analysis.parts, {
                name = obj.Name .. " (Texture)",
                type = "Texture", 
                parent = obj.Parent.Name,
                texture = obj.Texture,
                face = obj.Face.Name,
                transparency = obj.Transparency
            })
            
        -- Добавляем анализ GUI элементов
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            table.insert(analysis.parts, {
                name = obj.Name .. " (GUI)",
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled
            })
            
        -- Добавляем анализ эффектов
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            table.insert(analysis.parts, {
                name = obj.Name .. " (Effect)",
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled
            })
            
        -- Добавляем анализ источников света
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            table.insert(analysis.parts, {
                name = obj.Name .. " (Light)",
                type = obj.ClassName,
                parent = obj.Parent.Name,
                enabled = obj.Enabled,
                brightness = obj.Brightness,
                color = obj.Color
            })
        end
    end
    
    return analysis
end

-- Функция генерации детального текста
local function generateDetailText(analysis)
    local text = string.format([[%s = {
    ["PrimaryPart"] = "%s",
    ["ModelSize"] = %s,
    ["ModelPosition"] = %s,
    ["TotalParts"] = %d,
    ["TotalMeshes"] = %d,
    ["TotalMotor6D"] = %d,
    ["TotalHumanoids"] = %d,
    ["TotalAttachments"] = %d,
    ["TotalScripts"] = %d,
    
    ["Meshes"] = {]], 
        analysis.uuid,
        analysis.primaryPart or "None",
        analysis.modelSize and string.format("Vector3.new(%.2f, %.2f, %.2f)", analysis.modelSize.X, analysis.modelSize.Y, analysis.modelSize.Z) or "nil",
        analysis.modelPosition and string.format("Vector3.new(%.2f, %.2f, %.2f)", analysis.modelPosition.X, analysis.modelPosition.Y, analysis.modelPosition.Z) or "nil",
        analysis.partCount,
        analysis.meshCount,
        analysis.motor6dCount,
        analysis.humanoidCount,
        analysis.attachmentCount,
        analysis.scriptCount
    )
    
    -- Добавление мешей
    for i, mesh in ipairs(analysis.meshes) do
        text = text .. string.format([[
        [%d] = {name = "%s", type = "%s", parent = "%s", meshId = "%s"}]], 
            i, mesh.name, mesh.type, mesh.parent, mesh.meshId or "")
        if i < #analysis.meshes then text = text .. "," end
    end
    text = text .. "\n    },\n"
    
    -- Добавление Motor6D с полными анимационными данными
    text = text .. '\n    ["Motor6D"] = {'
    for i, motor in ipairs(analysis.motor6ds) do
        -- Безопасное получение компонентов CFrame
        local c0x, c0y, c0z, c0r00, c0r01, c0r02, c0r10, c0r11, c0r12, c0r20, c0r21, c0r22 = 0,0,0,1,0,0,0,1,0,0,0,1
        local c1x, c1y, c1z, c1r00, c1r01, c1r02, c1r10, c1r11, c1r12, c1r20, c1r21, c1r22 = 0,0,0,1,0,0,0,1,0,0,0,1
        local tx, ty, tz, tr00, tr01, tr02, tr10, tr11, tr12, tr20, tr21, tr22 = 0,0,0,1,0,0,0,1,0,0,0,1
        
        if motor.c0 then
            c0x, c0y, c0z, c0r00, c0r01, c0r02, c0r10, c0r11, c0r12, c0r20, c0r21, c0r22 = motor.c0:GetComponents()
        end
        if motor.c1 then
            c1x, c1y, c1z, c1r00, c1r01, c1r02, c1r10, c1r11, c1r12, c1r20, c1r21, c1r22 = motor.c1:GetComponents()
        end
        if motor.transform then
            tx, ty, tz, tr00, tr01, tr02, tr10, tr11, tr12, tr20, tr21, tr22 = motor.transform:GetComponents()
        end
        
        text = text .. string.format([[
        [%d] = {
            name = "%s", 
            part0 = "%s", 
            part1 = "%s",
            c0 = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            c1 = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            transform = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            currentAngle = %.3f,
            desiredAngle = %.3f,
            maxVelocity = %.3f
        }]], 
            i, motor.name, motor.part0, motor.part1,
            c0x, c0y, c0z, c0r00, c0r01, c0r02, c0r10, c0r11, c0r12, c0r20, c0r21, c0r22,
            c1x, c1y, c1z, c1r00, c1r01, c1r02, c1r10, c1r11, c1r12, c1r20, c1r21, c1r22,
            tx, ty, tz, tr00, tr01, tr02, tr10, tr11, tr12, tr20, tr21, tr22,
            motor.currentAngle, motor.desiredAngle, motor.maxVelocity)
        if i < #analysis.motor6ds then text = text .. "," end
    end
    text = text .. "\n    },\n"
    
    -- Добавление частей с полными CFrame данными
    text = text .. '\n    ["Parts"] = {'
    for i, part in ipairs(analysis.parts) do
        -- Безопасное получение компонентов CFrame
        local px, py, pz, pr00, pr01, pr02, pr10, pr11, pr12, pr20, pr21, pr22 = 0,0,0,1,0,0,0,1,0,0,0,1
        local rx, ry, rz, rr00, rr01, rr02, rr10, rr11, rr12, rr20, rr21, rr22 = 0,0,0,1,0,0,0,1,0,0,0,1
        
        if part.cframe then
            px, py, pz, pr00, pr01, pr02, pr10, pr11, pr12, pr20, pr21, pr22 = part.cframe:GetComponents()
        end
        if part.relativeCFrame then
            rx, ry, rz, rr00, rr01, rr02, rr10, rr11, rr12, rr20, rr21, rr22 = part.relativeCFrame:GetComponents()
        end
        
        text = text .. string.format([[
        [%d] = {
            name = "%s", 
            type = "%s", 
            size = Vector3.new(%.2f, %.2f, %.2f), 
            material = "%s",
            color = Color3.new(%.3f, %.3f, %.3f),
            brickColor = "%s",
            transparency = %.2f,
            canCollide = %s,
            position = Vector3.new(%.2f, %.2f, %.2f),
            rotation = Vector3.new(%.2f, %.2f, %.2f),
            cframe = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            relativeCFrame = CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f),
            reflectance = %.2f
        }]], 
            i, part.name, part.type, 
            part.size.X, part.size.Y, part.size.Z, 
            part.material,
            part.color.R, part.color.G, part.color.B,
            part.brickColor,
            part.transparency,
            tostring(part.canCollide),
            part.position.X, part.position.Y, part.position.Z,
            part.rotation.X, part.rotation.Y, part.rotation.Z,
            px, py, pz, pr00, pr01, pr02, pr10, pr11, pr12, pr20, pr21, pr22,
            rx, ry, rz, rr00, rr01, rr02, rr10, rr11, rr12, rr20, rr21, rr22,
            part.reflectance)
        if i < #analysis.parts then text = text .. "," end
    end
    text = text .. "\n    }"
    
    -- Добавление гуманоидов (только если есть)
    if #analysis.humanoids > 0 then
        text = text .. ',\n\n    ["Humanoids"] = {'
        for i, humanoid in ipairs(analysis.humanoids) do
            text = text .. string.format([[
        [%d] = {name = "%s", health = %.1f, maxHealth = %.1f, walkSpeed = %.1f}]], 
                i, humanoid.name, humanoid.health, humanoid.maxHealth, humanoid.walkSpeed)
            if i < #analysis.humanoids then text = text .. "," end
        end
        text = text .. "\n    }"
    end
    
    -- Добавление аттачментов (только если есть)
    if #analysis.attachments > 0 then
        text = text .. ',\n\n    ["Attachments"] = {'
        for i, attachment in ipairs(analysis.attachments) do
            text = text .. string.format([[
        [%d] = {name = "%s", parent = "%s", position = Vector3.new(%.2f, %.2f, %.2f)}]], 
                i, attachment.name, attachment.parent, attachment.position.X, attachment.position.Y, attachment.position.Z)
            if i < #analysis.attachments then text = text .. "," end
        end
        text = text .. "\n    }"
    end
    
    -- Добавление скриптов (только если есть)
    if #analysis.scripts > 0 then
        text = text .. ',\n\n    ["Scripts"] = {'
        for i, script in ipairs(analysis.scripts) do
            text = text .. string.format([[
        [%d] = {name = "%s", type = "%s", parent = "%s", enabled = %s}]], 
                i, script.name, script.type, script.parent, tostring(script.enabled))
            if i < #analysis.scripts then text = text .. "," end
        end
        text = text .. "\n    }"
    end
    
    text = text .. "\n}"
    
    -- Проверяем длину текста и предупреждаем о возможном обрезании
    if #text > 200000 then
        print("⚠️ Warning: Generated text is", #text, "characters long - may be truncated by clipboard")
    end
    
    return text
end

-- === WINDUI СИСТЕМА ===

-- Gradient function for text styling
function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. '<font color="rgb(' .. r .. ", " .. g .. ", " .. b .. ')">' .. char .. "</font>"
    end

    return result
end

-- Show initial popup
local Confirmed = false

WindUI:Popup({
    Title = "Pet Analyzer Loaded!",
    Icon = "search",
    IconThemed = true,
    Content = "Advanced " .. gradient("Pet Analysis Tool", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) .. " with detailed model inspection for Roblox pets",
    Buttons = {
        {
            Title = "Cancel",
            Callback = function()
            end,
            Variant = "Secondary"
        },
        {
            Title = "Start Analyzing",
            Icon = "arrow-right",
            Callback = function()
                Confirmed = true
            end,
            Variant = "Primary"
        }
    }
})

repeat
    wait()
until Confirmed

-- Create main WindUI window
local Window = WindUI:CreateWindow({
    Title = "Pet Analyzer | Advanced Model Inspector",
    Icon = "search",
    IconThemed = true,
    Author = "Pet Analysis Tool",
    Folder = "PetAnalyzer",
    Size = UDim2.fromOffset(450, 400),
    Transparent = false,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function()
        end,
        Anonymous = false
    },
    SideBarWidth = 160,
    ScrollBarEnabled = true
})

Window:EditOpenButton({
    Title = "Pet Analyzer",
    Icon = "search",
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("#FF6B6B"), Color3.fromHex("#4ECDC4")),
    Draggable = true
})

-- Create sections and tabs
local Tabs = {}

Tabs.AnalyzerSection = Window:Section({
    Title = "Pet Analysis Tools",
    Icon = "search",
    Opened = true
})

Tabs.ResultsSection = Window:Section({
    Title = "Analysis Results",
    Icon = "file-text",
    Opened = false
})

Tabs.MainTab = Tabs.AnalyzerSection:Tab({
    Title = "Analyzer",
    Icon = "search",
    Desc = "Find and analyze nearby UUID pets"
})

Tabs.ResultsTab = Tabs.ResultsSection:Tab({
    Title = "Results",
    Icon = "list",
    Desc = "View analyzed pets and detailed data"
})

Tabs.SettingsTab = Tabs.AnalyzerSection:Tab({
    Title = "Settings",
    Icon = "settings",
    Desc = "Configure analysis parameters"
})

Window:SelectTab(1)

-- Function to show detailed analysis in a popup
function showDetailedAnalysis(analysis)
    local detailText = generateDetailText(analysis)
    
    WindUI:Popup({
        Title = "📋 Detailed Analysis: " .. analysis.uuid,
        Icon = "file-text",
        IconThemed = true,
        Content = "Complete model analysis with " .. analysis.partCount .. " parts, " .. analysis.meshCount .. " meshes, and " .. analysis.motor6dCount .. " Motor6D joints.",
        Buttons = {
            {
                Title = "Copy to Clipboard",
                Icon = "copy",
                Callback = function()
                    -- Многоэтапное копирование для длинных текстов
                    local maxClipboardSize = 45000  -- Уменьшаем лимит для надежности
                    local textLength = #detailText
                    
                    if textLength > maxClipboardSize then
                        -- Разбиваем на части и копируем поэтапно
                        local totalParts = math.ceil(textLength / maxClipboardSize)
                        
                        -- Создаем popup с кнопками для каждой части
                        local buttons = {}
                        
                        for i = 1, totalParts do
                            local startPos = (i - 1) * maxClipboardSize + 1
                            local endPos = math.min(i * maxClipboardSize, textLength)
                            local partText = string.sub(detailText, startPos, endPos)
                            
                            table.insert(buttons, {
                                Title = string.format("Copy Part %d/%d", i, totalParts),
                                Icon = "copy",
                                Callback = function()
                                    pcall(function()
                                        if setclipboard then
                                            setclipboard(partText)
                                        else
                                            game:GetService("GuiService"):SetClipboard(partText)
                                        end
                                    end)
                                    
                                    WindUI:Notify({
                                        Title = string.format("Part %d Copied!", i),
                                        Content = string.format("Copied part %d/%d (%d chars)", i, totalParts, #partText),
                                        Icon = "copy",
                                        Duration = 3
                                    })
                                end
                            })
                        end
                        
                        table.insert(buttons, {
                            Title = "Close",
                            Callback = function() end
                        })
                        
                        WindUI:Popup({
                            Title = "📋 Multi-Part Copy",
                            Icon = "layers",
                            Content = string.format("Text is %d chars long, split into %d parts of ~%d chars each. Copy each part separately:", textLength, totalParts, maxClipboardSize),
                            Buttons = buttons
                        })
                        
                    else
                        -- Обычное копирование для коротких текстов
                        pcall(function()
                            if setclipboard then
                                setclipboard(detailText)
                            else
                                game:GetService("GuiService"):SetClipboard(detailText)
                            end
                        end)
                        
                        WindUI:Notify({
                            Title = "Copied!",
                            Content = "Analysis data copied to clipboard",
                            Icon = "copy",
                            Duration = 3
                        })
                    end
                    
                    print("📋 Pet Analysis Data:")
                    -- Разбиваем длинный текст на части для консоли
                    local maxChunkSize = 15000
                    local textLength = #detailText
                    if textLength > maxChunkSize then
                        local chunks = math.ceil(textLength / maxChunkSize)
                        print(string.format("📄 Analysis too long (%d chars), splitting into %d parts:", textLength, chunks))
                        for i = 1, chunks do
                            local startPos = (i - 1) * maxChunkSize + 1
                            local endPos = math.min(i * maxChunkSize, textLength)
                            local chunk = string.sub(detailText, startPos, endPos)
                            print(string.format("--- Part %d/%d ---", i, chunks))
                            print(chunk)
                        end
                    else
                        print(detailText)
                    end
                    
                    WindUI:Notify({
                        Title = "Copied!",
                        Content = "Analysis data copied to clipboard",
                        Icon = "copy",
                        Duration = 3
                    })
                end,
                Variant = "Primary"
            },
            {
                Title = "Close",
                Callback = function()
                end,
                Variant = "Secondary"
            }
        }
    })
end

-- Function to create detailed notebook window
function createDetailedNotebook(analysis)
    -- Use a simple popup instead of complex window structure
    local detailText = generateDetailText(analysis)
    
    WindUI:Popup({
        Title = "📋 Detailed Pet Analysis",
        Icon = "file-text",
        IconThemed = true,
        Content = string.format([[Pet: %s

📊 Summary:
• Parts: %d total
• Meshes: %d with Asset IDs  
• Motor6D: %d joints
• Size: %.1f×%.1f×%.1f studs
• Position: %.1f, %.1f, %.1f

Complete analysis data has been copied to clipboard and printed to console.]], 
            analysis.customName or analysis.uuid,
            analysis.partCount,
            analysis.meshCount, 
            analysis.motor6dCount,
            analysis.modelSize.X, analysis.modelSize.Y, analysis.modelSize.Z,
            analysis.modelPosition.X, analysis.modelPosition.Y, analysis.modelPosition.Z),
        Buttons = {
            {
                Title = "📋 Copy Full Data",
                Icon = "copy",
                Callback = function()
                    pcall(function()
                        if setclipboard then
                            setclipboard(detailText)
                        else
                            game:GetService("GuiService"):SetClipboard(detailText)
                        end
                    end)
                    
                    print("📋 Pet Analysis Data:")
                    -- Разбиваем длинный текст на части для консоли
                    local maxChunkSize = 15000
                    local textLength = #detailText
                    if textLength > maxChunkSize then
                        local chunks = math.ceil(textLength / maxChunkSize)
                        print(string.format("📄 Analysis too long (%d chars), splitting into %d parts:", textLength, chunks))
                        for i = 1, chunks do
                            local startPos = (i - 1) * maxChunkSize + 1
                            local endPos = math.min(i * maxChunkSize, textLength)
                            local chunk = string.sub(detailText, startPos, endPos)
                            print(string.format("--- Part %d/%d ---", i, chunks))
                            print(chunk)
                        end
                    else
                        print(detailText)
                    end
                    
                    WindUI:Notify({
                        Title = "Copied!",
                        Content = "Full pet analysis data copied to clipboard",
                        Icon = "copy",
                        Duration = 3
                    })
                end,
                Variant = "Primary"
            },
            {
                Title = "Close",
                Callback = function()
                end,
                Variant = "Secondary"
            }
        }
    })
end

-- Function to show detailed hand tool analysis
function showHandToolDetailedAnalysis(analysis)
    local detailText = generateHandToolDetailText(analysis)
    
    WindUI:Popup({
        Title = "🔧 Hand Tool Analysis: " .. analysis.toolName,
        Icon = "tool",
        IconThemed = true,
        Content = string.format([[Tool: %s (%s)

📊 Complete Analysis:
• Parts: %d total
• Meshes: %d with Asset IDs
• Motor6D: %d joints with animation data
• Scripts: %d (LocalScript/Script)
• Animations: %d animation objects
• Sounds: %d sound effects
• GUIs: %d interface elements
• Effects: %d particle/visual effects
• Lights: %d light sources
• Attachments: %d attachment points

Handle: %s
Tool Properties: Enabled=%s, CanBeDropped=%s

Complete analysis data with CFrame animations, Motor6D data, and all child objects has been copied to clipboard.]], 
            analysis.toolName,
            analysis.toolType,
            analysis.partCount,
            analysis.meshCount,
            analysis.motor6dCount,
            analysis.scriptCount,
            analysis.animationCount,
            analysis.soundCount,
            analysis.guiCount,
            analysis.effectCount,
            analysis.lightCount,
            analysis.attachmentCount,
            analysis.handle and analysis.handle.name or "None",
            tostring(analysis.enabled),
            tostring(analysis.canBeDropped)),
        Buttons = {
            {
                Title = "📋 Copy Full Tool Data",
                Icon = "copy",
                Callback = function()
                    -- Многоэтапное копирование для длинных текстов
                    local maxClipboardSize = 45000  -- Уменьшаем лимит для надежности
                    local textLength = #detailText
                    
                    if textLength > maxClipboardSize then
                        -- Разбиваем на части и копируем поэтапно
                        local totalParts = math.ceil(textLength / maxClipboardSize)
                        
                        -- Создаем popup с кнопками для каждой части
                        local buttons = {}
                        
                        for i = 1, totalParts do
                            local startPos = (i - 1) * maxClipboardSize + 1
                            local endPos = math.min(i * maxClipboardSize, textLength)
                            local partText = string.sub(detailText, startPos, endPos)
                            
                            table.insert(buttons, {
                                Title = string.format("Copy Part %d/%d", i, totalParts),
                                Icon = "copy",
                                Callback = function()
                                    pcall(function()
                                        if setclipboard then
                                            setclipboard(partText)
                                        else
                                            game:GetService("GuiService"):SetClipboard(partText)
                                        end
                                    end)
                                    
                                    WindUI:Notify({
                                        Title = string.format("Part %d Copied!", i),
                                        Content = string.format("Copied part %d/%d (%d chars)", i, totalParts, #partText),
                                        Icon = "copy",
                                        Duration = 3
                                    })
                                end
                            })
                        end
                        
                        table.insert(buttons, {
                            Title = "Close",
                            Callback = function() end
                        })
                        
                        WindUI:Popup({
                            Title = "📋 Multi-Part Copy Tool",
                            Icon = "layers",
                            Content = string.format("Tool analysis is %d chars long, split into %d parts of ~%d chars each. Copy each part separately:", textLength, totalParts, maxClipboardSize),
                            Buttons = buttons
                        })
                        
                    else
                        -- Обычное копирование для коротких текстов
                        pcall(function()
                            if setclipboard then
                                setclipboard(detailText)
                            else
                                game:GetService("GuiService"):SetClipboard(detailText)
                            end
                        end)
                        
                        WindUI:Notify({
                            Title = "Copied!",
                            Content = "Full hand tool analysis data copied to clipboard",
                            Icon = "copy",
                            Duration = 3
                        })
                    end
                    
                    print("🔧 Hand Tool Analysis Data:")
                    -- Разбиваем длинный текст на части для консоли
                    local maxChunkSize = 15000
                    local textLength = #detailText
                    if textLength > maxChunkSize then
                        local chunks = math.ceil(textLength / maxChunkSize)
                        print(string.format("📄 Analysis too long (%d chars), splitting into %d parts:", textLength, chunks))
                        for i = 1, chunks do
                            local startPos = (i - 1) * maxChunkSize + 1
                            local endPos = math.min(i * maxChunkSize, textLength)
                            local chunk = string.sub(detailText, startPos, endPos)
                            print(string.format("--- Part %d/%d ---", i, chunks))
                            print(chunk)
                        end
                    else
                        print(detailText)
                    end
                    
                    WindUI:Notify({
                        Title = "Copied!",
                        Content = "Full hand tool analysis data copied to clipboard",
                        Icon = "copy",
                        Duration = 3
                    })
                end,
                Variant = "Primary"
            },
            {
                Title = "Close",
                Callback = function()
                end,
                Variant = "Secondary"
            }
        }
    })
end

-- Function to update results tab with cards
function updateResultsTab()
    print("🔄 Updating Results tab with", #analyzedPets, "pets")
    
    -- Clear existing content
    pcall(function()
        Tabs.ResultsTab:Clear()
    end)
    
    if #analyzedPets == 0 then
        Tabs.ResultsTab:Paragraph({
            Title = "No Analysis Data",
            Desc = "No pets have been analyzed yet. Use the Analyzer tab to scan for pets.",
            Image = "info",
            Color = "Gray"
        })
        print("📝 Results tab shows empty state")
        return
    end
    
    Tabs.ResultsTab:Paragraph({
        Title = "Analysis Results",
        Desc = "Found " .. #analyzedPets .. " analyzed pets",
        Image = "list",
        Color = "Blue"
    })
    
    for i, analysis in ipairs(analyzedPets) do
        -- Pet card with custom name input
        Tabs.ResultsTab:Input({
            Title = "Pet #" .. i .. " Name",
            Placeholder = analysis.uuid,
            Value = analysis.customName or "",
            Callback = function(text)
                if text and text ~= "" then
                    analysis.customName = text
                else
                    analysis.customName = nil
                end
                WindUI:Notify({
                    Title = "Name Updated",
                    Content = "Pet name has been updated",
                    Icon = "edit",
                    Duration = 2
                })
            end
        })
        
        Tabs.ResultsTab:Paragraph({
            Title = analysis.customName or analysis.uuid,
            Desc = string.format("Parts: %d | Meshes: %d | Motor6D: %d | Humanoids: %d\nSize: %.1f×%.1f×%.1f studs", 
                analysis.partCount, analysis.meshCount, analysis.motor6dCount, analysis.humanoidCount,
                analysis.modelSize.X, analysis.modelSize.Y, analysis.modelSize.Z),
            Image = "search",
            Color = "Green"
        })
        
        Tabs.ResultsTab:Button({
            Title = "📋 Open Detailed Notebook",
            Icon = "book-open",
            Callback = function()
                createDetailedNotebook(analysis)
            end
        })
        
        Tabs.ResultsTab:Button({
            Title = "📄 Quick Copy Data",
            Icon = "copy",
            Callback = function()
                showDetailedAnalysis(analysis)
            end
        })
        
        if i < #analyzedPets then
            Tabs.ResultsTab:Divider()
        end
    end
end

-- Main Tab Implementation
Tabs.MainTab:Paragraph({
    Title = "Pet Analyzer",
    Desc = "Searches for pets with UUID names (containing {}) and provides detailed model analysis",
    Image = "search",
    Color = "Blue"
})

Tabs.MainTab:Button({
    Title = "🔬 Analyze Closest Pet",
    Icon = "search",
    Callback = function()
        WindUI:Notify({
            Title = "Analyzing...",
            Content = "Searching for nearby UUID pets",
            Icon = "search",
            Duration = 2
        })
        
        spawn(function()
            local petModel = findClosestUUIDPet()
            if petModel then
                local analysis = analyzePetModel(petModel)
                
                -- Check if already exists
                local alreadyExists = false
                for _, existingPet in pairs(analyzedPets) do
                    if existingPet.uuid == analysis.uuid then
                        alreadyExists = true
                        break
                    end
                end
                
                if not alreadyExists and #analyzedPets < CONFIG.MAX_ANALYZED_PETS then
                    table.insert(analyzedPets, analysis)
                    currentAnalysis = analysis
                    
                    WindUI:Notify({
                        Title = "Analysis Complete!",
                        Content = "Found pet: " .. analysis.uuid .. " with " .. analysis.partCount .. " parts",
                        Icon = "check-circle",
                        Duration = 4
                    })
                    
                    -- Update results tab
                    updateResultsTab()
                    
                    -- Force refresh Results tab by selecting it
                    spawn(function()
                        wait(0.5)
                        Window:SelectTab(2) -- Results tab
                        wait(0.1)
                        Window:SelectTab(1) -- Back to main tab
                    end)
                else
                    WindUI:Notify({
                        Title = "Pet Already Analyzed",
                        Content = "This pet has already been analyzed",
                        Icon = "info",
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({
                    Title = "No Pet Found",
                    Content = "No UUID pets found within " .. CONFIG.SEARCH_RADIUS .. " studs",
                    Icon = "alert-triangle",
                    Duration = 4
                })
            end
        end)
    end
})

Tabs.MainTab:Button({
    Title = "📋 Show Detailed Analysis",
    Icon = "file-text",
    Callback = function()
        if currentAnalysis then
            showDetailedAnalysis(currentAnalysis)
        else
            WindUI:Notify({
                Title = "No Analysis Available",
                Content = "Please analyze a pet first",
                Icon = "alert-triangle",
                Duration = 3
            })
        end
    end
})

Tabs.MainTab:Divider()

Tabs.MainTab:Paragraph({
    Title = "Hand Tool Analysis",
    Desc = "Analyze the tool currently equipped in your hand",
    Image = "tool",
    Color = "Orange"
})

Tabs.MainTab:Button({
    Title = "🔧 Analyze Hand Pet",
    Icon = "tool",
    Callback = function()
        WindUI:Notify({
            Title = "Analyzing Hand Tool...",
            Content = "Searching for tool in player's hand",
            Icon = "tool",
            Duration = 2
        })
        
        spawn(function()
            local handTool = findHandTool()
            if handTool then
                print("🔧 Analyzing hand tool:", handTool.Name)
                local analysis = analyzeHandTool(handTool)
                currentHandAnalysis = analysis
                
                print("🔧 Analysis complete. Motor6D count:", analysis.motor6dCount)
                for i, motor in ipairs(analysis.motor6ds) do
                    print("Motor", i, ":", motor.name, "C0 exists:", motor.c0 ~= nil, "C1 exists:", motor.c1 ~= nil)
                end
                
                WindUI:Notify({
                    Title = "Hand Tool Analysis Complete!",
                    Content = string.format("Tool: %s with %d parts, %d meshes, %d Motor6D, %d scripts", 
                        analysis.toolName, analysis.partCount, analysis.meshCount, analysis.motor6dCount, analysis.scriptCount),
                    Icon = "check-circle",
                    Duration = 4
                })
            else
                WindUI:Notify({
                    Title = "No Tool Found",
                    Content = "No tool found in player's hand. Equip a tool first.",
                    Icon = "alert-triangle",
                    Duration = 4
                })
            end
        end)
    end
})

Tabs.MainTab:Button({
    Title = "📄 Show Detailed Analysis Hand",
    Icon = "file-text",
    Callback = function()
        if currentHandAnalysis then
            showHandToolDetailedAnalysis(currentHandAnalysis)
        else
            WindUI:Notify({
                Title = "No Hand Tool Analysis",
                Content = "Please analyze a hand tool first",
                Icon = "alert-triangle",
                Duration = 3
            })
        end
    end
})

Tabs.MainTab:Divider()

-- Dynamic stats paragraph that updates
local function updateMainTabStats()
    Tabs.MainTab:Paragraph({
        Title = "Quick Stats",
        Desc = "Analyzed Pets: " .. #analyzedPets .. "/" .. CONFIG.MAX_ANALYZED_PETS,
        Image = "bar-chart",
        Color = "Green"
    })
end

updateMainTabStats()

-- Settings Tab Implementation
Tabs.SettingsTab:Paragraph({
    Title = "Analysis Settings",
    Desc = "Configure search parameters and limits",
    Image = "settings",
    Color = "Purple"
})

Tabs.SettingsTab:Slider({
    Title = "Search Radius (Studs)",
    Value = {
        Min = 50,
        Max = 500,
        Default = CONFIG.SEARCH_RADIUS
    },
    Callback = function(value)
        CONFIG.SEARCH_RADIUS = value
        WindUI:Notify({
            Title = "Search Radius Updated",
            Content = "Now searching within " .. value .. " studs",
            Icon = "target",
            Duration = 2
        })
    end
})

Tabs.SettingsTab:Slider({
    Title = "Max Analyzed Pets",
    Value = {
        Min = 5,
        Max = 50,
        Default = CONFIG.MAX_ANALYZED_PETS
    },
    Callback = function(value)
        CONFIG.MAX_ANALYZED_PETS = value
        WindUI:Notify({
            Title = "Pet Limit Updated",
            Content = "Can now store up to " .. value .. " analyzed pets",
            Icon = "list",
            Duration = 2
        })
    end
})

Tabs.SettingsTab:Button({
    Title = "Clear All Data",
    Icon = "trash-2",
    Callback = function()
        analyzedPets = {}
        currentAnalysis = nil
        WindUI:Notify({
            Title = "Data Cleared",
            Content = "All analyzed pet data has been cleared",
            Icon = "trash-2",
            Duration = 3
        })
        updateResultsTab()
    end
})

-- Initialize results tab
updateResultsTab()

print("✅ Pet Analyzer with WindUI loaded successfully!")
