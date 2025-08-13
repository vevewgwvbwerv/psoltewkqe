-- 🧭 PetOriginTracer_Safe.lua
-- Наблюдение за появлением питомцев без хука низкого уровня (без эксплойта)
-- Логирует: источник модели (эвристики), путь появления в Backpack/Workspace, анимации/Humanoid, атрибуты KG/Age, триггеры ProximityPrompt

-- Сервисы
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local PPS = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local localPlayer = Players.LocalPlayer
local backpack = localPlayer and localPlayer:WaitForChild("Backpack")

-- Настройки
local KEYWORDS = {"pet","egg","hatch","summon","spawn","inventory","backpack"}
local PET_NAME_HINTS = {"pet","dog","cat","dragon","wolf","fox","bear","rabbit","bird","tiger","lion","shark","ghost","slime"}
local MAX_LOG_LEN = 140

-- Утилиты
local function now()
	return os.date("%H:%M:%S")
end

local function safeName(inst)
	if typeof(inst) == "Instance" then
		local ok, path = pcall(function() return inst:GetFullName() end)
		return ok and path or (inst.ClassName .. ":" .. inst.Name)
	end
	return tostring(inst)
end

local function trunc(s)
	s = tostring(s or "")
	if #s > MAX_LOG_LEN then return s:sub(1, MAX_LOG_LEN - 3) .. "..." end
	return s
end

local function info(fmt, ...)
	print(string.format("[%s][Tracer] ", now()) .. string.format(fmt, ...))
end

local function isKeyworded(name)
	name = string.lower(name or "")
	for _, k in ipairs(KEYWORDS) do
		if string.find(name, k) then return true end
	end
	return false
end

local function looksLikePetName(name)
	name = string.lower(name or "")
	for _, k in ipairs(PET_NAME_HINTS) do
		if string.find(name, k) then return true end
	end
	return false
end

-- Наблюдаем каталоги в RS как потенциальные источники моделей
local modelLibraries = {}
local function indexLibraries()
	modelLibraries = {}
	for _, child in ipairs(RS:GetChildren()) do
		if child:IsA("Folder") or child:IsA("Model") then
			if isKeyworded(child.Name) or looksLikePetName(child.Name) then
				modelLibraries[child] = true
			end
			-- погружаемся на 1 уровень
			for _, sub in ipairs(child:GetChildren()) do
				if sub:IsA("Folder") or sub:IsA("Model") then
					if isKeyworded(sub.Name) or looksLikePetName(sub.Name) then
						modelLibraries[sub] = true
					end
				end
			end
		end
	end
	info("Просканированы возможные библиотеки в ReplicatedStorage: %d", (#(function(t) local c=0 for _ in pairs(t) do c=c+1 end return setmetatable({}, {__len=function() return c end}) end)(modelLibraries)))
end
indexLibraries()
RS.ChildAdded:Connect(indexLibraries)
RS.ChildRemoved:Connect(indexLibraries)

-- Корреляция действий игрока: ProximityPrompt → последующие события (spawn/clone/parent)
local recentPrompt = nil
PPS.PromptTriggered:Connect(function(prompt, player)
	if player == localPlayer then
		recentPrompt = {
			at = tick(),
			path = safeName(prompt),
			action = prompt.ActionText,
		}
		info("PromptTriggered by you: action='%s' at %s", trunc(prompt.ActionText), trunc(safeName(prompt)))
	end
end)

-- Объект считается питомцем, если:
-- 1) Model с Humanoid/Animator, или
-- 2) Tool содержащий модель, или
-- 3) Имя похоже на питомца
local function classifyPetCandidate(inst)
	if not inst then return false, "nil" end
	if inst:IsA("Model") then
		if inst:FindFirstChildOfClass("Humanoid") then return true, "Model+Humanoid" end
		if looksLikePetName(inst.Name) then return true, "Model+NameHint" end
	elseif inst:IsA("Tool") then
		if looksLikePetName(inst.Name) then return true, "Tool+NameHint" end
		if inst:FindFirstChildWhichIsA("Model", true) then return true, "Tool+ContainsModel" end
	end
	return false, "NoPetSignals"
end

-- Попытка найти похожую модель в библиотеках RS по имени
local function guessLibrarySourceByName(name)
	if not name or name == "" then return nil end
	for lib, _ in pairs(modelLibraries) do
		local found = lib:FindFirstChild(name, true)
		if found then
			return found
		end
	end
	return nil
end

-- Мониторинг Backpack: появление Tool/моделей
if backpack then
	backpack.ChildAdded:Connect(function(child)
		local isPet, why = classifyPetCandidate(child)
		if isPet then
			local src = guessLibrarySourceByName(child.Name)
			local srcStr = src and ("likely from " .. safeName(src)) or "unknown"
			local viaPrompt = (recentPrompt and (tick() - recentPrompt.at) < 5) and (" after Prompt '"..(recentPrompt.action or "").."' @ "..recentPrompt.path) or ""
			info("Backpack++ PetCandidate: %s [%s] %s | source: %s", trunc(safeName(child)), why, viaPrompt, srcStr)
		end
	end)
end

-- Мониторинг Workspace: любые новые Model/Tool как потенциальные спауны
WS.DescendantAdded:Connect(function(inst)
	local isPet, why = classifyPetCandidate(inst)
	if isPet then
		local src = guessLibrarySourceByName(inst.Name)
		local srcStr = src and ("likely from " .. safeName(src)) or "unknown"
		local viaPrompt = (recentPrompt and (tick() - recentPrompt.at) < 5) and (" after Prompt '"..(recentPrompt.action or "").."' @ "..recentPrompt.path) or ""
		info("Workspace++ PetCandidate: %s [%s] %s | source: %s", trunc(safeName(inst)), why, viaPrompt, srcStr)
	end
end)

-- Глубокое наблюдение за конкретной моделью питомца: Humanoid, Animator, анимации, стейты, атрибуты
local observed = setmetatable({}, {__mode = "k"})
local function attachDeepObservers(model)
	if observed[model] then return end
	observed[model] = true

	local function logHumanoid(h)
		info("Humanoid attached: %s", trunc(safeName(h)))
		local ok1, err1 = pcall(function()
			h.StateChanged:Connect(function(old, new)
				info("HumanoidState: %s -> %s @ %s", tostring(old), tostring(new), trunc(safeName(model)))
			end)
		end)
		if not ok1 then info("Humanoid State hook error: %s", tostring(err1)) end

		local animator = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 2)
		if animator then
			info("Animator found: %s", trunc(safeName(animator)))
			local ok2, err2 = pcall(function()
				animator.AnimationPlayed:Connect(function(track)
					local anim = track and track.Animation
					info("AnimationPlayed: track=%s animId=%s on %s", trunc(safeName(track)), anim and trunc(anim.AnimationId) or "nil", trunc(safeName(model)))
				end)
			end)
			if not ok2 then info("Animator hook error: %s", tostring(err2)) end
		end
	end

	-- Атрибуты KG/Age
	for _, attr in ipairs({"KG", "Age", "Size", "Scale"}) do
		local ok, _ = pcall(function()
			model:GetAttributeChangedSignal(attr):Connect(function()
				info("Attribute %s changed: %s -> %s @ %s", attr, tostring(model:GetAttribute(attr)), tostring(model:GetAttribute(attr)), trunc(safeName(model)))
			end)
		end)
		if not ok then
			-- ignore
		end
	end

	-- Наблюдаем важные BasePart на изменение Size (масштаб по KG)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local lastSize = part.Size
			part:GetPropertyChangedSignal("Size"):Connect(function()
				local newSize = part.Size
				if (newSize - lastSize).Magnitude > 0.001 then
					info("Part resized: %s from %s to %s @ %s", trunc(part.Name), tostring(lastSize), tostring(newSize), trunc(safeName(model)))
					lastSize = newSize
				end
			end)
		end
	end

	-- Переустановка и постановка на ноги: CFrame/PivotTo/PrimaryPart
	local function hookPoseSignals(m)
		local primary = m.PrimaryPart
		if primary then
			local lastCF = primary.CFrame
			primary:GetPropertyChangedSignal("CFrame"):Connect(function()
				local cf = primary.CFrame
				if (cf.Position - lastCF.Position).Magnitude > 0.01 then
					info("Model moved: Δpos=%.2f @ %s", (cf.Position - lastCF.Position).Magnitude, trunc(safeName(m)))
					lastCF = cf
				end
			end)
		end
		m:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
			info("PrimaryPart changed on %s", trunc(safeName(m)))
			hookPoseSignals(m)
		end)
	end
	hookPoseSignals(model)
end

-- Подписываемся на все новые Model/Tool и прикручиваем глубокие наблюдатели, если это питомец
local function tryAttach(inst)
	local isPet, _ = classifyPetCandidate(inst)
	if isPet then
		local model = inst
		if inst:IsA("Tool") then
			-- если Tool, попробуем найти вложенную Model
			local subModel = inst:FindFirstChildWhichIsA("Model", true)
			model = subModel or inst
		end
		attachDeepObservers(model)
	end
end

-- Инициализация: прикрутиться к уже существующим
if backpack then
	for _, child in ipairs(backpack:GetChildren()) do tryAttach(child) end
	backpack.ChildAdded:Connect(tryAttach)
end
for _, d in ipairs(WS:GetDescendants()) do tryAttach(d) end
WS.DescendantAdded:Connect(tryAttach)

-- Наблюдение за Remote объектами (только обнаружение, без перехвата вызовов)
local function logInterestingRemotes(container)
	for _, obj in ipairs(container:GetDescendants()) do
		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
			if isKeyworded(obj.Name) then
				info("Remote discovered: %s (%s)", trunc(safeName(obj)), obj.ClassName)
			end
		end
	end
end
logInterestingRemotes(RS)
RS.DescendantAdded:Connect(function(inst)
	if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
		if isKeyworded(inst.Name) then
			info("Remote discovered: %s (%s)", trunc(safeName(inst)), inst.ClassName)
		end
	end
end)

info("PetOriginTracer_Safe initialized. Выполните выдачу питомца своим скриптом и смотрите логи здесь.")
