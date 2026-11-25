# Installe tous les skills Claude Code de cette configuration sur une nouvelle machine Windows.
#
# Prérequis : Git, Node.js (avec npm) et Claude Code installés, et Claude Code connecté à ton compte.
#
# Utilisation (dans PowerShell, depuis le dossier dézippé) :
#   powershell -ExecutionPolicy Bypass -File .\install.ps1               # tout sauf gstack
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -WithGstack   # avec gstack (installe aussi Bun)

param([switch]$WithGstack)

$ErrorActionPreference = 'Continue'
$Here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Claude  = Join-Path $env:USERPROFILE '.claude'
$Skills  = Join-Path $Claude 'skills'
$Tmp     = Join-Path $env:TEMP ("claude-skills-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Force $Skills, $Tmp | Out-Null

function Step($t) { Write-Host "`n=== $t" -ForegroundColor Cyan }
function Need($cmd) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Host "Manquant : $cmd. Installe-le puis relance le script." -ForegroundColor Red; exit 1
  }
}

Step 'Vérification des prérequis'
Need git; Need node; Need npm; Need claude

# 1. Plugins (se mettent à jour tout seuls)
Step 'Plugins'
$plugins = @(
  @{ repo = 'juliusbrussee/caveman';                 id = 'caveman@caveman' },
  @{ repo = 'Jakeschincariol/instagram-agent-skill'; id = 'instagram-agent@instagram-agent-skill' },
  @{ repo = 'blader/humanizer';                      id = 'humanizer@humanizer' },
  @{ repo = 'leonxlnx/taste-skill';                  id = 'taste-skill@taste-skill' },
  @{ repo = 'mattpocock/skills';                     id = 'mattpocock-skills@mattpocock' },
  @{ repo = 'longmaba/no-limit';                     id = 'no-limit@longmaba-mods' }
)
foreach ($p in $plugins) {
  claude plugin marketplace add $p.repo
  claude plugin install $p.id
}

# 2. Skills copiés depuis GitHub (Emil Kowalski, Vercel)
Step 'Skills Emil Kowalski et Vercel'
git clone -q --depth 1 https://github.com/emilkowalski/skills.git "$Tmp\emil"
git clone -q --depth 1 https://github.com/vercel-labs/agent-skills.git "$Tmp\vercel"
foreach ($src in @("$Tmp\emil\skills", "$Tmp\vercel\skills")) {
  Get-ChildItem $src -Directory | ForEach-Object {
    $dest = Join-Path $Skills $_.Name
    if (Test-Path $dest) { Write-Host "  déjà présent : $($_.Name)" }
    else { Copy-Item $_.FullName $dest -Recurse; Write-Host "  + $($_.Name)" }
  }
}

# 3. Playwright CLI + son skill
Step 'Playwright CLI'
npm install -g @playwright/cli@latest
Push-Location $env:USERPROFILE; playwright-cli install --skills; Pop-Location

# 4. Skills maison (gestionnaire DC, pont CSO) et bibliothèque DESIGN.md
Step 'Skills maison et DESIGN.md'
foreach ($n in @('gestionnaire-de-skill-dc', 'cso-linux')) {
  Copy-Item (Join-Path $Here "skills\$n") (Join-Path $Skills $n) -Recurse -Force
  Write-Host "  + $n"
}
Copy-Item (Join-Path $Here 'design-md') (Join-Path $Claude 'design-md') -Recurse -Force
Write-Host '  + design-md (84 références)'

# 5. CLAUDE.md global (sauvegarde de l'existant)
Step 'CLAUDE.md global'
$cm = Join-Path $Claude 'CLAUDE.md'
if (Test-Path $cm) {
  $bak = "$cm.bak-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
  Copy-Item $cm $bak
  Write-Host "  CLAUDE.md existant sauvegardé : $bak"
  Add-Content -Path $cm -Value ("`n" + (Get-Content (Join-Path $Here 'CLAUDE.md') -Raw)) -Encoding UTF8
  Write-Host '  règles ajoutées à la fin du CLAUDE.md existant'
} else {
  Copy-Item (Join-Path $Here 'CLAUDE.md') $cm
  Write-Host '  CLAUDE.md créé'
}

# 6. gstack (optionnel)
if ($WithGstack) {
  Step 'gstack'
  if (-not (Get-Command bun -ErrorAction SilentlyContinue)) { npm install -g bun@latest }
  $g = Join-Path $Skills 'gstack'
  if (-not (Test-Path $g)) { git clone -q --single-branch --depth 1 https://github.com/garrytan/gstack.git $g }
  $bash = 'C:\Program Files\Git\bin\bash.exe'
  if (Test-Path $bash) { & $bash -lc "cd ~/.claude/skills/gstack && ./setup --prefix" }
  else { Write-Host '  Git Bash introuvable : lance ./setup --prefix à la main dans ~/.claude/skills/gstack' -ForegroundColor Yellow }
}

Remove-Item $Tmp -Recurse -Force -ErrorAction SilentlyContinue
Step 'Terminé'
Write-Host 'Ouvre une nouvelle session Claude Code pour charger les plugins.'
Write-Host 'Les skills marketing, social-media et anthropic se synchronisent tout seuls avec ton compte claude.ai.'
if (-not $WithGstack) { Write-Host 'gstack non installé (relance avec -WithGstack si besoin).' }
Write-Host "Audits de sécurité avancés (VM Ubuntu) : voir LISTE-SKILLS.md, section 'cso-linux'."
