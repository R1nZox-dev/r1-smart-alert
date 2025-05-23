# 🚨 Smart shooting Alert 

A Smart shooting Alert  system for FiveM that integrates with Google's **Gemini AI** 🤖 to analyze mugshots of unmasked shooters and generate **realistic facial descriptions** 🧑‍💼. Built for role-play realism, smart NPC detection, and performance 🧠.

**⚠️ IMPORTANT**: Since the mugshot image is sent as a small base64 string, Gemini 1.5 Flash does a surprisingly good job describing the face — but it may still struggle with perfect accuracy in some edge cases. This will improve in future versions as optimization and image input quality get better.
**PREVIEW** : https://streamable.com/83nkaz
## 📦 Installation

1. 📁 Place this resource in your resources folder.
2. ⚙️ Add `ensure r1-smart-alert-` to your `server.cfg`.
3. 🔧 Set your Gemini API key in `server/main.lua` and ur discord webhook in the `Config.lua`
4. ✅ Make sure dependencies are installed (listed below).
5. make sure to add this to the Config file into your ps-dispatch Folder >shared > Config.lua > Config.blips : 
```lua
['smart-alert'] = {
        radius = 0,
        sprite = 110,
        color = 1,
        scale = 1.0,
        length = 3,
        sound = 'Lose_1st',
        sound2 = 'GTAO_FM_Events_Soundset',
        offset = false,
        flash = false
    },
```
6. ✏️ If you're using a different mugshot or alert system, modify the exports and callbacks in client/main.lua accordingly.

---

## ✨ Features

* 🤖 Gemini 1.5 Flash API integration for image-based AI analysis
* 👤 Generates facial descriptions (gender, skin tone, hair, accessories, etc.)
* 👁️ Only triggers when nearby NPCs can clearly see the shooter
* 🎭 Skips AI if player is wearing a mask
* 🖼️ Uses base64 mugshots with Gemini’s image model
* ⏱️ Includes cooldowns (per player and per street)
* ⚡ Lightweight (avg. 0.1ms CPU usage)
* 🚓 Sends alerts to `ps-dispatch` (or custom system)

---

## 📚 Requirements
* goth girl 
* Brain 
* [Gemini-API-access]  (https://ai.google.dev/gemini-api/docs/api-key)
* [MugShotBase64] (https://github.com/BaziForYou/MugShotBase64)
* [ps-dispatch](https://github.com/Project-Sloth/ps-dispatch) or another alert system

---

## 📊 Gemini Free Tier Limits

* **15 requests/min**
* **1,500 requests/day**
* **1,000,000 input tokens/request**
* **8,000 output tokens/request**

If you need more, add funds to your Google Gemini billing account.

---

## ⚙️ Configuration

```lua
Config = {}

Config.AIEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key="
Config.ShootingCooldown = 1800 -- cooldown for repeated shooting detection
Config.AlertChance = 65 -- chance to trigger alert; lower it (e.g. 15) if you expect lots of action
Config.Debug = false -- show debug prints in console
Config.PedDetectionRadius = 35 -- NPC detection range
Config.PlayerSelectedLanguage = "english" -- default prompt language

Config.AIPrompts = {
    ["english"] = "Describe visible shooter traits: skin, face, hair, beard, hat, glasses, clothes, accessories. Start with 'The individual is' or 'has'. Be factual. Max 175 chars.",
    ["polish"] = "Opisz cechy strzelca: skóra, twarz, włosy, zarost, czapka, okulary, ubranie, dodatki. Zacznij od „Osoba jest” lub „ma”. Tylko fakty. Max 175 znaków.",
    ["spanish"] = "Describe rasgos visibles: piel, cara, cabello, barba, sombrero, gafas, ropa, accesorios. Empieza con “El individuo es” o “tiene”. Sin suposiciones. <175 caracteres.",
    ["french"] = "Décris les traits visibles: peau, visage, cheveux, barbe, chapeau, lunettes, habits, accessoires. Commence par « L’individu est » ou « a ». Max 175 caractères.",
    ["arabic"] = "صف الملامح الظاهرة: البشرة، الوجه، الشعر، اللحية، القبعة، النظارات، الملابس، الإكسسوارات. ابدأ بـ “الشخص هو” أو “يمتلك”. أقل من 175 حرفًا.",
    ["russian"] = "Опиши черты: кожа, лицо, волосы, борода, шапка, очки, одежда, аксессуары. Начни с «Человек является» или «имеет». Без догадок. До 175 символов.",
    ["portuguese"] = "Descreva traços visíveis: pele, rosto, cabelo, barba, chapéu, óculos, roupa, acessórios. Comece com “O indivíduo é” ou “tem”. Máx. 175 caracteres.",
    ["turkish"] = "Atıcının görünümü: ten, yüz, saç, sakal, şapka, gözlük, kıyafet, aksesuar. \"Birey şudur\" ya da \"vardır\" ile başla. Maks. 175 karakter. Tahmin etme.",
    ["german"] = "Beschreibe Merkmale: Haut, Gesicht, Haare, Bart, Hut, Brille, Kleidung, Accessoires. Beginne mit „Die Person ist“ oder „hat“. Max. 175 Zeichen.",
    ["dutch"] = "Beschrijf kenmerken: huid, gezicht, haar, baard, hoed, bril, kleding, accessoires. Begin met \"Het individu is\" of \"heeft\". Max. 175 tekens.",
    ["swedish"] = "Beskriv synliga drag: hud, ansikte, hår, skägg, hatt, glasögon, kläder, accessoarer. Börja med ”Individen är” eller ”har”. Max 175 tecken."
}
```

---

## 💬 Developer Notes

> I've spent a long time looking for a free AI API that works for FiveM — and Gemini 1.5 Flash is currently the best free AI model available for this use case.

>If you can afford it, I recommend adding funds to your Google Gemini wallet to go beyond the free limit of 1,500 requests/day and 15 requests/minute.

>🛡️ This script is configured carefully to avoid hitting those limits. But if you're running a heavy RP server (e.g., 200+ players and frequent gunfights), I strongly suggest setting AlertChance to 15% to stay within the free usage.

>📊 A built-in Discord log system helps you monitor request counts. If your server goes over the limit, it will warn you in Discord so you can either stop the resource temporarily or add funds to continue uninterrupted.

>⚠️ As AI platforms like Gemini may become fully paid in the future, I plan to release a version using a home-hosted AI model. It won't match Gemini's quality, but it'll be a functional free alternative for basic RP scenarios.

>❌ Do not sell or publish "inspired" versions of this script — especially if the core logic is simple.
>⭐ For support, just star this GitHub repository. If you're building something better, please give credit.
>💬 For updates, suggestions, or issues — contact me directly on Discord: @ice4ice

---

## 🔔 Discord Log & Warnings

The system includes a **Discord logger** to:

* Track the number of AI requests made
* Warn you if you're about to exceed the **free limit**
* Recommend stopping the resource or upgrading Gemini access if needed

---

## 🛠️ Future

AI services are becoming paid — so I'll provide a **self-hosted alternative** soon. It won't match Gemini’s power, but it will be free and usable for light RP servers.

---

Enjoy the system. **R1nzox is passion , Only for YOU**  🚨

## STATS 

![Clones](https://raw.githubusercontent.com/R1nZox-dev/r1-smart-alert/main/stats/clones.svg)



