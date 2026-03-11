local QuestConfig = {}

QuestConfig.DailyQuestPool = {
    {
        Id = "MINE_PAILLETTES_10",
        Title = "L'Or de la Rivière",
        Description = "Récupère 10 paillettes d'or",
        Type = "Collect",
        Target = "Paillettes",
        Goal = 10,
        Reward = { Cash = 30, XP = 50 },
        MinLevel = 1,
    },
    {
        Id = "MINE_PEPITES_5",
        Title = "Chercheur de Pépites",
        Description = "Récupère 5 pépites d'or",
        Type = "Collect",
        Target = "Pepites",
        Goal = 5,
        Reward = { Cash = 50, XP = 75 },
        MinLevel = 2,
    },
    {
        Id = "SELL_ITEMS_3",
        Title = "Le Commerce d'Abord",
        Description = "Effectue 3 ventes chez un marchand",
        Type = "Sell",
        Target = "AnyTransaction",
        Goal = 3,
        Reward = { Cash = 40, XP = 50 },
        MinLevel = 1,
    },
    {
        Id = "CRAFT_OR_PUR_5",
        Title = "Apprenti Forgeron",
        Description = "Raffine 5 lots d'or pur",
        Type = "Craft",
        Target = "OrPur",
        Goal = 5,
        Reward = { Cash = 60, XP = 80 },
        MinLevel = 1,
    },
    {
        Id = "MINE_GEMS_3",
        Title = "Chasseur de Gemmes",
        Description = "Trouve 3 gemmes (peu importe le type)",
        Type = "Collect",
        Target = "AnyGem",
        Goal = 3,
        Reward = { Cash = 75, XP = 100 },
        MinLevel = 2,
    },
    {
        Id = "MINE_ORE_10",
        Title = "Mineur de Fond",
        Description = "Récupère 10 minerais d'or dans la mine",
        Type = "Collect",
        Target = "MineraiOr",
        Goal = 10,
        Reward = { Cash = 80, XP = 100 },
        MinLevel = 3,
    },
    {
        Id = "EARN_CASH_200",
        Title = "Millionnaire en Herbe",
        Description = "Gagne 200$ en ventes",
        Type = "Earn",
        Target = "Cash",
        Goal = 200,
        Reward = { Cash = 50, XP = 75 },
        MinLevel = 1,
    },
}

QuestConfig.DAILY_QUEST_COUNT = 3
QuestConfig.QUEST_RESET_HOUR_UTC = 0

return QuestConfig
