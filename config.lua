Config = {}

Config.AIEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" -- incase u change  AI model put endpoint URL

    -- Cooldown time (in seconds) for the shooting detection logic per player.
Config.ShootingCooldown = 1800
    -- Percentage chance (0-100) that an alert will be sent. Helps to avoid too many alerts. do not change this so you dont cross the request limite
Config.AlertChance = 65
    -- Debug mode (true/false).  Prints messages to the client console.
Config.Debug = true
Config.TagEveryoneThreshold = 1400 -- The request number at which to tag @everyone
    -- Ped detection radius (in game units) to check for nearby NPCs.
Config.PedDetectionRadius = 35
    -- Maximum distance (in game units) for the raycast to check line of sight to an NPC.
Config.PlayerSelectedLanguage = "english" -- Set the default or selected language here
Config.DiscordWebhookURL = 'https://discord.com/api/webhooks/your_webhook_url_here' -- Replace with your actual Discord webhook URL
Config.AIPrompts = {
    -- English
    ["english"] = "Describe visible shooter traits: skin, face, hair, beard, hat, glasses, clothes, accessories. Start with 'The individual is' or 'has'. Be factual. Max 175 chars.",

    -- Polish
    ["polish"] = "Opisz cechy strzelca: skóra, twarz, włosy, zarost, czapka, okulary, ubranie, dodatki. Zacznij od „Osoba jest” lub „ma”. Tylko fakty. Max 175 znaków.",

    -- Spanish
    ["spanish"] = "Describe rasgos visibles: piel, cara, cabello, barba, sombrero, gafas, ropa, accesorios. Empieza con “El individuo es” o “tiene”. Sin suposiciones. <175 caracteres.",

    -- French
    ["french"] = "Décris les traits visibles: peau, visage, cheveux, barbe, chapeau, lunettes, habits, accessoires. Commence par « L’individu est » ou « a ». Max 175 caractères.",

    -- Arabic
    ["arabic"] = "صف الملامح الظاهرة: البشرة، الوجه، الشعر، اللحية، القبعة، النظارات، الملابس، الإكسسوارات. ابدأ بـ “الشخص هو” أو “يمتلك”. أقل من 175 حرفًا.",

    -- Russian
    ["russian"] = "Опиши черты: кожа, лицо, волосы, борода, шапка, очки, одежда, аксессуары. Начни с «Человек является» или «имеет». Без догадок. До 175 символов.",

    -- Portuguese
    ["portuguese"] = "Descreva traços visíveis: pele, rosto, cabelo, barba, chapéu, óculos, roupa, acessórios. Comece com “O indivíduo é” ou “tem”. Máx. 175 caracteres.",

    -- Turkish
    ["turkish"] = "Atıcının görünümü: ten, yüz, saç, sakal, şapka, gözlük, kıyafet, aksesuar. \"Birey şudur\" ya da \"vardır\" ile başla. Maks. 175 karakter. Tahmin etme.",

    -- German
    ["german"] = "Beschreibe Merkmale: Haut, Gesicht, Haare, Bart, Hut, Brille, Kleidung, Accessoires. Beginne mit „Die Person ist“ oder „hat“. Max. 175 Zeichen.",

    -- Dutch
    ["dutch"] = "Beschrijf kenmerken: huid, gezicht, haar, baard, hoed, bril, kleding, accessoires. Begin met \"Het individu is\" of \"heeft\". Max. 175 tekens.",

    -- Swedish
    ["swedish"] = "Beskriv synliga drag: hud, ansikte, hår, skägg, hatt, glasögon, kläder, accessoarer. Börja med ”Individen är” eller ”har”. Max 175 tecken."
}


