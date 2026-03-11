local ToolConfig = {}

ToolConfig.Tools = {
    Batee = {
        DisplayName = "Batée",
        Description = "Permet de tamiser l'or dans la rivière",
        Category = "Mining",
        RequiredZones = { "Zone1", "Zone2" },
        BaseActionTime = 5,
        Levels = {
            [1] = { Name = "Batée en Bois",   BuyPrice = 0,   UpgradePrice = nil },
            [2] = { Name = "Batée en Cuivre",  BuyPrice = nil, UpgradePrice = 150 },
            [3] = { Name = "Batée en Fer",     BuyPrice = nil, UpgradePrice = 500 },
        },
    },
    Tapis = {
        DisplayName = "Tapis de Prospection",
        Description = "Tapis pour filtrer les sédiments — meilleur rendement",
        Category = "Mining",
        RequiredZones = { "Zone1", "Zone2" },
        BaseActionTime = 8,
        Levels = {
            [1] = { Name = "Tapis Basique",   BuyPrice = 100, UpgradePrice = nil },
            [2] = { Name = "Tapis Amélioré",  BuyPrice = nil, UpgradePrice = 300 },
            [3] = { Name = "Tapis Pro",       BuyPrice = nil, UpgradePrice = 800 },
        },
    },
    Pioche = {
        DisplayName = "Pioche",
        Description = "Pour miner les filons et le minerai dans la mine",
        Category = "Mining",
        RequiredZones = { "Zone2", "Zone3" },
        BaseActionTime = 4,
        Levels = {
            [1] = { Name = "Pioche en Bois",  BuyPrice = 200, UpgradePrice = nil },
            [2] = { Name = "Pioche en Fer",   BuyPrice = nil, UpgradePrice = 600 },
            [3] = { Name = "Pioche en Acier", BuyPrice = nil, UpgradePrice = 1500 },
        },
    },
}

return ToolConfig
