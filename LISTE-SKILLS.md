# Mes skills Claude Code

Export du 25/11/2026. Pour tout réinstaller sur une autre machine Windows, dézippe ce dossier puis lance dans PowerShell :

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -WithGstack
```

Prérequis : Git, Node.js et Claude Code installés, Claude Code connecté au compte. Sans `-WithGstack`, tout est installé sauf gstack.

## Plugins (mise à jour automatique)

| Plugin | Source | Contenu |
|---|---|---|
| caveman | github.com/juliusbrussee/caveman | Réponses courtes, économie de tokens (actif en permanence, hooks) |
| instagram-agent | github.com/Jakeschincariol/instagram-agent-skill | 13 skills Instagram : reel, caption, carousel, story, plan, viral, profil... |
| humanizer | github.com/blader/humanizer | Retire le style « écrit par une IA » |
| taste-skill | github.com/leonxlnx/taste-skill | Design de sites web haut de gamme |
| mattpocock-skills | github.com/mattpocock/skills | Ingénierie : TDD, diagnostic de bugs, revue, spec, PR... |
| no-limit | github.com/longmaba/no-limit | Plugin déjà présent sur la machine d'origine |
| claude-seo | github.com/AgriciDaniel/claude-seo | SEO complet : 29 sous-skills et 20 agents (technique, contenu, schema, Core Web Vitals, local, GEO/IA...). Après install, lancer `/seo setup` une fois (Python 3.11+) |
| andrej-karpathy-skills | github.com/forrestchang/andrej-karpathy-skills | Règles tirées des remarques d'Andrej Karpathy sur les erreurs de code des LLM |
| i-have-adhd | github.com/ayghri/i-have-adhd | Réponses faciles à lire (format adapté au TDAH, utile pour tous) |
| ponytail | github.com/DietrichGebert/ponytail | Posture « senior dev paresseux » : moins de code, audit, revue, dette technique, suivi du coût par tâche. Webhook laissé vide : rien ne sort de la machine |
| superpowers | github.com/obra/superpowers | Méthode de travail : brainstorming, plan, TDD, sous-agents. Télémétrie coupée (`SUPERPOWERS_DISABLE_TELEMETRY=1`) |
| unslop | github.com/heydamir/unslop | Transforme une interface « générée par IA » en design avec du caractère |
| ecc | github.com/affaan-m/ECC | Gros pack d'agents, skills, commandes et hooks qualité. Appelle parfois Haiku (forfait) |

## Synchronisés avec le compte claude.ai (rien à installer)

Ils arrivent tout seuls dès que Claude Code est connecté au compte de l'organisation.

- **marketing** et **marketing-skills** : CRO, copywriting, SEO, ads, emails, pricing, lancement...
- **social-media-skills** : TikTok, Instagram, LinkedIn, YouTube, X, Pinterest, outils IA image/vidéo/voix...
- **anthropic-skills** : docx, pdf, pptx, xlsx, docs, skill-creator...

## Skills copiés depuis GitHub

- **Emil Kowalski** (github.com/emilkowalski/skills), 20 skills : animate, animate-expo, animation-performance, animation-vocabulary, apple-design, ask-emil, ask-sonner, break-ui, choreograph, emil-design-eng, find-animation-opportunities, gestures, improve-animations, learn-taste, mobile-native, pick-ui-library, prototype, remove-animations, review-animations, write-swift
- **Vercel** (github.com/vercel-labs/agent-skills), 9 skills : composition-patterns, deploy-to-vercel, react-best-practices, react-native-skills, react-view-transitions, vercel-cli-with-tokens, vercel-optimize, web-design-guidelines, writing-guidelines
- **Playwright CLI** (npm `@playwright/cli`) : skill playwright-cli

## Outils en ligne de commande (installés par `install.ps1`)

Règle : aucune API payante. Aucune clé (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GROQ_API_KEY`...) n'est configurée.

- **uv** (winget `astral-sh.uv`) : installe les outils Python ci-dessous.
- **SkillSpector** (NVIDIA) : scanner de sécurité de skills. Toujours lancer `skillspector scan <chemin> --no-llm`.
- **graphify** : transforme un projet en graphe de connaissances. `GRAPHIFY_BACKEND=none` est posé pour qu'il n'utilise jamais une clé API.
- **agent-reach** : lecture de GitHub, YouTube, Reddit, web... Installé depuis GitHub (le paquet PyPI du même nom n'est pas le bon). Ne pas ajouter `xiaoyuzhou` (clé Groq payante).
- **agent-desktop** (Vercel, npm) : pilote les applications du bureau Windows. Skills `agent-desktop` et `agent-desktop-windows`.
- **obscura** : navigateur headless (binaire Windows officiel, empreinte SHA-256 vérifiée) et son skill.

## Refusés après audit de sécurité

- **claude-octopus** : lit et réécrit le jeton de connexion Claude, peut utiliser des clés API payantes.
- **claude-mem** : appelle Haiku après chaque action (forte conso du forfait), télémétrie et mise à jour automatique actives par défaut.

## gstack (option `-WithGstack`)

github.com/garrytan/gstack, environ 60 skills préfixés `gstack-` : office-hours, plan-ceo-review, plan-eng-review, review, ship, qa, design-review, design-consultation, cso, document-generate, retro, make-pdf, diagram...

- Installe Bun (gratuit) et ajoute des hooks à Claude Code (routage, garde-fou des commandes destructives).
- `gstack-cso` en natif Windows demande Visual Studio 2022 Build Tools (charge C++) :
  ```powershell
  winget install --id Microsoft.VisualStudio.2022.BuildTools -e --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
  ```
  puis relancer `./setup --prefix` dans `~/.claude/skills/gstack`.

## Skills maison (inclus dans ce zip)

- **gestionnaire-de-skill-dc** : choisit tout seul le modèle, le mode de réponse et l'enchaînement de skills pour chaque demande en français. Activé par la règle du `CLAUDE.md` fourni.
- **cso-linux** : lance les audits de sécurité gstack dans une VM Ubuntu (WSL2) pour le mode avancé avec Docker.
- **design-md** : 84 fichiers DESIGN.md de référence (Apple, Airbnb...) copiés dans `~/.claude/design-md`.

### Mettre en place la VM pour cso-linux (manuel, droits admin)

1. PowerShell en administrateur :
   ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   winget install --id Microsoft.WSL -e
   ```
2. Redémarrer le PC.
3. Installer Ubuntu (sur un disque qui a de la place, par exemple D:) :
   ```powershell
   wsl --install -d Ubuntu-24.04 --no-launch
   wsl --manage Ubuntu-24.04 --move D:\WSL\Ubuntu
   ```
4. Dans Ubuntu (en root) : installer `git curl unzip build-essential docker.io`, Node 22 (depuis nodejs.org), Bun (`npm i -g bun`), puis gstack :
   ```bash
   git clone --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
   cd ~/.claude/skills/gstack && GSTACK_CSO_IMAGE_PULL_TIMEOUT_SECONDS=300 ./setup --prefix --no-skill-routing --no-skill-contracts --no-destructive-guard
   ```
5. Vérifier depuis Windows : `bash ~/.claude/skills/cso-linux/cso-wsl.sh status`

Prévoir environ 15 Go pour la VM et les images Docker.
