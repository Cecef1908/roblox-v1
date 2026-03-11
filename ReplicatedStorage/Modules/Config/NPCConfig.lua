local NPCConfig = {}

NPCConfig.NPCs = {
    Marchand = {
        DisplayName = "Marcel le Marchand",
        Location = "HubCentral",
        Type = "Buyer",
        Dialogue = {
            Greeting = "Bonjour voyageur ! Tu as de l'or à vendre ?",
            NoItems = "Reviens quand tu auras quelque chose pour moi !",
            Success = "Marché conclu ! Voici tes %d$ !",
        },
        BuysAll = true,
        PriceTable = "MarchandLocal",
        ProximityMaxDistance = 10,
        ProximityActionText = "Vendre",
    },
    Negociant = {
        DisplayName = "Pierre le Négociant",
        Location = "HubCentral",
        Type = "Buyer",
        Dialogue = {
            Greeting = "Je ne prends que la qualité. Or pur, lingots, gemmes nobles.",
            NoItems = "Rien d'intéressant ? Reviens avec du raffiné.",
            Success = "Excellent ! %d$ pour ces merveilles !",
        },
        BuysAll = false,
        AcceptedItems = { "OrPur", "Lingots", "Amethyste", "Topaze" },
        PriceTable = "Negociant",
        ProximityMaxDistance = 10,
        ProximityActionText = "Négocier",
    },
    Vendeur = {
        DisplayName = "Jacques l'Outilleur",
        Location = "HubCentral",
        Type = "ShopKeeper",
        Dialogue = {
            Greeting = "Bienvenue ! J'ai les meilleurs outils de la région !",
            NotEnoughCash = "Tu n'as pas assez d'argent, reviens plus tard.",
            Purchase = "Bon choix ! Prends-en soin !",
            MaxLevel = "Cet outil est déjà au maximum !",
        },
        ProximityMaxDistance = 10,
        ProximityActionText = "Acheter",
    },
    Forgeron = {
        DisplayName = "Gustave le Forgeron",
        Location = "HubCentral",
        Type = "Crafter",
        Dialogue = {
            Greeting = "Apporte-moi du minerai, je te ferai de l'or pur !",
            NoMaterials = "Il te manque des matériaux.",
            Success = "Et voilà ! Du beau travail !",
        },
        ProximityMaxDistance = 8,
        ProximityActionText = "Forger",
    },
    Barman = {
        DisplayName = "Bill le Barman",
        Location = "HubCentral.Saloon",
        Type = "Saloon",
        Dialogue = {
            Greeting = "Bienvenue au Saloon ! Un remontant ?",
            MaxDrinks = "T'as assez bu pour aujourd'hui, cow-boy.",
            BuffActive = "Tu as déjà un boost actif !",
            Serve = "Santé ! Tu te sens %s pendant %d minutes !",
        },
        ProximityMaxDistance = 8,
        ProximityActionText = "Boire un verre",
    },
    Guide = {
        DisplayName = "Tom le Guide",
        Location = "Zone1_RiviereTransquille",
        Type = "Tutor",
        Dialogue = {
            Step1 = "Bienvenue, nouveau ! Je vais t'apprendre à chercher de l'or. Approche-toi de la rivière !",
            Step2 = "Vois ces reflets dans l'eau ? Utilise ta batée là-bas. Appuie sur E !",
            Step3 = "Bravo ! Tu as trouvé des paillettes ! Maintenant, tourne la batée pour filtrer...",
            Step4 = "Super ! Tu peux vendre ça au marchand en ville, ou le raffiner à la forge !",
            Step5 = "Continue à miner. Quand tu seras Orpailleur, les Collines t'ouvriront leurs secrets...",
            Complete = "Tu te débrouilles bien ! La rivière est à toi maintenant.",
        },
        ProximityMaxDistance = 12,
        ProximityActionText = "Parler",
    },
}

return NPCConfig
