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

--[[ Nivel de ejemplo (puedes activarlo si lo necesitas):
[99] = {
    kills = 70,
    monster = "demon",
    rewardFree = {
        mount = 52  -- ID de la mount (por ejemplo: 52 = Shadow Draptor)
    },
    rewardPremium = {
        outfit = {
            male = 130,     -- ID de outfit masculino
            female = 126,   -- ID de outfit femenino
            addons = 2      -- número de addons a dar (0 a 3)
        },
        exp = 100000
    }
}
--- new code multiple reward

[40] = {
    kills = 600,
    monster = "Final Boss",
    rewardFree = {
        items = {
            { id = 2160, count = 5 },
            { id = 6527, count = 1 }
        }
    },
    rewardPremium = {
        outfits = {
            { male = 1300, female = 1301 },
            { male = 1288, female = 1289, addons = 3 }
        },
        mounts = { 135, 144 }
    }
}

]]

GamePass = {
    levels = {
        [1] = {
            kills = 60,
            monster = "rat",
            rewardFree = { exp = 10000 },
            rewardPremium = { exp = 5000 }
        },
        [2] = {
            kills = 80,
            monster = "orc",
            rewardFree = { item = 3043, count = 3 },
            rewardPremium = { exp = 5000 }
        },
        [3] = {
            kills = 100,
            monster = "cyclops",
            rewardFree = { item = 3043, count = 15 },
            rewardPremium = { exp = 20000 }
        },
        [4] = {
            kills = 120,
            monster = "dragon hatchling",
            rewardFree = { mount = 13 },
            rewardPremium = { item = 60006, count = 2, exp = 5000 }
        },
        [5] = {
            kills = 20,
            monster = "scorpion",
            rewardFree = { item = 60006, count = 1 },
            rewardPremium = { item = 3043, count = 5, exp = 5000 }
        },
        [7] = {
            kills = 2000,
            monster = "Mega Dragon",
            rewardFree = { item = 60006, count = 20, exp = 80000 },
            rewardPremium = {
                outfit = {
                    male = 1288,
                    female = 1289,
                    addons = 2
                }
            }
        }
    },
    storageLevel = 92000,
    storageKillsBase = 92001,
    storageGamePassType = 92002, -- 1 = Free, 2 = Premium
    storageClaimedBase = 92050,
	storagePremiumClaimedBase = 92100
}
