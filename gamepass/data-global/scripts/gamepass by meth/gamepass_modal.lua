-- ============================================================
--  System created and developed by Meth28
--  GitHub: https://github.com/meth28
--
--  If you want to support free content,
--  you can donate at:
--  https://paypal.me/tibiana

--  More scripts and projects:
--  https://github.com/Meth28/scripts

-- ============================================================


local gamepass = CreatureEvent("Gamepass2")
-- Asumimos que GamePass está definido y cargado desde libs/gamepass.lua
local function giveRewards(player, rewards, rewardType)
    if not rewards then return end

    if rewards.exp then
        player:addExperience(rewards.exp)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has recibido una recompensa del GamePass " .. rewardType .. ": " .. rewards.exp .. " puntos de experiencia.")
    end

    -- Múltiples ítems con nombres
	if rewards.items then
    for _, entry in ipairs(rewards.items) do
        local id = entry.id
        local count = entry.count or 1
        local name = ItemType(id):getName() or "ítem desconocido"
        player:addItem(id, count)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            "Has recibido: " .. count .. "x " .. name .. " como parte del GamePass " .. rewardType .. ".")
    end
	elseif rewards.item then
    local count = rewards.count or 1
    local name = ItemType(rewards.item):getName() or "ítem desconocido"
    player:addItem(rewards.item, count)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        "Has recibido: " .. count .. "x " .. name .. " como parte del GamePass " .. rewardType .. ".")
	end

    if rewards.outfits then
        for _, outfit in ipairs(rewards.outfits) do
            local sex = player:getSex()
            local outfitId = (sex == 0) and outfit.male or outfit.female
            if outfitId then
                if not player:hasOutfit(outfitId) then
                    player:addOutfit(outfitId)
                end
                if outfit.addons then
                    if not player:hasOutfit(outfitId, outfit.addons) then
                        player:addOutfitAddon(outfitId, outfit.addons)
                    end
                end
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has recibido un atuendo del GamePass " .. rewardType .. ".")
            end
        end
    elseif rewards.outfit then
        local sex = player:getSex()
        local outfitId = (sex == 0) and rewards.outfit.male or rewards.outfit.female
        if outfitId then
            if not player:hasOutfit(outfitId) then
                player:addOutfit(outfitId)
            end
            if rewards.outfit.addons then
                if not player:hasOutfit(outfitId, rewards.outfit.addons) then
                    player:addOutfitAddon(outfitId, rewards.outfit.addons)
                end
            end
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has recibido un atuendo del GamePass " .. rewardType .. ".")
        end
    end
	
    if rewards.mounts then
        for _, mountId in ipairs(rewards.mounts) do
            if not player:hasMount(mountId) then
                player:addMount(mountId)
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has recibido una montura del GamePass " .. rewardType .. ".")
            end
        end
    elseif rewards.mount then
        if not player:hasMount(rewards.mount) then
            player:addMount(rewards.mount)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has recibido una montura del GamePass " .. rewardType .. ".")
        end
    end
end

-- Función para registrar en archivo las recompensas retroactivas entregadas
local function logGamePassRetroactive(player, level)
    local file = io.open("data/server_logs/gamepass_retroactive.log", "a")
    if not file then return end

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local name = player:getName()
    local logEntry = string.format("[%s] %s recibio recompensas retroactivas Premium del nivel %d\n", timestamp, name, level)
    file:write(logEntry)
    file:close()
end

local function grantRetroactiveRewards(player)
    local currentLevel = player:getStorageValue(GamePass.storageLevel)
    if currentLevel < 1 then currentLevel = 1 end

    for level = 1, currentLevel - 1 do
        local data = GamePass.levels[level]
        if not data then break end

        local claimedStorage = GamePass.storageClaimedBase + level
        local premiumStorage = GamePass.storagePremiumClaimedBase + level

        local claimed = player:getStorageValue(claimedStorage)
        local premiumClaimed = player:getStorageValue(premiumStorage)

        -- Solo entregamos recompensas Premium retroactivas no reclamadas
        if premiumClaimed ~= 1 then
            -- Solo si reclamó la Free (claimed == 1) o no reclamó nada (claimed ~= 1)
            -- En ambos casos entregamos solo Premium aquí
            giveRewards(player, data.rewardPremium, "Premium")
            player:setStorageValue(premiumStorage, 1)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has recibido retroactivamente la recompensa Premium del nivel " .. level .. " del GamePass.")
            logGamePassRetroactive(player, level)
        end
    end
end

function gamepass.onModalWindow(player, modalWindowId, buttonId, choiceId)
    if modalWindowId ~= 1001 then return false end

    local level = player:getStorageValue(GamePass.storageLevel)
    if level < 1 then level = 1 end

    local data = GamePass.levels[level]
    if not data then
        player:sendCancelMessage("No se han encontrado datos para este nivel.")
        return false
    end

    local killStorage = GamePass.storageKillsBase + level
    local claimedStorage = GamePass.storageClaimedBase + level
    local kills = player:getStorageValue(killStorage)
    local claimed = player:getStorageValue(claimedStorage)

    local gamePassType = player:getStorageValue(GamePass.storageGamePassType) or 1

    -- Si el jugador es Premium, entregar recompensas retroactivas Premium no reclamadas
    if gamePassType == 2 then
        grantRetroactiveRewards(player)
    end

    if buttonId == 2 then -- Reclamar recompensa
        if claimed == 1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Ya has reclamado la recompensa de este nivel.")
            return true
        end

        if kills < data.kills then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Aun no has completado los requisitos para reclamar esta recompensa.")
            return true
        end

        -- Dar recompensas Free siempre
        giveRewards(player, data.rewardFree, "Free")

        -- Si es Premium, dar recompensas Premium también
        if gamePassType == 2 then
            giveRewards(player, data.rewardPremium, "Premium")
            player:setStorageValue(GamePass.storagePremiumClaimedBase + level, 1)
        end

        -- Guardar que se reclamó y subir nivel
        player:setStorageValue(claimedStorage, 1)
        player:setStorageValue(GamePass.storageLevel, level + 1)
        player:setStorageValue(killStorage, -1)

        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Felicidades! Has subido al nivel " .. (level + 1) .. " del GamePass.")
        player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_RED)

    elseif buttonId == 3 then -- Saltar nivel con token
        if player:removeItem(43735, 1) then
            local nextLevel = level + 1
            player:setStorageValue(GamePass.storageLevel, nextLevel)

            local nextData = GamePass.levels[nextLevel]
            if nextData then
                -- Dar recompensas Free y Premium si corresponde
                giveRewards(player, nextData.rewardFree, "Free")
                if gamePassType == 2 then
                    giveRewards(player, nextData.rewardPremium, "Premium")
                    player:setStorageValue(GamePass.storagePremiumClaimedBase + nextLevel, 1)
                end

                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has avanzado al nivel " .. nextLevel .. " del GamePass usando un GamePass Token.")
                player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
            else
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "No hay datos disponibles para el siguiente nivel.")
            end
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "No tienes un GamePass Token.")
        end
    end

    return true
end

gamepass:register()
