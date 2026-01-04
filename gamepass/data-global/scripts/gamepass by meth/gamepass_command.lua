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

local gamepass = TalkAction("!gamepass")

function gamepass.onSay(player, words, param)
    if player:getLevel() < 75 then
        player:sendTextMessage(MESSAGE_LOOK, "Debes ser al menos nivel 75 para usar el GamePass.")
        return true
    end
	
    local level = player:getStorageValue(GamePass.storageLevel)
    if level < 0 then level = 1 end

    local data = GamePass.levels[level]
    if not data then return false end

    local killStorage = GamePass.storageKillsBase + level
    local kills = math.max(player:getStorageValue(killStorage), 0)

    local window = ModalWindow(1001, "GamePass", "Nivel: " .. level)
    window:addButton(1, "Cerrar")

    if kills >= data.kills then
        window:addButton(2, "Reclamar nivel " .. level)
        window:setDefaultEnterButton(2)
    else
        window:setDefaultEnterButton(1)
    end

    window:addButton(3, "Saltar Nivel (1 Token)")
    window:addChoice(1, "Mata " .. data.kills .. "x " .. data.monster .. " (" .. kills .. "/" .. data.kills .. ")")

    window:sendToPlayer(player)
    return false
end

gamepass:groupType("god")
gamepass:register()

local gamepassAction = Action()

function gamepassAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getLevel() < 75 then
        player:sendTextMessage(MESSAGE_LOOK, "Debes ser al menos nivel 75 para usar el GamePass.")
        return true
    end

    local level = player:getStorageValue(GamePass.storageLevel)
    if level < 0 then level = 1 end

    local data = GamePass.levels[level]
    if not data then return false end
	
	player:sendTextMessage(MESSAGE_LOOK, "Utiliza el comando !gamepass.")

    local killStorage = GamePass.storageKillsBase + level
    local kills = math.max(player:getStorageValue(killStorage), 0)
    local window = ModalWindow(1001, "GamePass", "Nivel: " .. level)
    window:addButton(1, "Cerrar")

    if kills >= data.kills then
        window:addButton(2, "Reclamar nivel " .. level)
        window:setDefaultEnterButton(2)
    else
        window:setDefaultEnterButton(1)
    end

    window:addButton(3, "Saltar Nivel (1 Token)")
    window:addChoice(1, "Mata " .. data.kills .. "x " .. data.monster .. " (" .. kills .. "/" .. data.kills .. ")")

    window:sendToPlayer(player)
    return true
end

gamepassAction:aid(28010)
gamepassAction:register()
