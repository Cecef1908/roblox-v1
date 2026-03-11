local EconomyConfig = {}

-- ============================================================
-- PRIX DE VENTE
-- ============================================================
EconomyConfig.SellPrices = {
    MarchandLocal = {
        Paillettes   = 2,
        OrPur        = 10,
        Lingots      = 50,
        Pepites      = 15,
        MineraiOr    = 5,
        Quartz       = 8,
        Amethyste    = 25,
        Topaze       = 40,
    },
    Negociant = {
        OrPur        = 13,
        Lingots      = 65,
        Amethyste    = 33,
        Topaze       = 52,
    },
}

-- ============================================================
-- XP REWARDS
-- ============================================================
EconomyConfig.XPRewards = {
    MinePaillette    = 5,
    MinePepite       = 15,
    MineMineraiOr    = 20,
    MineGem          = 25,
    MineQuartz       = 25,
    MineAmethyste    = 25,
    MineTopaze       = 25,
    CraftOrPur       = 10,
    CraftLingot      = 30,
    SellTransaction  = 5,
    QuestComplete    = 50,
    BossDefeat       = 200,
}

-- ============================================================
-- LEVEL THRESHOLDS
-- ============================================================
EconomyConfig.LevelThresholds = {
    [1] = { Name = "Amateur",      MinXP = 0,    MaxXP = 499  },
    [2] = { Name = "Orpailleur",   MinXP = 500,  MaxXP = 1999 },
    [3] = { Name = "Prospecteur",  MinXP = 2000, MaxXP = math.huge },
}

-- ============================================================
-- DROP RATES (%)
-- ============================================================
EconomyConfig.DropRates = {
    Zone1 = {
        Paillettes   = { Chance = 80, MinQty = 1, MaxQty = 3 },
        Quartz       = { Chance = 15, MinQty = 1, MaxQty = 1 },
        Pepites      = { Chance = 5,  MinQty = 1, MaxQty = 1 },
    },
    Zone2_Detecteur = {
        Pepites      = { Chance = 60, MinQty = 1, MaxQty = 2 },
        Paillettes   = { Chance = 25, MinQty = 2, MaxQty = 5 },
        Amethyste    = { Chance = 10, MinQty = 1, MaxQty = 1 },
        Topaze       = { Chance = 5,  MinQty = 1, MaxQty = 1 },
    },
    Zone2_Filon = {
        MineraiOr    = { Chance = 50, MinQty = 2, MaxQty = 4 },
        Pepites      = { Chance = 30, MinQty = 1, MaxQty = 2 },
        Amethyste    = { Chance = 15, MinQty = 1, MaxQty = 1 },
        Topaze       = { Chance = 5,  MinQty = 1, MaxQty = 1 },
    },
    Zone3 = {
        MineraiOr    = { Chance = 45, MinQty = 3, MaxQty = 6 },
        Pepites      = { Chance = 25, MinQty = 1, MaxQty = 3 },
        Amethyste    = { Chance = 15, MinQty = 1, MaxQty = 2 },
        Topaze       = { Chance = 10, MinQty = 1, MaxQty = 1 },
        Quartz       = { Chance = 5,  MinQty = 2, MaxQty = 4 },
    },
}

-- ============================================================
-- TOOL BONUSES
-- ============================================================
EconomyConfig.ToolBonuses = {
    QuantityMultiplier = {
        [1] = 1.0,
        [2] = 1.5,
        [3] = 2.0,
    },
    SpeedMultiplier = {
        [1] = 1.0,
        [2] = 0.8,
        [3] = 0.6,
    },
}

-- ============================================================
-- RESPAWN TIMERS (secondes)
-- ============================================================
EconomyConfig.RespawnTimers = {
    Zone1_GoldSpot     = 30,
    Zone2_DetectSpot   = 45,
    Zone2_Filon        = 90,
    Zone3_OreNode      = 60,
    Zone3_GemNode      = 120,
    Boss_Respawn       = 300,
}

return EconomyConfig
