----https://github.com/Meth28/scripts
----Meth28
----Do you want to support? https://paypal.me/tibiana

local internalNpcName = "[Lunera-Roulette]"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{text = 'Hello adventurer, Are you looking for bets? Tell me Bet'}
}

npcConfig.health = 100
npcConfig.maxHealth = 100
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
    lookType = 1211,
	lookAddons = 3,
	lookMount = 0
}

npcConfig.flags = {
    floorchange = false,
}

local SPIN_INTERVAL = 500
local SPIN_STEPS = 12
local EFFECTS = {
    red   = CONST_ME_FIREAREA,
    black = CONST_ME_MORTAREA,
    green = CONST_ME_CARNIPHILA
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local playerBets = {}

local function spinRoulette(player, colorChoice, amount)
    local uid = player:getId()
    local pos = Position(player:getPosition().x, player:getPosition().y - 1, player:getPosition().z)
    local step = 1

    local function nextStep()
        if step > SPIN_STEPS then
            local finalColor
            local roll = math.random(1, 100)
            if colorChoice == "green" then
                if roll <= 10 then
                    finalColor = "green"
                else
                    finalColor = (math.random(1, 2) == 1) and "red" or "black"
                end
            else
                if roll <= 45 then
                    finalColor = colorChoice
                else
                    local otherColors = {"red", "black"}
                    repeat
                        finalColor = otherColors[math.random(#otherColors)]
                    until finalColor ~= colorChoice
                end
            end

            doSendMagicEffect(pos, EFFECTS[finalColor])

            local playerFinal = Player(uid)
            if not playerFinal then return end

            if finalColor == colorChoice then
                local reward = (finalColor == "green") and amount * 14 or amount * 2
                playerFinal:addTransferableCoins(reward)
                playerFinal:sendTextMessage(MESSAGE_LOOK, "| The ball landed on " .. finalColor .. "! You WON " .. reward .. " Tibia Coins! |")

                GameStore.insertHistory(playerFinal:getAccountId(), GameStore.HistoryTypes.HISTORY_TYPE_NONE, 
                    "You won on the roulette and received " .. reward .. " transferable tibia coins.", reward, GameStore.CoinType.Transferable)
            else
                playerFinal:sendTextMessage(MESSAGE_ADMINISTRATOR, "| The ball landed on " .. finalColor .. ". You LOST " .. amount .. " Tibia Coins. |")

                GameStore.insertHistory(playerFinal:getAccountId(), GameStore.HistoryTypes.HISTORY_TYPE_NONE, 
                    "You lost on the roulette and spent " .. amount .. " transferable tibia coins.", -amount, GameStore.CoinType.Transferable)
            end
            return
        end

        local colors = {"red","black","green"}
        local effectColor = colors[math.random(#colors)]
        doSendMagicEffect(pos, EFFECTS[effectColor])

        step = step + 1
        addEvent(nextStep, SPIN_INTERVAL)
    end

    nextStep()
end

npcType.onThink = function(npc, interval)
    npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
    npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
    npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
    npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
    npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
    npcHandler:onCloseChannel(npc, creature)
end

npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME| Are you looking for bets? say me {bet}.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "See you later |PLAYERNAME| come back soon.")


local function greetCallback(npc, creature)
    local playerId = creature:getId()
    npcHandler:setTopic(playerId, 1)
    npcHandler:say("Hello " .. creature:getName() .. "! Which color do you want to bet on? {red}, {black} or {green}?", npc, creature)
    return true
end
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

local function creatureSayCallback(npc, creature, type, msg)
    local player = Player(creature)
    if not player then return false end
    local playerId = player:getId()
    msg = msg:lower()

    if not npcHandler:checkInteraction(npc, creature) then
        return false
    end

    local topic = npcHandler:getTopic(playerId)

    if msg == "bet" and topic == 0 then
        npcHandler:setTopic(playerId, 1)
        npcHandler:say("Which color do you want to bet on? {red}, {black} or {green}?", npc, creature)
        return true
    end

    if topic == 1 then
        if msg == "red" or msg == "black" or msg == "green" then
            playerBets[playerId] = { color = msg }
            npcHandler:say("How many Tibia Coins do you want to bet?", npc, creature)
            npcHandler:setTopic(playerId, 2)
        else
            npcHandler:say("Please choose {red}, {black} or {green}.", npc, creature)
        end
        return true
    end

    if topic == 2 then
        local amount = tonumber(msg)
        if amount and amount > 0 then
            if player:getTransferableCoins() < amount then
                npcHandler:say("You don't have enough Tibia Coins.", npc, creature)
                npcHandler:setTopic(playerId, 0)
                playerBets[playerId] = nil
                return true
            end
            playerBets[playerId].amount = amount
            local potentialWin = (playerBets[playerId].color == "green") and amount * 14 or amount * 2
            npcHandler:say("If you win, you will get " .. potentialWin .. " Tibia Coins. Confirm? {yes} or {no}", npc, creature)
            npcHandler:setTopic(playerId, 3)
        else
            npcHandler:say("Please say a valid number.", npc, creature)
        end
        return true
    end

    if topic == 3 then
        if msg == "yes" then
            local bet = playerBets[playerId]
            if player:removeTransferableCoins(bet.amount) then
                npcHandler:say("Spinning the wheel for " .. bet.color .. " with " .. bet.amount .. " coins...", npc, creature)
                spinRoulette(player, bet.color, bet.amount)
            else
                npcHandler:say("You don't have enough Tibia Coins.", npc, creature)
            end
            npcHandler:setTopic(playerId, 0)
            playerBets[playerId] = nil
        elseif msg == "no" then
            npcHandler:say("Bet canceled.", npc, creature)
            npcHandler:setTopic(playerId, 0)
            playerBets[playerId] = nil
        end
        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
