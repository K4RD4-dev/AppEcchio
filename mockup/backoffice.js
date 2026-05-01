const STORAGE_KEY = "appecchio_backoffice_mockup_v4";

const navCatalog = {
  dashboard: { label: "Cruscotto", hint: "oggi" },
  page: { label: "La mia pagina", hint: "scheda" },
  media: { label: "Foto e copertina", hint: "media" },
  menu: { label: "Menu / listino", hint: "catalogo" },
  events: { label: "Eventi", hint: "visibilità" },
  vouchers: { label: "Voucher", hint: "token" },
  reports: { label: "Segnalazioni", hint: "coda" },
  communications: { label: "Comunicazioni", hint: "push" },
  organizations: { label: "Organizzazioni", hint: "rete" },
  members: { label: "Membri", hint: "gruppi" },
  stats: { label: "Statistiche", hint: "trend" },
  permissions: { label: "Permessi", hint: "RBAC" },
  support: { label: "Assistenza", hint: "ticket" },
};

const roleConfig = {
  merchant: {
    name: "Esercente",
    initial: "E",
    scope: "Gestione attività locale",
    defaultOrg: "osteria",
    nav: ["dashboard", "page", "media", "menu", "events", "vouchers", "stats", "support"],
    eyebrow: "Pannello attività",
    title: "Gestisci pagina, menu, offerte ed eventi",
    copy: "Una console compatta per tenere aggiornata la presenza del locale in app e coordinare promozioni, voucher ed eventi.",
    action: "Apri eventi",
    metrics: [
      ["Visite pagina", "1.248", "+18%"],
      ["Aperture menu", "432", "+9%"],
      ["Voucher riscattati", "37", "+12%"],
      ["Eventi attivi", "3", "2 privati"],
    ],
    priorities: [
      "Confermare orario speciale di domenica",
      "Aggiornare due piatti stagionali",
      "Evento degustazione in revisione URP",
    ],
  },
  organization: {
    name: "Organizzazione",
    initial: "O",
    scope: "Associazione, Pro Loco, gruppo locale",
    defaultOrg: "proloco",
    nav: ["dashboard", "page", "events", "members", "communications", "stats", "support"],
    eyebrow: "Area organizzazione",
    title: "Eventi pubblici, riunioni interne e gruppi",
    copy: "Ogni organizzazione può pubblicare eventi aperti al paese e appuntamenti visibili solo a soci, direttivo o invitati.",
    action: "Apri eventi",
    metrics: [
      ["Eventi pubblici", "8", "+3"],
      ["Riunioni interne", "5", "mese"],
      ["Membri attivi", "64", "+6"],
      ["Inviti in attesa", "12", "RSVP"],
    ],
    priorities: [
      "Assemblea soci da confermare",
      "Turni volontari festa del paese",
      "Comunicazione Pro Loco da inviare ai membri",
    ],
  },
  supervisor: {
    name: "Supervisore",
    initial: "S",
    scope: "Coordinamento operativo",
    defaultOrg: "comune",
    nav: ["dashboard", "events", "reports", "communications", "organizations", "stats", "support"],
    eyebrow: "Sala controllo",
    title: "Code operative, approvazioni e anomalie",
    copy: "Il supervisore governa gli eventi in revisione, le segnalazioni, le notifiche e le attività assegnate agli uffici.",
    action: "Revisiona eventi",
    metrics: [
      ["Segnalazioni aperte", "23", "5 urgenti"],
      ["Eventi in revisione", "7", "oggi"],
      ["Notifiche pronte", "4", "2 comunali"],
      ["Anomalie voucher", "2", "bassa"],
    ],
    priorities: [
      "Approvare calendario weekend",
      "Smistare segnalazioni viabilità",
      "Verificare doppia scansione voucher",
    ],
  },
  mayor: {
    name: "Sindaco",
    initial: "S",
    scope: "Visione istituzionale",
    defaultOrg: "comune",
    nav: ["dashboard", "events", "reports", "communications", "stats"],
    eyebrow: "Cruscotto istituzionale",
    title: "Priorità del territorio e comunicazioni pubbliche",
    copy: "Una vista sintetica per decisioni, comunicazioni da approvare, criticità del territorio e andamento dei servizi.",
    action: "Report eventi",
    metrics: [
      ["Segnalazioni risolte", "81%", "+7%"],
      ["Tempo medio risposta", "2,4 gg", "-0,6"],
      ["Eventi mese", "19", "+5"],
      ["Avvisi pubblici", "6", "2 da approvare"],
    ],
    priorities: [
      "Comunicazione lavori viabilità",
      "Report mensile servizi al cittadino",
      "Evento patrocinato in attesa decisione",
    ],
  },
  admin: {
    name: "Amministratore",
    initial: "A",
    scope: "Configurazione piattaforma",
    defaultOrg: "comune",
    nav: ["dashboard", "organizations", "page", "events", "vouchers", "reports", "communications", "members", "stats", "permissions", "support"],
    eyebrow: "Console sistema",
    title: "Ruoli, permessi, contenuti e audit",
    copy: "Il pannello amministratore controlla configurazioni, organizzazioni, ruoli, regole gamification, contenuti e sicurezza.",
    action: "Gestisci eventi",
    metrics: [
      ["Utenti backoffice", "42", "+4"],
      ["Ruoli configurati", "9", "RBAC"],
      ["Schede pubblicate", "118", "+11"],
      ["Azioni sensibili", "16", "audit"],
    ],
    priorities: [
      "Rivedere permessi editor eventi",
      "Aggiornare categorie attività",
      "Controllare log esportazione dati",
    ],
  },
};

const defaultState = {
  role: "merchant",
  organizationId: "osteria",
  currentView: "dashboard",
  organizations: {
    osteria: {
      name: "Osteria Monte Nerone",
      type: "Ristorante",
      shortDescription: "Cucina tipica, prodotti locali e serate in terrazza.",
      longDescription: "Locale nel centro di Apecchio con menu stagionale, piatti del territorio, birre artigianali e piccole degustazioni su prenotazione.",
      address: "Via Roma 12, Apecchio",
      phone: "+39 0722 000000",
      email: "info@osteriamontenerone.it",
      website: "osteriamontenerone.it",
      opening: "Oggi 12:00-14:30, 19:00-22:00",
      services: ["Prenotazione", "Voucher", "Menu stagionale", "Animali ammessi"],
      status: "Pubblicata",
      coverImage: demoCover("restaurant"),
      coverFit: "cover",
      coverPositionX: 50,
      coverPositionY: 50,
    },
    proloco: {
      name: "Pro Loco Apecchio",
      type: "Associazione",
      shortDescription: "Eventi, volontariato e promozione del territorio.",
      longDescription: "Organizzazione locale per iniziative pubbliche, supporto agli eventi, coordinamento volontari e valorizzazione della comunità.",
      address: "Piazza del Comune, Apecchio",
      phone: "+39 0722 111111",
      email: "proloco@apecchio.example",
      website: "prolocoapecchio.example",
      opening: "Su appuntamento",
      services: ["Eventi", "Volontari", "Assemblee", "Comunicazioni soci"],
      status: "Pubblicata",
      coverImage: demoCover("community"),
      coverFit: "cover",
      coverPositionX: 50,
      coverPositionY: 45,
    },
    comune: {
      name: "Comune di Apecchio",
      type: "Ente",
      shortDescription: "Servizi comunali, comunicazioni e vita pubblica.",
      longDescription: "Area istituzionale per coordinare servizi, uffici, comunicazioni, sedute, segnalazioni e contenuti pubblici nell'app.",
      address: "Piazza San Martino, Apecchio",
      phone: "+39 0722 222222",
      email: "segreteria@comune.apecchio.example",
      website: "comune.apecchio.example",
      opening: "Uffici su appuntamento",
      services: ["Segnalazioni", "Uffici", "Sedute", "Avvisi"],
      status: "Istituzionale",
      coverImage: demoCover("municipal"),
      coverFit: "cover",
      coverPositionX: 50,
      coverPositionY: 48,
    },
  },
  menuItems: [
    { id: "m1", orgId: "osteria", category: "Primi", name: "Tagliatelle al tartufo", description: "Pasta fresca, tartufo locale, burro di montagna.", price: "14", tags: ["Tipico", "Stagionale"], active: true },
    { id: "m2", orgId: "osteria", category: "Secondi", name: "Brasato alla birra", description: "Cottura lenta con birra artigianale del territorio.", price: "18", tags: ["Territorio"], active: true },
    { id: "m3", orgId: "osteria", category: "Dolci", name: "Crostata di visciole", description: "Dolce della casa.", price: "6", tags: ["Casa"], active: false },
  ],
  events: [
    { id: "e1", orgId: "osteria", title: "Cena degustazione del Monte Nerone", type: "Degustazione", date: "2026-05-16", time: "20:30", visibility: "public", audience: "Tutti", status: "In revisione", placements: ["Calendario pubblico", "Pagina organizzazione"], rsvp: "Prenotazione obbligatoria", description: "Menu degustazione con prodotti locali e abbinamento birre.", reviewNote: "Verificare immagine e capienza prima della pubblicazione.", owner: "Osteria Monte Nerone", capacity: 42, rsvpCount: 34, checkinCount: 0, waitlistCount: 3, participationTrend: "+18%" },
    { id: "e2", orgId: "osteria", title: "Briefing staff weekend", type: "Riunione interna", date: "2026-05-03", time: "10:00", visibility: "org_members", audience: "Staff attività", status: "Pubblicato interno", placements: ["Calendario interno"], rsvp: "Conferma presenza", description: "Allineamento su turni, prenotazioni e disponibilità menu.", reviewNote: "", owner: "Osteria Monte Nerone", capacity: 8, rsvpCount: 7, checkinCount: 6, waitlistCount: 0, participationTrend: "+2" },
    { id: "e3", orgId: "proloco", title: "Riunione direttivo Pro Loco", type: "Consiglio", date: "2026-05-08", time: "21:00", visibility: "group", audience: "Direttivo", status: "Riservato", placements: ["Gruppo direttivo"], rsvp: "RSVP", description: "Preparazione calendario estivo e turni volontari.", reviewNote: "", owner: "Pro Loco Apecchio", capacity: 12, rsvpCount: 9, checkinCount: 0, waitlistCount: 0, participationTrend: "stabile" },
    { id: "e4", orgId: "comune", title: "Consiglio comunale", type: "Consiglio", date: "2026-05-12", time: "18:30", visibility: "council", audience: "Cittadini, consiglieri e segreteria", status: "Pubblico con allegati interni", placements: ["Calendario pubblico", "Area consiglio"], rsvp: "Nessun RSVP", description: "Seduta con ordine del giorno pubblico e note preparatorie interne.", reviewNote: "Separare allegati pubblici e materiali riservati.", owner: "Comune di Apecchio", capacity: 80, rsvpCount: 28, checkinCount: 0, waitlistCount: 0, participationTrend: "+6%" },
  ],
  vouchers: [
    { code: "VCH-5MONTE", orgId: "osteria", label: "Sconto 5%", status: "Validato", date: "2026-04-29", amount: "3,40" },
    { code: "VCH-10NERONE", orgId: "osteria", label: "Sconto 10%", status: "Disponibile", date: "2026-05-01", amount: "7,80" },
  ],
  reports: [
    { title: "Buche in via Garibaldi", area: "Viabilità", priority: "Alta", status: "Assegnata ufficio tecnico" },
    { title: "Lampione spento", area: "Manutenzione", priority: "Media", status: "In lavorazione" },
    { title: "Rifiuti area picnic", area: "Ambiente", priority: "Media", status: "Nuova" },
  ],
  members: [
    { orgId: "proloco", name: "Maria Rossi", group: "Direttivo", role: "Proprietario organizzazione" },
    { orgId: "proloco", name: "Luca Bianchi", group: "Eventi", role: "Editor eventi" },
    { orgId: "proloco", name: "Sara Conti", group: "Volontari", role: "Membro" },
    { orgId: "osteria", name: "Giulia Ferri", group: "Staff attività", role: "Editor menu" },
    { orgId: "osteria", name: "Paolo Neri", group: "Staff attività", role: "Scanner voucher" },
  ],
  groups: [
    { orgId: "osteria", name: "Staff attività", visibility: "Eventi interni, turni, briefing", members: 6 },
    { orgId: "osteria", name: "Fornitori", visibility: "Inviti e note operative", members: 4 },
    { orgId: "proloco", name: "Direttivo", visibility: "Riunioni riservate e documenti", members: 7 },
    { orgId: "proloco", name: "Volontari", visibility: "Turni, eventi e comunicazioni", members: 34 },
    { orgId: "comune", name: "Ufficio tecnico", visibility: "Segnalazioni e riunioni interne", members: 5 },
    { orgId: "comune", name: "Giunta", visibility: "Agenda istituzionale riservata", members: 6 },
  ],
};

const visibilityCatalog = {
  public: {
    label: "Pubblico",
    className: "public",
    help: "Visibile a tutti: calendario pubblico, mappa e home solo dopo revisione quando richiesto.",
  },
  org_page: {
    label: "Pagina organizzazione",
    className: "public",
    help: "Visibile nella scheda dell'attività o organizzazione, senza spinta automatica in home.",
  },
  org_members: {
    label: "Solo membri",
    className: "private",
    help: "Visibile solo agli utenti collegati all'organizzazione selezionata.",
  },
  group: {
    label: "Gruppo specifico",
    className: "private",
    help: "Visibile a un gruppo: direttivo, staff evento, volontari, dipendenti o ufficio.",
  },
  invite: {
    label: "Su invito",
    className: "private",
    help: "Visibile solo alle persone invitate, con RSVP e notifiche mirate.",
  },
  municipal_internal: {
    label: "Interno Comune",
    className: "review",
    help: "Visibile solo ai ruoli comunali autorizzati: uffici, supervisori, segreteria.",
  },
  council: {
    label: "Consiglio / Giunta",
    className: "review",
    help: "Per appuntamenti istituzionali con parte pubblica separata da materiali o note interne.",
  },
};

let state = loadState();

const roleSelect = document.getElementById("roleSelect");
const organizationSelect = document.getElementById("organizationSelect");
const workspace = document.getElementById("workspace");
const mainNav = document.getElementById("mainNav");

function demoCover(kind) {
  const palette = {
    restaurant: ["#0b7285", "#c97824", "#fff3d8", "Tavola"],
    community: ["#2f855a", "#6a4c93", "#f7ecdc", "Comunità"],
    municipal: ["#1d3557", "#89c2d9", "#edf7f8", "Comune"],
  }[kind] || ["#0b7285", "#c97824", "#edf7f8", "APPecchio"];
  const svg = `
    <svg width="900" height="520" viewBox="0 0 900 520" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="${palette[0]}"/>
          <stop offset="1" stop-color="${palette[1]}"/>
        </linearGradient>
      </defs>
      <rect width="900" height="520" fill="url(#g)"/>
      <path d="M0 390C130 322 235 438 360 360S610 260 900 332v188H0z" fill="${palette[2]}" opacity=".92"/>
      <circle cx="720" cy="128" r="76" fill="${palette[2]}" opacity=".62"/>
      <text x="64" y="112" fill="white" font-family="Arial, sans-serif" font-size="54" font-weight="800">${palette[3]}</text>
      <text x="66" y="162" fill="white" opacity=".86" font-family="Arial, sans-serif" font-size="24">Immagine demo modificabile</text>
    </svg>
  `;
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`;
}

function loadState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved ? mergeState(defaultState, JSON.parse(saved)) : structuredClone(defaultState);
  } catch {
    return structuredClone(defaultState);
  }
}

function mergeState(base, saved) {
  return {
    ...structuredClone(base),
    ...saved,
    organizations: { ...base.organizations, ...(saved.organizations || {}) },
    menuItems: saved.menuItems || base.menuItems,
    events: saved.events || base.events,
    vouchers: saved.vouchers || base.vouchers,
    reports: saved.reports || base.reports,
    members: saved.members || base.members,
    groups: saved.groups || base.groups,
  };
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function currentOrg() {
  return state.organizations[state.organizationId] || state.organizations.osteria;
}

function currentRole() {
  return roleConfig[state.role] || roleConfig.merchant;
}

function setRole(role) {
  state.role = role;
  const config = currentRole();
  state.organizationId = config.defaultOrg;
  if (!config.nav.includes(state.currentView)) {
    state.currentView = "dashboard";
  }
  render();
}

function setView(view) {
  state.currentView = view;
  render();
}

function render() {
  const config = currentRole();
  roleSelect.value = state.role;
  organizationSelect.value = state.organizationId;
  document.getElementById("roleInitial").textContent = config.initial;
  document.getElementById("roleName").textContent = config.name;
  document.getElementById("roleScope").textContent = config.scope;
  renderNav();
  renderWorkspace();
  saveState();
}

function renderNav() {
  const config = currentRole();
  mainNav.innerHTML = config.nav
    .map((key) => {
      const item = navCatalog[key];
      const active = state.currentView === key ? "active" : "";
      return `<button class="${active}" data-view="${key}"><span>${item.label}</span><small>${item.hint}</small></button>`;
    })
    .join("");
}

function renderWorkspace() {
  const renderers = {
    dashboard: renderDashboard,
    page: renderPageEditor,
    media: renderMedia,
    menu: renderMenu,
    events: renderEvents,
    vouchers: renderVouchers,
    reports: renderReports,
    communications: renderCommunications,
    organizations: renderOrganizations,
    members: renderMembers,
    stats: renderStats,
    permissions: renderPermissions,
    support: renderSupport,
  };
  const renderer = renderers[state.currentView] || renderDashboard;
  renderer();
}

function renderDashboard() {
  const template = document.getElementById("dashboardTemplate");
  const node = template.content.cloneNode(true);
  const config = currentRole();
  node.querySelector("[data-role-eyebrow]").textContent = config.eyebrow;
  node.querySelector("[data-role-title]").textContent = config.title;
  node.querySelector("[data-role-copy]").textContent = config.copy;
  node.querySelector("[data-primary-action]").textContent = config.action;
  node.querySelector("[data-primary-action]").dataset.action = "go-events";
  node.querySelector("[data-metrics]").innerHTML = config.metrics
    .map(([label, value, trend]) => `<article class="metric-card"><span>${label}</span><strong>${value}</strong><small>${trend}</small></article>`)
    .join("");
  node.querySelector("[data-participation]").innerHTML = renderDashboardParticipation();
  node.querySelector("[data-priorities]").innerHTML = config.priorities
    .map((item) => `<li><span>${item}</span><span class="chip review">Da gestire</span></li>`)
    .join("");
  node.querySelector("[data-activity]").innerHTML = [
    "Scheda organizzazione aggiornata",
    "Evento interno creato con visibilità limitata",
    "Voucher validato senza anomalie",
    "Nuova comunicazione salvata in bozza",
  ]
    .map((item) => `<li><span>${item}</span><span class="muted">oggi</span></li>`)
    .join("");
  workspace.innerHTML = "";
  workspace.appendChild(node);
}

function renderDashboardParticipation() {
  const events = dashboardParticipationEvents();
  const totals = events.reduce(
    (acc, event) => {
      const metrics = eventParticipation(event);
      acc.capacity += metrics.capacity;
      acc.rsvp += metrics.rsvpCount;
      acc.checkin += metrics.checkinCount;
      acc.waitlist += metrics.waitlistCount;
      return acc;
    },
    { capacity: 0, rsvp: 0, checkin: 0, waitlist: 0 },
  );
  const rsvpRate = percent(totals.rsvp, totals.capacity);
  const attendanceRate = percent(totals.checkin, totals.rsvp);
  const title = state.role === "mayor" ? "Partecipazione eventi pubblici e istituzionali" : "Partecipazione eventi";
  const caption = state.role === "mayor"
    ? "Vista aggregata senza eventi interni di organizzazioni o staff."
    : "RSVP, check-in e capienza degli eventi visibili per questo ruolo.";

  return `
    <section class="participation-grid">
      <article class="panel participation-summary">
        <div class="panel-heading">
          <h3>${title}</h3>
          <span class="chip ${events.length ? "public" : "draft"}">${events.length} eventi</span>
        </div>
        <p class="muted">${caption}</p>
        <div class="participation-kpis">
          ${participationKpi("RSVP", totals.rsvp, `${rsvpRate}% capienza`)}
          ${participationKpi("Check-in", totals.checkin, `${attendanceRate}% presenze`)}
          ${participationKpi("Posti", Math.max(totals.capacity - totals.rsvp, 0), `${totals.capacity} totali`)}
          ${participationKpi("Attesa", totals.waitlist, "lista attesa")}
        </div>
      </article>
      <article class="panel participation-list-panel">
        <div class="panel-heading">
          <h3>Prossimi eventi</h3>
          <span class="muted">RSVP + check-in</span>
        </div>
        <div class="participation-list">
          ${events.map(renderParticipationRow).join("") || `<p class="muted">Nessun evento con partecipazione visibile.</p>`}
        </div>
      </article>
    </section>
  `;
}

function dashboardParticipationEvents() {
  const events = state.role === "mayor"
    ? state.events.filter((event) => ["public", "council"].includes(event.visibility))
    : visibleEventsForRole();
  return [...events].sort((a, b) => `${a.date} ${a.time}`.localeCompare(`${b.date} ${b.time}`)).slice(0, 5);
}

function eventParticipation(event) {
  return {
    capacity: Number(event.capacity || 0),
    rsvpCount: Number(event.rsvpCount || 0),
    checkinCount: Number(event.checkinCount || 0),
    waitlistCount: Number(event.waitlistCount || 0),
    participationTrend: event.participationTrend || "0",
  };
}

function participationKpi(label, value, detail) {
  return `
    <div class="participation-kpi">
      <span>${label}</span>
      <strong>${value}</strong>
      <small>${detail}</small>
    </div>
  `;
}

function renderParticipationRow(event) {
  const metrics = eventParticipation(event);
  const rsvpRate = percent(metrics.rsvpCount, metrics.capacity);
  const attendanceRate = percent(metrics.checkinCount, metrics.rsvpCount);
  const stateInfo = participationState(metrics);
  const showOwner = ["admin", "supervisor", "mayor"].includes(state.role);
  return `
    <article class="participation-row">
      <header>
        <div>
          <strong>${escapeHtml(event.title)}</strong>
          <p>${showOwner ? `${escapeHtml(orgLabel(event.orgId))} · ` : ""}${escapeHtml(event.date)} · ${escapeHtml(event.time)} · ${escapeHtml(event.audience)}</p>
        </div>
        <span class="chip ${stateInfo.className}">${stateInfo.label}</span>
      </header>
      <div class="participation-bars">
        ${participationBar("RSVP", metrics.rsvpCount, metrics.capacity, rsvpRate)}
        ${participationBar("Check-in", metrics.checkinCount, metrics.rsvpCount, attendanceRate)}
      </div>
      <footer>
        <span>${metrics.rsvpCount}/${metrics.capacity} prenotati</span>
        <span>${metrics.checkinCount}/${metrics.rsvpCount} presenti</span>
        <span>${metrics.waitlistCount} in attesa</span>
        <span>Trend ${escapeHtml(metrics.participationTrend)}</span>
      </footer>
    </article>
  `;
}

function participationBar(label, value, max, rate) {
  return `
    <div class="participation-bar-row">
      <span>${label}</span>
      <div class="participation-bar"><span style="width: ${rate}%"></span></div>
      <strong>${value}/${max}</strong>
    </div>
  `;
}

function participationState(metrics) {
  if (metrics.capacity > 0 && metrics.rsvpCount >= metrics.capacity) {
    return { label: metrics.waitlistCount > 0 ? "Sold out" : "Completo", className: "review" };
  }
  if (metrics.capacity > 0 && percent(metrics.rsvpCount, metrics.capacity) >= 85) {
    return { label: "Quasi pieno", className: "private" };
  }
  if (metrics.capacity > 0 && percent(metrics.rsvpCount, metrics.capacity) < 35) {
    return { label: "Bassa partecipazione", className: "draft" };
  }
  return { label: "Posti disponibili", className: "public" };
}

function percent(value, max) {
  const numericMax = Number(max || 0);
  if (!numericMax) return 0;
  return Math.min(100, Math.round((Number(value || 0) / numericMax) * 100));
}

function renderPageEditor() {
  const org = currentOrg();
  workspace.innerHTML = `
    <section class="editor-layout">
      <div class="editor-stack">
        <div class="hero-panel">
          <div>
            <p class="eyebrow">Scheda pubblica</p>
            <h2>Modifica la pagina dell'organizzazione</h2>
            <p>Le informazioni base alimentano scheda app, mappa, ricerca e collegamenti con eventi, menu e voucher.</p>
          </div>
          <button class="primary-action" data-action="publish-page">Salva modifiche</button>
        </div>
        <article class="editor-card">
          <div class="panel-heading">
            <h3>Immagine pagina</h3>
            <span class="chip public">Copertina</span>
          </div>
          <div class="cover-editor">
            <div class="cover-editor-preview" data-cover-editor-preview style="${coverStyle(org)}"></div>
            <div class="field-grid">
              <label class="full">
                Carica immagine dal computer
                <input id="coverFileInput" type="file" accept="image/*" />
              </label>
              ${field("URL immagine", "coverImage", org.coverImage || "", "full")}
              <label>
                Visualizzazione
                <select data-org-field="coverFit">
                  <option value="cover" ${coverValue(org.coverFit, "cover")}>Riempi area</option>
                  <option value="contain" ${coverValue(org.coverFit, "contain")}>Mostra intera</option>
                </select>
              </label>
              <label>
                Fuoco orizzontale
                <input data-org-field="coverPositionX" type="range" min="0" max="100" value="${Number(org.coverPositionX ?? 50)}" />
              </label>
              <label>
                Fuoco verticale
                <input data-org-field="coverPositionY" type="range" min="0" max="100" value="${Number(org.coverPositionY ?? 50)}" />
              </label>
              <label>
                Sfondo quando intera
                <select data-org-field="coverBackground">
                  <option value="light" ${coverValue(org.coverBackground, "light")}>Chiaro</option>
                  <option value="dark" ${coverValue(org.coverBackground, "dark")}>Scuro</option>
                </select>
              </label>
            </div>
            <div class="button-row">
              <button class="secondary-action" data-action="use-demo-cover">Usa immagine demo</button>
              <button class="ghost-action" data-action="center-cover">Centra immagine</button>
            </div>
          </div>
        </article>
        <article class="editor-card">
          <div class="panel-heading">
            <h3>Informazioni principali</h3>
            <span class="chip ${org.status === "Pubblicata" ? "public" : "review"}">${escapeHtml(org.status)}</span>
          </div>
          <div class="field-grid">
            ${field("Nome", "name", org.name)}
            ${field("Categoria", "type", org.type)}
            ${field("Indirizzo", "address", org.address)}
            ${field("Telefono", "phone", org.phone)}
            ${field("Email", "email", org.email)}
            ${field("Sito", "website", org.website)}
            ${field("Orari", "opening", org.opening, "full")}
            ${field("Descrizione breve", "shortDescription", org.shortDescription, "full")}
            ${textArea("Descrizione estesa", "longDescription", org.longDescription)}
            ${field("Servizi, separati da virgola", "services", org.services.join(", "), "full")}
          </div>
        </article>
      </div>
      ${renderPhonePreview(org)}
    </section>
  `;
}

function field(label, key, value, extraClass = "") {
  return `
    <label class="${extraClass}">
      ${label}
      <input data-org-field="${key}" value="${escapeHtml(value)}" />
    </label>
  `;
}

function coverValue(current, expected) {
  const value = current || (expected === "light" ? "light" : "cover");
  return value === expected ? "selected" : "";
}

function textArea(label, key, value) {
  return `
    <label class="full">
      ${label}
      <textarea data-org-field="${key}">${escapeHtml(value)}</textarea>
    </label>
  `;
}

function renderPhonePreview(org) {
  return `
    <aside class="phone-preview">
      <div class="phone-shell">
        <div class="preview-cover" data-preview-cover style="${coverStyle(org)}"></div>
        <div class="preview-body">
          <span class="chip public">${escapeHtml(org.type)}</span>
          <h3 class="preview-title" data-preview-name>${escapeHtml(org.name)}</h3>
          <p data-preview-short>${escapeHtml(org.shortDescription)}</p>
          <div class="chip-row" data-preview-services>
            ${org.services.map((service) => `<span class="chip">${escapeHtml(service)}</span>`).join("")}
          </div>
          <p><strong>Oggi</strong><br />${escapeHtml(org.opening)}</p>
          <div class="preview-actions">
            <span>Chiama</span>
            <span>Mappa</span>
            <span>Menu</span>
          </div>
        </div>
      </div>
    </aside>
  `;
}

function coverStyle(org) {
  const image = org.coverImage || demoCover("restaurant");
  const fit = org.coverFit || "cover";
  const positionX = Number(org.coverPositionX ?? 50);
  const positionY = Number(org.coverPositionY ?? 50);
  const background = org.coverBackground === "dark" ? "#1f2d35" : "#edf7f8";
  return `background-image: url('${escapeAttribute(image)}'); background-size: ${fit}; background-position: ${positionX}% ${positionY}%; background-repeat: no-repeat; background-color: ${background};`;
}

function escapeAttribute(value) {
  return String(value ?? "").replaceAll("\\", "\\\\").replaceAll("'", "\\'");
}

function renderMedia() {
  const org = currentOrg();
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Media attività</p>
          <h2>Copertina, galleria e anteprime</h2>
          <p>La prima versione simula il flusso: copertina, foto ordinabili, stato revisione e anteprima mobile.</p>
        </div>
        <button class="primary-action" data-action="mock-upload">Aggiungi foto</button>
      </div>
      <div class="three-column">
        ${["Copertina principale", "Sala e dettagli", "Piatto o servizio"].map((title, index) => `
          <article class="panel">
            <div class="preview-cover" style="min-height: ${index === 0 ? 190 : 150}px; ${index === 0 ? coverStyle(org) : ""}"></div>
            <div class="panel-heading" style="margin-top: 12px">
              <h3>${title}</h3>
              <span class="chip ${index === 0 ? "public" : "draft"}">${index === 0 ? "Attiva" : "Bozza"}</span>
            </div>
            <div class="button-row">
              <button class="secondary-action" data-action="mock-upload">Sostituisci</button>
              <button class="ghost-action" data-action="mock-reorder">Sposta</button>
            </div>
          </article>
        `).join("")}
      </div>
    </section>
  `;
}

function renderMenu() {
  const org = currentOrg();
  const items = state.menuItems.filter((item) => item.orgId === state.organizationId);
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">${escapeHtml(org.name)}</p>
          <h2>Menu, listino o catalogo servizi</h2>
          <p>Per ristoranti e bar diventa menu; per attività e servizi diventa catalogo con prezzi, disponibilità ed etichette.</p>
        </div>
        <button class="primary-action" data-action="add-menu-item">Aggiungi voce</button>
      </div>
      <div class="editor-layout">
        <article class="editor-card">
          <div class="panel-heading">
            <h3>Nuova voce</h3>
            <span class="chip">Bozza rapida</span>
          </div>
          <div class="field-grid">
            <label>Categoria<input id="menuCategory" value="Specialità" /></label>
            <label>Prezzo<input id="menuPrice" value="12" /></label>
            <label class="full">Nome<input id="menuName" value="Nuova proposta del giorno" /></label>
            <label class="full">Descrizione<textarea id="menuDescription">Descrizione sintetica visibile nella scheda.</textarea></label>
            <label class="full">Etichette<input id="menuTags" value="Stagionale, Tipico" /></label>
          </div>
        </article>
        <article class="panel">
          <div class="panel-heading">
            <h3>Stato listino</h3>
            <span class="muted">${items.length} voci</span>
          </div>
          <div class="mini-chart">
            ${bar("Attive", items.filter((item) => item.active).length, Math.max(items.length, 1))}
            ${bar("Non disponibili", items.filter((item) => !item.active).length, Math.max(items.length, 1))}
            ${bar("Con tag stagionale", items.filter((item) => item.tags.includes("Stagionale")).length, Math.max(items.length, 1))}
          </div>
        </article>
      </div>
      <article class="panel">
        <div class="panel-heading">
          <h3>Voci pubblicate</h3>
          <span class="muted">ordinamento demo</span>
        </div>
        <div class="menu-list">
          ${items.map(renderMenuItem).join("") || `<p class="muted">Nessuna voce per questa organizzazione.</p>`}
        </div>
      </article>
    </section>
  `;
}

function renderMenuItem(item) {
  return `
    <div class="menu-item">
      <div>
        <strong>${escapeHtml(item.name)} · €${escapeHtml(item.price)}</strong>
        <p>${escapeHtml(item.category)} · ${escapeHtml(item.description)}</p>
        <div class="chip-row" style="margin-top: 8px">
          ${item.tags.map((tag) => `<span class="chip">${escapeHtml(tag)}</span>`).join("")}
          <span class="chip ${item.active ? "public" : "draft"}">${item.active ? "Attiva" : "Non disponibile"}</span>
        </div>
      </div>
      <div class="button-row">
        <button class="secondary-action" data-action="toggle-menu-item" data-id="${item.id}">${item.active ? "Disattiva" : "Attiva"}</button>
        <button class="danger-action" data-action="remove-menu-item" data-id="${item.id}">Rimuovi</button>
      </div>
    </div>
  `;
}

function renderEvents() {
  const org = currentOrg();
  const events = visibleEventsForRole();
  const reviewQueue = state.events.filter((event) => event.status === "In revisione");
  const canReview = ["admin", "supervisor"].includes(state.role);
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Calendario con permessi</p>
          <h2>Eventi pubblici, di pagina, interni e su invito</h2>
          <p>Ogni evento nasce con una visibilità precisa, così ristoranti, associazioni e Comune possono separare comunicazione pubblica e coordinamento interno.</p>
        </div>
        <button class="primary-action" data-action="create-event">Crea evento</button>
      </div>
      <div class="event-board">
        <article class="editor-card">
          <div class="panel-heading">
            <h3>Nuovo evento</h3>
            <span class="chip">${escapeHtml(org.name)}</span>
          </div>
          <div class="field-grid">
            <label class="full">Titolo<input id="eventTitle" value="Nuovo appuntamento" /></label>
            <label>Tipologia
              <select id="eventType">
                <option>Degustazione</option>
                <option>Riunione interna</option>
                <option>Assemblea</option>
                <option>Consiglio</option>
                <option>Evento culturale</option>
                <option>Servizio comunale</option>
              </select>
            </label>
            <label>Data<input id="eventDate" type="date" value="2026-05-15" /></label>
            <label>Ora<input id="eventTime" type="time" value="20:30" /></label>
            <label>Visibilità
              <select id="eventVisibility">
                ${Object.entries(visibilityCatalog).map(([key, item]) => `<option value="${key}">${item.label}</option>`).join("")}
              </select>
            </label>
            <label class="full">Destinatari<input id="eventAudience" value="Tutti" /></label>
            <label class="full">RSVP / prenotazione<input id="eventRsvp" value="Prenotazione facoltativa" /></label>
            <label>Capienza<input id="eventCapacity" type="number" min="0" value="0" /></label>
            <label>RSVP iniziali<input id="eventRsvpCount" type="number" min="0" value="0" /></label>
            <label class="full">Descrizione<textarea id="eventDescription">Descrizione sintetica dell'evento, visibile solo ai destinatari corretti.</textarea></label>
          </div>
          <div id="visibilityHelp" class="visibility-help" style="margin-top: 12px"></div>
          <div class="panel-heading" style="margin-top: 14px">
            <h3>Canali</h3>
            <span class="muted">solo se coerenti con la visibilità</span>
          </div>
          <div class="chip-row">
            ${checkbox("placementPage", "Pagina organizzazione", true)}
            ${checkbox("placementCalendar", "Calendario pubblico", true)}
            ${checkbox("placementMap", "Mappa", false)}
            ${checkbox("placementInternal", "Calendario interno", false)}
          </div>
        </article>
        <article class="panel">
          <div class="panel-heading">
            <h3>Eventi visibili per questo ruolo</h3>
            <span class="muted">${events.length} eventi</span>
          </div>
          <div class="event-toolbar">
            ${Object.entries(visibilityCatalog).map(([key, item]) => `<span class="chip ${item.className}">${item.label}: ${events.filter((event) => event.visibility === key).length}</span>`).join("")}
          </div>
          <div class="event-list">
            ${events.map(renderEventCard).join("") || `<p class="muted">Nessun evento visibile.</p>`}
          </div>
        </article>
      </div>
      ${canReview ? `
        <article class="panel">
          <div class="panel-heading">
            <h3>Coda revisione pubblica</h3>
            <span class="chip review">${reviewQueue.length} in attesa</span>
          </div>
          <div class="request-grid">
            ${reviewQueue.map((event) => `
              <div class="request-item">
                <div>
                  <strong>${escapeHtml(event.title)}</strong>
                  <p>${escapeHtml(orgLabel(event.orgId))} · ${escapeHtml(event.date)} ${escapeHtml(event.time)} · ${escapeHtml(event.reviewNote || "Nessuna nota")}</p>
                </div>
                <div class="button-row">
                  <button class="secondary-action" data-action="approve-event" data-id="${event.id}">Approva</button>
                  <button class="danger-action" data-action="request-event-changes" data-id="${event.id}">Correzioni</button>
                </div>
              </div>
            `).join("") || `<p class="muted">Nessun evento pubblico da revisionare.</p>`}
          </div>
        </article>
      ` : ""}
    </section>
  `;
  updateVisibilityHelp();
}

function checkbox(id, label, checked) {
  return `
    <label class="chip">
      <input id="${id}" type="checkbox" ${checked ? "checked" : ""} style="width: auto; min-height: auto" />
      ${label}
    </label>
  `;
}

function visibleEventsForRole() {
  if (["admin", "supervisor", "mayor"].includes(state.role)) {
    return state.events;
  }
  return state.events.filter((event) => event.orgId === state.organizationId);
}

function orgLabel(orgId) {
  return state.organizations[orgId]?.name || "Organizzazione";
}

function statusClass(status) {
  if (status.includes("revisione") || status.includes("Correzioni")) return "review";
  if (status.includes("Pubblicato") || status.includes("Approvato")) return "public";
  if (status.includes("Riservato") || status.includes("interno")) return "private";
  return "draft";
}

function renderEventCard(event) {
  const visibility = visibilityCatalog[event.visibility] || visibilityCatalog.public;
  const canReview = ["admin", "supervisor"].includes(state.role) && event.status === "In revisione";
  const canManageOwn = event.orgId === state.organizationId && ["merchant", "organization"].includes(state.role);
  return `
    <article class="event-card">
      <header>
        <div>
          <h4>${escapeHtml(event.title)}</h4>
          <p>${escapeHtml(orgLabel(event.orgId))} · ${escapeHtml(event.type)} · ${escapeHtml(event.date)} · ${escapeHtml(event.time)}</p>
        </div>
        <span class="chip ${visibility.className}">${visibility.label}</span>
      </header>
      <p>${escapeHtml(event.description || "Descrizione evento da completare.")}</p>
      <p><strong>Destinatari:</strong> ${escapeHtml(event.audience)}</p>
      <p><strong>RSVP:</strong> ${escapeHtml(event.rsvp)}</p>
      <div class="event-meta">
        <span class="chip ${statusClass(event.status)}">${escapeHtml(event.status)}</span>
        ${event.placements.map((placement) => `<span class="chip">${escapeHtml(placement)}</span>`).join("")}
      </div>
      ${(canReview || canManageOwn) ? `
        <div class="decision-strip">
          ${canReview ? `
            <button class="secondary-action" data-action="approve-event" data-id="${event.id}">Approva</button>
            <button class="danger-action" data-action="request-event-changes" data-id="${event.id}">Chiedi correzioni</button>
          ` : ""}
          ${canManageOwn ? `
            <button class="ghost-action" data-action="duplicate-event" data-id="${event.id}">Duplica</button>
            <button class="danger-action" data-action="cancel-event" data-id="${event.id}">Annulla</button>
          ` : ""}
        </div>
      ` : ""}
    </article>
  `;
}

function renderVouchers() {
  const vouchers = state.role === "admin" || state.role === "supervisor"
    ? state.vouchers
    : state.vouchers.filter((voucher) => voucher.orgId === state.organizationId);
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Gamification</p>
          <h2>Voucher, riscatti e regole convenzione</h2>
          <p>Validazione rapida per esercenti, controlli anti-abuso per supervisori e configurazione per amministratori.</p>
        </div>
        <button class="primary-action" data-action="validate-voucher">Valida voucher demo</button>
      </div>
      <div class="two-column">
        <article class="panel">
          <div class="panel-heading"><h3>Storico voucher</h3><span class="muted">${vouchers.length} record</span></div>
          <div class="table-like">
            <div class="table-row"><span>Codice</span><span>Stato</span><span>Valore</span></div>
            ${vouchers.map((voucher) => `
              <div class="table-row">
                <strong>${escapeHtml(voucher.code)}</strong>
                <span>${escapeHtml(voucher.status)}</span>
                <span>€${escapeHtml(voucher.amount)}</span>
              </div>
            `).join("")}
          </div>
        </article>
        <article class="panel">
          <div class="panel-heading"><h3>Regole convenzione</h3><span class="chip public">Attiva</span></div>
          <ul class="plain-list">
            <li><span>Voucher 5% e 10%</span><span class="muted">accettati</span></li>
            <li><span>Uso singolo per codice</span><span class="muted">obbligatorio</span></li>
            <li><span>Controllo doppia validazione</span><span class="muted">automatico</span></li>
            <li><span>Problemi voucher</span><span class="muted">ticket supervisore</span></li>
          </ul>
        </article>
      </div>
    </section>
  `;
}

function renderReports() {
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Cura del territorio</p>
          <h2>Segnalazioni, priorità e assegnazioni</h2>
          <p>La coda collega cittadino, supervisore, ufficio competente e vista sintetica per il Sindaco.</p>
        </div>
        <button class="primary-action" data-action="assign-report">Assegna urgente</button>
      </div>
      <div class="request-grid">
        ${state.reports.map((report) => `
          <div class="request-item">
            <div>
              <strong>${escapeHtml(report.title)}</strong>
              <p>${escapeHtml(report.area)} · priorità ${escapeHtml(report.priority)} · ${escapeHtml(report.status)}</p>
            </div>
            <span class="chip ${report.priority === "Alta" ? "review" : "draft"}">${escapeHtml(report.priority)}</span>
          </div>
        `).join("")}
      </div>
    </section>
  `;
}

function renderCommunications() {
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Comunicazioni</p>
          <h2>Avvisi, news e notifiche mirate</h2>
          <p>Ogni messaggio può essere pubblico, per cittadini, per turisti, per membri organizzazione o per ruoli comunali.</p>
        </div>
        <button class="primary-action" data-action="draft-communication">Nuova comunicazione</button>
      </div>
      <div class="three-column">
        ${[
          ["Avviso pubblico", "In revisione Sindaco", "review"],
          ["Messaggio ai volontari", "Programmato", "private"],
          ["Notifica evento weekend", "Bozza URP", "draft"],
        ].map(([title, status, cls]) => `
          <article class="panel">
            <div class="panel-heading"><h3>${title}</h3><span class="chip ${cls}">${status}</span></div>
            <p class="muted">Target, canale e approvazione cambiano in base al ruolo.</p>
          </article>
        `).join("")}
      </div>
    </section>
  `;
}

function renderOrganizations() {
  const rows = Object.entries(state.organizations);
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Registro locale</p>
          <h2>Attività, associazioni ed enti</h2>
          <p>Ogni organizzazione ha pagina, membri, permessi, eventi e regole di pubblicazione.</p>
        </div>
        <button class="primary-action" data-action="new-organization">Nuova organizzazione</button>
      </div>
      <div class="request-grid">
        ${rows.map(([id, org]) => `
          <div class="request-item">
            <div>
              <strong>${escapeHtml(org.name)}</strong>
              <p>${escapeHtml(org.type)} · ${escapeHtml(org.address)} · ${escapeHtml(org.status)}</p>
              <div class="chip-row" style="margin-top: 8px">
                <span class="chip">Eventi: ${state.events.filter((event) => event.orgId === id).length}</span>
                <span class="chip">Gruppi: ${state.groups.filter((group) => group.orgId === id).length}</span>
                <span class="chip">Membri: ${state.members.filter((member) => member.orgId === id).length}</span>
              </div>
            </div>
            <button class="secondary-action" data-action="select-org" data-id="${id}">Apri</button>
          </div>
        `).join("")}
      </div>
    </section>
  `;
}

function renderMembers() {
  const org = currentOrg();
  const groups = scopedRows(state.groups);
  const members = scopedRows(state.members);
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Gruppi organizzazione</p>
          <h2>Membri, direttivo, staff e invitati</h2>
          <p>I gruppi di ${escapeHtml(org.name)} determinano quali eventi interni e quali comunicazioni private possono essere viste.</p>
        </div>
        <button class="primary-action" data-action="invite-member">Invita membro</button>
      </div>
      <div class="two-column">
        <article class="panel">
          <div class="panel-heading">
            <h3>Gruppi</h3>
            <span class="muted">${groups.length} gruppi</span>
          </div>
          <div class="request-grid">
            ${groups.map((group) => `
              <div class="request-item">
                <div>
                  <strong>${escapeHtml(group.name)}</strong>
                  <p>${escapeHtml(group.visibility)}</p>
                </div>
                <span class="chip private">${group.members} membri</span>
              </div>
            `).join("") || `<p class="muted">Nessun gruppo per questo contesto.</p>`}
          </div>
        </article>
        <article class="panel">
          <div class="panel-heading">
            <h3>Membri</h3>
            <span class="muted">${members.length} persone</span>
          </div>
          <div class="request-grid">
            ${members.map((member) => `
              <div class="request-item">
                <div>
                  <strong>${escapeHtml(member.name)}</strong>
                  <p>${escapeHtml(member.group)} · ${escapeHtml(member.role)}</p>
                </div>
                <span class="chip">${escapeHtml(member.group)}</span>
              </div>
            `).join("") || `<p class="muted">Nessun membro per questo contesto.</p>`}
          </div>
        </article>
      </div>
      <article class="panel">
        <div class="panel-heading">
          <h3>Regole visibilità</h3>
          <span class="chip review">applicate agli eventi</span>
        </div>
        <div class="permission-grid">
          <div class="permission-row"><div><strong>Solo membri</strong><p>Visibile a tutti gli utenti collegati all'organizzazione.</p></div><span class="chip private">Privato</span></div>
          <div class="permission-row"><div><strong>Gruppo specifico</strong><p>Visibile solo a un gruppo, per esempio direttivo, staff o volontari.</p></div><span class="chip private">Mirato</span></div>
          <div class="permission-row"><div><strong>Su invito</strong><p>Visibile solo agli invitati, anche se non sono membri stabili.</p></div><span class="chip private">RSVP</span></div>
        </div>
      </article>
    </section>
  `;
}

function scopedRows(rows) {
  if (["admin", "supervisor", "mayor"].includes(state.role)) {
    return rows;
  }
  return rows.filter((row) => row.orgId === state.organizationId);
}

function renderStats() {
  const org = currentOrg();
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Statistiche</p>
          <h2>Andamento per pagina, eventi e servizi</h2>
          <p>Dati aggregati per capire interesse, efficacia delle comunicazioni e uso dei servizi senza profilazione invasiva.</p>
        </div>
        <button class="primary-action" data-action="export-stats">Esporta report</button>
      </div>
      <div class="three-column">
        <article class="panel">
          <div class="panel-heading"><h3>${escapeHtml(org.name)}</h3><span class="muted">30 giorni</span></div>
          <div class="mini-chart">
            ${bar("Visite", 82, 100)}
            ${bar("Click chiama", 38, 100)}
            ${bar("Indicazioni", 56, 100)}
            ${bar("Menu", 71, 100)}
          </div>
        </article>
        <article class="panel">
          <div class="panel-heading"><h3>Eventi</h3><span class="muted">visibilità</span></div>
          <div class="mini-chart">
            ${bar("Pubblici", state.events.filter((event) => event.visibility === "public").length, state.events.length)}
            ${bar("Interni", state.events.filter((event) => ["org_members", "group", "invite"].includes(event.visibility)).length, state.events.length)}
            ${bar("Istituzionali", state.events.filter((event) => ["municipal_internal", "council"].includes(event.visibility)).length, state.events.length)}
          </div>
        </article>
        <article class="panel">
          <div class="panel-heading"><h3>Servizi</h3><span class="muted">trend</span></div>
          <ul class="plain-list">
            <li><span>Segnalazioni chiuse</span><span class="chip public">81%</span></li>
            <li><span>Eventi approvati</span><span class="chip public">12</span></li>
            <li><span>Voucher validati</span><span class="chip">37</span></li>
          </ul>
        </article>
      </div>
    </section>
  `;
}

function bar(label, value, max) {
  const safeMax = Math.max(Number(max), 1);
  const percentage = Math.min(100, Math.round((Number(value) / safeMax) * 100));
  return `
    <div class="bar-row">
      <span>${escapeHtml(label)}</span>
      <div class="bar"><span style="width: ${percentage}%"></span></div>
      <strong>${escapeHtml(value)}</strong>
    </div>
  `;
}

function renderPermissions() {
  const rows = [
    ["Admin", "Tutto", "utenti, ruoli, configurazioni, audit"],
    ["Supervisore", "Operativo", "approvazioni, segnalazioni, eventi, anomalie"],
    ["Sindaco", "Decisionale", "KPI, priorità, comunicazioni da approvare"],
    ["Esercente", "Organizzazione propria", "pagina, menu, offerte, eventi e voucher"],
    ["Editor eventi", "Limitato", "crea eventi per organizzazione o gruppo"],
  ];
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">RBAC</p>
          <h2>Ruoli e permessi</h2>
          <p>La matrice separa lettura, modifica, approvazione e pubblicazione per ogni funzione.</p>
        </div>
        <button class="primary-action" data-action="mock-permissions">Modifica matrice</button>
      </div>
      <div class="permission-grid">
        ${rows.map(([role, scope, detail]) => `
          <div class="permission-row">
            <div>
              <strong>${role}</strong>
              <p>${detail}</p>
            </div>
            <span class="chip review">${scope}</span>
          </div>
        `).join("")}
      </div>
    </section>
  `;
}

function renderSupport() {
  workspace.innerHTML = `
    <section class="view-grid">
      <div class="hero-panel">
        <div>
          <p class="eyebrow">Assistenza</p>
          <h2>Richieste, problemi voucher e supporto contenuti</h2>
          <p>Un canale unico per chiedere supporto, segnalare problemi di validazione o richiedere modifiche non autonome.</p>
        </div>
        <button class="primary-action" data-action="open-ticket">Apri ticket</button>
      </div>
      <div class="two-column">
        <article class="panel">
          <div class="panel-heading"><h3>Ticket rapidi</h3><span class="muted">template</span></div>
          <ul class="plain-list">
            <li><span>Problema voucher</span><button class="secondary-action" data-action="open-ticket">Apri</button></li>
            <li><span>Richiesta cambio categoria</span><button class="secondary-action" data-action="open-ticket">Apri</button></li>
            <li><span>Evento bloccato in revisione</span><button class="secondary-action" data-action="open-ticket">Apri</button></li>
          </ul>
        </article>
        <article class="panel">
          <div class="panel-heading"><h3>Stato richieste</h3><span class="chip public">2 aperte</span></div>
          <ul class="plain-list">
            <li><span>Validazione voucher non riuscita</span><span class="muted">in carico</span></li>
            <li><span>Foto copertina da approvare</span><span class="muted">in revisione</span></li>
          </ul>
        </article>
      </div>
    </section>
  `;
}

function updateOrgField(input) {
  const org = currentOrg();
  const key = input.dataset.orgField;
  if (key === "services") {
    org.services = input.value.split(",").map((item) => item.trim()).filter(Boolean);
  } else if (key === "coverPositionX" || key === "coverPositionY") {
    org[key] = Number(input.value || 50);
  } else {
    org[key] = input.value;
  }
  const previewName = document.querySelector("[data-preview-name]");
  const previewShort = document.querySelector("[data-preview-short]");
  const previewServices = document.querySelector("[data-preview-services]");
  if (previewName) previewName.textContent = org.name;
  if (previewShort) previewShort.textContent = org.shortDescription;
  if (previewServices) {
    previewServices.innerHTML = org.services.map((service) => `<span class="chip">${escapeHtml(service)}</span>`).join("");
  }
  updateCoverPreview();
  saveState();
}

function updateCoverPreview() {
  const org = currentOrg();
  const style = coverStyle(org);
  document.querySelectorAll("[data-preview-cover], [data-cover-editor-preview]").forEach((element) => {
    element.setAttribute("style", style);
  });
}

function handleCoverFile(file) {
  if (!file || !file.type.startsWith("image/")) {
    showToast("Scegli un file immagine valido.");
    return;
  }
  const reader = new FileReader();
  reader.addEventListener("load", () => {
    currentOrg().coverImage = reader.result;
    const input = document.querySelector('[data-org-field="coverImage"]');
    if (input) input.value = reader.result;
    updateCoverPreview();
    saveState();
    showToast("Immagine caricata nella pagina.");
  });
  reader.readAsDataURL(file);
}

function addMenuItem() {
  const name = document.getElementById("menuName")?.value.trim();
  if (!name) {
    showToast("Inserisci un nome per la voce.");
    return;
  }
  state.menuItems.unshift({
    id: `m${Date.now()}`,
    orgId: state.organizationId,
    category: document.getElementById("menuCategory").value.trim() || "Catalogo",
    name,
    description: document.getElementById("menuDescription").value.trim(),
    price: document.getElementById("menuPrice").value.trim() || "0",
    tags: document.getElementById("menuTags").value.split(",").map((tag) => tag.trim()).filter(Boolean),
    active: true,
  });
  showToast("Voce aggiunta al menu/listino.");
  render();
}

function toggleMenuItem(id) {
  const item = state.menuItems.find((entry) => entry.id === id);
  if (item) {
    item.active = !item.active;
    showToast(item.active ? "Voce riattivata." : "Voce disattivata.");
    render();
  }
}

function removeMenuItem(id) {
  state.menuItems = state.menuItems.filter((item) => item.id !== id);
  showToast("Voce rimossa dal mockup.");
  render();
}

function updateVisibilityHelp() {
  const select = document.getElementById("eventVisibility");
  const help = document.getElementById("visibilityHelp");
  if (!select || !help) return;
  const item = visibilityCatalog[select.value];
  help.textContent = item.help;
  const isPublic = ["public", "org_page", "council"].includes(select.value);
  const isInternal = ["org_members", "group", "invite", "municipal_internal", "council"].includes(select.value);
  const placementCalendar = document.getElementById("placementCalendar");
  const placementMap = document.getElementById("placementMap");
  const placementInternal = document.getElementById("placementInternal");
  if (placementCalendar) placementCalendar.checked = select.value === "public" || select.value === "council";
  if (placementMap) placementMap.checked = select.value === "public";
  if (placementInternal) placementInternal.checked = isInternal && !isPublic;
}

function createEvent() {
  const title = document.getElementById("eventTitle")?.value.trim();
  if (!title) {
    showToast("Inserisci un titolo evento.");
    return;
  }
  const visibility = document.getElementById("eventVisibility").value;
  const placements = [];
  if (document.getElementById("placementPage").checked) placements.push("Pagina organizzazione");
  if (document.getElementById("placementCalendar").checked) placements.push("Calendario pubblico");
  if (document.getElementById("placementMap").checked) placements.push("Mappa");
  if (document.getElementById("placementInternal").checked) placements.push("Calendario interno");

  const needsReview = visibility === "public" || placements.includes("Calendario pubblico") || placements.includes("Mappa");
  const internal = ["org_members", "group", "invite", "municipal_internal", "council"].includes(visibility);
  state.events.unshift({
    id: `e${Date.now()}`,
    orgId: state.organizationId,
    title,
    type: document.getElementById("eventType").value,
    date: document.getElementById("eventDate").value,
    time: document.getElementById("eventTime").value,
    visibility,
    audience: document.getElementById("eventAudience").value.trim() || "Destinatari da definire",
    status: needsReview ? "In revisione" : internal ? "Pubblicato interno" : "Pubblicato",
    placements: placements.length ? placements : ["Calendario interno"],
    rsvp: document.getElementById("eventRsvp").value.trim() || "Nessun RSVP",
    description: document.getElementById("eventDescription").value.trim(),
    reviewNote: needsReview ? "Contenuto pubblico da controllare prima della pubblicazione." : "",
    owner: currentOrg().name,
    capacity: Number(document.getElementById("eventCapacity").value || 0),
    rsvpCount: Number(document.getElementById("eventRsvpCount").value || 0),
    checkinCount: 0,
    waitlistCount: 0,
    participationTrend: "nuovo",
  });
  showToast(needsReview ? "Evento creato e inviato in revisione." : "Evento creato con visibilità limitata.");
  render();
}

function updateEventStatus(id, status, message) {
  const event = state.events.find((entry) => entry.id === id);
  if (!event) return;
  event.status = status;
  event.reviewNote = message;
  showToast(message);
  render();
}

function duplicateEvent(id) {
  const event = state.events.find((entry) => entry.id === id);
  if (!event) return;
  state.events.unshift({
    ...event,
    id: `e${Date.now()}`,
    title: `${event.title} - copia`,
    status: event.visibility === "public" ? "In revisione" : "Bozza",
    reviewNote: "Evento duplicato da ricontrollare.",
  });
  showToast("Evento duplicato.");
  render();
}

function validateVoucher() {
  state.vouchers.unshift({
    code: `VCH-${Math.random().toString(36).slice(2, 8).toUpperCase()}`,
    orgId: state.organizationId,
    label: "Sconto demo",
    status: "Validato",
    date: "2026-05-01",
    amount: "5,20",
  });
  showToast("Voucher demo validato e registrato.");
  render();
}

function showToast(message) {
  document.querySelector(".toast")?.remove();
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = message;
  document.body.appendChild(toast);
  window.setTimeout(() => toast.remove(), 2400);
}

mainNav.addEventListener("click", (event) => {
  const button = event.target.closest("[data-view]");
  if (button) setView(button.dataset.view);
});

workspace.addEventListener("input", (event) => {
  if (event.target.matches("[data-org-field]")) {
    updateOrgField(event.target);
  }
});

workspace.addEventListener("change", (event) => {
  if (event.target.matches("[data-org-field]")) {
    updateOrgField(event.target);
  }
  if (event.target.id === "eventVisibility") {
    updateVisibilityHelp();
  }
  if (event.target.id === "coverFileInput") {
    handleCoverFile(event.target.files?.[0]);
  }
});

workspace.addEventListener("click", (event) => {
  const button = event.target.closest("[data-action]");
  if (!button) return;
  const action = button.dataset.action;
  const id = button.dataset.id;
  const actions = {
    "publish-page": () => showToast("Modifiche salvate. Le parti sensibili restano revisionabili."),
    "mock-upload": () => showToast("Upload simulato: qui apriremmo selezione foto."),
    "mock-reorder": () => showToast("Riordino simulato."),
    "add-menu-item": addMenuItem,
    "toggle-menu-item": () => toggleMenuItem(id),
    "remove-menu-item": () => removeMenuItem(id),
    "create-event": createEvent,
    "approve-event": () => updateEventStatus(id, "Pubblicato", "Evento approvato e pubblicato nei canali selezionati."),
    "request-event-changes": () => updateEventStatus(id, "Correzioni richieste", "Richieste correzioni all'organizzazione prima della pubblicazione."),
    "duplicate-event": () => duplicateEvent(id),
    "cancel-event": () => updateEventStatus(id, "Annullato", "Evento annullato nel mockup."),
    "validate-voucher": validateVoucher,
    "assign-report": () => showToast("Segnalazione urgente assegnata all'ufficio tecnico."),
    "draft-communication": () => showToast("Bozza comunicazione creata."),
    "new-organization": () => showToast("Creazione organizzazione: flusso da dettagliare."),
    "select-org": () => {
      state.organizationId = id;
      state.currentView = "page";
      render();
    },
    "invite-member": () => showToast("Invito membro simulato."),
    "export-stats": () => showToast("Export report simulato."),
    "mock-permissions": () => showToast("Modifica matrice permessi simulata."),
    "open-ticket": () => showToast("Ticket aperto nel mockup."),
    "use-demo-cover": () => {
      const org = currentOrg();
      const type = org.type === "Ristorante" ? "restaurant" : org.type === "Ente" ? "municipal" : "community";
      org.coverImage = demoCover(type);
      updateCoverPreview();
      saveState();
      render();
      showToast("Immagine demo applicata.");
    },
    "center-cover": () => {
      currentOrg().coverPositionX = 50;
      currentOrg().coverPositionY = 50;
      updateCoverPreview();
      saveState();
      render();
      showToast("Immagine centrata.");
    },
    "go-events": () => {
      state.currentView = "events";
      render();
    },
  };
  if (actions[action]) actions[action]();
});

roleSelect.addEventListener("change", (event) => setRole(event.target.value));

organizationSelect.addEventListener("change", (event) => {
  state.organizationId = event.target.value;
  render();
});

render();
