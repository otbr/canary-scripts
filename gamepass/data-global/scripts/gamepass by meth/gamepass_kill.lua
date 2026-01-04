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

local gamepass = CreatureEvent("Gamepass")

function gamepass.onKill(player, target)
    if not target or not target:isMonster() then
        return true
    end

    -- Permitir también si el target es boss
    if not target:isMonster() and not target:isBoss() then
        return true
    end

    -- Obtener lista de jugadores que participaron en la kill (party o daño compartido)
    local participants = {}
    if player:getParty() then
        participants = player:getParty():getMembers()
        table.insert(participants, player) -- agregar también al killer
    else
        participants = {player}
    end

    -- Recorremos los jugadores involucrados
    for _, member in ipairs(participants) do
        if member and member:isPlayer() then
            local level = member:getStorageValue(GamePass.storageLevel)
            if level < 0 then level = 1 end

            local data = GamePass.levels[level]
            if not data then
                goto continue
            end

            -- Comparación flexible por nombre (ignora mayúsculas/minúsculas)
            if target:getName():lower() ~= data.monster:lower() then
                goto continue
            end

            local killStorage = GamePass.storageKillsBase + level
            local kills = math.max(member:getStorageValue(killStorage), 0)
            kills = kills + 1
            member:setStorageValue(killStorage, kills)

            if kills == data.kills then
                member:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                    "¡Has completado el nivel " .. level .. " del GamePass!")
            end

            ::continue::
        end
    end

    return true
end

gamepass:register()
