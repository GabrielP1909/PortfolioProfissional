const loadPartial = async (selector, partialUrl, append = false) => {
    const element = document.querySelector(selector);
    if (!element) return;

    try {
        const response = await fetch(partialUrl);
        if (!response.ok) throw new Error(`Failed to load ${partialUrl}`);
        const html = await response.text();
        if (append) {
            element.insertAdjacentHTML('beforeend', html);
        } else {
            element.innerHTML = html;
        }
    } catch (error) {
        console.error(error);
        element.innerHTML = `<div class="error-message">Não foi possível carregar ${partialUrl}</div>`;
    }
};

const initInteractions = () => {
    const hdr = document.getElementById('site-header');
    const burger = document.getElementById('hdrBurger');
    const nav = document.getElementById('hdrNav');

    if (hdr) {
        window.addEventListener('scroll', () => {
            hdr.classList.toggle('hdr--scrolled', window.scrollY > 20);
        }, { passive: true });
    }

    if (burger && nav) {
        burger.addEventListener('click', () => {
            const open = nav.classList.toggle('nav--open');
            burger.classList.toggle('burger--open', open);
            burger.setAttribute('aria-expanded', open);
            document.body.style.overflow = open ? 'hidden' : '';
        });

        nav.querySelectorAll('a').forEach((link) => {
            link.addEventListener('click', () => {
                nav.classList.remove('nav--open');
                burger.classList.remove('burger--open');
                burger.setAttribute('aria-expanded', 'false');
                document.body.style.overflow = '';
            });
        });
    }

    const fadeInBlocks = document.querySelectorAll(
        '.svc-card, .pf-card, .proc-item, .testi-card, .section-heading-row, .section-label, .stack-row'
    );

    if (fadeInBlocks.length) {
        const io = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('is-visible');
                    io.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1 });

        fadeInBlocks.forEach((el, i) => {
            el.classList.add('anim-fade');
            el.style.transitionDelay = `${(i % 4) * 80}ms`;
            io.observe(el);
        });
    }

    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.hdr-nav a');

    if (sections.length && navLinks.length) {
        const spy = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    navLinks.forEach((link) => link.classList.remove('nav-active'));
                    const activeLink = document.querySelector(`.hdr-nav a[href="#${entry.target.id}"]`);
                    if (activeLink) activeLink.classList.add('nav-active');
                }
            });
        }, { rootMargin: '-40% 0px -55% 0px' });

        sections.forEach((section) => spy.observe(section));
    }
};

const initPage = async () => {
    await loadPartial('#header', 'partials/header.html');

    const mainSections = [
        'partials/hero.html',
        'partials/services.html',
        'partials/portfolio.html',
        'partials/process.html',
        'partials/testimonials.html',
        'partials/stack.html',
        'partials/contact.html'
    ];

    for (const sectionUrl of mainSections) {
        await loadPartial('#main-content', sectionUrl, true);
    }

    await loadPartial('#footer', 'partials/footer.html');

    initInteractions();
};

document.addEventListener('DOMContentLoaded', initPage);
