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

local premiummodal = CreatureEvent("GamePassPremiumConfirm")
local STORAGE_GAMEPASS_TYPE = 92002

function premiummodal.onModalWindow(player, modalWindowId, buttonId, choiceId)
    if modalWindowId ~= 2001 or player:getStorageValue(90002) ~= 1 then
        return false
    end

    if buttonId == 1 then
        -- Confirmó activación
        if player:getItemCount(60005) >= 1 then
            player:removeItem(60005, 1)
            player:setStorageValue(STORAGE_GAMEPASS_TYPE, 2)

            if grantRetroactivePremiumRewards then
                grantRetroactivePremiumRewards(player)
            end

            player:addItem(63219, 1) -- Roulette Token como bono
            player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Felicidades! Has activado el Game Pass Premium y recibido 1 Roulette Token.")
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "No tienes el ítem necesario para activar el Premium.")
        end
    else
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Has cancelado la activación del Game Pass Premium.")
    end

    player:setStorageValue(90002, -1)
    return true
end

premiummodal:register()