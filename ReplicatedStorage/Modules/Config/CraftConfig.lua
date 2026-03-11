local CraftConfig = {}

CraftConfig.Recipes = {
    {
        Id = "REFINE_OR_PUR",
        Name = "Raffiner de l'Or Pur",
        Description = "5 paillettes → 1 or pur",
        Inputs = {
            { Item = "Paillettes", Quantity = 5 },
        },
        Output = { Item = "OrPur", Quantity = 1 },
        CraftTime = 3,
        RequiredLevel = 1,
        XPReward = 10,
    },
    {
        Id = "FORGE_LINGOT",
        Name = "Forger un Lingot",
        Description = "3 or pur + 2 minerai d'or → 1 lingot",
        Inputs = {
            { Item = "OrPur", Quantity = 3 },
            { Item = "MineraiOr", Quantity = 2 },
        },
        Output = { Item = "Lingots", Quantity = 1 },
        CraftTime = 5,
        RequiredLevel = 2,
        XPReward = 30,
    },
    {
        Id = "REFINE_PEPITES",
        Name = "Raffiner des Pépites",
        Description = "2 pépites → 1 or pur",
        Inputs = {
            { Item = "Pepites", Quantity = 2 },
        },
        Output = { Item = "OrPur", Quantity = 1 },
        CraftTime = 2,
        RequiredLevel = 1,
        XPReward = 8,
    },
}

return CraftConfig
