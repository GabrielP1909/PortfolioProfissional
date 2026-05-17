$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

New-Item -ItemType Directory -Force -Path src\pages\partials, assets\js | Out-Null

# Split CSS into category files
$cssPath = 'assets\css\style.css'
$cssLines = Get-Content $cssPath -Raw -Encoding UTF8 | Out-String -Split "\r?\n"

function GetStart($idx) {
    while ($idx -gt 0 -and $cssLines[$idx] -notmatch '^\s*/\*') {
        $idx--
    }
    return $idx
}

$markers = @{
    header = 'HEADER'
    layout = 'LAYOUT'
    hero = 'HERO'
    services = 'SERVICES'
    portfolio = 'PORTFOLIO'
    process = 'PROCESS'
    testimonials = 'TESTIMONIALS'
    stack = 'STACK'
    contact = 'CONTACT'
    footer = 'FOOTER'
    responsive = 'RESPONSIVE — Tablet'
}
$pos = @{}
for ($i = 0; $i -lt $cssLines.Count; $i++) {
    foreach ($k in $markers.Keys) {
        if ($cssLines[$i] -match '^\s*' + [regex]::Escape($markers[$k]) + '\s*$') {
            $pos[$k] = GetStart $i
        }
    }
}

$sections = @(
    @{name='base.css'; start=0; end=$pos['header'] - 1},
    @{name='header.css'; start=$pos['header']; end=$pos['layout'] - 1},
    @{name='hero.css'; start=$pos['hero']; end=$pos['services'] - 1},
    @{name='services.css'; start=$pos['services']; end=$pos['portfolio'] - 1},
    @{name='portfolio.css'; start=$pos['portfolio']; end=$pos['process'] - 1},
    @{name='process.css'; start=$pos['process']; end=$pos['testimonials'] - 1},
    @{name='testimonials.css'; start=$pos['testimonials']; end=$pos['stack'] - 1},
    @{name='stack.css'; start=$pos['stack']; end=$pos['contact'] - 1},
    @{name='contact.css'; start=$pos['contact']; end=$pos['footer'] - 1},
    @{name='footer.css'; start=$pos['footer']; end=$pos['responsive'] - 1},
    @{name='responsive.css'; start=$pos['responsive']; end=$cssLines.Count - 1}
)

foreach ($sec in $sections) {
    $out = "assets\css\$($sec.name)"
    $cssLines[$sec.start..$sec.end] | Set-Content $out -Encoding UTF8
}

@'
@import url("base.css");
@import url("header.css");
@import url("hero.css");
@import url("services.css");
@import url("portfolio.css");
@import url("process.css");
@import url("testimonials.css");
@import url("stack.css");
@import url("contact.css");
@import url("footer.css");
@import url("responsive.css");
'@ | Set-Content $cssPath -Encoding UTF8

# Split HTML into partials
$htmlPath = 'src\pages\index.html'
$htmlLines = Get-Content $htmlPath -Raw -Encoding UTF8 | Out-String -Split "\r?\n"

function GetCommentStart($idx) {
    while ($idx -gt 0 -and $htmlLines[$idx] -notmatch '^\s*<!--') {
        $idx--
    }
    return $idx
}

$htmlMarkers = @{
    header = 'HEADER'
    hero = 'HERO'
    services = 'SERVICES'
    portfolio = 'PORTFOLIO'
    process = 'PROCESS'
    testimonials = 'TESTIMONIALS'
    stack = 'STACK'
    contact = 'CONTACT'
    footer = 'FOOTER'
}
$htmlPos = @{}
for ($i = 0; $i -lt $htmlLines.Count; $i++) {
    foreach ($k in $htmlMarkers.Keys) {
        if ($htmlLines[$i] -match '^\s*' + [regex]::Escape($htmlMarkers[$k]) + '\s*$') {
            $htmlPos[$k] = GetCommentStart $i
        }
    }
}

$htmlSections = @(
    @{name='header.html'; start=$htmlPos['header']; end=$htmlPos['hero'] - 1},
    @{name='hero.html'; start=$htmlPos['hero']; end=$htmlPos['services'] - 1},
    @{name='services.html'; start=$htmlPos['services']; end=$htmlPos['portfolio'] - 1},
    @{name='portfolio.html'; start=$htmlPos['portfolio']; end=$htmlPos['process'] - 1},
    @{name='process.html'; start=$htmlPos['process']; end=$htmlPos['testimonials'] - 1},
    @{name='testimonials.html'; start=$htmlPos['testimonials']; end=$htmlPos['stack'] - 1},
    @{name='stack.html'; start=$htmlPos['stack']; end=$htmlPos['contact'] - 1},
    @{name='contact.html'; start=$htmlPos['contact']; end=$htmlPos['footer'] - 1},
    @{name='footer.html'; start=$htmlPos['footer']; end=$htmlLines.Count - 4}
)

foreach ($sec in $htmlSections) {
    $out = "src\pages\partials\$($sec.name)"
    $htmlLines[$sec.start..$sec.end] | Set-Content $out -Encoding UTF8
}

@'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EvoTech — Desenvolvimento Web Premium</title>
    <link rel="icon" href="../assets/images/favicon2.png" type="image/png">
    <link rel="stylesheet" href="../assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,300;12..96,400;12..96,500;12..96,600;12..96,700;12..96,800&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,400&display=swap" rel="stylesheet">
</head>
<body>
    <div id="header"></div>
    <main id="main-content"></main>
    <div id="footer"></div>
    <script src="../assets/js/main.js" defer></script>
</body>
</html>
'@ | Set-Content $htmlPath -Encoding UTF8

@'
const sections = [
    { target: '#header', url: './partials/header.html' },
    { target: '#main-content', url: './partials/hero.html' },
    { target: '#main-content', url: './partials/services.html' },
    { target: '#main-content', url: './partials/portfolio.html' },
    { target: '#main-content', url: './partials/process.html' },
    { target: '#main-content', url: './partials/testimonials.html' },
    { target: '#main-content', url: './partials/stack.html' },
    { target: '#main-content', url: './partials/contact.html' },
    { target: '#footer', url: './partials/footer.html' },
];

async function loadSection(item) {
    try {
        const response = await fetch(item.url);
        if (!response.ok) {
            throw new Error(`${item.url} não pôde ser carregado (${response.status})`);
        }
        const html = await response.text();
        document.querySelector(item.target).insertAdjacentHTML('beforeend', html);
    } catch (error) {
        console.error(error);
    }
}

function initPage() {
    const hdr = document.getElementById('site-header');
    const burger = document.getElementById('hdrBurger');
    const nav = document.getElementById('hdrNav');

    if (!hdr || !burger || !nav) return;

    window.addEventListener('scroll', () => {
        hdr.classList.toggle('hdr--scrolled', window.scrollY > 20);
    }, { passive: true });

    burger.addEventListener('click', () => {
        const open = nav.classList.toggle('nav--open');
        burger.classList.toggle('burger--open', open);
        burger.setAttribute('aria-expanded', open);
        document.body.style.overflow = open ? 'hidden' : '';
    });

    nav.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
        nav.classList.remove('nav--open');
        burger.classList.remove('burger--open');
        burger.setAttribute('aria-expanded', 'false');
        document.body.style.overflow = '';
    }));

    const io = new IntersectionObserver((entries) => {
        entries.forEach(e => {
            if (e.isIntersecting) {
                e.target.classList.add('is-visible');
                io.unobserve(e.target);
            }
        });
    }, { threshold: 0.1 });

    document.querySelectorAll(
        '.svc-card, .pf-card, .proc-item, .testi-card, .section-heading-row, .section-label, .stack-row'
    ).forEach((el, i) => {
        el.classList.add('anim-fade');
        el.style.transitionDelay = `${(i % 4) * 80}ms`;
        io.observe(el);
    });

    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.hdr-nav a');
    const spy = new IntersectionObserver((entries) => {
        entries.forEach(e => {
            if (e.isIntersecting) {
                navLinks.forEach(l => l.classList.remove('nav-active'));
                const a = document.querySelector(`.hdr-nav a[href="#${e.target.id}"]`);
                if (a) a.classList.add('nav-active');
            }
        });
    }, { rootMargin: '-40% 0px -55% 0px' });
    sections.forEach(s => spy.observe(s));
}

(async function() {
    for (const section of sections) {
        await loadSection(section);
    }
    initPage();
})();
'@ | Set-Content assets\js\main.js -Encoding UTF8
