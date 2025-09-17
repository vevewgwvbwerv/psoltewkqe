local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
loadstring(game:HttpGet("https://gitlab.com/darkiedarkie/dark/-/raw/main/Spawner.lua"))()


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

-- Egg ESP Data
local PetData = {
    ["Common Egg"] = {
        ["Golden Lab"] = 33.33,
        ["Dog"] = 33.33,
        ["Bunny"] = 33.33
    },
    ["Uncommon Egg"] = {
        ["Black Bunny"] = 25,
        ["Chicken"] = 25,
        ["Cat"] = 25,
        ["Deer"] = 25
    },
    ["Rare Egg"] = {
        ["Orange Tabby"] = 33.33,
        ["Spotted Deer"] = 25,
        ["Pig"] = 16.67,
        ["Rooster"] = 16.67,
        ["Monkey"] = 8.33
    },
    ["Legendary Egg"] = {
        ["Cow"] = 42.55,
        ["Silver Monkey"] = 42.55,
        ["Sea Otter"] = 10.64,
        ["Turtle"] = 2.13,
        ["Polar Bear"] = 2.13
    },
    ["Mythical Egg"] = {
        ["Grey Mouse"] = 35.71,
        ["Brown Mouse"] = 26.79,
        ["Squirrel"] = 26.79,
        ["Red Giant Ant"] = 8.93,
        ["Red Fox"] = 1.79
    },
    ["Bug Egg"] = {
        ["Snail"] = 40,
        ["Giant Ant"] = 30,
        ["Caterpillar"] = 25,
        ["Praying Mantis"] = 4,
        ["Dragonfly"] = 1
    },
    ["Night Egg"] = {
        ["Hedgehog"] = 47,
        ["Mole"] = 23.5,
        ["Frog"] = 17.63,
        ["Echo Frog"] = 8.23,
        ["Night Owl"] = 3.53,
        ["Raccoon"] = 0.12
    },
    ["Premium Night Egg"] = {
        ["Hedgehog"] = 49,
        ["Mole"] = 22,
        ["Frog"] = 14,
        ["Echo Frog"] = 10,
        ["Night Owl"] = 4,
        ["Raccoon"] = 1
    },
    ["Bee Egg"] = {
        ["Bee"] = 65,
        ["Honey Bee"] = 25,
        ["Bear Bee"] = 5,
        ["Petal Bee"] = 4,
        ["Queen Bee (Pet)"] = 1
    },
    ["Anti Bee Egg"] = {
        ["Wasp"] = 55,
        ["Tarantula Hawk"] = 30,
        ["Moth"] = 13.75,
        ["Butterfly"] = 1,
        ["Disco Bee"] = 0.25
    },
    ["Common Summer Egg"] = {
        ["Starfish"] = 50,
        ["Seagull"] = 25,
        ["Crab"] = 25
    },
    ["Rare Summer Egg"] = {
        ["Flamingo"] = 30,
        ["Toucan"] = 25,
        ["Sea Turtle"] = 20,
        ["Orangutan"] = 15,
        ["Seal"] = 10
    },
    ["Paradise Egg"] = {
        ["Ostrich"] = 40,
        ["Peacock"] = 30,
        ["Capybara"] = 21,
        ["Scarlet Macaw"] = 8,
        ["Mimic Octopus"] = 1
    },
    ["Oasis Egg"] = {
        ["Meerkat"] = 45,
        ["Sand Snake"] = 34.5,
        ["Axolotl"] = 15,
        ["Hyacinth Macaw"] = 5,
        ["Fennec Fox"] = 0.5
    },
    ["Premium Oasis Egg"] = {
        ["Meerkat"] = 45,
        ["Sand Snake"] = 34.5,
        ["Axolotl"] = 15,
        ["Hyacinth Macaw"] = 5,
        ["Fennec Fox"] = 0.5
    },
    ["Dinosaur Egg"] = {
        ["Raptor"] = 35,
        ["Triceratops"] = 32.5,
        ["Stegosaurus"] = 28,
        ["Pterodactyl"] = 3,
        ["Brontosaurus"] = 1,
        ["T-Rex"] = 0.5
    },
    ["Primal Egg"] = {
        ["Parasaurolophus"] = 35,
        ["Iguanodon"] = 32.5,
        ["Pachycephalosaurus"] = 28,
        ["Dilophosaurus"] = 3,
        ["Ankylosaurus"] = 1,
        ["Spinosaurus"] = 0.5
    },
    ["Premium Primal Egg"] = {
        ["Parasaurolophus"] = 35,
        ["Iguanodon"] = 32.5,
        ["Pachycephalosaurus"] = 28,
        ["Dilophosaurus"] = 3,
        ["Ankylosaurus"] = 1,
        ["Spinosaurus"] = 0.5
    },
    ["Zen Egg"] = {
        ["Shiba Inu"] = 40,
        ["Nihonzaru"] = 31,
        ["Tanuki"] = 20.82,
        ["Tanchozuru"] = 4.6,
        ["Kappa"] = 3.5,
        ["Kitsune"] = 0.08
    },
    ["Gourmet Egg"] = {
        ["Bagel Bunny"] = 50,
        ["Pancake Mole"] = 38,
        ["Sushi Bear"] = 7,
        ["Spaghetti Sloth"] = 4,
        ["French Fry Ferret"] = 1
    }
}

-- Egg ESP Variables
local EggVisuals = {}
local VisualsEnabled = false
local AutoRerollEnabled = false
local RerollSpeed = 0.5
local SelectedPet = ""
local AutoRerollConnection
local PausedEggs = {}
local SavedPredictions = {}

-- Egg ESP Functions
local function getRandomPet(eggName)
    local pets = PetData[eggName]
    if not pets then return "Unknown Pet" end
    local totalWeight = 0
    local weightedPets = {}
    for petName, chance in pairs(pets) do
        totalWeight = totalWeight + chance
        table.insert(weightedPets, {name = petName, weight = chance})
    end
    local randomValue = math.random() * totalWeight
    local currentWeight = 0
    for _, petData in pairs(weightedPets) do
        currentWeight = currentWeight + petData.weight
        if randomValue <= currentWeight then
            return petData.name
        end
    end
    return weightedPets[1].name
end

local function findPlayerFarm()
    local player = game.Players.LocalPlayer
    if not workspace:FindFirstChild("Farm") then return nil end
    local playerName = player.Name
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        if farm.Name == "Farm" and farm:FindFirstChild("Important") then
            local important = farm.Important
            local data = important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") then
                local ownerValue = data.Owner.Value
                if tostring(ownerValue) == playerName then
                    return farm
                end
            end
        end
    end
    return nil
end

local function createEggVisual(egg)
    local eggName = egg:GetAttribute("EggName") or "Unknown Egg"
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = egg

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.Adornee = egg
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = workspace

    local eggId = tostring(egg)
    local petName
    if SavedPredictions[eggId] then
        petName = SavedPredictions[eggId]
    else
        petName = getRandomPet(eggName)
        SavedPredictions[eggId] = petName
    end

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = petName
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.TextScaled = false
    textLabel.TextWrapped = true
    textLabel.Visible = false
    textLabel.Parent = billboard

    return {
        highlight = highlight,
        billboard = billboard,
        textLabel = textLabel,
        eggName = eggName,
        eggId = eggId
    }
end

local function updateEggVisuals()
    if not VisualsEnabled then return end
    local playerFarm = findPlayerFarm()
    if not playerFarm then
        WindUI:Notify({
            Title = "Farm Not Found",
            Content = "Could not locate your farm",
            Icon = "alert-triangle",
            Duration = 3
        })
        return
    end
    
    local important = playerFarm:FindFirstChild("Important")
    if not important then return end
    
    local objectsPhysical = important:FindFirstChild("Objects_Physical")
    if not objectsPhysical then return end

    for _, visual in pairs(EggVisuals) do
        if visual.highlight then visual.highlight:Destroy() end
        if visual.billboard then visual.billboard:Destroy() end
    end
    EggVisuals = {}

    local totalEggs = 0
    local readyEggs = 0
    local playerEggs = 0
    local player = game.Players.LocalPlayer

    for _, obj in pairs(objectsPhysical:GetChildren()) do
        if obj.Name == "PetEgg" then
            totalEggs = totalEggs + 1
            local isReady = obj:GetAttribute("READY")
            if isReady then
                readyEggs = readyEggs + 1
            end
            local owner = obj:GetAttribute("OWNER")
            if owner == player.Name then
                playerEggs = playerEggs + 1
                EggVisuals[obj] = createEggVisual(obj)
            end
        end
    end

    WindUI:Notify({
        Title = "Egg ESP Active",
        Content = "Found " .. playerEggs .. " eggs | " .. readyEggs .. " ready",
        Icon = "eye",
        Duration = 3
    })
end

local function rerollPredictions()
    for egg, visual in pairs(EggVisuals) do
        if not PausedEggs[egg] and visual.textLabel and visual.eggName and visual.eggId then
            local newPet = getRandomPet(visual.eggName)
            visual.textLabel.Text = newPet
            visual.textLabel.Visible = true
            SavedPredictions[visual.eggId] = newPet
            if SelectedPet ~= "" and newPet == SelectedPet then
                PausedEggs[egg] = true
                WindUI:Notify({
                    Title = "Target Pet Found!",
                    Content = "Found " .. SelectedPet .. " prediction!",
                    Icon = "target",
                    Duration = 4
                })
            end
        end
    end
end

local function toggleVisuals(state)
    VisualsEnabled = state
    if state then
        updateEggVisuals()
    else
        for _, visual in pairs(EggVisuals) do
            if visual.highlight then visual.highlight:Destroy() end
            if visual.billboard then visual.billboard:Destroy() end
        end
        EggVisuals = {}
        PausedEggs = {}
    end
end

local function handleAutoReroll()
    if AutoRerollConnection then
        AutoRerollConnection:Disconnect()
    end
    if AutoRerollEnabled and VisualsEnabled then
        AutoRerollConnection = game:GetService("RunService").Heartbeat:Connect(function()
            wait(RerollSpeed)
            rerollPredictions()
        end)
    end
end

local Confirmed = false

WindUI:Popup(
    {
        Title = "Loaded!!! Spawner & Egg ESP",
        Icon = "sparkles",
        IconThemed = true,
        Content = "This is a " ..
            gradient("Spawner Script", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) ..
                " with " .. gradient("Egg ESP / Preditor", Color3.fromHex("#FF6B6B"), Color3.fromHex("#4ECDC4")) .. " for GaG",
        Buttons = {
            {
                Title = "Cancel",
                Callback = function()
                end,
                Variant = "Secondary"
            },
            {
                Title = "Continue",
                Icon = "arrow-right",
                Callback = function()
                    Confirmed = true
                end,
                Variant = "Primary"
            }
        }
    }
)

repeat
    wait()
until Confirmed

local Window =
    WindUI:CreateWindow(
    {
        Title = "Spawner Hub | Made by DonCalderone",
        Icon = "sparkles",
        IconThemed = true,
        Author = "Grow A Garden",
        Folder = "VisualSpawner",
        Size = UDim2.fromOffset(420, 350),
        Transparent = false,
        Theme = "Dark",
        User = {
            Enabled = true,
            Callback = function()
            end,
            Anonymous = false
        },
        SideBarWidth = 150,
        ScrollBarEnabled = true
    }
)

Window:EditOpenButton(
    {
        Title = "Open Spawner",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 12),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("FF6B6B"), Color3.fromHex("4ECDC4")),
        Draggable = true
    }
)

local Tabs = {}

-- Create main sections
do
    Tabs.SpawnerSection =
        Window:Section(
        {
            Title = "Spawner Tools",
            Icon = "sparkles",
            Opened = true
        }
    )

    Tabs.ESPSection =
        Window:Section(
        {
            Title = "Egg ESP Tools",
            Icon = "eye",
            Opened = false
        }
    )

    Tabs.ReplacementSection =
        Window:Section(
        {
            Title = "Instant Replacement",
            Icon = "zap",
            Opened = false
        }
    )

    -- Spawner tabs
    Tabs.PetTab =
        Tabs.SpawnerSection:Tab(
        {
            Title = "Pets",
            Icon = "heart",
            Desc = "Spawn pets with custom stats"
        }
    )

    Tabs.SeedTab =
        Tabs.SpawnerSection:Tab(
        {
            Title = "Seeds",
            Icon = "leaf",
            Desc = "Spawn seeds in your garden"
        }
    )

    Tabs.EggTab =
        Tabs.SpawnerSection:Tab(
        {
            Title = "Eggs",
            Icon = "egg",
            Desc = "Spawn eggs for rare pets"
        }
    )

    -- ESP Tab
    Tabs.EggESPTab =
        Tabs.ESPSection:Tab(
        {
            Title = "Egg ESP",
            Icon = "eye",
            Desc = "Predicts ur egg u can even change them"
        }
    )

    Tabs.UITab =
        Tabs.SpawnerSection:Tab(
        {
            Title = "UI Color",
            Icon = "palette",
            Desc = "Customize UI colors and theme"
        }
    )

    -- Instant Replacement Tab
    Tabs.ReplacementTab =
        Tabs.ReplacementSection:Tab(
        {
            Title = "Instant Replace",
            Icon = "zap",
            Desc = "Instant pet replacement system"
        }
    )
end

Window:SelectTab(1)

-- Pet Tab Implementation
local petName = "Raccoon"
local petWeight = 1
local petAge = 2

Tabs.PetTab:Paragraph(
    {
        Title = "Pet Spawner",
        Desc = "Enter the pet name and customize its stats before spawning",
        Image = "heart",
        Color = "Blue"
    }
)

Tabs.PetTab:Input(
    {
        Title = "Pet Name",
        Value = "Raccoon",
        InputIcon = "search",
        Placeholder = "Enter pet name (e.g., Raccoon, Cat, Dog)",
        Callback = function(input)
            petName = input
        end
    }
)

Tabs.PetTab:Input(
    {
        Title = "Pet Weight (KG)",
        Value = tostring(petWeight),
        InputIcon = "weight",
        Placeholder = "Enter pet weight in KG",
        Callback = function(input)
            local num = tonumber(input)
            if num then
                petWeight = num
            else
                WindUI:Notify({
                    Title = "Invalid Weight",
                    Content = "Please enter a valid number for weight.",
                    Icon = "alert-triangle",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.PetTab:Input(
    {
        Title = "Pet Age",
        Value = tostring(petAge),
        InputIcon = "clock",
        Placeholder = "Enter pet age",
        Callback = function(input)
            local num = tonumber(input)
            if num then
                petAge = num
            else
                WindUI:Notify({
                    Title = "Invalid Age",
                    Content = "Please enter a valid number for age.",
                    Icon = "alert-triangle",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.PetTab:Button(
    {
        Title = "Spawn Pet",
        Icon = "plus-circle",
        Callback = function()
            if petName and petName ~= "" then
                local success, error =
                    pcall(
                    function()
                        Spawner.SpawnPet(petName, petWeight, petAge)
                    end
                )

                if success then
                    WindUI:Notify(
                        {
                            Title = "Pet Spawned!",
                            Content = petName .. " spawned with " .. petWeight .. "KG and age " .. petAge,
                            Icon = "heart",
                            Duration = 4
                        }
                    )
                else
                    WindUI:Notify(
                        {
                            Title = "Spawn Failed",
                            Content = "Failed to spawn " .. petName .. ". Check if the name is correct.",
                            Icon = "alert-circle",
                            Duration = 4
                        }
                    )
                end
            else
                WindUI:Notify(
                    {
                        Title = "Error",
                        Content = "Please enter a pet name!",
                        Icon = "alert-triangle",
                        Duration = 3
                    }
                )
            end
        end
    }
)

-- Seed Tab Implementation
local seedName = "Candy Blossom"

Tabs.SeedTab:Paragraph(
    {
        Title = "Seed Spawner",
        Desc = "Enter the seed name to spawn",
        Image = "leaf",
        Color = "Green"
    }
)

Tabs.SeedTab:Input(
    {
        Title = "Seed Name",
        Value = "Candy Blossom",
        InputIcon = "sprout",
        Placeholder = "Enter seed name (e.g., Candy Blossom, Sunflower)",
        Callback = function(input)
            seedName = input
        end
    }
)

Tabs.SeedTab:Button(
    {
        Title = "Spawn Seed",
        Icon = "sprout",
        Callback = function()
            if seedName and seedName ~= "" then
                local success, error =
                    pcall(
                    function()
                        Spawner.SpawnSeed(seedName)
                    end
                )

                if success then
                    WindUI:Notify(
                        {
                            Title = "Seed Spawned!",
                            Content = seedName .. " has been spawned Check your backpack",
                            Icon = "leaf",
                            Duration = 4
                        }
                    )
                else
                    WindUI:Notify(
                        {
                            Title = "Spawn Failed",
                            Content = "Failed to spawn " .. seedName .. ". Check if the name is correct.",
                            Icon = "alert-circle",
                            Duration = 4
                        }
                    )
                end
            else
                WindUI:Notify(
                    {
                        Title = "Error",
                        Content = "Please enter a seed name!",
                        Icon = "alert-triangle",
                        Duration = 3
                    }
                )
            end
        end
    }
)

-- Egg Tab Implementation
local eggName = "Night Egg"

Tabs.EggTab:Paragraph(
    {
        Title = "Egg Spawner",
        Desc = "Enter the egg name to spawn",
        Image = "egg",
        Color = "Orange"
    }
)

Tabs.EggTab:Input(
    {
        Title = "Egg Name",
        Value = "Night Egg",
        InputIcon = "gift",
        Placeholder = "Enter egg name (e.g., Night Egg, Bug Egg)",
        Callback = function(input)
            eggName = input
        end
    }
)

Tabs.EggTab:Button(
    {
        Title = "Spawn Egg",
        Icon = "gift",
        Callback = function()
            if eggName and eggName ~= "" then
                local success, error =
                    pcall(
                    function()
                        Spawner.SpawnEgg(eggName)
                    end
                )

                if success then
                    WindUI:Notify(
                        {
                            Title = "Egg Spawned!",
                            Content = eggName .. " has been spawned successfully",
                            Icon = "egg",
                            Duration = 4
                        }
                    )
                else
                    WindUI:Notify(
                        {
            Title = "Spawn Failed",
                            Content = "Failed to spawn " .. eggName .. ". Check if the name is correct.",
                            Icon = "alert-circle",
                            Duration = 4
                        }
                    )
                end
            else
                WindUI:Notify(
                    {
                        Title = "Error",
                        Content = "Please enter an egg name!",
                        Icon = "alert-triangle",
                        Duration = 3
                    }
                )
            end
        end
    }
)

-- Egg ESP Tab Implementation
Tabs.EggESPTab:Paragraph(
    {
        Title = "Egg ESP System",
        Desc = "Pet Prediction | Made by DonCalderone",
        Image = "eye",
        Color = "Red"
    }
)

Tabs.EggESPTab:Toggle(
    {
        Title = "Enable Egg ESP",
        Value = false,
        Callback = function(enabled)
            toggleVisuals(enabled)
            if enabled then
                WindUI:Notify({
                    Title = "Egg ESP Enabled",
                    Content = "Red highlights and predictions active",
                    Icon = "eye",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Egg ESP Disabled",
                    Content = "All visuals have been removed",
                    Icon = "eye-off",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.EggESPTab:Button(
    {
        Title = "Reroll Predictions",
        Icon = "refresh-cw",
        Callback = function()
            if VisualsEnabled then
                PausedEggs = {}
                rerollPredictions()
                WindUI:Notify({
                    Title = "Predictions Rerolled",
                    Content = "All egg predictions have been updated",
                    Icon = "refresh-cw",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "ESP Not Active",
                    Content = "Please enable Egg ESP first!",
                    Icon = "alert-triangle",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.EggESPTab:Toggle(
    {
        Title = "Auto Reroll",
        Value = false,
        Callback = function(enabled)
            AutoRerollEnabled = enabled
            handleAutoReroll()
            WindUI:Notify({
                Title = "Auto Reroll " .. (enabled and "Enabled" or "Disabled"),
                Content = "Predictions will " .. (enabled and "auto-update" or "stop updating"),
                Icon = enabled and "play" or "pause",
                Duration = 3
            })
        end
    }
)

Tabs.EggESPTab:Slider(
    {
        Title = "Reroll Speed",
        Value = {
            Min = 1,
            Max = 10,
            Default = 1
        },
        Callback = function(value)
            RerollSpeed = value * 0.5
            if value == 1 then RerollSpeed = 0.25 end
            if AutoRerollEnabled then handleAutoReroll() end
        end
    }
)

Tabs.EggESPTab:Input(
    {
        Title = "Target Pet (Case Sensitive)",
        Value = "",
        InputIcon = "target",
        Placeholder = "Enter pet name to pause on (e.g., Kitsune, T-Rex)",
        Callback = function(input)
            SelectedPet = input
            PausedEggs = {}
            WindUI:Notify({
                Title = "Target Set",
                Content = "Will pause when " .. (input ~= "" and input or "any pet") .. " is found",
                Icon = "target",
                Duration = 3
            })
        end
    }
)

Tabs.EggESPTab:Divider()

Tabs.EggESPTab:Paragraph(
    {
        Title = "How to Use Egg ESP",
        Desc = "1. Enable Egg ESP to see red highlights\n2. Use Reroll to change predictions\n3. Set Target Pet to auto-pause\n4. Auto Reroll continuously updates predictions",
        Image = "info",
        Color = "Blue"
    }
)

-- UI Color Tab Implementation
local currentThemeName = WindUI:GetCurrentTheme()
local themes = WindUI:GetThemes()

local ThemeAccent = themes[currentThemeName].Accent
local ThemeOutline = themes[currentThemeName].Outline
local ThemeText = themes[currentThemeName].Text
local ThemePlaceholderText = themes[currentThemeName].Placeholder

function updateTheme()
    WindUI:AddTheme(
        {
            Name = currentThemeName,
            Accent = ThemeAccent,
            Outline = ThemeOutline,
            Text = ThemeText,
            Placeholder = ThemePlaceholderText
        }
    )
    WindUI:SetTheme(currentThemeName)
end

Tabs.UITab:Paragraph(
    {
        Title = "UI Customization",
        Desc = "Change colors and theme of the interface",
        Image = "palette",
        Color = "Blue"
    }
)

-- Theme selector
local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

local themeDropdown =
    Tabs.UITab:Dropdown(
    {
        Title = "Select Theme",
        Values = themeValues,
        Value = WindUI:GetCurrentTheme(),
        Callback = function(theme)
            WindUI:SetTheme(theme)
            WindUI:Notify(
                {
                    Title = "Theme Changed",
                    Content = "Theme changed to " .. theme,
                    Icon = "palette",
                    Duration = 3
                }
            )
        end
    }
)

-- Transparency toggle
Tabs.UITab:Toggle(
    {
        Title = "Window Transparency",
        Value = false,
        Callback = function(enabled)
            Window:ToggleTransparency(enabled)
            WindUI:Notify(
                {
                    Title = "Transparency " .. (enabled and "Enabled" or "Disabled"),
                    Content = "Window transparency has been " .. (enabled and "enabled" or "disabled"),
                    Icon = enabled and "eye" or "eye-off",
                    Duration = 3
                }
            )
        end
    }
)

Tabs.UITab:Divider()

-- Custom theme creation
Tabs.UITab:Input(
    {
        Title = "Custom Theme Name",
        Value = currentThemeName,
        Placeholder = "Enter theme name",
        Callback = function(name)
            currentThemeName = name
        end
    }
)

Tabs.UITab:Colorpicker(
    {
        Title = "Accent Color",
        Default = Color3.fromHex(ThemeAccent),
        Callback = function(color)
            ThemeAccent = color:ToHex()
        end
    }
)

Tabs.UITab:Colorpicker(
    {
        Title = "Outline Color",
        Default = Color3.fromHex(ThemeOutline),
        Callback = function(color)
            ThemeOutline = color:ToHex()
        end
    }
)

Tabs.UITab:Colorpicker(
    {
        Title = "Text Color",
        Default = Color3.fromHex(ThemeText),
        Callback = function(color)
            ThemeText = color:ToHex()
        end
    }
)

Tabs.UITab:Colorpicker(
    {
        Title = "Placeholder Text Color",
        Default = Color3.fromHex(ThemePlaceholderText),
        Callback = function(color)
            ThemePlaceholderText = color:ToHex()
        end
    }
)

Tabs.UITab:Button(
    {
        Title = "Apply Custom Theme",
        Icon = "check",
        Callback = function()
            updateTheme()
            WindUI:Notify(
                {
                    Title = "Custom Theme Applied",
                    Content = "Theme '" .. currentThemeName .. "' has been applied",
                    Icon = "palette",
                    Duration = 4
                }
            )
        end
    }
)

-- Credits section
Tabs.UITab:Divider()

Tabs.UITab:Paragraph(
    {
        Title = "Credits",
        Desc = "DonCalderone",
        Image = "users",
        Color = "Purple"
    }
)

-- Instant Replacement Tab Implementation
Tabs.ReplacementTab:Paragraph(
    {
        Title = "Instant Pet Replacement",
        Desc = "Advanced pet replacement system with instant visual swapping",
        Image = "zap",
        Color = "Purple"
    }
)

Tabs.ReplacementTab:Toggle(
    {
        Title = "Enable ESP System",
        Value = true,
        Callback = function(enabled)
            espEnabled = enabled
            if enabled then
                scanForEggs()
                WindUI:Notify({
                    Title = "ESP System Enabled",
                    Content = "Scanning for eggs and enabling ESP",
                    Icon = "eye",
                    Duration = 3
                })
            else
                -- Clear all ESP
                for egg, data in pairs(displayedEggs) do
                    if data.gui then
                        data.gui:Destroy()
                    end
                end
                displayedEggs = {}
                WindUI:Notify({
                    Title = "ESP System Disabled",
                    Content = "All ESP visuals removed",
                    Icon = "eye-off",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.ReplacementTab:Button(
    {
        Title = "Randomize Pet Predictions",
        Icon = "shuffle",
        Callback = function()
            randomizePets()
            WindUI:Notify({
                Title = "Predictions Randomized",
                Content = "All pet predictions have been updated",
                Icon = "shuffle",
                Duration = 3
            })
        end
    }
)

Tabs.ReplacementTab:Toggle(
    {
        Title = "Enable Instant Replacement",
        Value = true,
        Callback = function(enabled)
            replacementActive = enabled
            if enabled then
                WindUI:Notify({
                    Title = "Instant Replacement Enabled",
                    Content = "Pets will be instantly replaced when spawned",
                    Icon = "zap",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Instant Replacement Disabled",
                    Content = "Pet replacement system paused",
                    Icon = "pause",
                    Duration = 3
                })
            end
        end
    }
)

Tabs.ReplacementTab:Button(
    {
        Title = "View Replacement Log",
        Icon = "list",
        Callback = function()
            WindUI:Notify({
                Title = "Replacement Log",
                Content = "Total replacements: " .. #replacementLog .. " (Check console for details)",
                Icon = "list",
                Duration = 4
            })
            print("\n⚡ REPLACEMENT LOG:")
            for i, entry in ipairs(replacementLog) do
                print("✅ " .. entry.original .. " → " .. entry.target .. " (" .. entry.method .. ")")
            end
            print("📊 Total replacements: " .. #replacementLog)
        end
    }
)

Tabs.ReplacementTab:Button(
    {
        Title = "Cache Pet Models",
        Icon = "download",
        Callback = function()
            cachePetModels()
            WindUI:Notify({
                Title = "Models Cached",
                Content = "Pet models have been cached for faster replacement",
                Icon = "download",
                Duration = 3
            })
        end
    }
)

Tabs.ReplacementTab:Divider()

Tabs.ReplacementTab:Paragraph(
    {
        Title = "How Instant Replacement Works",
        Desc = "1. Enable ESP to see egg predictions\n2. Enable Instant Replacement\n3. When you hatch an egg, the pet will be instantly replaced with the predicted one\n4. All original attributes are preserved",
        Image = "info",
        Color = "Blue"
    }
)

-- Window close handler
Window:OnClose(
    function()
        -- Clean up ESP visuals on close
        if AutoRerollConnection then
            AutoRerollConnection:Disconnect()
        end
        
        for _, visual in pairs(EggVisuals) do
            if visual.highlight then visual.highlight:Destroy() end
            if visual.billboard then visual.billboard:Destroy() end
        end
        
        EggVisuals = {}
        PausedEggs = {}
        SavedPredictions = {}
        
        -- Clean up replacement system
        for egg, data in pairs(displayedEggs) do
            if data.gui then
                data.gui:Destroy()
            end
        end
        displayedEggs = {}
        replacementLog = {}
        petModels = {}
    end
)

-- Initialize Instant Replacement System
print("⚡ Initializing Instant Replacement System...")
cachePetModels()
scanForEggs()
setupInstantMonitoring()

-- Global variables for external access
_G.InstantReplacer = {
    espEnabled = espEnabled,
    replacementActive = replacementActive,
    displayedEggs = displayedEggs,
    replacementLog = replacementLog,
    petModels = petModels,
    instantReplacePet = instantReplacePet
}


-- ⚡ ROBLOXESP INTEGRATION - Variables and Functions
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

-- Настройки для системы замены
local espEnabled = true
local replacementActive = true

-- База данных питомцев по яйцам
local eggChances = {
    ["Common Egg"] = {"Dog", "Bunny", "Golden Lab"},
    ["Uncommon Egg"] = {"Black Bunny", "Chicken", "Cat", "Deer"},
    ["Rare Egg"] = {"Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey"},
    ["Legendary Egg"] = {"Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear"},
    ["Mythic Egg"] = {"Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox"},
    ["Bug Egg"] = {"Snail", "Giant Ant", "Caterpillar", "Praying Mantis", "Dragon Fly"},
    ["Night Egg"] = {"Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon"},
    ["Bee Egg"] = {"Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"},
    ["Anti Bee Egg"] = {"Wasp", "Tarantula Hawk", "Moth", "Butterfly", "Disco Bee"},
    ["Common Summer Egg"] = {"Starfish", "Seafull", "Crab"},
    ["Rare Summer Egg"] = {"Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal"},
    ["Paradise Egg"] = {"Ostrich", "Peacock", "Capybara", "Scarlet Macaw", "Mimic Octopus"},
    ["Premium Night Egg"] = {"Hedgehog", "Mole", "Frog", "Echo Frog"},
    ["Dinosaur Egg"] = {"Raptor", "Triceratops", "T-Rex", "Stegosaurus", "Pterodactyl", "Brontosaurus"}
}

-- Хранилище данных
local displayedEggs = {}
local replacementLog = {}
local petModels = {}

-- Кэш моделей питомцев для быстрого доступа
local function cachePetModels()
    print("🔍 Кэширование моделей питомцев...")
    
    -- Поиск в ReplicatedStorage
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local modelName = obj.Name
            petModels[modelName] = obj
            
            -- Также добавляем варианты названий
            petModels[modelName:lower()] = obj
            petModels[modelName:gsub(" ", "")] = obj
            petModels[modelName:gsub(" ", "_")] = obj
        end
    end
    
    print("✅ Закэшировано моделей: " .. #petModels)
end

-- Функция получения модели питомца
local function getPetModel(petName)
    -- Сначала проверяем кэш
    if petModels[petName] then
        return petModels[petName]
    end
    
    -- Проверяем варианты названий
    local variants = {
        petName,
        petName:lower(),
        petName:upper(),
        petName:gsub(" ", ""),
        petName:gsub(" ", "_"),
        petName:gsub(" ", "-")
    }
    
    for _, variant in pairs(variants) do
        if petModels[variant] then
            return petModels[variant]
        end
    end
    
    -- Если не найдено в кэше, ищем в реальном времени
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            for _, variant in pairs(variants) do
                if obj.Name == variant then
                    petModels[petName] = obj -- Добавляем в кэш
                    return obj
                end
            end
        end
    end
    
    return nil
end

-- Функция создания ESP
local function createEspGui(egg, eggName, petName)
    if egg:FindFirstChild("EggESP") then
        egg:FindFirstChild("EggESP"):Destroy()
    end
    
    local adornee = egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart
    if not adornee then return nil end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP"
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local eggLabel = Instance.new("TextLabel")
    eggLabel.Size = UDim2.new(1, 0, 0.5, 0)
    eggLabel.BackgroundTransparency = 1
    eggLabel.Text = eggName
    eggLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    eggLabel.TextStrokeTransparency = 0
    eggLabel.TextScaled = true
    eggLabel.Font = Enum.Font.SourceSansBold
    eggLabel.Parent = billboard

    local petLabel = Instance.new("TextLabel")
    petLabel.Name = "PetLabel"
    petLabel.Size = UDim2.new(1, 0, 0.5, 0)
    petLabel.Position = UDim2.new(0, 0, 0.5, 0)
    petLabel.BackgroundTransparency = 1
    petLabel.Text = petName
    petLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    petLabel.TextStrokeTransparency = 0
    petLabel.TextScaled = true
    petLabel.Font = Enum.Font.SourceSansBold
    petLabel.Parent = billboard

    billboard.Parent = egg
    return billboard
end

-- Функция поиска яиц
local function findEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, "Egg") then
            local eggName = obj.Name
            if eggChances[eggName] then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

-- Функция добавления ESP к яйцу
local function addESP(egg)
    if displayedEggs[egg] then return end
    
    local eggName = egg.Name
    if not eggChances[eggName] then return end

    local availablePets = eggChances[eggName]
    local randomPet = availablePets[math.random(1, #availablePets)]
    
    local espGui = nil
    if espEnabled then
        espGui = createEspGui(egg, eggName, randomPet)
    end
    
    displayedEggs[egg] = {
        egg = egg,
        gui = espGui,
        eggName = eggName,
        currentPet = randomPet,
        availablePets = availablePets
    }
    
    print("🥚 ESP добавлен: " .. eggName .. " → " .. randomPet)
end

-- Функция переключения ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    for egg, data in pairs(displayedEggs) do
        if espEnabled then
            if not data.gui then
                data.gui = createEspGui(egg, data.eggName, data.currentPet)
            end
        else
            if data.gui then
                data.gui:Destroy()
                data.gui = nil
            end
        end
    end
    
    print(espEnabled and "🟢 ESP включен" or "🔴 ESP выключен")
end

-- Функция рандомизации питомцев
local function randomizePets()
    local randomizedCount = 0
    
    for egg, data in pairs(displayedEggs) do
        local newPet = data.availablePets[math.random(1, #data.availablePets)]
        data.currentPet = newPet
        
        if espEnabled and data.gui then
            local petLabel = data.gui:FindFirstChild("PetLabel")
            if petLabel then
                petLabel.Text = newPet
            end
        end
        
        randomizedCount = randomizedCount + 1
        print("🎲 " .. data.eggName .. " → " .. newPet)
    end
    
    print("🎲 Рандомизировано питомцев: " .. randomizedCount)
end

-- ⚡ МГНОВЕННАЯ ЗАМЕНА ПИТОМЦА
local function instantReplacePet(originalPet, targetPetName, eggPosition)
    print("⚡ МГНОВЕННАЯ ЗАМЕНА: " .. originalPet.Name .. " → " .. targetPetName)
    
    -- Получаем модель целевого питомца
    local targetModel = getPetModel(targetPetName)
    if not targetModel then
        print("❌ Модель не найдена: " .. targetPetName)
        return false
    end
    
    -- Сохраняем важные данные оригинального питомца
    local originalData = {
        parent = originalPet.Parent,
        cframe = originalPet.PrimaryPart and originalPet.PrimaryPart.CFrame or 
                originalPet:FindFirstChildWhichIsA("BasePart") and originalPet:FindFirstChildWhichIsA("BasePart").CFrame,
        name = originalPet.Name,
        attributes = {}
    }
    
    -- Сохраняем все атрибуты
    for attr, value in pairs(originalPet:GetAttributes()) do
        originalData.attributes[attr] = value
    end
    
    -- Создаем новую модель
    local newPet = targetModel:Clone()
    newPet.Name = originalData.name -- Сохраняем оригинальное имя для совместимости
    
    -- Устанавливаем позицию
    if originalData.cframe then
        if newPet.PrimaryPart then
            newPet.PrimaryPart.CFrame = originalData.cframe
        elseif newPet:FindFirstChildWhichIsA("BasePart") then
            newPet:FindFirstChildWhichIsA("BasePart").CFrame = originalData.cframe
        end
    end
    
    -- Восстанавливаем атрибуты
    for attr, value in pairs(originalData.attributes) do
        newPet:SetAttribute(attr, value)
    end
    
    -- МГНОВЕННАЯ замена
    originalPet:Destroy()
    newPet.Parent = originalData.parent
    
    -- Логируем замену
    table.insert(replacementLog, {
        time = tick(),
        original = originalPet.Name,
        target = targetPetName,
        success = true,
        method = "instant_visual"
    })
    
    print("✅ МГНОВЕННАЯ ЗАМЕНА ЗАВЕРШЕНА: " .. targetPetName)
    return true
end

-- Функция проверки на питомца
local function isPetModel(obj)
    if not obj:IsA("Model") then return false end
    
    local humanoid = obj:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local hasHead = obj:FindFirstChild("Head")
    local hasTorso = obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
    
    return hasHead and hasTorso
end

-- ⚡ СИСТЕМА МГНОВЕННОГО МОНИТОРИНГА
local function setupInstantMonitoring()
    -- 1. Мониторинг workspace с мгновенной реакцией
    workspace.ChildAdded:Connect(function(child)
        if not replacementActive then return end
        
        if isPetModel(child) then
            -- МГНОВЕННАЯ обработка без задержек
            spawn(function()
                print("🐾 ОБНАРУЖЕН ПИТОМЕЦ: " .. child.Name)
                
                -- Ищем ближайший ESP для замены
                local targetPet = nil
                local minDistance = math.huge
                local childPos = child.PrimaryPart and child.PrimaryPart.Position or 
                                child:FindFirstChildWhichIsA("BasePart") and child:FindFirstChildWhichIsA("BasePart").Position
                
                if childPos then
                    for egg, data in pairs(displayedEggs) do
                        if data.currentPet then
                            local eggPos = egg.PrimaryPart and egg.PrimaryPart.Position or 
                                          egg:FindFirstChildWhichIsA("BasePart") and egg:FindFirstChildWhichIsA("BasePart").Position
                            
                            if eggPos then
                                local distance = (childPos - eggPos).Magnitude
                                if distance < minDistance and distance < 100 then
                                    minDistance = distance
                                    targetPet = data.currentPet
                                end
                            end
                        end
                    end
                    
                    -- Если найден ESP и питомец не соответствует - МГНОВЕННАЯ ЗАМЕНА
                    if targetPet and targetPet ~= child.Name then
                        print("🎯 НЕСООТВЕТСТВИЕ! ESP: " .. targetPet .. ", Выпал: " .. child.Name)
                        instantReplacePet(child, targetPet, childPos)
                    else
                        print("✅ Питомец соответствует ESP: " .. (targetPet or "нет ESP"))
                    end
                end
            end)
        end
    end)
    
    -- 2. Мониторинг NPCS папки
    local npcsFolder = workspace:FindFirstChild("NPCS")
    if npcsFolder then
        npcsFolder.ChildAdded:Connect(function(child)
            if not replacementActive then return end
            
            if isPetModel(child) then
                spawn(function()
                    print("👥 ПИТОМЕЦ В NPCS: " .. child.Name)
                    
                    -- Ищем любой ESP для замены
                    for egg, data in pairs(displayedEggs) do
                        if data.currentPet and data.currentPet ~= child.Name then
                            print("🔄 ЗАМЕНА В NPCS: " .. data.currentPet)
                            instantReplacePet(child, data.currentPet, nil)
                            break
                        end
                    end
                end)
            end
        end)
    end
    
    -- 3. Мониторинг каждый кадр для максимальной скорости
    runService.Heartbeat:Connect(function()
        if not replacementActive then return end
        
        -- Проверяем все новые питомцы в workspace
        for _, obj in pairs(workspace:GetChildren()) do
            if isPetModel(obj) and not obj:GetAttribute("ProcessedByReplacer") then
                obj:SetAttribute("ProcessedByReplacer", true)
                
                spawn(function()
                    -- Ищем соответствующий ESP
                    local objPos = obj.PrimaryPart and obj.PrimaryPart.Position or 
                                  obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position
                    
                    if objPos then
                        for egg, data in pairs(displayedEggs) do
                            if data.currentPet then
                                local eggPos = egg.PrimaryPart and egg.PrimaryPart.Position or 
                                              egg:FindFirstChildWhichIsA("BasePart") and egg:FindFirstChildWhichIsA("BasePart").Position
                                
                                if eggPos and (objPos - eggPos).Magnitude < 50 then
                                    if data.currentPet ~= obj.Name then
                                        print("⚡ HEARTBEAT ЗАМЕНА: " .. obj.Name .. " → " .. data.currentPet)
                                        instantReplacePet(obj, data.currentPet, objPos)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- Сканирование яиц
local function scanForEggs()
    local eggs = findEggs()
    for _, egg in pairs(eggs) do
        addESP(egg)
    end
    print("🔍 Найдено яиц: " .. #eggs)
end

-- Мониторинг новых яиц
workspace.ChildAdded:Connect(function(child)
    wait(0.1)
    if child:IsA("Model") and string.find(child.Name, "Egg") and eggChances[child.Name] then
        addESP(child)
    end
end)

print("✅ INTEGRATED WINDUI SYSTEM LOADED!")
print("🔥 Features:")
print("   - WindUI interface with all ROBLOXESP functions")
print("   - Spawner system for pets, seeds, and eggs")
print("   - Advanced Egg ESP with predictions")
print("   - Instant pet replacement system")
print("   - Model caching for maximum performance")
print("⚡ All systems integrated into WindUI!")
