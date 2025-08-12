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
        Title = "Spawner Hub | Made by MozilOnTop",
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
        Desc = "Pet Prediction | Made by MozilOnTop",
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
        Desc = "MozilOnTop",
        Image = "users",
        Color = "Purple"
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
    end
)
