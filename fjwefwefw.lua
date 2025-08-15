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
                part1 = obj.Part1 and obj.Part1.Name or "None"
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
    
    -- Добавление Motor6D
    text = text .. '\n    ["Motor6D"] = {'
    for i, motor in ipairs(analysis.motor6ds) do
        text = text .. string.format([[
        [%d] = {name = "%s", part0 = "%s", part1 = "%s"}]], 
            i, motor.name, motor.part0, motor.part1)
        if i < #analysis.motor6ds then text = text .. "," end
    end
    text = text .. "\n    },\n"
    
    -- Добавление частей
    text = text .. '\n    ["Parts"] = {'
    for i, part in ipairs(analysis.parts) do
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
                    pcall(function()
                        if setclipboard then
                            setclipboard(detailText)
                        else
                            game:GetService("GuiService"):SetClipboard(detailText)
                        end
                    end)
                    
                    print("📋 Pet Analysis Data:")
                    print(detailText)
                    
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
    local NotebookWindow = WindUI:CreateWindow({
        Title = "📋 Pet Analysis: " .. (analysis.customName or analysis.uuid),
        Icon = "file-text",
        IconThemed = true,
        Author = "Detailed Pet Data",
        Folder = "PetAnalyzer_Details",
        Size = UDim2.fromOffset(600, 500),
        Transparent = false,
        Theme = "Dark",
        User = {
            Enabled = false
        },
        SideBarWidth = 0,
        ScrollBarEnabled = true
    })
    
    local DetailTab = NotebookWindow:Tab({
        Title = "Analysis Data",
        Icon = "database",
        Desc = "Complete pet model information"
    })
    
    DetailTab:Paragraph({
        Title = "Pet Information",
        Desc = string.format("UUID: %s\nParts: %d | Meshes: %d | Motor6D: %d", 
            analysis.uuid, analysis.partCount, analysis.meshCount, analysis.motor6dCount),
        Image = "info",
        Color = "Blue"
    })
    
    DetailTab:Button({
        Title = "📋 Copy Full Analysis",
        Icon = "copy",
        Callback = function()
            local detailText = generateDetailText(analysis)
            pcall(function()
                if setclipboard then
                    setclipboard(detailText)
                else
                    game:GetService("GuiService"):SetClipboard(detailText)
                end
            end)
            
            print("📋 Pet Analysis Data:")
            print(detailText)
            
            WindUI:Notify({
                Title = "Copied!",
                Content = "Full analysis data copied to clipboard",
                Icon = "copy",
                Duration = 3
            })
        end
    })
    
    DetailTab:Divider()
    
    -- Model Properties
    DetailTab:Paragraph({
        Title = "Model Properties",
        Desc = string.format("Size: %.1f×%.1f×%.1f\nPosition: %.1f, %.1f, %.1f\nPrimary Part: %s", 
            analysis.modelSize.X, analysis.modelSize.Y, analysis.modelSize.Z,
            analysis.modelPosition.X, analysis.modelPosition.Y, analysis.modelPosition.Z,
            analysis.primaryPart),
        Image = "box",
        Color = "Purple"
    })
    
    -- Parts breakdown
    if #analysis.parts > 0 then
        DetailTab:Paragraph({
            Title = "Parts Breakdown",
            Desc = string.format("%d total parts found", #analysis.parts),
            Image = "layers",
            Color = "Green"
        })
    end
    
    -- Meshes breakdown
    if #analysis.meshes > 0 then
        DetailTab:Paragraph({
            Title = "Meshes Found",
            Desc = string.format("%d meshes with asset IDs", #analysis.meshes),
            Image = "triangle",
            Color = "Orange"
        })
    end
    
    -- Motor6D joints
    if #analysis.motor6ds > 0 then
        DetailTab:Paragraph({
            Title = "Motor6D Joints",
            Desc = string.format("%d joints connecting parts", #analysis.motor6ds),
            Image = "link",
            Color = "Red"
        })
    end
    
    DetailTab:Button({
        Title = "Close Notebook",
        Icon = "x",
        Callback = function()
            NotebookWindow:Destroy()
        end
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
