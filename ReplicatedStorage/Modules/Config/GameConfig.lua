local GameConfig = {}

-- ============================================================
-- CONSTANTES GLOBALES
-- ============================================================
GameConfig.MAX_INVENTORY_SLOTS = 100
GameConfig.AUTO_SAVE_INTERVAL = 60
GameConfig.DATASTORE_NAME = "GoldRush_PlayerData_V1"

-- ============================================================
-- SALOON
-- ============================================================
GameConfig.Saloon = {
    MaxDrinksPerDay = 3,
    DrinkCost = 15,

    Drinks = {
        {
            Id = "WHISKEY_VITESSE",
            Name = "Whiskey du Mineur",
            Description = "+20% vitesse de minage pendant 5 min",
            BuffType = "SpeedBoost",
            BuffValue = 0.20,
            Duration = 300,
            Cost = 15,
        },
        {
            Id = "BIERE_CHANCE",
            Name = "Bière Porte-Bonheur",
            Description = "+15% chance de gemmes pendant 5 min",
            BuffType = "LuckBoost",
            BuffValue = 0.15,
            Duration = 300,
            Cost = 20,
        },
    },

    DayNight = {
        CycleDuration = 720,
        DayRatio = 0.6,
        NightRatio = 0.4,
        NightDrinkDiscount = 0.20,
    },
}

-- ============================================================
-- BOSS
-- ============================================================
GameConfig.Boss = {
    GardienMine = {
        DisplayName = "Le Gardien de la Mine",
        Health = 500,
        Damage = 15,
        AttackInterval = 2,
        MoveSpeed = 12,
        AggroRange = 30,
        LeashRange = 50,
        SpawnCooldown = 300,

        Attacks = {
            { Name = "Coup de Pioche", Damage = 15, Range = 5, Cooldown = 2 },
            { Name = "Éboulement", Damage = 25, Range = 15, Cooldown = 10 },
        },

        Rewards = {
            Cash = 200,
            XP = 200,
            Drops = {
                { Item = "Lingots", Quantity = 2, Chance = 100 },
                { Item = "Topaze", Quantity = 1, Chance = 50 },
                { Item = "Amethyste", Quantity = 2, Chance = 75 },
            },
        },

        HealthBarVisible = true,
    },
}

return GameConfig
